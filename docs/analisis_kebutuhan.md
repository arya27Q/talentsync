# Dokumen Analisis Kebutuhan Sistem (Software Requirements Specification - SRS)
**Aplikasi:** TalentSync — Platform Kolaborasi Mahasiswa, UMKM, dan Mentor  
**Mata Kuliah:** Pemrograman Aplikasi Bergerak (Kelas 2024A)  
**Program Studi:** S1 Sistem Informasi, Fakultas Teknik, Universitas Negeri Surabaya (2026)  
**Tim Penyusun:**
- Musa Chang Li Panjaitan (24051214004)
- Owen Cita Karmanto (24051214011)
- Arya Pratama Yudhistira (24051214017)
- Andika Octavianto (24051214026)

---

## 1. Pendahuluan

### 1.1 Latar Belakang
Perkembangan teknologi informasi membuka peluang luas bagi mahasiswa untuk memperoleh pengalaman kerja nyata dan membangun portofolio profesional, sekaligus membantu Usaha Mikro, Kecil, dan Menengah (UMKM) dalam memenuhi kebutuhan digitalisasi usaha. Kendati demikian, beberapa tantangan nyata dihadapi oleh para pihak:
1. Mahasiswa sering kali kesulitan memperoleh proyek nyata pertama karena belum memiliki rekam jejak portofolio yang terpercaya.
2. UMKM memerlukan tenaga pendukung untuk tugas-tugas digital, namun memiliki keterbatasan anggaran dan kesulitan menemukan talenta yang terverifikasi keahliannya.
3. Praktisi/Mentor memiliki keahlian yang dapat dibagikan, namun belum memiliki media terintegrasi yang menghubungkan bimbingan keterampilan dengan penyelesaian proyek riil di lapangan.

TalentSync hadir sebagai solusi aplikasi *mobile* berbasis Flutter yang menghubungkan ketiga entitas tersebut dalam ekosistem sirkular: **Belajar (Mentoring) $\rightarrow$ Praktik (Proyek UMKM) $\rightarrow$ Reputasi (Portofolio & Rekomendasi).**

### 1.2 Identifikasi Masalah
1. Mahasiswa belum memiliki media kredibel untuk memamerkan keahlian dan mendapatkan kepercayaan pemberi proyek pertama.
2. UMKM belum memiliki mekanisme seleksi talenta mahasiswa yang objektif dan transparan.
3. Belum tersedianya ekosistem terpadu yang memadukan pembelajaran, pengerjaan proyek, penilaian hasil, dan pencatatan riwayat aktivitas.
4. Diperlukan sistem insentif dan transaksi kredit internal yang terstruktur agar interaksi berlangsung aman tanpa spekulasi finansial awal.

### 1.3 Rumusan Masalah
1. Bagaimana merancang dan mengembangkan aplikasi mobile yang menghubungkan mahasiswa, UMKM, dan mentor dalam satu platform?
2. Bagaimana mengimplementasikan fitur pencarian proyek, mentoring, manajemen portofolio, dan penilaian menggunakan Flutter?
3. Bagaimana merancang mekanisme TimeCoin (TC) untuk mendukung pencatatan kredit internal dan pertukaran manfaat antar pengguna?
4. Bagaimana merancang antarmuka dan alur interaksi yang ramah dan konsisten untuk tiga peran pengguna yang berbeda?
5. Bagaimana melakukan pengujian untuk memastikan kestabilan dan validitas fungsionalitas sistem?

### 1.4 Tujuan Pengembangan
- Menghasilkan rancangan aplikasi mobile *multi-role* (Mahasiswa, UMKM, Mentor) dalam satu ekosistem digital.
- Mengimplementasikan fitur utama menggunakan Flutter dengan UI yang bersih, ergonomis, dan modern.
- Menyediakan fasilitas manajemen proyek (*Kanban/workspace*), mentoring terpandu, portofolio digital, dan sistem ulasan bintang.
- Mengembangkan mekanisme TimeCoin sebagai kredit internal aplikasi yang tercatat secara aman di backend.
- Melakukan verifikasi dan pengujian fungsional serta antarmuka secara komprehensif.

