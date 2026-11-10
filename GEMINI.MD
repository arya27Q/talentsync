# 🧠 GEMINI.MD — TalentSync Knowledge Base & Agent Guidelines

Dokumen ini adalah **pedoman memori utama (living documentation)** bagi asisten AI (Gemini / Antigravity) saat mengelola, mengembangkan, dan memodifikasi proyek **TalentSync**. Berkas ini merangkum seluruh hasil analisis, aturan baku desain, preferensi pengguna, arsitektur teknis, serta log penyelesaian masalah (*troubleshooting log*) agar agen **TIDAK PERLU menganalisis ulang dari awal** dan dapat langsung bertindak secara konsisten.

---

## 📌 1. Identitas & Gambaran Proyek

* **Nama Aplikasi:** TalentSync
* **Kategori:** Mobile Application (Pendidikan, Portofolio, Kolaborasi Proyek & Mentoring)
* **Mata Kuliah:** Pemrograman Aplikasi Bergerak (Kelas 2024A)
* **Program Studi:** S1 Sistem Informasi, Fakultas Teknik, Universitas Negeri Surabaya (2026)
* **Tim Pengembang:**
  * Musa Chang Li Panjaitan (24051214004)
  * Owen Cita Karmanto (24051214011)
  * Arya Pratama Yudhistira (24051214017)
  * Andika Octavianto (24051214026)
* **Stack Teknologi:**
  * **Frontend:** Flutter (Dart), arsitektur *Feature-First*
  * **Backend:** Laravel RESTful API (PHP)
  * **Basis Data:** PostgreSQL (Relasional)
  * **Desain UI/UX:** Figma

---

## 🎨 2. Aturan Baku Desain UI/UX: Panduan Anti "AI Slop" (WAJIB DIPATUHI)

Pengguna secara tegas **MENOLAK tampilan bergaya "AI Slop"** (desain artifisial murahan khas hasil generate AI yang norak, terlalu ramai, tidak konsisten, atau hampa). Seluruh layar dan komponen UI pada TalentSync **WAJIB** menerapkan standar desain manusia profesional (*Human-Crafted Clean UI*).

Berikut adalah katalog rinci ciri-ciri **AI Slop yang DILARANG KERAS** beserta **Standar Baku Penggantinya**:

### 🚫 2.1 Tipografi & Font Slop
* ❌ **AI Slop yang Dilarang:**
  - Menggunakan lebih dari 2 jenis *font family* dalam satu aplikasi.
  - Memakai font dekoratif/script/tulisan tangan pada antarmuka profesional.
  - Berat font (*font weight*) yang acak tanpa hirarki (misal teks keterangan biasa dibuat w900, atau judul dibuat tipis w200).
  - Teks menggunakan gradien warna-warni neon (misal teks judul bergradien ungu-pink-cyan).
  - Menyelipkan emoticon/emoji sembarangan di samping teks salam atau judul (contoh: *"Good morning ☀️"*, *"Hot Projects 🔥🚀"*, *"Earn Coins 💰✨"*).
  - Menggunakan huruf kapital semua (*ALL CAPS*) secara berlebihan dengan spasi huruf (*letter-spacing*) yang aneh.
* ✅ **Standar Baku TalentSync:**
  - Font tunggal bersih dan profesional (gunakan standar `GoogleFonts.plusJakartaSans` atau `GoogleFonts.inter` / sistem bawaan).
  - Skala tipografi teratur:
    * *Large Title:* `fontSize: 24 - 28`, `fontWeight: FontWeight.bold`, warna Slate 900 (`0xFF0F172A`) atau Dark Brown (`0xFF4D332D`).
    * *Section Title:* `fontSize: 18 - 20`, `fontWeight: FontWeight.bold`.
    * *Card Title / Subtitle:* `fontSize: 14 - 16`, `fontWeight: FontWeight.w600`.
    * *Body Text:* `fontSize: 13 - 14`, `fontWeight: FontWeight.normal`, warna teks abu-abu gelap `Colors.grey.shade700` atau Slate 500 (`0xFF64748B`).
    * *Caption / Meta:* `fontSize: 11 - 12`, `fontWeight: FontWeight.w500`, warna `Colors.grey.shade500`.
  - Teks bersih dari emoji kartun dekoratif!

### 🚫 2.2 Ikonografi & Emoticon Slop
* ❌ **AI Slop yang Dilarang:**
  - Menggunakan stiker kartun 3D, emoji tanah liat (*clay 3D emoji*), atau ikon bergaya stiker mainan anak-anak.
  - Mencampuradukkan berbagai gaya ikon dalam satu layar (misal: ada ikon *line-art* tipis, tiba-tiba ada ikon *duotone*, ikon *sharp*, dan ikon *filled* tebal).
  - Menggunakan emoji ponsel standar sebagai ikon menu/tombol/tab.
  - Memberikan *glow neon* atau lingkaran gradien mencolok di belakang ikon sederhana.
* ✅ **Standar Baku TalentSync:**
  - **100% Native Material Icons Rounded (`Icons.<name>_rounded`):**
    * Status Proyek Aktif: `Icons.bolt_rounded`
    * Status Proyek Selesai: `Icons.task_alt_rounded`
    * Penilaian / Rating: `Icons.star_rounded` (warna Warm Amber Gold `Color(0xFFF59E0B)`)
    * TimeCoin / Kredit: `Icons.toll_rounded` (warna Amber Gold `Color(0xFFF59E0B)` / Primary Tan)
    * Filter / Penyesuaian: `Icons.tune_rounded`
    * Tenggat Waktu / Kalender: `Icons.access_time_rounded` / `Icons.calendar_today_rounded`
    * Navigasi Kembali: `Icons.keyboard_arrow_left_rounded`
    * Tambah / Unggah: `Icons.add_rounded` / `Icons.upload_file_rounded`
  - Ikon berukuran proporsional: navigation bar `24-26`, button `18-20`, list item `20-22`, tag chip `14-16`.

