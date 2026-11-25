<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MentoringClass extends Model
{
    protected $fillable = [
        'mentor_id', 'topic', 'description', 'scheduled_time', 'duration_minutes',
        'duration_label', 'duration_days', 'price_tc', 'meeting_link', 'capacity', 'status',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_time' => 'datetime',
            'duration_minutes' => 'integer',
            'duration_days' => 'integer',
        ];
    }

    public function effectiveDurationLabel(): string
    {
        $label = trim((string) ($this->duration_label ?? ''));
        if ($label !== '') {
            return $label;
        }
        if (($this->duration_days ?? 0) >= 2) {
            return "{$this->duration_days} Hari";
        }

        return ($this->duration_minutes ?? 60).' menit';
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

    public function materials(): HasMany
    {
        return $this->hasMany(MentoringMaterial::class, 'class_id')->latest();
    }
}
