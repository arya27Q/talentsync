<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectDeliverable;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use App\Models\Review;
use App\Models\StudentCertificate;
use App\Models\StudentProfile;
use App\Models\TimeCoinWallet;
use App\Models\User;
use App\Services\NotificationDispatcher;
use App\Services\StudentEligibilityService;
use App\Services\TimeCoinLedgerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MsmeSubmissionController extends Controller
{
    public function __construct(
        private readonly TimeCoinLedgerService $ledger,
        private readonly NotificationDispatcher $notifications,
        private readonly StudentEligibilityService $eligibility,
    ) {
    }

    /**
     * Daftar pengajuan hasil (milestone deliverables) pada proyek milik UMKM.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $projectId = $request->query('project_id');
        $statusFilter = $request->query('status', 'submitted');

        $projectIds = Project::where('msme_id', $user->id)
            ->when($projectId, fn ($q) => $q->where('id', (int) $projectId))
            ->pluck('id');

        if ($projectIds->isEmpty()) {
            return response()->json([
                'status' => 'success',
                'data' => [
                    'counts' => [
                        'submitted' => 0,
                        'revision_requested' => 0,
                        'approved' => 0,
                    ],
                    'items' => [],
                ],
            ]);
        }

        $allMilestones = ProjectMilestone::query()
            ->with([
                'project.msme.umkmProfile',
                'project.milestones',
                'project.applications' => fn ($q) => $q->where('status', 'accepted')->with('student.studentProfile'),
                'deliverables' => fn ($q) => $q->latest('id'),
            ])
            ->whereIn('project_id', $projectIds)
            ->whereIn('status', ['submitted', 'revision_requested', 'approved'])
            ->orderByDesc('updated_at')
            ->orderBy('step_order')
            ->get();

        $counts = [
            'submitted' => $allMilestones->where('status', 'submitted')->count(),
            'revision_requested' => $allMilestones->where('status', 'revision_requested')->count(),
            'approved' => $allMilestones->where('status', 'approved')->count(),
        ];

        $filtered = $statusFilter && $statusFilter !== 'all'
            ? $allMilestones->where('status', $statusFilter)->values()
            : $allMilestones->values();

        $items = $filtered->map(function (ProjectMilestone $milestone) use ($user) {
            $project = $milestone->project;
            $deliverable = $milestone->deliverables->first();
            $acceptedApp = $project?->applications?->first();
            $student = $acceptedApp?->student ?? $deliverable?->student;
            $studentProfile = $student?->studentProfile;

            $projectMilestones = $project?->milestones ?? collect();
            $totalStages = max(1, $projectMilestones->count());
            $unapprovedOtherCount = $projectMilestones
                ->where('id', '!=', $milestone->id)
                ->where('status', '!=', 'approved')
                ->count();
            $isFinalStage = $unapprovedOtherCount === 0;

            $existingReview = ($project && $student)
                ? Review::where('reviewer_id', $user->id)
                    ->where('reviewee_id', $student->id)
                    ->where('project_id', $project->id)
                    ->first()
                : null;

            return [
                'milestone_id' => $milestone->id,
                'deliverable_id' => $deliverable?->id,
                'project_id' => $milestone->project_id,
                'project_title' => $project?->title ?? 'Proyek UMKM',
                'project_category' => $project?->category ?? 'Umum',
                'project_status' => $project?->status ?? 'in_progress',
                'project_reward_tc' => (int) ($project?->reward_tc ?? 0),
                'deliverables_checklist' => $project?->deliverables_checklist ?? [],
                'step_order' => (int) $milestone->step_order,
                'total_stages' => $totalStages,
                'is_final_stage' => $isFinalStage,
                'milestone_title' => $milestone->title,
                'milestone_description' => $milestone->description,
                'milestone_reward_tc' => (int) $milestone->reward_tc,
                'milestone_status' => $milestone->status,
                'submission_format' => $deliverable?->submission_format ?? 'link',
                'deliverable_url' => $deliverable?->deliverable_url,
                'file_name' => $deliverable?->file_name,
                'file_size_label' => $deliverable?->file_size_label,
                'submission_notes' => $deliverable?->submission_notes,
                'attachment_links' => $deliverable?->attachment_links ?? [],
                'revision_count' => (int) ($deliverable?->revision_count ?? 0),
                'revision_notes' => $deliverable?->revision_notes,
                'recommend_mentor_consultation' => (bool) ($deliverable?->recommend_mentor_consultation ?? false),
                'deliverable_status' => $deliverable?->status ?? $milestone->status,
                'submitted_at' => $deliverable?->submitted_at?->toIso8601String() ?? $milestone->updated_at?->toIso8601String(),
                'reviewed_at' => $deliverable?->reviewed_at?->toIso8601String(),
                'student' => $student ? [
                    'id' => $student->id,
                    'name' => $student->name,
                    'avatar_url' => $studentProfile?->avatar_url,
                    'university' => $studentProfile?->university ?? 'Universitas Negeri Surabaya',
                    'major' => $studentProfile?->major ?? 'S1 Sistem Informasi',
                    'rating' => (float) ($studentProfile?->rating_average ?? 0),
                ] : null,
                'existing_review' => $existingReview ? [
                    'rating' => (int) $existingReview->rating,
                    'review_text' => $existingReview->review_text,
                ] : null,
            ];
        })->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'counts' => $counts,
                'items' => $items,
            ],
        ]);
    }

    /**
     * Meminta revisi pada milestone yang telah dikumpulkan mahasiswa.
     */
    public function requestRevision(Request $request, ProjectMilestone $milestone): JsonResponse
    {
        $user = $request->user();
        $project = Project::findOrFail($milestone->project_id);
        abort_unless($project->msme_id === $user->id, 403, 'Anda tidak berhak meninjau proyek ini.');

        $data = $request->validate([
            'revision_notes' => ['required', 'string', 'min:5', 'max:2000'],
            'recommend_mentor_consultation' => ['sometimes', 'boolean'],
        ], [
            'revision_notes.required' => 'Catatan revisi wajib diisi agar mahasiswa memahami perbaikan yang diperlukan.',
            'revision_notes.min' => 'Catatan revisi minimal 5 karakter.',
        ]);

        $recommendMentor = (bool) ($data['recommend_mentor_consultation'] ?? false);

        $acceptedApp = ProjectApplication::where('project_id', $project->id)
            ->where('status', 'accepted')
            ->first();
        abort_unless($acceptedApp !== null, 409, 'Proyek belum memiliki mahasiswa pelaksana.');

        DB::transaction(function () use ($milestone, $project, $data, $recommendMentor, $acceptedApp) {
            $lockedMilestone = ProjectMilestone::query()->lockForUpdate()->findOrFail($milestone->id);
            abort_unless(
                $lockedMilestone->status === 'submitted',
                409,
                'Hanya tahap berstatus menunggu tinjauan yang dapat diminta revisi.',
            );

            $latestDeliverable = ProjectDeliverable::where('milestone_id', $lockedMilestone->id)
                ->latest('id')
                ->first();

            if ($latestDeliverable) {
                $latestDeliverable->update([
                    'status' => 'revision_requested',
                    'revision_notes' => trim($data['revision_notes']),
                    'recommend_mentor_consultation' => $recommendMentor,
                    'reviewed_at' => now(),
                ]);
            }

            $lockedMilestone->update(['status' => 'revision_requested']);

            // Kembalikan tugas Kanban pada tahap ini yang sedang di kolom Review ke In Progress
            ProjectTask::where('project_id', $project->id)
                ->where('milestone_id', $lockedMilestone->id)
                ->where('status', 'review')
                ->update(['status' => 'in_progress']);

            $hasOtherSubmitted = ProjectMilestone::where('project_id', $project->id)
                ->where('id', '!=', $lockedMilestone->id)
                ->where('status', 'submitted')
                ->exists();

            if (! $hasOtherSubmitted && $project->status === 'review') {
                $project->update(['status' => 'in_progress']);
            }
        }, 3);

        $msmeName = $user->umkmProfile?->business_name ?? $user->name;
        $mentorNote = $recommendMentor
            ? ' Mitra juga menyarankan konsultasi singkat bersama Peer Mentor.'
            : '';

        $this->notifications->send(
            $acceptedApp->student_id,
            'deliverable_revision_requested',
            'Permintaan Revisi Proyek UMKM',
            "{$msmeName} meminta revisi pada {$milestone->title}: ".Str::limit(trim($data['revision_notes']), 110).$mentorNote,
            '/workspace/submission',
            ['project_id' => $project->id, 'milestone_id' => $milestone->id],
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Permintaan revisi berhasil dikirim ke mahasiswa.',
            'data' => [
                'milestone_id' => $milestone->id,
                'milestone_status' => 'revision_requested',
                'recommend_mentor_consultation' => $recommendMentor,
            ],
        ]);
    }

    /**
     * Menyetujui milestone, merilis escrow TimeCoin ke mahasiswa, membuka tahap selanjutnya,
     * dan jika ini tahap terakhir: selesaikan proyek, simpan rating/ulasan, serta terbitkan portofolio & sertifikat.
     */
    public function approve(Request $request, ProjectMilestone $milestone): JsonResponse
    {
        $user = $request->user();
        $project = Project::with('msme.umkmProfile')->findOrFail($milestone->project_id);
        abort_unless($project->msme_id === $user->id, 403, 'Anda tidak berhak menyetujui proyek ini.');

        $data = $request->validate([
            'rating' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:5'],
            'review_text' => ['sometimes', 'nullable', 'string', 'max:2000'],
        ]);

        $acceptedApp = ProjectApplication::where('project_id', $project->id)
            ->where('status', 'accepted')
            ->first();
        abort_unless($acceptedApp !== null, 409, 'Proyek belum memiliki mahasiswa pelaksana.');

        $student = User::findOrFail($acceptedApp->student_id);

        $result = DB::transaction(function () use ($user, $project, $milestone, $student, $data) {
            $lockedMilestone = ProjectMilestone::query()->lockForUpdate()->findOrFail($milestone->id);
            abort_unless(
                $lockedMilestone->status === 'submitted',
                409,
                $lockedMilestone->status === 'approved'
                    ? 'Tahap ini sudah disetujui dan TimeCoin telah dicairkan sebelumnya.'
                    : 'Tahap ini belum diajukan oleh mahasiswa untuk ditinjau.',
            );

            $latestDeliverable = ProjectDeliverable::where('milestone_id', $lockedMilestone->id)
                ->latest('id')
                ->first();

            if ($latestDeliverable) {
                $latestDeliverable->update([
                    'status' => 'approved',
                    'reviewed_at' => now(),
                ]);
            }

            $lockedMilestone->update(['status' => 'approved']);

            // Tandai tugas Kanban pada tahap ini sebagai selesai (done)
            ProjectTask::where('project_id', $project->id)
                ->where('milestone_id', $lockedMilestone->id)
                ->where('status', '!=', 'done')
                ->update(['status' => 'done']);

            // Kunci & rilis TimeCoin ke dompet mahasiswa secara ACID
            $msmeWallet = TimeCoinWallet::firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 0, 'locked_balance' => 0],
            );
            $studentWallet = TimeCoinWallet::firstOrCreate(
                ['user_id' => $student->id],
                ['balance' => 0, 'locked_balance' => 0],
            );

            $lockedMsmeWallet = TimeCoinWallet::query()->lockForUpdate()->findOrFail($msmeWallet->id);
            $lockedStudentWallet = TimeCoinWallet::query()->lockForUpdate()->findOrFail($studentWallet->id);

            $rewardTc = (int) $lockedMilestone->reward_tc;
            $this->ledger->releaseProjectMilestoneReward(
                $lockedMsmeWallet,
                $lockedStudentWallet,
                $user->id,
                $student->id,
                $rewardTc,
                $lockedMilestone,
            );

            // Cek apakah masih ada tahap berikutnya
            $nextMilestone = ProjectMilestone::where('project_id', $project->id)
                ->where('status', 'locked')
                ->orderBy('step_order')
                ->first();

            if ($nextMilestone) {
                $nextMilestone->update(['status' => 'open']);
            }

            $remainingUnapproved = ProjectMilestone::where('project_id', $project->id)
                ->where('status', '!=', 'approved')
                ->count();

            $isProjectCompleted = $remainingUnapproved === 0;
            $certificateCode = null;
            $portfolioCreated = false;

            if ($isProjectCompleted) {
                $project->update(['status' => 'completed']);

                $rating = (int) ($data['rating'] ?? 5);
                $reviewText = trim((string) ($data['review_text'] ?? ''));
                if ($reviewText === '') {
                    $reviewText = 'Hasil pengerjaan proyek sesuai kebutuhan usaha dan diserahkan dengan baik.';
                }

                Review::updateOrCreate(
                    [
                        'reviewer_id' => $user->id,
                        'reviewee_id' => $student->id,
                        'project_id' => $project->id,
                    ],
                    [
                        'rating' => $rating,
                        'review_text' => $reviewText,
                    ],
                );

                // Auto terbitkan Portofolio Terverifikasi untuk Mahasiswa
                $businessName = $user->umkmProfile?->business_name ?? $user->name;
                $portfolio = Portfolio::firstOrCreate(
                    [
                        'student_id' => $student->id,
                        'project_id' => $project->id,
                    ],
                    [
                        'title' => $project->title,
                        'category' => $project->category,
                        'client_name' => $businessName,
                        'role_title' => $project->division ?: $project->category,
                        'duration_label' => $project->duration_label ?: '14 Hari',
                        'reward_tc' => (int) $project->reward_tc,
                        'rating' => $rating,
                        'tags' => $project->skills ?? [$project->category],
                        'problem_summary' => Str::limit($project->description, 350),
                        'solution_summary' => $latestDeliverable?->submission_notes
                            ?: 'Menyelesaikan seluruh tahapan deliverable proyek sesuai spesifikasi mitra UMKM.',
                        'result_summary' => 'Seluruh tahapan milestone tervalidasi dan disetujui mitra UMKM.',
                        'deliverable_highlights' => $project->deliverables_checklist ?? [],
                        'testimonial_quote' => $reviewText,
                        'testimonial_author' => $businessName,
                        'case_study_url' => $latestDeliverable?->deliverable_url,
                        'is_verified' => true,
                        'is_featured' => false,
                    ],
                );
                $portfolioCreated = $portfolio->wasRecentlyCreated;

                // Auto terbitkan Sertifikat Penyelesaian Proyek
                $existingCert = StudentCertificate::where('student_id', $student->id)
                    ->where('source_type', 'project')
                    ->where('reference_type', Project::class)
                    ->where('reference_id', $project->id)
                    ->first();

                if ($existingCert) {
                    $certificateCode = $existingCert->certificate_code;
                } else {
                    $certificateCode = 'TS-PRJ-'.str_pad((string) $project->id, 4, '0', STR_PAD_LEFT).'-'.strtoupper(Str::random(3));
                    StudentCertificate::create([
                        'student_id' => $student->id,
                        'source_type' => 'project',
                        'certificate_code' => $certificateCode,
                        'title' => $project->title,
                        'issuer_name' => $businessName,
                        'category_label' => 'Proyek UMKM',
                        'reference_type' => Project::class,
                        'reference_id' => $project->id,
                        'issued_at' => now(),
                    ]);
                }

                // Sinkronisasi metrik profil mahasiswa (completed_projects_count, rating_average)
                $studentProfile = StudentProfile::where('user_id', $student->id)->first();
                if ($studentProfile) {
                    $completedProjects = Project::where('status', 'completed')
                        ->whereHas('applications', fn ($q) => $q->where('student_id', $student->id)->where('status', 'accepted'))
                        ->count();
                    $avgRating = (float) Review::where('reviewee_id', $student->id)->avg('rating');
                    $studentProfile->update([
                        'completed_projects_count' => max((int) $studentProfile->completed_projects_count, $completedProjects),
                        'rating_average' => $avgRating > 0 ? round($avgRating, 2) : (float) $rating,
                    ]);
                }
            } else {
                $hasOtherSubmitted = ProjectMilestone::where('project_id', $project->id)
                    ->where('status', 'submitted')
                    ->exists();
                $project->update(['status' => $hasOtherSubmitted ? 'review' : 'in_progress']);
            }

            return [
                'reward_tc' => $rewardTc,
                'is_project_completed' => $isProjectCompleted,
                'project_status' => $project->fresh()->status,
                'next_milestone_id' => $nextMilestone?->id,
                'next_milestone_title' => $nextMilestone?->title,
                'student_balance_tc' => (int) $lockedStudentWallet->fresh()->balance,
                'msme_balance_tc' => (int) $lockedMsmeWallet->fresh()->balance,
                'portfolio_created' => $portfolioCreated,
                'certificate_code' => $certificateCode,
            ];
        }, 3);

        if ($result['is_project_completed']) {
            $this->eligibility->mentorSwitchEligibility($student->fresh());
        }

        $msmeName = $user->umkmProfile?->business_name ?? $user->name;
        if ($result['is_project_completed']) {
            $this->notifications->send(
                $student,
                'project_completed',
                'Proyek Selesai & TimeCoin Cair!',
                "{$msmeName} telah menyetujui seluruh tahap '{$project->title}'. +{$result['reward_tc']} TC masuk dompet, serta portofolio & sertifikat proyek telah diterbitkan.",
                '/project/completed',
                ['project_id' => $project->id],
            );
        } else {
            $nextInfo = $result['next_milestone_title']
                ? " {$result['next_milestone_title']} kini telah dibuka."
                : '';
            $this->notifications->send(
                $student,
                'milestone_approved',
                'Tahap Proyek Disetujui!',
                "{$msmeName} menyetujui {$milestone->title}. +{$result['reward_tc']} TC berhasil masuk ke dompet Anda.{$nextInfo}",
                '/workspace/submission',
                ['project_id' => $project->id, 'milestone_id' => $milestone->id],
            );
        }

        return response()->json([
            'status' => 'success',
            'message' => $result['is_project_completed']
                ? "Proyek selesai! +{$result['reward_tc']} TC telah ditransfer ke {$student->name}, serta portofolio dan sertifikat proyek otomatis diterbitkan."
                : "{$milestone->title} disetujui! +{$result['reward_tc']} TC telah ditransfer ke {$student->name}.",
            'data' => [
                'milestone_id' => $milestone->id,
                'milestone_status' => 'approved',
                ...$result,
            ],
        ]);
    }
}
