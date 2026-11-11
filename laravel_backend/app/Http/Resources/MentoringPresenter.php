<?php

namespace App\Http\Resources;

use App\Models\MentorProfile;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;

final class MentoringPresenter
{
    public static function mentorProfile(MentorProfile $profile): array
    {
        return [
            'user_id' => $profile->user_id,
            'name' => $profile->relationLoaded('user') ? $profile->user?->name : null,
            'email' => $profile->relationLoaded('user') ? $profile->user?->email : null,
            'avatar_url' => $profile->avatar_url,
            'title_headline' => $profile->title_headline,
            'bio' => $profile->bio,
            'hourly_rate_tc' => $profile->hourly_rate_tc,
            'is_premium' => self::isPremium($profile),
            'verification_status' => $profile->verification_status,
            'premium_expires_at' => $profile->premium_expires_at,
            'cashout_fee_percent' => self::isPremium($profile) ? 0 : 10,
            'rating_average' => (float) $profile->rating_average,
        ];
    }

    public static function mentoringClass(MentoringClass $class, bool $includeMeetingLink = false): array
    {
        return [
            'id' => $class->id,
            'mentor_id' => $class->mentor_id,
            'mentor_name' => $class->mentor?->name,
            'title_headline' => $class->mentor?->mentorProfile?->title_headline,
            'topic' => $class->topic,
            'description' => $class->description,
            'scheduled_time' => $class->scheduled_time,
            'duration_minutes' => $class->duration_minutes,
            'price_tc' => $class->price_tc,
            'meeting_link' => $includeMeetingLink ? $class->meeting_link : null,
            'capacity' => $class->capacity,
            'enrolled_count' => $class->enrolled_count ?? null,
            'status' => $class->status,
        ];
    }

    public static function enrollment(MentoringEnrollment $enrollment, bool $includeStudent = false): array
    {
        $data = [
            'id' => $enrollment->id,
            'class_id' => $enrollment->class_id,
            'student_id' => $enrollment->student_id,
            'paid_tc' => $enrollment->paid_tc,
            'status' => $enrollment->status,
            'has_endorsement' => $enrollment->has_endorsement,
            'endorsement_notes' => $enrollment->endorsement_notes,
            'assessment_score' => $enrollment->assessment_score,
            'mentor_feedback' => $enrollment->mentor_feedback,
            'student_confirmed_at' => $enrollment->student_confirmed_at,
            'class' => $enrollment->relationLoaded('mentoringClass') ? [
                'id' => $enrollment->mentoringClass->id,
                'topic' => $enrollment->mentoringClass->topic,
                'scheduled_time' => $enrollment->mentoringClass->scheduled_time,
            ] : null,
        ];

        if ($includeStudent && $enrollment->relationLoaded('student')) {
            $data['student'] = [
                'id' => $enrollment->student->id,
                'name' => $enrollment->student->name,
                'email' => $enrollment->student->email,
            ];
        }

        return $data;
    }

    public static function isPremium(?MentorProfile $profile): bool
    {
        return (bool) $profile?->is_premium
            && (! $profile->premium_expires_at || $profile->premium_expires_at->isFuture());
    }
}
