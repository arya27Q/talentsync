<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Project\ApplyProjectRequest;
use App\Http\Resources\ProjectPresenter;
use App\Http\Resources\StudentPresenter;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectBookmark;
use App\Services\ProjectWorkflowService;
use App\Services\StudentEligibilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function __construct(
        private readonly ProjectWorkflowService $workflow,
        private readonly StudentEligibilityService $eligibility,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $student = $request->user();
        $search = mb_strtolower(trim((string) $request->query('search', '')));
        $category = trim((string) $request->query('category', ''));
        $sort = trim((string) $request->query('sort', 'recommended'));
        $mentorCertOnly = $request->boolean('mentor_certificate_only');

        $query = Project::query()
            ->with(['msme.umkmProfile'])
            ->where('status', 'open');

        if ($search !== '') {
            $like = '%'.$search.'%';
            $query->where(function ($q) use ($like) {
                $q->whereRaw('LOWER(title) LIKE ?', [$like])
                    ->orWhereRaw('LOWER(description) LIKE ?', [$like])
                    ->orWhereRaw('LOWER(category) LIKE ?', [$like])
                    ->orWhereHas('msme.umkmProfile', fn ($u) => $u->whereRaw('LOWER(business_name) LIKE ?', [$like]));
            });
        }

        if ($category !== '' && ! in_array(mb_strtolower($category), ['semua', 'terdekat'], true)) {
            $catLower = mb_strtolower($category);
            $query->where(function ($q) use ($catLower) {
                $q->whereRaw('LOWER(category) LIKE ?', ['%'.$catLower.'%'])
                    ->orWhereRaw('LOWER(CAST(skills AS CHAR)) LIKE ?', ['%'.$catLower.'%']);
            });
        }

        if (mb_strtolower($category) === 'terdekat') {
            $query->whereHas('msme.umkmProfile', fn ($u) => $u->whereRaw("LOWER(city) LIKE '%surabaya%'"));
        }

        if ($mentorCertOnly) {
            $query->where(function ($q) {
                $q->where('requires_endorsement', true)
                    ->orWhere('benefit_badge', 'like', '%Rekomendasi%');
            });
        }

        match ($sort) {
            'highest_reward' => $query->orderByDesc('reward_tc'),
            'nearest_deadline' => $query->orderBy('deadline'),
            default => $query->orderByDesc('created_at'),
        };

        $projects = $query->paginate(min((int) $request->integer('per_page', 15), 50));
        $bookmarkedIds = ProjectBookmark::where('student_id', $student->id)
            ->pluck('project_id')
            ->all();

        $latestUpdated = Project::where('status', 'open')->max('updated_at');

        return response()->json([
            'status' => 'success',
            'data' => $projects->getCollection()
                ->map(fn (Project $p) => ProjectPresenter::projectCard($p, in_array($p->id, $bookmarkedIds, true)))
                ->values(),
            'meta' => [
                'current_page' => $projects->currentPage(),
                'last_page' => $projects->lastPage(),
                'total' => $projects->total(),
                'total_verified_projects' => Project::where('status', 'open')->count(),
                'last_updated_at' => $latestUpdated,
            ],
        ]);
    }

    public function show(Request $request, Project $project): JsonResponse
    {
        $student = $request->user();
        $project->load(['msme.umkmProfile', 'milestones']);

        $isBookmarked = ProjectBookmark::where('project_id', $project->id)
            ->where('student_id', $student->id)
            ->exists();
        $existingApp = ProjectApplication::where('project_id', $project->id)
            ->where('student_id', $student->id)
            ->first();
        $eligibility = $this->eligibility->projectApplicationEligibility($student, $project);

        return response()->json([
            'status' => 'success',
            'data' => ProjectPresenter::projectDetail($project, $eligibility, $isBookmarked, $existingApp),
        ]);
    }

    public function toggleBookmark(Request $request, Project $project): JsonResponse
    {
        $studentId = $request->user()->id;
        $existing = ProjectBookmark::where('project_id', $project->id)
            ->where('student_id', $studentId)
            ->first();

        if ($existing) {
            $existing->delete();
            $bookmarked = false;
        } else {
            ProjectBookmark::create([
                'project_id' => $project->id,
                'student_id' => $studentId,
            ]);
            $bookmarked = true;
        }

        return response()->json([
            'status' => 'success',
            'message' => $bookmarked ? 'Proyek disimpan ke favorit.' : 'Proyek dihapus dari favorit.',
            'data' => ['is_bookmarked' => $bookmarked],
        ]);
    }

    public function applyContext(Request $request, Project $project): JsonResponse
    {
        $student = $request->user();
        $project->load(['msme.umkmProfile', 'milestones']);
        $eligibility = $this->eligibility->projectApplicationEligibility($student, $project);
        $portfolios = Portfolio::where('student_id', $student->id)
            ->where('is_verified', true)
            ->latest()
            ->get()
            ->map(fn (Portfolio $p) => StudentPresenter::portfolio($p))
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'project' => ProjectPresenter::projectCard($project),
                'eligibility' => $eligibility,
                'portfolios' => $portfolios,
            ],
        ]);
    }

    public function apply(ApplyProjectRequest $request, Project $project): JsonResponse
    {
        $application = $this->workflow->apply($request->user(), $project, $request->validated());

        return response()->json([
            'status' => 'success',
            'message' => 'Lamaran berhasil diajukan dan menunggu kurasi UMKM.',
            'data' => ProjectPresenter::application($application->load('project.msme.umkmProfile')),
        ], 201);
    }
}

