<?php

namespace App\Services;

use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectDeliverable;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use App\Models\Review;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ProjectWorkflowService
{
    public function __construct(
        private readonly StudentEligibilityService $eligibility,
        private readonly NotificationDispatcher $notifications,
    ) {
    }

    public function apply(User $student, Project $project, array $data): ProjectApplication
    {
        abort_unless($project->status === 'open', 409, 'Lowongan proyek ini sudah ditutup atau sedang dikerjakan.');

        $check = $this->eligibility->projectApplicationEligibility($student, $project);
        abort_unless($check['can_apply'], 403, $check['reason']);

        $portfolioIds = $data['portfolio_ids'] ?? [];
        if ($portfolioIds !== []) {
            $ownedCount = Portfolio::where('student_id', $student->id)
                ->whereIn('id', $portfolioIds)
                ->count();
            abort_if($ownedCount !== count(array_unique($portfolioIds)), 422, 'Portofolio yang dipilih tidak valid.');
        }

        try {
            $application = DB::transaction(function () use ($student, $project, $data, $portfolioIds, $check) {
                $lockedProject = Project::query()->lockForUpdate()->findOrFail($project->id);
                abort_unless($lockedProject->status === 'open', 409, 'Lowongan proyek ini sudah tidak terbuka.');

                return ProjectApplication::create([
                    'project_id' => $lockedProject->id,
                    'student_id' => $student->id,
                    'cover_letter' => $data['cover_letter'],
                    'portfolio_ids' => array_values(array_unique($portfolioIds)),
                    'portfolio_link' => $data['portfolio_link'] ?? null,
                    'has_mentor_endorsement_snapshot' => $check['has_mentor_endorsement'],
                    'timeline_commitment' => $data['timeline_commitment'] ?? $lockedProject->duration_label,
                    'dedication_hours' => $data['dedication_hours'] ?? '10-15 jam / minggu',
                    'status' => 'pending',
                    'applied_at' => now(),
                ]);
            }, 3);
        } catch (QueryException $exception) {
            if (ProjectApplication::where('project_id', $project->id)->where('student_id', $student->id)->exists()) {
                abort(409, 'Anda sudah mengajukan lamaran untuk proyek ini.');
            }
            throw $exception;
        }

        $this->notifications->send(
            $project->msme_id,
            'project_application_received',
            'Pelamar Baru Proyek UMKM',
            "{$student->name} melamar untuk proyek {$project->title}.",
            '/msme/review-applicants',
            ['project_id' => $project->id],
        );

        $this->notifications->send(
            $student,
            'project_application_submitted',
            'Lamaran Proyek Terkirim',
            "Lamaran Anda untuk {$project->title} sedang menunggu kurasi mitra UMKM.",
            '/my-projects',
            ['project_id' => $project->id],
        );

        return $application;
    }

    public function submitMilestoneDeliverable(
        User $student,
        ProjectMilestone $milestone,
        array $data,
        ?UploadedFile $file = null,
    ): ProjectDeliverable {
        $project = Project::findOrFail($milestone->project_id);
        $this->assertAcceptedStudent($student, $project);

        $storedPath = null;
        $fileName = null;
        $fileSizeLabel = null;
        if ($file) {
            $storedPath = $file->store('project-deliverables', 'public');
            $fileName = $file->getClientOriginalName();
            $bytes = $file->getSize() ?: 0;
            $fileSizeLabel = $bytes >= 1048576
                ? number_format($bytes / 1048576, 1).' MB'
                : max(1, (int) round($bytes / 1024)).' KB';
        }

        try {
            $deliverable = DB::transaction(function () use ($student, $project, $milestone, $data, $storedPath, $fileName, $fileSizeLabel) {
                $lockedMilestone = ProjectMilestone::query()->lockForUpdate()->findOrFail($milestone->id);
                abort_if(
                    in_array($lockedMilestone->status, ['locked', 'approved'], true),
                    409,
                    $lockedMilestone->status === 'locked'
                        ? 'Tahap ini masih terkunci sampai tahap sebelumnya selesai.'
                        : 'Tahap ini sudah disetujui UMKM.',
                );

                $prevCount = ProjectDeliverable::where('milestone_id', $lockedMilestone->id)
                    ->where('student_id', $student->id)
                    ->count();

                $deliverable = ProjectDeliverable::create([
                    'project_id' => $project->id,
                    'milestone_id' => $lockedMilestone->id,
                    'student_id' => $student->id,
                    'submission_format' => $data['submission_format'] ?? ($storedPath ? 'file' : 'link'),
                    'deliverable_url' => $data['deliverable_url'] ?? ($storedPath ? Storage::disk('public')->url($storedPath) : null),
                    'file_path' => $storedPath,
                    'file_name' => $fileName,
                    'file_size_label' => $fileSizeLabel,
                    'submission_notes' => $data['submission_notes'] ?? null,
                    'attachment_links' => $data['attachment_links'] ?? [],
                    'revision_count' => $prevCount,
                    'status' => 'submitted',
                    'submitted_at' => now(),
                ]);

                $lockedMilestone->update(['status' => 'submitted']);
                if ($project->status === 'in_progress') {
                    $project->update(['status' => 'review']);
                }

                return $deliverable;
            }, 3);
        } catch (\Throwable $e) {
            if ($storedPath !== null) {
                Storage::disk('public')->delete($storedPath);
            }
            throw $e;
        }

        $this->notifications->send(
            $project->msme_id,
            'deliverable_submitted',
            'Hasil Tahap Proyek Dikirim',
            "{$student->name} mengumpulkan hasil untuk tahap {$milestone->title}.",
            '/msme/review-submission',
            ['project_id' => $project->id],
        );

        return $deliverable;
    }

    public function addCustomMilestone(User $student, Project $project, array $data): ProjectMilestone
    {
        $this->assertAcceptedStudent($student, $project);

        return DB::transaction(function () use ($project, $data) {
            $lockedProject = Project::query()->lockForUpdate()->findOrFail($project->id);
            $allocated = (int) $lockedProject->milestones()->sum('reward_tc');
            $remainingBudget = max(0, $lockedProject->reward_tc - $allocated);
            $requestedTc = (int) $data['reward_tc'];

            if ($requestedTc > $remainingBudget) {
                // Split budget equitably from unlocked future milestones instead of inflating escrow budget.
                $adjustable = $lockedProject->milestones()
                    ->whereIn('status', ['locked', 'open'])
                    ->orderByDesc('step_order')
                    ->first();
                abort_if(
                    ! $adjustable || ($adjustable->reward_tc + $remainingBudget) <= $requestedTc,
                    422,
                    'Nominal tahap baru melebihi sisa alokasi anggaran proyek ('.$lockedProject->reward_tc.' TC).',
                );
                $takeFromAdjustable = $requestedTc - $remainingBudget;
                $adjustable->decrement('reward_tc', $takeFromAdjustable);
            }

            $nextOrder = ((int) $lockedProject->milestones()->max('step_order')) + 1;
            $hasOpen = $lockedProject->milestones()->whereIn('status', ['open', 'submitted', 'revision_requested'])->exists();

            return ProjectMilestone::create([
                'project_id' => $lockedProject->id,
                'step_order' => $nextOrder,
                'title' => $data['title'],
                'description' => $data['description'] ?? null,
                'reward_tc' => $requestedTc,
                'status' => $hasOpen ? 'locked' : 'open',
            ]);
        }, 3);
    }

    public function reviewClient(User $student, Project $project, array $data): Review
    {
        $this->assertAcceptedStudent($student, $project);
        abort_unless($project->status === 'completed', 409, 'Ulasan mitra hanya dapat dikirim setelah proyek dinyatakan selesai.');

        $existing = Review::where('reviewer_id', $student->id)
            ->where('reviewee_id', $project->msme_id)
            ->where('project_id', $project->id)
            ->first();
        abort_if($existing !== null, 409, 'Anda sudah memberikan ulasan untuk proyek ini.');

        return Review::create([
            'reviewer_id' => $student->id,
            'reviewee_id' => $project->msme_id,
            'project_id' => $project->id,
            'rating' => (int) $data['rating'],
            'review_text' => $data['review_text'] ?? null,
        ]);
    }

    public function assertAcceptedStudent(User $student, Project $project): void
    {
        $isAssigned = ProjectApplication::where('project_id', $project->id)
            ->where('student_id', $student->id)
            ->where('status', 'accepted')
            ->exists();
        abort_unless($isAssigned, 403, 'Anda bukan pelaksana terpilih untuk proyek ini.');
    }

    public function assertStudentTaskOwner(User $student, ProjectTask $task): void
    {
        abort_unless($task->student_id === $student->id, 403, 'Anda tidak berhak mengubah tugas ini.');
    }
}

