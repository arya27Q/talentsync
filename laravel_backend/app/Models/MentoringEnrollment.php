<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MentoringEnrollment extends Model
{
    protected $fillable = [
        'class_id', 'student_id', 'paid_tc', 'topic_focus', 'student_notes', 'materials_url',
        'status', 'has_endorsement', 'endorsement_notes',
        'assessment_score', 'mentor_feedback', 'rubric_scores', 'evaluated_at', 'student_confirmed_at',
    ];

    protected function casts(): array
    {
        return [
            'has_endorsement' => 'boolean',
            'rubric_scores' => 'array',
            'evaluated_at' => 'datetime',
            'student_confirmed_at' => 'datetime',
        ];
    }

    public function mentoringClass(): BelongsTo
    {
        return $this->belongsTo(MentoringClass::class, 'class_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(MentoringMessage::class, 'enrollment_id');
    }

    public function actionItems(): HasMany
    {
        return $this->hasMany(MentoringActionItem::class, 'enrollment_id')->orderBy('id');
    }
}
