<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProjectPresenter;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMilestone;
use App\Models\TimeCoinWallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MsmeDashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $umkmProfile = $user->umkmProfile;

        $projectsQuery = Project::where('msme_id', $user->id);
        $totalProjectsCount = (clone $projectsQuery)->count();
        $activeProjectsCount = (clone $projectsQuery)->whereIn('status', ['open', 'in_progress', 'review'])->count();
        $inProgressProjectsCount = (clone $projectsQuery)->whereIn('status', ['in_progress', 'review'])->count();
        $completedProjectsCount = (clone $projectsQuery)->where('status', 'completed')->count();

        $projectIds = (clone $projectsQuery)->pluck('id');
        $newApplicantsCount = ProjectApplication::whereIn('project_id', $projectIds)
            ->where('status', 'pending')
            ->count();

        $pendingSubmissionsQuery = ProjectMilestone::query()
            ->with([
                'project:id,title',
                'deliverables' => fn ($q) => $q->with('student.studentProfile')->latest('id'),
            ])
            ->whereIn('project_id', $projectIds)
            ->where('status', 'submitted');

        $pendingSubmissionsCount = (clone $pendingSubmissionsQuery)->count();
        $latestPendingMilestone = (clone $pendingSubmissionsQuery)->latest('updated_at')->first();
        $latestDeliverable = $latestPendingMilestone?->deliverables?->first();
        $latestStudent = $latestDeliverable?->student;
        $pendingSubmissionPreview = $latestPendingMilestone ? [
            'project_id' => $latestPendingMilestone->project_id,
            'milestone_id' => $latestPendingMilestone->id,
            'project_title' => $latestPendingMilestone->project?->title ?? 'Proyek UMKM',
            'milestone_title' => $latestPendingMilestone->title,
            'student_name' => $latestStudent?->name ?? 'Mahasiswa',
            'student_avatar_url' => $latestStudent?->studentProfile?->avatar_url,
        ] : null;

        $wallet = TimeCoinWallet::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'locked_balance' => 0]
        );

        $recentPostings = Project::with([
            'msme.umkmProfile',
            'milestones',
            'applications' => fn ($q) => $q->with('student.studentProfile'),
        ])
            ->where('msme_id', $user->id)
            ->latest('id')
            ->take(5)
            ->get()
            ->map(function ($project) {
                /** @var Project $project */
                $applicantsCount = $project->applications->count();
                $acceptedApp = $project->applications->firstWhere('status', 'accepted');
                $student = $acceptedApp?->student;
                $studentProfile = $student?->studentProfile;
                $milestones = $project->milestones;
                $totalStages = max(1, $milestones->count());
                $approvedCount = $milestones->where('status', 'approved')->count();
                $hasPendingSubmission = $milestones->contains('status', 'submitted');

                return [
                    ...ProjectPresenter::projectCard($project),
                    'applicants_count' => $applicantsCount,
                    'current_stage' => min($totalStages, $approvedCount + 1),
                    'total_stages' => $totalStages,
                    'progress_percent' => (int) round(($approvedCount / $totalStages) * 100),
                    'has_pending_submission' => $hasPendingSubmission,
                    'accepted_student' => $student ? [
                        'id' => $student->id,
                        'name' => $student->name,
                        'avatar_url' => $studentProfile?->avatar_url,
                        'university' => $studentProfile?->university ?? 'Universitas Negeri Surabaya',
                    ] : null,
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => [
                'owner_name' => $user->name,
                'business_name' => $umkmProfile?->business_name ?? $user->name,
                'business_sector' => $umkmProfile?->business_sector ?? 'UMKM',
                'logo_url' => $umkmProfile?->logo_url,
                'avatar_url' => $umkmProfile?->logo_url,
                'address' => $umkmProfile?->address,
                'city' => $umkmProfile?->city ?? 'Surabaya',
                'nib' => $umkmProfile?->nib,
                'balance_tc' => (int) $wallet->balance,
                'locked_balance_tc' => (int) $wallet->locked_balance,
                'active_projects_count' => $activeProjectsCount,
                'new_applicants_count' => $newApplicantsCount,
                'pending_submissions_count' => $pendingSubmissionsCount,
                'pending_submission_preview' => $pendingSubmissionPreview,
                'completed_projects_count' => $completedProjectsCount,
                'total_projects_count' => $totalProjectsCount,
                'active_slots_used' => min(2, $activeProjectsCount),
                'active_slots_max' => (bool) ($umkmProfile?->is_premium ?? false) ? 10 : 2,
                'is_premium' => (bool) ($umkmProfile?->is_premium ?? false),
                'is_verified' => (bool) ($umkmProfile?->is_verified ?? true),
                'recent_postings' => $recentPostings,
            ],
        ]);
    }
}
