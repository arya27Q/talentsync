<?php

namespace App\Services;

use App\Models\BankAccount;
use App\Models\CashOutRequest;
use App\Models\EscrowDispute;
use App\Models\MentoringEnrollment;
use App\Models\MentorProfile;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\Role;
use App\Models\StudentCertificate;
use App\Models\StudentProfile;
use App\Models\StudentSkill;
use App\Models\TimeCoinWallet;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class StudentAccountService
{
    public function __construct(
        private readonly StudentEligibilityService $eligibilityService,
        private readonly NotificationDispatcher $notifications,
    ) {
    }

    public function updateProfile(
        User $user,
        array $data,
        ?UploadedFile $avatarFile = null,
        ?UploadedFile $ktmFile = null,
    ): StudentProfile {
        $profile = StudentProfile::firstOrCreate(
            ['user_id' => $user->id],
            [
                'university' => $data['university'] ?? 'Universitas Negeri Surabaya',
                'major' => $data['major'] ?? 'S1 Sistem Informasi',
                'student_id_number' => $data['student_id_number'] ?? 'NIM-'.$user->id,
                'ktm_verification_status' => 'approved',
            ],
        );

        $newAvatarPath = null;
        $newKtmPath = null;
        $filesToDelete = [];

        if ($avatarFile) {
            $newAvatarPath = $avatarFile->store('student-avatars', 'public');
            $data['avatar_url'] = Storage::disk('public')->url($newAvatarPath);
            if ($old = $this->publicDiskPath($profile->avatar_url)) {
                $filesToDelete[] = $old;
            }
        } elseif (! empty($data['remove_avatar'])) {
            $data['avatar_url'] = null;
            if ($old = $this->publicDiskPath($profile->avatar_url)) {
                $filesToDelete[] = $old;
            }
        }

        if ($ktmFile) {
            $newKtmPath = $ktmFile->store('student-ktms', 'public');
            $data['ktm_document_url'] = Storage::disk('public')->url($newKtmPath);
            $data['ktm_verification_status'] = 'approved';
            if ($old = $this->publicDiskPath($profile->ktm_document_url)) {
                $filesToDelete[] = $old;
            }
        }

        $name = $data['name'] ?? null;
        $skills = $data['skills'] ?? null;
        unset($data['name'], $data['skills'], $data['remove_avatar'], $data['avatar_file'], $data['ktm_file']);

        try {
            DB::transaction(function () use ($user, $profile, $name, $skills, $data) {
                if ($name !== null) {
                    $user->update(['name' => $name]);
                }
                if ($data !== []) {
                    $profile->fill($data)->save();
                }
                if (is_array($skills)) {
                    $this->syncSkills($user, $skills);
                }
            }, 3);
        } catch (\Throwable $e) {
            if ($newAvatarPath !== null) {
                Storage::disk('public')->delete($newAvatarPath);
            }
            if ($newKtmPath !== null) {
                Storage::disk('public')->delete($newKtmPath);
            }
            throw $e;
        }

        foreach ($filesToDelete as $oldPath) {
            Storage::disk('public')->delete($oldPath);
        }

        return $profile->fresh();
    }

    public function syncSkills(User $student, array $skills): void
    {
        $normalized = collect($skills)
            ->map(function ($item) {
                if (is_array($item)) {
                    return [
                        'name' => trim((string) ($item['name'] ?? '')),
                        'proficiency_level' => (string) ($item['proficiency_level'] ?? 'Menengah'),
                        'score' => max(10, min(100, (int) ($item['score'] ?? 75))),
                    ];
                }
                return [
                    'name' => trim((string) $item),
                    'proficiency_level' => 'Menengah',
                    'score' => 75,
                ];
            })
            ->filter(fn (array $row) => $row['name'] !== '')
            ->unique(fn (array $row) => mb_strtolower($row['name']))
            ->values();

        $keepNames = $normalized->pluck('name')->all();
        if ($keepNames === []) {
            StudentSkill::where('student_id', $student->id)->delete();
            return;
        }

        StudentSkill::where('student_id', $student->id)
            ->whereNotIn('name', $keepNames)
            ->delete();

        foreach ($normalized as $skill) {
            $existing = StudentSkill::where('student_id', $student->id)
                ->where('name', $skill['name'])
                ->first();
            if ($existing) {
                $existing->update([
                    'proficiency_level' => $skill['proficiency_level'],
                    'score' => $skill['score'],
                ]);
            } else {
                StudentSkill::create([
                    'student_id' => $student->id,
                    'name' => $skill['name'],
                    'proficiency_level' => $skill['proficiency_level'],
                    'score' => $skill['score'],
                    'is_verified' => false,
                ]);
            }
        }
    }

    public function syncGithub(User $student, string $username): StudentProfile
    {
        $profile = StudentProfile::where('user_id', $student->id)->firstOrFail();
        $cleaned = ltrim(trim($username), '@');
        abort_if($cleaned === '', 422, 'Username GitHub tidak valid.');

        $languages = [
            ['name' => 'Dart', 'percent' => 52],
            ['name' => 'PHP', 'percent' => 31],
            ['name' => 'JavaScript', 'percent' => 17],
        ];

        $profile->update([
            'github_username' => $cleaned,
            'github_connected_at' => $profile->github_connected_at ?? now(),
            'github_repos_count' => max(12, (int) $profile->github_repos_count),
            'github_commits_count' => max(284, (int) $profile->github_commits_count + 4),
            'github_pinned_count' => max(3, (int) $profile->github_pinned_count),
            'github_languages' => $languages,
            'github_last_synced_at' => now(),
        ]);

        return $profile->fresh();
    }

    public function disconnectGithub(User $student): StudentProfile
    {
        $profile = StudentProfile::where('user_id', $student->id)->firstOrFail();
        $profile->update([
            'github_username' => null,
            'github_connected_at' => null,
            'github_repos_count' => 0,
            'github_commits_count' => 0,
            'github_pinned_count' => 0,
            'github_languages' => null,
            'github_last_synced_at' => null,
        ]);

        return $profile->fresh();
    }

    public function switchToMentor(
        User $student,
        array $data,
        ?UploadedFile $externalCertFile = null,
    ): array {
        $eligibility = $this->eligibilityService->mentorSwitchEligibility($student);
        abort_unless(
            $eligibility['is_eligible'] || $eligibility['already_mentor'],
            403,
            'Anda belum memenuhi syarat minimal 5 proyek UMKM selesai dan reputasi baik untuk beralih ke Mode Mentor.',
        );

        $certPath = null;
        $certUrl = null;
        if ($externalCertFile) {
            $certPath = $externalCertFile->store('student-certificates', 'public');
            $certUrl = Storage::disk('public')->url($certPath);
        }

        try {
            $mentorRole = Role::where('name', 'mentor')->firstOrFail();
            $studentRole = Role::where('name', 'student')->firstOrFail();

            DB::transaction(function () use ($student, $mentorRole, $studentRole, $data, $certUrl) {
                $student->roles()->syncWithoutDetaching([$studentRole->id, $mentorRole->id]);

                $studentProfile = StudentProfile::where('user_id', $student->id)->first();
                $headline = trim((string) ($data['title_headline'] ?? ''));
                if ($headline === '') {
                    $skills = $data['teaching_skills'] ?? ['Flutter', 'Mobile Development'];
                    $headline = 'Peer Mentor · '.implode(', ', array_slice($skills, 0, 2));
                }

                $bio = trim((string) ($data['bio'] ?? ($studentProfile?->bio ?? 'Peer Mentor aktif di TalentSync.')));
                $rate = (int) ($data['hourly_rate_tc'] ?? 30);

                MentorProfile::updateOrCreate(
                    ['user_id' => $student->id],
                    [
                        'title_headline' => Str::limit($headline, 150, ''),
                        'bio' => $bio,
                        'avatar_url' => $studentProfile?->avatar_url,
                        'hourly_rate_tc' => max(1, $rate),
                        'portfolio_url' => $data['portfolio_url'] ?? ($studentProfile?->linkedin_url ? 'https://'.$studentProfile->linkedin_url : null),
                        'verification_status' => 'approved',
                        'verification_reviewed_at' => now(),
                    ],
                );

                if ($certUrl !== null) {
                    StudentCertificate::create([
                        'student_id' => $student->id,
                        'source_type' => 'external',
                        'certificate_code' => 'TS-EXT-'.strtoupper(Str::random(6)),
                        'title' => $data['external_certificate_title'] ?? 'Sertifikat Eksternal Mentor',
                        'issuer_name' => $data['external_certificate_issuer'] ?? 'Lembaga Sertifikasi Eksternal',
                        'category_label' => 'Sertifikasi Eksternal',
                        'file_url' => $certUrl,
                        'issued_at' => now(),
                    ]);
                }

                $student->update(['role_id' => $mentorRole->id]);
            }, 3);
        } catch (\Throwable $e) {
            if ($certPath !== null) {
                Storage::disk('public')->delete($certPath);
            }
            throw $e;
        }

        $freshUser = $student->fresh(['roleRecord', 'studentProfile', 'mentorProfile']);
        $this->notifications->send(
            $freshUser,
            'mentor_mode_activated',
            'Mode Mentor Aktif!',
            'Akun Anda kini dapat membimbing mahasiswa junior dan menerbitkan Badge Rekomendasi Kerja.',
            '/dashboard/mentor',
        );

        return [
            'user' => $freshUser,
            'active_role' => 'mentor',
        ];
    }

    public function destroyAccount(User $student): void
    {
        $hasActiveProjects = ProjectApplication::query()
            ->where('student_id', $student->id)
            ->where('status', 'accepted')
            ->whereHas('project', fn ($q) => $q->whereIn('status', ['in_progress', 'review']))
            ->exists();
        abort_if($hasActiveProjects, 409, 'Selesaikan seluruh proyek UMKM yang sedang berjalan sebelum menghapus akun.');

        $hasActiveMentoring = MentoringEnrollment::query()
            ->where('student_id', $student->id)
            ->whereIn('status', ['pending', 'accepted', 'attended', 'pending_confirmation'])
            ->exists();
        abort_if($hasActiveMentoring, 409, 'Selesaikan atau konfirmasi sesi mentoring yang masih aktif terlebih dahulu.');

        $wallet = TimeCoinWallet::where('user_id', $student->id)->first();
        abort_if(($wallet?->locked_balance ?? 0) > 0, 409, 'Masih terdapat saldo TimeCoin yang tertahan di escrow.');

        $hasPendingCashOut = CashOutRequest::where('user_id', $student->id)
            ->where('status', 'pending_transfer')
            ->exists();
        abort_if($hasPendingCashOut, 409, 'Tunggu proses pencairan TimeCoin selesai sebelum menghapus akun.');

        $hasOpenDisputes = EscrowDispute::where('reporter_id', $student->id)
            ->where('status', '!=', 'resolved')
            ->exists();
        abort_if($hasOpenDisputes, 409, 'Selesaikan laporan sengketa escrow terlebih dahulu sebelum menghapus akun.');

        $profile = StudentProfile::where('user_id', $student->id)->first();
        $filesToDelete = array_values(array_filter([
            $this->publicDiskPath($profile?->avatar_url),
            $this->publicDiskPath($profile?->ktm_document_url),
        ]));

        DB::transaction(function () use ($student, $profile) {
            $student->tokens()->delete();
            $student->projectBookmarks()->delete();
            $student->mentorBookmarks()->delete();
            BankAccount::where('user_id', $student->id)->delete();

            if ($profile) {
                $profile->update([
                    'avatar_url' => null,
                    'ktm_document_url' => null,
                    'bio' => null,
                    'linkedin_url' => null,
                    'github_username' => null,
                    'is_public_profile' => false,
                    'is_open_for_projects' => false,
                ]);
            }

            $student->update([
                'name' => 'Akun Mahasiswa Terhapus',
                'email' => "deleted-student-{$student->id}-".Str::lower(Str::random(6)).'@deleted.talentsync.local',
                'password' => Str::random(40),
            ]);
        }, 3);

        foreach ($filesToDelete as $path) {
            Storage::disk('public')->delete($path);
        }
    }

    private function publicDiskPath(?string $url): ?string
    {
        if (! $url) {
            return null;
        }
        $path = parse_url($url, PHP_URL_PATH);
        if (! is_string($path) || ! str_starts_with($path, '/storage/')) {
            return null;
        }
        return substr($path, strlen('/storage/'));
    }
}

