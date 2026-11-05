# Struktur Menu & Navigasi Antarmuka Aplikasi TalentSync
**Platform:** Flutter Mobile App (Android)  
**Model:** Multi-Role (Mahasiswa, Mitra UMKM, Peer Mentor)  
**Desain Standar:** 100% Native Material Icons Rounded, Anti "AI Slop", Kontras Ergonomis  

Dokumen ini merangkum seluruh struktur navigasi menu aplikasi **TalentSync** berdasarkan 3 sudut pandang (POV) pengguna, alur **Pusat Konsultasi/Mentoring**, **Workspace Kanban**, **Escrow TimeCoin (TC)**, serta aksesibilitas **Logout & Sesi Akun**.

---

## 1. 🎓 Menu POV: Mahasiswa (Student Flow)
*Target Pengguna:* Mahasiswa aktif yang melamar proyek UMKM, membangun portofolio nyata, mengikuti bimbingan mentor, dan mencairkan TimeCoin ke Rupiah.

### A. Bottom Navigation Bar (4 Tab Utama)
1. **Eksplorasi ([`DashboardMahasiswaScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/dashboard/screens/dashboard_mahasiswa_screen.dart))**
   * **Header:** Avatar inisial, salam personal, lonceng notifikasi, dan tombol cepat **Logout Merah** (`Icons.logout_rounded`) dengan dialog konfirmasi.
   * **Kartu Saldo & Status:** Saldo TimeCoin aktif, total proyek selesai, dan tombol aksi cepat (*Cari Proyek*, *Mentor Saya*, *Reward*).
   * **Interactive Image Carousel:** Slider galeri visual kolaborasi nyata UMKM & bimbingan mentor dengan tombol geser interaktif.
   * **Proyek Aktif (2):** Kartu tugas yang sedang dikerjakan lengkap dengan progress bar, tahapan milestone, dan tenggat waktu.
   * **Pusat Konsultasi & Bimbingan:** Kartu mentor aktif (`Dimas Prasetyo, S.Kom \u00B7 Senior Peer`), jadwal bimbingan live (*Hari ini \u00B7 19.30 WIB*), tombol *Jadwal Saya* (`AppRoutes.myMentors`), tombol *Masuk Sesi* (`AppRoutes.ruangBelajar`), serta link *Cari mentor* (`AppRoutes.findMentors`).
   * **Rekomendasi Proyek UMKM:** Banner proyek UMKM terkurasi dengan tombol lamar langsung.

2. **Tugas Saya ([`MyProjectsScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/project/screens/my_projects_screen.dart))**
   * Metrik tugas: Proyek Berjalan, Menunggu Review UMKM, dan Proyek Selesai.
   * Tab filter status: `Aktif`, `Review`, `Selesai`.
   * Tombol aksi kartu: **Open Workspace** menuju Ruang Kerja Kanban & Obrolan Proyek.

3. **Dompet ([`WalletDashboardScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/wallet/screens/wallet_dashboard_screen.dart))**
   * Ringkasan saldo TimeCoin dan ekuivalensi Rupiah ($1\text{ TC} \approx \text{Rp}1.000$).
   * Riwayat mutasi kredit (pemasukan imbalan proyek UMKM, pembayaran sesi mentoring).
   * Tombol **Pencairan Dana (Cash-Out):** Penarikan ke rekening bank / e-wallet dengan **0% potongan biaya administrasi**.
   * Shortcut ke **Reward Hub** untuk penukaran voucher merchandise / diskon.

4. **Profil ([`PortfolioDashboardScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/portfolio/screens/portfolio_dashboard_screen.dart))**
   * **Header:** Judul profil, tombol gear **Pengaturan Akun** (`AppRoutes.settings`), dan tombol cepat **Logout Merah** (`Icons.logout_rounded`).
   * **Kartu Identitas:** Nama, NIM/KTM terverifikasi, universitas, program studi, dan rating bintang.
   * **Radar Chart Keahlian:** Diagram visual kompetensi (Flutter, Laravel, UI Design, Database, Komunikasi).
   * **Keahlian Terverifikasi & Badge:** Daftar skill tervalidasi dan *Badge Rekomendasi Mentor (Endorse)*.
   * **Proyek Terverifikasi:** Portofolio proyek nyata UMKM yang telah selesai dan divalidasi.
   * **Kartu Sesi Akun Mahasiswa:** Kartu dedicated di bagian bawah dengan tombol eksplisit **"Keluar dari Akun Mahasiswa"**.

