<?php

namespace Tests\Feature;

use App\Models\MentorProfile;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\Role;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MentoringWorkflowTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_and_mentor_registration_reject_missing_credentials(): void
    {
        $this->postJson('/api/auth/login', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email', 'password']);

        $this->postJson('/api/auth/register-mentor', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'name', 'email', 'password', 'title_headline', 'bio',
                'verification_document_url', 'portfolio_url',
            ]);

        $this->postJson('/api/auth/register', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'email', 'password', 'role']);
    }

    public function test_student_and_msme_registration_create_the_correct_role_profiles_and_login_checks_passwords(): void
    {
        $studentResponse = $this->postJson('/api/auth/register', [
            'name' => 'Mahasiswa Baru',
            'email' => 'student@example.test',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'student',
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'Sistem Informasi',
            'student_id_number' => '24051214001',
        ])->assertCreated()->assertJsonPath('data.user.role', 'student');
        $studentId = $studentResponse->json('data.user.id');
        $this->assertDatabaseHas('student_profiles', ['user_id' => $studentId, 'student_id_number' => '24051214001']);

        $msmeResponse = $this->postJson('/api/auth/register', [
            'name' => 'Pemilik Usaha',
            'email' => 'msme@example.test',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'msme',
            'business_name' => 'Toko Contoh',
            'business_sector' => 'Kuliner',
            'address' => 'Surabaya',
        ])->assertCreated()->assertJsonPath('data.user.role', 'msme');
        $this->assertDatabaseHas('umkm_profiles', ['user_id' => $msmeResponse->json('data.user.id'), 'business_name' => 'Toko Contoh']);

        $this->postJson('/api/auth/login', ['email' => 'student@example.test', 'password' => 'wrong-password'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('email');
        $this->postJson('/api/auth/login', ['email' => 'student@example.test', 'password' => 'password123'])
            ->assertOk()
            ->assertJsonPath('data.user.role', 'student');
    }

    public function test_booking_stays_in_escrow_until_student_confirms_and_mentor_can_only_endorse_a_passing_completed_session(): void
    {
        $student = $this->userWithRole('student');
        $mentor = $this->userWithRole('mentor');
        MentorProfile::create(['user_id' => $mentor->id, 'verification_status' => 'approved']);
        $studentWallet = TimeCoinWallet::create(['user_id' => $student->id, 'balance' => 100]);
        $mentorWallet = TimeCoinWallet::create(['user_id' => $mentor->id]);
        $class = MentoringClass::create([
            'mentor_id' => $mentor->id,
            'topic' => 'Review arsitektur',
            'scheduled_time' => now()->addHour(),
            'duration_minutes' => 60,
            'price_tc' => 30,
            'capacity' => 1,
        ]);

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/mentoring/classes/{$class->id}/book")
            ->assertCreated()
            ->assertJsonPath('data.status', 'pending');

        $this->assertSame(70, $studentWallet->fresh()->balance);
        $this->assertSame(30, $studentWallet->fresh()->locked_balance);
        $this->assertSame(0, $mentorWallet->fresh()->balance);

        $enrollment = MentoringEnrollment::firstOrFail();
        $this->actingAs($mentor, 'sanctum')
            ->patchJson("/api/mentoring/enrollments/{$enrollment->id}/decision", ['decision' => 'accepted'])
            ->assertOk();

        $this->travel(2)->hours();
        $this->actingAs($mentor, 'sanctum')
            ->patchJson("/api/mentoring/enrollments/{$enrollment->id}/attendance", ['status' => 'attended'])
            ->assertOk();
        $this->postJson("/api/mentoring/enrollments/{$enrollment->id}/assessment", [
            'score' => 85,
            'mentor_feedback' => 'Kompetensi sesi memenuhi kriteria rekomendasi.',
        ])->assertOk();

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/mentoring/enrollments/{$enrollment->id}/confirm-completion", [
                'rating' => 5,
                'review_text' => 'Sesi sangat membantu.',
            ])
            ->assertOk();

        $this->assertSame(0, $studentWallet->fresh()->locked_balance);
        $this->assertSame(30, $mentorWallet->fresh()->balance);
        $this->assertSame('completed', $enrollment->fresh()->status);

        $this->actingAs($mentor, 'sanctum')
            ->postJson("/api/mentoring/enrollments/{$enrollment->id}/endorse", [
                'endorsement_notes' => 'Direkomendasikan untuk proyek Flutter.',
            ])
            ->assertOk();
        $this->assertTrue($enrollment->fresh()->has_endorsement);
        $this->assertSame(4, TimeCoinTransaction::count());
    }

    public function test_declined_booking_refunds_escrow_and_other_roles_cannot_manage_mentor_classes(): void
    {
        $student = $this->userWithRole('student');
        $mentor = $this->userWithRole('mentor');
        MentorProfile::create(['user_id' => $mentor->id, 'verification_status' => 'approved']);
        $msme = $this->userWithRole('msme');
        $wallet = TimeCoinWallet::create(['user_id' => $student->id, 'balance' => 40]);
        TimeCoinWallet::create(['user_id' => $mentor->id]);
        $class = MentoringClass::create([
            'mentor_id' => $mentor->id,
            'topic' => 'Dasar BLoC',
            'scheduled_time' => now()->addDay(),
            'duration_minutes' => 60,
            'price_tc' => 20,
            'capacity' => 1,
        ]);

        $this->actingAs($student, 'sanctum')->postJson("/api/mentoring/classes/{$class->id}/book")->assertCreated();
        $enrollment = MentoringEnrollment::firstOrFail();
        $this->actingAs($mentor, 'sanctum')
            ->patchJson("/api/mentoring/enrollments/{$enrollment->id}/decision", ['decision' => 'declined'])
            ->assertOk();

        $this->assertSame(40, $wallet->fresh()->balance);
        $this->assertSame(0, $wallet->fresh()->locked_balance);
        $this->assertSame('declined', $enrollment->fresh()->status);

        $this->actingAs($msme, 'sanctum')
            ->postJson('/api/mentoring/mentor/classes', [])
            ->assertForbidden();
    }

    public function test_cash_out_keeps_student_fee_zero_and_applies_ten_percent_to_freemium_mentor(): void
    {
        $student = $this->userWithRole('student');
        $mentor = $this->userWithRole('mentor');
        $studentWallet = TimeCoinWallet::create(['user_id' => $student->id, 'balance' => 100]);
        $mentorWallet = TimeCoinWallet::create(['user_id' => $mentor->id, 'balance' => 100]);
        MentorProfile::create(['user_id' => $mentor->id, 'is_premium' => false, 'verification_status' => 'approved']);
        $payload = [
            'amount_tc' => 100,
            'bank_name' => 'BCA',
            'account_number' => '1234567890',
            'account_holder_name' => 'TalentSync User',
        ];

        $this->actingAs($student, 'sanctum')
            ->postJson('/api/wallet/cash-out', $payload)
            ->assertCreated()
            ->assertJsonPath('data.admin_fee_idr', 0)
            ->assertJsonPath('data.admin_fee_percent', 0)
            ->assertJsonPath('data.disbursed_amount_idr', 100000);
        $this->assertSame(0, $studentWallet->fresh()->balance);

        $this->actingAs($mentor, 'sanctum')
            ->postJson('/api/wallet/cash-out', $payload)
            ->assertCreated()
            ->assertJsonPath('data.admin_fee_idr', 10000)
            ->assertJsonPath('data.admin_fee_percent', 10)
            ->assertJsonPath('data.disbursed_amount_idr', 90000);
        $this->assertSame(0, $mentorWallet->fresh()->balance);
    }

    public function test_mentor_registration_requires_admin_verification_and_premium_changes_only_after_admin_payment_confirmation(): void
    {
        $registration = $this->postJson('/api/auth/register-mentor', [
            'name' => 'Mentor Baru',
            'email' => 'mentor@example.test',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'title_headline' => 'Flutter Mentor',
            'bio' => 'Membimbing pengembangan aplikasi Flutter.',
            'verification_document_url' => 'https://example.test/credential.pdf',
            'portfolio_url' => 'https://github.com/mentor',
        ])->assertCreated()->assertJsonPath('data.verification_status', 'pending');
        $mentor = User::where('email', 'mentor@example.test')->firstOrFail();
        $this->actingAs($mentor, 'sanctum')
            ->postJson('/api/mentoring/mentor/classes', [])
            ->assertForbidden();

        $admin = $this->userWithRole('admin');
        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/mentors/{$mentor->id}/verification", ['verification_status' => 'approved'])
            ->assertOk();
        $this->actingAs($mentor->fresh(), 'sanctum')
            ->postJson('/api/mentoring/mentor/premium-subscriptions')
            ->assertCreated()
            ->assertJsonPath('data.payment_status', 'pending');
        $subscription = \App\Models\MentorPremiumSubscription::firstOrFail();
        $this->actingAs($admin, 'sanctum')
            ->patchJson("/api/admin/mentor-premium-subscriptions/{$subscription->id}", ['payment_status' => 'paid'])
            ->assertOk();

        $this->actingAs($mentor->fresh(), 'sanctum')
            ->getJson('/api/wallet/summary')
            ->assertOk()
            ->assertJsonPath('data.cashout_fee_percent', 0);
    }

    private function userWithRole(string $role): User
    {
        return User::factory()->create([
            'role_id' => Role::where('name', $role)->firstOrFail()->id,
        ]);
    }
}
