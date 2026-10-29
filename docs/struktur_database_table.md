# Dokumentasi Struktur Database & ERD
**Sistem:** Hybrid Wallet (TimeCoin & Rupiah) & Multi-Role Account (Mahasiswa, UMKM, Mentor)

Arsitektur database ini dirancang untuk mendukung sistem *Single Account* (satu email bisa berganti *role* dari Mahasiswa ke Mentor) dan *Hybrid Wallet* (TimeCoin & Rupiah), yang sangat optimal untuk dieksekusi menggunakan *Laravel Eloquent (Migration)*.

---

## 1. Modul Autentikasi & Profil (*User Management*)

Tabel ini adalah jantung dari aplikasi. Semua jenis *user* ditampung di sini, dibedakan berdasarkan *role* dan status verifikasinya.

### Tabel `users`
*   `id` (Primary Key)
*   `name`, `email`, `password`
*   `role` (Enum: `student`, `msme`, `mentor`) $\rightarrow$ *Role default saat daftar.*
*   `is_mentor` (Boolean) $\rightarrow$ *Jika True, mahasiswa bisa membuka fitur Mentor.*
*   `balance_timecoin` (Integer) $\rightarrow$ *Saldo koin digital.*
*   `balance_rupiah` (Decimal) $\rightarrow$ *Saldo uang tunai untuk Cash Task/Cash-out.*
*   `is_premium` (Boolean) $\rightarrow$ *Status berlangganan untuk UMKM / Verified Partner.*

### Tabel `skills` 
*   `id` (Primary Key)
*   `name` (String) $\rightarrow$ *Master data keahlian seperti "Flutter", "Laravel".*

### Tabel `user_skills` 
*   `id` (Primary Key)
*   `user_id` (Foreign Key $\rightarrow$ `users.id`)
*   `skill_id` (Foreign Key $\rightarrow$ `skills.id`)
*   *Relasi Many-to-Many antara users dan skills untuk tagging portofolio/keahlian.*

---

## 2. Modul UMKM & Tugas (*Task & Collaboration*)

Modul ini mengatur siklus hidup sebuah proyek dari awal diposting UMKM sampai diselesaikan Mahasiswa.

### Tabel `tasks` (Lapak kerjaan dari UMKM)
*   `id` (Primary Key)
*   `msme_id` (Foreign Key $\rightarrow$ `users.id`)
*   `title`, `description`, `category`
*   `task_type` (Enum: `barter`, `cash`)
*   `reward_timecoin` (Integer)
*   `reward_rupiah` (Decimal)
*   `status` (Enum: `open`, `in_progress`, `review`, `completed`, `cancelled`)

### Tabel `task_applications` (Lamaran Mahasiswa)
*   `id` (Primary Key)
*   `task_id` (Foreign Key $\rightarrow$ `tasks.id`)
*   `student_id` (Foreign Key $\rightarrow$ `users.id`)
*   `status` (Enum: `pending`, `accepted`, `rejected`)

### Tabel `portfolios` (Otomatis ter-generate saat *task completed*)
*   `id` (Primary Key)
*   `student_id` (Foreign Key $\rightarrow$ `users.id`)
*   `task_id` (Foreign Key $\rightarrow$ `tasks.id`)
*   `final_file_url` (Link GitHub/Figma)
*   `rating` (Integer 1-5 dari UMKM)

---

## 3. Modul Mentoring (*Expertise & Booking*)

Modul ini aktif ketika `is_mentor` bernilai *True* pada tabel `users`.

### Tabel `mentor_services` (Jasa yang ditawarkan Mentor)
*   `id` (Primary Key)
*   `mentor_id` (Foreign Key $\rightarrow$ `users.id`)
*   `title` (Contoh: "Mentoring Setup API Laravel")
*   `price_timecoin` (Integer)
*   `price_rupiah` (Decimal) $\rightarrow$ *(Tambahan: Untuk jalur bimbingan darurat Premium)*

### Tabel `mentoring_sessions` (Riwayat *booking* sesi)
*   `id` (Primary Key)
*   `service_id` (Foreign Key $\rightarrow$ `mentor_services.id`)
*   `student_id` (Foreign Key $\rightarrow$ `users.id` yang menyewa)
*   `payment_type` (Enum: `timecoin`, `cash`) $\rightarrow$ *(Tambahan: Penanda bayar koin atau uang)*
*   `status` (Enum: `booked`, `ongoing`, `completed`)
*   `meeting_link` (URL sesi ruang kerja / GMeet)
*   `rating` (Integer 1-5) $\rightarrow$ *(Tambahan: Penilaian dari mahasiswa untuk mentor)*
*   `review` (Text) $\rightarrow$ *(Tambahan: Ulasan bimbingan)*

---

## 4. Modul Reward & Barter (*Vouchers*)

Sistem untuk memastikan *voucher* UMKM bisa diklaim, dengan validasi khusus: hanya bisa diklaim oleh mahasiswa yang *pernah* bekerja untuk UMKM tersebut.

### Tabel `vouchers` (Katalog di Reward Hub)
*   `id` (Primary Key)
*   `msme_id` (Foreign Key $\rightarrow$ `users.id`)
*   `title`, `image_url`
*   `cost_timecoin` (Harga tukar koin)
*   `stock` (Integer)

### Tabel `voucher_redemptions` (Riwayat klaim mahasiswa)
*   `id` (Primary Key)
*   `student_id` (Foreign Key $\rightarrow$ `users.id`)
*   `voucher_id` (Foreign Key $\rightarrow$ `vouchers.id`)
*   `qr_code_hash` (Teks enkripsi untuk di-*scan* UMKM)
*   `is_used` (Boolean: *True* jika sudah dipakai di warkop/toko)
*   *Catatan Logic Backend: Sebelum insert ke tabel ini, Laravel wajib mengecek tabel `portfolios` apakah student_id pernah mengerjakan tasks milik msme_id.*

---

## 5. Modul Keuangan (*E-Wallet History & Escrow*)

Tabel krusial untuk mencatat arus masuk-keluar (mutasi) uang dan koin agar *traceable* dan terhindar dari *bug/exploit*.

### Tabel `transactions` (Polymorphic Relation)
*   `id` (Primary Key)
*   `user_id` (Foreign Key $\rightarrow$ `users.id`)
*   `currency_type` (Enum: `timecoin`, `rupiah`)
*   `transaction_type` (Enum: `income`, `expense`, `escrow_hold`, `escrow_release`, `withdrawal`)
*   `amount` (Nominal koin/uang)
*   `reference_type` (String) $\rightarrow$ *(Menunjuk ke model tabel asal uang, misal: 'App\Models\Task', 'App\Models\MentoringSession', 'App\Models\Voucher')*
*   `reference_id` (Integer) $\rightarrow$ *(ID dari record di tabel referensi tersebut)*
*   `status` (Enum: `pending`, `success`, `failed`)
