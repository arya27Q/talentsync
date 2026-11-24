<?php

namespace Tests\Feature;

use App\Models\MentorProfile;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\Role;
use App\Models\StudentProfile;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ApplicationCredentialsAndMsmeInboxTest extends TestCase
{
    use RefreshDatabase;

    private function createRole(string $name): Role
    {
        return Role::firstOrCreate(['name' => $name], ['description' => ucfirst($name)]);
    }

    private function makeStudent(string $name, string $email, string $nim): User
    {
        $role = $this->createRole('student');
        $user = User::factory()->create(['name' => $name, 'email' => $email, 'role_id' => $role->id]);
        $user->roles()->syncWithoutDetaching([$role->id]);
        StudentProfile::create([
            'user_id' => $user->id,
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'S1 Sistem Informasi',
            'student_id_number' => $nim,
            'ktm_verification_status' => 'approved',
            'completed_projects_count' => 0,
            'rating_average' => 0,
        ]);
        TimeCoinWallet::create(['user_id' => $user->id, 'balance' => 0, 'locked_balance' => 0]);

        return $user;
    }

    private function makeMsme(string $name, string $email, string $businessName): User
    {
        $role = $this->createRole('msme');
        $user = User::factory()->create(['name' => $name, 'email' => $email, 'role_id' => $role->id]);
        $user->roles()->syncWithoutDetaching([$role->id]);
        UmkmProfile::create([
            'user_id' => $user->id,
            'business_name' => $businessName,
            'business_sector' => 'Kuliner',
            'address' => 'Jl. Ketintang No. 10, Surabaya',
            'city' => 'Surabaya',
        ]);
        TimeCoinWallet::create(['user_id' => $user->id, 'balance' => 500, 'locked_balance' => 0]);

        return $user;
    }

    private function makeMentor(string $name, string $email): User
    {
        $role = $this->createRole('mentor');
        $user = User::factory()->create(['name' => $name, 'email' => $email, 'role_id' => $role->id]);
        $user->roles()->syncWithoutDetaching([$role->id]);
        MentorProfile::create([
            'user_id' => $user->id,
            'title_headline' => 'Senior Flutter & UI/UX Mentor',
            'bio' => 'Berpengalaman membimbing proyek UMKM.',
            'hourly_rate_tc' => 45,
            'verification_status' => 'approved',
        ]);

        return $user;
    }

    private function makeOpenProject(User $msme): Project
    {
        return Project::create([
            'msme_id' => $msme->id,
            'code' => 'PRJ-TEST-'.rand(100, 999),
            'title' => 'Aplikasi Katalog Kopi Senja',
            'category' => 'Mobile',
            'description' => 'Membuat katalog menu digital untuk kedai kopi.',
            'reward_tc' => 150,
            'deadline' => now()->addDays(14),
            'duration_label' => '2 Minggu',
            'status' => 'open',
            'requires_endorsement' => false,
        ]);
    }

    public function test_fresh_student_can_apply_with_linkedin_and_cv_upload_and_msme_rejection_sends_evaluation_and_locks_chat(): void
    {
        Storage::fake('public');

        $msme = $this->makeMsme('Bu Sari', 'sari@umkm.test', 'Kopi Senja');
        $student = $this->makeStudent('Arya Pratama', 'arya@student.test', '24051214017');
        $mentor = $this->makeMentor('Kak Sinta Mentor', 'sinta@mentor.test');
        $project = $this->makeOpenProject($msme);

        // Before applying, student CANNOT open or send chat to MSME (403)
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'message' => 'Halo Bu, boleh tanya dulu sebelum melamar?',
            ])
            ->assertForbidden();

        // Without portfolio, endorsement, or LinkedIn+CV -> still 403
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$project->id}/apply", [
                'cover_letter' => 'Saya siap mengerjakan proyek katalog kopi ini dengan baik.',
                'commitment_accepted' => true,
            ])
            ->assertForbidden();

        // With LinkedIn + uploaded CV PDF + optional GitHub -> 201 Created
        $cvPdf = UploadedFile::fake()->create('CV_Arya_Pratama.pdf', 120, 'application/pdf');
        $applyRes = $this->actingAs($student, 'sanctum')
            ->post("/api/projects/{$project->id}/apply", [
                'cover_letter' => 'Halo Bu Sari, meskipun baru di TalentSync, saya sudah lampirkan LinkedIn, CV, dan GitHub saya.',
                'linkedin_url' => 'https://www.linkedin.com/in/arya-pratama-yudhistira/',
                'cv_file' => $cvPdf,
                'github_url' => 'https://github.com/arya27Q',
                'commitment_accepted' => '1',
            ], ['Accept' => 'application/json'])
            ->assertCreated();

        $applicationId = $applyRes->json('data.id');
        $this->assertNotNull($applicationId);

        // Now that student applied (pending), chat IS allowed
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'message' => 'Halo Bu Sari, saya baru saja melamar proyek katalog kopi.',
            ])
            ->assertCreated();

        // MSME sees real credentials & real 0 completed projects (no fake 3)
        $this->actingAs($msme, 'sanctum')
            ->getJson("/api/msme/applicants/{$applicationId}")
            ->assertOk()
            ->assertJsonPath('data.completed_projects_count', 0)
            ->assertJsonPath('data.linkedin_url', 'https://www.linkedin.com/in/arya-pratama-yudhistira/')
            ->assertJsonPath('data.cv_file_name', 'CV_Arya_Pratama.pdf')
            ->assertJsonPath('data.github_url', 'https://github.com/arya27Q');

        // MSME rejecting WITHOUT mandatory evaluation feedback -> 422 validation error
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$applicationId}/reject-to-mentor", [
                'feedback' => '',
            ])
            ->assertUnprocessable();

        // MSME rejecting WITHOUT choosing a recommended mentor while mentors exist -> 422
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$applicationId}/reject-to-mentor", [
                'feedback' => 'Skill dasarnya bagus, namun perlu bimbingan arsitektur Flutter terlebih dahulu.',
            ])
            ->assertUnprocessable();

        // MSME rejects with mandatory feedback & specific mentor -> saved & posted into chat
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$applicationId}/reject-to-mentor", [
                'feedback' => 'Skill dasarnya bagus, namun perlu bimbingan arsitektur Flutter dulu bersama Kak Sinta.',
                'recommended_mentor_id' => $mentor->id,
            ])
            ->assertOk()
            ->assertJsonPath('data.recommended_mentor.id', $mentor->id)
            ->assertJsonPath('data.recommended_mentor.name', 'Kak Sinta Mentor');

        $this->assertDatabaseHas('project_applications', [
            'id' => $applicationId,
            'status' => 'rejected',
            'recommended_mentor_id' => $mentor->id,
        ]);

        // Student can STILL READ chat history including MSME's evaluation message, with can_send = false
        $threadRes = $this->actingAs($student, 'sanctum')
            ->getJson("/api/projects/{$project->id}/messages")
            ->assertOk()
            ->assertJsonPath('data.can_send', false)
            ->assertJsonPath('data.application_status', 'rejected')
            ->assertJsonCount(2, 'data.messages');

        $lastMsg = $threadRes->json('data.messages.1.message');
        $this->assertStringContainsString('[Evaluasi Lamaran]', $lastMsg);
        $this->assertStringContainsString('Kak Sinta Mentor', $lastMsg);

        // Neither student nor MSME can send new messages once rejected (403)
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'message' => 'Bu tolong terima saya dong.',
            ])
            ->assertForbidden();

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'student_id' => $student->id,
                'message' => 'Pesan susulan setelah ditolak.',
            ])
            ->assertForbidden();

        // Student can REAPPLY to the same open project after rejection (updates rejected -> pending)
        $this->actingAs($student, 'sanctum')
            ->getJson("/api/projects/{$project->id}")
            ->assertOk()
            ->assertJsonPath('data.can_reapply', true);

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$project->id}/apply", [
                'cover_letter' => 'Halo Bu Sari, saya sudah ikut bimbingan mentor dan memperbaiki portofolio saya untuk melamar ulang.',
                'linkedin_url' => 'https://www.linkedin.com/in/arya-pratama-yudhistira/',
                'cv_url' => 'https://drive.google.com/file/d/cv-arya-v2',
                'commitment_accepted' => true,
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'pending');

        // After reapplying (status back to pending), chat unlocks again!
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'message' => 'Halo Bu Sari, saya baru saja mengajukan lamaran ulang setelah bimbingan mentor.',
            ])
            ->assertCreated();
    }

    public function test_msme_inbox_only_shows_applicants_with_isolated_per_student_chat(): void
    {
        $msme = $this->makeMsme('Pak Budi', 'budi@umkm.test', 'Warung Nusantara');
        $studentA = $this->makeStudent('Mahasiswa Satu', 'mhs1@student.test', '24051214001');
        $studentB = $this->makeStudent('Mahasiswa Dua', 'mhs2@student.test', '24051214002');
        $project = $this->makeOpenProject($msme);

        // Both students apply first using LinkedIn + CV URL
        foreach ([$studentA, $studentB] as $idx => $s) {
            $this->actingAs($s, 'sanctum')
                ->postJson("/api/projects/{$project->id}/apply", [
                    'cover_letter' => 'Saya siap berkontribusi mengerjakan proyek Warung Nusantara dengan maksimal.',
                    'linkedin_url' => "https://linkedin.com/in/student-{$idx}",
                    'cv_url' => "https://drive.google.com/file/d/cv-{$idx}",
                    'commitment_accepted' => true,
                ])
                ->assertCreated();
        }

        // Both applicants chat MSME on the same project
        $this->actingAs($studentA, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'message' => 'Halo Pak, apakah proyek ini boleh dikerjakan pakai Flutter?',
            ])
            ->assertCreated();

        $this->actingAs($studentB, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'message' => 'Permisi Pak Budi, estimasi target selesainya kapan ya?',
            ])
            ->assertCreated();

        // MSME dashboard reports 2 unread messages
        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/dashboard')
            ->assertOk()
            ->assertJsonPath('data.unread_messages_count', 2);

        // MSME inbox shows 2 separate student threads with student names & Pelamar badge
        $inboxRes = $this->actingAs($msme, 'sanctum')
            ->getJson('/api/inbox')
            ->assertOk()
            ->assertJsonCount(2, 'data');

        $partnerNames = collect($inboxRes->json('data'))->pluck('partner_name')->all();
        $this->assertContains('Mahasiswa Satu', $partnerNames);
        $this->assertContains('Mahasiswa Dua', $partnerNames);

        // MSME opens thread with Student A -> only sees Student A's message & replies
        $this->actingAs($msme, 'sanctum')
            ->getJson("/api/projects/{$project->id}/messages?student_id={$studentA->id}")
            ->assertOk()
            ->assertJsonPath('data.student.id', $studentA->id)
            ->assertJsonPath('data.can_send', true)
            ->assertJsonCount(1, 'data.messages');

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/projects/{$project->id}/messages", [
                'student_id' => $studentA->id,
                'message' => 'Boleh banget Mas, kita jadwalkan diskusi ya!',
            ])
            ->assertCreated();

        // Student A sees 2 messages; Student B still only sees their own 1 message
        $this->actingAs($studentA, 'sanctum')
            ->getJson("/api/projects/{$project->id}/messages")
            ->assertOk()
            ->assertJsonCount(2, 'data.messages');

        $this->actingAs($studentB, 'sanctum')
            ->getJson("/api/projects/{$project->id}/messages")
            ->assertOk()
            ->assertJsonCount(1, 'data.messages');
    }
}