### 1.5 Manfaat Pengembangan
- **Bagi Mahasiswa:** Wadah mendapatkan proyek nyata, mentoring industri, portofolio terverifikasi, dan penghasilan/reward TimeCoin (bisa dicairkan dengan biaya admin 0%).
- **Bagi UMKM:** Akses ke talenta mahasiswa berbiaya terjangkau dengan keahlian terkurasi mentor, sistem pelacakan progres transparan, dan hasil kerja tervalidasi.
- **Bagi Mentor:** Media berbagi ilmu secara terstruktur, monetisasi keahlian lewat kelas berbayar TimeCoin, dan pemberian *endorsement* bagi murid unggulan.
- **Bagi Tim Pengembang:** Penerapan nyata rekayasa perangkat lunak bergerak, arsitektur client-server (Flutter + Laravel + PostgreSQL), manajemen state, dan integrasi API RESTful.

### 1.6 Batasan Masalah
1. Aplikasi difokuskan pada platform **Android Mobile** menggunakan kerangka kerja **Flutter**.
2. Sistem mencakup tiga peran utama: **Mahasiswa**, **Mitra UMKM**, dan **Mentor**.
3. Layanan backend menggunakan **Laravel RESTful API** dengan basis data relasional **PostgreSQL**.
4. TimeCoin (TC) pada tahap awal berfungsi sebagai **kredit internal aplikasi** yang divalidasi penuh di sisi backend.
5. Pembayaran eksternal dan integrasi gateway pembayaran nyata bersifat opsional/tahap lanjutan; pencairan dana mengacu pada rasio nilai dasar rancangan ($1\text{ TC} = \text{Rp}1.000$).
6. Pengujian difokuskan pada pengujian fungsional, antarmuka, akses peran, dan validitas transaksi.

---

## 2. Deskripsi Pengguna dan Hak Akses

| Peran | Syarat Verifikasi | Hak Akses Utama |
|---|---|---|
| **Mahasiswa** | Kartu Tanda Mahasiswa (KTM) yang valid | - Mengelola profil dan portofolio karya.<br>- Menjelajahi dan melamar proyek UMKM.<br>- Mengikuti kelas mentoring menggunakan TimeCoin.<br>- Mengerjakan tugas pada Kanban workspace dan mengunggah deliverable.<br>- Menerima ulasan, rating, dan transfer TimeCoin.<br>- Mengaktifkan fitur *Switch as a Mentor* jika telah menyelesaikan $\ge 5$ proyek dengan performa baik.<br>- Melakukan pencairan (*cash-out*) TimeCoin ke Rupiah dengan biaya admin 0%. |
| **Mitra UMKM** | Identitas Pemilik & Profil Usaha yang sah | - Mengelola profil usaha.<br>- Mempublikasikan kebutuhan proyek beserta rincian tugas dan imbalan TimeCoin.<br>- Menyeleksi pelamar proyek berdasarkan portofolio dan *Badge Rekomendasi Mentor*.<br>- Memantau progres pengerjaan pada Kanban.<br>- Mengevaluasi hasil akhir (*deliverable*), meminta revisi, atau menyetujui.<br>- Memberikan rating, ulasan, dan mentransfer imbalan TimeCoin.<br>- Berlangganan paket Premium untuk kuota posting lebih banyak dan filter talenta rekomendasi. |
| **Mentor** | Verifikasi Keahlian & Portofolio Profesional | - Mengelola profil keahlian dan tarif kelas.<br>- Membuat dan mengelola jadwal sesi mentoring.<br>- Mengajar melalui tautan video call dan memberikan umpan balik tugas.<br>- Menerima kredit TimeCoin dari peserta mentoring.<br>- Memberikan *Badge Rekomendasi Kerja (Endorsement)* kepada mahasiswa berprestasi.<br>- Menarik saldo TimeCoin ke Rupiah (Freemium: potongan biaya admin 10%, Premium: 0% biaya admin). |

