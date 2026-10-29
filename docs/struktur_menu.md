# Struktur Menu & UI/UX Aplikasi TimeWork
**Platform:** Flutter Mobile App
**Model:** Multi-Role (Mahasiswa, UMKM, Mentor)

Dokumen ini merangkum seluruh *flow* navigasi (menu) aplikasi TimeWork berdasarkan 3 sudut pandang (POV) pengguna, yang telah ditambahkan fitur **Pesan (Chat)** dan **Notifikasi** agar lebih *user-friendly*. 

Agar UI/UX terlihat profesional dan modern seperti aplikasi *startup* sungguhan, menu-menu ini dikelompokkan menggunakan **Bottom Navigation Bar** untuk fitur utama, dan menu pendukung diletakkan di dalam halaman profil.

---

## 1. 🎓 Menu POV: Mahasiswa
*Target Pengguna: Mahasiswa aktif yang mencari tugas UMKM, membangun portofolio, dan mencari mentor.*

### A. Bottom Navigation Bar (Menu Utama)
1.  **Beranda (Dashboard)**
    *   Ringkasan proyek aktif & rekomendasi pekerjaan.
    *   Informasi saldo TimeCoin & Rupiah (Widget sekilas).
    *   *Ikon Top Bar:* **Notifikasi** (Pemberitahuan lamaran tugas/sesi diterima) & **Pesan/Chat**.
2.  **Proyek**
    *   *Tab 1 (Cari Proyek):* Eksplorasi daftar proyek UMKM (Jalur Barter & *Cash Task*).
    *   *Tab 2 (Proyek Saya):* Memantau proyek yang sedang dikerjakan (In Progress) dan riwayat yang sudah selesai.
3.  **Mentoring**
    *   Mencari daftar mentor yang tersedia (Dosen praktisi atau *Kating*).
    *   Melihat profil mentor, harga bimbingan (TC/Rupiah), dan melakukan *Booking* jadwal.
4.  **Wallet & Reward**
    *   *Tab 1 (TimeCoin Wallet):* Mengecek detail saldo dan riwayat mutasi koin.
    *   *Tab 2 (Reward Hub):* Menukarkan TimeCoin dengan *voucher* promo dari UMKM.
5.  **Profil**
    *   Menampilkan *Rating* reputasi dan level mahasiswa (misal: *Top Talent*).
    *   **Portofolio:** Daftar riwayat tugas yang berhasil diselesaikan beserta nilai dari UMKM.

### B. Fitur Khusus (Terdapat di dalam Halaman Profil)
*   **Switch to Mentor Mode:** *Toggle* khusus untuk beralih profil menjadi Mentor (Hanya akan muncul dan bisa diklik jika mahasiswa sudah memenuhi syarat reputasi/portofolio minimal).

---

## 2. 🏪 Menu POV: UMKM
*Target Pengguna: Pemilik usaha yang ingin mencari talenta mahasiswa untuk membantu operasional atau digitalisasi.*

### A. Bottom Navigation Bar (Menu Utama)
1.  **Beranda (Dashboard)**
    *   Ringkasan jumlah proyek aktif, jumlah pelamar, dan statistik performa.
    *   *Ikon Top Bar:* **Notifikasi** & **Pesan/Chat** (Untuk diskusi detail tugas dengan mahasiswa).
2.  **Proyek Saya**
    *   Daftar tugas yang telah dipublikasikan.
    *   **Buat Proyek Baru:** Tombol aksi utama (FAB) untuk *posting* lowongan/kerjaan baru.
    *   Pusat **Evaluasi & Rating**: Memberikan nilai Bintang 1-5 dan *review* untuk mahasiswa yang telah menyelesaikan tugas.
3.  **Talent Search (Cari Mahasiswa)**
    *   Eksplorasi/pencarian mahasiswa berdasarkan kemampuan (skill), *rating*, dan pengalaman portofolio.
4.  **Wallet & Premium**
    *   *Tab 1 (TimeCoin Quota):* Mengecek sisa modal TimeCoin (kuota 20 TC bulanan).
    *   *Tab 2 (Premium Access):* Halaman langganan untuk membuka fitur *"Cash Task"* (membayar mahasiswa menggunakan Rupiah untuk merekrut talenta terbaik).
5.  **Profil UMKM**
    *   Informasi usaha, deskripsi toko, galeri produk, dan status verifikasi akun.

---

## 3. 💼 Menu POV: Mentor
*Target Pengguna: Profesional industri atau Mahasiswa Kating (Peer-to-Peer) yang membuka jasa bimbingan.*

### A. Bottom Navigation Bar (Menu Utama)
1.  **Beranda (Dashboard)**
    *   Ringkasan jadwal mentoring hari ini/minggu ini.
    *   Laporan total pendapatan (TC & Rupiah) sekilas.
    *   *Ikon Top Bar:* **Notifikasi** & **Pesan/Chat** (Jalur komunikasi dengan mahasiswa).
2.  **Kelola Booking**
    *   Daftar permintaan bimbingan masuk (Pending) untuk di-ACC atau ditolak.
    *   Jadwal *meeting* yang akan datang beserta *link* ruang kerja virtual (contoh: GMeet/Zoom).
3.  **Jasa Mentoring (Lapak)**
    *   Pengaturan bidang keahlian, deskripsi kelas, durasi sesi, dan pasang tarif (dalam TC maupun Rupiah).
4.  **Wallet & Cash-Out**
    *   Rincian saldo masuk dari hasil mengajar.
    *   **Tarik Dana (Cash-Out):** Form pengajuan pencairan TimeCoin menjadi Rupiah yang ditransfer ke rekening pribadi.
5.  **Profil Mentor**
    *   Ulasan (*Review* & *Rating*) dari anak didik sebelumnya.
    *   Akses ke fitur **Featured Mentor** (Langganan premium berbayar agar profil selalu disorot di urutan teratas pencarian).
