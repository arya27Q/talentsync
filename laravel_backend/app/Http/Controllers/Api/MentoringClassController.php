<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentoringClass;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MentoringClassController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $classes = MentoringClass::query()
            ->with('mentor:id,name')
            ->withCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])])
            ->where('mentor_id', $request->user()->id)
            ->orderByDesc('scheduled_time')
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $classes->getCollection()->map(fn (MentoringClass $class) => MentoringPresenter::mentoringClass($class, true)),
            'meta' => ['current_page' => $classes->currentPage(), 'last_page' => $classes->lastPage()],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'topic' => ['required', 'string', 'max:200'],
            'description' => ['nullable', 'string', 'max:10000'],
            'scheduled_time' => ['required', 'date', 'after:now'],
            'duration_minutes' => ['sometimes', 'integer', 'min:15', 'max:480'],
            'price_tc' => ['required', 'integer', 'min:1', 'max:100000'],
            'meeting_link' => ['nullable', 'url', 'max:2048'],
            'capacity' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);
        $data['mentor_id'] = $request->user()->id;
        $class = MentoringClass::create($data);
        $class->load('mentor:id,name', 'mentor.mentorProfile');

        return response()->json(['status' => 'success', 'message' => 'Kelas mentoring berhasil dibuat.', 'data' => MentoringPresenter::mentoringClass($class, true)], 201);
    }

    public function update(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless($mentoringClass->mentor_id === $request->user()->id, 403);
        $data = $request->validate([
            'topic' => ['sometimes', 'required', 'string', 'max:200'],
            'description' => ['sometimes', 'nullable', 'string', 'max:10000'],
            'scheduled_time' => ['sometimes', 'required', 'date', 'after:now'],
            'duration_minutes' => ['sometimes', 'integer', 'min:15', 'max:480'],
            'price_tc' => ['sometimes', 'required', 'integer', 'min:1', 'max:100000'],
            'meeting_link' => ['sometimes', 'nullable', 'url', 'max:2048'],
            'capacity' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'status' => ['sometimes', Rule::in(['open', 'completed', 'cancelled'])],
        ]);
        if (($data['status'] ?? null) === 'completed') {
            abort_unless($mentoringClass->scheduled_time->copy()->addMinutes($mentoringClass->duration_minutes)->isPast(), 409, 'Kelas hanya dapat diselesaikan setelah jadwalnya.');
        }
        if ($mentoringClass->enrollments()->exists()) {
            abort_if(array_diff(array_keys($data), ['status']) !== [], 409, 'Jadwal atau tarif tidak dapat diubah setelah ada pendaftar.');
            abort_unless(($data['status'] ?? null) === 'completed', 409, 'Kelas dengan pendaftar hanya dapat ditandai selesai.');
            abort_if($mentoringClass->enrollments()->whereIn('status', ['pending', 'accepted', 'attended', 'pending_confirmation'])->exists(), 409, 'Selesaikan seluruh booking sebelum menutup kelas.');
        }
        $mentoringClass->update($data);
        $mentoringClass->load('mentor:id,name', 'mentor.mentorProfile');

        return response()->json(['status' => 'success', 'message' => 'Kelas mentoring berhasil diperbarui.', 'data' => MentoringPresenter::mentoringClass($mentoringClass->fresh('mentor.mentorProfile'))]);
    }

    public function destroy(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        abort_unless($mentoringClass->mentor_id === $request->user()->id, 403);
        abort_if($mentoringClass->enrollments()->exists(), 409, 'Kelas yang memiliki riwayat pendaftar tidak dapat dihapus.');
        $mentoringClass->delete();

        return response()->json(['status' => 'success', 'message' => 'Kelas mentoring berhasil dihapus.']);
    }
}
