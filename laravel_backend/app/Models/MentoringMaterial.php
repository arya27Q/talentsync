<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentoringMaterial extends Model
{
    protected $fillable = [
        'class_id', 'mentor_id', 'title', 'description', 'kind', 'meta_label', 'resource_url', 'is_new',
    ];

    protected function casts(): array
    {
        return ['is_new' => 'boolean'];
    }

    public function mentoringClass(): BelongsTo
    {
        return $this->belongsTo(MentoringClass::class, 'class_id');
    }

    public function mentor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'mentor_id');
    }
}

