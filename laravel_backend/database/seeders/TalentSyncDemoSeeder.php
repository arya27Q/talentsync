<?php

namespace Database\Seeders;

use App\Models\BankAccount;
use App\Models\MentoringActionItem;
use App\Models\MentoringAssignment;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\MentoringMaterial;
use App\Models\MentoringMessage;
use App\Models\MentorProfile;
use App\Models\Portfolio;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\ProjectDeliverable;
use App\Models\ProjectMessage;
use App\Models\ProjectMilestone;
use App\Models\ProjectTask;
use App\Models\Review;
use App\Models\Reward;
use App\Models\Role;
use App\Models\StudentCertificate;
use App\Models\StudentProfile;
use App\Models\StudentSkill;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use App\Services\NotificationDispatcher;
use Illuminate\Database\Seeder;

class TalentSyncDemoSeeder extends Seeder
{
    public function run(): void
    {
        $studentRole = Role::firstOrCreate(['name' => 'student'], ['description' => 'Mahasiswa']);
        $msmeRole = Role::firstOrCreate(['name' => 'msme'], ['description' => 'Mitra UMKM']);
        $mentorRole = Role::firstOrCreate(['name' => 'mentor'], ['description' => 'Mentor']);

        // 1. Mahasiswa demo (NIM 24051214017)
        $student = User::firstOrCreate(
            ['email' => 'arya@mhs.unesa.ac.id'],
            ['name' => 'Arya Pratama', 'password' => 'password123', 'role_id' => $studentRole->id],
        );
        $student->roles()->syncWithoutDetaching([$studentRole->id]);

        StudentProfile::updateOrCreate(
            ['user_id' => $student->id],
            [
                'university' => 'Universitas Negeri Surabaya',
                'major' => 'S1 Sistem Informasi',
                'student_id_number' => '24051214017',
                'ktm_verification_status' => 'approved',
                'headline' => 'Flutter Developer',
                'bio' => 'Mahasiswa Sistem Informasi yang fokus membangun aplikasi kasir dan katalog digital untuk UMKM Jawa Timur.',
                'cohort_year' => 'Angkatan 2024',
                'semester' => 5,
                'linkedin_url' => 'linkedin.com/in/arya-pratama',
                'github_username' => 'aryapratama',
                'github_connected_at' => now()->subDays(14),
                'github_repos_count' => 12,
                'github_commits_count' => 284,
                'github_pinned_count' => 3,
                'github_languages' => [
                    ['name' => 'Dart', 'percent' => 52],
                    ['name' => 'PHP', 'percent' => 31],
                    ['name' => 'JavaScript', 'percent' => 17],
                ],
                'github_last_synced_at' => now()->subMinutes(5),
                'is_mentor_eligible' => true,
                'completed_projects_count' => 5,
                'total_contribution_hours' => 96,
                'rating_average' => 4.90,
            ],
        );

        $studentWallet = TimeCoinWallet::firstOrCreate(['user_id' => $student->id], ['balance' => 150, 'locked_balance' => 30]);
        if ($studentWallet->balance === 0 && ! TimeCoinTransaction::where('wallet_id', $studentWallet->id)->exists()) {
            $studentWallet->update(['balance' => 150, 'locked_balance' => 30]);
        }

        BankAccount::firstOrCreate(
            ['user_id' => $student->id, 'account_number' => '8291029102'],
            ['bank_name' => 'BCA', 'account_holder_name' => 'Arya Pratama', 'is_primary' => true],
        );

        $skills = [
            ['name' => 'Flutter', 'proficiency_level' => 'Mahir', 'score' => 92, 'is_verified' => true],
            ['name' => 'Laravel', 'proficiency_level' => 'Menengah', 'score' => 75, 'is_verified' => true],
            ['name' => 'MySQL', 'proficiency_level' => 'Menengah', 'score' => 78, 'is_verified' => true],
            ['name' => 'Dart', 'proficiency_level' => 'Mahir', 'score' => 90, 'is_verified' => true],
            ['name' => 'Figma', 'proficiency_level' => 'Dasar', 'score' => 65, 'is_verified' => false],
        ];
        foreach ($skills as $s) {
            StudentSkill::firstOrCreate(
                ['student_id' => $student->id, 'name' => $s['name']],
                [
                    'proficiency_level' => $s['proficiency_level'],
                    'score' => $s['score'],
                    'is_verified' => $s['is_verified'],
                    'verified_source' => $s['is_verified'] ? 'Proyek UMKM & Mentor' : null,
                    'verified_at' => $s['is_verified'] ? now()->subDays(3) : null,
                ],
            );
        }

        // 2. Mitra UMKM accounts
        $umkmBuSri = $this->createUmkm(
            $msmeRole->id,
            'umkm.busri@talentsync.id',
            'Ibu Sri Wahyuni',
            'Toko Bu Sri',
            'Klaster Ritel',
            'Jl. Ketintang Baru No. 14',
            'Ketintang',
            'Surabaya',
        );
        $umkmMakNah = $this->createUmkm(
            $msmeRole->id,
            'umkm.maknah@talentsync.id',
            'Mak Nah',
            'Keripik Tempe Mak Nah',
            'Klaster Kuliner',
            'Jl. Raya Tenggilis No. 22',
            'Tenggilis',
            'Surabaya',
        );
        $umkmBuRudi = $this->createUmkm(
            $msmeRole->id,
            'umkm.burudi@talentsync.id',
            'Ibu Rudianto',
            'Sambal Bu Rudi',
            'Klaster Kuliner',
            'Jl. Rungkut Industri III No. 8',
            'Rungkut',
            'Surabaya',
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        );
        $umkmBatik = $this->createUmkm(
            $msmeRole->id,
            'umkm.batik@talentsync.id',
            'Hendra Kusuma',
            'Batik Warisan Nusantara',
            'Klaster Kriya & Fashion',
            'Jl. Dharmawangsa No. 45',
            'Gubeng',
            'Surabaya',
        );

        // 3. Mentors & Classes
        $dimas = User::firstOrCreate(
            ['email' => 'dimas.mentor@talentsync.id'],
            ['name' => 'Dimas Prasetyo', 'password' => 'password123', 'role_id' => $mentorRole->id],
        );
        $dimas->roles()->syncWithoutDetaching([$mentorRole->id]);
        MentorProfile::firstOrCreate(
            ['user_id' => $dimas->id],
            [
                'title_headline' => 'Senior Flutter Engineer · Fintech lokal',
                'bio' => 'Audit arsitektur Flutter, code review proyek UMKM, dan simulasi wawancara teknis.',
                'avatar_url' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                'hourly_rate_tc' => 30,
                'is_premium' => true,
                'verification_status' => 'approved',
                'rating_average' => 4.90,
            ],
        );
        TimeCoinWallet::firstOrCreate(['user_id' => $dimas->id], ['balance' => 420]);

        $nadia = User::firstOrCreate(
            ['email' => 'nadia.mentor@talentsync.id'],
            ['name' => 'Nadia Kusuma', 'password' => 'password123', 'role_id' => $mentorRole->id],
        );
        $nadia->roles()->syncWithoutDetaching([$mentorRole->id]);
        MentorProfile::firstOrCreate(
            ['user_id' => $nadia->id],
            [
                'title_headline' => 'Product Designer · Design System Lead',
                'bio' => 'Kurasi portofolio UI/UX Figma dan penyusunan studi kasus siap tender UMKM.',
                'hourly_rate_tc' => 25,
                'verification_status' => 'approved',
                'rating_average' => 4.85,
            ],
        );
        TimeCoinWallet::firstOrCreate(['user_id' => $nadia->id], ['balance' => 250]);

        $dimasClass = MentoringClass::firstOrCreate(
            ['mentor_id' => $dimas->id, 'topic' => 'Arsitektur Flutter & BLoC'],
            [
                'description' => 'Audit struktur Feature-First, manajemen state, dan persiapan proyek UMKM.',
                'scheduled_time' => now()->addDays(2)->setTime(19, 0),
                'duration_minutes' => 60,
                'price_tc' => 30,
                'meeting_link' => 'https://meet.google.com/ts-dimas-flutter',
                'capacity' => 10,
                'status' => 'open',
            ],
        );
        $dimasPastClass = MentoringClass::firstOrCreate(
            ['mentor_id' => $dimas->id, 'topic' => 'Kurasi portofolio tender UMKM'],
            [
                'description' => 'Review studi kasus nyata dan persiapan presentasi klien UMKM.',
                'scheduled_time' => now()->subDays(3)->setTime(19, 0),
                'duration_minutes' => 60,
                'price_tc' => 30,
                'meeting_link' => 'https://meet.google.com/ts-dimas-kurasi',
                'capacity' => 10,
                'status' => 'open',
            ],
        );
        $nadiaClass = MentoringClass::firstOrCreate(
            ['mentor_id' => $nadia->id, 'topic' => 'Design System & Figma Token'],
            [
                'description' => 'Membangun komponen Figma yang konsisten dan siap di-handoff ke developer.',
                'scheduled_time' => now()->addDays(4)->setTime(16, 0),
                'duration_minutes' => 60,
                'price_tc' => 25,
                'meeting_link' => 'https://meet.google.com/ts-nadia-figma',
                'capacity' => 8,
                'status' => 'open',
            ],
        );

        // Enrollments for Arya
        $activeEnrollment = MentoringEnrollment::firstOrCreate(
            ['class_id' => $dimasClass->id, 'student_id' => $student->id],
            [
                'paid_tc' => 30,
                'topic_focus' => 'Arsitektur Flutter & BLoC',
                'status' => 'accepted',
            ],
        );
        $evaluatedEnrollment = MentoringEnrollment::firstOrCreate(
            ['class_id' => $dimasPastClass->id, 'student_id' => $student->id],
            [
                'paid_tc' => 30,
                'topic_focus' => 'Kurasi portofolio tender UMKM',
                'status' => 'completed',
                'has_endorsement' => true,
                'endorsement_notes' => 'Menguasai struktur Clean Feature-First dan siap mengerjakan aplikasi kasir UMKM.',
                'assessment_score' => 88,
                'mentor_feedback' => 'Visual desain sangat rapi dan alur transaksi mudah dipahami pengguna toko.',
                'rubric_scores' => [
                    ['label' => 'Visual & Desain', 'score' => 92, 'grade' => 'A+'],
                    ['label' => 'UX Flow', 'score' => 85, 'grade' => 'A'],
                    ['label' => 'Bisnis UMKM', 'score' => 87, 'grade' => 'A'],
                ],
                'evaluated_at' => now()->subDays(2),
                'student_confirmed_at' => now()->subDay(),
            ],
        );

        if (! MentoringActionItem::where('enrollment_id', $evaluatedEnrollment->id)->exists()) {
            MentoringActionItem::create([
                'enrollment_id' => $evaluatedEnrollment->id,
                'title' => 'Tambahkan metrik dampak sebelum-sesudah di studi kasus',
                'tag' => 'Wajib',
                'detail' => 'Sertakan persentase percepatan input transaksi toko.',
                'is_completed' => true,
                'completed_at' => now()->subDay(),
            ]);
            MentoringActionItem::create([
                'enrollment_id' => $evaluatedEnrollment->id,
                'title' => 'Sertakan tautan demo prototype Figma pada lamaran proyek',
                'tag' => 'Rekomendasi',
                'detail' => 'UMKM lebih cepat menerima kandidat dengan demo interaktif.',
                'is_completed' => false,
            ]);
        }

        if (! MentoringMaterial::where('class_id', $dimasClass->id)->exists()) {
            MentoringMaterial::create([
                'class_id' => $dimasClass->id,
                'mentor_id' => $dimas->id,
                'title' => 'Panduan Struktur Folder Feature-First Flutter',
                'description' => 'Checklist pembagian folder data, models, screens, dan widgets.',
                'kind' => 'pdf',
                'meta_label' => 'PDF · 2,4 MB',
                'resource_url' => 'https://flutter.dev/docs',
                'is_new' => true,
            ]);
            MentoringMaterial::create([
                'class_id' => $dimasClass->id,
                'mentor_id' => $dimas->id,
                'title' => 'Rekaman: Refactor Fitur Kasir ke State Bersih',
                'description' => 'Studi kasus pemisahan API client dari widget.',
                'kind' => 'video',
                'meta_label' => 'Video · 25 mnt',
                'resource_url' => 'https://meet.google.com/ts-dimas-flutter',
                'is_new' => true,
            ]);
        }

        if (! MentoringAssignment::where('class_id', $dimasClass->id)->exists()) {
            MentoringAssignment::create([
                'class_id' => $dimasClass->id,
                'mentor_id' => $dimas->id,
                'title' => 'Refactor repository stok barang',
                'description' => 'Pisahkan pemanggilan API dan tangani error jaringan secara bersih.',
                'due_at' => now()->addDays(5),
            ]);
            MentoringAssignment::create([
                'class_id' => $dimasClass->id,
                'mentor_id' => $dimas->id,
                'title' => 'Tulis 5 unit test untuk perhitungan laba & escrow',
                'description' => 'Pastikan seluruh kasus batas nilai diuji.',
                'due_at' => now()->addDays(9),
            ]);
        }

        if (! MentoringMessage::where('enrollment_id', $activeEnrollment->id)->exists()) {
            MentoringMessage::create([
                'enrollment_id' => $activeEnrollment->id,
                'sender_id' => $dimas->id,
                'message' => 'Halo Arya, silakan kirim progres desain atau repo proyek sebelum sesi nanti malam ya.',
            ]);
        }

        // 4. Open UMKM Projects (Explore)
        $openSambal = Project::firstOrCreate(
            ['code' => 'PRJ-OPEN-01'],
            [
                'msme_id' => $umkmBuRudi->id,
                'title' => 'Redesain Kemasan & Katalog Online',
                'division' => 'Divisi Branding & Pemasaran',
                'category' => 'UI/UX Design',
                'description' => 'Membuat antarmuka katalog produk sambal serta redesain label kemasan siap cetak agar lebih menarik di marketplace.',
                'deliverables_checklist' => [
                    'Moodboard & riset kompetitor kemasan kuliner',
                    '3 konsep desain label botol siap cetak (CMYK/PDF)',
                    'Prototype katalog online interaktif di Figma',
                ],
                'reward_tc' => 300,
                'deadline' => now()->addDays(14)->toDateString(),
                'duration_label' => '2 Minggu',
                'work_mode' => 'Hybrid',
                'location_label' => 'Rungkut, Surabaya',
                'skills' => ['UI/UX Design', 'Figma', 'Packaging'],
                'benefit_badge' => 'Sertifikat & Portofolio',
                'requires_endorsement' => false,
                'atmosphere_photo_url' => 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
                'atmosphere_caption' => 'Dapur produksi & etalase Mitra Sambal Bu Rudi',
                'status' => 'open',
            ],
        );
        $this->seedMilestones($openSambal, [
            ['title' => 'Riset & Moodboard Kemasan', 'reward_tc' => 75, 'status' => 'open'],
            ['title' => 'Desain Label Kemasan Final', 'reward_tc' => 125, 'status' => 'locked'],
            ['title' => 'Katalog Online Interaktif', 'reward_tc' => 100, 'status' => 'locked'],
        ]);

        $openBatik = Project::firstOrCreate(
            ['code' => 'PRJ-OPEN-02'],
            [
                'msme_id' => $umkmBatik->id,
                'title' => 'Web Katalog & Pemesanan Batik Nusantara',
                'division' => 'Divisi Digitalisasi Ritel',
                'category' => 'Frontend',
                'description' => 'Membangun landing page katalog motif batik tulis dengan filter kategori dan integrasi pesan WhatsApp.',
                'deliverables_checklist' => [
                    'Halaman katalog responsif mobile & desktop',
                    'Filter motif batik & halaman detail ukuran',
                ],
                'reward_tc' => 450,
                'deadline' => now()->addDays(21)->toDateString(),
                'duration_label' => '3 Minggu',
                'work_mode' => 'Remote',
                'location_label' => 'Gubeng, Surabaya',
                'skills' => ['Frontend', 'React', 'Mobile'],
                'benefit_badge' => 'Rekomendasi Kerja',
                'requires_endorsement' => true,
                'status' => 'open',
            ],
        );
        $this->seedMilestones($openBatik, [
            ['title' => 'Wireframe & Desain UI Katalog', 'reward_tc' => 150, 'status' => 'open'],
            ['title' => 'Implementasi Frontend & Filter', 'reward_tc' => 200, 'status' => 'locked'],
            ['title' => 'QA Responsif & Deployment', 'reward_tc' => 100, 'status' => 'locked'],
        ]);

        // 5. Active Student Projects (Toko Bu Sri & Keripik Tempe Mak Nah)
        $activeBuSri = Project::firstOrCreate(
            ['code' => 'PRJ-A188'],
            [
                'msme_id' => $umkmBuSri->id,
                'title' => 'Aplikasi Kasir Sederhana Toko Kelontong',
                'division' => 'Divisi Sistem Kasir',
                'category' => 'Mobile',
                'description' => 'Pembuatan aplikasi kasir Android untuk pencatatan stok harian dan cetak struk sederhana.',
                'deliverables_checklist' => ['UI Kasir & Keranjang', 'Fitur Stok & Transaksi Harian', 'Laporan Penjualan Mingguan'],
                'reward_tc' => 120,
                'deadline' => now()->addDays(11)->toDateString(),
                'duration_label' => '2 Minggu',
                'work_mode' => 'Hybrid',
                'location_label' => 'Ketintang, Surabaya',
                'skills' => ['Flutter', 'SQLite', 'BLoC'],
                'benefit_badge' => 'Sertifikat & Portofolio',
                'status' => 'in_progress',
            ],
        );
        $this->seedMilestones($activeBuSri, [
            ['title' => 'Desain UI & Alur Transaksi Kasir', 'reward_tc' => 30, 'status' => 'approved'],
            ['title' => 'Fitur stok & transaksi', 'reward_tc' => 50, 'status' => 'open'],
            ['title' => 'Pengujian Akhir & Serah Terima', 'reward_tc' => 40, 'status' => 'locked'],
        ]);
        ProjectApplication::firstOrCreate(
            ['project_id' => $activeBuSri->id, 'student_id' => $student->id],
            [
                'cover_letter' => 'Saya berpengalaman membangun aplikasi kasir Flutter lokal.',
                'has_mentor_endorsement_snapshot' => true,
                'status' => 'accepted',
                'reviewed_at' => now()->subDays(5),
            ],
        );
        if (! ProjectTask::where('project_id', $activeBuSri->id)->exists()) {
            ProjectTask::insert([
                ['project_id' => $activeBuSri->id, 'student_id' => $student->id, 'title' => 'Rancang layar keranjang & pembayaran', 'tag' => 'UI', 'status' => 'done', 'deadline_label' => '8 Jul', 'sort_order' => 1, 'created_at' => now(), 'updated_at' => now()],
                ['project_id' => $activeBuSri->id, 'student_id' => $student->id, 'title' => 'Integrasi database stok SQLite', 'tag' => 'Backend', 'status' => 'done', 'deadline_label' => '10 Jul', 'sort_order' => 2, 'created_at' => now(), 'updated_at' => now()],
                ['project_id' => $activeBuSri->id, 'student_id' => $student->id, 'title' => 'Implementasi fitur scan barcode barang', 'tag' => 'Fitur', 'status' => 'in_progress', 'deadline_label' => '14 Jul', 'sort_order' => 3, 'created_at' => now(), 'updated_at' => now()],
                ['project_id' => $activeBuSri->id, 'student_id' => $student->id, 'title' => 'Cetak struk thermal & rekap harian', 'tag' => 'QA', 'status' => 'todo', 'deadline_label' => '18 Jul', 'sort_order' => 4, 'created_at' => now(), 'updated_at' => now()],
            ]);
        }
        if (! ProjectMessage::where('project_id', $activeBuSri->id)->exists()) {
            ProjectMessage::create([
                'project_id' => $activeBuSri->id,
                'sender_id' => $umkmBuSri->id,
                'message' => 'Halo Mas Arya, untuk halaman stok mohon dibuat tombol tambah cepat ya biar mudah dipakai kasir.',
            ]);
        }

        $activeMakNah = Project::firstOrCreate(
            ['code' => 'PRJ-B204'],
            [
                'msme_id' => $umkmMakNah->id,
                'title' => 'Logo dan Kemasan Baru Keripik Tempe',
                'division' => 'Divisi Branding Produk',
                'category' => 'UI/UX Design',
                'description' => 'Pembuatan identitas visual dan desain kemasan pouch 250g.',
                'reward_tc' => 35,
                'deadline' => now()->addDays(4)->toDateString(),
                'duration_label' => '1 Minggu',
                'work_mode' => 'Remote',
                'location_label' => 'Tenggilis, Surabaya',
                'skills' => ['Figma', 'Branding'],
                'status' => 'in_progress',
            ],
        );
        $this->seedMilestones($activeMakNah, [
            ['title' => 'Sketsa Logo Utama', 'reward_tc' => 15, 'status' => 'approved'],
            ['title' => 'Panduan brand & aset grafis', 'reward_tc' => 20, 'status' => 'open'],
        ]);
        ProjectApplication::firstOrCreate(
            ['project_id' => $activeMakNah->id, 'student_id' => $student->id],
            [
                'cover_letter' => 'Siap membantu branding kemasan keripik tempe agar lebih modern.',
                'has_mentor_endorsement_snapshot' => true,
                'status' => 'accepted',
                'reviewed_at' => now()->subDays(3),
            ],
        );

        // 6. Completed Projects + Verified Portfolios + Certificates (5 completed for Switch as a Mentor!)
        $completedDefs = [
            ['code' => 'PRJ-CMP-01', 'title' => 'Sistem reservasi meja Warung Pak Gito', 'cat' => 'Backend', 'tc' => 80, 'client' => 'Warung Pak Gito', 'tags' => ['Laravel', 'MySQL']],
            ['code' => 'PRJ-CMP-02', 'title' => 'Katalog digital produk Depot Barokah', 'cat' => 'Mobile', 'tc' => 150, 'client' => 'Depot Makan Barokah', 'tags' => ['Flutter', 'REST API']],
            ['code' => 'PRJ-CMP-03', 'title' => 'Landing page promo Laundry Bersih Jaya', 'cat' => 'Frontend', 'tc' => 45, 'client' => 'Laundry Bersih Jaya', 'tags' => ['HTML', 'Tailwind']],
            ['code' => 'PRJ-CMP-04', 'title' => 'Redesain Nota & QRIS Kerajinan Anyam Ayu', 'cat' => 'UI/UX Design', 'tc' => 70, 'client' => 'Kerajinan Anyam Ayu', 'tags' => ['Figma', 'Branding']],
            ['code' => 'PRJ-CMP-05', 'title' => 'Dashboard Stok Kopi Tepi Kali', 'cat' => 'Mobile', 'tc' => 110, 'client' => 'Kopi Tepi Kali', 'tags' => ['Flutter', 'SQLite']],
        ];
        foreach ($completedDefs as $idx => $def) {
            $p = Project::firstOrCreate(
                ['code' => $def['code']],
                [
                    'msme_id' => $umkmBuSri->id,
                    'title' => $def['title'],
                    'category' => $def['cat'],
                    'description' => 'Proyek kolaborasi digitalisasi UMKM yang telah divalidasi tuntas.',
                    'reward_tc' => $def['tc'],
                    'deadline' => now()->subDays(15 - $idx)->toDateString(),
                    'duration_label' => '2 Minggu',
                    'work_mode' => 'Remote',
                    'location_label' => 'Surabaya',
                    'skills' => $def['tags'],
                    'status' => 'completed',
                ],
            );
            ProjectApplication::firstOrCreate(
                ['project_id' => $p->id, 'student_id' => $student->id],
                ['cover_letter' => 'Portofolio selesai.', 'has_mentor_endorsement_snapshot' => true, 'status' => 'accepted'],
            );
            Portfolio::firstOrCreate(
                ['student_id' => $student->id, 'project_id' => $p->id],
                [
                    'title' => $def['title'],
                    'category' => $def['cat'],
                    'client_name' => $def['client'],
                    'role_title' => 'Mobile & Web Developer',
                    'duration_label' => '2 minggu',
                    'reward_tc' => $def['tc'],
                    'rating' => 4.9,
                    'tags' => $def['tags'],
                    'problem_summary' => "Mitra {$def['client']} sebelumnya mencatat pesanan dan stok secara manual sehingga rawan selisih.",
                    'solution_summary' => 'Membangun alur aplikasi yang ringan, ringkas, dan dapat dioperasikan langsung dari ponsel pemilik usaha.',
                    'result_summary' => 'Waktu rekap harian berkurang drastis dan seluruh tahap milestone disetujui tepat waktu.',
                    'deliverable_highlights' => ['Source code modular', 'Panduan penggunaan UMKM', 'Video demo hasil akhir'],
                    'testimonial_quote' => 'Hasil kerja rapi, komunikatif saat revisi, dan langsung dipakai operasional harian kami.',
                    'testimonial_author' => 'Pemilik '.$def['client'],
                    'is_verified' => true,
                    'is_featured' => $idx < 3,
                ],
            );
            StudentCertificate::firstOrCreate(
                ['certificate_code' => 'TS-PRJ-'.str_pad((string) ($idx + 1), 4, '0', STR_PAD_LEFT)],
                [
                    'student_id' => $student->id,
                    'source_type' => 'project',
                    'title' => $def['title'],
                    'issuer_name' => $def['client'],
                    'category_label' => 'Proyek UMKM',
                    'reference_type' => Project::class,
                    'reference_id' => $p->id,
                    'issued_at' => now()->subDays(10 - $idx),
                ],
            );
        }

        StudentCertificate::firstOrCreate(
            ['certificate_code' => 'TS-END-0087'],
            [
                'student_id' => $student->id,
                'source_type' => 'mentoring_endorsement',
                'title' => 'Rekomendasi Kerja: Flutter Developer',
                'issuer_name' => 'Dimas Prasetyo, Mentor',
                'category_label' => 'Endorse Mentor',
                'reference_type' => MentoringEnrollment::class,
                'reference_id' => $evaluatedEnrollment->id,
                'issued_at' => now()->subDay(),
            ],
        );

        // 7. Rewards Catalog
        $rewards = [
            ['title' => 'Kopi Gratis Mitra Kuliner', 'provider' => 'Kopi Tepi Kali', 'description' => '1 minuman pilihan ukuran reguler.', 'tc_price' => 15, 'icon_key' => 'local_cafe'],
            ['title' => 'Saldo E-Wallet Rp25.000', 'provider' => 'GoPay / DANA / OVO', 'description' => 'Voucher pencairan cepat e-wallet.', 'tc_price' => 25, 'icon_key' => 'account_balance_wallet'],
            ['title' => 'Kelas Online Flutter Lanjutan', 'provider' => 'TalentSync Academy', 'description' => 'Akses rekaman & modul arsitektur.', 'tc_price' => 60, 'icon_key' => 'school'],
            ['title' => 'Cetak Laporan / Skripsi 1 Eks', 'provider' => 'Fotokopi Ketintang Jaya', 'description' => 'Gratis cetak & jilid softcover.', 'tc_price' => 40, 'icon_key' => 'print'],
            ['title' => 'Paket Makan Siang Hemat', 'provider' => 'Warung Pak Gito', 'description' => 'Nasi ayam penyet + es teh manis.', 'tc_price' => 20, 'icon_key' => 'restaurant'],
            ['title' => 'Sertifikat Kompetensi Terverifikasi', 'provider' => 'TalentSync QA Board', 'description' => 'Verifikasi kompetensi portofolio prioritas.', 'tc_price' => 75, 'icon_key' => 'workspace_premium'],
        ];
        foreach ($rewards as $reward) {
            Reward::firstOrCreate(['title' => $reward['title']], $reward);
        }

        // 8. Sample Transactions & Notifications
        if (! TimeCoinTransaction::where('wallet_id', $studentWallet->id)->exists()) {
            TimeCoinTransaction::create([
                'wallet_id' => $studentWallet->id,
                'sender_id' => $umkmBuSri->id,
                'recipient_id' => $student->id,
                'transaction_type' => 'project_reward',
                'direction' => 'credit',
                'ledger_account' => 'balance',
                'amount' => 150,
                'reference_type' => Project::class,
                'reference_id' => $activeBuSri->id,
                'status' => 'completed',
                'created_at' => now()->subDays(2),
            ]);
            TimeCoinTransaction::create([
                'wallet_id' => $studentWallet->id,
                'sender_id' => $student->id,
                'recipient_id' => $dimas->id,
                'transaction_type' => 'mentoring_payment',
                'direction' => 'debit',
                'ledger_account' => 'balance',
                'amount' => 30,
                'reference_type' => MentoringEnrollment::class,
                'reference_id' => $activeEnrollment->id,
                'status' => 'completed',
                'created_at' => now()->subDay(),
            ]);
        }

        if (! $student->notifications()->exists()) {
            $dispatcher = app(NotificationDispatcher::class);
            $dispatcher->send(
                $student,
                'project_accepted',
                'Lamaran Proyek Diterima',
                'Toko Bu Sri menerima lamaran Anda untuk Aplikasi Kasir Sederhana.',
                '/my-projects',
            );
            $dispatcher->send(
                $student,
                'wallet_reward',
                '+150 TC Diterima',
                'Imbalan milestone proyek UMKM telah masuk ke Dompet TimeCoin Anda.',
                '/wallet',
            );
            $dispatcher->send(
                $student,
                'mentor_endorsement',
                'Badge Rekomendasi Mentor Terbit',
                'Dimas Prasetyo menyematkan Badge Rekomendasi Kerja di portofolio Anda.',
                '/portfolio/certificates',
            );
        }
    }

