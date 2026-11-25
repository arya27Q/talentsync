<?php

namespace Tests\Feature;

use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectMilestone;
use App\Models\Review;
use App\Models\Role;
use App\Models\StudentCertificate;
use App\Models\StudentProfile;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class Stage4SubmissionEscrowTest extends TestCase
{
    use RefreshDatabase;

    private function createMsmeAndStudent(): array
    {
        $msmeRole = Role::firstOrCreate(['name' => 'msme'], ['description' => 'Mitra UMKM']);
        $studentRole = Role::firstOrCreate(['name' => 'student'], ['description' => 'Mahasiswa']);

        $msme = User::create([
            'name' => 'Bu Sari',
            'email' => 'sari.stage4@umkm.test',
            'password' => 'password123',
            'role_id' => $msmeRole->id,
        ]);
        $msme->roles()->syncWithoutDetaching([$msmeRole->id]);
        UmkmProfile::create([
            'user_id' => $msme->id,
            'business_name' => 'Kopi Sari Nusantara',
            'business_sector' => 'F&B',
            'address' => 'Jl. Ketintang 9',
            'city' => 'Surabaya',
            'is_verified' => true,
        ]);
        TimeCoinWallet::create(['user_id' => $msme->id, 'balance' => 100, 'locked_balance' => 0]);

        $student = User::create([
            'name' => 'Bima Mahasiswa',
            'email' => 'bima.stage4@mhs.unesa.ac.id',
            'password' => 'password123',
            'role_id' => $studentRole->id,
        ]);
        $student->roles()->syncWithoutDetaching([$studentRole->id]);
        StudentProfile::create([
            'user_id' => $student->id,
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'S1 Sistem Informasi',
            'student_id_number' => '24051214901',
            'ktm_verification_status' => 'approved',
        ]);
        TimeCoinWallet::create(['user_id' => $student->id, 'balance' => 0, 'locked_balance' => 0]);

        Portfolio::create([
            'student_id' => $student->id,
            'title' => 'Portofolio Awal',
            'category' => 'UI/UX',
            'client_name' => 'Toko Awal',
            'is_verified' => true,
        ]);

        return [$msme, $student];
    }

    public function test_full_stage4_revision_approval_escrow_release_and_project_completion(): void
    {
        [$msme, $student] = $this->createMsmeAndStudent();

        // 1. MSME creates a 100 TC project (auto-splits into 3 milestones: 30, 40, 30 TC)
        $projectRes = $this->actingAs($msme, 'sanctum')
            ->postJson('/api/msme/projects', [
                'title' => 'Aplikasi Kasir Kopi Sari',
                'category' => 'Mobile Dev',
                'reward_tc' => 100,
                'description' => 'Membuat aplikasi kasir Android dengan cetak struk.',
                'deliverables_checklist' => ['Desain UI', 'APK Rilis', 'Panduan'],
            ])
            ->assertCreated();

        $projectId = (int) $projectRes->json('data.id');
        $milestones = ProjectMilestone::where('project_id', $projectId)->orderBy('step_order')->get();
        $this->assertCount(3, $milestones);

        // 2. Student applies & MSME accepts
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$projectId}/apply", [
                'cover_letter' => 'Siap mengerjakan aplikasi kasir dengan Flutter sesuai timeline.',
                'commitment_accepted' => true,
            ])
            ->assertCreated();

        $appId = (int) Project::findOrFail($projectId)->applications()->firstOrFail()->id;
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$appId}/accept")
            ->assertOk()
            ->assertJsonPath('data.escrow_locked_tc', 100)
            ->assertJsonPath('data.balance_tc', 0)
            ->assertJsonPath('data.locked_balance_tc', 100);

        $this->assertSame(0, TimeCoinWallet::where('user_id', $msme->id)->value('balance'));
        $this->assertSame(100, TimeCoinWallet::where('user_id', $msme->id)->value('locked_balance'));

        // Fresh MSME dashboard before any submission should show 0 pending_submissions_count
        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/dashboard')
            ->assertOk()
            ->assertJsonPath('data.pending_submissions_count', 0)
            ->assertJsonPath('data.pending_submission_preview', null);

        // 3. Student submits Milestone 1 (30 TC)
        $m1 = $milestones[0];
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/milestones/{$m1->id}/submissions", [
                'submission_format' => 'link',
                'deliverable_url' => 'https://figma.com/file/kasir-stage1',
                'submission_notes' => 'Draft riset dan wireframe tahap 1 selesai.',
            ])
            ->assertCreated();

        // MSME Dashboard & Submissions endpoint immediately reflect 1 pending submission
        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/dashboard')
            ->assertOk()
            ->assertJsonPath('data.pending_submissions_count', 1)
            ->assertJsonPath('data.pending_submission_preview.student_name', 'Bima Mahasiswa');

        $this->actingAs($msme, 'sanctum')
            ->getJson("/api/msme/submissions?project_id={$projectId}&status=submitted")
            ->assertOk()
            ->assertJsonPath('data.counts.submitted', 1)
            ->assertJsonPath('data.items.0.milestone_id', $m1->id)
            ->assertJsonPath('data.items.0.is_final_stage', false);

        // 4. MSME requests revision on Milestone 1 with mentor consultation recommendation
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/milestones/{$m1->id}/revision", [
                'revision_notes' => 'Tolong rapikan alur diskon member dan ukuran tombol kasir.',
                'recommend_mentor_consultation' => true,
            ])
            ->assertOk()
            ->assertJsonPath('data.milestone_status', 'revision_requested')
            ->assertJsonPath('data.recommend_mentor_consultation', true);

        // Student sees revision_requested + revision_notes + recommend_mentor_consultation
        $this->actingAs($student, 'sanctum')
            ->getJson("/api/projects/{$projectId}/milestones")
            ->assertOk()
            ->assertJsonPath('data.milestones.0.status', 'revision_requested')
            ->assertJsonPath('data.milestones.0.latest_deliverable.recommend_mentor_consultation', true);

        // 5. Student re-submits Milestone 1, MSME approves -> +30 TC released & Milestone 2 unlocked
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/milestones/{$m1->id}/submissions", [
                'submission_format' => 'link',
                'deliverable_url' => 'https://figma.com/file/kasir-stage1-v2',
                'submission_notes' => 'Revisi tombol kasir dan alur diskon selesai.',
            ])
            ->assertCreated();

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/milestones/{$m1->id}/approve")
            ->assertOk()
            ->assertJsonPath('data.is_project_completed', false)
            ->assertJsonPath('data.reward_tc', 30)
            ->assertJsonPath('data.student_balance_tc', 30)
            ->assertJsonPath('data.msme_balance_tc', 0);

        $this->assertSame(70, (int) TimeCoinWallet::where('user_id', $msme->id)->value('locked_balance'));

        // Double approval must be blocked with 409
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/milestones/{$m1->id}/approve")
            ->assertStatus(409);

        // Milestone 2 is now open -> submit & approve (+40 TC)
        $m2 = $milestones[1];
        $this->assertSame('open', $m2->fresh()->status);
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/milestones/{$m2->id}/submissions", [
                'submission_format' => 'link',
                'deliverable_url' => 'https://github.com/bima/kasir-mvp',
                'submission_notes' => 'Deliverable utama MVP kasir selesai.',
            ])
            ->assertCreated();

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/milestones/{$m2->id}/approve")
            ->assertOk()
            ->assertJsonPath('data.is_project_completed', false)
            ->assertJsonPath('data.student_balance_tc', 70)
            ->assertJsonPath('data.msme_balance_tc', 0);

        $this->assertSame(30, (int) TimeCoinWallet::where('user_id', $msme->id)->value('locked_balance'));

        // 6. Final Milestone 3 (30 TC) -> submit -> verify is_final_stage=true -> approve with 5-star review
        $m3 = $milestones[2];
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/milestones/{$m3->id}/submissions", [
                'submission_format' => 'link',
                'deliverable_url' => 'https://github.com/bima/kasir-final',
                'submission_notes' => 'Final APK dan dokumentasi siap dipakai.',
            ])
            ->assertCreated();

        $this->actingAs($msme, 'sanctum')
            ->getJson("/api/msme/submissions?project_id={$projectId}&status=submitted")
            ->assertOk()
            ->assertJsonPath('data.items.0.is_final_stage', true);

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/milestones/{$m3->id}/approve", [
                'rating' => 5,
                'review_text' => 'Aplikasi kasir sangat cepat, rapi, dan langsung dipakai di toko kami!',
            ])
            ->assertOk()
            ->assertJsonPath('data.is_project_completed', true)
            ->assertJsonPath('data.project_status', 'completed')
            ->assertJsonPath('data.student_balance_tc', 100)
            ->assertJsonPath('data.msme_balance_tc', 0)
            ->assertJsonPath('data.portfolio_created', true);

        $this->assertSame(0, (int) TimeCoinWallet::where('user_id', $msme->id)->value('locked_balance'));

        // Verify DB side-effects: Portfolio, Certificate, Review, StudentProfile metrics, Ledger transactions
        $this->assertTrue(Portfolio::where('student_id', $student->id)->where('project_id', $projectId)->where('is_verified', true)->exists());
        $this->assertTrue(StudentCertificate::where('student_id', $student->id)->where('reference_id', $projectId)->exists());
        $this->assertTrue(Review::where('reviewer_id', $msme->id)->where('reviewee_id', $student->id)->where('project_id', $projectId)->exists());
        $this->assertSame(2, (int) StudentProfile::where('user_id', $student->id)->value('completed_projects_count'));
        $this->assertSame(5.0, (float) StudentProfile::where('user_id', $student->id)->value('rating_average'));
        $this->assertSame(3, TimeCoinTransaction::where('recipient_id', $student->id)->where('transaction_type', 'project_reward')->where('direction', 'credit')->count());

        // Student reviews MSME -> MSME profile rating updates live from 0 to 5
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$projectId}/review-client", [
                'rating' => 5,
                'review_text' => 'Mitra sangat komunikatif dan cepat validasi.',
            ])
            ->assertCreated();

        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/profile')
            ->assertOk()
            ->assertJsonPath('data.completed_projects_count', 1)
            ->assertJsonPath('data.rating', 5)
            ->assertJsonPath('data.mentored_students_count', 1);
    }
}
