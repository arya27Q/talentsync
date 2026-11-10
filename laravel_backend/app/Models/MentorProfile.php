<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MentorProfile extends Model
{
    protected $fillable = [
        'user_id', 'title_headline', 'bio', 'hourly_rate_tc', 'is_premium',
        'verification_status', 'verification_document_url', 'portfolio_url',
        'verification_rejection_reason', 'verification_reviewed_by', 'verification_reviewed_at',
        'premium_expires_at', 'rating_average',
    ];

    protected function casts(): array
    {
        return [
            'is_premium' => 'boolean',
            'premium_expires_at' => 'datetime',
            'verification_reviewed_at' => 'datetime',
            'rating_average' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
