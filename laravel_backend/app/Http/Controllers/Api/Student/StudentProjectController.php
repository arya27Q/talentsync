<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Project\SubmitDeliverableRequest;
use App\Http\Resources\ProjectPresenter;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectDeliverable;
use App\Models\ProjectMilestone;
use App\Models\Review;
use App\Services\ProjectWorkflowService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudentProjectController extends Controller
{
    public function __construct(private readonly ProjectWorkflowService $workflow)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $student = $request->user();

        $applications = ProjectApplication::query()
            ->with(['project.msme.umkmProfile', 'project.milestones'])
            ->where('student_id', $student->id)
            ->latest('applied_at')
            ->get();

        $activeProjects = [];
        $pendingApplications = [];
        $completedProjects = [];
        $escrowTotalTc = 0;

        foreach ($applications as $app) {
            $project = $app->project;
            if (! $project) {
                continue;
            }
            if ($app->status === 'accepted' && in_array($project->status, ['in_progress', 'review'], true)) {
                $milestones = $project->milestones;
                $totalStages = max(1, $milestones->count());
                $approvedCount = $milestones->where('status', 'approved')->count();
                $releasedTc = (int) $milestones->where('status', 'approved')->sum('reward_tc');
                $escrowTc = max(0, $project->reward_tc - $releasedTc);
                $escrowTotalTc += $escrowTc;
                $currentMilestone = $milestones->first(fn ($m) => in_array($m->status, ['open', 'submitted', 'revision_requested'], true))
                    ?? $milestones->first();

                $card = ProjectPresenter::projectCard($project);
                $activeProjects[] = [
                    ...$card,
                    'current_stage' => min($totalStages, $approvedCount + 1),
                    'total_stages' => $totalStages,
                    'progress_percent' => (int) round(($approvedCount / $totalStages) * 100),
                    'released_tc' => $releasedTc,
                    'escrow_tc' => $escrowTc,
                    'next_milestone' => $currentMilestone?->title ?? 'Pengerjaan tugas aktif',
                    'is_urgent' => $card['days_left'] <= 5,
                ];
            } elseif ($app->status === 'accepted' && $project->status === 'completed') {
                $review = Review::where('reviewee_id', $student->id)
                    ->where('project_id', $project->id)
                    ->first();
                $completedProjects[] = [
                    ...ProjectPresenter::projectCard($project),
                    'rating' => (float) ($review?->rating ?? 5.0),
                    'review_text' => $review?->review_text,
                    'completed_at' => $project->updated_at?->toIso8601String(),
                ];
            } else {
                $pendingApplications[] = ProjectPresenter::application($app);
            }
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'summary' => [
                    'active_count' => count($activeProjects),
                    'escrow_total_tc' => $escrowTotalTc,
                    'pending_count' => count($pendingApplications),
                    'completed_count' => count($completedProjects),
                ],
                'active_projects' => $activeProjects,
                'pending_applications' => $pendingApplications,
                'completed_projects' => $completedProjects,
            ],
        ]);
    }

    public function milestones(Request $request, Project $project): JsonResponse
    {
        $this->workflow->assertAcceptedStudent($request->user(), $project);
        $project->load([
            'msme.umkmProfile',
            'milestones.deliverables' => fn ($q) => $q->where('student_id', $request->user()->id),
        ]);

        $milestones = $project->milestones;
        $totalStages = max(1, $milestones->count());
        $approvedCount = $milestones->where('status', 'approved')->count();
        $releasedTc = (int) $milestones->where('status', 'approved')->sum('reward_tc');

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'summary' => [
                    'approved_count' => $approvedCount,
                    'total_stages' => $totalStages,
                    'progress_percent' => (int) round(($approvedCount / $totalStages) * 100),
                    'released_tc' => $releasedTc,
                    'escrow_tc' => max(0, $project->reward_tc - $releasedTc),
                ],
                'milestones' => $milestones->map(fn (ProjectMilestone $m) => ProjectPresenter::milestone($m))->values(),
            ],
        ]);
    }

    public function addMilestone(Request $request, Project $project): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'min:3', 'max:200'],
            'description' => ['nullable', 'string', 'max:2000'],
            'reward_tc' => ['required', 'integer', 'min:1', 'max:100000'],
        ]);

        $milestone = $this->workflow->addCustomMilestone($request->user(), $project, $data);

        return response()->json([
            'status' => 'success',
            'message' => 'Tahap milestone baru berhasil ditambahkan.',
            'data' => ProjectPresenter::milestone($milestone),
        ], 201);
    }

    public function submitDeliverable(SubmitDeliverableRequest $request, ProjectMilestone $milestone): JsonResponse
    {
        $deliverable = $this->workflow->submitMilestoneDeliverable(
            $request->user(),
            $milestone,
            $request->validated(),
            $request->file('deliverable_file'),
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Hasil pekerjaan berhasil dikirim untuk peninjauan mitra UMKM.',
            'data' => ProjectPresenter::deliverable($deliverable),
        ], 201);
    }

    public function completionSummary(Request $request, Project $project): JsonResponse
    {
        $student = $request->user();
        $this->workflow->assertAcceptedStudent($student, $project);
        $project->load(['msme.umkmProfile', 'milestones']);

        $deliverables = ProjectDeliverable::where('project_id', $project->id)
            ->where('student_id', $student->id)
            ->latest('submitted_at')
            ->get()
            ->map(fn (ProjectDeliverable $d) => ProjectPresenter::deliverable($d))
            ->values();

        $clientReviewOfStudent = Review::where('reviewer_id', $project->msme_id)
            ->where('reviewee_id', $student->id)
            ->where('project_id', $project->id)
            ->first();

        $studentReviewOfClient = Review::where('reviewer_id', $student->id)
            ->where('reviewee_id', $project->msme_id)
            ->where('project_id', $project->id)
            ->first();

        $finalMilestone = $project->milestones->sortByDesc('step_order')->first();

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'final_released_tc' => $finalMilestone?->reward_tc ?? $project->reward_tc,
                'deliverables' => $deliverables,
                'client_testimonial' => $clientReviewOfStudent ? [
                    'author_name' => $project->msme?->umkmProfile?->business_name ?? $project->msme?->name,
                    'rating' => $clientReviewOfStudent->rating,
                    'comment' => $clientReviewOfStudent->review_text,
                ] : null,
                'has_reviewed_client' => $studentReviewOfClient !== null,
                'student_review' => $studentReviewOfClient ? [
                    'rating' => $studentReviewOfClient->rating,
                    'review_text' => $studentReviewOfClient->review_text,
                ] : null,
            ],
        ]);
    }

    public function reviewClient(Request $request, Project $project): JsonResponse
    {
        $data = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'review_text' => ['nullable', 'string', 'max:2000'],
        ]);

        $review = $this->workflow->reviewClient($request->user(), $project, $data);

        return response()->json([
            'status' => 'success',
            'message' => 'Ulasan untuk mitra UMKM berhasil disimpan.',
            'data' => [
                'id' => $review->id,
                'rating' => $review->rating,
                'review_text' => $review->review_text,
            ],
        ], 201);
    }
}

