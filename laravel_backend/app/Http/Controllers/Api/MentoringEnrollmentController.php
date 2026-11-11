<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentoringActionItem;
use App\Models\MentoringAssignment;
use App\Models\MentoringAssignmentSubmission;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\MentoringMaterial;
use App\Models\MentorProfile;
use App\Models\Portfolio;
use App\Models\Review;
use App\Models\StudentCertificate;
use App\Models\TimeCoinWallet;
use App\Services\NotificationDispatcher;
use App\Services\TimeCoinLedgerService;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class MentoringEnrollmentController extends Controller
{
    public function __construct(
        private readonly TimeCoinLedgerService $ledger,
        private readonly NotificationDispatcher $notifications,
    ) {
    }

    public function book(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        $student = $request->user();
        $data = $request->validate([
            'topic_focus' => ['nullable', 'string', 'max:200'],
            'student_notes' => ['nullable', 'string', 'max:2000'],
            'materials_url' => ['nullable', 'url', 'max:2048'],
        ]);

        try {
            $result = DB::transaction(function () use ($mentoringClass, $student, $data) {
                $class = MentoringClass::query()->lockForUpdate()->findOrFail($mentoringClass->id);
                abort_unless($class->status === 'open' && $class->scheduled_time->isFuture(), 409, 'Kelas ini sudah tidak menerima pendaftaran.');

                $studentWallet = TimeCoinWallet::where('user_id', $student->id)->lockForUpdate()->first();
                abort_if(! $studentWallet, 422, 'Dompet TimeCoin belum tersedia.');
                abort_if($studentWallet->balance < $class->price_tc, 422, 'Saldo TimeCoin tidak mencukupi.');
                $enrolledCount = $class->enrollments()->whereNotIn('status', ['absent', 'declined'])->count();
                abort_if($enrolledCount >= $class->capacity, 409, 'Kuota kelas sudah penuh.');

                $enrollment = MentoringEnrollment::create([
                    'class_id' => $class->id,
                    'student_id' => $student->id,
                    'paid_tc' => $class->price_tc,
                    'topic_focus' => $data['topic_focus'] ?? $class->topic,
                    'student_notes' => $data['student_notes'] ?? null,
                    'materials_url' => $data['materials_url'] ?? null,
                    'status' => 'pending',
                ]);
                $this->ledger->holdForMentoring($studentWallet, $student->id, $class->mentor_id, $class->price_tc, $enrollment);

                return [$class, $enrollment];
            }, 3);
        } catch (QueryException $exception) {
            if (MentoringEnrollment::where('class_id', $mentoringClass->id)->where('student_id', $student->id)->exists()) {
                return response()->json(['status' => 'error', 'message' => 'Anda sudah terdaftar pada kelas ini.'], 409);
            }

            throw $exception;
        }

        [$class, $enrollment] = $result;

        $this->notifications->send(
            $class->mentor_id,
            'mentoring_booked',
            'Permintaan Booking Sesi Baru',
            "{$student->name} memesan sesi {$class->topic} ({$class->price_tc} TC).",
            '/dashboard/mentor',
        );

        return response()->json([
            'status' => 'success',
            'message' => "Permintaan bimbingan berhasil dikirim. {$class->price_tc} TC ditahan sementara sampai sesi selesai dikonfirmasi.",
            'data' => ['enrollment_id' => $enrollment->id, 'status' => $enrollment->status, 'scheduled_time' => $class->scheduled_time],
        ], 201);
    }

    public function show(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $enrollment->load([
            'mentoringClass.mentor:id,name',
            'mentoringClass.mentor.mentorProfile',
            'actionItems',
        ]);
        $isParticipant = $enrollment->student_id === $request->user()->id
            || $enrollment->mentoringClass?->mentor_id === $request->user()->id;
        abort_unless($isParticipant, 403);

        $includeLink = in_array($enrollment->status, ['accepted', 'attended', 'pending_confirmation', 'completed'], true);

        return response()->json([
            'status' => 'success',
            'data' => [
                ...MentoringPresenter::enrollment($enrollment, $enrollment->mentoringClass?->mentor_id === $request->user()->id),
                'class' => MentoringPresenter::mentoringClass($enrollment->mentoringClass, $includeLink),
            ],
        ]);
    }

    public function studentIndex(Request $request): JsonResponse
    {
        $enrollments = MentoringEnrollment::query()
            ->with(['mentoringClass.mentor:id,name', 'mentoringClass.mentor.mentorProfile', 'actionItems'])
            ->where('student_id', $request->user()->id)
            ->latest()
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $enrollments->getCollection()->map(fn (MentoringEnrollment $enrollment) => [
                ...MentoringPresenter::enrollment($enrollment),
                'class' => MentoringPresenter::mentoringClass(
                    $enrollment->mentoringClass,
                    in_array($enrollment->status, ['accepted', 'attended', 'pending_confirmation', 'completed'], true),
                ),
            ]),
            'meta' => ['current_page' => $enrollments->currentPage(), 'last_page' => $enrollments->lastPage()],
        ]);
    }

    public function studentMentors(Request $request): JsonResponse
    {
        $studentId = $request->user()->id;
        $enrollments = MentoringEnrollment::query()
            ->with(['mentoringClass.mentor:id,name', 'mentoringClass.mentor.mentorProfile'])
            ->where('student_id', $studentId)
            ->latest()
            ->get();

        $certificatesCount = StudentCertificate::where('student_id', $studentId)->count();
        $projectsCount = Portfolio::where('student_id', $studentId)->count();
        $classIds = $enrollments->pluck('class_id')->unique()->values();
        $materialsByClass = MentoringMaterial::whereIn('class_id', $classIds)->get()->groupBy('class_id');
        $assignmentsByClass = MentoringAssignment::whereIn('class_id', $classIds)->get()->groupBy('class_id');
        $submissionsByAssignment = MentoringAssignmentSubmission::where('student_id', $studentId)
            ->get()
            ->keyBy('assignment_id');

        $nextSession = $enrollments
            ->first(fn (MentoringEnrollment $e) => in_array($e->status, ['accepted', 'pending'], true));

        $grouped = $enrollments->groupBy(fn (MentoringEnrollment $e) => $e->mentoringClass?->mentor_id ?? 0);
        $mentors = $grouped->map(function ($group) use ($materialsByClass, $assignmentsByClass, $submissionsByAssignment) {
            /** @var MentoringEnrollment $latest */
            $latest = $group->first();
            $mentor = $latest->mentoringClass?->mentor;
            $mentorClassIds = $group->pluck('class_id')->unique();

            $materialsCount = $mentorClassIds->sum(fn ($cid) => ($materialsByClass->get($cid) ?? collect())->count());
            $newMaterialsCount = $mentorClassIds->sum(fn ($cid) => ($materialsByClass->get($cid) ?? collect())->where('is_new', true)->count());

            $assignments = $mentorClassIds->flatMap(fn ($cid) => $assignmentsByClass->get($cid) ?? collect());
            $tasksTotal = $assignments->count();
            $tasksDone = $assignments->filter(fn ($a) => $submissionsByAssignment->has($a->id))->count();

            $resultsCount = $group->whereNotNull('assessment_score')->count();
            $certsCount = $group->whereIn('status', ['completed'])->count() + $group->where('has_endorsement', true)->count();

            return [
                'mentor_id' => $mentor?->id,
                'mentor_name' => $mentor?->name ?? 'Mentor',
                'avatar_url' => $mentor?->mentorProfile?->avatar_url,
                'title_headline' => $mentor?->mentorProfile?->title_headline ?? 'Peer Mentor',
                'topic' => $latest->topic_focus ?? $latest->mentoringClass?->topic,
                'latest_enrollment_id' => $latest->id,
                'latest_class_id' => $latest->class_id,
                'latest_status' => $latest->status,
                'sessions_count' => $group->count(),
                'materials_count' => $materialsCount,
                'new_materials_count' => $newMaterialsCount,
                'tasks_done' => $tasksDone,
                'tasks_total' => $tasksTotal,
                'pending_tasks_count' => max(0, $tasksTotal - $tasksDone),
                'results_count' => $resultsCount,
                'certificates_count' => $certsCount,
                'projects_count' => 0,
            ];
        })->values();

        $totalMaterials = $materialsByClass->flatten(1)->count();

        return response()->json([
            'status' => 'success',
            'data' => [
                'summary' => [
                    'mentors_count' => $mentors->count(),
                    'materials_count' => $totalMaterials,
                    'certificates_count' => $certificatesCount,
                    'projects_count' => $projectsCount,
                ],
                'next_session' => $nextSession ? [
                    ...MentoringPresenter::enrollment($nextSession),
                    'class' => MentoringPresenter::mentoringClass(
                        $nextSession->mentoringClass,
                        in_array($nextSession->status, ['accepted', 'attended', 'pending_confirmation', 'completed'], true),
                    ),
                ] : null,
                'mentors' => $mentors,
            ],
        ]);
    }

    public function materials(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $isParticipant = $enrollment->student_id === $request->user()->id
            || $enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists();
        abort_unless($isParticipant, 403);

        $materials = MentoringMaterial::where('class_id', $enrollment->class_id)
            ->latest()
            ->get()
            ->map(fn (MentoringMaterial $m) => [
                'id' => $m->id,
                'title' => $m->title,
                'description' => $m->description,
                'kind' => $m->kind,
                'meta_label' => $m->meta_label,
                'resource_url' => $m->resource_url,
                'is_new' => (bool) $m->is_new,
                'created_at' => $m->created_at?->toIso8601String(),
            ]);

        return response()->json(['status' => 'success', 'data' => $materials]);
    }

    public function storeMaterial(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless($mentoringClass->mentor_id === $request->user()->id, 403);
        $data = $request->validate([
            'title' => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:2000'],
            'kind' => ['required', Rule::in(['pdf', 'video', 'link'])],
            'meta_label' => ['nullable', 'string', 'max:80'],
            'resource_url' => ['required', 'url', 'max:2048'],
        ]);

        $material = MentoringMaterial::create([
            ...$data,
            'class_id' => $mentoringClass->id,
            'mentor_id' => $request->user()->id,
        ]);

        return response()->json(['status' => 'success', 'data' => $material], 201);
    }

    public function toggleActionItem(Request $request, MentoringEnrollment $enrollment, MentoringActionItem $item): JsonResponse
    {
        abort_unless($enrollment->student_id === $request->user()->id && $item->enrollment_id === $enrollment->id, 403);
        $nextState = ! $item->is_completed;
        $item->update([
            'is_completed' => $nextState,
            'completed_at' => $nextState ? now() : null,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $item->id,
                'is_completed' => (bool) $item->is_completed,
                'completed_at' => $item->completed_at?->toIso8601String(),
            ],
        ]);
    }

    public function mentorIndex(Request $request): JsonResponse
    {
        $enrollments = MentoringEnrollment::query()
            ->with(['student:id,name,email', 'mentoringClass:id,mentor_id,topic,scheduled_time'])
            ->whereHas('mentoringClass', fn ($query) => $query->where('mentor_id', $request->user()->id))
            ->latest()
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $enrollments->getCollection()->map(fn (MentoringEnrollment $enrollment) => MentoringPresenter::enrollment($enrollment, true)),
            'meta' => ['current_page' => $enrollments->currentPage(), 'last_page' => $enrollments->lastPage()],
        ]);
    }

    public function decide(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $data = $request->validate(['decision' => ['required', Rule::in(['accepted', 'declined'])]]);
        $result = DB::transaction(function () use ($request, $enrollment, $data) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            $class = MentoringClass::findOrFail($record->class_id);
            abort_unless($class->mentor_id === $request->user()->id, 403);
            abort_unless($record->status === 'pending', 409, 'Booking ini sudah diproses.');
            if ($data['decision'] === 'accepted') {
                abort_unless($class->scheduled_time->isFuture(), 409, 'Booking tidak dapat diterima setelah jadwal dimulai.');
            }
            $record->update(['status' => $data['decision']]);

            if ($data['decision'] === 'declined') {
                $this->refundEscrow($record, $class->mentor_id);
            }

            return $record->fresh(['mentoringClass']);
        }, 3);

        $this->notifications->send(
            $result->student_id,
            'mentoring_decision',
            $data['decision'] === 'accepted' ? 'Sesi Bimbingan Diterima' : 'Booking Bimbingan Ditolak',
            $data['decision'] === 'accepted'
                ? 'Mentor menyetujui sesi Anda. Tautan ruang pertemuan kini sudah tersedia.'
                : 'Mentor menolak booking sesi dan dana TimeCoin Anda telah dikembalikan.',
            '/mentors/my-mentors',
        );

        return response()->json(['status' => 'success', 'message' => 'Keputusan booking berhasil disimpan.', 'data' => MentoringPresenter::enrollment($result)]);
    }

    public function attendance(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        abort_unless($enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(), 403);
        abort_unless($enrollment->mentoringClass->scheduled_time->copy()->addMinutes($enrollment->mentoringClass->duration_minutes)->isPast(), 409, 'Kehadiran hanya dapat dicatat setelah sesi selesai.');
        $data = $request->validate(['status' => ['required', Rule::in(['attended', 'absent'])]]);
        DB::transaction(function () use ($enrollment, $data, $request) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            abort_unless($record->status === 'accepted', 409, 'Hanya booking yang diterima mentor dapat dicatat kehadirannya.');
            $record->update($data);
            if ($data['status'] === 'absent') {
                $this->refundEscrow($record, $request->user()->id);
            }
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Kehadiran berhasil diperbarui.', 'data' => MentoringPresenter::enrollment($enrollment->fresh(['student', 'mentoringClass']))]);
    }

    public function assess(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $data = $request->validate([
            'score' => ['required', 'integer', 'min:0', 'max:100'],
            'mentor_feedback' => ['required', 'string', 'min:5', 'max:5000'],
            'rubric_scores' => ['sometimes', 'array'],
        ]);
        $record = DB::transaction(function () use ($request, $enrollment, $data) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            abort_unless($record->mentoringClass()->where('mentor_id', $request->user()->id)->exists(), 403);
            abort_unless($record->status === 'attended', 409, 'Penilaian hanya dapat diberikan setelah sesi dihadiri.');
            abort_unless($record->mentoringClass->scheduled_time->copy()->addMinutes($record->mentoringClass->duration_minutes)->isPast(), 409, 'Sesi belum selesai.');
            $record->update([
                'assessment_score' => $data['score'],
                'mentor_feedback' => $data['mentor_feedback'],
                'rubric_scores' => $data['rubric_scores'] ?? [
                    ['label' => 'Visual & Desain', 'score' => min(100, $data['score'] + 3), 'grade' => 'A'],
                    ['label' => 'Alur UX & Arsitektur', 'score' => $data['score'], 'grade' => 'A'],
                    ['label' => 'Kesiapan Proyek UMKM', 'score' => max(0, $data['score'] - 2), 'grade' => 'A-'],
                ],
                'evaluated_at' => now(),
                'status' => 'pending_confirmation',
            ]);

            if (! $record->actionItems()->exists()) {
                MentoringActionItem::create([
                    'enrollment_id' => $record->id,
                    'title' => 'Rapikan dokumentasi studi kasus di portofolio',
                    'tag' => 'Wajib',
                    'detail' => 'Lampirkan ringkasan masalah, solusi, dan tangkapan layar utama sebelum melamar proyek UMKM.',
                ]);
                MentoringActionItem::create([
                    'enrollment_id' => $record->id,
                    'title' => 'Terapkan catatan feedback dari sesi mentoring',
                    'tag' => 'Perbaikan',
                    'detail' => $data['mentor_feedback'],
                ]);
            }

            return $record->fresh(['actionItems', 'mentoringClass']);
        }, 3);

        $this->notifications->send(
            $record->student_id,
            'mentoring_assessed',
            'Hasil Evaluasi Bimbingan Tersedia',
            "Skor sesi Anda: {$record->assessment_score}/100. Konfirmasikan penyelesaian sesi untuk melepaskan escrow.",
            '/mentoring/selesai',
            ['enrollment_id' => $record->id],
        );

        return response()->json(['status' => 'success', 'message' => 'Hasil evaluasi dikirim untuk konfirmasi mahasiswa.', 'data' => MentoringPresenter::enrollment($record)]);
    }

    public function confirmCompletion(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $data = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'review_text' => ['nullable', 'string', 'max:2000'],
            'strength_tags' => ['sometimes', 'array'],
            'strength_tags.*' => ['string', 'max:80'],
        ]);
        $completed = DB::transaction(function () use ($request, $enrollment, $data) {
            $record = MentoringEnrollment::query()->lockForUpdate()->findOrFail($enrollment->id);
            abort_unless($record->student_id === $request->user()->id, 403);
            abort_unless($record->status === 'pending_confirmation', 409, 'Sesi belum menunggu konfirmasi penyelesaian.');
            $class = MentoringClass::with('mentor:id,name')->findOrFail($record->class_id);
            $studentWallet = TimeCoinWallet::where('user_id', $record->student_id)->lockForUpdate()->firstOrFail();
            $mentorWallet = TimeCoinWallet::firstOrCreate(['user_id' => $class->mentor_id]);
            $mentorWallet = TimeCoinWallet::whereKey($mentorWallet->id)->lockForUpdate()->firstOrFail();
            abort_if($studentWallet->locked_balance < $record->paid_tc, 409, 'Saldo escrow tidak sesuai dengan booking.');

            $this->ledger->releaseMentoringEscrow(
                $studentWallet,
                $mentorWallet,
                $record->student_id,
                $class->mentor_id,
                $record->paid_tc,
                $record,
            );
            $record->update(['status' => 'completed', 'student_confirmed_at' => now()]);
            Review::create([
                'reviewer_id' => $record->student_id,
                'reviewee_id' => $class->mentor_id,
                'mentoring_class_id' => $class->id,
                'rating' => $data['rating'],
                'review_text' => $data['review_text'] ?? null,
                'strength_tags' => $data['strength_tags'] ?? null,
            ]);
            $average = Review::where('reviewee_id', $class->mentor_id)->whereNotNull('mentoring_class_id')->avg('rating');
            MentorProfile::firstOrCreate(['user_id' => $class->mentor_id])->update(['rating_average' => $average]);

            StudentCertificate::firstOrCreate(
                [
                    'student_id' => $record->student_id,
                    'source_type' => 'mentoring_completion',
                    'reference_type' => MentoringEnrollment::class,
                    'reference_id' => $record->id,
                ],
                [
                    'certificate_code' => 'TS-MNT-'.str_pad((string) $record->id, 4, '0', STR_PAD_LEFT),
                    'title' => 'Lulus Bimbingan: '.$class->topic,
                    'issuer_name' => $class->mentor?->name ?? 'Mentor TalentSync',
                    'category_label' => 'Mentoring',
                    'issued_at' => now(),
                ],
            );

            return $record->fresh(['mentoringClass', 'actionItems']);
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Sesi selesai dan saldo escrow telah diteruskan ke mentor.', 'data' => MentoringPresenter::enrollment($completed)]);
    }

    public function endorse(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        abort_unless($enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(), 403);
        abort_unless($enrollment->status === 'completed' && $enrollment->assessment_score >= 80, 409, 'Endorsement mensyaratkan sesi selesai dan nilai minimal 80.');
        abort_if($enrollment->has_endorsement, 409, 'Murid ini sudah menerima endorsement untuk sesi tersebut.');
        $data = $request->validate(['endorsement_notes' => ['required', 'string', 'min:10', 'max:2000']]);
        $enrollment->update(['has_endorsement' => true, 'endorsement_notes' => $data['endorsement_notes']]);

        $enrollment->load('mentoringClass.mentor:id,name');
        StudentCertificate::firstOrCreate(
            [
                'student_id' => $enrollment->student_id,
                'source_type' => 'mentoring_endorsement',
                'reference_type' => MentoringEnrollment::class,
                'reference_id' => $enrollment->id,
            ],
            [
                'certificate_code' => 'TS-END-'.strtoupper(Str::random(6)),
                'title' => 'Rekomendasi Kerja: '.($enrollment->mentoringClass?->topic ?? 'TalentSync'),
                'issuer_name' => ($enrollment->mentoringClass?->mentor?->name ?? 'Mentor').', Mentor',
                'category_label' => 'Endorse Mentor',
                'issued_at' => now(),
            ],
        );

        $this->notifications->send(
            $enrollment->student_id,
            'mentor_endorsement',
            'Selamat! Anda Meraih Badge Rekomendasi Mentor',
            'Badge Rekomendasi Kerja kini tersemat di portofolio Anda untuk melamar proyek UMKM.',
            '/portfolio/certificates',
        );

        return response()->json(['status' => 'success', 'message' => 'Badge Rekomendasi Kerja berhasil disematkan ke portofolio mahasiswa.', 'data' => MentoringPresenter::enrollment($enrollment->fresh(['student', 'mentoringClass']))]);
    }

    private function refundEscrow(MentoringEnrollment $enrollment, int $mentorId): void
    {
        $wallet = TimeCoinWallet::where('user_id', $enrollment->student_id)->lockForUpdate()->firstOrFail();
        $this->ledger->refundMentoringEscrow($wallet, $mentorId, $enrollment->student_id, $enrollment->paid_tc, $enrollment);
    }
}
