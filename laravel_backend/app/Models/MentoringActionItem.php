<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentoringActionItem extends Model
{
    protected $fillable = [
        'enrollment_id', 'title', 'tag', 'detail', 'is_completed', 'completed_at',
    ];

    protected function casts(): array
    {
        return ['is_completed' => 'boolean', 'completed_at' => 'datetime'];
    }

    public function enrollment(): BelongsTo
    {
        return $this->belongsTo(MentoringEnrollment::class, 'enrollment_id');
    }
}

