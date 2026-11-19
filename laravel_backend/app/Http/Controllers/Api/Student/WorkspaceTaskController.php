<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProjectPresenter;
use App\Models\Project;
use App\Models\ProjectTask;
use App\Services\ProjectWorkflowService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WorkspaceTaskController extends Controller
{
    public function __construct(private readonly ProjectWorkflowService $workflow)
    {
    }

    public function index(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        $isMsmeOwner = $project->msme_id === $user->id && $user->hasRole('msme');

        if (! $isMsmeOwner) {
            $this->workflow->assertAcceptedStudent($user, $project);
        }

        $project->load(['msme.umkmProfile', 'milestones']);

        $acceptedApp = $project->applications()
            ->with('student.studentProfile')
            ->where('status', 'accepted')
            ->first();

        $studentId = $isMsmeOwner
            ? ($acceptedApp?->student_id ?? 0)
            : $user->id;

        $tasks = ProjectTask::where('project_id', $project->id)
            ->when($studentId > 0, fn ($q) => $q->where('student_id', $studentId))
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $total = $tasks->count();
        $todo = $tasks->where('status', 'todo')->count();
        $inProgress = $tasks->where('status', 'in_progress')->count();
        $review = $tasks->where('status', 'review')->count();
        $done = $tasks->where('status', 'done')->count();

        $student = $acceptedApp?->student;
        $studentProfile = $student?->studentProfile;

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'is_read_only' => $isMsmeOwner,
                'accepted_student' => $student ? [
                    'id' => $student->id,
                    'name' => $student->name,
                    'avatar_url' => $studentProfile?->avatar_url,
                    'university' => $studentProfile?->university ?? 'Universitas Negeri Surabaya',
                ] : null,
                'stats' => [
                    'todo_count' => $todo,
                    'in_progress_count' => $inProgress,
                    'review_count' => $review,
                    'done_count' => $done,
                    'total_count' => $total,
                    'progress_percent' => $total > 0 ? (int) round(($done / $total) * 100) : 0,
                ],
                'tasks' => $tasks->map(fn (ProjectTask $task) => ProjectPresenter::task($task))->values(),
            ],
        ]);
    }

    public function store(Request $request, Project $project): JsonResponse
    {
        $this->workflow->assertAcceptedStudent($request->user(), $project);

        $data = $request->validate([
            'title' => ['required', 'string', 'min:2', 'max:200'],
            'tag' => ['sometimes', 'string', 'max:40'],
            'status' => ['sometimes', Rule::in(['todo', 'in_progress', 'review', 'done'])],
            'deadline_label' => ['nullable', 'string', 'max:40'],
            'due_date' => ['nullable', 'date'],
        ]);

        $maxOrder = (int) ProjectTask::where('project_id', $project->id)
            ->where('student_id', $request->user()->id)
            ->max('sort_order');

        $task = ProjectTask::create([
            'project_id' => $project->id,
            'student_id' => $request->user()->id,
            'title' => $data['title'],
            'tag' => $data['tag'] ?? 'Fitur',
            'status' => $data['status'] ?? 'todo',
            'deadline_label' => $data['deadline_label'] ?? $project->deadline?->translatedFormat('d M') ?? '12 Jul',
            'due_date' => $data['due_date'] ?? null,
            'sort_order' => $maxOrder + 1,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Tugas Kanban berhasil ditambahkan.',
            'data' => ProjectPresenter::task($task),
        ], 201);
    }

    public function update(Request $request, ProjectTask $task): JsonResponse
    {
        $this->workflow->assertStudentTaskOwner($request->user(), $task);

        $data = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'min:2', 'max:200'],
            'tag' => ['sometimes', 'string', 'max:40'],
            'status' => ['sometimes', Rule::in(['todo', 'in_progress', 'review', 'done'])],
            'deadline_label' => ['sometimes', 'nullable', 'string', 'max:40'],
        ]);

        $task->update($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Tugas Kanban diperbarui.',
            'data' => ProjectPresenter::task($task->fresh()),
        ]);
    }

    public function destroy(Request $request, ProjectTask $task): JsonResponse
    {
        $this->workflow->assertStudentTaskOwner($request->user(), $task);
        $task->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Tugas Kanban dihapus.',
        ]);
    }
}

