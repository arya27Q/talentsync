# Struktur Folder Flutter (Architecture Design)

Untuk aplikasi dengan skala menengah ke atas dan *multi-role* (Mahasiswa, UMKM, Mentor) seperti ekosistem TimeCoin, arsitektur yang paling direkomendasikan adalah **Feature-First Architecture** yang disesuaikan dengan penggunaan **Provider** untuk State Management.

Berikut adalah rancangan struktur direktori untuk proyek Flutter-mu di dalam folder `lib/`:

## 📁 Struktur `lib/` (Feature-First dengan Provider)

```text
lib/
│
├── core/                   # 1. Kebutuhan Global (Dipakai di mana-mana)
│   ├── constants/          # Warna, ukuran font, path icon/gambar
│   ├── network/            # Setup dasar API (Dio/HTTP, Interceptor token)
│   ├── providers/          # Provider Global (misal: ThemeProvider, SessionProvider)
│   ├── routes/             # Konfigurasi Navigasi / Rute (GoRouter atau Route Names)
│   ├── utils/              # Fungsi bantuan (misal: format Rupiah)
│   └── widgets/            # Widget global (misal: CustomButton, LoadingBox)
│
├── features/               # 2. Fitur Utama Aplikasi
│   │
│   ├── auth/               # --> FITUR LOGIN / REGISTER
│   │   ├── models/         # Blueprint data (contoh: user_model.dart)
│   │   ├── services/       # Tempat nembak API Laravel (contoh: auth_service.dart)
│   │   ├── providers/      # Logika state / Provider (contoh: auth_provider.dart)
│   │   ├── screens/        # Halaman UI (contoh: login_screen.dart)
│   │   └── widgets/        # Komponen UI khusus fitur ini aja
│   │
│   ├── dashboard/          # --> FITUR DASBOR UTAMA 
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   └── screens/        # (Bisa dipisah: dashboard_mahasiswa_screen, umkm, mentor)
│   │
│   ├── project/            # --> FITUR TUGAS / PROYEK
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   └── screens/
│   │
│   ├── mentoring/          # --> FITUR MENTORING (Peer-to-Peer)
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   └── screens/
│   │
│   ├── wallet/             # --> FITUR TIMECOIN, VOUCHER, & CASH-OUT
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   └── screens/
│
└── main.dart               # Entry point (runApp dan MultiProvider ditaruh sini)
```

---

## 📝 Penjelasan Filosofi Struktur

Mengapa kita menggunakan **Feature-First Architecture** dan bukan *Layer-First* tradisional?

Analogi mudahnya adalah seperti **Supermarket vs Toko Kelontong**:
*   **Cara Lama (Layer-First / Toko Kelontong):** Memisahkan *file* berdasarkan JENISNYA (Semua model dikumpul di folder `models`, semua API di `services`). Saat proyek membesar, satu folder bisa berisi puluhan *file* yang tidak saling terkait (model mentoring campur dengan model proyek).
*   **Cara Kita (Feature-First / Supermarket):** Memisahkan *folder* berdasarkan **FITUR (Bagian)**. Setiap fitur memiliki "divisinya" sendiri secara mandiri (terdiri dari `models`, `services`, `providers`, dan `screens`).

**Kelebihan Pendekatan Ini:**
1.  **Fokus:** Saat mengerjakan fitur `mentoring`, Anda hanya perlu membuka folder `features/mentoring`.
2.  **Team-Work Friendly:** Mendukung kerja tim paralel tanpa memicu *conflict* kode.
3.  **Modular:** Fitur sangat mudah dihapus, dimodifikasi, atau dipindahkan tanpa membuat *error* berantai.

---

## 🔗 Pemetaan Fitur Terhadap 3 Sudut Pandang (POV)

Struktur 5 folder utama di dalam `features/` telah dirancang untuk mencakup seluruh ekosistem (Mahasiswa, UMKM, dan Mentor) dengan pembagian tugas sebagai berikut:

### 1. `features/mentoring` (Fitur Mentoring)
*   **POV Mahasiswa:** Mencari daftar Mentor (termasuk *Kating* yang menggunakan *Switch Mode*), melihat jadwal, dan melakukan *booking* (menggunakan TimeCoin atau Jalur Rupiah Darurat).
*   **POV Mentor:** Menerima/menolak pesanan bimbingan, mengatur jadwal, dan melihat riwayat sesi.
*   *POV UMKM: Tidak menggunakan fitur ini.*

### 2. `features/wallet` (Fitur Dompet & Keuangan)
*   **POV Mahasiswa:** Mengecek saldo TimeCoin dari hasil tugas, dan menukar TimeCoin menjadi *Voucher Promo UMKM*.
*   **POV Mentor:** Mengecek saldo TimeCoin yang diperoleh, dan mengajukan **Cash-Out** (pencairan ke Rupiah).
*   **POV UMKM:** Mengecek kuota TC bulanan (20 TC) untuk membuat proyek jalur barter.

### 3. `features/project` (Fitur Tugas UMKM)
*   **POV UMKM:** Mempublikasikan lowongan/pekerjaan (Jalur Barter atau *Cash Task*).
*   **POV Mahasiswa:** Mencari tugas, melamar pekerjaan, mengunggah portofolio (Figma/Github), dan mendapatkan ulasan (Rating Bintang 5).
*   *POV Mentor: Tidak menggunakan fitur ini.*

### 4. `features/dashboard` (Halaman Utama)
Sebagai layar beranda (*Home Screen*) yang akan menampilkan antarmuka berbeda secara dinamis setelah pengguna *login*. 
Terdiri dari layar spesifik:
*   `dashboard_mahasiswa_screen.dart`
*   `dashboard_umkm_screen.dart`
*   `dashboard_mentor_screen.dart`

### 5. `features/auth` (Otentikasi & Profil)
Digunakan oleh ke-3 POV untuk proses *Login*, *Register* (termasuk unggah KTM untuk Mahasiswa atau Foto Toko untuk UMKM), serta menangani profil pengguna (termasuk memunculkan tombol *"Switch to Mentor Mode"* untuk mahasiswa yang memenuhi syarat).

---

## ⚙️ Penanganan Proses Pencairan Uang (Cash-Out) & Ketiadaan Admin POV di Flutter

Aplikasi seluler (Flutter) ini secara khusus didesain **hanya sebagai antarmuka pengguna akhir (end-user)**. Oleh karena itu, aplikasi ini **tidak menyertakan POV Admin (Admin Panel)** di dalamnya.

**Alur Penanganan *Cash-Out*:**
1.  **Sisi Aplikasi Flutter (Pengaju):** Di dalam `features/wallet/screens`, aplikasi hanya menyediakan antarmuka bagi Mentor untuk memasukkan nominal penarikan, detail rekening, dan memantau status pengajuan (misal: "Pending/Sedang Diproses").
2.  **Sisi Backend Laravel (Pengelola):** Seluruh *Dashboard Admin* (untuk memantau transaksi, menyetujui pengajuan, dan mengubah status pencairan menjadi "Sukses") sepenuhnya di-hosting dan dikelola melalui **Web Backend Laravel** (misalnya menggunakan *Filament*, *Nova*, atau tampilan *Blade* khusus). Admin (pemilik aplikasi) akan melakukan transfer lalu memberikan konfirmasi via Web Panel, yang otomatis akan memperbarui status di aplikasi Flutter.

Desain ini menjamin keamanan (*security*) tingkat tinggi, memisahkan logika sensitif dari *client-side*, dan mencegah aplikasi *mobile* dari beban *bloatware* yang tidak perlu.
