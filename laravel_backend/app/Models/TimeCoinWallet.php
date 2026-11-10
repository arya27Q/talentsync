<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TimeCoinWallet extends Model
{
    protected $fillable = ['user_id', 'balance', 'locked_balance'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
