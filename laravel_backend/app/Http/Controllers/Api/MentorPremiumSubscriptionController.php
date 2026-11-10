<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentorPremiumSubscription;
use App\Models\MentorProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MentorPremiumSubscriptionController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $subscription = DB::transaction(function () use ($request) {
            $profile = MentorProfile::where('user_id', $request->user()->id)->lockForUpdate()->firstOrFail();
            abort_if(MentoringPresenter::isPremium($profile), 409, 'Paket Premium mentor masih aktif.');
            abort_if(MentorPremiumSubscription::where('mentor_id', $request->user()->id)->where('payment_status', 'pending')->exists(), 409, 'Sudah ada pengajuan Premium yang menunggu pembayaran.');

            return MentorPremiumSubscription::create([
                'mentor_id' => $request->user()->id,
                'amount_idr' => 50000,
                'payment_status' => 'pending',
                'payment_reference' => 'TS-MP-'.Str::upper(Str::random(12)),
            ]);
        }, 3);

        return response()->json([
            'status' => 'success',
            'message' => 'Pengajuan Premium dibuat dan menunggu verifikasi pembayaran admin.',
            'data' => [
                'id' => $subscription->id,
                'amount_idr' => $subscription->amount_idr,
                'payment_status' => $subscription->payment_status,
                'payment_reference' => $subscription->payment_reference,
            ],
        ], 201);
    }

    public function index(Request $request): JsonResponse
    {
        $subscriptions = MentorPremiumSubscription::where('mentor_id', $request->user()->id)
            ->latest()
            ->paginate(10);

        return response()->json(['status' => 'success', 'data' => $subscriptions]);
    }
}
