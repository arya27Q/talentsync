<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentoringAssignment;
use App\Models\MentoringAssignmentSubmission;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class MentoringAssignmentController extends Controller
{
    public function store(Request $request, MentoringClass $mentoringClass): JsonResponse
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

    public function index(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $this->authorizeParticipant($request, $enrollment);
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

    public function submit(Request $request, MentoringAssignment $assignment): JsonResponse
    {
        $data = $request->validate([
            'submission_notes' => ['nullable', 'string', 'max:5000'],
            'deliverable_url' => ['nullable', 'required_without:submission_notes', 'url', 'max:2048'],
        ]);
        MentoringEnrollment::where('class_id', $assignment->class_id)
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

    public function review(Request $request, MentoringAssignmentSubmission $submission): JsonResponse
    {
        $data = $request->validate([
            'score' => ['required', 'integer', 'min:0', 'max:100'],
            'feedback' => ['required', 'string', 'min:3', 'max:5000'],
            'decision' => ['required', Rule::in(['reviewed', 'revision_requested'])],
        ]);
        abort_unless($submission->assignment()->where('mentor_id', $request->user()->id)->exists(), 403);
        abort_unless($submission->status === 'submitted', 409, 'Tugas ini tidak sedang menunggu penilaian.');
        $submission->update(['score' => $data['score'], 'feedback' => $data['feedback'], 'status' => $data['decision']]);

        return response()->json(['status' => 'success', 'message' => 'Penilaian tugas berhasil disimpan.', 'data' => $submission->fresh()]);
    }

    private function authorizeParticipant(Request $request, MentoringEnrollment $enrollment): void
    {
        abort_unless(
            $enrollment->student_id === $request->user()->id
                || $enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(),
            403,
        );
    }
}
