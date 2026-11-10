<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentoringEnrollment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MentoringMessageController extends Controller
{
    public function index(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $this->authorizeParticipant($request, $enrollment);

        return response()->json([
            'status' => 'success',
            'data' => $enrollment->messages()->with('sender:id,name')->oldest()->paginate(50),
        ]);
    }

    public function store(Request $request, MentoringEnrollment $enrollment): JsonResponse
    {
        $this->authorizeParticipant($request, $enrollment);
        abort_if(in_array($enrollment->status, ['declined', 'absent'], true), 409, 'Percakapan sudah ditutup.');
        $data = $request->validate([
            'message' => ['nullable', 'required_without:attachment_url', 'string', 'max:10000'],
            'attachment_url' => ['nullable', 'required_without:message', 'url', 'max:2048'],
        ]);
        $message = $enrollment->messages()->create([...$data, 'sender_id' => $request->user()->id])
            ->load('sender:id,name');

        return response()->json(['status' => 'success', 'data' => $message], 201);
    }

    private function authorizeParticipant(Request $request, MentoringEnrollment $enrollment): void
    {
        if ($request->user()->hasRole('mentor')) {
            abort_unless($request->user()->mentorProfile?->verification_status === 'approved', 403, 'Akun mentor belum terverifikasi.');
        }

        abort_unless(
            $enrollment->student_id === $request->user()->id
                || $enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(),
            403,
        );
    }
}