### B. Pusat Layanan Konsultasi & Bimbingan Mahasiswa
Mahasiswa yang belum memiliki portofolio proyek nyata wajib mengikuti bimbingan mentor terlebih dahulu melalui modul:
* **Eksplorasi Mentor ([`FindMentorsScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentoring/screens/find_mentors_screen.dart)):** Filter bidang keahlian, review murid, dan tarif TC.
* **Profil Mentor ([`MentorProfileScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentoring/screens/mentor_profile_screen.dart)):** Informasi silabus dan portofolio mentor.
* **Booking Bimbingan ([`BookingSessionScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentoring/screens/booking_session_screen.dart)):** Pemilihan jadwal konsultasi & pembayaran TC.
* **Live Mentoring ([`MentoringSessionScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentoring/screens/mentoring_session_screen.dart)):** Ruang tatap muka Live Video Call online.
* **Ruang Belajar ([`RuangBelajarScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentoring/screens/ruang_belajar_screen.dart)):** Pengunggahan tugas latihan studi kasus.
* **Hasil Evaluasi ([`MentoringResultScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentoring/screens/mentoring_result_screen.dart)):** Nilai akhir dan penerbitan *Badge Rekomendasi Kerja*.

### C. Ruang Kolaborasi Kerja Mahasiswa
* **Workspace Kanban ([`WorkspaceKanbanScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/workspace/screens/workspace_kanban_screen.dart)):** Kolom To Do, In Progress, Done; terintegrasi dengan banner bantuan **"Mengalami Kendala Teknis Proyek? Konsultasi dengan Mentor"**.
* **Submission ([`SubmissionScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/workspace/screens/submission_screen.dart)):** Form serah terima deliverable dengan banner pra-pengumpulan **"Konsultasi Sebelum Mengumpulkan"** dan tombol obrolan UMKM.
* **Fitur Switch as a Mentor ([`SwitchToMentorScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/profile/screens/switch_to_mentor_screen.dart)):** Terbuka setelah menyelesaikan $\ge 5$ proyek UMKM nyata.

---

## 2. 🏪 Menu POV: Mitra UMKM (MSME Flow)
*Target Pengguna:* Pelaku UMKM yang memposting kebutuhan proyek, mendanai imbalan via TimeCoin, menyeleksi mahasiswa ber-badge, dan memvalidasi deliverable.

### A. Bottom Navigation Bar (Menu Utama)
1. **Dashboard UMKM ([`MsmeDashboardScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_dashboard_screen.dart))**
   * Ringkasan proyek aktif berjalan, pelamar baru yang masuk, dan total proyek selesai.
   * Kuota TimeCoin bulanan yang tersedia (kuota dasar bulanan) & tombol Top-Up.
   * Banner showcase interaktif digitalisasi bisnis UMKM.
   * Shortcut posting proyek baru dan obrolan proyek.

2. **Daftar Lowongan Proyek ([`MsmePostingsScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_postings_screen.dart))**
   * Pengelolaan lowongan yang dipublikasikan (Open, Screening, In Progress, Completed).
   * Wizard posting proyek ([`MsmeCreateTaskWizardScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_create_task_wizard_screen.dart)): Kebutuhan tugas, kategori, tenggat waktu, imbalan TC, dan syarat pelamar (portofolio / badge mentor).

3. **Seleksi Pelamar ([`MsmeReviewApplicantsScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_review_applicants_screen.dart))**
   * Pemeriksaan profil pelamar, riwayat proyek nyata, dan verifikasi Badge Rekomendasi Mentor.
   * Tombol aksi:
     * **Terima Pelamar:** Memulai pengerjaan proyek dan mengunci anggaran TC ke sistem escrow.
     * **Tolak & Arahkan Bimbingan Mentor:** Menolak secara edukatif dengan menyarankan pelamar mengikuti bimbingan mentor terlebih dahulu.

4. **Evaluasi & Validasi Deliverable ([`MsmeReviewSubmissionScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_review_submission_screen.dart))**
   * Peninjauan berkas pengerjaan mahasiswa.
   * **Minta Revisi:** Dialog revisi teknis dengan opsi menyarankan mahasiswa berkonsultasi dengan mentor pendamping.
   * **Validasi Hasil & Transfer TimeCoin:** Merilis dana TC escrow ke mahasiswa disertai rating bintang 1-5 dan testimoni ulasan.

