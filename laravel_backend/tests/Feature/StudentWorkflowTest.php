<?php

namespace Tests\Feature;

use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\MentorProfile;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectMilestone;
use App\Models\Reward;
use App\Models\Role;
use App\Models\StudentProfile;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use Database\Seeders\TalentSyncDemoSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class StudentWorkflowTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_can_register_with_ktm_file_and_login_using_nim_or_email(): void
    {
        Storage::fake('public');
        $ktm = UploadedFile::fake()->image('ktm.jpg', 600, 400);

        $register = $this->post('/api/auth/register', [
            'name' => 'Andika Octavianto',
            'email' => 'andika@mhs.unesa.ac.id',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'student',
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'S1 Sistem Informasi',
            'student_id_number' => '24051214026',
            'ktm_file' => $ktm,
        ], ['Accept' => 'application/json'])->assertCreated();

        $this->assertNotEmpty($register->json('data.user.student_id_number'));
        Storage::disk('public')->assertExists('student-ktms/'.$ktm->hashName());

        // Login with NIM
        $this->postJson('/api/auth/login', [
            'identifier' => '24051214026',
            'password' => 'password123',
        ])->assertOk()->assertJsonPath('data.user.role', 'student');

        // Login with email
        $this->postJson('/api/auth/login', [
            'email' => 'andika@mhs.unesa.ac.id',
            'password' => 'password123',
        ])->assertOk()->assertJsonPath('data.user.name', 'Andika Octavianto');
    }

    public function test_project_application_enforces_verified_portfolio_or_mentor_endorsement_rule(): void
    {
        $student = $this->makeStudent('24051214099');
        $msme = $this->makeMsme('Toko Uji');
        $openProject = Project::create([
            'msme_id' => $msme->id,
            'code' => 'PRJ-ELIG-1',
            'title' => 'Aplikasi Kasir',
            'category' => 'Mobile',
            'description' => 'Butuh aplikasi kasir Flutter sederhana.',
            'reward_tc' => 150,
            'deadline' => now()->addDays(10)->toDateString(),
            'requires_endorsement' => false,
            'status' => 'open',
        ]);
        $endorsedOnlyProject = Project::create([
            'msme_id' => $msme->id,
            'code' => 'PRJ-ELIG-2',
            'title' => 'Sistem Enterprise UMKM',
            'category' => 'Backend',
            'description' => 'Wajib punya badge mentor.',
            'reward_tc' => 300,
            'deadline' => now()->addDays(15)->toDateString(),
            'requires_endorsement' => true,
            'status' => 'open',
        ]);

        // Without portfolio and without endorsement -> blocked (403)
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$openProject->id}/apply", [
                'cover_letter' => 'Saya berminat mengerjakan proyek ini dengan sungguh-sungguh.',
                'commitment_accepted' => true,
            ])
            ->assertForbidden();

        // Add verified portfolio -> open project allowed, endorsed-only still blocked!
        $portfolio = Portfolio::create([
            'student_id' => $student->id,
            'title' => 'Aplikasi Inventaris',
            'category' => 'Mobile',
            'is_verified' => true,
        ]);

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$openProject->id}/apply", [
                'cover_letter' => 'Saya sudah punya portofolio terverifikasi.',
                'portfolio_ids' => [$portfolio->id],
                'commitment_accepted' => true,
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'pending');

        // Duplicate apply blocked with 409
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$openProject->id}/apply", [
                'cover_letter' => 'Lamaran kedua harus ditolak.',
                'commitment_accepted' => true,
            ])
            ->assertConflict();

        // Project requiring mentor endorsement stays blocked until endorsement exists
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$endorsedOnlyProject->id}/apply", [
                'cover_letter' => 'Ingin melamar proyek khusus rekomendasi mentor.',
                'commitment_accepted' => true,
            ])
            ->assertForbidden();

        $mentor = $this->makeMentor();
        $class = MentoringClass::create([
            'mentor_id' => $mentor->id,
            'topic' => 'Backend Laravel',
            'scheduled_time' => now()->subDay(),
            'price_tc' => 20,
        ]);
        MentoringEnrollment::create([
            'class_id' => $class->id,
            'student_id' => $student->id,
            'paid_tc' => 20,
            'status' => 'completed',
            'assessment_score' => 90,
            'has_endorsement' => true,
            'endorsement_notes' => 'Sangat kompeten.',
        ]);

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$endorsedOnlyProject->id}/apply", [
                'cover_letter' => 'Sekarang sudah punya Badge Rekomendasi Kerja dari mentor.',
                'commitment_accepted' => true,
            ])
            ->assertCreated();
    }

    public function test_kanban_tasks_milestone_submission_and_wallet_operations_work_end_to_end(): void
    {
        $this->seed(TalentSyncDemoSeeder::class);
        $student = User::where('email', 'arya@mhs.unesa.ac.id')->firstOrFail();
        $activeProject = Project::where('code', 'PRJ-A188')->firstOrFail();
        $openMilestone = ProjectMilestone::where('project_id', $activeProject->id)
            ->where('status', 'open')
            ->firstOrFail();

        // Dashboard loads complete summary
        $this->actingAs($student, 'sanctum')
            ->getJson('/api/student/dashboard')
            ->assertOk()
            ->assertJsonPath('data.wallet.balance_tc', 150)
            ->assertJsonStructure(['data' => ['user', 'wallet', 'active_projects', 'recommended_projects']]);

        // Kanban CRUD
        $createdTask = $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$activeProject->id}/tasks", [
                'title' => 'Buat modal konfirmasi struk',
                'tag' => 'UI',
            ])
            ->assertCreated();
        $taskId = $createdTask->json('data.id');

        $this->actingAs($student, 'sanctum')
            ->patchJson("/api/tasks/{$taskId}", ['status' => 'done'])
            ->assertOk()
            ->assertJsonPath('data.status', 'done');

        // Milestone deliverable submission
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/milestones/{$openMilestone->id}/submissions", [
                'submission_format' => 'link',
                'deliverable_url' => 'https://github.com/aryapratama/kasir/pull/1',
                'submission_notes' => 'Fitur stok selesai diuji.',
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'submitted');

        $this->assertSame('submitted', $openMilestone->fresh()->status);

        // Wallet Top-Up + P2P Transfer + Reward Redeem
        $otherStudent = $this->makeStudent('24051214055', 'rekan@mhs.unesa.ac.id');

        $this->actingAs($student, 'sanctum')
            ->postJson('/api/wallet/top-up', ['amount_tc' => 50, 'payment_channel' => 'qris_sandbox'])
            ->assertCreated()
            ->assertJsonPath('data.balance_tc', 200);

        $this->actingAs($student, 'sanctum')
            ->postJson('/api/wallet/transfer', ['recipient_identifier' => '24051214055', 'amount_tc' => 25])
            ->assertCreated()
            ->assertJsonPath('data.sender_balance_tc', 175);

        $this->assertSame(125, TimeCoinWallet::where('user_id', $otherStudent->id)->value('balance'));

        $reward = Reward::firstOrFail();
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/wallet/rewards/{$reward->id}/redeem")
            ->assertCreated()
            ->assertJsonStructure(['data' => ['balance_tc', 'voucher' => ['voucher_code', 'qr_payload']]]);
    }

    public function test_switch_to_mentor_enforces_five_completed_projects_and_switches_roles_cleanly(): void
    {
        $newStudent = $this->makeStudent('24051214088', 'baru@mhs.unesa.ac.id');
        $this->actingAs($newStudent, 'sanctum')
            ->getJson('/api/student/mentor-eligibility')
            ->assertOk()
            ->assertJsonPath('data.is_eligible', false);

        $this->actingAs($newStudent, 'sanctum')
            ->postJson('/api/student/switch-to-mentor', ['teaching_skills' => ['Flutter']])
            ->assertForbidden();

        $this->seed(TalentSyncDemoSeeder::class);
        $eligibleStudent = User::where('email', 'arya@mhs.unesa.ac.id')->firstOrFail();

        $this->actingAs($eligibleStudent, 'sanctum')
            ->getJson('/api/student/mentor-eligibility')
            ->assertOk()
            ->assertJsonPath('data.is_eligible', true);

        $this->actingAs($eligibleStudent, 'sanctum')
            ->postJson('/api/student/switch-to-mentor', [
                'teaching_skills' => ['Flutter', 'Laravel'],
                'title_headline' => 'Peer Mentor Flutter & Backend',
                'hourly_rate_tc' => 30,
            ])
            ->assertOk()
            ->assertJsonPath('data.active_role', 'mentor');

        // Can access mentor dashboard now and switch back to student anytime
        $this->actingAs($eligibleStudent->fresh(), 'sanctum')
            ->getJson('/api/mentoring/mentor/dashboard')
            ->assertOk();

        $this->actingAs($eligibleStudent->fresh(), 'sanctum')
            ->postJson('/api/auth/switch-role', ['role' => 'student'])
            ->assertOk()
            ->assertJsonPath('data.user.role', 'student');
    }

    public function test_student_can_update_profile_pin_github_and_safely_delete_idle_account(): void
    {
        $student = $this->makeStudent('24051214077', 'delete@mhs.unesa.ac.id');

        $this->actingAs($student, 'sanctum')
            ->putJson('/api/student/profile', [
                'name' => 'Mahasiswa Updated',
                'headline' => 'Backend Developer',
                'skills' => ['Laravel', 'PostgreSQL'],
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'Mahasiswa Updated');

        $this->actingAs($student, 'sanctum')
            ->putJson('/api/student/security/pin', ['pin' => '123456'])
            ->assertOk()
            ->assertJsonPath('data.has_transaction_pin', true);

        $this->actingAs($student, 'sanctum')
            ->postJson('/api/student/portfolio/github/sync', ['github_username' => 'mhsdev'])
            ->assertOk()
            ->assertJsonPath('data.username', 'mhsdev');

        $this->actingAs($student, 'sanctum')
            ->deleteJson('/api/student/account')
            ->assertOk();

        $this->assertDatabaseHas('users', [
            'id' => $student->id,
            'name' => 'Akun Mahasiswa Terhapus',
        ]);
    }

    public function test_student_explore_inbox_notifications_mentoring_catalog_portfolio_and_disputes_endpoints(): void
    {
        $this->seed(TalentSyncDemoSeeder::class);
        $student = User::where('email', 'arya@mhs.unesa.ac.id')->firstOrFail();

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/projects?search=Kemasan')
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $openProject = Project::where('code', 'PRJ-OPEN-01')->firstOrFail();
        $this->actingAs($student, 'sanctum')
            ->getJson("/api/projects/{$openProject->id}")
            ->assertOk()
            ->assertJsonPath('data.eligibility.can_apply', true);

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$openProject->id}/bookmark")
            ->assertOk()
            ->assertJsonPath('data.is_bookmarked', true);

        $activeProject = Project::where('code', 'PRJ-A188')->firstOrFail();
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$activeProject->id}/messages", [
                'message' => 'Siap Bu Sri, tombol cepat sudah ditambahkan.',
            ])
            ->assertCreated();

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/inbox')
            ->assertOk()
            ->assertJsonStructure(['data' => [['thread_id', 'thread_type', 'reference_id', 'partner_name']]]);

        $notifications = $this->actingAs($student, 'sanctum')
            ->getJson('/api/notifications')
            ->assertOk();
        $firstNotifId = $notifications->json('data.0.id');
        $this->actingAs($student, 'sanctum')
            ->patchJson("/api/notifications/{$firstNotifId}/read")
            ->assertOk()
            ->assertJsonPath('data.is_read', true);

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/mentoring/mentors')
            ->assertOk()
            ->assertJsonStructure(['data' => [['id', 'name', 'nearest_class']]]);

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/mentoring/student/mentors')
            ->assertOk()
            ->assertJsonStructure(['data' => ['summary', 'mentors']]);

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/student/portfolio')
            ->assertOk()
            ->assertJsonStructure(['data' => ['profile', 'radar_metrics', 'verified_projects']]);

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/student/certificates')
            ->assertOk()
            ->assertJsonStructure(['data' => ['certificates']]);

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/wallet/transactions')
            ->assertOk();

        $this->actingAs($student, 'sanctum')
            ->postJson('/api/disputes', [
                'reference_type' => 'project',
                'reference_id' => $activeProject->id,
                'category' => 'milestone_review',
                'description' => 'Butuh peninjauan milestone karena mitra belum merespons 5 hari.',
            ])
            ->assertCreated();
    }

    private function makeStudent(string $nim, ?string $email = null): User
    {
        $roleId = Role::where('name', 'student')->value('id');
        $user = User::factory()->create(['role_id' => $roleId, 'email' => $email ?? "mhs-{$nim}@unesa.ac.id"]);
        $user->roles()->syncWithoutDetaching([$roleId]);
        StudentProfile::create([
            'user_id' => $user->id,
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'Sistem Informasi',
            'student_id_number' => $nim,
            'ktm_verification_status' => 'approved',
        ]);
        TimeCoinWallet::create(['user_id' => $user->id, 'balance' => 100]);

        return $user;
    }

    private function makeMsme(string $businessName): User
    {
        $roleId = Role::where('name', 'msme')->value('id');
        $user = User::factory()->create(['role_id' => $roleId]);
        $user->roles()->syncWithoutDetaching([$roleId]);
        UmkmProfile::create([
            'user_id' => $user->id,
            'business_name' => $businessName,
            'business_sector' => 'Kuliner',
            'address' => 'Surabaya',
        ]);
        TimeCoinWallet::create(['user_id' => $user->id, 'balance' => 500]);

        return $user;
    }

    private function makeMentor(): User
    {
        $roleId = Role::where('name', 'mentor')->value('id');
        $user = User::factory()->create(['role_id' => $roleId]);
        $user->roles()->syncWithoutDetaching([$roleId]);
        MentorProfile::create(['user_id' => $user->id, 'verification_status' => 'approved']);
        TimeCoinWallet::create(['user_id' => $user->id]);

        return $user;
    }
}
