<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WalletTopUp extends Model
{
    protected $fillable = [
        'user_id', 'amount_tc', 'amount_idr', 'payment_channel', 'payment_reference', 'status',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