### 🚫 2.3 Grid, Posisi, Alignment & Spacing Slop
* ❌ **AI Slop yang Dilarang:**
  - Kartu pada Grid/List memiliki tinggi yang jomplang atau tidak sejajar (*broken masonry grid* tanpa perhitungan aspek rasio).
  - *Russian-Doll Containers:* Membungkus widget secara berlebihan tanpa fungsi (misal: `Padding` di dalam `Container` di dalam `Padding` di dalam `Container`).
  - *Border-in-border-in-border:* Kartu punya garis pinggir, di dalamnya ada kontainer bergaris pinggir, di dalamnya ada chip bergaris pinggir tebal.
  - Nilai padding/margin acak (misal: `left: 17`, `right: 23`, `top: 7`, `bottom: 31`).
  - Elemen di dalam `Row` tidak rata tengah secara vertikal (lupa menambahkan `crossAxisAlignment: CrossAxisAlignment.center`), sehingga teks dan ikon terlihat melayang tidak sejajar.
  - Badge mengambang yang menutupi teks judul atau tombol aksi.
  - Konten menempel ke pinggir layar tanpa `SafeArea` atau margin horizontal.
* ✅ **Standar Baku TalentSync:**
  - Gunakan sistem kelipatan 4pt / 8pt grid (`4`, `8`, `12`, `16`, `20`, `24`, `32`).
  - Margin horizontal layar konsisten: selalu `20.0` atau `24.0` px (`EdgeInsets.symmetric(horizontal: 24)`).
  - Setiap kartu memiliki susunan hierarki yang jelas dari atas ke bawah:
    1. *Header:* Avatar/Logo + Judul + Rating/Status
    2. *Body:* Deskripsi ringkas (maks 2-3 baris dengan `TextOverflow.ellipsis`)
    3. *Meta/Tags:* Chip keahlian horizontal (`Wrap` dengan `spacing: 8`)
    4. *Action:* Tombol aksi primer di bagian bawah dengan lebar penuh (`double.infinity`).
  - Spasi antar elemen kartu di dalam `ListView` konsisten menggunakan `const SizedBox(height: 16)` atau `12`.

### 🚫 2.4 Warna, Gradien & Shadow Slop
* ❌ **AI Slop yang Dilarang:**
  - Gradien cyberpunk neon ungu-cyan (*crypto/web3 aesthetic*) yang tidak relevan dengan platform edukasi/proyek UMKM.
  - Bayangan neon berpendar (*neon glow shadows*) dengan `blurRadius: 40`, `spreadRadius: 10`, warna menyala terang.
  - Menumpuk 5 jenis warna abu-abu dan putih yang bertabrakan di latar belakang.
  - Efek *Glassmorphism* berlebihan (`BackdropFilter` blur berat + border putih 1px) yang merusak keterbacaan teks dan menurunkan performa render Flutter (*frame drop*).
* ✅ **Pilihan Palet Resmi TalentSync:**
  
  **Opsi Utama / Terbuka — "Trust & Growth" (Deep Royal Navy & Warm Amber Gold) [Rekomendasi Utama]:**
  * `primaryNavy`: `Color(0xFF1E3A8A)` — Warna aksi utama, tombol CTA, identitas profesional & kredibilitas.
  * `darkSlate`: `Color(0xFF0F172A)` — Teks judul utama, header, dan elemen kontras tinggi.
  * `secondarySlate`: `Color(0xFF64748B)` — Keterangan body, subtitle, dan label pendukung.
  * `canvasWhite`: `Color(0xFFF8FAFC)` — Latar belakang canvas bersih, sejuk, dan modern.
  * `accentAmberGold`: `Color(0xFFF59E0B)` — Aksen koin TimeCoin, bintang rating, dan badge prestasi.
  * `borderSlate`: `Color(0xFFE2E8F0)` — Garis pembatas kartu/divider 1px halus.
  * `cardSurface`: `Colors.white` — Latar belakang kartu utama.

  **Opsi Alternatif — "Warm Heritage" (Brown & Tan):**
  * `primaryTan`: `Color(0xFFB88656)` — Warna tombol aksi dan aksen.
  * `darkBrown`: `Color(0xFF4D332D)` — Teks judul & header.
  * `warmOffWhite`: `Color(0xFFF9F6F0)` — Canvas bernuansa hangat.

  **Bayangan Natural Halus:**
  * Kartu: `BoxShadow(color: Color(0xFF0F172A).withValues(alpha: 0.05), blurRadius: 15, offset: Offset(0, 5))`
  * Tombol CTA: `BoxShadow(color: Color(0xFF1E3A8A).withValues(alpha: 0.25), blurRadius: 10, offset: Offset(0, 4))`

