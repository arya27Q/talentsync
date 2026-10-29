# Struktur Folder & Arsitektur Laravel (Backend API)

Karena aplikasi seluler (Flutter) berinteraksi dengan backend melalui *REST API*, struktur proyek Laravel yang kita buat harus dioptimalkan untuk memproduksi *response* JSON (bukan mengembalikan *View* HTML biasa). 

Berikut adalah panduan struktur Laravel agar selaras dengan **Feature-First Architecture** di Flutter.

## 1. 📁 Struktur Folder Utama (Fokus API)

Di Laravel, kita tetap menggunakan **MVC (Model-View-Controller)** bawaan, namun kita merapikan `Controllers` dan `Routes` berdasarkan fitur agar sama rapinya dengan Flutter.

```text
laravel_backend/
│
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/                     # --> KUMPULAN API UNTUK FLUTTER
│   │   │   │   ├── AuthController.php   
│   │   │   │   ├── ProjectController.php
│   │   │   │   ├── MentoringController.php
│   │   │   │   └── WalletController.php
│   │   │   │
│   │   │   └── Admin/                   # --> KUMPULAN CONTROLLER UNTUK WEB ADMIN
│   │   │       └── CashoutController.php (Untuk ACC penarikan uang)
│   │   │
│   │   ├── Middleware/                  # --> PENGAMAN (SATPAm) PERAN
│   │   │   ├── CheckRoleMahasiswa.php   # Blokir UMKM biar gak bisa ambil tugas mhs
│   │   │   ├── CheckRoleUmkm.php
│   │   │   └── CheckRoleMentor.php
│   │   │
│   │   └── Resources/                   # --> FORMATTER JSON (Sangat Penting!)
│   │       ├── ProjectResource.php      # Merapikan JSON output sebelum dikirim ke Flutter
│   │       └── UserResource.php
│   │
│   └── Models/                          # --> BLUEPRINT DATABASE
│       ├── User.php                     # Menyimpan data Mahasiswa, UMKM, Mentor
│       ├── Project.php                  # Data tugas dari UMKM
│       ├── MentoringSession.php         # Data sesi bimbingan
│       └── Transaction.php              # Riwayat keluar-masuk TimeCoin & Rupiah
│
├── routes/
│   ├── api.php                          # --> SEMUA ENDPOINT UNTUK FLUTTER DITARUH SINI
│   └── web.php                          # --> KHUSUS UNTUK ADMIN PANEL (ACC CASHOUT)
│
└── database/
    └── migrations/                      # Skema rancangan tabel database
```

---

## 2. 🗄️ Skema Database (Tabel Inti)

Agar sistem *Hybrid (TimeCoin & Rupiah)* ini berjalan lancar, berikut adalah rancangan tabel paling penting yang harus kamu buat di Laravel:

### A. Tabel `users`
Satu tabel untuk ke-3 peran (POV). Kita pisahkan berdasarkan kolom `role`.
*   `id`
*   `name`, `email`, `password`
*   `role` (enum: `mahasiswa`, `umkm`, `mentor`, `admin`)
*   `timecoin_balance` (integer: Jumlah TC saat ini)
*   `is_premium` (boolean: True jika UMKM bayar langganan / Mahasiswa Top Talent)

### B. Tabel `projects` (Tugas UMKM)
*   `id`
*   `umkm_id` (Foreign Key ke `users`)
*   `title`, `description`
*   `reward_type` (enum: `timecoin`, `cash`) -> Jalur Barter atau Premium
*   `reward_amount` (integer: 20 TC atau Rp150.000)
*   `status` (enum: `open`, `in_progress`, `completed`)

### C. Tabel `mentoring_sessions`
*   `id`
*   `mentor_id` (Foreign Key ke `users`)
*   `student_id` (Foreign Key ke `users`)
*   `payment_type` (enum: `timecoin`, `cash`) -> Normal atau Darurat
*   `price` (integer)
*   `status` (enum: `pending`, `accepted`, `completed`)

### D. Tabel `transactions` (Penting untuk Cash-out & Jejak Koin)
Tabel ini wajib ada biar tidak ada koin/uang "gaib".
*   `id`
*   `user_id`
*   `type` (enum: `earn_tc`, `spend_tc`, `cashout_rupiah`)
*   `amount` (integer)
*   `status` (enum: `pending`, `success`, `failed`) -> Admin akan mengubah status `cashout_rupiah` dari pending ke success.

---

## 3. 🛡️ Paket (Package) Laravel yang Wajib Diinstal

Biar nyambung ke Flutter lebih gampang dan keamanannya setara *startup* profesional, instal ini di Laravel-mu:

1.  **Laravel Sanctum:** Ini wajib untuk autentikasi API. Flutter akan mengirimkan email & password saat *Login*, lalu Sanctum akan merespons dengan **Bearer Token**. Token ini yang dipakai Flutter sebagai "KTP" untuk nembak API lainnya.
2.  **Laravel API Resources:** (Bawaan Laravel). Jangan pernah me-return `Model::all()` langsung ke Flutter. Gunakan `API Resource` untuk merapikan struktur JSON (misalnya menyembunyikan `password` atau `created_at` yang tidak perlu agar data Flutter lebih hemat kuota).
3.  **Filament / Laravel Nova (Opsional tapi Sangat Disarankan):** Sangat cocok untuk membuat **Dashboard Admin**. Daripada kamu *ngoding* web admin dari nol buat fitur "Persetujuan Cash-out" atau "Banned User", pakai *Filament* bisa menghasilkan dasbor admin rapi dalam hitungan jam.

---

## 4. 🔗 Hubungan (Routing) Laravel ke Flutter

Di file `routes/api.php`, kamu akan membuat struktur yang seirama persis dengan folder `features/` di Flutter:

```php
// Rute Terbuka (Tanpa Token) - Sesuai dengan folder "features/auth" di Flutter
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Rute Tertutup (Butuh Token Sanctum dari Flutter)
Route::middleware('auth:sanctum')->group(function () {
    
    // Fitur Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Fitur Project
    Route::apiResource('projects', ProjectController::class);

    // Fitur Mentoring
    Route::apiResource('mentoring', MentoringController::class);

    // Fitur Wallet & Cash-Out
    Route::get('/wallet/balance', [WalletController::class, 'getBalance']);
    Route::post('/wallet/cashout', [WalletController::class, 'requestCashout']);

});
```

Dengan struktur Laravel yang API-sentris seperti ini, *programmer* Backend (Laravel) dan Frontend (Flutter) bakal punya bahasa yang sama dan bisa kerja barengan dengan sangat cepat!
