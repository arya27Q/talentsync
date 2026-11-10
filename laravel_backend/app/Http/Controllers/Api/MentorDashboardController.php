<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\TimeCoinWallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MentorDashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $mentorId = $request->user()->id;
        $classIds = MentoringClass::query()->where('mentor_id', $mentorId)->select('id');
        $balance = TimeCoinWallet::where('user_id', $mentorId)->value('balance') ?? 0;

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => $balance,
                'estimated_idr' => $balance * 1000,
                'new_bookings' => MentoringEnrollment::whereIn('class_id', $classIds)->where('status', 'pending')->count(),
                'scheduled_bookings' => MentoringEnrollment::whereIn('class_id', $classIds)->where('status', 'accepted')->count(),
                'needs_review' => MentoringEnrollment::whereIn('class_id', $classIds)->where('status', 'attended')->count(),
                'endorsement_requests' => MentoringEnrollment::whereIn('class_id', $classIds)
                    ->where('status', 'completed')
                    ->where('assessment_score', '>=', 80)
                    ->where('has_endorsement', false)
                    ->count(),
            ],
        ]);
    }
}
