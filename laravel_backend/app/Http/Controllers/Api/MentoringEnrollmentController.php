<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentorProfile;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\Review;
use App\Models\TimeCoinWallet;
use App\Services\TimeCoinLedgerService;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class MentoringEnrollmentController extends Controller
{
    public function __construct(private readonly TimeCoinLedgerService $ledger)
    {
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
                $enrolledCount = $class->enrollments()->whereNotIn('status', ['absent', 'declined'])->count();
                abort_if($enrolledCount >= $class->capacity, 409, 'Kuota kelas sudah penuh.');

                $enrollment = MentoringEnrollment::create([
                    'class_id' => $class->id,
                    'student_id' => $student->id,
                    'paid_tc' => $class->price_tc,
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

        return response()->json([
            'status' => 'success',
            'message' => "Permintaan bimbingan berhasil dikirim. {$class->price_tc} TC ditahan sementara sampai sesi selesai dikonfirmasi.",
            'data' => ['enrollment_id' => $enrollment->id, 'status' => $enrollment->status, 'scheduled_time' => $class->scheduled_time],
        ], 201);
    }

    public function studentIndex(Request $request): JsonResponse
    {
        $enrollments = MentoringEnrollment::query()
            ->with(['mentoringClass.mentor:id,name'])
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

            return $record->fresh();
        }, 3);

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
        ]);
        $record = DB::transaction(function () use ($request, $enrollment, $data) {
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

        return response()->json(['status' => 'success', 'message' => 'Hasil evaluasi dikirim untuk konfirmasi mahasiswa.', 'data' => MentoringPresenter::enrollment($record)]);
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
            ]);
            $average = Review::where('reviewee_id', $class->mentor_id)->whereNotNull('mentoring_class_id')->avg('rating');
            MentorProfile::firstOrCreate(['user_id' => $class->mentor_id])->update(['rating_average' => $average]);

            return $record->fresh();
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

        return response()->json(['status' => 'success', 'message' => 'Badge Rekomendasi Kerja berhasil disematkan ke portofolio mahasiswa.', 'data' => MentoringPresenter::enrollment($enrollment->fresh(['student', 'mentoringClass']))]);
    }

    private function refundEscrow(MentoringEnrollment $enrollment, int $mentorId): void
    {
        $wallet = TimeCoinWallet::where('user_id', $enrollment->student_id)->lockForUpdate()->firstOrFail();
        $this->ledger->refundMentoringEscrow($wallet, $mentorId, $enrollment->student_id, $enrollment->paid_tc, $enrollment);
    }
}
