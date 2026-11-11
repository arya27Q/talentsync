<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentSkill extends Model
{
    protected $fillable = [
        'student_id', 'name', 'proficiency_level', 'score', 'is_verified', 'verified_source', 'verified_at',
    ];

    protected function casts(): array
    {
        return ['is_verified' => 'boolean', 'verified_at' => 'datetime'];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}