---

## 3. Analisis Kebutuhan Fungsional (Functional Requirements)

Berikut adalah daftar kebutuhan fungsional sistem (FR-01 s/d FR-12):

| Kode FR | Nama Kebutuhan | Pengguna | Deskripsi Spesifikasi |
|---|---|---|---|
| **FR-01** | Autentikasi & Profil Akun | Semua Pengguna | Sistem harus menyediakan pendaftaran, login, pemilihan peran (Mahasiswa/UMKM/Mentor), verifikasi identitas (KTM/usaha), serta edit profil pengguna. |
| **FR-02** | Manajemen Hak Akses & Peran | Sistem | Sistem harus membatasi akses antarmuka dan endpoint API sesuai peran akun aktif yang terotentikasi token Bearer. |
| **FR-03** | Eksplorasi & Pelamaran Proyek | Mahasiswa | Mahasiswa dapat mencari, memfilter proyek berdasarkan kategori/imbalan, melihat detail proyek, dan mengajukan lamaran beserta portofolio/badge mentor. |
| **FR-04** | Publikasi & Manajemen Proyek | UMKM | UMKM dapat membuat proyek baru, menentukan deskripsi tugas, syarat, kuota imbalan TimeCoin, dan membatasi pelamar (khusus talenta ber-badge jika premium). |
| **FR-05** | Seleksi Pelamar & Kontrak | UMKM | UMKM dapat melihat daftar pelamar, membaca portofolio, menerima kandidat terpilih, atau menolak pelamar yang tidak sesuai. |
| **FR-06** | Penyerahan Hasil (*Deliverable*) | Mahasiswa | Mahasiswa dapat mengunggah tautan/berkas hasil pekerjaan, mencatat progres pada activity tracker, dan mengajukan validasi akhir. |
| **FR-07** | Pengelolaan Sesi Mentoring | Mentor | Mentor dapat membuat jadwal kelas, menentukan topik keahlian, membagikan link video call, dan menetapkan tarif pendaftaran dalam satuan TimeCoin. |
| **FR-08** | Pendaftaran Mentoring | Mahasiswa | Mahasiswa dapat meninjau profil mentor, memesan sesi (*Book Session*), dan melakukan konfirmasi pendaftaran dengan pemotongan saldo TimeCoin. |
| **FR-09** | Rating & Ulasan Proyek | UMKM, Mahasiswa | UMKM memberikan rating bintang (1-5) dan ulasan tertulis saat proyek diselesaikan. Ulasan otomatis masuk ke reputasi publik profil mahasiswa. |
| **FR-10** | Portofolio & Endorsement Mentor | Mahasiswa, Mentor | Mahasiswa dapat menautkan hasil kerja ke galeri portofolio. Mentor dapat menyematkan *Badge Rekomendasi Kerja* (*Endorsement*) pada murid yang kompeten. |
| **FR-11** | Manajemen Saldo & Transaksi TimeCoin | Semua Pengguna | Sistem mencatat mutasi kredit internal TimeCoin (pemberian imbalan, bayar kelas, top-up, tukar voucher promo, penarikan dana) dalam buku besar (*ledger*) yang konsisten. |
| **FR-12** | Manajemen Paket Langganan Premium | UMKM, Mentor | Sistem menyediakan status akun Freemium dan Premium. UMKM premium mendapat kuota posting ekstra dan filter rekomendasi. Mentor premium bebas potongan admin cash-out. |

---

## 4. Analisis Kebutuhan Nonfungsional (Non-Functional Requirements)

