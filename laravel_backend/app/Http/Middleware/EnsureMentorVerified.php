<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureMentorVerified
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->mentorProfile?->verification_status !== 'approved') {
            return response()->json([
                'status' => 'error',
                'message' => 'Akun mentor menunggu verifikasi sebelum dapat membuka kelas.',
            ], 403);
        }

        return $next($request);
    }
}
