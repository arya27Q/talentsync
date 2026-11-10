<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentorProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminMentorVerificationController extends Controller
{
    public function pending(): JsonResponse
    {
        $mentors = User::query()
            ->whereHas('roleRecord', fn ($query) => $query->where('name', 'mentor'))
            ->whereHas('mentorProfile', fn ($query) => $query->where('verification_status', 'pending'))
            ->with('mentorProfile:user_id,title_headline,bio,verification_document_url,portfolio_url,verification_status')
            ->orderBy('id')
            ->paginate(20);

        return response()->json([
            'status' => 'success',
            'data' => $mentors->getCollection()->map(fn (User $mentor) => [
                'id' => $mentor->id,
                'name' => $mentor->name,
                'email' => $mentor->email,
                'profile' => [
                    'title_headline' => $mentor->mentorProfile->title_headline,
                    'bio' => $mentor->mentorProfile->bio,
                    'verification_document_url' => $mentor->mentorProfile->verification_document_url,
                    'portfolio_url' => $mentor->mentorProfile->portfolio_url,
                ],
            ]),
            'meta' => ['current_page' => $mentors->currentPage(), 'last_page' => $mentors->lastPage()],
        ]);
    }

    public function review(Request $request, User $mentor): JsonResponse
    {
        abort_unless($mentor->hasRole('mentor'), 404);
        $data = $request->validate([
            'verification_status' => ['required', Rule::in(['approved', 'rejected'])],
            'rejection_reason' => ['required_if:verification_status,rejected', 'nullable', 'string', 'max:2000'],
        ]);
        $profile = MentorProfile::where('user_id', $mentor->id)->firstOrFail();
        $profile->update([
            'verification_status' => $data['verification_status'],
            'verification_rejection_reason' => $data['verification_status'] === 'rejected' ? $data['rejection_reason'] : null,
            'verification_reviewed_by' => $request->user()->id,
            'verification_reviewed_at' => now(),
        ]);

        return response()->json(['status' => 'success', 'message' => 'Status verifikasi mentor diperbarui.', 'data' => [
            'mentor_id' => $mentor->id,
            'verification_status' => $profile->verification_status,
        ]]);
    }
}
