<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentProfile extends Model
{
    protected $fillable = [
        'user_id', 'university', 'major', 'student_id_number', 'ktm_document_url',
        'is_mentor_eligible', 'completed_projects_count',
    ];

    protected function casts(): array
    {
        return ['is_mentor_eligible' => 'boolean'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
