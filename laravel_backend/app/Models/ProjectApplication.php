<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProjectApplication extends Model
{
    protected $fillable = [
        'project_id', 'student_id', 'cover_letter', 'portfolio_ids', 'portfolio_link',
        'has_mentor_endorsement_snapshot', 'timeline_commitment', 'dedication_hours',
        'status', 'rejection_feedback', 'reviewed_at', 'applied_at',
    ];

    protected function casts(): array
    {
        return [
            'portfolio_ids' => 'array',
            'has_mentor_endorsement_snapshot' => 'boolean',
            'reviewed_at' => 'datetime',
            'applied_at' => 'datetime',
        ];
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}

