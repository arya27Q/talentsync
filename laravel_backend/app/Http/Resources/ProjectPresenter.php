<?php

namespace App\Http\Resources;

use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectDeliverable;
use App\Models\ProjectMessage;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use Illuminate\Support\Carbon;

final class ProjectPresenter
{
    public static function projectCard(Project $project, bool $isBookmarked = false): array
    {
        $umkm = $project->relationLoaded('msme') ? $project->msme : null;
        $umkmProfile = $umkm?->relationLoaded('umkmProfile') ? $umkm->umkmProfile : $umkm?->umkmProfile;
        $daysLeft = $project->deadline
            ? max(0, (int) now()->startOfDay()->diffInDays(Carbon::parse($project->deadline)->startOfDay(), false))
            : 0;

        return [
            'id' => $project->id,
            'code' => $project->code,
            'title' => $project->title,
            'division' => $project->division,
            'category' => $project->category,
            'description' => $project->description,
            'reward_tc' => $project->reward_tc,
            'estimated_idr' => $project->reward_tc * 1000,
            'deadline' => $project->deadline?->toDateString(),
            'days_left' => $daysLeft,
            'duration_label' => $project->duration_label,
            'work_mode' => $project->work_mode,
            'location_label' => $project->location_label,
            'skills' => $project->skills ?? [],
            'benefit_badge' => $project->benefit_badge,
            'requires_endorsement' => (bool) $project->requires_endorsement,
            'status' => $project->status,
            'is_bookmarked' => $isBookmarked,
            'msme' => [
                'id' => $project->msme_id,
                'owner_name' => $umkm?->name,
                'business_name' => $umkmProfile?->business_name ?? $umkm?->name ?? 'Mitra UMKM',
                'business_sector' => $umkmProfile?->business_sector ?? $project->category,
                'logo_url' => $umkmProfile?->logo_url,
                'district' => $umkmProfile?->district,
                'city' => $umkmProfile?->city ?? 'Surabaya',
                'is_verified' => (bool) ($umkmProfile?->is_verified ?? true),
            ],
        ];
    }

    public static function projectDetail(
        Project $project,
        array $eligibility,
        bool $isBookmarked,
        ?ProjectApplication $application = null,
    ): array {
        $umkm = $project->msme;
        $umkmProfile = $umkm?->umkmProfile;
        $milestones = $project->milestones;

        return [
            ...self::projectCard($project, $isBookmarked),
            'deliverables_checklist' => $project->deliverables_checklist ?? [],
            'milestones_count' => $milestones->count(),
            'milestones' => $milestones->map(fn (ProjectMilestone $m) => self::milestone($m))->values(),
            'atmosphere' => [
                'photo_url' => $project->atmosphere_photo_url,
                'caption' => $project->atmosphere_caption,
                'location' => trim(($umkmProfile?->district ?? '').($umkmProfile?->district && $umkmProfile?->city ? ', ' : '').($umkmProfile?->city ?? 'Surabaya')),
            ],
            'eligibility' => $eligibility,
            'has_applied' => $application !== null,
            'application_status' => $application?->status,
        ];
    }

    public static function milestone(ProjectMilestone $milestone): array
    {
        $latestDeliverable = $milestone->relationLoaded('deliverables')
            ? $milestone->deliverables->first()
            : null;

        return [
            'id' => $milestone->id,
            'project_id' => $milestone->project_id,
            'step_order' => $milestone->step_order,
            'title' => $milestone->title,
            'description' => $milestone->description,
            'reward_tc' => $milestone->reward_tc,
            'status' => $milestone->status,
            'due_date' => $milestone->due_date?->toDateString(),
            'latest_deliverable' => $latestDeliverable ? self::deliverable($latestDeliverable) : null,
        ];
    }

    public static function deliverable(ProjectDeliverable $deliverable): array
    {
        return [
            'id' => $deliverable->id,
            'project_id' => $deliverable->project_id,
            'milestone_id' => $deliverable->milestone_id,
            'submission_format' => $deliverable->submission_format,
            'deliverable_url' => $deliverable->deliverable_url,
            'file_name' => $deliverable->file_name,
            'file_size_label' => $deliverable->file_size_label,
            'submission_notes' => $deliverable->submission_notes,
            'attachment_links' => $deliverable->attachment_links ?? [],
            'revision_count' => $deliverable->revision_count,
            'revision_notes' => $deliverable->revision_notes,
            'recommend_mentor_consultation' => (bool) $deliverable->recommend_mentor_consultation,
            'status' => $deliverable->status,
            'submitted_at' => $deliverable->submitted_at?->toIso8601String(),
        ];
    }

    public static function application(ProjectApplication $application): array
    {
        return [
            'id' => $application->id,
            'project_id' => $application->project_id,
            'status' => $application->status,
            'cover_letter' => $application->cover_letter,
            'portfolio_link' => $application->portfolio_link,
            'has_mentor_endorsement_snapshot' => (bool) $application->has_mentor_endorsement_snapshot,
            'timeline_commitment' => $application->timeline_commitment,
            'dedication_hours' => $application->dedication_hours,
            'rejection_feedback' => $application->rejection_feedback,
            'applied_at' => $application->applied_at?->toIso8601String(),
            'project' => $application->relationLoaded('project') && $application->project
                ? self::projectCard($application->project)
                : null,
        ];
    }

    public static function task(ProjectTask $task): array
    {
        return [
            'id' => $task->id,
            'project_id' => $task->project_id,
            'milestone_id' => $task->milestone_id,
            'title' => $task->title,
            'tag' => $task->tag,
            'status' => $task->status,
            'deadline_label' => $task->deadline_label ?? $task->due_date?->translatedFormat('d M'),
            'due_date' => $task->due_date?->toDateString(),
            'sort_order' => $task->sort_order,
        ];
    }

    public static function message(ProjectMessage $message): array
    {
        return [
            'id' => $message->id,
            'project_id' => $message->project_id,
            'sender_id' => $message->sender_id,
            'sender_name' => $message->relationLoaded('sender') ? $message->sender?->name : null,
            'message' => $message->message,
            'attachment_url' => $message->attachment_url,
            'attachment_name' => $message->attachment_name,
            'created_at' => $message->created_at?->toIso8601String(),
        ];
    }
}

