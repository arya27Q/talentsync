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
        $completedProjectsCount = (int) ($student->studentProfile?->completed_projects_count ?? 0);
        $radarMetrics = $this->buildRadarMetrics(
            $skills,
            $portfolios,
            $completedProjectsCount,
            $certificates->count(),
            $completedMentoring->count(),
        );

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

    private function buildRadarMetrics(
        $skills,
        $portfolios,
        int $completedProjectsCount,
        int $certificatesCount,
        int $mentoringCount,
    ): array {
        $verifiedPortfolios = $portfolios->filter(fn (Portfolio $p) => (bool) $p->is_verified);
        $totalEvidence = max($portfolios->count(), $completedProjectsCount);
        $hasAnyActivity = $totalEvidence > 0 || $certificatesCount > 0 || $mentoringCount > 0;

        // Build searchable portfolio text for category/tool matching
        $portfolioCorpus = $portfolios->map(function (Portfolio $p) {
            return mb_strtolower(trim(implode(' ', array_filter([
                $p->title,
                $p->category,
                $p->tools_or_tech ?? '',
                $p->description ?? '',
            ]))));
        });

        $defaultLabels = ['Flutter', 'Laravel', 'UI Design', 'Database', 'Komunikasi', 'Testing'];

        $labels = $skills->take(6)
            ->map(fn (StudentSkill $s) => [
                'label' => $s->name,
                'is_verified' => (bool) $s->is_verified,
                'raw_score' => (int) $s->score,
            ])
            ->values()
            ->all();

        foreach ($defaultLabels as $fallbackLabel) {
            if (count($labels) >= 6) {
                break;
            }
            $exists = collect($labels)->contains(
                fn ($row) => mb_strtolower($row['label']) === mb_strtolower($fallbackLabel)
            );
            if (! $exists) {
                $labels[] = [
                    'label' => $fallbackLabel,
                    'is_verified' => false,
                    'raw_score' => 0,
                ];
            }
        }

        // Dynamic scaling:
        // - 0 portfolios, 0 completed projects, 0 certs, 0 mentoring -> 0 (or tiny 15 baseline only for explicitly added skills)
        // - Grows automatically as verified portfolios, completed projects, certs, and mentoring sessions accumulate!
        $activityBase = $hasAnyActivity
            ? min(85, ($totalEvidence * 18) + ($verifiedPortfolios->count() * 8) + ($certificatesCount * 6) + ($mentoringCount * 5))
            : 0;

        return collect($labels)->map(function (array $item) use ($hasAnyActivity, $activityBase, $portfolioCorpus) {
            $label = $item['label'];
            $needle = mb_strtolower($label);

            if (! $hasAnyActivity) {
                // Fresh student without any portfolio/project/cert/mentoring yet:
                // keep chart small/zero so it visibly expands once real portfolio work exists
                $score = $item['raw_score'] > 0 ? 15 : 0;
                return ['label' => $label, 'score' => $score];
            }

            $matchedPortfolios = $portfolioCorpus->filter(fn (string $text) => str_contains($text, $needle))->count();
            $bonus = ($matchedPortfolios * 12) + ($item['is_verified'] ? 10 : 0);
            if ($needle === 'komunikasi') {
                $bonus += 8;
            }
            $score = max(20, min(100, $activityBase + $bonus));

            return ['label' => $label, 'score' => $score];
        })->values()->all();
    }
}

