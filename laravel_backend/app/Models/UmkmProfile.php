<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UmkmProfile extends Model
{
    protected $fillable = [
        'user_id', 'business_name', 'business_sector', 'logo_url', 'address', 'district', 'city',
        'business_document_url', 'is_premium', 'is_verified', 'monthly_quota_tc',
    ];

    protected function casts(): array
    {
        return [
            'is_premium' => 'boolean',
            'is_verified' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
