<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProjectDeliverable extends Model
{
    protected $fillable = [
        'project_id', 'milestone_id', 'student_id', 'submission_format',
        'deliverable_url', 'file_path', 'file_name', 'file_size_label',
        'submission_notes', 'attachment_links', 'revision_count',
        'revision_notes', 'recommend_mentor_consultation', 'status',
        'submitted_at', 'reviewed_at',
    ];

    protected function casts(): array
    {
        return [
            'attachment_links' => 'array',
            'recommend_mentor_consultation' => 'boolean',
            'submitted_at' => 'datetime',
            'reviewed_at' => 'datetime',
        ];
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }

    public function milestone(): BelongsTo
    {
        return $this->belongsTo(ProjectMilestone::class, 'milestone_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}