    private function createUmkm(
        int $roleId,
        string $email,
        string $ownerName,
        string $businessName,
        string $sector,
        string $address,
        string $district,
        string $city,
        ?string $logoUrl = null,
    ): User {
        $user = User::firstOrCreate(
            ['email' => $email],
            ['name' => $ownerName, 'password' => 'password123', 'role_id' => $roleId],
        );
        $user->roles()->syncWithoutDetaching([$roleId]);
        UmkmProfile::firstOrCreate(
            ['user_id' => $user->id],
            [
                'business_name' => $businessName,
                'business_sector' => $sector,
                'logo_url' => $logoUrl,
                'address' => $address,
                'district' => $district,
                'city' => $city,
                'is_verified' => true,
            ],
        );
        TimeCoinWallet::firstOrCreate(['user_id' => $user->id], ['balance' => 1000]);

        return $user;
    }

    private function seedMilestones(Project $project, array $stages): void
    {
        if ($project->milestones()->exists()) {
            return;
        }
        foreach ($stages as $index => $stage) {
            ProjectMilestone::create([
                'project_id' => $project->id,
                'step_order' => $index + 1,
                'title' => $stage['title'],
                'reward_tc' => $stage['reward_tc'],
                'status' => $stage['status'],
            ]);
        }
    }
}

