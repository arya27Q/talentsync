<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Http\Resources\ProjectPresenter;
use App\Http\Resources\StudentPresenter;
use App\Models\MentoringEnrollment;
use App\Models\Project;
use App\Models\TimeCoinWallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentDashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $student = $request->user()->load(['roleRecord', 'roles', 'studentProfile', 'studentSkills']);
        $wallet = TimeCoinWallet::firstOrCreate(['user_id' => $student->id]);

        $activeProjects = Project::query()
            ->with(['msme.umkmProfile', 'milestones'])
            ->whereIn('status', ['in_progress', 'review'])
            ->whereHas('applications', fn ($q) => $q->where('student_id', $student->id)->where('status', 'accepted'))
            ->latest('updated_at')
            ->get()
            ->map(function (Project $project) {
                $milestones = $project->milestones;
                $totalStages = max(1, $milestones->count());
                $approvedCount = $milestones->where('status', 'approved')->count();
                $releasedTc = (int) $milestones->where('status', 'approved')->sum('reward_tc');
                $currentMilestone = $milestones->first(fn ($m) => in_array($m->status, ['open', 'submitted', 'revision_requested'], true))
                    ?? $milestones->first();
                $card = ProjectPresenter::projectCard($project);

                return [
                    ...$card,
                    'current_stage' => min($totalStages, $approvedCount + 1),
                    'total_stages' => $totalStages,
                    'progress_percent' => (int) round(($approvedCount / $totalStages) * 100),
                    'released_tc' => $releasedTc,
                    'escrow_tc' => max(0, $project->reward_tc - $releasedTc),
                    'next_milestone' => $currentMilestone?->title ?? 'Tahap pengerjaan proyek',
                    'is_urgent' => $card['days_left'] <= 5,
                ];
            })
            ->values();

        $nextMentoring = MentoringEnrollment::query()
            ->with(['mentoringClass.mentor.mentorProfile'])
            ->where('student_id', $student->id)
            ->whereIn('status', ['accepted', 'pending', 'attended', 'pending_confirmation'])
            ->orderByDesc('updated_at')
            ->first();

        $bookmarkedProjectIds = $student->projectBookmarks()->pluck('project_id')->all();
        $recommendedProjects = Project::query()
            ->with(['msme.umkmProfile'])
            ->where('status', 'open')
            ->orderByDesc('created_at')
            ->limit(3)
            ->get()
            ->map(fn (Project $p) => ProjectPresenter::projectCard($p, in_array($p->id, $bookmarkedProjectIds, true)))
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => StudentPresenter::profile($student, $wallet->balance),
                'wallet' => [
                    'balance_tc' => $wallet->balance,
                    'locked_balance_tc' => $wallet->locked_balance,
                    'estimated_idr' => $wallet->balance * 1000,
                ],
                'unread_notifications_count' => $student->unreadNotifications()->count(),
                'active_projects_count' => $activeProjects->count(),
                'active_projects' => $activeProjects,
                'next_mentoring' => $nextMentoring ? MentoringPresenter::enrollment($nextMentoring) : null,
                'recommended_projects' => $recommendedProjects,
            ],
        ]);
    }
}

