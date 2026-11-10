<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentorPremiumSubscription extends Model
{
    protected $fillable = [
        'mentor_id', 'amount_idr', 'payment_status', 'payment_reference',
        'starts_at', 'expires_at', 'processed_by',
    ];

    protected function casts(): array
    {
        return ['starts_at' => 'datetime', 'expires_at' => 'datetime'];
    }

    public function mentor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'mentor_id');
    }

    public function processor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'processed_by');
    }
}
