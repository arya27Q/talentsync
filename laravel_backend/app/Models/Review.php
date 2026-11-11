<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Review extends Model
{
    protected $fillable = [
        'reviewer_id', 'reviewee_id', 'mentoring_class_id', 'project_id',
        'rating', 'review_text', 'strength_tags',
    ];

    protected function casts(): array
    {
        return ['strength_tags' => 'array'];
    }

    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewer_id');
    }

    public function reviewee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewee_id');
    }

    public function mentoringClass(): BelongsTo
    {
        return $this->belongsTo(MentoringClass::class, 'mentoring_class_id');
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class, 'project_id');
    }
}
