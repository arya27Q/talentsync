<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    public function handle(Request $request, Closure $next, string $roles): Response
    {
        $allowedRoles = explode('|', $roles);
        if (! $request->user() || ! in_array($request->user()->roleRecord?->name, $allowedRoles, true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Anda tidak memiliki kewenangan untuk mengakses tindakan ini.',
            ], 403);
        }

        if ($request->user()->isSuspended()) {
            $reason = trim((string) ($request->user()->suspended_reason ?? ''));

            return response()->json([
                'status' => 'error',
                'message' => $reason !== ''
                    ? "Akun Anda sedang dibekukan oleh Admin TalentSync. Alasan: {$reason}"
                    : 'Akun Anda sedang dibekukan oleh Admin TalentSync.',
            ], 403);
        }

        return $next($request);
    }
}
