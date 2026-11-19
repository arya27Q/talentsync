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

        $minProjectsRequired = 20;
        $ratingAverage = (float) ($profile?->rating_average ?? 0);
        if ($ratingAverage <= 0 && $verifiedPortfolioCount > 0) {
            $ratingAverage = (float) Portfolio::where('student_id', $student->id)->avg('rating');
        }

        $hasOpenDispute = EscrowDispute::where('reporter_id', $student->id)
            ->where('status', '!=', 'resolved')
            ->exists();

        // Pilar 1: Jam Terbang Nyata (Minimal 20 proyek, rating >= 4.8, bebas sengketa)
        $minRatingRequired = 4.8;
        $ratingValid = $completedProjects === 0 ? false : $ratingAverage >= $minRatingRequired;
        $pillar1Valid = ($completedProjects >= $minProjectsRequired) && $ratingValid && (! $hasOpenDispute);

        // Pilar 2: Pengakuan Mitra Luar (Minimal 3 ulasan bintang tinggi / surat kepuasan mitra UMKM)
        $reviewsCount = \App\Models\Review::where('reviewee_id', $student->id)
            ->where('rating', '>=', 4.5)
            ->count();
        $verifiedClientsCount = Portfolio::where('student_id', $student->id)
            ->where('is_verified', true)
            ->whereNotNull('client_name')
            ->distinct('client_name')
            ->count();
        $partnerEndorsements = max($reviewsCount, $verifiedClientsCount);
        $minPartnerEndorsements = 3;
        $pillar2Valid = $partnerEndorsements >= $minPartnerEndorsements;

        // Pilar 3: Validasi Industri / Eksternal (Minimal 1 sertifikasi industri BNSP/Google atau rekomendasi eksternal)
        $externalCertsCount = \App\Models\StudentCertificate::where('student_id', $student->id)
            ->where(function ($q) {
                $q->where('source_type', 'external')
                    ->orWhere('source_type', 'mentoring_endorsement')
                    ->orWhere('category_label', 'like', '%sertifikasi%')
                    ->orWhereNotNull('file_url');
            })
            ->count();
        $minExternalCerts = 1;
        $pillar3Valid = $externalCertsCount >= $minExternalCerts;

        $isEligible = $ktmVerified
            && $pillar1Valid
            && $pillar2Valid
            && $pillar3Valid;

        if ($profile && ($profile->is_mentor_eligible !== $isEligible || $profile->completed_projects_count !== $completedProjects)) {
            $profile->update([
                'is_mentor_eligible' => $isEligible,
                'completed_projects_count' => $completedProjects,
            ]);
        }

        $checks = [
            [
                'pillar' => 0,
                'pillar_name' => 'Prasyarat Identitas Akademik',
                'key' => 'ktm_verified',
                'label' => 'KTM & Identitas Akademik Terverifikasi',
                'detail' => $ktmVerified
                    ? ($profile?->university.' · NIM '.$profile?->student_id_number)
                    : 'Unggah dan verifikasi KTM terlebih dahulu.',
                'passed' => $ktmVerified,
            ],
            [
                'pillar' => 1,
                'pillar_name' => 'Pilar 1: Jam Terbang Nyata',
                'key' => 'completed_projects',
                'label' => "Selesaikan minimal {$minProjectsRequired} proyek UMKM nyata",
                'detail' => "{$completedProjects}/{$minProjectsRequired} proyek selesai terverifikasi.",
                'passed' => $completedProjects >= $minProjectsRequired,
            ],
            [
                'pillar' => 1,
                'pillar_name' => 'Pilar 1: Jam Terbang Nyata',
                'key' => 'rating',
                'label' => "Reputasi rating UMKM minimal {$minRatingRequired}",
                'detail' => $ratingAverage > 0
                    ? 'Rating rata-rata '.number_format($ratingAverage, 2).' dari proyek selesai.'
                    : 'Belum memiliki ulasan proyek selesai.',
                'passed' => $ratingValid,
            ],
            [
                'pillar' => 1,
                'pillar_name' => 'Pilar 1: Jam Terbang Nyata',
                'key' => 'no_dispute',
                'label' => 'Bebas sengketa escrow aktif (Zero Dispute)',
                'detail' => $hasOpenDispute
                    ? 'Selesaikan laporan kendala escrow yang masih aktif.'
                    : 'Tidak ada sengketa atau penalti aktif.',
                'passed' => ! $hasOpenDispute,
            ],
            [
                'pillar' => 2,
                'pillar_name' => 'Pilar 2: Pengakuan Mitra Luar',
                'key' => 'partner_endorsements',
                'label' => "Minimal {$minPartnerEndorsements} Surat Kepuasan / Ulasan Mitra UMKM",
                'detail' => $partnerEndorsements > 0
                    ? "{$partnerEndorsements}/{$minPartnerEndorsements} mitra UMKM terverifikasi memberikan ulasan bintang tinggi."
                    : "0/{$minPartnerEndorsements} mitra UMKM. Selesaikan proyek untuk memperoleh ulasan mitra.",
                'passed' => $pillar2Valid,
            ],
            [
                'pillar' => 3,
                'pillar_name' => 'Pilar 3: Validasi Industri / Eksternal',
                'key' => 'external_validation',
                'label' => "Minimal {$minExternalCerts} Sertifikasi Industri atau Rekomendasi Eksternal",
                'detail' => $externalCertsCount > 0
                    ? "Tersedia {$externalCertsCount} sertifikasi industri / rekomendasi terdata."
                    : 'Unggah berkas sertifikasi (BNSP/Google) atau rekomendasi dosen pada formulir di bawah.',
                'passed' => $pillar3Valid,
            ],
        ];

        return [
            'is_eligible' => $isEligible,
            'already_mentor' => $student->hasAssignedRole('mentor'),
            'ktm_verified' => $ktmVerified,
            'completed_projects_count' => $completedProjects,
            'min_projects_required' => $minProjectsRequired,
            'rating_average' => round($ratingAverage, 2),
            'min_rating_required' => $minRatingRequired,
            'partner_endorsements_count' => $partnerEndorsements,
            'min_partner_endorsements' => $minPartnerEndorsements,
            'external_certs_count' => $externalCertsCount,
            'min_external_certs' => $minExternalCerts,
            'has_open_dispute' => $hasOpenDispute,
            'pillars_summary' => [
                'pillar_1' => [
                    'number' => 1,
                    'title' => 'Jam Terbang Nyata',
                    'subtitle' => "Minimal {$minProjectsRequired} Proyek UMKM & Rating {$minRatingRequired}",
                    'passed' => $pillar1Valid,
                    'progress' => min(1.0, $completedProjects / $minProjectsRequired),
                    'metric' => "{$completedProjects}/{$minProjectsRequired} Proyek · ★ ".number_format($ratingAverage, 1),
                ],
                'pillar_2' => [
                    'number' => 2,
                    'title' => 'Pengakuan Mitra Luar',
                    'subtitle' => "Minimal {$minPartnerEndorsements} Ulasan / Surat Kepuasan Mitra UMKM",
                    'passed' => $pillar2Valid,
                    'progress' => min(1.0, $partnerEndorsements / $minPartnerEndorsements),
                    'metric' => "{$partnerEndorsements}/{$minPartnerEndorsements} Mitra UMKM",
                ],
                'pillar_3' => [
                    'number' => 3,
                    'title' => 'Validasi Industri / Eksternal',
                    'subtitle' => 'Sertifikasi BNSP/Google atau Rekomendasi Dosen',
                    'passed' => $pillar3Valid,
                    'progress' => $pillar3Valid ? 1.0 : 0.0,
                    'metric' => $externalCertsCount > 0 ? "{$externalCertsCount} Berkas Terverifikasi" : 'Unggah Dokumen',
                ],
            ],
            'checks' => $checks,
        ];
    }
}

