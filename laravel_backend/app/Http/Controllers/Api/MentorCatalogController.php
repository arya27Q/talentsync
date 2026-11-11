<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentoringClass;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MentorCatalogController extends Controller
{
    public function mentors(Request $request): JsonResponse
    {
        $mentors = User::query()
            ->whereHas('roleRecord', fn ($query) => $query->where('name', 'mentor'))
            ->with('mentorProfile')
            ->when($request->filled('search'), fn ($query) => $query->where(function ($query) use ($request) {
                $term = '%'.$request->string('search')->trim().'%';
                $query->where('name', 'like', $term)
                    ->orWhereHas('mentorProfile', fn ($profile) => $profile
                        ->where('title_headline', 'like', $term)
                        ->orWhere('bio', 'like', $term));
            }))
            ->orderBy('name')
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $mentors->getCollection()->map(fn (User $mentor) => [
                'id' => $mentor->id,
                'name' => $mentor->name,
                'title_headline' => $mentor->mentorProfile?->title_headline,
                'bio' => $mentor->mentorProfile?->bio,
                'hourly_rate_tc' => $mentor->mentorProfile?->hourly_rate_tc,
                'rating' => (float) ($mentor->mentorProfile?->rating_average ?? 0),
                'is_premium' => MentoringPresenter::isPremium($mentor->mentorProfile),
            ]),
            'meta' => [
                'current_page' => $mentors->currentPage(),
                'last_page' => $mentors->lastPage(),
                'per_page' => $mentors->perPage(),
                'total' => $mentors->total(),
            ],
        ]);
    }

    public function classes(Request $request): JsonResponse
    {
        $classes = MentoringClass::query()
            ->with(['mentor:id,name'])
            ->withCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])])
            ->where('status', 'open')
            ->where('scheduled_time', '>=', now())
            ->whereHas('mentor.roleRecord', fn ($query) => $query->where('name', 'mentor'))
            ->whereRaw('(select count(*) from mentoring_enrollments where mentoring_enrollments.class_id = mentoring_classes.id and mentoring_enrollments.status not in (?, ?)) < mentoring_classes.capacity', ['absent', 'declined'])
            ->when($request->filled('mentor_id'), fn ($query) => $query->where('mentor_id', $request->integer('mentor_id')))
            ->when($request->filled('topic'), fn ($query) => $query->where('topic', 'like', '%'.$request->string('topic')->trim().'%'))
            ->orderBy('scheduled_time')
            ->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $classes->getCollection()->map(fn (MentoringClass $class) => MentoringPresenter::mentoringClass($class)),
            'meta' => ['current_page' => $classes->currentPage(), 'last_page' => $classes->lastPage()],
        ]);
    }

    public function showClass(MentoringClass $mentoringClass): JsonResponse
    {
        $mentoringClass->load('mentor:id,name,role_id');
        abort_unless($mentoringClass->mentor?->hasRole('mentor') ?? false, 404);
        $mentoringClass->loadCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])]);

        return response()->json(['status' => 'success', 'data' => MentoringPresenter::mentoringClass($mentoringClass)]);
    }
}
