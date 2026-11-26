<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureNotSuspended
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if ($user && $user->isSuspended()) {
            $reason = trim((string) ($user->suspended_reason ?? ''));

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
