<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentorProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MentorProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $profile = MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);

        return response()->json(['status' => 'success', 'data' => MentoringPresenter::mentorProfile($profile)]);
    }

    public function verificationStatus(Request $request): JsonResponse
    {
        $profile = MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);

        return response()->json(['status' => 'success', 'data' => [
            'verification_status' => $profile->verification_status,
            'rejection_reason' => $profile->verification_rejection_reason,
        ]]);
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title_headline' => ['sometimes', 'nullable', 'string', 'max:150'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'hourly_rate_tc' => ['sometimes', 'integer', 'min:1', 'max:100000'],
            'verification_document_url' => ['sometimes', 'url', 'max:2048'],
            'portfolio_url' => ['sometimes', 'url', 'max:2048'],
        ]);
        $profile = MentorProfile::firstOrCreate(['user_id' => $request->user()->id]);

        if (array_key_exists('verification_document_url', $data) || array_key_exists('portfolio_url', $data)) {
            $data['verification_status'] = 'pending';
            $data['verification_rejection_reason'] = null;
            $data['verification_reviewed_by'] = null;
            $data['verification_reviewed_at'] = null;
        }

        $profile->fill($data)->save();

        return response()->json(['status' => 'success', 'message' => 'Profil mentor berhasil diperbarui.', 'data' => MentoringPresenter::mentorProfile($profile->fresh())]);
    }

}
