<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentorPremiumSubscription;
use App\Models\MentorProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class AdminMentorPremiumController extends Controller
{
    public function pending(): JsonResponse
    {
        $subscriptions = MentorPremiumSubscription::with('mentor:id,name,email')
            ->where('payment_status', 'pending')
            ->latest()
            ->paginate(20);

        return response()->json(['status' => 'success', 'data' => $subscriptions]);
    }

    public function resolve(Request $request, MentorPremiumSubscription $subscription): JsonResponse
    {
        $data = $request->validate(['payment_status' => ['required', Rule::in(['paid', 'failed'])]]);
        $result = DB::transaction(function () use ($request, $subscription, $data) {
            $record = MentorPremiumSubscription::query()->lockForUpdate()->findOrFail($subscription->id);
            abort_unless($record->payment_status === 'pending', 409, 'Pengajuan ini sudah diproses.');
            $record->update([
                'payment_status' => $data['payment_status'],
                'processed_by' => $request->user()->id,
                'starts_at' => $data['payment_status'] === 'paid' ? now() : null,
                'expires_at' => $data['payment_status'] === 'paid' ? now()->addMonthNoOverflow() : null,
            ]);

            if ($data['payment_status'] === 'paid') {
                MentorProfile::where('user_id', $record->mentor_id)->update([
                    'is_premium' => true,
                    'premium_expires_at' => $record->expires_at,
                ]);
            }

            return $record->fresh();
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Status pembayaran Premium diperbarui.', 'data' => [
            'id' => $result->id,
            'payment_status' => $result->payment_status,
            'expires_at' => $result->expires_at,
        ]]);
    }
}
