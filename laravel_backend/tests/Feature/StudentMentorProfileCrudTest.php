<?php

namespace Tests\Feature;

use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class StudentMentorProfileCrudTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        Role::firstOrCreate(['name' => 'student']);
        Role::firstOrCreate(['name' => 'mentor']);
        Role::firstOrCreate(['name' => 'msme']);
    }

    public function test_student_register_crud_avatar_strict_png_jpg_and_logout(): void
    {
        // Reject PDF as avatar_file during registration
        $pdfFake = UploadedFile::fake()->create('bukan-foto.pdf', 50, 'application/pdf');
        $this->post('/api/auth/register', [
            'name' => 'Budi Mahasiswa',
            'email' => 'budi.mhs@unesa.ac.id',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'student',
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'S1 Sistem Informasi',
            'student_id_number' => '24051214099',
            'avatar_file' => $pdfFake,
        ], ['Accept' => 'application/json'])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['avatar_file']);

        // Register with valid PNG avatar
        $pngAvatar = UploadedFile::fake()->image('avatar.png', 200, 200);
        $registerRes = $this->post('/api/auth/register', [
            'name' => 'Budi Mahasiswa',
            'email' => 'budi.mhs@unesa.ac.id',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'student',
            'university' => 'Universitas Negeri Surabaya',
            'major' => 'S1 Sistem Informasi',
            'student_id_number' => '24051214099',
            'avatar_file' => $pngAvatar,
        ], ['Accept' => 'application/json']);

        $registerRes->assertStatus(201);
        $token = $registerRes->json('data.token');
        $this->assertNotEmpty($registerRes->json('data.user.avatar_url'));

        // Update profile with thematic preset avatar + new name/bio/skills
        $this->withToken($token)
            ->putJson('/api/student/profile', [
                'name' => 'Budi Santoso',
                'university' => 'Universitas Negeri Surabaya',
                'major' => 'S1 Teknik Informatika',
                'headline' => 'Flutter Developer',
                'bio' => 'Fokus membangun aplikasi mobile untuk UMKM.',
                'avatar_url' => 'avatar:student_tech',
                'skills' => ['Flutter', 'Laravel'],
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'Budi Santoso')
            ->assertJsonPath('data.avatar_url', 'avatar:student_tech');

        // Reject PDF on student profile update
        $this->withToken($token)
            ->post('/api/student/profile', [
                '_method' => 'PUT',
                'name' => 'Budi Santoso',
                'university' => 'Universitas Negeri Surabaya',
                'major' => 'S1 Teknik Informatika',
                'avatar_file' => UploadedFile::fake()->create('doc.pdf', 30, 'application/pdf'),
            ], ['Accept' => 'application/json'])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['avatar_file']);

        // Upload new cropped PNG photo on student profile update
        $croppedPng = UploadedFile::fake()->image('budi_cropped.png', 480, 480);
        $updatePhotoRes = $this->withToken($token)
            ->post('/api/student/profile', [
                '_method' => 'PUT',
                'name' => 'Budi Santoso',
                'university' => 'Universitas Negeri Surabaya',
                'major' => 'S1 Teknik Informatika',
                'avatar_file' => $croppedPng,
            ], ['Accept' => 'application/json']);

        $updatePhotoRes->assertOk();
        $this->assertStringContainsString('student-avatars', (string) $updatePhotoRes->json('data.avatar_url'));

        // Logout succeeds
        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk();
    }

    public function test_mentor_register_real_zero_metrics_crud_avatar_strict_png_jpg_and_delete(): void
    {
        $validPdf = UploadedFile::fake()->create('cv-mentor.pdf', 100, 'application/pdf');

        // Reject PDF as mentor avatar_file
        $this->post('/api/auth/register-mentor', [
            'name' => 'Raka Mentor',
            'email' => 'raka.mentor@talentsync.id',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'title_headline' => 'Mentor Flutter',
            'bio' => 'Berpengalaman membimbing proyek mobile.',
            'hourly_rate_tc' => 35,
            'portfolio_url' => 'https://github.com/raka-mentor',
            'cv_file' => $validPdf,
            'avatar_file' => UploadedFile::fake()->create('bad.pdf', 20, 'application/pdf'),
        ], ['Accept' => 'application/json'])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['avatar_file']);

        // Register mentor with thematic preset avatar
        $registerRes = $this->post('/api/auth/register-mentor', [
            'name' => 'Raka Mentor',
            'email' => 'raka.mentor@talentsync.id',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'title_headline' => 'Mentor Flutter',
            'bio' => 'Berpengalaman membimbing proyek mobile.',
            'hourly_rate_tc' => 35,
            'portfolio_url' => 'https://github.com/raka-mentor',
            'cv_file' => UploadedFile::fake()->create('cv-mentor.pdf', 100, 'application/pdf'),
            'avatar_url' => 'avatar:mentor_tech',
        ], ['Accept' => 'application/json']);

        $registerRes->assertStatus(201);
        $token = $registerRes->json('data.token');
        $this->assertSame('avatar:mentor_tech', $registerRes->json('data.avatar_url'));

        // Fresh mentor profile returns real 0 metrics & empty lists (no fake numbers)
        $this->withToken($token)
            ->getJson('/api/mentoring/mentor/profile')
            ->assertOk()
            ->assertJsonPath('data.name', 'Raka Mentor')
            ->assertJsonPath('data.avatar_url', 'avatar:mentor_tech')
            ->assertJsonPath('data.teaching_hours', 0)
            ->assertJsonPath('data.rating_average', 0)
            ->assertJsonPath('data.students_count', 0)
            ->assertJsonCount(0, 'data.classes')
            ->assertJsonCount(0, 'data.reviews');

        // Dashboard returns live mentor name & avatar_url
        $this->withToken($token)
            ->getJson('/api/mentoring/mentor/dashboard')
            ->assertOk()
            ->assertJsonPath('data.name', 'Raka Mentor')
            ->assertJsonPath('data.avatar_url', 'avatar:mentor_tech');

        // Update mentor profile with cropped JPG photo & new name/headline
        $croppedJpg = UploadedFile::fake()->image('raka_cropped.jpg', 480, 480);
        $updateRes = $this->withToken($token)
            ->post('/api/mentoring/mentor/profile', [
                '_method' => 'PUT',
                'name' => 'Raka Pratama',
                'title_headline' => 'Senior Flutter Mentor',
                'bio' => 'Fokus arsitektur bersih dan review kode.',
                'avatar_file' => $croppedJpg,
            ], ['Accept' => 'application/json']);

        $updateRes->assertOk()
            ->assertJsonPath('data.name', 'Raka Pratama')
            ->assertJsonPath('data.title_headline', 'Senior Flutter Mentor');
        $this->assertStringContainsString('mentor-avatars', (string) $updateRes->json('data.avatar_url'));

        // Switch mentor avatar back to preset avatar
        $this->withToken($token)
            ->putJson('/api/mentoring/mentor/profile', [
                'name' => 'Raka Pratama',
                'title_headline' => 'Senior Flutter Mentor',
                'avatar_url' => 'avatar:mentor_design',
            ])
            ->assertOk()
            ->assertJsonPath('data.avatar_url', 'avatar:mentor_design');

        // Reject PDF on mentor profile update
        $this->withToken($token)
            ->post('/api/mentoring/mentor/profile', [
                '_method' => 'PUT',
                'name' => 'Raka Pratama',
                'title_headline' => 'Senior Flutter Mentor',
                'avatar_file' => UploadedFile::fake()->create('fake.pdf', 30, 'application/pdf'),
            ], ['Accept' => 'application/json'])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['avatar_file']);

        // Delete mentor account cleanly
        $this->withToken($token)
            ->deleteJson('/api/mentoring/mentor/account')
            ->assertOk();
    }
}
