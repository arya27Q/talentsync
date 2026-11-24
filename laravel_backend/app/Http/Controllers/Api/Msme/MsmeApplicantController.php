<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Models\MentoringEnrollment;
use App\Models\MentorProfile;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectMessage;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use App\Models\StudentCertificate;
use App\Models\User;
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
            'recommendedMentor.mentorProfile',
        ])->whereHas('project', function ($q) use ($user) {
            $q->where('msme_id', $user->id);
        });

        if ($projectId) {
            $query->where('project_id', $projectId);
        }

        if ($filter === 'recommended' || $filter === 'endorsed') {
            $query->where('has_mentor_endorsement_snapshot', true);
        } elseif (in_array($filter, ['pending', 'accepted', 'rejected'], true)) {
            $query->where('status', $filter);
        }

        $applications = $query->latest('applied_at')->get();

        $data = $applications->map(function (ProjectApplication $app) {
            $student = $app->student;
            $profile = $student?->studentProfile;
            $skills = $student?->studentSkills?->pluck('name')->values()->all() ?? [];
            $rating = (float) ($profile?->rating_average ?? 0);
            $completedCount = (int) ($profile?->completed_projects_count ?? 0);

            $endorsementMentorName = null;
            if ($app->has_mentor_endorsement_snapshot) {
                $endorsedEnrollment = MentoringEnrollment::with('mentoringClass.mentor')
                    ->where('student_id', $app->student_id)
                    ->where('has_endorsement', true)
                    ->latest('id')
                    ->first();
                $endorsementMentorName = $endorsedEnrollment?->mentoringClass?->mentor?->name;
            }

            $githubUsername = trim((string) ($profile?->github_username ?? ''));
            $profileGithubUrl = $githubUsername !== ''
                ? (str_starts_with($githubUsername, 'http') ? $githubUsername : 'https://github.com/'.ltrim($githubUsername, '@/'))
                : null;

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
                'mentor_name' => $endorsementMentorName,
                'skills' => $skills,
                'cover_letter' => $app->cover_letter ?? '',
                'timeline_commitment' => $app->timeline_commitment ?? '2 Minggu',
                'dedication_hours' => $app->dedication_hours ?? '10-15 jam / minggu',
                'portfolio_link' => $app->portfolio_link,
                'linkedin_url' => $app->linkedin_url ?? $profile?->linkedin_url,
                'cv_url' => $app->cv_url,
                'cv_file_name' => $app->cv_file_name,
                'github_url' => $app->github_url ?? $profileGithubUrl,
                'recommended_mentor' => $app->recommendedMentor ? [
                    'id' => $app->recommendedMentor->id,
                    'name' => $app->recommendedMentor->name,
                    'title_headline' => $app->recommendedMentor->mentorProfile?->title_headline,
                ] : null,
                'rejection_feedback' => $app->rejection_feedback,
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
     * Detail profil pelamar beserta portofolio nyata, CV/LinkedIn/GitHub, dan sertifikasi bimbingan.
     */
    public function show(Request $request, ProjectApplication $application): JsonResponse
    {
        $user = $request->user();
        abort_unless($application->project && $application->project->msme_id === $user->id, 403, 'Akses ditolak.');

        $application->load(['student.studentProfile', 'student.studentSkills', 'project', 'recommendedMentor.mentorProfile']);
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

        $endorsementMentorName = null;
        if ($application->has_mentor_endorsement_snapshot) {
            $endorsedEnrollment = MentoringEnrollment::with('mentoringClass.mentor')
                ->where('student_id', $application->student_id)
                ->where('has_endorsement', true)
                ->latest('id')
                ->first();
            $endorsementMentorName = $endorsedEnrollment?->mentoringClass?->mentor?->name;
        }

        $githubUsername = trim((string) ($profile?->github_username ?? ''));
        $profileGithubUrl = $githubUsername !== ''
            ? (str_starts_with($githubUsername, 'http') ? $githubUsername : 'https://github.com/'.ltrim($githubUsername, '@/'))
            : null;

        return response()->json([
            'status' => 'success',
            'data' => [
                'application_id' => $application->id,
                'project_id' => $application->project_id,
                'project_title' => $application->project?->title,
                'project_reward_tc' => (int) ($application->project?->reward_tc ?? 0),
                'student_id' => $student?->id,
                'name' => $student?->name,
                'email' => $student?->email,
                'avatar_url' => $profile?->avatar_url,
                'university' => $profile?->university ?? 'Universitas Negeri Surabaya',
                'major' => $profile?->major ?? 'S1 Sistem Informasi',
                'headline' => $profile?->headline ?? 'Mahasiswa Aktif TalentSync',
                'bio' => $profile?->bio ?? 'Mahasiswa aktif dengan minat tinggi dalam pengembangan solusi digital bagi UMKM.',
                'rating' => (float) ($profile?->rating_average ?? 0),
                'completed_projects_count' => (int) ($profile?->completed_projects_count ?? 0),
                'total_contribution_hours' => (int) ($profile?->total_contribution_hours ?? 0),
                'has_mentor_endorsement' => (bool) $application->has_mentor_endorsement_snapshot,
                'endorsement_badge' => $application->has_mentor_endorsement_snapshot ? 'Rekomendasi Mentor' : null,
                'mentor_name' => $endorsementMentorName,
                'skills' => $student?->studentSkills?->pluck('name')->values()->all() ?? [],
                'cover_letter' => $application->cover_letter,
                'timeline_commitment' => $application->timeline_commitment,
                'dedication_hours' => $application->dedication_hours,
                'portfolio_link' => $application->portfolio_link,
                'linkedin_url' => $application->linkedin_url ?? $profile?->linkedin_url,
                'cv_url' => $application->cv_url,
                'cv_file_name' => $application->cv_file_name,
                'github_url' => $application->github_url ?? $profileGithubUrl,
                'recommended_mentor' => $application->recommendedMentor ? [
                    'id' => $application->recommendedMentor->id,
                    'name' => $application->recommendedMentor->name,
                    'title_headline' => $application->recommendedMentor->mentorProfile?->title_headline,
                ] : null,
                'rejection_feedback' => $application->rejection_feedback,
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

            // Tolak pelamar lain yang masih pending & kirim pesan evaluasi penutup di chat
            $otherPendingApps = ProjectApplication::where('project_id', $project->id)
                ->where('id', '!=', $application->id)
                ->where('status', 'pending')
                ->get();

            foreach ($otherPendingApps as $otherApp) {
                $closingFeedback = 'Terima kasih telah melamar. Saat ini mitra telah memilih pelamar lain untuk proyek ini. Tetap semangat membangun portofolio!';
                $otherApp->update([
                    'status' => 'rejected',
                    'reviewed_at' => now(),
                    'rejection_feedback' => $closingFeedback,
                ]);
                ProjectMessage::create([
                    'project_id' => $project->id,
                    'student_id' => $otherApp->student_id,
                    'sender_id' => $user->id,
                    'message' => "[Evaluasi Lamaran]\n{$closingFeedback}",
                ]);
            }

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
     * Menolak pelamar secara edukatif dengan mengarahkan ke bimbingan mentor
     * (opsional: UMKM memilih mentor spesifik yang direkomendasikan).
     */
    public function rejectToMentor(Request $request, ProjectApplication $application): JsonResponse
    {
        $user = $request->user();
        $project = $application->project;

        abort_unless($project && $project->msme_id === $user->id, 403, 'Akses ditolak.');
        abort_unless($application->status === 'pending', 409, 'Lamaran ini sudah tidak berstatus pending.');

        $hasActiveMentors = MentorProfile::exists();
        $allowCatalog = $request->boolean('allow_catalog_choice');

        $data = $request->validate([
            'feedback' => ['required', 'string', 'min:40', 'max:500'],
            'allow_catalog_choice' => ['sometimes', 'boolean'],
            'recommended_mentor_id' => [($hasActiveMentors && ! $allowCatalog) ? 'required' : 'nullable', 'integer', 'exists:users,id'],
        ], [
            'feedback.required' => 'Catatan evaluasi/alasan penolakan wajib diisi agar mahasiswa dapat belajar.',
            'feedback.min' => 'Tuliskan catatan evaluasi minimal 40 karakter yang memuat alasan teknis maupun non-teknis secara jelas bagi mahasiswa.',
            'recommended_mentor_id.required' => 'Wajib memilih salah satu mentor yang direkomendasikan atau opsi katalog mentor.',
        ]);

        $recommendedMentor = null;
        if (! empty($data['recommended_mentor_id'])) {
            $recommendedMentor = User::with('mentorProfile')
                ->where('id', $data['recommended_mentor_id'])
                ->whereHas('mentorProfile')
                ->first();
            abort_unless($recommendedMentor !== null, 422, 'Mentor yang dipilih tidak ditemukan.');
        }

        $feedback = trim((string) $data['feedback']);

        DB::transaction(function () use ($application, $project, $user, $feedback, $recommendedMentor) {
            $application->update([
                'status' => 'rejected',
                'rejection_feedback' => $feedback,
                'recommended_mentor_id' => $recommendedMentor?->id,
                'reviewed_at' => now(),
            ]);

            // Wajib kirim pesan evaluasi ke ruang chat mahasiswa sebelum chat dikunci (read-only)
            $evaluationChatText = "[Evaluasi Lamaran]\n{$feedback}";
            if ($recommendedMentor) {
                $evaluationChatText .= "\n\nRekomendasi Mentor: {$recommendedMentor->name}";
                if ($recommendedMentor->mentorProfile?->title_headline) {
                    $evaluationChatText .= " ({$recommendedMentor->mentorProfile->title_headline})";
                }
            }
            ProjectMessage::create([
                'project_id' => $project->id,
                'student_id' => $application->student_id,
                'sender_id' => $user->id,
                'message' => $evaluationChatText,
            ]);

            $msmeName = $user->umkmProfile?->business_name ?? $user->name;
            $notifBody = $recommendedMentor
                ? "Mitra UMKM {$msmeName} menyarankan Anda mengikuti bimbingan bersama Mentor {$recommendedMentor->name} pada bidang '{$project->category}'. Catatan: {$feedback}"
                : "Mitra UMKM {$msmeName} menyarankan Anda mengambil bimbingan mentor terlebih dahulu pada bidang '{$project->category}' sebelum melamar kembali. Catatan: {$feedback}";

            $this->notifications->send(
                $application->student_id,
                'application_directed_to_mentor',
                $recommendedMentor ? "Rekomendasi Mentor: {$recommendedMentor->name}" : 'Arahan Bimbingan Mentor',
                $notifBody,
                $recommendedMentor ? '/mentors/profile' : '/mentors',
                array_filter([
                    'category' => $project->category,
                    'project_id' => $project->id,
                    'recommended_mentor_id' => $recommendedMentor?->id,
                    'recommended_mentor_name' => $recommendedMentor?->name,
                    'feedback' => $feedback,
                ], fn ($v) => $v !== null),
            );
        });

        return response()->json([
            'status' => 'success',
            'message' => $recommendedMentor
                ? "Lamaran ditolak secara edukatif dan rekomendasi Mentor {$recommendedMentor->name} telah dikirimkan ke mahasiswa."
                : 'Lamaran ditolak secara edukatif dan rekomendasi bimbingan mentor telah dikirimkan ke mahasiswa.',
            'data' => [
                'application_id' => $application->id,
                'status' => 'rejected',
                'recommended_mentor' => $recommendedMentor ? [
                    'id' => $recommendedMentor->id,
                    'name' => $recommendedMentor->name,
                    'title_headline' => $recommendedMentor->mentorProfile?->title_headline,
                ] : null,
            ],
        ]);
    }
}
