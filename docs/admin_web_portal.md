# TalentSync Admin Web Portal (Branch `feat/admin-web-arya`)

Dokumen ini merangkum arsitektur, fitur operasional, sistem keamanan (100% self-hosted tanpa vendor pihak ketiga), daftar endpoint API, serta panduan menjalankan **Admin Web Portal** TalentSync menggunakan Flutter Web dan Laravel REST API.

---

## 1. Arsitektur & Pemisahan Platform

- **Aplikasi Mobile (`!kIsWeb`):** Berjalan di Android/iOS dengan orientasi Portrait terkunci untuk 3 POV (**Mahasiswa**, **Mitra UMKM**, dan **Peer Mentor**).
- **Admin Web Portal (`kIsWeb`):** Berjalan di browser desktop/tablet (`flutter run -d chrome`) dan langsung masuk ke rute `/admin/login` menuju `/admin/dashboard` tanpa mengganggu pengalaman mobile.
- **Backend Tunggal:** Menggunakan server Laravel yang sama (`laravel_backend/`) dengan proteksi autentikasi Sanctum + middleware `role:admin` dan `not_suspended`.

---

## 2. Modul & Fitur Admin Web Portal

### A. Ringkasan Ekosistem (`Ringkasan`)
- Hero banner antrean tindakan (Cash-Out tertunda, Upgrade Mentor Premium, Sengketa terbuka).
- 4 kartu KPI utama (Total Pengguna 3 POV, Proyek UMKM, TimeCoin Beredar, Dana Smart Escrow).
- Mutasi TimeCoin terbaru + komposisi distribusi 3 POV dan status proyek secara real-time.

### B. Persetujuan Keuangan (`Persetujuan`)
- **Antrean Pencairan Dana Cash-Out:** Setujui transfer Rupiah atau tolak & refund saldo TC ke pengguna. Nominal tinggi (`>= 300 TC`) mewajibkan konfirmasi ulang kata sandi admin.
- **Antrean Upgrade Mentor Premium:** Aktivasi atau penolakan paket langganan 0% potongan admin.

### C. Resolusi Sengketa (`Sengketa`)
- Daftar laporan kendala proyek, mentoring, dan escrow dengan filter status (`all`, `open`, `resolved`, `rejected`).
- Modal keputusan mediasi dengan catatan resolusi wajib (min. 10 karakter) dan notifikasi otomatis ke pelapor.

### D. Direktori Pengguna 3 POV (`Pengguna 3 POV`)
- Tabel data standar berkolom (`PENGGUNA`, `PERAN`, `SALDO & ESCROW`, `STATUS`, `AKSI`) dengan pencarian, filter peran, pagination, dan **Export CSV**.
- **Verifikasi Identitas:** Setujui atau tandai pending status verifikasi Mahasiswa (KTM), UMKM, maupun Mentor.
- **Bekukan Akun & Cabut Sesi Paksa (*Force Logout*):** Memblokir login akun bermasalah beserta alasan dan langsung menghapus seluruh token Sanctum aktif.
- **Penyesuaian / Refund Saldo Darurat:** Tambah (`+TC`) atau koreksi (`-TC`) saldo dompet pengguna dengan `lockForUpdate()`, alasan wajib, konfirmasi kata sandi admin, serta pencatatan otomatis ke Buku Besar dan Log Audit.

### E. Proyek, Buku Besar & Katalog (`Proyek & Ledger`)
- **Moderasi Proyek UMKM:** Tabel berkolom untuk menonaktifkan atau mengaktifkan kembali proyek yang melanggar, lengkap dengan pencarian, filter status, dan pagination.
- **Audit Buku Besar TimeCoin:** Filter per jenis transaksi (`top_up`, `voucher_barter`, `project_escrow_hold`, `project_reward`, `cash_out`, `admin_adjustment`), pagination, dan **Export CSV**.
- **Moderasi Kelas Mentoring:** Tabel berkolom untuk meninjau dan menonaktifkan kelas mentoring bermasalah beserta pagination.
- **Katalog Reward:** Tabel berkolom untuk menambah item reward baru dan mengatur status aktif/nonaktif voucher penukaran TimeCoin.

### F. Keamanan & Audit (`Keamanan & Audit`)
1. **Deteksi Anomali Ekonomi TimeCoin:** Pemindaian otomatis langsung dari MySQL untuk Cash-Out `>= 300 TC`, frekuensi Cash-Out `>= 2x/24 jam`, dan transfer `>= 500 TC` dalam 7 hari.
2. **Rekam Jejak Audit Administrator (`admin_audit_logs`):** Mencatat seluruh aksi sensitif admin (aktor, aksi, target, detail, IP address, timestamp) lengkap dengan filter, pagination, dan **Export CSV**.
3. **Broadcast Pengumuman Sistem:** Mengirim notifikasi pengumuman/peringatan keamanan ke `Semua 3 POV`, `Mahasiswa`, `Mitra UMKM`, atau `Peer Mentor` melalui tabel `notifications` lokal.
4. **Sesi Perangkat Admin & Idle Guard:** Daftar perangkat login aktif (`/auth/sessions`), tombol **Keluar dari Perangkat Lain**, serta **Idle Auto-Logout 20 menit** otomatis di Flutter Web.

