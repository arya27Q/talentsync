<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentoringMessage extends Model
{
    protected $fillable = ['enrollment_id', 'sender_id', 'message', 'attachment_url'];

    public function enrollment(): BelongsTo
    {
        return $this->belongsTo(MentoringEnrollment::class, 'enrollment_id');
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }
}
