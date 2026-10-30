# Struktur Menu & UI/UX Aplikasi TalentSync
**Platform:** Flutter Mobile App  
**Model:** Multi-Role (Mahasiswa, UMKM, Mentor)  

Dokumen ini merangkum seluruh *flow* navigasi (menu) aplikasi **TalentSync** berdasarkan 3 sudut pandang (POV) pengguna, dilengkapi dengan fitur **Pesan/Workspace Chat**, **Notifikasi**, serta integrasi perputaran **TimeCoin (TC)**.

Untuk menjaga tampilan antarmuka tetap bersih, ergonomis, dan terbebas dari *AI Slop*, menu-menu utama diorganisasikan menggunakan **Bottom Navigation Bar** dengan rute terstruktur, sedangkan menu pengaturan dan profil diletakkan pada tab Profil masing-masing peran.

---

## 1. 🎓 Menu POV: Mahasiswa
*Target Pengguna:* Mahasiswa aktif yang mencari tugas UMKM, membangun portofolio, dan bimbingan bersama mentor.

### A. Bottom Navigation Bar (Menu Utama)
1. **Beranda (Dashboard Mahasiswa)**
   * Ringkasan statistik aktivitas: Proyek Aktif (`Icons.bolt_rounded`), Proyek Selesai (`Icons.task_alt_rounded`), Skor Rating (`Icons.star_rounded`).
   * Widget ringkas saldo TimeCoin (`Icons.toll_rounded`).
   * Banner rekomendasi proyek terkini (*Explore Projects*).
   * *Top Bar:* Ikon Notifikasi & Pesan/Chat.
2. **Proyek (Projects Hub)**
   * *Tab 1 (Cari Proyek):* Menjelajahi proyek terbuka dari UMKM, filter kategori, nominal imbalan TimeCoin, dan syarat portofolio/badge mentor.
   * *Tab 2 (Proyek Saya):* Memantau tugas yang sedang dikerjakan (*In Progress*) dan riwayat proyek yang telah disetujui (*Completed*).
   * Tombol aksi: **Open Workspace** (menuju papan Kanban & chat kolaborasi dengan UMKM).
3. **Mentoring**
   * Direktori mentor profesional dan praktisi industri.
   * Filter bidang keahlian (Flutter, UI/UX, Backend, dll.).
   * Tombol aksi kartu: **Book Session** (coklat solid `AppColors.primaryTan`) untuk memesan jadwal bimbingan dengan tarif TimeCoin.
4. **Dompet & Reward (Wallet)**
   * *Tab 1 (TimeCoin Wallet):* Saldo TC, riwayat mutasi transaksi kredit masuk/keluar, dan menu pencairan (*Cash-Out* ke Rupiah dengan **0% potongan admin**).
   * *Tab 2 (Reward Hub):* Menukarkan TimeCoin dengan reward internal atau voucher promosi.
5. **Profil & Portofolio**
   * Identitas mahasiswa, universitas, program studi, dan status verifikasi KTM.
   * Galeri portofolio proyek selesai dan ulasan bintang dari UMKM.
   * *Badge Rekomendasi Kerja (Endorsement)* dari mentor.

### B. Fitur Khusus Mahasiswa
* **Switch as a Mentor:** *Toggle* mode mentor pada halaman profil yang otomatis aktif jika mahasiswa telah menyelesaikan $\ge 5$ proyek UMKM dengan rekam jejak penilaian baik.

---

## 2. 🏪 Menu POV: Mitra UMKM
*Target Pengguna:* Pelaku UMKM yang membutuhkan tenaga pendukung digitalisasi usaha dengan bantuan mahasiswa terkurasi.

### A. Bottom Navigation Bar (Menu Utama)
1. **Dashboard UMKM**
   * Ringkasan proyek aktif berjalan, pelamar baru yang masuk, dan total penyelesaian proyek.
   * Kuota TimeCoin bulanan yang tersedia (kuota dasar bulanan).
   * *Top Bar:* Notifikasi lamaran & Workspace Chat.
2. **Manajemen Proyek (Projects)**
   * Daftar proyek yang sedang dipublikasikan beserta status pelamar.
   * **Tombol FAB (Posting Proyek Baru):** Formulir pengisian nama pekerjaan, kategori, deskripsi tugas, imbalan TimeCoin, dan syarat wajib (portofolio eksternal / badge mentor).
   * **Evaluasi & Validasi Hasil Kerja:** Halaman pemeriksaan berkas *deliverable*, tombol minta revisi, atau tombol validasi hasil akhir (*"Validasi Hasil & Transfer 150 TimeCoin"*) disertai pemberian rating bintang 1-5 dan ulasan.
3. **Talent Search (Cari Talenta)**
   * Menjelajahi profil mahasiswa berdasarkan keahlian teknis, rating portofolio, dan kepemilikan Badge Rekomendasi Mentor.
4. **Wallet & Layanan Premium**
   * Status kuota TimeCoin proyek.
   * Menu langganan **Paket Premium UMKM** (membuka kuota posting ekstra dan filter pelamar khusus talenta ber-badge).
5. **Profil Usaha**
   * Nama usaha, legalitas/dokumen verifikasi, bidang industri, dan kontak resmi.

---

## 3. 💼 Menu POV: Mentor
*Target Pengguna:* Profesional industri atau alumni/mahasiswa berprestasi yang membuka bimbingan keterampilan.

### A. Bottom Navigation Bar (Menu Utama)
1. **Dashboard Mentor**
   * Ringkasan jadwal sesi mentoring aktif, total murid yang dibimbing, dan perolehan saldo TimeCoin.
   * *Top Bar:* Notifikasi booking baru & Chat Bimbingan.
2. **Kelola Sesi & Kelas Mentoring**
   * Daftar sesi bimbingan yang akan datang (*Upcoming Sessions*).
   * Tautan ruang virtual (*Virtual Workspace / Video Call UI / Google Meet*).
   * Halaman evaluasi murid: Memeriksa tugas bimbingan dan tombol **"Beri Badge (Endorse)"** untuk merekomendasikan murid kompeten ke mitra UMKM.
3. **Lapak Bimbingan (Services)**
   * Pengaturan topik keahlian, silabus ringkas, jadwal ketersediaan bimbingan, dan penetapan tarif TimeCoin per jam (*"Book for 3 TC / hr"*).
4. **Dompet & Penarikan Dana (Cash-Out)**
   * Saldo TimeCoin yang terkumpul dari sesi kelas.
   * Form penarikan dana ke rekening bank ($1\text{ TC} \approx \text{Rp}1.000$).
   * Tampilan skema biaya admin: Freemium (potongan 10%) vs opsi upgrade ke **Premium Mentor** (0% potongan admin).
5. **Profil Mentor**
   * Portofolio profesional, ulasan bintang dari anak didik, dan pengaturan akun.
