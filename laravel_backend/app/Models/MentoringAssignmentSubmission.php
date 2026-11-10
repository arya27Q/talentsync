<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentoringAssignmentSubmission extends Model
{
    protected $fillable = [
        'assignment_id', 'student_id', 'submission_notes', 'deliverable_url', 'score', 'feedback', 'status',
    ];

    public function assignment(): BelongsTo
    {
        return $this->belongsTo(MentoringAssignment::class, 'assignment_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
