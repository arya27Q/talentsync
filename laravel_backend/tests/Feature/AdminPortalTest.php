<?php

namespace Tests\Feature;

use App\Models\EscrowDispute;
use App\Models\Project;
use App\Models\Role;
use App\Models\StudentProfile;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPortalTest extends TestCase
{
    use RefreshDatabase;

    public function test_non_admin_users_cannot_access_admin_portal_endpoints(): void
    {
        $student = $this->userWithRole('student');

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/admin/dashboard')
            ->assertForbidden();

        $this->actingAs($student, 'sanctum')
            ->getJson('/api/admin/users')
            ->assertForbidden();
    }

    public function test_admin_can_view_dashboard_manage_users_resolve_disputes_and_moderate_projects(): void
    {
        $admin = $this->userWithRole('admin');
        $student = $this->userWithRole('student');
        $msme = $this->userWithRole('msme');
        $mentor = $this->userWithRole('mentor');

        StudentProfile::create([
            'user_id' => $student->id,
            'university' => 'UNESA',
            'major' => 'Sistem Informasi',
            'student_id_number' => '24051214017',
            'ktm_verification_status' => 'pending',
        ]);
        UmkmProfile::create([
            'user_id' => $msme->id,
            'business_name' => 'Toko Uji Admin',
            'business_sector' => 'Kuliner',
            'address' => 'Jl. Ketintang Surabaya',
            'is_verified' => false,
        ]);
        TimeCoinWallet::create(['user_id' => $msme->id, 'balance' => 300, 'locked_balance' => 100]);

        $project = Project::create([
            'code' => 'PRJ-ADM-01',
            'msme_id' => $msme->id,
            'title' => 'Aplikasi Kasir Uji',
            'description' => 'Proyek untuk uji moderasi admin.',
            'category' => 'App Development',
            'reward_tc' => 100,
            'deadline' => now()->addDays(14),
            'duration_label' => '14 Hari',
            'status' => 'open',
        ]);

        $dispute = EscrowDispute::create([
            'reporter_id' => $student->id,
            'reference_type' => Project::class,
            'reference_id' => $project->id,
            'category' => 'Keterlambatan Validasi',
            'description' => 'Mitra UMKM belum menanggapi hasil milestone selama 5 hari.',
            'status' => 'open',
        ]);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/dashboard')
            ->assertOk()
            ->assertJsonPath('data.users.students', 1)
            ->assertJsonPath('data.users.msmes', 1)
            ->assertJsonPath('data.users.mentors', 1)
            ->assertJsonPath('data.economy.total_circulating_tc', 300)
            ->assertJsonPath('data.economy.total_locked_escrow_tc', 100)
            ->assertJsonPath('data.queues.open_disputes', 1);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/users?role=student')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.verification_status', 'pending');

        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/users/{$student->id}/verification", [
                'status' => 'approved',
                'target_role' => 'student',
            ])
            ->assertOk()
            ->assertJsonPath('data.verification_status', 'approved');

        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/disputes/{$dispute->id}", [
                'status' => 'resolved',
                'resolution_notes' => 'Admin telah memediasi kedua pihak dan milestone divalidasi.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'resolved');

        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/projects/{$project->id}/status", [
                'status' => 'cancelled',
                'reason' => 'Deskripsi proyek belum memenuhi standar.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'cancelled');

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/transactions')
            ->assertOk();
    }

    public function test_admin_security_controls_suspend_force_logout_audit_anomalies_and_broadcast(): void
    {
        $admin = $this->userWithRole('admin');
        $student = $this->userWithRole('student');
        $msme = $this->userWithRole('msme');

        // Give student an active Sanctum token
        $student->createToken('android-phone');
        $this->assertSame(1, $student->tokens()->count());

        // 1. Force logout revokes all tokens and logs audit
        $this->actingAs($admin, 'sanctum')
            ->postJson("/api/admin/users/{$student->id}/force-logout")
            ->assertOk()
            ->assertJsonPath('data.revoked_tokens', 1);
        $this->assertSame(0, $student->tokens()->count());

        // 2. Suspend user blocks login and revokes sessions
        $student->createToken('android-phone-2');
        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/users/{$student->id}/suspension", [
                'is_suspended' => true,
                'reason' => 'Indikasi pelanggaran kebijakan escrow.',
            ])
            ->assertOk()
            ->assertJsonPath('data.is_suspended', true);
        $this->assertSame(0, $student->tokens()->count());

        $this->postJson('/api/auth/login', [
            'email' => $student->email,
            'password' => 'password',
        ])->assertStatus(422);

        // 3. Unsuspend user restores access
        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/users/{$student->id}/suspension", [
                'is_suspended' => false,
            ])
            ->assertOk()
            ->assertJsonPath('data.is_suspended', false);

        // 4. Broadcast announcement delivers to active non-admin users
        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/admin/announcements/broadcast', [
                'target_role' => 'all',
                'title' => 'Peringatan Keamanan Escrow',
                'body' => 'Jangan pernah melakukan transaksi di luar ekosistem Smart Escrow TalentSync.',
            ])
            ->assertOk()
            ->assertJsonPath('data.recipients_count', 2);
        $this->assertSame(1, $msme->notifications()->count());

        // 5. Security anomalies & Audit logs endpoints return structured data
        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/security/anomalies')
            ->assertOk()
            ->assertJsonStructure(['data' => ['summary', 'alerts']]);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/audit-logs')
            ->assertOk()
            ->assertJsonPath('meta.total', 4);

        // 6. Admin password confirmation rejects wrong password and accepts valid password
        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/admin/security/confirm-password', ['password' => 'wrong'])
            ->assertStatus(422);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/admin/security/confirm-password', ['password' => 'password'])
            ->assertOk();
    }

    public function test_admin_can_adjust_wallet_moderate_mentoring_manage_rewards_and_export_csv(): void
    {
        $admin = $this->userWithRole('admin');
        $student = $this->userWithRole('student');
        $mentor = $this->userWithRole('mentor');

        TimeCoinWallet::create(['user_id' => $student->id, 'balance' => 50, 'locked_balance' => 0]);

        // 1. Wallet adjustment requires valid admin password
        $this->actingAs($admin, 'sanctum')
            ->postJson("/api/admin/users/{$student->id}/wallet-adjustment", [
                'direction' => 'credit',
                'amount_tc' => 40,
                'reason' => 'Refund darurat sengketa proyek.',
                'admin_password' => 'wrong',
            ])
            ->assertStatus(422);

        $this->actingAs($admin, 'sanctum')
            ->postJson("/api/admin/users/{$student->id}/wallet-adjustment", [
                'direction' => 'credit',
                'amount_tc' => 40,
                'reason' => 'Refund darurat sengketa proyek.',
                'admin_password' => 'password',
            ])
            ->assertOk()
            ->assertJsonPath('data.balance_tc', 90);

        // 2. Mentoring class moderation
        $mentoringClass = \App\Models\MentoringClass::create([
            'mentor_id' => $mentor->id,
            'topic' => 'Kelas Flutter Dasar',
            'description' => 'Belajar layout responsif Flutter.',
            'scheduled_time' => now()->addDays(2),
            'duration_minutes' => 120,
            'duration_label' => '3 Hari',
            'duration_days' => 3,
            'price_tc' => 35,
            'capacity' => 5,
            'status' => 'open',
        ]);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/mentoring-classes')
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/mentoring-classes/{$mentoringClass->id}/status", [
                'status' => 'cancelled',
                'reason' => 'Materi tidak sesuai pedoman.',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'cancelled');

        // 3. Rewards catalog CRUD
        $created = $this->actingAs($admin, 'sanctum')
            ->postJson('/api/admin/rewards', [
                'title' => 'Voucher Kopi Kampus',
                'provider' => 'Kopi Kenangan',
                'description' => 'Potongan Rp25.000 di outlet kampus.',
                'tc_price' => 30,
                'stock' => 25,
            ])
            ->assertCreated();
        $rewardId = $created->json('data.id');

        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/rewards/{$rewardId}", [
                'stock' => 50,
                'is_active' => false,
            ])
            ->assertOk()
            ->assertJsonPath('data.stock', 50)
            ->assertJsonPath('data.is_active', false);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/rewards')
            ->assertOk()
            ->assertJsonCount(1, 'data');

        // 4. CSV exports (users, transactions, audit-logs)
        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/export/transactions')
            ->assertOk()
            ->assertJsonStructure(['data' => ['filename', 'rows_count', 'csv']]);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/export/users')
            ->assertOk();

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/export/audit-logs')
            ->assertOk();
    }

    private function userWithRole(string $role): User
    {
        $roleModel = Role::firstOrCreate(['name' => $role], ['description' => ucfirst($role)]);

        return User::factory()->create([
            'role_id' => $roleModel->id,
        ]);
    }
}
