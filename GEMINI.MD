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
    * *Large Title:* `fontSize: 24 - 28`, `fontWeight: FontWeight.bold`, warna `AppColors.darkBrown`.
    * *Section Title:* `fontSize: 18 - 20`, `fontWeight: FontWeight.bold`, warna `AppColors.darkBrown`.
    * *Card Title / Subtitle:* `fontSize: 14 - 16`, `fontWeight: FontWeight.w600`.
    * *Body Text:* `fontSize: 13 - 14`, `fontWeight: FontWeight.normal`, warna teks abu-abu gelap `Colors.grey.shade700`.
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
    * Penilaian / Rating: `Icons.star_rounded` (warna `Color(0xFFFF8F00)`)
    * TimeCoin / Kredit: `Icons.toll_rounded` (warna `AppColors.primaryTan`)
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
* ✅ **Standar Baku TalentSync:**
  - **Palet Resmi Terbatas & Bersih (`AppColors`):**
    * `primaryTan`: `Color(0xFFB88656)` — Warna utama aksi, tombol CTA, aksen TimeCoin.
    * `darkBrown`: `Color(0xFF4D332D)` — Warna teks judul, header, ikon aktif kontras.
    * `warmOffWhite`: `Color(0xFFF9F6F0)` — Warna canvas latar belakang aplikasi (hangat & nyaman di mata).
    * `darkSurface`: `Color(0xFF1E1E1E)` — Elemen gelap/kartu kontras.
    * `cardSurface`: `Colors.white` — Latar belakang kartu utama.
  - **Bayangan Natural Halus:**
    * Kartu: `BoxShadow(color: AppColors.darkBrown.withValues(alpha: 0.05), blurRadius: 15, offset: Offset(0, 5))`
    * Tombol Utama: `BoxShadow(color: AppColors.primaryTan.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 4))`

### 🚫 2.5 Tombol (Buttons) & Komponen Aksi Slop
* ❌ **AI Slop yang Dilarang:**
  - **DILARANG KERAS tombol model outline tipis putih/transparan:** Tombol aksi utama (seperti *Book Session*, *Open Workspace*, *Apply*) berlatar putih/transparan dengan hanya garis tepi tipis coklat. Ini terlihat kosong, seperti tombol *disabled* atau belum selesai di-*render*.
  - Tombol berbentuk kapsul neon mengkilap (*glossy*) dengan refleksi cahaya imitasi.
  - Tidak ada perbedaan tegas antara tombol utama (*primary*) dan tombol pendukung (*secondary*).
* ✅ **Standar Baku TalentSync:**
  - **Primary Action Button (Tombol Aksi Utama):**
    ```dart
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryTan, // Coklat solid penuh
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTan.withValues(alpha: 0.3),
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
  - **Secondary Button:** Menggunakan latar belakang `AppColors.warmOffWhite`, teks `AppColors.darkBrown` tebal, tanpa shadow mencolok.
  - **Tag / Skill Chip:**
    * Latar belakang: `AppColors.warmOffWhite`
    * Teks: `AppColors.darkBrown`, `fontSize: 10 - 12`, `fontWeight: FontWeight.bold`
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
| 2026-10-29 | Tombol Book Session/Open Workspace tampak kosong | Tombol menggunakan border outline dan latar transparan/putih. | Ubah dekorasi tombol menjadi `color: AppColors.primaryTan` solid penuh dengan teks `Colors.white` dan `FontWeight.bold`. |
| 2026-10-29 | Ikon terlihat kekanak-kanakan / gaya AI stiker | Ikon matahari kartun dan ornamen stiker yang tidak profesional. | Bersihkan seluruh ornamen kartun, ganti dengan ikon standar `Icons.*_rounded`. |
| 2026-10-30 | Lint warning `use_null_aware_elements` di Dart 3+ | Menggunakan `if (trailing != null) trailing!` di widget list. | Gunakan sintaks null-aware element: `?trailing,`. |

---

## 🏛️ 5. Logika Bisnis Inti (Ekosistem Hybrid & TimeCoin)

* **3 Entitas Pengguna:**
  1. **Mahasiswa:** Mengikuti mentoring (bayar TC), melamar proyek UMKM (syarat portofolio / badge rekomendasi mentor), menerima transfer TC, bebas *cash-out* ke Rupiah (**0% potongan admin**), dan dapat membuka mode *Switch as a Mentor* jika telah menyelesaikan $\ge 5$ proyek.
  2. **Mitra UMKM:** Posting proyek dengan imbalan TC, menyeleksi mahasiswa, memvalidasi hasil kerja, memberi rating & ulasan bintang, berlangganan paket Premium (opsional) untuk kuota ekstra & filter pelamar ber-badge.
  3. **Mentor:** Membuka kelas mentoring dengan tarif TC, memberikan *Badge Rekomendasi Kerja (Endorse)* bagi murid yang kompeten, mencairkan TC ke Rupiah (*Freemium* dipotong biaya admin 10%, *Premium* 0% admin).
* **Konversi Referensi:** $1\text{ TC} \approx \text{Rp}1.000$.

---

## 🗺️ 6. Peta Direktori & Navigasi Kode (`flutter_frontend/lib`)

```text
lib/
├── main.dart                                # Entry point aplikasi
├── role_selection_screen.dart               # Pemilihan peran (Mahasiswa / UMKM / Mentor)
├── splash_screen.dart                       # Splash screen awal
├── core/
│   ├── constants/app_colors.dart            # Definisi warna resmi (primaryTan, darkBrown, warmOffWhite)
│   ├── routes/app_routes.dart               # Daftar nama rute aplikasi
│   └── widgets/                             # Widget global (TimeCoinIcon, GradientBackground)
└── features/
    ├── auth/screens/                        # Login, Register, Onboarding, Setup Profile (per peran)
    ├── dashboard/screens/                   # dashboard_mahasiswa_screen, student_main_layout
    ├── project/screens/                     # explore_projects_screen, my_projects_screen, project_detail_screen
    ├── mentoring/screens/                   # find_mentors_screen, mentor_profile_screen, booking_session_screen, mentor_chat_screen
    ├── wallet/screens/                      # wallet_dashboard_screen, reward_hub_screen, transfer_screen, history_screen
    ├── workspace/screens/                   # workspace_kanban_screen, workspace_chat_screen, submission_screen, inbox_screen
    ├── portfolio/screens/                   # portfolio_dashboard_screen, case_study_screen
    ├── profile/screens/                     # student_settings_screen, edit_profile_screen, help_support_screen, privacy_security_screen
    └── notifications/screens/               # notifications_screen
```

---

## 📝 7. Prosedur Kerja Agen Selanjutnya (Standard Operating Procedure)

1. **Cek Dokumen Terlebih Dahulu:** Sebelum menjawab atau membuat perubahan, baca `GEMINI.MD` dan berkas terkait di `docs/`.
2. **Jangan Menganalisis Ulang Hal yang Sudah Baku:** Langsung terapkan aturan desain (ikon native, tombol coklat solid, warna warm off-white, anti AI slop) tanpa bertanya ulang atau mengubah ke gaya lain.
3. **Dokumentasikan Masalah Baru Secara Otomatis:** Jika dalam pengerjaan tugas berikutnya muncul kendala baru (error build, konfigurasi package, penyesuaian rute), agen wajib mencatat temuan dan solusinya ke tabel pada Bagian 4 dokumen ini.
4. **Verifikasi Akhir:** Setiap penulisan kode wajib divalidasi dengan `flutter analyze` hingga dipastikan `No issues found!`.
