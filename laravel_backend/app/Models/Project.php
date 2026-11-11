<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Project extends Model
{
    protected $fillable = [
        'msme_id', 'code', 'title', 'division', 'category', 'description',
        'deliverables_checklist', 'reward_tc', 'deadline', 'duration_label',
        'work_mode', 'location_label', 'skills', 'benefit_badge',
        'requires_endorsement', 'atmosphere_photo_url', 'atmosphere_caption', 'status',
    ];

    protected function casts(): array
    {
        return [
            'deliverables_checklist' => 'array',
            'skills' => 'array',
            'deadline' => 'date',
            'requires_endorsement' => 'boolean',
        ];
    }

    public function msme(): BelongsTo
    {
        return $this->belongsTo(User::class, 'msme_id');
    }

    public function milestones(): HasMany
    {
        return $this->hasMany(ProjectMilestone::class)->orderBy('step_order');
    }

    public function applications(): HasMany
    {
        return $this->hasMany(ProjectApplication::class);
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(ProjectTask::class)->orderBy('sort_order')->orderBy('id');
    }

    public function deliverables(): HasMany
    {
        return $this->hasMany(ProjectDeliverable::class)->latest('submitted_at');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(ProjectMessage::class);
    }

    public function bookmarks(): HasMany
    {
        return $this->hasMany(ProjectBookmark::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }
}

