<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\StudentPresenter;
use App\Models\MentoringEnrollment;
use App\Models\Portfolio;
use App\Models\StudentCertificate;
use App\Models\StudentSkill;
use App\Models\TimeCoinWallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PortfolioController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $student = $request->user()->load(['roleRecord', 'roles', 'studentProfile', 'studentSkills']);
        $balance = TimeCoinWallet::where('user_id', $student->id)->value('balance') ?? 0;

        $portfolios = Portfolio::where('student_id', $student->id)
            ->orderByDesc('is_featured')
            ->latest()
            ->get();

        $certificates = StudentCertificate::where('student_id', $student->id)->latest('issued_at')->get();
        $completedMentoring = MentoringEnrollment::query()
            ->with('mentoringClass')
            ->where('student_id', $student->id)
            ->whereIn('status', ['attended', 'pending_confirmation', 'completed'])
            ->get();

        $mentoringMinutes = (int) $completedMentoring->sum(fn (MentoringEnrollment $e) => $e->mentoringClass?->duration_minutes ?? 60);

        $skills = $student->studentSkills;
        $radarMetrics = $this->buildRadarMetrics($skills);

        $endorsements = MentoringEnrollment::query()
            ->with('mentoringClass.mentor:id,name')
            ->where('student_id', $student->id)
            ->where('has_endorsement', true)
            ->latest()
            ->get()
            ->map(fn (MentoringEnrollment $e) => [
                'enrollment_id' => $e->id,
                'mentor_name' => $e->mentoringClass?->mentor?->name ?? 'Mentor',
                'notes' => $e->endorsement_notes,
                'score' => $e->assessment_score,
            ])
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'profile' => StudentPresenter::profile($student, $balance, $endorsements->isNotEmpty()),
                'public_cv_url' => 'https://talentsync.id/cv/'.str_replace(' ', '-', mb_strtolower($student->name)),
                'certificates_count' => $certificates->count(),
                'mentoring_sessions_count' => $completedMentoring->count(),
                'mentoring_hours' => round($mentoringMinutes / 60, 1),
                'radar_metrics' => $radarMetrics,
                'endorsements' => $endorsements,
                'verified_projects' => $portfolios->map(fn (Portfolio $p) => StudentPresenter::portfolio($p))->values(),
            ],
        ]);
    }

    public function caseStudy(Request $request, Portfolio $portfolio): JsonResponse
    {
        abort_unless($portfolio->student_id === $request->user()->id || $portfolio->is_verified, 403);

        return response()->json([
            'status' => 'success',
            'data' => StudentPresenter::portfolio($portfolio),
        ]);
    }

    public function certificates(Request $request): JsonResponse
    {
        $student = $request->user()->load('studentProfile');
        $certificates = StudentCertificate::where('student_id', $student->id)
            ->latest('issued_at')
            ->get()
            ->map(fn (StudentCertificate $c) => StudentPresenter::certificate($c))
            ->values();

        $completedCount = (int) ($student->studentProfile?->completed_projects_count ?? 0);
        $requiredCount = 5;

        $lockedMilestones = $completedCount >= $requiredCount ? [] : [[
            'title' => 'Sertifikat Mentor TalentSync',
            'subtitle' => "Terbuka setelah {$requiredCount} proyek selesai ({$completedCount}/{$requiredCount})",
            'current_count' => $completedCount,
            'required_count' => $requiredCount,
        ]];

        return response()->json([
            'status' => 'success',
            'data' => [
                'certificates' => $certificates,
                'locked_milestones' => $lockedMilestones,
            ],
        ]);
    }

    private function buildRadarMetrics($skills): array
    {
        if ($skills->isEmpty()) {
            return [
                ['label' => 'Flutter', 'score' => 70],
                ['label' => 'Laravel', 'score' => 65],
                ['label' => 'UI Design', 'score' => 60],
                ['label' => 'Database', 'score' => 65],
                ['label' => 'Komunikasi', 'score' => 80],
                ['label' => 'Testing', 'score' => 60],
            ];
        }

        $items = $skills->take(6)->map(fn (StudentSkill $s) => [
            'label' => $s->name,
            'score' => (int) $s->score,
        ])->values()->all();

        $fallbacks = [
            ['label' => 'Komunikasi', 'score' => 88],
            ['label' => 'Testing', 'score' => 72],
            ['label' => 'Database', 'score' => 75],
            ['label' => 'UI Design', 'score' => 70],
            ['label' => 'Laravel', 'score' => 70],
            ['label' => 'Flutter', 'score' => 85],
        ];
        foreach ($fallbacks as $fallback) {
            if (count($items) >= 6) {
                break;
            }
            $exists = collect($items)->contains(fn ($i) => mb_strtolower($i['label']) === mb_strtolower($fallback['label']));
            if (! $exists) {
                $items[] = $fallback;
            }
        }

        return $items;
    }
}

