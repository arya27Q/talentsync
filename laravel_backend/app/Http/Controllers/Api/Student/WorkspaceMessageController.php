<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProjectPresenter;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMessage;
use App\Models\User;
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
        $isMsmeOwner = (int) $project->msme_id === (int) $user->id;
        $isStudent = $user->hasRole('student') && ! $isMsmeOwner;
        $this->authorizeThreadAccess($user->id, $project, $isStudent);

        $project->load(['msme.umkmProfile', 'milestones']);

        $requestedStudentId = $request->query('student_id') ? (int) $request->query('student_id') : null;
        $threadStudentId = $isStudent
            ? $user->id
            : $this->resolveMsmeThreadStudentId($project, $requestedStudentId);

        $application = $threadStudentId !== null
            ? $project->applications()->where('student_id', $threadStudentId)->first()
            : null;

        if ($isStudent) {
            abort_unless(
                $application !== null,
                403,
                'Lamar proyek ini terlebih dahulu untuk membuka obrolan dengan Mitra UMKM.',
            );
        }

        $messagesQuery = $project->messages()->with('sender:id,name');

        if ($threadStudentId !== null && $application !== null) {
            $messagesQuery->where(function ($q) use ($threadStudentId, $project) {
                $q->where('student_id', $threadStudentId)
                    ->orWhere(function ($legacy) use ($threadStudentId, $project) {
                        $legacy->whereNull('student_id')
                            ->whereIn('sender_id', [$threadStudentId, $project->msme_id]);
                    });
            });

            // Mark incoming messages in this thread as read
            ProjectMessage::where('project_id', $project->id)
                ->where(function ($q) use ($threadStudentId) {
                    $q->where('student_id', $threadStudentId)->orWhereNull('student_id');
                })
                ->where('sender_id', '!=', $user->id)
                ->whereNull('read_at')
                ->update(['read_at' => now()]);
        } else {
            $messagesQuery->whereRaw('1 = 0');
        }

        $messages = $messagesQuery
            ->orderBy('created_at')
            ->orderBy('id')
            ->paginate(50);

        $activeMilestone = $project->milestones
            ->first(fn ($m) => in_array($m->status, ['open', 'submitted', 'revision_requested'], true))
            ?? $project->milestones->first();

        $student = ($threadStudentId && $application !== null)
            ? User::with('studentProfile')->find($threadStudentId)
            : null;
        $studentProfile = $student?->studentProfile;
        $applicationStatus = $application?->status;

        $canSend = $application !== null && in_array($applicationStatus, ['pending', 'accepted'], true);
        $chatClosedReason = match ($applicationStatus) {
            'rejected' => $isStudent
                ? 'Obrolan telah ditutup karena lamaran tidak dilanjutkan. Baca pesan evaluasi dari Mitra UMKM di atas sebagai bahan belajar.'
                : 'Obrolan ini ditutup karena pelamar telah ditolak. Pesan evaluasi Anda tetap tersimpan untuk dibaca mahasiswa.',
            null => 'Belum ada pelamar pada proyek ini. Obrolan akan otomatis aktif setelah ada mahasiswa yang melamar.',
            default => null,
        };

        $studentSummary = $student ? [
            'id' => $student->id,
            'name' => $student->name,
            'avatar_url' => $studentProfile?->avatar_url,
            'university' => $studentProfile?->university ?? 'Universitas Negeri Surabaya',
            'major' => $studentProfile?->major ?? 'S1 Sistem Informasi',
            'application_status' => $applicationStatus,
        ] : null;

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'student' => $studentSummary,
                'accepted_student' => $studentSummary,
                'application_status' => $applicationStatus,
                'can_send' => $canSend,
                'chat_closed_reason' => $chatClosedReason,
                'active_milestone' => $activeMilestone ? ProjectPresenter::milestone($activeMilestone) : null,
                'messages' => $messages->getCollection()->map(fn (ProjectMessage $m) => ProjectPresenter::message($m))->values(),
            ],
        ]);
    }

    public function store(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        $isMsmeOwner = (int) $project->msme_id === (int) $user->id;
        $isStudent = $user->hasRole('student') && ! $isMsmeOwner;
        $this->authorizeThreadAccess($user->id, $project, $isStudent);

        $data = $request->validate([
            'message' => ['nullable', 'required_without:attachment_file', 'string', 'max:10000'],
            'attachment_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png', 'webp', 'pdf', 'zip'])->max(5 * 1024)],
            'milestone_id' => ['nullable', 'integer'],
            'student_id' => ['nullable', 'integer', 'exists:users,id'],
        ]);

        $threadStudentId = $isStudent
            ? $user->id
            : $this->resolveMsmeThreadStudentId(
                $project,
                isset($data['student_id']) ? (int) $data['student_id'] : null,
            );

        $application = $threadStudentId !== null
            ? ProjectApplication::where('project_id', $project->id)
                ->where('student_id', $threadStudentId)
                ->first()
            : null;

        if ($application === null) {
            abort(
                403,
                $isStudent
                    ? 'Lamar proyek ini terlebih dahulu untuk mengirim pesan ke Mitra UMKM.'
                    : 'Obrolan hanya tersedia dengan mahasiswa yang telah melamar proyek ini.',
            );
        }

        if ($application->status === 'rejected') {
            abort(
                403,
                'Obrolan sudah ditutup karena lamaran berstatus ditolak. Riwayat pesan evaluasi tetap dapat dibaca.',
            );
        }

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
                'student_id' => $threadStudentId,
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

        if (! $isMsmeOwner) {
            $this->notifications->send(
                $project->msme_id,
                'project_message',
                'Pesan Baru dari Pelamar',
                "{$user->name}: ".($data['message'] ?: ($attachmentName ?? 'Mengirim lampiran')),
                '/msme/chat',
                ['project_id' => $project->id, 'student_id' => $user->id],
            );
        } elseif ($threadStudentId !== null) {
            $msmeName = $user->umkmProfile?->business_name ?? $user->name;
            $this->notifications->send(
                $threadStudentId,
                'project_message',
                'Pesan Baru dari Mitra UMKM',
                "{$msmeName}: ".($data['message'] ?: ($attachmentName ?? 'Mengirim lampiran')),
                '/workspace/chat',
                ['project_id' => $project->id],
            );
        }

        return response()->json([
            'status' => 'success',
            'data' => ProjectPresenter::message($message),
        ], 201);
    }

    private function resolveMsmeThreadStudentId(Project $project, ?int $requestedStudentId): ?int
    {
        if ($requestedStudentId !== null) {
            return $requestedStudentId;
        }

        $acceptedId = $project->applications()
            ->where('status', 'accepted')
            ->value('student_id');
        if ($acceptedId) {
            return (int) $acceptedId;
        }

        $latestApplicantId = $project->applications()
            ->latest('applied_at')
            ->value('student_id');

        return $latestApplicantId ? (int) $latestApplicantId : null;
    }

    private function authorizeThreadAccess(int $userId, Project $project, bool $isStudent): void
    {
        abort_unless($isStudent || (int) $project->msme_id === $userId, 403);
    }
}
