<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Portfolio extends Model
{
    protected $fillable = [
        'student_id', 'project_id', 'title', 'category', 'client_name', 'role_title',
        'duration_label', 'reward_tc', 'rating', 'tags', 'problem_summary',
        'solution_summary', 'result_summary', 'deliverable_highlights',
        'testimonial_quote', 'testimonial_author', 'preview_image_url',
        'case_study_url', 'is_verified', 'is_featured',
    ];

    protected function casts(): array
    {
        return [
            'tags' => 'array',
            'deliverable_highlights' => 'array',
            'rating' => 'decimal:2',
            'is_verified' => 'boolean',
            'is_featured' => 'boolean',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }
}

