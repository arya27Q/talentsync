<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EscrowDispute;
use App\Models\MentoringEnrollment;
use App\Models\Project;
use App\Services\NotificationDispatcher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DisputeController extends Controller
{
    public function __construct(private readonly NotificationDispatcher $notifications)
    {
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'reference_type' => ['required', Rule::in(['project', 'mentoring_enrollment', 'wallet'])],
            'reference_id' => ['required', 'integer', 'min:1'],
            'category' => ['required', 'string', 'max:80'],
            'description' => ['required', 'string', 'min:10', 'max:5000'],
        ]);

        $resolvedClass = match ($data['reference_type']) {
            'project' => Project::class,
            'mentoring_enrollment' => MentoringEnrollment::class,
            'wallet' => $request->user()::class,
        };

        $resolvedId = match ($data['reference_type']) {
            'project' => Project::findOrFail($data['reference_id'])->id,
            'mentoring_enrollment' => MentoringEnrollment::where('student_id', $request->user()->id)
                ->findOrFail($data['reference_id'])->id,
            'wallet' => $request->user()->id,
        };

        $dispute = EscrowDispute::create([
            'reporter_id' => $request->user()->id,
            'reference_type' => $resolvedClass,
            'reference_id' => $resolvedId,
            'category' => $data['category'],
            'description' => $data['description'],
            'status' => 'open',
        ]);

        $this->notifications->send(
            $request->user(),
            'dispute_created',
            'Laporan Kendala Diterima',
            'Tim resolusi TalentSync akan meninjau laporan Anda dalam 1x24 jam.',
            '/settings/help-support',
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Laporan kendala berhasil dikirim ke tim resolusi TalentSync.',
            'data' => [
                'id' => $dispute->id,
                'status' => $dispute->status,
                'created_at' => $dispute->created_at?->toIso8601String(),
            ],
        ], 201);
    }
}

