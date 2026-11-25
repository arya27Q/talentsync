<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\Role;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class Stage5MsmeFinanceTest extends TestCase
{
    use RefreshDatabase;

    private function createMsme(): User
    {
        $role = Role::firstOrCreate(['name' => 'msme']);
        $user = User::factory()->create(['role_id' => $role->id]);
        $user->roles()->syncWithoutDetaching([$role->id]);

        UmkmProfile::create([
            'user_id' => $user->id,
            'business_name' => 'Kopi Kenangan Unesa',
            'business_sector' => 'F&B',
            'address' => 'Jl. Ketintang No. 12, Surabaya',
            'city' => 'Surabaya',
            'is_verified' => true,
            'is_premium' => false,
            'monthly_quota_tc' => 20,
        ]);

        TimeCoinWallet::create([
            'user_id' => $user->id,
            'balance' => 0,
            'locked_balance' => 0,
        ]);

        return $user;
    }

    private function createStudent(int $initialBalance = 100): User
    {
        $role = Role::firstOrCreate(['name' => 'student']);
        $user = User::factory()->create(['role_id' => $role->id]);
        $user->roles()->syncWithoutDetaching([$role->id]);

        TimeCoinWallet::create([
            'user_id' => $user->id,
            'balance' => $initialBalance,
            'locked_balance' => 0,
        ]);

        return $user;
    }

    public function test_msme_barter_voucher_credits_wallet_publishes_to_student_rewards_and_tracks_redemption(): void
    {
        Storage::fake('public');
        $msme = $this->createMsme();
        $student = $this->createStudent(100);

        $barterRes = $this->actingAs($msme, 'sanctum')->post('/api/msme/barters', [
            'voucher_type' => 'free_product',
            'title' => 'Gratis 1 Es Kopi Susu',
            'quantity' => 5,
            'value_idr' => 15000,
            'validity_days' => 60,
            'is_guaranteed' => '1',
            'design_file' => UploadedFile::fake()->image('voucher.png', 400, 400),
        ], ['Accept' => 'application/json']);

        $barterRes->assertCreated()
            ->assertJsonPath('data.balance_tc', 75)
            ->assertJsonPath('data.barter.total_tc', 75)
            ->assertJsonPath('data.barter.tc_per_voucher', 15)
            ->assertJsonPath('data.barter.quantity', 5)
            ->assertJsonPath('data.barter.redeemed_count', 0);

        $rewardId = $barterRes->json('data.barter.reward_id');
        $this->assertNotNull($rewardId);

        // Student sees the bartered voucher in Katalog Hadiah and redeems 1 unit
        $this->actingAs($student, 'sanctum')
            ->getJson('/api/wallet/rewards')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $rewardId,
                'title' => 'Gratis 1 Es Kopi Susu',
                'provider' => 'Kopi Kenangan Unesa',
                'tc_price' => 15,
            ]);

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/wallet/rewards/{$rewardId}/redeem")
            ->assertCreated();

        // MSME barter history reflects 1/5 redeemed live
        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/barters')
            ->assertOk()
            ->assertJsonPath('data.balance_tc', 75)
            ->assertJsonPath('data.barters.0.redeemed_count', 1)
            ->assertJsonPath('data.barters.0.remaining_stock', 4);
    }

    public function test_msme_top_up_applies_5_percent_fee_for_free_and_0_percent_after_partner_pro_upgrade(): void
    {
        $msme = $this->createMsme();

        // 1. Top-up on Free plan -> 5% admin fee
        $freeTopUp = $this->actingAs($msme, 'sanctum')->postJson('/api/msme/top-up', [
            'amount_tc' => 100,
            'payment_channel' => 'qris_sandbox',
        ]);

        $freeTopUp->assertCreated()
            ->assertJsonPath('data.amount_tc', 100)
            ->assertJsonPath('data.base_idr', 100000)
            ->assertJsonPath('data.admin_fee_percent', 5)
            ->assertJsonPath('data.admin_fee_idr', 5000)
            ->assertJsonPath('data.total_payable_idr', 105000)
            ->assertJsonPath('data.balance_tc', 100)
            ->assertJsonPath('data.is_premium', false);

        // 2. Free MSME can create up to 2 active projects, 3rd is blocked (422)
        for ($i = 1; $i <= 2; $i++) {
            $this->actingAs($msme, 'sanctum')->postJson('/api/msme/projects', [
                'title' => "Proyek Gratis #{$i}",
                'category' => 'Desain & Grafis',
                'reward_tc' => 30,
                'description' => 'Deskripsi proyek uji slot gratis.',
            ])->assertCreated();
        }

        $this->actingAs($msme, 'sanctum')->postJson('/api/msme/projects', [
            'title' => 'Proyek Ke-3 Sebelum Pro',
            'category' => 'Desain & Grafis',
            'reward_tc' => 30,
            'description' => 'Harus ditolak karena slot paket gratis maksimal 2.',
        ])->assertStatus(422);

        // 3. Upgrade to Partner Pro (yearly)
        $subRes = $this->actingAs($msme, 'sanctum')->postJson('/api/msme/subscription', [
            'plan_type' => 'yearly',
            'payment_channel' => 'va_bca',
        ]);

        $subRes->assertCreated()
            ->assertJsonPath('data.is_premium', true)
            ->assertJsonPath('data.slots_max', 10)
            ->assertJsonPath('data.admin_fee_percent', 0)
            ->assertJsonPath('data.monthly_quota_tc', 500)
            ->assertJsonPath('data.active_subscription.plan_type', 'yearly')
            ->assertJsonPath('data.active_subscription.price_idr', 490000);

        // 4. Dashboard reflects Partner Pro, 0% admin, 2/10 slots
        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/dashboard')
            ->assertOk()
            ->assertJsonPath('data.is_premium', true)
            ->assertJsonPath('data.active_slots_used', 2)
            ->assertJsonPath('data.active_slots_max', 10)
            ->assertJsonPath('data.admin_fee_percent', 0);

        // 5. 3rd project is now unlocked!
        $this->actingAs($msme, 'sanctum')->postJson('/api/msme/projects', [
            'title' => 'Proyek Ke-3 Partner Pro',
            'category' => 'Desain & Grafis',
            'reward_tc' => 30,
            'description' => 'Berhasil dibuka setelah upgrade Partner Pro.',
        ])->assertCreated();

        // 6. Top-up on Partner Pro -> 0% admin fee!
        $proTopUp = $this->actingAs($msme, 'sanctum')->postJson('/api/msme/top-up', [
            'amount_tc' => 200,
            'payment_channel' => 'gopay',
        ]);

        $proTopUp->assertCreated()
            ->assertJsonPath('data.admin_fee_percent', 0)
            ->assertJsonPath('data.admin_fee_idr', 0)
            ->assertJsonPath('data.total_payable_idr', 200000)
            ->assertJsonPath('data.balance_tc', 300);

        // 7. Transactions history contains both top-ups
        $txRes = $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/transactions')
            ->assertOk()
            ->assertJsonPath('data.balance_tc', 300)
            ->assertJsonPath('data.total_income_tc', 300)
            ->assertJsonPath('data.is_premium', true);

        $this->assertCount(2, $txRes->json('data.transactions'));
    }

    public function test_accept_applicant_blocks_when_msme_balance_insufficient_and_locks_escrow_after_top_up(): void
    {
        $msme = $this->createMsme(); // starts with 0 TC
        $student = $this->createStudent(0);

        $projectRes = $this->actingAs($msme, 'sanctum')->postJson('/api/msme/projects', [
            'title' => 'Desain Kemasan Produk Kopi',
            'category' => 'Desain & Grafis',
            'reward_tc' => 80,
            'description' => 'Desain kemasan standing pouch 250g.',
        ])->assertCreated();

        $projectId = (int) $projectRes->json('data.id');
        $application = ProjectApplication::create([
            'project_id' => $projectId,
            'student_id' => $student->id,
            'cover_letter' => 'Siap membuat desain kemasan sesuai brief.',
            'status' => 'pending',
            'applied_at' => now(),
        ]);

        // 1. Accept blocked (422) because balance is 0 TC < 80 TC
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$application->id}/accept")
            ->assertStatus(422);

        $this->assertSame('pending', $application->fresh()->status);
        $this->assertSame('open', Project::findOrFail($projectId)->status);

        // 2. MSME tops up 100 TC
        $this->actingAs($msme, 'sanctum')->postJson('/api/msme/top-up', [
            'amount_tc' => 100,
            'payment_channel' => 'qris_sandbox',
        ])->assertCreated();

        // 3. Accept now succeeds and locks 80 TC in escrow, leaving 20 TC free balance
        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$application->id}/accept")
            ->assertOk()
            ->assertJsonPath('data.project_status', 'in_progress')
            ->assertJsonPath('data.escrow_locked_tc', 80)
            ->assertJsonPath('data.balance_tc', 20)
            ->assertJsonPath('data.locked_balance_tc', 80);

        $wallet = TimeCoinWallet::where('user_id', $msme->id)->firstOrFail();
        $this->assertSame(20, (int) $wallet->balance);
        $this->assertSame(80, (int) $wallet->locked_balance);
    }
}