---

## 3. Daftar Endpoint API Admin (`role:admin`)

| Method | Endpoint | Fungsi |
|---|---|---|
| `GET` | `/api/admin/dashboard` | Ringkasan metrik 3 POV, ekonomi TimeCoin, dan antrean |
| `GET` | `/api/admin/users` | Daftar pengguna 3 POV (search, filter role, pagination) |
| `PATCH` | `/api/admin/users/{user}/verification` | Ubah status verifikasi akun |
| `PATCH` | `/api/admin/users/{user}/suspension` | Bekukan atau buka blokir akun (otomatis cabut token) |
| `POST` | `/api/admin/users/{user}/force-logout` | Cabut paksa seluruh token sesi pengguna |
| `POST` | `/api/admin/users/{user}/wallet-adjustment` | Penyesuaian/refund saldo TimeCoin (wajib kata sandi admin) |
| `GET` | `/api/admin/disputes` | Daftar laporan sengketa |
| `PATCH` | `/api/admin/disputes/{dispute}` | Simpan keputusan mediasi sengketa |
| `GET` | `/api/admin/projects` | Daftar proyek UMKM untuk moderasi |
| `PATCH` | `/api/admin/projects/{project}/status` | Nonaktifkan / aktifkan kembali proyek |
| `GET` | `/api/admin/mentoring-classes` | Daftar kelas mentoring untuk moderasi |
| `PATCH` | `/api/admin/mentoring-classes/{mentoringClass}/status` | Nonaktifkan / aktifkan kembali kelas mentoring |
| `GET` | `/api/admin/rewards` | Daftar katalog reward |
| `POST` | `/api/admin/rewards` | Tambah item reward baru |
| `PATCH` | `/api/admin/rewards/{reward}` | Perbarui stok/harga/status reward |
| `GET` | `/api/admin/transactions` | Audit buku besar TimeCoin (filter tipe & pagination) |
| `GET` | `/api/admin/audit-logs` | Rekam jejak aktivitas admin (filter aksi & pagination) |
| `GET` | `/api/admin/security/anomalies` | Deteksi anomali transaksi TimeCoin berbasis SQL |
| `POST` | `/api/admin/security/confirm-password` | Verifikasi ulang kata sandi admin untuk aksi kritis |
| `POST` | `/api/admin/announcements/broadcast` | Kirim pengumuman massal ke 3 POV |
| `GET` | `/api/admin/export/{resource}` | Export CSV (`users`, `transactions`, `audit-logs`) |
| `GET` | `/api/admin/cash-outs/pending` | Daftar antrean Cash-Out |
| `PATCH` | `/api/wallet/cash-outs/{cashOutRequest}` | Setujui atau tolak & refund Cash-Out |
| `GET` | `/api/admin/mentor-premium-subscriptions/pending` | Daftar antrean upgrade Mentor Premium |
| `PATCH` | `/api/admin/mentor-premium-subscriptions/{subscription}` | Setujui atau tolak pembayaran Mentor Premium |

### Proteksi Rate Limiter Tambahan
- `/api/auth/login`, `/api/auth/register`, `/api/auth/register-mentor`: `throttle:5,1`
- `/api/wallet/cash-out`, `/api/disputes`: `throttle:5,1`
- `/api/wallet/transfer`, `/api/wallet/top-up`: `throttle:10,1`

---

## 4. Cara Menjalankan (Development Lokal)

### 1. Backend Laravel
```powershell
cd c:\laragon\www\talentsync\laravel_backend
php artisan migrate --force
php artisan db:seed --class=TalentSyncDemoSeeder --force
php artisan serve
```

### 2. Admin Web Portal (Chrome)
```powershell
cd c:\laragon\www\talentsync\flutter_frontend
flutter run -d chrome
```

### Akun Demo Admin (Seeder)
- **Email:** `admin@talentsync.id`
- **Kata Sandi:** `password123`

### 3. Aplikasi Mobile (Android Emulator, opsional bersamaan)
```powershell
cd c:\laragon\www\talentsync\flutter_frontend
flutter run -d <device_id_emulator>
```

---

## 5. Status Pengujian Terakhir
- **Laravel PHPUnit:** `30/30 passed (527 assertions)` termasuk `AdminPortalTest.php`.
- **Flutter Analyze:** `No issues found!`
- **Flutter Widget Tests:** `88/88 passed` termasuk `admin_portal_test.dart` (`1280x800` & `800x600`), `mentor_custom_duration_test.dart`, dan `overflow_test.dart` (`360x640`).
