<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CashOutRequest extends Model
{
    protected $fillable = [
        'user_id', 'amount_tc', 'admin_fee_idr', 'disbursed_amount_idr',
        'bank_name', 'account_number', 'account_holder_name', 'status',
    ];

    protected function casts(): array
    {
        return [
            'account_number' => 'encrypted',
            'account_holder_name' => 'encrypted',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
