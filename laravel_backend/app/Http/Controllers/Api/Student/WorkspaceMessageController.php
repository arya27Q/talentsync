<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProjectPresenter;
use App\Models\Project;
use App\Models\ProjectMessage;
use App\Services\NotificationDispatcher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\File;

class WorkspaceMessageController extends Controller
{
    public function __construct(private readonly NotificationDispatcher $notifications)
    {
    }

    public function index(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        $this->authorizeThreadAccess($user->id, $project, $user->hasRole('student'));

        $project->load(['msme.umkmProfile', 'milestones']);

        ProjectMessage::where('project_id', $project->id)
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $messages = $project->messages()
            ->with('sender:id,name')
            ->orderBy('created_at')
            ->orderBy('id')
            ->paginate(50);

        $activeMilestone = $project->milestones
            ->first(fn ($m) => in_array($m->status, ['open', 'submitted', 'revision_requested'], true))
            ?? $project->milestones->first();

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'active_milestone' => $activeMilestone ? ProjectPresenter::milestone($activeMilestone) : null,
                'messages' => $messages->getCollection()->map(fn (ProjectMessage $m) => ProjectPresenter::message($m))->values(),
            ],
        ]);
    }

    public function store(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        $this->authorizeThreadAccess($user->id, $project, $user->hasRole('student'));

        $data = $request->validate([
            'message' => ['nullable', 'required_without:attachment_file', 'string', 'max:10000'],
            'attachment_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png', 'webp', 'pdf', 'zip'])->max(5 * 1024)],
            'milestone_id' => ['nullable', 'integer'],
        ]);

        $attachmentUrl = null;
        $attachmentName = null;
        $storedPath = null;
        if ($request->hasFile('attachment_file')) {
            $file = $request->file('attachment_file');
            $storedPath = $file->store('project-chat', 'public');
            $attachmentUrl = Storage::disk('public')->url($storedPath);
            $attachmentName = $file->getClientOriginalName();
        }

        try {
            $message = ProjectMessage::create([
                'project_id' => $project->id,
                'sender_id' => $user->id,
                'milestone_id' => $data['milestone_id'] ?? null,
                'message' => $data['message'] ?? null,
                'attachment_url' => $attachmentUrl,
                'attachment_name' => $attachmentName,
            ])->load('sender:id,name');
        } catch (\Throwable $e) {
            if ($storedPath !== null) {
                Storage::disk('public')->delete($storedPath);
            }
            throw $e;
        }

        if ($user->id !== $project->msme_id) {
            $this->notifications->send(
                $project->msme_id,
                'project_message',
                'Pesan Baru Workspace Proyek',
                "{$user->name}: ".($data['message'] ?: ($attachmentName ?? 'Mengirim lampiran')),
                '/msme/chat',
                ['project_id' => $project->id],
            );
        }

        return response()->json([
            'status' => 'success',
            'data' => ProjectPresenter::message($message),
        ], 201);
    }

    private function authorizeThreadAccess(int $userId, Project $project, bool $isStudent): void
    {
        abort_unless($isStudent || $project->msme_id === $userId, 403);
    }
}

