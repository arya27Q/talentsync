<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMilestone;
use App\Models\Role;
use App\Models\StudentProfile;
use App\Models\UmkmProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class Stage3WorkspaceTest extends TestCase
{
    use RefreshDatabase;

    private function createUserWithRole(string $roleName, array $overrides = []): User
    {
        $role = Role::firstOrCreate(['name' => $roleName]);
        $user = User::create([
            'name' => $overrides['name'] ?? ucfirst($roleName).' Demo',
            'email' => $overrides['email'] ?? $roleName.uniqid().'@talentsync.test',
            'password' => Hash::make('password123'),
            'role_id' => $role->id,
        ]);
        $user->roles()->syncWithoutDetaching([$role->id]);

        if ($roleName === 'student') {
            StudentProfile::create([
                'user_id' => $user->id,
                'university' => 'Universitas Negeri Surabaya',
                'major' => 'S1 Sistem Informasi',
                'student_id_number' => '24051214'.random_int(100, 999),
            ]);
        } elseif ($roleName === 'msme') {
            UmkmProfile::create([
                'user_id' => $user->id,
                'business_name' => 'Kopi Tepi Kali',
                'business_sector' => 'Kuliner',
                'address' => 'Jl. Ketintang Baru No. 12, Surabaya',
                'city' => 'Surabaya',
            ]);
        }

        return $user;
    }

    public function test_stage_3_end_to_end_kanban_submission_and_bidirectional_chat(): void
    {
        $msme = $this->createUserWithRole('msme', ['name' => 'Bu Rina']);
        $student = $this->createUserWithRole('student', ['name' => 'Arya Pratama']);

        // 1. MSME creates a project (auto-generates 3 milestones)
        $createRes = $this->actingAs($msme, 'sanctum')->postJson('/api/msme/projects', [
            'title' => 'Aplikasi Kasir Kedai Kopi',
            'category' => 'Mobile',
            'reward_tc' => 150,
            'description' => 'Membuat aplikasi kasir Android untuk kedai kopi.',
        ]);
        $createRes->assertStatus(201);
        $projectId = (int) $createRes->json('data.id');

        // 2. Create pending application & MSME accepts it
        $application = ProjectApplication::create([
            'project_id' => $projectId,
            'student_id' => $student->id,
            'cover_letter' => 'Siap mengerjakan proyek kasir hingga tuntas.',
            'status' => 'pending',
            'applied_at' => now(),
        ]);

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/msme/applications/{$application->id}/accept")
            ->assertOk()
            ->assertJsonPath('data.project_status', 'in_progress');

        // 3. Student sees active project with 3 auto-generated Kanban tasks
        $this->actingAs($student, 'sanctum')
            ->getJson('/api/student/projects')
            ->assertOk()
            ->assertJsonPath('data.active_projects.0.id', $projectId)
            ->assertJsonPath('data.active_projects.0.kanban_total_count', 3)
            ->assertJsonPath('data.active_projects.0.kanban_done_count', 0);

        // 4. Student moves Kanban task through in_progress -> review -> done & edits title
        $kanbanRes = $this->actingAs($student, 'sanctum')
            ->getJson("/api/projects/{$projectId}/tasks")
            ->assertOk()
            ->assertJsonPath('data.is_read_only', false)
            ->assertJsonPath('data.stats.total_count', 3);

        $firstTaskId = (int) $kanbanRes->json('data.tasks.0.id');

        $this->actingAs($student, 'sanctum')
            ->patchJson("/api/tasks/{$firstTaskId}", [
                'status' => 'review',
                'title' => 'Riset & Wireframe Kasir',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'review')
            ->assertJsonPath('data.title', 'Riset & Wireframe Kasir');

        $this->actingAs($student, 'sanctum')
            ->patchJson("/api/tasks/{$firstTaskId}", ['status' => 'done'])
            ->assertOk()
            ->assertJsonPath('data.status', 'done');

        // 5. MSME can monitor Kanban (read-only) but cannot mutate tasks
        $this->actingAs($msme, 'sanctum')
            ->getJson("/api/projects/{$projectId}/tasks")
            ->assertOk()
            ->assertJsonPath('data.is_read_only', true)
            ->assertJsonPath('data.stats.done_count', 1)
            ->assertJsonPath('data.accepted_student.name', 'Arya Pratama');

        $this->actingAs($msme, 'sanctum')
            ->patchJson("/api/tasks/{$firstTaskId}", ['status' => 'todo'])
            ->assertStatus(403);

        // 6. Student submits deliverable for Milestone 1
        $milestone1 = ProjectMilestone::where('project_id', $projectId)
            ->orderBy('step_order')
            ->firstOrFail();

        $this->actingAs($student, 'sanctum')
            ->postJson("/api/milestones/{$milestone1->id}/submissions", [
                'submission_format' => 'link',
                'deliverable_url' => 'https://figma.com/file/kasir-kopi-v1',
                'submission_notes' => 'Draft riset dan wireframe sudah selesai.',
            ])
            ->assertStatus(201);

        // 7. Student milestones endpoint returns latest_deliverable; MSME postings shows pending submission
        $this->actingAs($student, 'sanctum')
            ->getJson("/api/projects/{$projectId}/milestones")
            ->assertOk()
            ->assertJsonPath('data.milestones.0.status', 'submitted')
            ->assertJsonPath('data.milestones.0.latest_deliverable.deliverable_url', 'https://figma.com/file/kasir-kopi-v1');

        $this->actingAs($msme, 'sanctum')
            ->getJson('/api/msme/projects')
            ->assertOk()
            ->assertJsonPath('data.0.has_pending_submission', true)
            ->assertJsonPath('data.0.kanban_done_count', 1)
            ->assertJsonPath('data.0.accepted_student.name', 'Arya Pratama');

        // 8. Bidirectional workspace chat between Student & MSME
        $this->actingAs($student, 'sanctum')
            ->postJson("/api/projects/{$projectId}/messages", [
                'message' => 'Halo Bu Rina, tahap 1 sudah saya kirim.',
            ])
            ->assertStatus(201);

        $this->actingAs($msme, 'sanctum')
            ->postJson("/api/projects/{$projectId}/messages", [
                'message' => 'Terima kasih Arya, segera saya tinjau.',
            ])
            ->assertStatus(201);

        $this->actingAs($msme, 'sanctum')
            ->getJson("/api/projects/{$projectId}/messages")
            ->assertOk()
            ->assertJsonPath('data.accepted_student.name', 'Arya Pratama')
            ->assertJsonCount(2, 'data.messages');

        $this->assertDatabaseHas('notifications', [
            'notifiable_id' => $student->id,
            'type' => 'project_message',
        ]);
        $this->assertDatabaseHas('notifications', [
            'notifiable_id' => $msme->id,
            'type' => 'project_message',
        ]);
    }
}
