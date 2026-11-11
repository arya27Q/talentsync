<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentoringEnrollment;
use App\Models\MentoringMessage;
use App\Models\Project;
use App\Models\ProjectMessage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InboxController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $search = mb_strtolower(trim((string) $request->query('q', '')));

        $projects = Project::query()
            ->with(['msme.umkmProfile'])
            ->where(function ($query) use ($user) {
                $query->whereHas('applications', fn ($app) => $app->where('student_id', $user->id))
                    ->orWhereHas('messages', fn ($msg) => $msg->where('sender_id', $user->id));
            })
            ->get();

        $projectThreads = $projects->map(function (Project $project) use ($user) {
            $latestMessage = ProjectMessage::where('project_id', $project->id)->latest('created_at')->first();
            $unreadCount = ProjectMessage::where('project_id', $project->id)
                ->where('sender_id', '!=', $user->id)
                ->whereNull('read_at')
                ->count();
            $umkmName = $project->msme?->umkmProfile?->business_name ?? $project->msme?->name ?? 'Mitra UMKM';

            return [
                'thread_id' => 'project-'.$project->id,
                'thread_type' => 'project',
                'reference_id' => $project->id,
                'partner_name' => $umkmName,
                'subtitle' => $project->title,
                'avatar_url' => $project->msme?->umkmProfile?->logo_url,
                'last_message' => $latestMessage?->message ?? ($latestMessage?->attachment_name ? 'Mengirim lampiran: '.$latestMessage->attachment_name : 'Mulai obrolan proyek dengan mitra'),
                'last_message_at' => $latestMessage?->created_at?->toIso8601String() ?? $project->updated_at?->toIso8601String(),
                'unread_count' => $unreadCount,
            ];
        });

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

