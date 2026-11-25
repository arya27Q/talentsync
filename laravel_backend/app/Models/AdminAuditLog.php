<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Http\Request;

class AdminAuditLog extends Model
{
    protected $fillable = [
        'admin_id',
        'action',
        'target_type',
        'target_id',
        'target_label',
        'details',
        'ip_address',
        'user_agent',
    ];

    public function admin(): BelongsTo
    {
        return $this->belongsTo(User::class, 'admin_id');
    }

    public static function record(
        Request $request,
        string $action,
        ?string $targetType = null,
        ?int $targetId = null,
        ?string $targetLabel = null,
        ?string $details = null,
    ): ?self {
        $admin = $request->user();
        if (! $admin) {
            return null;
        }

        return self::create([
            'admin_id' => $admin->id,
            'action' => $action,
            'target_type' => $targetType,
            'target_id' => $targetId,
            'target_label' => $targetLabel ? mb_substr($targetLabel, 0, 255) : null,
            'details' => $details,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent() ? mb_substr((string) $request->userAgent(), 0, 255) : null,
        ]);
    }
}
