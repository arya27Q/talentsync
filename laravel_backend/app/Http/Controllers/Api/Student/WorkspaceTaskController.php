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
        $this->workflow->assertAcceptedStudent($request->user(), $project);
        $project->load('msme.umkmProfile');

        $tasks = ProjectTask::where('project_id', $project->id)
            ->where('student_id', $request->user()->id)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $total = $tasks->count();
        $done = $tasks->where('status', 'done')->count();

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'stats' => [
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
            'status' => ['sometimes', Rule::in(['todo', 'in_progress', 'done'])],
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
            'status' => ['sometimes', Rule::in(['todo', 'in_progress', 'done'])],
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

