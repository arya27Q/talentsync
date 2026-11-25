<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MsmeVoucherBarter extends Model
{
    protected $fillable = [
        'user_id',
        'reward_id',
        'voucher_type',
        'title',
        'quantity',
        'value_idr',
        'tc_per_voucher',
        'total_tc',
        'validity_days',
        'expires_at',
        'design_image_url',
        'is_guaranteed',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'is_guaranteed' => 'boolean',
            'expires_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function reward(): BelongsTo
    {
        return $this->belongsTo(Reward::class);
    }
}
