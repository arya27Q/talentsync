<?php

namespace App\Http\Resources;

use App\Models\Portfolio;
use App\Models\StudentCertificate;
use App\Models\StudentProfile;
use App\Models\StudentSkill;
use App\Models\User;

final class StudentPresenter
{
    public static function profile(User $user, int $balanceTc = 0, ?bool $hasEndorsement = null): array
    {
        $profile = $user->relationLoaded('studentProfile') ? $user->studentProfile : $user->studentProfile()->first();
        $skills = $user->relationLoaded('studentSkills') ? $user->studentSkills : $user->studentSkills()->get();
        $roles = $user->relationLoaded('roles') ? $user->roles->pluck('name')->values()->all() : [];
        if ($user->roleRecord?->name && ! in_array($user->roleRecord->name, $roles, true)) {
            $roles[] = $user->roleRecord->name;
        }

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->roleRecord?->name ?? 'student',
            'roles' => $roles,
            'balance_tc' => $balanceTc,
            'avatar_url' => $profile?->avatar_url,
            'university' => $profile?->university,
            'major' => $profile?->major,
            'student_id_number' => $profile?->student_id_number,
            'ktm_document_url' => $profile?->ktm_document_url,
            'ktm_verification_status' => $profile?->ktm_verification_status ?? 'approved',
            'headline' => $profile?->headline ?? 'Mahasiswa Talenta Digital',
            'bio' => $profile?->bio,
            'cohort_year' => $profile?->cohort_year,
            'semester' => $profile?->semester,
            'linkedin_url' => $profile?->linkedin_url,
            'github_username' => $profile?->github_username,
            'github_integration' => [
                'connected' => ! empty($profile?->github_username),
                'username' => $profile?->github_username,
                'repos_count' => (int) ($profile?->github_repos_count ?? 0),
                'commits_count' => (int) ($profile?->github_commits_count ?? 0),
                'pinned_count' => (int) ($profile?->github_pinned_count ?? 0),
                'languages' => $profile?->github_languages ?? [],
                'last_synced_at' => $profile?->github_last_synced_at?->toIso8601String(),
            ],
            'is_public_profile' => (bool) ($profile?->is_public_profile ?? true),
            'is_open_for_projects' => (bool) ($profile?->is_open_for_projects ?? true),
            'two_factor_enabled' => (bool) ($profile?->two_factor_enabled ?? false),
            'show_online_status' => (bool) ($profile?->show_online_status ?? true),
            'show_endorse_badge' => (bool) ($profile?->show_endorse_badge ?? true),
            'has_transaction_pin' => ! empty($profile?->transaction_pin_hash),
            'pin_updated_at' => $profile?->pin_updated_at?->toIso8601String(),
            'is_mentor_eligible' => (bool) ($profile?->is_mentor_eligible ?? false),
            'completed_projects_count' => (int) ($profile?->completed_projects_count ?? 0),
            'total_contribution_hours' => (int) ($profile?->total_contribution_hours ?? 0),
            'rating_average' => (float) ($profile?->rating_average ?? 0),
            'has_mentor_endorsement' => $hasEndorsement ?? $user->mentoringEnrollments()->where('has_endorsement', true)->exists(),
            'skills' => $skills->map(fn (StudentSkill $s) => self::skill($s))->values(),
        ];
    }

    public static function skill(StudentSkill $skill): array
    {
        return [
            'id' => $skill->id,
            'name' => $skill->name,
            'proficiency_level' => $skill->proficiency_level,
            'score' => $skill->score,
            'is_verified' => (bool) $skill->is_verified,
            'verified_source' => $skill->verified_source,
            'verified_at' => $skill->verified_at?->toIso8601String(),
        ];
    }

    public static function portfolio(Portfolio $portfolio): array
    {
        return [
            'id' => $portfolio->id,
            'project_id' => $portfolio->project_id,
            'title' => $portfolio->title,
            'category' => $portfolio->category,
            'client_name' => $portfolio->client_name,
            'role_title' => $portfolio->role_title,
            'duration_label' => $portfolio->duration_label,
            'reward_tc' => $portfolio->reward_tc,
            'rating' => (float) $portfolio->rating,
            'tags' => $portfolio->tags ?? [],
            'problem_summary' => $portfolio->problem_summary,
            'solution_summary' => $portfolio->solution_summary,
            'result_summary' => $portfolio->result_summary,
            'deliverable_highlights' => $portfolio->deliverable_highlights ?? [],
            'testimonial_quote' => $portfolio->testimonial_quote,
            'testimonial_author' => $portfolio->testimonial_author,
            'preview_image_url' => $portfolio->preview_image_url,
            'case_study_url' => $portfolio->case_study_url,
            'is_verified' => (bool) $portfolio->is_verified,
            'is_featured' => (bool) $portfolio->is_featured,
        ];
    }

    public static function certificate(StudentCertificate $certificate): array
    {
        return [
            'id' => $certificate->id,
            'source_type' => $certificate->source_type,
            'certificate_code' => $certificate->certificate_code,
            'title' => $certificate->title,
            'issuer_name' => $certificate->issuer_name,
            'category_label' => $certificate->category_label,
            'file_url' => $certificate->file_url,
            'reference_type' => $certificate->reference_type,
            'reference_id' => $certificate->reference_id,
            'issued_at' => $certificate->issued_at?->toIso8601String(),
        ];
    }
}