### 🚫 2.5 Tombol (Buttons) & Komponen Aksi Slop
* ❌ **AI Slop yang Dilarang:**
  - **DILARANG KERAS tombol model outline tipis putih/transparan:** Tombol aksi utama (seperti *Book Session*, *Open Workspace*, *Apply*) berlatar putih/transparan dengan hanya garis tepi tipis. Ini terlihat kosong, seperti tombol *disabled* atau belum selesai di-*render*.
  - Tombol berbentuk kapsul neon mengkilap (*glossy*) dengan refleksi cahaya imitasi.
  - Tidak ada perbedaan tegas antara tombol utama (*primary*) dan tombol pendukung (*secondary*).
* ✅ **Standar Baku TalentSync:**
  - **Primary Action Button (Tombol Aksi Utama):**
    ```dart
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Navy solid (atau AppColors.primaryTan)
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Book Session', // Teks aksi jelas
          style: TextStyle(
            color: Colors.white, // Teks putih bersih
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    )
    ```
  - **Secondary Button:** Menggunakan latar belakang netral, teks tebal, tanpa shadow mencolok.
  - **Tag / Skill Chip:**
    * Latar belakang: `Color(0xFFF1F5F9)` atau `AppColors.warmOffWhite`
    * Teks: Tebal kontras, `fontSize: 10 - 12`, `fontWeight: FontWeight.bold`
    * Sudut melengkung: `BorderRadius.circular(8)`

### 🚫 2.6 Micro-Copy & Gimmick Palsu Slop
* ❌ **AI Slop yang Dilarang:**
  - Badge "LIVE" berkedip merah palsu pada kartu mentor offline.
  - Kalimat klise kecerdasan buatan (*"AI-powered hyper synergy"*, *"Revolutionize your journey"*).
  - Statistik palsu dengan roket (*"🚀 99,999+ Super Students Joined"*).
* ✅ **Standar Baku TalentSync:**
  - Micro-copy lugas, fungsional, dan ramah: *"Book Session"*, *"Open Workspace"*, *"Apply"*, *"Validasi Hasil & Transfer 150 TimeCoin"*, *"Session in Progress"*.

---

## 💻 3. Aturan Teknis Flutter & Lingkungan Eksekusi

### 3.1 Penamaan Package & Import
* **Nama Package:** `flutter_frontend` (nama lama `skillswap_frontend` sudah diganti total).
* Setiap kali mengimpor berkas internal, **selalu gunakan:**
  ```dart
  import 'package:flutter_frontend/...';
  ```
* Jangan pernah menggunakan `package:skillswap_frontend/...`.

### 3.2 Eksekusi Perintah di Windows & Sandbox
* **Masalah:** Lingkungan sandbox default Windows pada terminal ini mengalami:
  `CreateProcessSecurityEnvironment: The system cannot find the path specified`.
* **Solusi Baku:**
  * Jalankan perintah CLI (PowerShell, Flutter, Git, dll.) dengan parameter **`BypassSandbox: true`**.
* **Path Flutter SDK:**
  * Gunakan path lengkap: `C:\flutter\bin\flutter.bat`.
* **Verifikasi Kode (Quality Gate):**
  * Setiap selesai mengedit file Dart, jalankan verifikasi:
    ```powershell
    C:\flutter\bin\flutter.bat analyze c:\laragon\www\talentsync\flutter_frontend
    ```
  * Pastikan selalu menghasilkan: **`No issues found!`**.

### 3.3 Penanganan File di Windows (CRLF vs LF)
* Di Windows, tool `edit_file` sering gagal (*target content not found*) akibat perbedaan karakter *newline* (CRLF `\r\n` vs LF `\n`).
* **Solusi Baku:**
  * Gunakan skrip PowerShell dengan `[System.IO.File]::ReadAllLines` / `[System.IO.File]::WriteAllLines` atau `write_file` dengan `Overwrite: true`.

---

## 🔄 4. Log Masalah yang Pernah Terjadi & Solusinya (Troubleshooting Log)

Bagian ini mencatat setiap masalah teknis yang pernah dihadapi agar agen langsung menerapkan solusinya:

