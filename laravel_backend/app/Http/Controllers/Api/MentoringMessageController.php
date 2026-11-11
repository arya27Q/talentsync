<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MentoringEnrollment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\File;

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
            'message' => ['nullable', 'required_without_all:attachment_url,attachment_file', 'string', 'max:10000'],
            'attachment_url' => ['nullable', 'required_without_all:message,attachment_file', 'url', 'max:2048'],
            'attachment_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png', 'webp', 'pdf', 'zip'])->max(5 * 1024)],
        ]);

        $attachmentUrl = $data['attachment_url'] ?? null;
        $storedPath = null;
        if ($request->hasFile('attachment_file')) {
            $storedPath = $request->file('attachment_file')->store('mentoring-chat', 'public');
            $attachmentUrl = Storage::disk('public')->url($storedPath);
        }

        try {
            $message = $enrollment->messages()->create([
                'message' => $data['message'] ?? null,
                'attachment_url' => $attachmentUrl,
                'sender_id' => $request->user()->id,
            ])->load('sender:id,name');
        } catch (\Throwable $e) {
            if ($storedPath !== null) {
                Storage::disk('public')->delete($storedPath);
            }
            throw $e;
        }

        return response()->json(['status' => 'success', 'data' => $message], 201);
    }

    private function authorizeParticipant(Request $request, MentoringEnrollment $enrollment): void
    {
        abort_unless(
            $enrollment->student_id === $request->user()->id
                || $enrollment->mentoringClass()->where('mentor_id', $request->user()->id)->exists(),
            403,
        );
    }
}
