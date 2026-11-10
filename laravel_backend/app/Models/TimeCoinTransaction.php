<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TimeCoinTransaction extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'wallet_id', 'sender_id', 'recipient_id', 'transaction_type', 'direction',
        'ledger_account', 'amount', 'reference_type', 'reference_id', 'status', 'created_at',
    ];

    protected function casts(): array
    {
        return ['created_at' => 'datetime'];
    }

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(TimeCoinWallet::class, 'wallet_id');
    }
}
