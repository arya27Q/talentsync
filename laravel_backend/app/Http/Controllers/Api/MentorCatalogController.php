<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\MentorBookmark;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MentorCatalogController extends Controller
{
    public function mentors(Request $request): JsonResponse
    {
        $studentId = $request->user()->id;
        $search = mb_strtolower(trim((string) $request->query('search', '')));
        $category = mb_strtolower(trim((string) $request->query('category', '')));
        $sort = trim((string) $request->query('sort', 'rating_desc'));

        $query = User::query()
            ->whereHas('roleRecord', fn ($q) => $q->where('name', 'mentor'))
            ->orWhereHas('roles', fn ($q) => $q->where('name', 'mentor'))
            ->with('mentorProfile')
            ->when($search !== '', function ($q) use ($search) {
                $like = '%'.$search.'%';
                $q->where(function ($inner) use ($like) {
                    $inner->whereRaw('LOWER(name) LIKE ?', [$like])
                        ->orWhereHas('mentorProfile', fn ($profile) => $profile
                            ->whereRaw('LOWER(COALESCE(title_headline, "")) LIKE ?', [$like])
                            ->orWhereRaw('LOWER(COALESCE(bio, "")) LIKE ?', [$like]));
                });
            })
            ->when($category !== '' && $category !== 'semua', function ($q) use ($category) {
                $like = '%'.$category.'%';
                $q->where(function ($inner) use ($like) {
                    $inner->whereHas('mentorProfile', fn ($profile) => $profile
                        ->whereRaw('LOWER(COALESCE(title_headline, "")) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(COALESCE(bio, "")) LIKE ?', [$like]))
                        ->orWhereHas('mentoringClasses', fn ($c) => $c
                            ->where('status', 'open')
                            ->whereRaw('LOWER(topic) LIKE ?', [$like]));
                });
            });

        if ($sort === 'lowest_price') {
            $query->leftJoin('mentor_profiles as mp_sort', 'mp_sort.user_id', '=', 'users.id')
                ->orderByRaw('COALESCE(mp_sort.hourly_rate_tc, 999999) asc')
                ->select('users.*');
        } else {
            $query->leftJoin('mentor_profiles as mp_sort', 'mp_sort.user_id', '=', 'users.id')
                ->orderByDesc('mp_sort.rating_average')
                ->orderBy('users.name')
                ->select('users.*');
        }

        $mentors = $query->paginate(min((int) $request->integer('per_page', 15), 50));
        $bookmarkedIds = MentorBookmark::where('student_id', $studentId)->pluck('mentor_id')->all();

        $mentorIds = $mentors->getCollection()->pluck('id')->all();
        $openClassesByMentor = MentoringClass::query()
            ->whereIn('mentor_id', $mentorIds)
            ->where('status', 'open')
            ->where('scheduled_time', '>=', now())
            ->withCount(['enrollments as enrolled_count' => fn ($q) => $q->whereNotIn('status', ['absent', 'declined'])])
            ->orderBy('scheduled_time')
            ->get()
            ->groupBy('mentor_id');

        $reviewsCountByMentor = Review::query()
            ->whereIn('reviewee_id', $mentorIds)
            ->whereNotNull('mentoring_class_id')
            ->selectRaw('reviewee_id, count(*) as total')
            ->groupBy('reviewee_id')
            ->pluck('total', 'reviewee_id');

        $sessionsCountByMentor = MentoringEnrollment::query()
            ->join('mentoring_classes', 'mentoring_classes.id', '=', 'mentoring_enrollments.class_id')
            ->whereIn('mentoring_classes.mentor_id', $mentorIds)
            ->whereIn('mentoring_enrollments.status', ['attended', 'pending_confirmation', 'completed'])
            ->selectRaw('mentoring_classes.mentor_id, count(*) as total')
            ->groupBy('mentoring_classes.mentor_id')
            ->pluck('total', 'mentor_id');

        return response()->json([
            'status' => 'success',
            'data' => $mentors->getCollection()->map(function (User $mentor) use (
                $bookmarkedIds,
                $openClassesByMentor,
                $reviewsCountByMentor,
                $sessionsCountByMentor,
            ) {
                $nearestClass = optional($openClassesByMentor->get($mentor->id))->first();
                $rating = (float) ($mentor->mentorProfile?->rating_average ?? 0);
                $isPremium = MentoringPresenter::isPremium($mentor->mentorProfile);

                return [
                    'id' => $mentor->id,
                    'name' => $mentor->name,
                    'avatar_url' => $mentor->mentorProfile?->avatar_url,
                    'title_headline' => $mentor->mentorProfile?->title_headline,
                    'bio' => $mentor->mentorProfile?->bio,
                    'focus_summary' => $mentor->mentorProfile?->bio,
                    'hourly_rate_tc' => $mentor->mentorProfile?->hourly_rate_tc ?? 30,
                    'rating' => $rating,
                    'reviews_count' => (int) ($reviewsCountByMentor[$mentor->id] ?? 0),
                    'sessions_count' => (int) ($sessionsCountByMentor[$mentor->id] ?? 0),
                    'portfolio_pass_rate' => 96,
                    'is_verified' => ($mentor->mentorProfile?->verification_status ?? 'approved') === 'approved',
                    'is_premium' => $isPremium,
                    'is_bookmarked' => in_array($mentor->id, $bookmarkedIds, true),
                    'tags' => array_values(array_filter([
                        $rating >= 4.5 ? 'Top Mentor' : 'Peer Mentor',
                        $isPremium ? 'Mentor Unggulan' : 'Fast feedback < 24 jam',
                    ])),
                    'nearest_class' => $nearestClass ? [
                        'id' => $nearestClass->id,
                        'topic' => $nearestClass->topic,
                        'scheduled_time' => $nearestClass->scheduled_time?->toIso8601String(),
                        'duration_minutes' => $nearestClass->duration_minutes,
                        'price_tc' => $nearestClass->price_tc,
                    ] : null,
                ];
            }),
            'meta' => [
                'current_page' => $mentors->currentPage(),
                'last_page' => $mentors->lastPage(),
                'per_page' => $mentors->perPage(),
                'total' => $mentors->total(),
                'available_count' => $mentors->total(),
            ],
        ]);
    }

    public function showMentor(Request $request, User $mentor): JsonResponse
    {
        abort_unless($mentor->hasAssignedRole('mentor'), 404, 'Mentor tidak ditemukan.');
        $mentor->load('mentorProfile');

        $classes = MentoringClass::query()
            ->with(['mentor:id,name', 'mentor.mentorProfile'])
            ->withCount(['enrollments as enrolled_count' => fn ($q) => $q->whereNotIn('status', ['absent', 'declined'])])
            ->where('mentor_id', $mentor->id)
            ->where('status', 'open')
            ->where('scheduled_time', '>=', now())
            ->orderBy('scheduled_time')
            ->get();

        $reviews = Review::query()
            ->with('reviewer:id,name')
            ->where('reviewee_id', $mentor->id)
            ->whereNotNull('mentoring_class_id')
            ->latest()
            ->limit(10)
            ->get()
            ->map(fn (Review $r) => [
                'id' => $r->id,
                'reviewer_name' => $r->reviewer?->name ?? 'Mahasiswa',
                'rating' => $r->rating,
                'review_text' => $r->review_text,
                'strength_tags' => $r->strength_tags ?? [],
                'created_at' => $r->created_at?->toIso8601String(),
            ]);

        $sessionsCount = MentoringEnrollment::query()
            ->whereHas('mentoringClass', fn ($q) => $q->where('mentor_id', $mentor->id))
            ->whereIn('status', ['attended', 'pending_confirmation', 'completed'])
            ->count();

        $isBookmarked = MentorBookmark::where('student_id', $request->user()->id)
            ->where('mentor_id', $mentor->id)
            ->exists();

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $mentor->id,
                'name' => $mentor->name,
                'avatar_url' => $mentor->mentorProfile?->avatar_url,
                'title_headline' => $mentor->mentorProfile?->title_headline,
                'bio' => $mentor->mentorProfile?->bio,
                'hourly_rate_tc' => $mentor->mentorProfile?->hourly_rate_tc ?? 30,
                'rating' => (float) ($mentor->mentorProfile?->rating_average ?? 0),
                'reviews_count' => $reviews->count(),
                'sessions_count' => $sessionsCount,
                'portfolio_pass_rate' => 96,
                'languages' => 'Bahasa Indonesia & Inggris',
                'format' => '1-on-1 Meet',
                'is_verified' => true,
                'is_premium' => MentoringPresenter::isPremium($mentor->mentorProfile),
                'is_bookmarked' => $isBookmarked,
                'deliverables' => [
                    'Audit file & case study PDF',
                    'Simulasi tanya-jawab klien UMKM',
                    'Lencana "Mentor Verified" di profil',
                    'Rekaman sesi & action plan evaluasi',
                ],
                'classes' => $classes->map(fn (MentoringClass $c) => MentoringPresenter::mentoringClass($c))->values(),
                'reviews' => $reviews,
            ],
        ]);
    }

    public function toggleMentorBookmark(Request $request, User $mentor): JsonResponse
    {
        abort_unless($mentor->hasAssignedRole('mentor'), 404, 'Mentor tidak ditemukan.');
        $studentId = $request->user()->id;
        $existing = MentorBookmark::where('student_id', $studentId)
            ->where('mentor_id', $mentor->id)
            ->first();

        if ($existing) {
            $existing->delete();
            $bookmarked = false;
        } else {
            MentorBookmark::create([
                'student_id' => $studentId,
                'mentor_id' => $mentor->id,
            ]);
            $bookmarked = true;
        }

        return response()->json([
            'status' => 'success',
            'message' => $bookmarked ? 'Mentor disimpan ke daftar favorit.' : 'Mentor dihapus dari favorit.',
            'data' => ['is_bookmarked' => $bookmarked],
        ]);
    }

    public function classes(Request $request): JsonResponse
    {
        $classes = MentoringClass::query()
            ->with(['mentor:id,name', 'mentor.mentorProfile'])
            ->withCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])])
            ->where('status', 'open')
            ->where('scheduled_time', '>=', now())
            ->where(function ($q) {
                $q->whereHas('mentor.roleRecord', fn ($role) => $role->where('name', 'mentor'))
                    ->orWhereHas('mentor.roles', fn ($role) => $role->where('name', 'mentor'));
            })
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
        $mentoringClass->load(['mentor:id,name,role_id', 'mentor.mentorProfile']);
        abort_unless($mentoringClass->mentor?->hasAssignedRole('mentor') ?? false, 404);
        $mentoringClass->loadCount(['enrollments as enrolled_count' => fn ($query) => $query->whereNotIn('status', ['absent', 'declined'])]);

        return response()->json(['status' => 'success', 'data' => MentoringPresenter::mentoringClass($mentoringClass)]);
    }
}