1. **Kemudahan Penggunaan (Usability):**
   - Menggunakan bahasa antarmuka yang ramah, jelas, dan baku (Bahasa Indonesia / English).
   - Mengadopsi palet warna hangat konsisten: `AppColors.primaryTan` (`#B88656`), `AppColors.darkBrown` (`#4D332D`), dan `AppColors.warmOffWhite` (`#F9F6F0`).
   - Elemen interaktif tombol aksi utama wajib berwarna solid coklat dengan kontras teks putih yang jelas.
2. **Keamanan (Security):**
   - Transmisi data wajib menggunakan protokol terenkripsi HTTPS.
   - Kata sandi disimpan dengan algoritma hashing aman (*bcrypt/argon2*) pada backend.
   - Autentikasi API menggunakan token standar *Laravel Sanctum*.
   - Validasi kepemilikan data (*authorization policy*) wajib diterapkan sebelum operasi mutasi data.
3. **Integritas Data (Data Integrity):**
   - Setiap mutasi saldo TimeCoin wajib dibungkus dalam *database transaction* (ACID) di backend untuk mencegah *race condition* atau saldo ganda.
   - Nilai saldo tidak boleh dimanipulasi secara langsung dari sisi aplikasi mobile.
4. **Kinerja (Performance):**
   - Waktu respons pemanggilan API utama ditargetkan di bawah 1 detik pada koneksi internet normal.
   - Pemuatan daftar data panjang (proyek, mentor, riwayat) menggunakan *pagination* atau *lazy loading*.
5. **Kompatibilitas (Compatibility):**
   - Mendukung perangkat Android dengan sistem operasi Android 8.0 (Oreo / API level 26) ke atas.
   - Tata letak responsif untuk berbagai resolusi layar ponsel Android.
6. **Kemudahan Pemeliharaan (Maintainability):**
   - Kode Flutter disusun menggunakan pendekatan **Feature-First Architecture** dan state management terstruktur.
   - Backend disusun dengan kaidah MVC / Service-Repository pattern di Laravel.
7. **Privasi & Perlindungan Data (Privacy):**
   - Dokumen verifikasi identitas (seperti KTM) hanya dapat diakses oleh administrator sistem untuk keperluan validasi akun.

---

## 5. Model Ekonomi & Kebijakan Monetisasi

### 5.1 Skema TimeCoin (TC)
- Nilai konversi referensi rancangan: $1\text{ TC} \approx \text{Rp}1.000$.
- **Distribusi Awal:**
  - Mahasiswa: Saldo awal 0 TC (dapat diperoleh dari bonus sambutan onboarding atau top-up modal awal).
  - UMKM: Kuota dasar operasional posting proyek (hingga 20 TC - 500 TC sesuai paket).
  - Mentor: Saldo awal 0 TC (diperoleh dari mahasiswa yang mendaftar kelas mentoring).

### 5.2 Skema Monetisasi & Cash-Out
1. **Mitra UMKM:**
   - *Freemium:* Kuota dasar posting proyek terbatas.
   - *Premium:* Berlangganan bulanan untuk kuota posting tak terbatas, filter pelamar ber-badge mentor, dan undangan talenta langsung.
2. **Mentor:**
   - *Freemium:* Bebas membuka kelas, namun pencairan saldo TimeCoin ke rekening bank dikenakan potongan biaya layanan platform sebesar **10%**.
   - *Premium:* Bebas biaya admin (potongan **0%** saat *cash-out* ke Rupiah) dan visibilitas profil dipromosikan ke halaman utama.
3. **Mahasiswa:**
   - Seluruh fitur pencarian proyek, pelamaran, dan workspace bebas biaya (*100% gratis*).
   - Mahasiswa berhak mencairkan saldo TimeCoin hasil pengerjaan proyek ke Rupiah dengan **0% potongan admin**, karena TalentSync dirancang sebagai platform pemberdayaan karier mahasiswa.

