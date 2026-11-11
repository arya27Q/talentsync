<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentorProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\File;

class MentorProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $profile = MentorProfile::firstOrCreate(
            ['user_id' => $request->user()->id],
            ['verification_status' => 'approved'],
        );

        return response()->json(['status' => 'success', 'data' => MentoringPresenter::mentorProfile($profile)]);
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title_headline' => ['sometimes', 'nullable', 'string', 'max:150'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'hourly_rate_tc' => ['sometimes', 'integer', 'min:1', 'max:100000'],
            'cv_file' => ['sometimes', File::types(['pdf'])->max(5 * 1024)],
            'verification_document_url' => ['sometimes', 'url', 'max:2048'],
            'portfolio_url' => ['sometimes', 'url', 'max:2048'],
        ]);
        $profile = MentorProfile::firstOrCreate(
            ['user_id' => $request->user()->id],
            ['verification_status' => 'approved'],
        );
        unset($data['cv_file']);

        if ($request->hasFile('cv_file')) {
            $cvPath = $request->file('cv_file')->store('mentor-cvs', 'public');
            $data['verification_document_url'] = Storage::disk('public')->url($cvPath);
        }

        if ($profile->verification_status !== 'approved') {
            $data['verification_status'] = 'approved';
            $data['verification_rejection_reason'] = null;
            $data['verification_reviewed_at'] = now();
        }

        $profile->fill($data)->save();

        return response()->json(['status' => 'success', 'message' => 'Profil mentor berhasil diperbarui.', 'data' => MentoringPresenter::mentorProfile($profile->fresh())]);
    }
}
