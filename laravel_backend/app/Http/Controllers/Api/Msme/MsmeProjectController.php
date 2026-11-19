<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProjectPresenter;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MsmeProjectController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $status = $request->query('status');

        $query = Project::with([
            'msme.umkmProfile',
            'milestones',
            'applications.student.studentProfile',
        ])->where('msme_id', $user->id);

        if ($status && $status !== 'all') {
            if ($status === 'in_progress') {
                $query->whereIn('status', ['in_progress', 'review']);
            } else {
                $query->where('status', $status);
            }
        }

        $projects = $query->latest('id')->get()->map(function ($project) {
            /** @var Project $project */
            $applicantsCount = $project->applications->count();
            $pendingCount = $project->applications->where('status', 'pending')->count();
            $acceptedApp = $project->applications->firstWhere('status', 'accepted');
            $acceptedStudent = $acceptedApp?->student;
            $studentProfile = $acceptedStudent?->studentProfile;

            $milestones = $project->milestones;
            $totalStages = max(1, $milestones->count());
            $approvedCount = $milestones->where('status', 'approved')->count();
            $releasedTc = (int) $milestones->where('status', 'approved')->sum('reward_tc');
            $escrowTc = max(0, (int) $project->reward_tc - $releasedTc);
            $submittedMilestone = $milestones->firstWhere('status', 'submitted');

            $kanbanTasks = $acceptedStudent
                ? ProjectTask::where('project_id', $project->id)
                    ->where('student_id', $acceptedStudent->id)
                    ->get()
                : collect();
            $kanbanTotal = $kanbanTasks->count();
            $kanbanDone = $kanbanTasks->where('status', 'done')->count();

            return [
                ...ProjectPresenter::projectCard($project),
                'applicants_count' => $applicantsCount,
                'pending_applicants_count' => $pendingCount,
                'milestones_count' => $milestones->count(),
                'current_stage' => min($totalStages, $approvedCount + 1),
                'total_stages' => $totalStages,
                'progress_percent' => (int) round(($approvedCount / $totalStages) * 100),
                'released_tc' => $releasedTc,
                'escrow_tc' => $escrowTc,
                'has_pending_submission' => $submittedMilestone !== null,
                'latest_submitted_milestone_title' => $submittedMilestone?->title,
                'kanban_done_count' => $kanbanDone,
                'kanban_total_count' => $kanbanTotal,
                'kanban_progress_percent' => $kanbanTotal > 0 ? (int) round(($kanbanDone / $kanbanTotal) * 100) : 0,
                'accepted_student' => $acceptedStudent ? [
                    'id' => $acceptedStudent->id,
                    'name' => $acceptedStudent->name,
                    'avatar_url' => $studentProfile?->avatar_url,
                    'university' => $studentProfile?->university ?? 'Universitas Negeri Surabaya',
                ] : null,
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $projects,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $umkmProfile = $user->umkmProfile;

        $data = $request->validate([
            'title' => ['required', 'string', 'max:200'],
            'category' => ['required', 'string', 'max:100'],
            'division' => ['nullable', 'string', 'max:120'],
            'reward_tc' => ['required', 'integer', 'min:5'],
            'deadline' => ['nullable', 'date'],
            'deadline_days' => ['nullable', 'integer', 'min:1', 'max:365'],
            'duration_label' => ['nullable', 'string', 'max:60'],
            'work_mode' => ['nullable', 'string', 'max:30'],
            'location_label' => ['nullable', 'string', 'max:120'],
            'description' => ['required', 'string'],
            'deliverables_checklist' => ['nullable', 'array'],
            'deliverables_checklist.*' => ['string', 'max:250'],
            'skills' => ['nullable', 'array'],
            'skills.*' => ['string', 'max:80'],
            'requires_endorsement' => ['nullable', 'boolean'],
            'benefit_badge' => ['nullable', 'string', 'max:120'],
        ]);

        $deadline = null;
        if (! empty($data['deadline'])) {
            $deadline = Carbon::parse($data['deadline']);
        } elseif (! empty($data['deadline_days'])) {
            $deadline = now()->addDays((int) $data['deadline_days']);
        } else {
            $deadline = now()->addDays(14);
        }

        $durationLabel = $data['duration_label'] ?? '14 Hari (2 Minggu)';
        $locationLabel = $data['location_label'] ?? ($umkmProfile?->city ?? 'Surabaya');
        $skills = $data['skills'] ?? [$data['category']];
        $checklist = $data['deliverables_checklist'] ?? [
            'Hasil pekerjaan utama sesuai instruksi',
            'Berkas sumber / file asli (master file)',
            'Tautan serah terima hasil pengerjaan',
        ];

        $code = 'TS-PRJ-'.strtoupper(Str::random(6));

        $project = DB::transaction(function () use ($user, $data, $code, $deadline, $durationLabel, $locationLabel, $skills, $checklist) {
            $createdProject = Project::create([
                'msme_id' => $user->id,
                'code' => $code,
                'title' => $data['title'],
                'division' => $data['division'] ?? $data['category'],
                'category' => $data['category'],
                'description' => $data['description'],
                'deliverables_checklist' => $checklist,
                'reward_tc' => (int) $data['reward_tc'],
                'deadline' => $deadline,
                'duration_label' => $durationLabel,
                'work_mode' => $data['work_mode'] ?? 'Hybrid',
                'location_label' => $locationLabel,
                'skills' => $skills,
                'benefit_badge' => $data['benefit_badge'] ?? 'Sertifikat & Portofolio',
                'requires_endorsement' => (bool) ($data['requires_endorsement'] ?? false),
                'status' => 'open',
            ]);

            $totalTc = (int) $data['reward_tc'];
            $part1 = (int) round($totalTc * 0.3);
            $part2 = (int) round($totalTc * 0.4);
            $part3 = max(1, $totalTc - ($part1 + $part2));

            ProjectMilestone::create([
                'project_id' => $createdProject->id,
                'step_order' => 1,
                'title' => 'Tahap 1: Riset & Konsep Awal',
                'description' => 'Penyusunan rencana kerja, pengumpulan referensi, dan draft konsep awal.',
                'reward_tc' => $part1,
                'status' => 'open',
            ]);

            ProjectMilestone::create([
                'project_id' => $createdProject->id,
                'step_order' => 2,
                'title' => 'Tahap 2: Pengerjaan Deliverable Utama',
                'description' => 'Realisasi pekerjaan utama sesuai spesifikasi dan ceklis hasil kerja.',
                'reward_tc' => $part2,
                'status' => 'locked',
            ]);

            ProjectMilestone::create([
                'project_id' => $createdProject->id,
                'step_order' => 3,
                'title' => 'Tahap 3: Finalisasi & Serah Terima',
                'description' => 'Pemeriksaan akhir, revisi minor jika diperlukan, dan penyerahan master file.',
                'reward_tc' => $part3,
                'status' => 'locked',
            ]);

            return $createdProject;
        });

        $project->load(['msme.umkmProfile', 'milestones']);

        return response()->json([
            'status' => 'success',
            'message' => 'Proyek berhasil dipublikasikan.',
            'data' => [
                ...ProjectPresenter::projectCard($project),
                'applicants_count' => 0,
                'milestones' => $project->milestones,
            ],
        ], 201);
    }

    public function show(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        abort_unless($project->msme_id === $user->id, 403, 'Anda tidak berhak melihat proyek ini.');

        $project->load([
            'msme.umkmProfile',
            'milestones',
            'applications.student.studentProfile',
            'applications.student.studentSkills',
            'deliverables',
        ]);

        $applicants = $project->applications->map(function ($app) {
            $student = $app->student;
            $profile = $student?->studentProfile;

            return [
                'id' => $app->id,
                'student_id' => $student?->id,
                'student_name' => $student?->name,
                'avatar_url' => $profile?->avatar_url,
                'university' => $profile?->university,
                'major' => $profile?->major,
                'student_id_number' => $profile?->student_id_number,
                'rating' => 4.9,
                'has_mentor_endorsement' => (bool) $app->has_mentor_endorsement_snapshot,
                'cover_letter' => $app->cover_letter,
                'portfolio_link' => $app->portfolio_link,
                'portfolio_ids' => $app->portfolio_ids ?? [],
                'timeline_commitment' => $app->timeline_commitment,
                'status' => $app->status,
                'applied_at' => $app->applied_at?->toIso8601String(),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => [
                ...ProjectPresenter::projectCard($project),
                'deliverables_checklist' => $project->deliverables_checklist ?? [],
                'milestones' => $project->milestones,
                'applicants' => $applicants,
                'applicants_count' => $applicants->count(),
            ],
        ]);
    }

    public function update(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        abort_unless($project->msme_id === $user->id, 403, 'Anda tidak berhak mengubah proyek ini.');

        $data = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'max:200'],
            'category' => ['sometimes', 'required', 'string', 'max:100'],
            'division' => ['nullable', 'string', 'max:120'],
            'reward_tc' => ['sometimes', 'required', 'integer', 'min:5'],
            'deadline' => ['nullable', 'date'],
            'deadline_days' => ['nullable', 'integer', 'min:1', 'max:365'],
            'duration_label' => ['nullable', 'string', 'max:60'],
            'work_mode' => ['nullable', 'string', 'max:30'],
            'location_label' => ['nullable', 'string', 'max:120'],
            'description' => ['sometimes', 'required', 'string'],
            'deliverables_checklist' => ['nullable', 'array'],
            'deliverables_checklist.*' => ['string', 'max:250'],
            'skills' => ['nullable', 'array'],
            'skills.*' => ['string', 'max:80'],
            'requires_endorsement' => ['nullable', 'boolean'],
            'benefit_badge' => ['nullable', 'string', 'max:120'],
            'status' => ['nullable', 'string', 'in:open,in_progress,review,completed,cancelled'],
        ]);

        if (isset($data['deadline_days']) && ! isset($data['deadline'])) {
            $data['deadline'] = now()->addDays((int) $data['deadline_days']);
        }

        DB::transaction(function () use ($project, $data) {
            $project->update($data);

            if (isset($data['reward_tc'])) {
                $totalTc = (int) $data['reward_tc'];
                $part1 = (int) round($totalTc * 0.3);
                $part2 = (int) round($totalTc * 0.4);
                $part3 = max(1, $totalTc - ($part1 + $part2));

                $milestones = $project->milestones()->orderBy('step_order')->get();
                if ($milestones->count() >= 3) {
                    $milestones[0]->update(['reward_tc' => $part1]);
                    $milestones[1]->update(['reward_tc' => $part2]);
                    $milestones[2]->update(['reward_tc' => $part3]);
                }
            }
        });

        $project->load(['msme.umkmProfile', 'milestones']);

        return response()->json([
            'status' => 'success',
            'message' => 'Detail tugas proyek berhasil diperbarui.',
            'data' => [
                ...ProjectPresenter::projectCard($project),
                'deliverables_checklist' => $project->deliverables_checklist ?? [],
                'milestones' => $project->milestones,
            ],
        ]);
    }

    public function destroy(Request $request, Project $project): JsonResponse
    {
        $user = $request->user();
        abort_unless($project->msme_id === $user->id, 403, 'Anda tidak berhak menghapus proyek ini.');

        if ($project->status !== 'open') {
            return response()->json([
                'status' => 'error',
                'message' => 'Proyek yang sedang berjalan atau sudah selesai tidak dapat dihapus.',
            ], 422);
        }

        DB::transaction(function () use ($project) {
            $project->milestones()->delete();
            $project->applications()->delete();
            $project->delete();
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Tugas proyek berhasil dihapus.',
        ]);
    }
}
