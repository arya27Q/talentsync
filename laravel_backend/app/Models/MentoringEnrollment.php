<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentoringEnrollment extends Model
{
    protected $fillable = [
        'class_id', 'student_id', 'paid_tc', 'status', 'has_endorsement', 'endorsement_notes',
        'assessment_score', 'mentor_feedback', 'student_confirmed_at',
    ];

    protected function casts(): array
    {
        return ['has_endorsement' => 'boolean', 'student_confirmed_at' => 'datetime'];
    }

    public function mentoringClass(): BelongsTo
    {
        return $this->belongsTo(MentoringClass::class, 'class_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function messages()
    {
        return $this->hasMany(MentoringMessage::class, 'enrollment_id');
    }

}
