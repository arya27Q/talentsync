<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentoringEnrollment;
use App\Models\MentoringMessage;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMessage;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InboxController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $search = mb_strtolower(trim((string) $request->query('q', '')));

        $activeRole = $user->roleRecord?->name;
        if ($activeRole === 'msme' || (! $user->hasRole('student') && $user->hasRole('msme'))) {
            return $this->msmeInbox($user, $search);
        }

        return $this->studentInbox($user, $search);
    }

    private function msmeInbox(User $msme, string $search): JsonResponse
    {
        $projects = Project::query()
            ->where('msme_id', $msme->id)
            ->get()
            ->keyBy('id');

        if ($projects->isEmpty()) {
            return response()->json(['status' => 'success', 'data' => []]);
        }

        $projectIds = $projects->keys()->all();

        // Only students who have actually applied to the MSME's projects appear in UMKM Inbox
        $applications = ProjectApplication::query()
            ->whereIn('project_id', $projectIds)
            ->orderByDesc('applied_at')
            ->get();

        if ($applications->isEmpty()) {
            return response()->json(['status' => 'success', 'data' => []]);
        }

        $messages = ProjectMessage::query()
            ->whereIn('project_id', $projectIds)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get();

        $messagesByKey = [];
        foreach ($messages as $msg) {
            $studentId = $msg->student_id;
            if (! $studentId && (int) $msg->sender_id !== (int) $msme->id) {
                $studentId = $msg->sender_id;
            }
            if (! $studentId) {
                $acceptedApp = $applications
                    ->first(fn ($a) => (int) $a->project_id === (int) $msg->project_id && $a->status === 'accepted');
                $studentId = $acceptedApp?->student_id;
            }
            if (! $studentId) {
                continue;
            }
            $key = $msg->project_id.':'.$studentId;
            $messagesByKey[$key][] = $msg;
        }

        $studentIds = $applications->pluck('student_id')->unique()->values()->all();
        $students = User::with('studentProfile')
            ->whereIn('id', $studentIds)
            ->get()
            ->keyBy('id');

        $threads = $applications->map(function (ProjectApplication $app) use ($projects, $students, $messagesByKey, $msme) {
            $project = $projects->get($app->project_id);
            $student = $students->get($app->student_id);
            if (! $project || ! $student) {
                return null;
            }

            $key = $app->project_id.':'.$app->student_id;
            $threadMessages = $messagesByKey[$key] ?? [];
            $latestMessage = $threadMessages[0] ?? null;
            $unreadCount = collect($threadMessages)
                ->filter(fn (ProjectMessage $m) => (int) $m->sender_id !== (int) $msme->id && $m->read_at === null)
                ->count();

            $badgeLabel = match ($app->status) {
                'accepted' => 'Diterima',
                'pending' => 'Pelamar',
                'rejected' => 'Ditolak (Arsip)',
                default => 'Pelamar',
            };

            $lastText = $latestMessage?->message
                ?? ($latestMessage?->attachment_name ? 'Mengirim lampiran: '.$latestMessage->attachment_name : null)
                ?? ($app->status === 'rejected' && $app->rejection_feedback
                    ? '[Evaluasi] '.$app->rejection_feedback
                    : 'Pelamar baru · Mulai obrolan proyek');

            return [
                'thread_id' => 'project-'.$project->id.'-student-'.$student->id,
                'thread_type' => 'project',
                'reference_id' => $project->id,
                'project_id' => $project->id,
                'student_id' => $student->id,
                'partner_name' => $student->name,
                'subtitle' => $project->title,
                'badge_label' => $badgeLabel,
                'application_status' => $app->status,
                'can_send' => in_array($app->status, ['pending', 'accepted'], true),
                'project_status' => $project->status,
                'university' => $student->studentProfile?->university ?? 'Universitas Negeri Surabaya',
                'avatar_url' => $student->studentProfile?->avatar_url,
                'last_message' => $lastText,
                'last_message_at' => $latestMessage?->created_at?->toIso8601String()
                    ?? $app->reviewed_at?->toIso8601String()
                    ?? $app->applied_at?->toIso8601String()
                    ?? $project->updated_at?->toIso8601String(),
                'unread_count' => $unreadCount,
            ];
        })->filter()->values();

        if ($search !== '') {
            $threads = $threads->filter(function (array $row) use ($search) {
                return str_contains(mb_strtolower($row['partner_name']), $search)
                    || str_contains(mb_strtolower($row['subtitle']), $search)
                    || str_contains(mb_strtolower($row['last_message']), $search)
                    || str_contains(mb_strtolower($row['badge_label']), $search);
            })->values();
        }

        $threads = $threads->sortByDesc('last_message_at')->values();

        return response()->json([
            'status' => 'success',
            'data' => $threads,
        ]);
    }

    private function studentInbox(User $user, string $search): JsonResponse
    {
        // Only projects where the student has submitted an application appear in Student Inbox
        $applications = ProjectApplication::query()
            ->with(['project.msme.umkmProfile'])
            ->where('student_id', $user->id)
            ->orderByDesc('applied_at')
            ->get();

        $projectThreads = $applications->map(function (ProjectApplication $app) use ($user) {
            $project = $app->project;
            if (! $project) {
                return null;
            }

            $threadQuery = ProjectMessage::where('project_id', $project->id)
                ->where(function ($q) use ($user) {
                    $q->where('student_id', $user->id)->orWhereNull('student_id');
                });
            $latestMessage = (clone $threadQuery)->latest('created_at')->latest('id')->first();
            $unreadCount = (clone $threadQuery)
                ->where('sender_id', '!=', $user->id)
                ->whereNull('read_at')
                ->count();
            $umkmName = $project->msme?->umkmProfile?->business_name ?? $project->msme?->name ?? 'Mitra UMKM';

            $badgeLabel = match ($app->status) {
                'accepted' => 'Diterima',
                'pending' => 'Menunggu Review',
                'rejected' => 'Ditolak (Arsip)',
                default => 'Lamaran',
            };

            return [
                'thread_id' => 'project-'.$project->id,
                'thread_type' => 'project',
                'reference_id' => $project->id,
                'partner_name' => $umkmName,
                'subtitle' => $project->title,
                'badge_label' => $badgeLabel,
                'application_status' => $app->status,
                'can_send' => in_array($app->status, ['pending', 'accepted'], true),
                'avatar_url' => $project->msme?->umkmProfile?->logo_url,
                'last_message' => $latestMessage?->message
                    ?? ($latestMessage?->attachment_name ? 'Mengirim lampiran: '.$latestMessage->attachment_name : 'Lamaran terkirim · Mulai obrolan proyek dengan mitra'),
                'last_message_at' => $latestMessage?->created_at?->toIso8601String()
                    ?? $app->reviewed_at?->toIso8601String()
                    ?? $app->applied_at?->toIso8601String()
                    ?? $project->updated_at?->toIso8601String(),
                'unread_count' => $unreadCount,
            ];
        })->filter();

        $enrollments = MentoringEnrollment::query()
            ->with(['mentoringClass.mentor.mentorProfile'])
            ->where('student_id', $user->id)
            ->get();

        $mentoringThreads = $enrollments->map(function (MentoringEnrollment $enrollment) {
            $latestMessage = MentoringMessage::where('enrollment_id', $enrollment->id)->latest('created_at')->first();
            $class = $enrollment->mentoringClass;
            $mentor = $class?->mentor;

            return [
                'thread_id' => 'mentor-'.$enrollment->id,
                'thread_type' => 'mentor',
                'reference_id' => $enrollment->id,
                'partner_name' => $mentor?->name ?? 'Mentor',
                'subtitle' => 'Mentor · '.($class?->topic ?? 'Bimbingan'),
                'badge_label' => 'Mentoring',
                'application_status' => null,
                'can_send' => true,
                'avatar_url' => $mentor?->mentorProfile?->avatar_url,
                'last_message' => $latestMessage?->message ?? ($latestMessage?->attachment_url ? 'Mengirim tautan materi bimbingan' : 'Diskusikan jadwal dan persiapan sesi'),
                'last_message_at' => $latestMessage?->created_at?->toIso8601String() ?? $enrollment->updated_at?->toIso8601String(),
                'unread_count' => 0,
            ];
        });

        $threads = $projectThreads
            ->concat($mentoringThreads)
            ->when($search !== '', fn ($col) => $col->filter(function (array $row) use ($search) {
                return str_contains(mb_strtolower($row['partner_name']), $search)
                    || str_contains(mb_strtolower($row['subtitle']), $search)
                    || str_contains(mb_strtolower($row['last_message']), $search);
            }))
            ->sortByDesc('last_message_at')
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => $threads,
        ]);
    }
}
