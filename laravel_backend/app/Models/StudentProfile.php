<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentProfile extends Model
{
    protected $fillable = [
        'user_id',
        'university',
        'major',
        'student_id_number',
        'ktm_document_url',
        'ktm_verification_status',
        'avatar_url',
        'headline',
        'bio',
        'cohort_year',
        'semester',
        'linkedin_url',
        'github_username',
        'github_connected_at',
        'github_repos_count',
        'github_commits_count',
        'github_pinned_count',
        'github_languages',
        'github_last_synced_at',
        'is_public_profile',
        'is_open_for_projects',
        'two_factor_enabled',
        'show_online_status',
        'show_endorse_badge',
        'transaction_pin_hash',
        'pin_updated_at',
        'is_mentor_eligible',
        'completed_projects_count',
        'total_contribution_hours',
        'rating_average',
    ];

    protected $hidden = [
        'transaction_pin_hash',
    ];

    protected function casts(): array
    {
        return [
            'is_mentor_eligible' => 'boolean',
            'is_public_profile' => 'boolean',
            'is_open_for_projects' => 'boolean',
            'two_factor_enabled' => 'boolean',
            'show_online_status' => 'boolean',
            'show_endorse_badge' => 'boolean',
            'github_languages' => 'array',
            'github_connected_at' => 'datetime',
            'github_last_synced_at' => 'datetime',
            'pin_updated_at' => 'datetime',
            'rating_average' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
