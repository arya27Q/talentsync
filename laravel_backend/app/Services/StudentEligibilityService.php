<?php

namespace App\Services;

use App\Models\EscrowDispute;
use App\Models\MentoringEnrollment;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\StudentProfile;
use App\Models\User;

class StudentEligibilityService
{
    public function projectApplicationEligibility(User $student, Project $project): array
    {
        $hasVerifiedPortfolio = Portfolio::query()
            ->where('student_id', $student->id)
            ->where('is_verified', true)
            ->exists();

        $hasMentorEndorsement = MentoringEnrollment::query()
            ->where('student_id', $student->id)
            ->where('has_endorsement', true)
            ->exists();

        if ($project->requires_endorsement) {
            $canApply = $hasMentorEndorsement;
            $reason = $canApply
                ? 'Memenuhi syarat khusus pelamar ber-Badge Rekomendasi Mentor.'
                : 'Proyek ini mewajibkan Badge Rekomendasi Kerja dari Mentor. Ikuti bimbingan mentor terlebih dahulu.';
        } else {
            $canApply = $hasVerifiedPortfolio || $hasMentorEndorsement;
            $reason = $canApply
                ? ($hasMentorEndorsement
                    ? 'Memenuhi syarat melalui Badge Rekomendasi Mentor.'
                    : 'Memenuhi syarat melalui Portofolio Terverifikasi.')
                : 'Wajib memiliki Portofolio Terverifikasi atau Badge Rekomendasi Mentor sebelum melamar proyek UMKM.';
        }

        return [
            'can_apply' => $canApply,
            'has_verified_portfolio' => $hasVerifiedPortfolio,
            'has_mentor_endorsement' => $hasMentorEndorsement,
            'requires_endorsement' => (bool) $project->requires_endorsement,
            'reason' => $reason,
        ];
    }

    public function mentorSwitchEligibility(User $student): array
    {
        $profile = StudentProfile::where('user_id', $student->id)->first();
        $ktmVerified = $profile?->ktm_verification_status === 'approved' && ! empty($profile?->student_id_number);

        $verifiedPortfolioCount = Portfolio::where('student_id', $student->id)
            ->where('is_verified', true)
            ->count();

        $completedProjects = max(
            (int) ($profile?->completed_projects_count ?? 0),
            Project::where('status', 'completed')
                ->whereHas('applications', fn ($q) => $q->where('student_id', $student->id)->where('status', 'accepted'))
                ->count(),
            $verifiedPortfolioCount,
        );

        $minProjectsRequired = 5;
        $ratingAverage = (float) ($profile?->rating_average ?? 0);
        if ($ratingAverage <= 0 && $verifiedPortfolioCount > 0) {
            $ratingAverage = (float) Portfolio::where('student_id', $student->id)->avg('rating');
        }

        $hasOpenDispute = EscrowDispute::where('reporter_id', $student->id)
            ->where('status', '!=', 'resolved')
            ->exists();

        $ratingValid = $completedProjects === 0 ? false : $ratingAverage >= 4.0;
        $isEligible = $ktmVerified
            && $completedProjects >= $minProjectsRequired
            && $ratingValid
            && ! $hasOpenDispute;

        if ($profile && ($profile->is_mentor_eligible !== $isEligible || $profile->completed_projects_count !== $completedProjects)) {
            $profile->update([
                'is_mentor_eligible' => $isEligible,
                'completed_projects_count' => $completedProjects,
            ]);
        }

        return [
            'is_eligible' => $isEligible,
            'already_mentor' => $student->hasAssignedRole('mentor'),
            'completed_projects_count' => $completedProjects,
            'min_projects_required' => $minProjectsRequired,
            'rating_average' => round($ratingAverage, 2),
            'checks' => [
                [
                    'key' => 'ktm_verified',
                    'label' => 'KTM & Identitas Akademik Terverifikasi',
                    'detail' => $ktmVerified
                        ? ($profile?->university.' · NIM '.$profile?->student_id_number)
                        : 'Unggah dan verifikasi KTM terlebih dahulu.',
                    'passed' => $ktmVerified,
                ],
                [
                    'key' => 'completed_projects',
                    'label' => "Selesaikan minimal {$minProjectsRequired} proyek UMKM nyata",
                    'detail' => "{$completedProjects}/{$minProjectsRequired} proyek selesai terverifikasi.",
                    'passed' => $completedProjects >= $minProjectsRequired,
                ],
                [
                    'key' => 'rating',
                    'label' => 'Reputasi rating UMKM minimal 4.0',
                    'detail' => $ratingAverage > 0
                        ? 'Rating rata-rata '.number_format($ratingAverage, 1).' dari proyek selesai.'
                        : 'Belum memiliki ulasan proyek selesai.',
                    'passed' => $ratingValid,
                ],
                [
                    'key' => 'no_dispute',
                    'label' => 'Bebas sengketa escrow aktif',
                    'detail' => $hasOpenDispute
                        ? 'Selesaikan laporan kendala escrow yang masih aktif.'
                        : 'Tidak ada sengketa atau penalti aktif.',
                    'passed' => ! $hasOpenDispute,
                ],
            ],
        ];
    }
}

