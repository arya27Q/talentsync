<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MentoringAssignment extends Model
{
    protected $fillable = ['class_id', 'mentor_id', 'title', 'description', 'due_at'];

    protected function casts(): array
    {
        return ['due_at' => 'datetime'];
    }

    public function mentoringClass(): BelongsTo
    {
        return $this->belongsTo(MentoringClass::class, 'class_id');
    }

    public function submissions(): HasMany
    {
        return $this->hasMany(MentoringAssignmentSubmission::class, 'assignment_id');
    }
}