5. **Top-Up, Barter & Dompet UMKM ([`MsmeBarterScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_barter_screen.dart))**
   * Paket Top-Up TimeCoin via Rupiah untuk mendanai imbalan proyek.
   * Menu voucher promosi produk UMKM dengan tata letak rapi (`runSpacing: 10`) dan informasi kuota sosial berformat nominal Rupiah (*"Setara Rp520.000"*).
   * Opsi langganan **Paket Premium UMKM** (kuota proyek ekstra hingga 500 TC, bebas biaya admin top-up, dan filter khusus pelamar ber-badge mentor).

6. **Profil Toko/Usaha ([`MsmeStoreProfileScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/msme/screens/msme_store_profile_screen.dart))**
   * Identitas pemilik usaha, legalitas NIB/dokumen, bidang industri, galeri produk, dan tombol Logout.

---

## 3. 💼 Menu POV: Peer Mentor (Mentor Flow)
*Target Pengguna:* Mahasiswa senior berprestasi / praktisi muda yang membimbing mahasiswa junior, menguji studi kasus nyata, menerbitkan Badge Rekomendasi Kerja, dan mencairkan TC ke Rupiah.

### A. Bottom Navigation Bar (Menu Utama)
1. **Dashboard Mentor ([`MentorDashboardScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_dashboard_screen.dart))**
   * **Hierarki Saldo Jelas:** Saldo kerja utama **TimeCoin (TC)** ditampilkan di posisi atas tebal, dengan estimasi Rupiah di bagian bawahnya.
   * **3 Kartu Metrik Display-Only:** *Booking baru*, *Perlu dinilai*, dan *Minta rekomendasi* dengan tinggi presisi seragam (`IntrinsicHeight`).
   * **Banner Ruang Kolaborasi Visual:** Dokumentasi atmosfer bimbingan kerja kolaboratif bergradien gelap.
   * **Kartu Navigasi Kerja Khusus:** Tombol aksi eksplisit *Lihat Booking Masuk*, *Buka Ruang Belajar*, dan *Daftar Permintaan Badge Rekomendasi*.

2. **Daftar Murid & Penilaian ([`MentorStudentsScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_students_screen.dart))**
   * Daftar mahasiswa yang sedang dibimbing.
   * Evaluasi tugas studi kasus dan tombol aksi **Beri Badge (Endorse)** ([`MentorRecommendationScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_recommendation_screen.dart)) untuk merekomendasikan murid kompeten ke mitra UMKM.

3. **Jadwal & Ruang Bimbingan**
   * Manajemen sesi live konsultasi ([`MentorBookingsScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_bookings_screen.dart)).
   * Ruang Live Video Call tatap muka online ([`MentorLiveMentoringScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_live_mentoring_screen.dart)).
   * Ruang Obrolan 1-on-1 dengan murid ([`MentorStudentChatScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_student_chat_screen.dart)).

4. **Layanan Bimbingan (Services) ([`MentorServicesScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_services_screen.dart))**
   * Pengaturan topik keahlian (Mobile, Web, UI/UX), jadwal bimbingan, dan tarif TimeCoin yang ramah mahasiswa.

5. **Dompet & Pencairan Dana ([`MentorWalletScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_wallet_screen.dart))**
   * Saldo TC yang terkumpul dari bimbingan murid.
   * Form pencairan dana (*Cash-Out*) ke rekening bank ([`MentorCashoutScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_cashout_screen.dart)).
   * Skema biaya admin: Freemium (potongan 10%) vs Upgrade ke **Mentor Premium** ([`MentorFeaturedUpgradeScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_featured_upgrade_screen.dart)) dengan **0% potongan biaya administrasi**.

6. **Profil Mentor ([`MentorProfileScreen`](file:///c:/laragon/www/talentsync/flutter_frontend/lib/features/mentor/screens/mentor_profile_screen.dart))**
   * Portofolio keahlian, riwayat bimbingan, testimoni rating murid, dan tombol Logout.
