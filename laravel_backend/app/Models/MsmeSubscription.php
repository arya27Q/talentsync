<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MsmeSubscription extends Model
{
    protected $fillable = [
        'user_id',
        'plan_type',
        'price_idr',
        'payment_channel',
        'payment_reference',
        'status',
        'starts_at',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'starts_at' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
