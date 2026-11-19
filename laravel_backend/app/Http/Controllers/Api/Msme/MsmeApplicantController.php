<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use App\Models\StudentCertificate;
use App\Services\NotificationDispatcher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MsmeApplicantController extends Controller
{
    public function __construct(
        private readonly NotificationDispatcher $notifications,
    ) {
    }

    /**
     * Mengambil daftar pelamar pada proyek milik Mitra UMKM yang sedang login.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        abort_unless($user, 401, 'Silakan login terlebih dahulu.');
        $projectId = $request->query('project_id');
        $filter = $request->query('filter', 'all');

        $query = ProjectApplication::with([
            'student.studentProfile',
            'student.studentSkills',
            'project',
        ])->whereHas('project', function ($q) use ($user) {
            $q->where('msme_id', $user->id);
        });

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        if ($filter === 'recommended' || $filter === 'endorsed') {
            $query->where('has_mentor_endorsement_snapshot', true);
        }

        $applications = $query->latest('applied_at')->get();

        $data = $applications->map(function (ProjectApplication $app) {
            $student = $app->student;
            $profile = $student?->studentProfile;
            $skills = $student?->studentSkills?->pluck('name')->values()->all() ?? [];
            if (empty($skills)) {
                $skills = ['UI/UX', 'Figma', 'Visual Design'];
            }

            $rating = (float) ($profile?->rating_average ?? 4.9);
            if ($rating <= 0) {
                $rating = 4.9;
            }

            $completedCount = (int) ($profile?->completed_projects_count ?? 0);
            if ($completedCount <= 0) {
                $completedCount = 3;
            }

            return [
                'id' => $app->id,
                'project_id' => $app->project_id,
                'project_title' => $app->project?->title ?? 'Tugas Proyek',
                'project_reward_tc' => (int) ($app->project?->reward_tc ?? 0),
                'student_id' => $app->student_id,
                'name' => $student?->name ?? 'Mahasiswa Pelamar',
                'avatar_url' => $profile?->avatar_url,
                'university' => $profile?->university ?? 'Universitas Negeri Surabaya',
                'major' => $profile?->major ?? 'S1 Sistem Informasi',
                'rating' => $rating,
                'completed_projects_count' => $completedCount,
                'has_mentor_endorsement' => (bool) $app->has_mentor_endorsement_snapshot,
                'endorsement_badge' => $app->has_mentor_endorsement_snapshot ? 'Rekomendasi Mentor' : null,
                'mentor_name' => 'Dimas Prasetyo (Senior Engineer)',
                'skills' => $skills,
                'cover_letter' => $app->cover_letter ?? 'Siap berkontribusi maksimal untuk kebutuhan digitalisasi toko.',
                'timeline_commitment' => $app->timeline_commitment ?? '14 Hari (2 Minggu)',
                'dedication_hours' => $app->dedication_hours ?? '10-15 jam / minggu',
                'portfolio_link' => $app->portfolio_link,
                'status' => $app->status,
                'applied_at' => $app->applied_at?->format('Y-m-d H:i') ?? now()->format('Y-m-d H:i'),
            ];
        });

        // Filter top_rated
        if ($filter === 'top_rated') {
            $data = $data->filter(fn ($item) => ($item['rating'] ?? 0) >= 4.8)->values();
        }

        return response()->json([
            'status' => 'success',
            'data' => $data,
        ]);
    }

    /**
     * Detail profil pelamar beserta portofolio nyata dan sertifikasi bimbingan.
     */
    public function show(Request $request, ProjectApplication $application): JsonResponse
    {
        $user = $request->user();
        abort_unless($application->project && $application->project->msme_id === $user->id, 403, 'Akses ditolak.');

        $student = $application->student;
        $profile = $student?->studentProfile;
        $portfolios = Portfolio::where('student_id', $application->student_id)
            ->where('is_verified', true)
            ->latest('id')
            ->take(4)
            ->get();

        $certificates = StudentCertificate::where('student_id', $application->student_id)
            ->latest('id')
            ->take(3)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'application_id' => $application->id,
                'project_id' => $application->project_id,
                'project_title' => $application->project?->title,
                'student_id' => $student?->id,
                'name' => $student?->name,
                'email' => $student?->email,
                'avatar_url' => $profile?->avatar_url,
                'university' => $profile?->university ?? 'Universitas Negeri Surabaya',
                'major' => $profile?->major ?? 'S1 Sistem Informasi',
                'headline' => $profile?->headline ?? 'Talenta Digital Terverifikasi',
                'bio' => $profile?->bio ?? 'Mahasiswa aktif dengan minat tinggi dalam pengembangan solusi digital bagi UMKM.',
                'rating' => (float) ($profile?->rating_average ?? 4.9),
                'completed_projects_count' => (int) ($profile?->completed_projects_count ?? 3),
                'has_mentor_endorsement' => (bool) $application->has_mentor_endorsement_snapshot,
                'endorsement_badge' => $application->has_mentor_endorsement_snapshot ? 'Rekomendasi Mentor' : null,
                'mentor_name' => 'Dimas Prasetyo (Senior Engineer)',
                'skills' => $student?->studentSkills?->pluck('name')->values()->all() ?? [],
                'cover_letter' => $application->cover_letter,
                'timeline_commitment' => $application->timeline_commitment,
                'dedication_hours' => $application->dedication_hours,
                'portfolio_link' => $application->portfolio_link,
                'status' => $application->status,
                'portfolios' => $portfolios,
                'certificates' => $certificates,
            ],
        ]);
    }

    /**
     * Menerima pelamar:
     * 1. Status pelamar -> accepted
     * 2. Status proyek -> in_progress (masuk tab Berjalan)
     * 3. Pelamar lain berstatus pending ditolak ramah
     * 4. Buat 3 kartu awal di Workspace Kanban mahasiswa
     * 5. Kirim notifikasi ucapan selamat & pembukaan ruang kerja ke mahasiswa
     */
    public function accept(Request $request, ProjectApplication $application): JsonResponse
    {
        $user = $request->user();
        $project = $application->project;

        abort_unless($project && $project->msme_id === $user->id, 403, 'Akses ditolak.');
        abort_unless($application->status === 'pending', 409, 'Lamaran ini sudah tidak berstatus pending.');

        DB::transaction(function () use ($application, $project, $user) {
            $application->update([
                'status' => 'accepted',
                'reviewed_at' => now(),
            ]);

            // Tolak pelamar lain yang masih pending
            ProjectApplication::where('project_id', $project->id)
                ->where('id', '!=', $application->id)
                ->where('status', 'pending')
                ->update([
                    'status' => 'rejected',
                    'reviewed_at' => now(),
                    'rejection_feedback' => 'Mitra telah memilih pelamar lain untuk proyek ini.',
                ]);

            // Ubah status proyek menjadi in_progress
            $project->update(['status' => 'in_progress']);

            // Pastikan 3 tahap milestone tersedia jika proyek lama belum memilikinya
            $milestones = $project->milestones()->orderBy('step_order')->get();
            if ($milestones->isEmpty()) {
                $totalTc = (int) $project->reward_tc;
                $part1 = (int) round($totalTc * 0.3);
                $part2 = (int) round($totalTc * 0.4);
                $part3 = max(1, $totalTc - ($part1 + $part2));

                $milestones = collect([
                    ProjectMilestone::create([
                        'project_id' => $project->id,
                        'step_order' => 1,
                        'title' => 'Tahap 1: Riset & Konsep Awal',
                        'description' => 'Penyusunan rencana kerja, pengumpulan referensi, dan draft konsep awal.',
                        'reward_tc' => $part1,
                        'status' => 'open',
                    ]),
                    ProjectMilestone::create([
                        'project_id' => $project->id,
                        'step_order' => 2,
                        'title' => 'Tahap 2: Pengerjaan Deliverable Utama',
                        'description' => 'Realisasi pekerjaan utama sesuai spesifikasi dan ceklis hasil kerja.',
                        'reward_tc' => $part2,
                        'status' => 'locked',
                    ]),
                    ProjectMilestone::create([
                        'project_id' => $project->id,
                        'step_order' => 3,
                        'title' => 'Tahap 3: Finalisasi & Serah Terima',
                        'description' => 'Pemeriksaan akhir, revisi minor jika diperlukan, dan penyerahan master file.',
                        'reward_tc' => $part3,
                        'status' => 'locked',
                    ]),
                ]);
            }

            // Buat 3 tugas awal di Workspace Kanban mahasiswa (hindari duplikasi)
            $hasTasks = ProjectTask::where('project_id', $project->id)
                ->where('student_id', $application->student_id)
                ->exists();

            if (! $hasTasks) {
                $tasks = [
                    ['title' => 'Riset & Penyelarasan Kebutuhan dengan Mitra', 'tag' => 'Tahap 1', 'sort_order' => 1, 'milestone' => $milestones->get(0)],
                    ['title' => 'Eksekusi Pengerjaan Deliverable Utama', 'tag' => 'Tahap 2', 'sort_order' => 2, 'milestone' => $milestones->get(1) ?? $milestones->get(0)],
                    ['title' => 'Finalisasi & Serah Terima Hasil Pekerjaan', 'tag' => 'Tahap 3', 'sort_order' => 3, 'milestone' => $milestones->get(2) ?? $milestones->get(0)],
                ];

                foreach ($tasks as $taskData) {
                    ProjectTask::create([
                        'project_id' => $project->id,
                        'student_id' => $application->student_id,
                        'milestone_id' => $taskData['milestone']?->id,
                        'title' => $taskData['title'],
                        'tag' => $taskData['tag'],
                        'status' => 'todo',
                        'deadline_label' => $project->duration_label ?? '14 Hari',
                        'sort_order' => $taskData['sort_order'],
                    ]);
                }
            }

            // Notifikasi ke mahasiswa
            $msmeName = $user->umkmProfile?->business_name ?? $user->name;
            $this->notifications->send(
                $application->student_id,
                'application_accepted',
                'Lamaran Proyek Diterima!',
                "Selamat! Lamaran Anda untuk tugas '{$project->title}' telah diterima oleh {$msmeName}. Ruang kerja Kanban telah aktif.",
                '/workspace/kanban',
                ['project_id' => $project->id],
            );
        });

        return response()->json([
            'status' => 'success',
            'message' => "Pelamar {$application->student?->name} berhasil diterima. Proyek telah berpindah ke tahap Berjalan.",
            'data' => [
                'application_id' => $application->id,
                'project_id' => $project->id,
                'project_status' => 'in_progress',
            ],
        ]);
    }

    /**
     * Menolak pelamar secara edukatif dengan mengarahkan ke bimbingan mentor:
     * 1. Status pelamar -> rejected
     * 2. Catatan arahan bimbingan mentor tersimpan
     * 3. Kirim notifikasi ramah ke mahasiswa untuk mengikuti bimbingan mentor
     */
    public function rejectToMentor(Request $request, ProjectApplication $application): JsonResponse
    {
        $user = $request->user();
        $project = $application->project;

        abort_unless($project && $project->msme_id === $user->id, 403, 'Akses ditolak.');
        abort_unless($application->status === 'pending', 409, 'Lamaran ini sudah tidak berstatus pending.');

        $data = $request->validate([
            'feedback' => ['nullable', 'string', 'max:500'],
        ]);

        $feedback = $data['feedback'] ?? 'Mitra menyarankan untuk mengikuti bimbingan mentor terlebih dahulu agar portofolio dan kesiapan kerja semakin optimal.';

        DB::transaction(function () use ($application, $project, $user, $feedback) {
            $application->update([
                'status' => 'rejected',
                'rejection_feedback' => $feedback,
                'reviewed_at' => now(),
            ]);

            $msmeName = $user->umkmProfile?->business_name ?? $user->name;
            $this->notifications->send(
                $application->student_id,
                'application_directed_to_mentor',
                'Arahan Bimbingan Mentor',
                "Mitra UMKM {$msmeName} menyarankan Anda mengambil bimbingan mentor terlebih dahulu pada bidang '{$project->category}' sebelum melamar kembali.",
                '/mentors',
                ['category' => $project->category],
            );
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Lamaran ditolak secara edukatif dan rekomendasi bimbingan mentor telah dikirimkan ke mahasiswa.',
            'data' => [
                'application_id' => $application->id,
                'status' => 'rejected',
            ],
        ]);
    }
}
