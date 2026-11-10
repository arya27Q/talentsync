<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentorProfile;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\MentoringAssignment;
use App\Models\MentoringAssignmentSubmission;
use App\Models\MentoringMessage;
use App\Models\Review;
use App\Models\MentorPremiumSubscription;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Support\Str;

class MentoringController extends Controller
{
    public function mentors(Request $request): JsonResponse
    {
        $mentors = User::query()
            ->whereHas('roleRecord', fn ($query) => $query->where('name', 'mentor'))
            ->whereHas('mentorProfile', fn ($query) => $query->where('verification_status', 'approved'))
            ->with('mentorProfile')
            ->when($request->filled('search'), fn ($query) => $query->where(function ($query) use ($request) {
                $term = '%'.$request->string('search')->trim().'%';
                $query->where('name', 'like', $term)
                    ->orWhereHas('mentorProfile', fn ($profile) => $profile
                        ->where('title_headline', 'like', $term)
                        ->orWhere('bio', 'like', $term));
            }))
            ->orderBy('name')
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $mentors->getCollection()->map(fn (User $mentor) => [
                'id' => $mentor->id,
                'name' => $mentor->name,
                'title_headline' => $mentor->mentorProfile?->title_headline,
                'bio' => $mentor->mentorProfile?->bio,
                'hourly_rate_tc' => $mentor->mentorProfile?->hourly_rate_tc,
                'rating' => (float) ($mentor->mentorProfile?->rating_average ?? 0),
                'is_premium' => $this->isPremiumProfile($mentor->mentorProfile),
            ]),
            'meta' => [
                'current_page' => $mentors->currentPage(),
                'last_page' => $mentors->lastPage(),
                'per_page' => $mentors->perPage(),
                'total' => $mentors->total(),
            ],
        ]);
    }

    public function classes(Request $request): JsonResponse
    {
        $classes = MentoringClass::query()
            ->with(['mentor:id,name'])
            ->withCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])])
            ->where('status', 'open')
            ->whereHas('mentor.roleRecord', fn ($query) => $query->where('name', 'mentor'))
            ->whereHas('mentor.mentorProfile', fn ($query) => $query->where('verification_status', 'approved'))
            ->where('scheduled_time', '>=', now())
            ->whereRaw('(select count(*) from mentoring_enrollments where mentoring_enrollments.class_id = mentoring_classes.id and mentoring_enrollments.status not in (?, ?)) < mentoring_classes.capacity', ['absent', 'declined'])
            ->when($request->filled('mentor_id'), fn ($query) => $query->where('mentor_id', $request->integer('mentor_id')))
            ->when($request->filled('topic'), fn ($query) => $query->where('topic', 'like', '%'.$request->string('topic')->trim().'%'))
            ->orderBy('scheduled_time')
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $classes->getCollection()->map(fn (MentoringClass $class) => $this->classData($class)),
            'meta' => ['current_page' => $classes->currentPage(), 'last_page' => $classes->lastPage()],
        ]);
    }

    public function showClass(MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless(MentorProfile::where('user_id', $mentoringClass->mentor_id)->where('verification_status', 'approved')->exists(), 404);
        $mentoringClass->load('mentor:id,name');
        $mentoringClass->loadCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])]);

        return response()->json(['status' => 'success', 'data' => $this->classData($mentoringClass)]);
    }

    public function mentorProfile(Request $request): JsonResponse
    {
        $profile = MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);

        return response()->json(['status' => 'success', 'data' => $this->profileData($profile)]);
    }

    public function verificationStatus(Request $request): JsonResponse
    {
        $profile = MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);

        return response()->json(['status' => 'success', 'data' => [
            'verification_status' => $profile->verification_status,
            'rejection_reason' => $profile->verification_rejection_reason,
        ]]);
    }

    public function mentorDashboard(Request $request): JsonResponse
    {
        $mentorId = $request->user()->id;
        $classIds = MentoringClass::query()->where('mentor_id', $mentorId)->select('id');
        $balance = TimeCoinWallet::where('user_id', $mentorId)->value('balance') ?? 0;

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => $balance,
                'estimated_idr' => $balance * 1000,
                'new_bookings' => MentoringEnrollment::whereIn('class_id', $classIds)->where('status', 'pending')->count(),
                'scheduled_bookings' => MentoringEnrollment::whereIn('class_id', $classIds)->where('status', 'accepted')->count(),
                'needs_review' => MentoringEnrollment::whereIn('class_id', $classIds)->where('status', 'attended')->count(),
                'endorsement_requests' => MentoringEnrollment::whereIn('class_id', $classIds)
                    ->where('status', 'completed')
                    ->where('assessment_score', '>=', 80)
                    ->where('has_endorsement', false)
                    ->count(),
            ],
        ]);
    }

    public function mentorClasses(Request $request): JsonResponse
    {
        $classes = MentoringClass::query()
            ->with('mentor:id,name')
            ->withCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])])
            ->where('mentor_id', $request->user()->id)
            ->orderByDesc('scheduled_time')
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $classes->getCollection()->map(fn (MentoringClass $class) => $this->classData($class, true)),
            'meta' => ['current_page' => $classes->currentPage(), 'last_page' => $classes->lastPage()],
        ]);
    }

    public function updateMentorProfile(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title_headline' => ['sometimes', 'nullable', 'string', 'max:150'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'hourly_rate_tc' => ['sometimes', 'integer', 'min:1', 'max:100000'],
            'verification_document_url' => ['sometimes', 'url', 'max:2048'],
            'portfolio_url' => ['sometimes', 'url', 'max:2048'],
        ]);

        $profile = MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);
        if (array_key_exists('verification_document_url', $data) || array_key_exists('portfolio_url', $data)) {
            $data['verification_status'] = 'pending';
            $data['verification_rejection_reason'] = null;
            $data['verification_reviewed_by'] = null;
            $data['verification_reviewed_at'] = null;
        }
        $profile->fill($data)->save();

        return response()->json(['status' => 'success', 'message' => 'Profil mentor berhasil diperbarui.', 'data' => $this->profileData($profile->fresh())]);
    }

    public function subscribePremium(Request $request): JsonResponse
    {
        $subscription = DB::transaction(function () use ($request) {
            $profile = MentorProfile::where('user_id', $request->user()->id)->lockForUpdate()->firstOrFail();
            $premiumActive = $profile->is_premium && (! $profile->premium_expires_at || $profile->premium_expires_at->isFuture());
            abort_if($premiumActive, 409, 'Paket Premium mentor masih aktif.');
            abort_if(MentorPremiumSubscription::where('mentor_id', $request->user()->id)->where('payment_status', 'pending')->exists(), 409, 'Sudah ada pengajuan Premium yang menunggu pembayaran.');

            return MentorPremiumSubscription::create([
                'mentor_id' => $request->user()->id,
                'amount_idr' => 50000,
                'payment_status' => 'pending',
                'payment_reference' => 'TS-MP-'.Str::upper(Str::random(12)),
            ]);
        }, 3);

        return response()->json([
            'status' => 'success',
            'message' => 'Pengajuan Premium dibuat dan menunggu verifikasi pembayaran admin.',
            'data' => [
                'id' => $subscription->id,
                'amount_idr' => $subscription->amount_idr,
                'payment_status' => $subscription->payment_status,
                'payment_reference' => $subscription->payment_reference,
            ],
        ], 201);
    }

    public function premiumSubscriptions(Request $request): JsonResponse
    {
        $subscriptions = MentorPremiumSubscription::where('mentor_id', $request->user()->id)
            ->latest()
            ->paginate(10);

        return response()->json(['status' => 'success', 'data' => $subscriptions]);
    }

    public function reviewMentorVerification(Request $request, User $mentor): JsonResponse
    {
        abort_unless($mentor->hasRole('mentor'), 404);
        $data = $request->validate([
            'verification_status' => ['required', Rule::in(['approved', 'rejected'])],
            'rejection_reason' => ['required_if:verification_status,rejected', 'nullable', 'string', 'max:2000'],
        ]);
        $profile = MentorProfile::where('user_id', $mentor->id)->firstOrFail();
        $profile->update([
            'verification_status' => $data['verification_status'],
            'verification_rejection_reason' => $data['verification_status'] === 'rejected' ? $data['rejection_reason'] : null,
            'verification_reviewed_by' => $request->user()->id,
            'verification_reviewed_at' => now(),
        ]);

        return response()->json(['status' => 'success', 'message' => 'Status verifikasi mentor diperbarui.', 'data' => [
            'mentor_id' => $mentor->id,
            'verification_status' => $profile->verification_status,
        ]]);
    }

    public function pendingMentorVerifications(): JsonResponse
    {
        $mentors = User::query()
            ->whereHas('roleRecord', fn ($query) => $query->where('name', 'mentor'))
            ->whereHas('mentorProfile', fn ($query) => $query->where('verification_status', 'pending'))
            ->with('mentorProfile:user_id,title_headline,bio,verification_document_url,portfolio_url,verification_status')
            ->orderBy('id')
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $mentors->getCollection()->map(fn (User $mentor) => [
                'id' => $mentor->id,
                'name' => $mentor->name,
                'email' => $mentor->email,
                'profile' => [
                    'title_headline' => $mentor->mentorProfile->title_headline,
                    'bio' => $mentor->mentorProfile->bio,
                    'verification_document_url' => $mentor->mentorProfile->verification_document_url,
                    'portfolio_url' => $mentor->mentorProfile->portfolio_url,
                ],
            ]),
            'meta' => ['current_page' => $mentors->currentPage(), 'last_page' => $mentors->lastPage()],
        ]);
    }

    public function pendingPremiumSubscriptions(): JsonResponse
    {
        $subscriptions = MentorPremiumSubscription::with('mentor:id,name,email')
            ->where('payment_status', 'pending')
            ->latest()
            ->paginate(20);

        return response()->json(['status' => 'success', 'data' => $subscriptions]);
    }

    public function resolvePremiumSubscription(Request $request, MentorPremiumSubscription $subscription): JsonResponse
    {
        $data = $request->validate(['payment_status' => ['required', Rule::in(['paid', 'failed'])]]);
        $result = DB::transaction(function () use ($request, $subscription, $data) {
            $record = MentorPremiumSubscription::query()->lockForUpdate()->findOrFail($subscription->id);
            abort_unless($record->payment_status === 'pending', 409, 'Pengajuan ini sudah diproses.');
            $record->update([
                'payment_status' => $data['payment_status'],
                'processed_by' => $request->user()->id,
                'starts_at' => $data['payment_status'] === 'paid' ? now() : null,
                'expires_at' => $data['payment_status'] === 'paid' ? now()->addMonthNoOverflow() : null,
            ]);

            if ($data['payment_status'] === 'paid') {
                MentorProfile::where('user_id', $record->mentor_id)->update([
                    'is_premium' => true,
                    'premium_expires_at' => $record->expires_at,
                ]);
            }

            return $record->fresh();
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Status pembayaran Premium diperbarui.', 'data' => [
            'id' => $result->id,
            'payment_status' => $result->payment_status,
            'expires_at' => $result->expires_at,
        ]]);
    }

    public function storeClass(Request $request): JsonResponse
    {
        $data = $request->validate([
            'topic' => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:10000'],
            'scheduled_time' => ['required', 'date', 'after:now'],
            'duration_minutes' => ['sometimes', 'integer', 'min:15', 'max:480'],
            'price_tc' => ['required', 'integer', 'min:1', 'max:100000'],
            'meeting_link' => ['nullable', 'url', 'max:2048'],
            'capacity' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);
        $data['mentor_id'] = $request->user()->id;
        $class = MentoringClass::create($data);
        MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);
        $class->load('mentor:id,name', 'mentor.mentorProfile');

        return response()->json(['status' => 'success', 'message' => 'Kelas mentoring berhasil dibuat.', 'data' => $this->classData($class, true)], 201);
    }

    public function updateClass(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless($mentoringClass->mentor_id === $request->user()->id, 403);
        $data = $request->validate([
            'topic' => ['sometimes', 'required', 'string', 'max:200'],
            'description' => ['sometimes', 'nullable', 'string', 'max:10000'],
            'scheduled_time' => ['sometimes', 'required', 'date', 'after:now'],
            'duration_minutes' => ['sometimes', 'integer', 'min:15', 'max:480'],
            'price_tc' => ['sometimes', 'required', 'integer', 'min:1', 'max:100000'],
            'meeting_link' => ['sometimes', 'nullable', 'url', 'max:2048'],
            'capacity' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'status' => ['sometimes', Rule::in(['open', 'completed', 'cancelled'])],
        ]);
        if (($data['status'] ?? null) === 'completed') {
            abort_unless($mentoringClass->scheduled_time->copy()->addMinutes($mentoringClass->duration_minutes)->isPast(), 409, 'Kelas hanya dapat diselesaikan setelah jadwalnya.');
        }
        if ($mentoringClass->enrollments()->exists()) {
            abort_if(array_diff(array_keys($data), ['status']) !== [], 409, 'Jadwal atau tarif tidak dapat diubah setelah ada pendaftar.');
            abort_unless(($data['status'] ?? null) === 'completed', 409, 'Kelas dengan pendaftar hanya dapat ditandai selesai.');
            abort_if($mentoringClass->enrollments()->whereIn('status', ['pending', 'accepted', 'attended', 'pending_confirmation'])->exists(), 409, 'Selesaikan seluruh booking sebelum menutup kelas.');
        }
        $mentoringClass->update($data);

        $mentoringClass->load('mentor:id,name', 'mentor.mentorProfile');

        return response()->json(['status' => 'success', 'message' => 'Kelas mentoring berhasil diperbarui.', 'data' => $this->classData($mentoringClass->fresh('mentor.mentorProfile'))]);
    }

    public function deleteClass(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless($mentoringClass->mentor_id === $request->user()->id, 403);
        abort_if($mentoringClass->enrollments()->exists(), 409, 'Kelas yang memiliki riwayat pendaftar tidak dapat dihapus.');
        $mentoringClass->delete();

        return response()->json(['status' => 'success', 'message' => 'Kelas mentoring berhasil dihapus.']);
    }

    public function book(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        $student = $request->user();

        try {
            $result = DB::transaction(function () use ($mentoringClass, $student) {
                $class = MentoringClass::query()->lockForUpdate()->findOrFail($mentoringClass->id);
                abort_unless($class->status === 'open' && $class->scheduled_time->isFuture(), 409, 'Kelas ini sudah tidak menerima pendaftaran.');

                $studentWallet = TimeCoinWallet::where('user_id', $student->id)->lockForUpdate()->first();
                abort_if(! $studentWallet, 422, 'Dompet TimeCoin belum tersedia.');

                abort_if($studentWallet->balance < $class->price_tc, 422, 'Saldo TimeCoin tidak mencukupi.');
                $enrolledCount = $class->enrollments()->where('status', '!=', 'absent')->count();
                abort_if($enrolledCount >= $class->capacity, 409, 'Kuota kelas sudah penuh.');

                $enrollment = MentoringEnrollment::create([
                    'class_id' => $class->id,
                    'student_id' => $student->id,
                    'paid_tc' => $class->price_tc,
                    'status' => 'pending',
                ]);
                $studentWallet->decrement('balance', $class->price_tc);
                $studentWallet->increment('locked_balance', $class->price_tc);

                foreach ([['debit', 'balance'], ['escrow_credit', 'locked_balance']] as [$direction, $ledgerAccount]) {
                    TimeCoinTransaction::create([
                        'wallet_id' => $studentWallet->id,
                        'sender_id' => $student->id,
                        'recipient_id' => $class->mentor_id,
                        'transaction_type' => 'mentoring_payment',
                        'direction' => $direction,
                        'ledger_account' => $ledgerAccount,
                        'amount' => $class->price_tc,
                        'reference_type' => MentoringEnrollment::class,
                        'reference_id' => $enrollment->id,
                        'status' => 'completed',
                    ]);
                }

                return [$class, $enrollment];
            }, 3);
        } catch (QueryException $exception) {
            if (MentoringEnrollment::where('class_id', $mentoringClass->id)->where('student_id', $student->id)->exists()) {
                return response()->json(['status' => 'error', 'message' => 'Anda sudah terdaftar pada kelas ini.'], 409);
            }

            throw $exception;
        }

        [$class, $enrollment] = $result;

        return response()->json([
            'status' => 'success',
            'message' => "Permintaan bimbingan berhasil dikirim. {$class->price_tc} TC ditahan sementara sampai sesi selesai dikonfirmasi.",
            'data' => ['enrollment_id' => $enrollment->id, 'status' => $enrollment->status, 'scheduled_time' => $class->scheduled_time],
        ], 201);
    }

    public function myEnrollments(Request $request): JsonResponse
    {
        $enrollments = MentoringEnrollment::query()
            ->with(['mentoringClass.mentor:id,name'])
            ->where('student_id', $request->user()->id)
            ->latest()
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $enrollments->getCollection()->map(fn (MentoringEnrollment $enrollment) => [
                'id' => $enrollment->id,
                'status' => $enrollment->status,
                'paid_tc' => $enrollment->paid_tc,
                'has_endorsement' => $enrollment->has_endorsement,
                'endorsement_notes' => $enrollment->endorsement_notes,
                'class' => $this->classData($enrollment->mentoringClass, in_array($enrollment->status, ['accepted', 'attended', 'pending_confirmation', 'completed'], true)),
            ]),
            'meta' => ['current_page' => $enrollments->currentPage(), 'last_page' => $enrollments->lastPage()],
        ]);
    }

    public function mentorEnrollments(Request $request): JsonResponse
    {
        $enrollments = MentoringEnrollment::query()
            ->with(['student:id,name,email', 'mentoringClass:id,mentor_id,topic,scheduled_time'])
            ->whereHas('mentoringClass', fn ($query) => $query->where('mentor_id', $request->user()->id))
            ->latest()
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $enrollments->getCollection()->map(fn (MentoringEnrollment $enrollment) => $this->enrollmentData($enrollment, true)),
            'meta' => ['current_page' => $enrollments->currentPage(), 'last_page' => $enrollments->lastPage()],
        ]);
    }

    public function decideBooking(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $data = $request->validate(['decision' => ['required', Rule::in(['accepted', 'declined'])]]);
        $result = DB::transaction(function () use ($request, $enrollment, $data) {
            $lockedEnrollment = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            $class = MentoringClass::findOrFail($lockedEnrollment->class_id);
            abort_unless($class->mentor_id === $request->user()->id, 403);
            abort_unless($lockedEnrollment->status === 'pending', 409, 'Booking ini sudah diproses.');
            if ($data['decision'] === 'accepted') {
                abort_unless($class->scheduled_time->isFuture(), 409, 'Booking tidak dapat diterima setelah jadwal dimulai.');
            }
            $lockedEnrollment->update(['status' => $data['decision']]);

            if ($data['decision'] === 'declined') {
                $this->refundEscrow($lockedEnrollment, $class->mentor_id);
            }

            return $lockedEnrollment->fresh();
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Keputusan booking berhasil disimpan.', 'data' => $this->enrollmentData($result)]);
    }

    public function submitAssessment(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $data = $request->validate([
            'score' => ['required', 'integer', 'min:0', 'max:100'],
            'mentor_feedback' => ['required', 'string', 'min:5', 'max:5000'],
        ]);
        $lockedEnrollment = DB::transaction(function () use ($request, $enrollment, $data) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            abort_unless($record->mentoringClass()->where('mentor_id', $request->user()->id)->exists(), 403);
            abort_unless($record->status === 'attended', 409, 'Penilaian hanya dapat diberikan setelah sesi dihadiri.');
            abort_unless($record->mentoringClass->scheduled_time->copy()->addMinutes($record->mentoringClass->duration_minutes)->isPast(), 409, 'Sesi belum selesai.');
            $record->update([
                'assessment_score' => $data['score'],
                'mentor_feedback' => $data['mentor_feedback'],
                'status' => 'pending_confirmation',
            ]);

            return $record->fresh();
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Hasil evaluasi dikirim untuk konfirmasi mahasiswa.', 'data' => $this->enrollmentData($lockedEnrollment)]);
    }

    public function confirmCompletion(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $data = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'review_text' => ['nullable', 'string', 'max:2000'],
        ]);
        $completed = DB::transaction(function () use ($request, $enrollment, $data) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            abort_unless($record->student_id === $request->user()->id, 403);
            abort_unless($record->status === 'pending_confirmation', 409, 'Sesi belum menunggu konfirmasi penyelesaian.');
            $class = MentoringClass::findOrFail($record->class_id);
            $studentWallet = TimeCoinWallet::where('user_id', $record->student_id)->lockForUpdate()->firstOrFail();
            $mentorWallet = TimeCoinWallet::firstOrCreate(['user_id' => $class->mentor_id]);
            $mentorWallet = TimeCoinWallet::whereKey($mentorWallet->id)->lockForUpdate()->firstOrFail();
            abort_if($studentWallet->locked_balance < $record->paid_tc, 409, 'Saldo escrow tidak sesuai dengan booking.');

            $studentWallet->decrement('locked_balance', $record->paid_tc);
            $mentorWallet->increment('balance', $record->paid_tc);
            $record->update(['status' => 'completed', 'student_confirmed_at' => now()]);
            $this->recordCoinEntry($studentWallet, $record->student_id, $class->mentor_id, 'mentoring_payment', 'escrow_debit', 'locked_balance', $record->paid_tc, $record);
            $this->recordCoinEntry($mentorWallet, $record->student_id, $class->mentor_id, 'mentoring_payment', 'credit', 'balance', $record->paid_tc, $record);

            Review::create([
                'reviewer_id' => $record->student_id,
                'reviewee_id' => $class->mentor_id,
                'mentoring_class_id' => $class->id,
                'rating' => $data['rating'],
                'review_text' => $data['review_text'] ?? null,
            ]);
            $average = Review::where('reviewee_id', $class->mentor_id)
                ->whereNotNull('mentoring_class_id')
                ->avg('rating');
            MentorProfile::firstOrCreate(['user_id' => $class->mentor_id])->update(['rating_average' => $average]);

            return $record->fresh();
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Sesi selesai dan saldo escrow telah diteruskan ke mentor.', 'data' => $this->enrollmentData($completed)]);
    }

    public function messages(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $this->authorizeEnrollmentParticipant($request, $enrollment);

        return response()->json([
            'status' => 'success',
            'data' => $enrollment->messages()->with('sender:id,name')->oldest()->paginate(50),
        ]);
    }

    public function sendMessage(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $this->authorizeEnrollmentParticipant($request, $enrollment);
        abort_if(in_array($enrollment->status, ['declined', 'absent'], true), 409, 'Percakapan sudah ditutup.');
        $data = $request->validate([
            'message' => ['nullable', 'required_without:attachment_url', 'string', 'max:10000'],
            'attachment_url' => ['nullable', 'required_without:message', 'url', 'max:2048'],
        ]);
        $message = $enrollment->messages()->create([
            ...$data,
            'sender_id' => $request->user()->id,
        ])->load('sender:id,name');

        return response()->json(['status' => 'success', 'data' => $message], 201);
    }

    public function createAssignment(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless($mentoringClass->mentor_id === $request->user()->id, 403);
        abort_unless($mentoringClass->status === 'open', 409, 'Tugas hanya dapat dibuat untuk kelas yang masih aktif.');
        $data = $request->validate([
            'title' => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:10000'],
            'due_at' => ['nullable', 'date', 'after:now'],
        ]);
        $assignment = $mentoringClass->assignments()->create([...$data, 'mentor_id' => $request->user()->id]);

        return response()->json(['status' => 'success', 'data' => $assignment], 201);
    }

    public function enrollmentAssignments(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $this->authorizeEnrollmentParticipant($request, $enrollment);
        $studentView = $enrollment->student_id === $request->user()->id;
        $assignments = MentoringAssignment::query()
            ->where('class_id', $enrollment->class_id)
            ->with(['submissions' => fn ($query) => $studentView ? $query->where('student_id', $request->user()->id) : $query->with('student:id,name')])
            ->orderBy('created_at')
            ->get();

        return response()->json(['status' => 'success', 'data' => $assignments->map(fn (MentoringAssignment $assignment) => [
            'id' => $assignment->id,
            'title' => $assignment->title,
            'description' => $assignment->description,
            'due_at' => $assignment->due_at,
            'submissions' => $assignment->submissions->map(fn (MentoringAssignmentSubmission $submission) => [
                'id' => $submission->id,
                'student_id' => $submission->student_id,
                'student_name' => $submission->student?->name,
                'submission_notes' => $submission->submission_notes,
                'deliverable_url' => $submission->deliverable_url,
                'score' => $submission->score,
                'feedback' => $submission->feedback,
                'status' => $submission->status,
            ]),
        ])]);
    }

    public function submitAssignment(Request $request, MentoringAssignment $assignment): JsonResponse
    {
        $data = $request->validate([
            'submission_notes' => ['nullable', 'string', 'max:5000'],
            'deliverable_url' => ['nullable', 'required_without:submission_notes', 'url', 'max:2048'],
        ]);
        $enrollment = MentoringEnrollment::where('class_id', $assignment->class_id)
            ->where('student_id', $request->user()->id)
            ->whereIn('status', ['accepted', 'attended'])
            ->firstOrFail();
        abort_if($assignment->due_at?->isPast(), 409, 'Batas waktu pengumpulan tugas sudah lewat.');
        $submission = DB::transaction(function () use ($assignment, $request, $data) {
            $existing = MentoringAssignmentSubmission::where('assignment_id', $assignment->id)
                ->where('student_id', $request->user()->id)
                ->lockForUpdate()
                ->first();
            abort_if($existing && $existing->status !== 'revision_requested', 409, 'Tugas ini sudah dikumpulkan dan menunggu penilaian.');

            if ($existing) {
                $existing->update([...$data, 'status' => 'submitted', 'score' => null, 'feedback' => null]);

                return $existing->fresh();
            }

            return MentoringAssignmentSubmission::create([
                ...$data,
                'assignment_id' => $assignment->id,
                'student_id' => $request->user()->id,
                'status' => 'submitted',
            ]);
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Tugas berhasil dikumpulkan.', 'data' => $submission], 201);
    }

    public function reviewAssignment(Request $request, MentoringAssignmentSubmission $submission): JsonResponse
    {
        $data = $request->validate([
            'score' => ['required', 'integer', 'min:0', 'max:100'],
            'feedback' => ['required', 'string', 'min:3', 'max:5000'],
            'decision' => ['required', Rule::in(['reviewed', 'revision_requested'])],
        ]);
        abort_unless($submission->assignment()->where('mentor_id', $request->user()->id)->exists(), 403);
        abort_unless($submission->status === 'submitted', 409, 'Tugas ini tidak sedang menunggu penilaian.');
        $submission->update([
            'score' => $data['score'],
            'feedback' => $data['feedback'],
            'status' => $data['decision'],
        ]);

        return response()->json(['status' => 'success', 'message' => 'Penilaian tugas berhasil disimpan.', 'data' => $submission->fresh()]);
    }

    public function updateAttendance(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        abort_unless($enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(), 403);
        abort_unless($enrollment->status === 'accepted', 409, 'Hanya booking yang diterima mentor dapat dicatat kehadirannya.');
        abort_unless($enrollment->mentoringClass->scheduled_time->copy()->addMinutes($enrollment->mentoringClass->duration_minutes)->isPast(), 409, 'Kehadiran hanya dapat dicatat setelah sesi selesai.');
        $data = $request->validate(['status' => ['required', Rule::in(['attended', 'absent'])]]);
        DB::transaction(function () use ($enrollment, $data, $request) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            abort_unless($record->status === 'accepted', 409, 'Kehadiran pendaftar ini sudah dicatat.');
            $record->update($data);
            if ($data['status'] === 'absent') {
                $this->refundEscrow($record, $request->user()->id);
            }
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Kehadiran berhasil diperbarui.', 'data' => $this->enrollmentData($enrollment->fresh(['student', 'mentoringClass']))]);
    }

    public function endorse(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        abort_unless($enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(), 403);
        abort_unless($enrollment->status === 'completed' && $enrollment->assessment_score >= 80, 409, 'Endorsement mensyaratkan sesi selesai dan nilai minimal 80.');
        abort_if($enrollment->has_endorsement, 409, 'Murid ini sudah menerima endorsement untuk sesi tersebut.');
        $data = $request->validate(['endorsement_notes' => ['required', 'string', 'min:10', 'max:2000']]);
        $enrollment->update(['has_endorsement' => true, 'endorsement_notes' => $data['endorsement_notes']]);

        return response()->json(['status' => 'success', 'message' => 'Badge Rekomendasi Kerja berhasil disematkan ke portofolio mahasiswa.', 'data' => $this->enrollmentData($enrollment->fresh(['student', 'mentoringClass']))]);
    }

    private function profileData(MentorProfile $profile): array
    {
        return [
            'user_id' => $profile->user_id,
            'title_headline' => $profile->title_headline,
            'bio' => $profile->bio,
            'hourly_rate_tc' => $profile->hourly_rate_tc,
            'is_premium' => $this->isPremiumProfile($profile),
            'verification_status' => $profile->verification_status,
            'premium_expires_at' => $profile->premium_expires_at,
            'cashout_fee_percent' => $this->isPremiumProfile($profile) ? 0 : 10,
            'rating_average' => (float) $profile->rating_average,
        ];
    }

    private function enrollmentData(MentoringEnrollment $enrollment, bool $includeStudent = false): array
    {
        $data = [
            'id' => $enrollment->id,
            'class_id' => $enrollment->class_id,
            'student_id' => $enrollment->student_id,
            'paid_tc' => $enrollment->paid_tc,
            'status' => $enrollment->status,
            'has_endorsement' => $enrollment->has_endorsement,
            'endorsement_notes' => $enrollment->endorsement_notes,
            'assessment_score' => $enrollment->assessment_score,
            'mentor_feedback' => $enrollment->mentor_feedback,
            'student_confirmed_at' => $enrollment->student_confirmed_at,
            'class' => $enrollment->relationLoaded('mentoringClass') ? [
                'id' => $enrollment->mentoringClass->id,
                'topic' => $enrollment->mentoringClass->topic,
                'scheduled_time' => $enrollment->mentoringClass->scheduled_time,
            ] : null,
        ];

        if ($includeStudent && $enrollment->relationLoaded('student')) {
            $data['student'] = [
                'id' => $enrollment->student->id,
                'name' => $enrollment->student->name,
                'email' => $enrollment->student->email,
            ];
        }

        return $data;
    }

    private function classData(MentoringClass $class, bool $includeMeetingLink = false): array
    {
        return [
            'id' => $class->id,
            'mentor_id' => $class->mentor_id,
            'mentor_name' => $class->mentor?->name,
            'title_headline' => $class->mentor?->mentorProfile?->title_headline,
            'topic' => $class->topic,
            'description' => $class->description,
            'scheduled_time' => $class->scheduled_time,
            'duration_minutes' => $class->duration_minutes,
            'price_tc' => $class->price_tc,
            'meeting_link' => $includeMeetingLink ? $class->meeting_link : null,
            'capacity' => $class->capacity,
            'enrolled_count' => $class->enrolled_count ?? null,
            'status' => $class->status,
        ];
    }

    private function refundEscrow(MentoringEnrollment $enrollment, int $mentorId): void
    {
        $wallet = TimeCoinWallet::where('user_id', $enrollment->student_id)->lockForUpdate()->firstOrFail();
        abort_if($wallet->locked_balance < $enrollment->paid_tc, 409, 'Saldo escrow tidak sesuai dengan booking.');
        $wallet->decrement('locked_balance', $enrollment->paid_tc);
        $wallet->increment('balance', $enrollment->paid_tc);
        $this->recordCoinEntry($wallet, $mentorId, $enrollment->student_id, 'mentoring_refund', 'escrow_debit', 'locked_balance', $enrollment->paid_tc, $enrollment);
        $this->recordCoinEntry($wallet, $mentorId, $enrollment->student_id, 'mentoring_refund', 'credit', 'balance', $enrollment->paid_tc, $enrollment);
    }

    private function recordCoinEntry(
        TimeCoinWallet $wallet,
        int $senderId,
        int $recipientId,
        string $type,
        string $direction,
        string $ledgerAccount,
        int $amount,
        MentoringEnrollment $enrollment,
    ): void {
        TimeCoinTransaction::create([
            'wallet_id' => $wallet->id,
            'sender_id' => $senderId,
            'recipient_id' => $recipientId,
            'transaction_type' => $type,
            'direction' => $direction,
            'ledger_account' => $ledgerAccount,
            'amount' => $amount,
            'reference_type' => MentoringEnrollment::class,
            'reference_id' => $enrollment->id,
            'status' => 'completed',
        ]);
    }

    private function authorizeEnrollmentParticipant(Request $request, MentoringEnrollment $enrollment): void
    {
        if ($request->user()->hasRole('mentor')) {
            abort_unless($request->user()->mentorProfile?->verification_status === 'approved', 403, 'Akun mentor belum terverifikasi.');
        }

        abort_unless(
            $enrollment->student_id === $request->user()->id
                || $enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(),
            403,
        );
    }

    private function isPremiumProfile(?MentorProfile $profile): bool
    {
        return (bool) $profile?->is_premium
            && (! $profile->premium_expires_at || $profile->premium_expires_at->isFuture());
    }
}
