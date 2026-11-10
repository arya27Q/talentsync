<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UmkmProfile extends Model
{
    protected $fillable = [
        'user_id', 'business_name', 'business_sector', 'address', 'business_document_url',
        'is_premium', 'monthly_quota_tc',
    ];

    protected function casts(): array
    {
        return ['is_premium' => 'boolean'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