| Tanggal | Masalah | Penyebab | Solusi Permanen |
|---|---|---|---|
| 2026-10-29 | Error import `package:skillswap_frontend/...` | Nama package lama masih tertinggal di `pubspec.yaml` dan seluruh file Dart. | Ubah `name: flutter_frontend` di `pubspec.yaml`, ganti seluruh import ke `package:flutter_frontend/`, dan jalankan `flutter pub get`. |
| 2026-10-29 | Missing package `google_fonts` | Layar menggunakan GoogleFonts namun package belum terpasang di `pubspec.yaml`. | Tambahkan `google_fonts: ^6.2.1` ke `dependencies` di `pubspec.yaml` dan jalankan `flutter pub get`. |
| 2026-10-29 | Sandbox terminal error `CreateProcessSecurityEnvironment` | Pembatasan hak akses sandbox Windows. | Setiap eksekusi command line wajib menyertakan flag `BypassSandbox: true`. |
| 2026-10-29 | Tool `edit_file` gagal mencocokkan target teks | Format akhiran baris Windows CRLF (`\r\n`) tidak cocok dengan target string. | Gunakan penggantian baris spesifik via PowerShell `[System.IO.File]::ReadAllLines` atau `write_file(Overwrite: true)`. |
| 2026-10-29 | Warning constructor `HistoryScreen({Key? key})` | Menggunakan sintaks lama bukan super parameters. | Perbarui menjadi `const HistoryScreen({super.key});`. |
| 2026-10-29 | Tombol Book Session/Open Workspace tampak kosong | Tombol menggunakan border outline dan latar transparan/putih. | Ubah dekorasi tombol menjadi solid penuh dengan teks `Colors.white` dan `FontWeight.bold`. |
| 2026-10-29 | Ikon terlihat kekanak-kanakan / gaya AI stiker | Ikon matahari kartun dan ornamen stiker yang tidak profesional. | Bersihkan seluruh ornamen kartun, ganti dengan ikon standar `Icons.*_rounded`. |
| 2026-10-30 | Lint warning `use_null_aware_elements` di Dart 3+ | Menggunakan `if (trailing != null) trailing!` di widget list. | Gunakan sintaks null-aware element: `?trailing,`. |
| 2026-11-02 | Lint info `unnecessary_underscores` di Dart 3.7+ | Pemakaian `(_, __)` pada `separatorBuilder` di `ListView.separated`. | Gunakan `(context, index)` atau single underscore `(_, _)`. |
| 2026-11-02 | Warning deprecated `activeColor` pada `Switch` di Flutter 3.31+ | Flutter SDK versi terbaru mengganti `activeColor` dengan `activeThumbColor`. | Gunakan `activeThumbColor: ...` pada widget `Switch`. |
| 2026-11-02 | Unused element `_buildNavIcon` di `switch_to_mentor_screen.dart` | Method sisa refactoring UI bottom navigation. | Hapus method tidak terpakai agar `flutter analyze` 100% bersih tanpa warning. |
| 2026-11-02 | Layout overflow pada chip estimasi waktu lamaran | Teks panjang pada layar sempit melebihi batas container horizontal. | Bungkus dengan `Expanded` dan `FittedBox(fit: BoxFit.scaleDown)` agar teks otomatis menyesuaikan ukuran layar tanpa overflow. |
| 2026-11-04 | Hapus referensi SKS & ubah auth mahasiswa ke KTM | Konsep kurikulum kampus SKS dihilangkan agar fokus pada ekosistem proyek nyata & portofolio; login mahasiswa diarahkan via NIM/KTM (tanpa SSO). | Ganti metrik SKS menjadi 'Proyek Selesai', hapus filter konversi SKS, ubah form login mahasiswa menjadi NIM/KTM, dan hapus SSO kampus. |
| 2026-11-04 | Standardisasi Bahasa Indonesia & Footer Nav | Masih terdapat istilah bahasa Inggris (Explore, My Tasks, Wallet, Profile) pada footer mahasiswa. | Ganti seluruh label bottom nav menjadi 'Eksplorasi', 'Tugas Saya', 'Dompet', dan 'Profil'. |
| 2026-11-04 | Redesain Pendaftaran Mentor Peer (Bukan Profesional) | Halaman register mentor sebelumnya bertuliskan 'Mentor Profesional' dengan form CV korporat. | Rombak total `mentor_register_screen.dart` menjadi Peer Mentor (mahasiswa senior/praktisi muda) dengan tarif terjangkau TC, bukti portofolio, dan kode etik bimbingan. |
| 2026-11-04 | Standardisasi Icon Rounded & Banner Showcase Mentor | Konsistensi ikon Style #1 (Material Icons Rounded) dan penambahan banner ruang kolaborasi visual di dashboard mentor. | Terapkan seluruh icon ke Icons.*_rounded, perbaiki typo getter icon, dan sematkan _buildVisualCollaborationBanner foto kerja kolaboratif bergradien gelap. |
| 2026-11-04 | Standardisasi 100% Seluruh Halaman ke Style #1 | Menyelaraskan seluruh modul (Auth, Mahasiswa, Mitra UMKM, Project, Mentoring, Portfolio, Wallet, Workspace) ke Material Icons Rounded & font bawaan Flutter. | Konversi 52 jenis icon varian outlined ke Icons.*_rounded di 48 berkas layar tanpa mengubah struktur logika bisnis, rute, atau layout yang sudah ada. |
| 2026-11-04 | Penggantian Icon Petir & Penambahan Interactive Carousel Gambar | Menghilangkan seluruh icon petir (bolt) ke icon kerja/progress profesional dan menambahkan carousel foto interaktif dengan tombol geser di Dashboard Mahasiswa, Dashboard UMKM, Store Profile UMKM, Postings UMKM, & Barter UMKM. | Ganti Icons.bolt_rounded ke timelapse/assignment/verified_user, buat InteractiveImageCarousel di core/widgets, dan sematkan galeri visual interaktif dengan kontrol prev/next & slide dots. |
| 2026-11-05 | Spacing Chip Barter, Format Saldo TC/Rupiah & Navigasi Mentor | Chip voucher pada layar barter UMKM dempet saat membungkus baris, teks kuota sosial belum mencantumkan nominal Rupiah, saldo mentor menampilkan Rupiah di atas TC, 3 kartu metrik mentor tingginya tidak presisi dan memiliki interaksi klik yang tidak diinginkan. | Tambahkan runSpacing: 10 pada Wrap voucher barter UMKM, ubah teks kuota sosial menjadi Setara Rp520.000, posisikan TC di bagian atas dengan Rupiah di bawahnya pada dashboard mentor, buat 3 kartu metrik menjadi display-only dengan IntrinsicHeight & SizedBox(height: 28), serta bangun kartu navigasi kerja mentor tersendiri dengan tombol aksi eksplisit (_buildQuickNavButton). |
| 2026-11-05 | Aksesibilitas Tombol Logout Mahasiswa & Ekosistem Segitiga | Mahasiswa kesulitan keluar dari sesi akun karena dashboard utama tidak memiliki tombol logout dan pada profil opsi logout tertimbun di bawah serta gear salah membuka editProfile. | Tambahkan tombol Logout merah eksplisit di header Dashboard Mahasiswa, header Profil Mahasiswa (berdampingan dengan Settings), sediakan kartu dedicated Sesi Akun di bagian bawah profil, pasang dialog konfirmasi _showLogoutConfirmation, serta integrasikan UI jembatan ekosistem (Tolak & Arahkan Bimbingan Mentor oleh UMKM, Banner Pendampingan Mentor di Kanban). |
| 2026-11-05 | Efek Loading Transisi Login ke Beranda (3 POV) | Perpindahan dari login menuju dashboard terjadi seketika tanpa indikator visual, berpotensi memicu double tap atau kebingungan pengguna. | Pasang state _isLoading asinkron (~1100ms) dengan spinner CircularProgressIndicator + micro-copy verifikasi peran ('Memverifikasi Mahasiswa...', 'Memverifikasi Mitra UMKM...', 'Memverifikasi Mentor...'), kunci input layar dengan AbsorbPointer, dan nonaktifkan tombol selama proses autentikasi berlangsung. |
| 2026-11-05 | Fitur Proyek Kustom di Create Task Wizard UMKM | Layar Create Task Wizard UMKM awalnya hanya menyediakan 6 template baku tanpa jalan keluar bagi UMKM yang memiliki kebutuhan proyek spesifik (misal video reels/TikTok, SOP inventaris toko, terjemahan menu, audit pembukuan). | Tambahkan kartu template 'Kebutuhan Kustom' (ikon tune_rounded), sematkan banner callout eksplisit di bawah grid ('Tidak menemukan kebutuhan usahamu? Tulis Proyek Kustom Sendiri'), dan sediakan modal form interaktif _showCustomProjectDialog untuk menentukan judul, kategori keahlian, alokasi imbalan TC, serta ringkasan tugas bebas. |
| 2026-11-05 | In-App Guide & Artikel Interaktif Berfoto di 3 Dashboard | Dashboard terasa kaku dan pengguna baru belum memahami fitur kunci (pencairan TC 0% admin, perolehan badge mentor, switch role mentor, smart escrow, posting proyek kustom, standar QA evaluasi). | Bangun widget modular InAppGuideSection di core/widgets lengkap dengan InAppArticle & bottom sheet reader interaktif, lalu sematkan carousel artikel edukatif berfoto Unsplash di Dashboard Mahasiswa, Dashboard UMKM, dan Dashboard Mentor. |
| 2026-11-05 | Fix White Screen: Horizontal Viewport Unbounded Width | Widget InAppGuideSection sempat terpanggil di dalam Row kartu rekomendasi/tahap kerja sehingga menerima lebar horizontal tak hingga (w <= Infinity) yang memicu crash render Flutter (layar putih). | Relokasi pemanggilan widget ke Column utama di luar Row, serta bungkus horizontal carousel dengan LayoutBuilder + width: availableWidth (fallback MediaQuery.sizeOf) agar kebal terhadap batasan unbounded. |
| 2026-11-05 | Tombol Navigasi Cepat 3 Kartu Metrik Dashboard Mitra UMKM | 3 kartu metrik UMKM sebelumnya pasif tanpa tombol aksi eksplisit, menyulitkan UMKM untuk langsung melompat mengelola proyek atau mereview pelamar. | Tambahkan header seksi 'Navigasi Cepat & Status' dengan badge 'Pilih Aksi', bungkus 3 kartu dengan IntrinsicHeight, tambahkan tombol aksi solid eksplisit di bagian bawah masing-masing kartu ('Kelola' -> Postingan Proyek, 'Review' -> Review Pelamar, 'Tinjau' -> Review Pengajuan Hasil) lengkap dengan animasi tap InkWell dan visual badge indikator status. |
| 2026-11-05 | Lokalisasi 100% Bahasa Indonesia Modul Mitra UMKM | Istilah antarmuka UMKM masih menggunakan bahasa Inggris (Create Task Wizard, My Postings, Review Applicants, Review Submission, Store Profile, Business Portal, Upgrade Slot, dsb.). | Lokalisasi menyeluruh ke Bahasa Indonesia baku pada 14 berkas UMKM ('Panduan Buat Tugas', 'Postingan Tugas Saya', 'Tinjau Pelamar', 'Tinjau Pengajuan Hasil', 'Profil Toko & Usaha', 'Portal Mitra UMKM', 'Tambah Slot', 'Tingkatkan', dsb.) tanpa mengubah hierarki widget, tata letak, logika bisnis, atau komponen sedikitpun. |
| 2026-11-05 | Pembuatan Dokumen PDF Progres Pengembangan UI/UX | Pengguna membutuhkan laporan kemajuan pengembangan resmi untuk keperluan laporan mata kuliah Pemrograman Aplikasi Bergerak. | Susun dokumen laporan progres komprehensif berformat PDF (A4 standar akademik) mencakup latar belakang transformasi desain coklat (Desert Sands) & eliminasi AI Slop, penerapan palet Trust & Growth (#1E3A8A & #F59E0B), realisasi Ekosistem Segitiga Hybrid (Proposal Bab I-V & Wireframe), fitur-fitur baru (Carousel interaktif, In-App Guide berfoto, Quick Nav Action, Proyek Kustom Wizard, Loading autentikasi), serta hasil verifikasi lulus flutter analyze & test. File tersimpan di `docs/Laporan_Progres_Pengembangan_TalentSync.pdf` dan root. |
| 2026-11-05 | Integrasi FigCraft MCP & Replikasi Desain UI Flutter | Pengguna meminta integrasi aplikasi desain lokal FigCraft dan replikasi seluruh layar UI Flutter ke dalam format desain FigCraft (.figcraft). | Konfigurasi server FigCraft MCP di `mcp_config.json` via `figcraft-cli mcp`, tambahkan executable ke User PATH Windows, dan bangun 10 layar mobile presisi (Role Selection, Auth Mahasiswa, Dashboard Mahasiswa, Kanban, Switch Mentor, Dashboard UMKM, Wizard Tugas, Tinjau Pelamar, Validasi Hasil, Dashboard Mentor) ke berkas `talentsync_ui_design.figcraft` beserta ekspor pratinjau PNG 10 layar di `docs/figcraft_preview/`. |

---

## 🏛️ 5. Logika Bisnis Inti (Ekosistem Segitiga Hybrid & TimeCoin)

* **3 Entitas Pengguna & Ekosistem Segitiga (Proposal Bab II & Wireframe Hal 15):**
  1. **Mahasiswa:**
     - Syarat wajib melamar proyek UMKM: Memiliki **Portofolio Terverifikasi** ATAU **Badge Rekomendasi dari Mentor**.
     - Jika belum memiliki portofolio: Wajib mencari bimbingan mentor terlebih dahulu (`AppRoutes.findMentors`), menyelesaikan latihan studi kasus di Ruang Belajar, hingga mendapatkan Badge Rekomendasi.
     - Pengerjaan proyek UMKM menghasilkan imbalan TimeCoin (TC) melalui sistem *escrow*.
     - Bebas melakukan pencairan (*Cash-Out*) TC ke Rupiah dengan **0% potongan biaya administrasi** ($1\text{ TC} = \text{Rp}1.000$).
     - Mahasiswa dapat beralih peran menjadi *Peer Mentor* melalui fitur **Switch as a Mentor** setelah menyelesaikan minimal $\ge 5$ proyek UMKM nyata dengan reputasi baik.
  2. **Mitra UMKM:**
     - Mendanai imbalan proyek dengan membeli kredit TimeCoin melalui fitur **Top-Up TimeCoin via Rupiah**.
     - Menyeleksi pelamar berdasarkan riwayat proyek nyata dan kepemilikan Badge Mentor.
     - Menyediakan aksi penolakan edukatif: **"Tolak & Arahkan Bimbingan Mentor"** bagi pelamar yang belum siap.
     - Meminta revisi hasil kerja (*deliverable*) dengan opsi menyarankan mahasiswa berkonsultasi dengan mentor pendamping.
     - Berlangganan paket **Premium UMKM** untuk mendapatkan kuota ekstra hingga 500 TC/bulan, bebas biaya administrasi saat top-up, dan filter pelamar ber-badge mentor.
  3. **Peer Mentor (Mahasiswa Senior / Praktisi Muda):**
     - Membuka kelas bimbingan & konsultasi 1-on-1 dengan tarif TC terjangkau.
     - Bertindak sebagai **Quality Assurance (Penjamin Mutu)** bagi UMKM: Menguji tugas murid (skor $\ge 80$) dan menerbitkan **Badge Rekomendasi Kerja (Endorse)**.
     - Memperoleh TC dari mahasiswa dan mencairkannya ke Rupiah (*Freemium* dipotong biaya admin 10%, *Premium* 0% admin).
* **Konversi Referensi:** $1\text{ TC} \approx \text{Rp}1.000$.

* **Pusat Akses Konsultasi di POV Mahasiswa:**
  1. *Dashboard Mahasiswa:* Seksi dedicated "Konsultasi & Bimbingan" (kartu mentor aktif, jadwal live bimbingan, tombol Jadwal Saya, tombol Masuk Sesi, dan link Cari Mentor).
  2. *Workspace Kanban:* Banner bantuan teknis "Mengalami Kendala Teknis Proyek? Konsultasi dengan Mentor" tepat di bawah kolom Kanban.
  3. *Submission Screen:* Banner pra-pengumpulan "Konsultasi Sebelum Mengumpulkan" untuk review mutu pengerjaan sebelum diserahkan ke UMKM.
  4. *Katalog Mentoring:* Navigasi langsung ke `/mentors` dengan 10 layar pendukung di `lib/features/mentoring/screens/`.

* **Standar Titik Akses Logout Mahasiswa:**
  - Header Dashboard Mahasiswa (di sebelah ikon lonceng notifikasi).
  - Header Profil Mahasiswa (di sebelah ikon gear pengaturan).
  - Kartu dedicated "Sesi Akun Mahasiswa" di bagian bawah layar profil.
  - Menu Pengaturan Mahasiswa (`AppRoutes.settings`).
  - Menu Privasi & Keamanan (`AppRoutes.privacySecurity`).

---

## 🗺️ 6. Peta Direktori & Arsitektur Standar Kode (`flutter_frontend/lib`)

Setiap modul di dalam `lib/features/nama_fitur/` mengadopsi struktur Feature-First terstandar:
```text
features/nama_fitur/
├── data/ (atau services/)  # Pemanggilan API / repository khusus fitur tersebut
├── models/                 # Data model & JSON serialization
├── controllers/            # Logika bisnis & state (pengganti nama 'logic/' atau 'providers/')
├── screens/ (atau views/)  # Halaman utama & modal (pengganti nama 'ui/')
├── widgets/                # Komponen UI pecahan (kartu, header, grafik)
└── utils/ (opsional)       # Helper / konstanta / formatter khusus fitur itu
```

Peta direktori modul aplikasi `flutter_frontend/lib/`:
```text
lib/
├── main.dart                                # Entry point aplikasi
├── role_selection_screen.dart               # Pemilihan peran (Mahasiswa / UMKM / Mentor)
├── splash_screen.dart                       # Splash screen awal
├── core/
│   ├── constants/app_colors.dart            # Definisi warna resmi (primaryNavy/Tan, darkSlate/Brown, canvasWhite)
│   ├── routes/app_routes.dart               # Daftar nama rute aplikasi
│   └── widgets/                             # Widget global (TimeCoinIcon, GradientBackground)
└── features/
    ├── auth/                                # controllers/, data/, models/, screens/, widgets/
    ├── dashboard/                           # controllers/, data/, models/, screens/, widgets/
    ├── project/                             # controllers/, data/, models/, screens/, widgets/
    ├── mentoring/                           # controllers/, data/, models/, screens/, widgets/
    ├── mentor/                              # controllers/, data/, models/, screens/, widgets/
    ├── wallet/                              # controllers/, data/, models/, screens/, widgets/
    ├── workspace/                           # controllers/, data/, models/, screens/, widgets/
    ├── portfolio/                           # controllers/, data/, models/, screens/, widgets/
    ├── profile/                             # controllers/, data/, models/, screens/, widgets/
    ├── notifications/                       # controllers/, data/, models/, screens/, widgets/
    ├── chat/                                # controllers/, data/, models/, screens/, widgets/
    └── gamification/                        # controllers/, data/, models/, screens/, widgets/
```

---
## 📝 7. Prosedur Kerja Agen Selanjutnya (Standard Operating Procedure)

1. **Cek Dokumen Terlebih Dahulu:** Sebelum menjawab atau membuat perubahan, baca `GEMINI.MD` dan berkas terkait di `docs/`.
2. **Jangan Menganalisis Ulang Hal yang Sudah Baku:** Langsung terapkan aturan desain (ikon native, tombol solid kontras, anti AI slop) tanpa bertanya ulang atau mengubah ke gaya lain.
3. **Dokumentasikan Masalah Baru Secara Otomatis:** Jika dalam pengerjaan tugas berikutnya muncul kendala baru (error build, konfigurasi package, penyesuaian rute), agen wajib mencatat temuan dan solusinya ke tabel pada Bagian 4 dokumen ini.
4. **Verifikasi Akhir:** Setiap penulisan kode wajib divalidasi dengan `flutter analyze` hingga dipastikan `No issues found!`.

---

## 📋 8. Master System Prompt (Prompt Awalan Standar Proyek)

Gunakan blok prompt berikut sebagai **pesan awalan** di setiap percakapan AI baru sebelum memberikan prompt detail per halaman. Prompt ini telah mengunci seluruh aturan Anti "AI Slop" dan palet warna **Opsi 1 ("Trust & Growth" — Deep Royal Navy & Amber Gold)**:

```markdown
Kamu adalah Senior Mobile Flutter Developer & UI/UX Specialist untuk proyek aplikasi mobile "TalentSync".

Sebelum saya memberikan prompt untuk pembuatan halaman per halaman, pahami dan PATUHI seluruh arsitektur teknis, sistem warna Opsi 1 (Trust & Growth), dan standar baku desain anti "AI Slop" berikut tanpa pengecualian:

---

### 1. IDENTITAS PROYEK & TEKNIS
- Nama Aplikasi: TalentSync (Platform Kolaborasi Mahasiswa, UMKM, dan Mentor).
- Konsep Ekosistem: Ekosistem Hybrid berbasis kredit internal TimeCoin (TC) dan Rupiah (1 TC ≈ Rp1.000).
- 3 Peran Pengguna:
  1. Mahasiswa (verifikasi KTM, eksplorasi & lamar proyek UMKM, ikut mentoring, mutasi TC, pencairan/cash-out 0% biaya admin, switch as a mentor jika lulus >= 5 proyek).
  2. Mitra UMKM (posting kebutuhan proyek dengan imbalan TC, filter pelamar ber-badge mentor, validasi deliverable, beri ulasan bintang & transfer TC).
  3. Mentor (buka sesi bimbingan berbayar TC, ruang virtual video call, beri Badge Rekomendasi Kerja/Endorse ke murid kompeten, pencairan TC).
- Stack: Flutter (Dart), Feature-First Architecture, State Management Provider/BLoC.
- Package Name & Import: WAJIB menggunakan `package:flutter_frontend/...` (DILARANG menggunakan nama package lain).
- Standar Sintaks: Dart 3+ null safety, constructor modern (`super.key`), null-aware elements (`?trailing`), dan kode bersih lulus `flutter analyze` (0 errors, 0 warnings).

---

### 2. PALET WARNA RESMI: "TRUST & GROWTH" (AppColors)
Terapkan sistem warna profesional berikut pada seluruh komponen UI:
- Primary Action / CTA: `Color(0xFF1E3A8A)` — Deep Royal Navy (Warna utama aksi, tombol CTA, status aktif, identitas profesional).
- Dark Text / Title: `Color(0xFF0F172A)` — Slate 900 (Warna teks judul utama, header, dan elemen kontras tinggi).
- Secondary Text: `Color(0xFF64748B)` — Slate 500 (Warna keterangan body, subtitle, dan label sekunder).
- Background Canvas: `Color(0xFFF8FAFC)` — Slate 50 / Soft Cool White (Latar belakang utama layar yang bersih, modern, dan sejuk).
- Card Surface: `Colors.white` — Latar belakang permukaan kartu utama.
- TimeCoin & Rating Accent: `Color(0xFFF59E0B)` — Warm Amber Gold (Warna ikon TimeCoin, bintang rating, dan badge prestasi).
- Border Line: `Color(0xFFE2E8F0)` — Slate 200 (Garis pembatas halus tipis 1px).

---

### 3. PANDUAN KETAT ANTI "AI SLOP" (WAJIB DIPATUHI)
Saya MENOLAK tampilan bergaya generik hasil generate AI yang norak dan murahan. Semua layar WAJIB menerapkan standar desain manusia profesional (Human-Crafted Clean UI):

1. 🚫 TIPOGRAFI:
   - DILARANG menggunakan lebih dari 2 font family. Gunakan font tunggal bersih (`GoogleFonts.plusJakartaSans` atau `GoogleFonts.inter` atau default Flutter).
   - DILARANG menyelipkan emoticon/emoji sembarangan di samping teks salam atau judul (JANGAN tulis "Good morning ☀️", "Hot Projects 🔥🚀", "Coins 💰✨". Tulis teks polos profesional: "Good morning", "Explore Projects", "150 TC").
   - DILARANG teks judul bergradien pelangi/neon. Warna judul utama WAJIB `Color(0xFF0F172A)`.
   - Skala Tipografi: Large Title (24-28 bold), Section Title (18-20 bold), Subtitle (14-16 w600), Body (13-14 normal), Caption (11-12 w500).

2. 🚫 IKONOGRAFI:
   - DILARANG menggunakan stiker 3D kartun, clay emoji, atau ornamen mainan anak-anak.
   - 100% WAJIB menggunakan Material Icons Rounded native Flutter (`Icons.<name>_rounded`).
     * Status Proyek Aktif: `Icons.bolt_rounded` (Navy: `Color(0xFF1E3A8A)`)
     * Status Proyek Selesai: `Icons.task_alt_rounded` (Emerald: `Color(0xFF10B981)`)
     * Penilaian / Rating: `Icons.star_rounded` (Amber Gold: `Color(0xFFF59E0B)`)
     * TimeCoin / Kredit: `Icons.toll_rounded` (Amber Gold: `Color(0xFFF59E0B)`)
     * Filter: `Icons.tune_rounded`
     * Tenggat / Waktu: `Icons.access_time_rounded` / `Icons.calendar_today_rounded`
     * Navigasi Kembali: `Icons.keyboard_arrow_left_rounded`

3. 🚫 TOMBOL AKSI UTAMA (PRIMARY ACTION BUTTON):
   - DILARANG KERAS tombol outline tipis transparan/putih yang terlihat kosong seperti tombol disable!
   - Tombol aksi utama (seperti "Book Session", "Open Workspace", "Apply", "Kirim Lamaran", "Validasi Hasil") WAJIB berlatar NAVY SOLID PENUH dengan teks putih tebal:
     ```dart
     Container(
       width: double.infinity,
       padding: const EdgeInsets.symmetric(vertical: 14),
       decoration: BoxDecoration(
         color: const Color(0xFF1E3A8A), // Deep Royal Navy solid
         borderRadius: BorderRadius.circular(14),
         boxShadow: [
           BoxShadow(
             color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
       child: const Center(
         child: Text(
           'Nama Aksi',
           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
         ),
       ),
     )
     ```

4. 🚫 GRID, POSISI & SPACING:
   - Gunakan sistem kelipatan 4pt/8pt grid (padding/margin: 8, 12, 16, 20, 24).
   - Margin horizontal layar konsisten: selalu `EdgeInsets.symmetric(horizontal: 24)` atau `20`.
   - DILARANG "Russian-Doll Containers" (kontainer berlapis-lapis tanpa fungsi) dan border-in-border-in-border.
   - Di dalam Row, WAJIB tambahkan `crossAxisAlignment: CrossAxisAlignment.center` agar teks dan ikon sejajar vertikal secara presisi.
   - Hirarki kartu dari atas ke bawah: Header (Avatar + Judul + Rating/Status) -> Body ringkas (maks 2-3 baris) -> Tags/Chips keahlian -> Tombol Aksi di bagian bawah.

5. 🚫 WARNA & SHADOW:
   - DILARANG gradien neon ungu-cyan khas crypto/web3.
   - DILARANG bayangan neon menyala terang. Gunakan bayangan lembut natural: `BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.05), blurRadius: 15, offset: Offset(0, 5))`.
   - DILARANG glassmorphism berlebihan (`BackdropFilter` blur berat) yang merusak keterbacaan teks dan membebani performa aplikasi.

6. 🚫 COPYWRITING:
   - DILARANG badge "LIVE" berkedip palsu jika bukan streaming langsung.
   - DILARANG jargon hiperbolik AI ("AI-powered ultra synergy", "🚀 99,999+ Students").
   - Gunakan micro-copy lugas, fungsional, dan ramah.

---

### TUGASMU:
Konfirmasikan bahwa kamu telah memahami seluruh identitas proyek TalentSync, palet warna Opsi 1 (Deep Royal Navy & Amber Gold), serta katalog Anti "AI Slop" di atas. Jawab HANYA dengan kalimat:
"Siap! Saya memahami seluruh konteks TalentSync, palet warna Deep Royal Navy & Amber Gold, serta aturan ketat Anti AI-Slop. Silakan berikan prompt halaman yang ingin dibuat."
```
