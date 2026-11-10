<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MentoringClass extends Model
{
    protected $fillable = [
        'mentor_id', 'topic', 'description', 'scheduled_time', 'duration_minutes',
        'price_tc', 'meeting_link', 'capacity', 'status',
    ];

    protected function casts(): array
    {
        return ['scheduled_time' => 'datetime'];
    }

    public function mentor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'mentor_id');
    }

    public function enrollments(): HasMany
    {
        return $this->hasMany(MentoringEnrollment::class, 'class_id');
    }

    public function assignments(): HasMany
    {
        return $this->hasMany(MentoringAssignment::class, 'class_id');
    }
}
