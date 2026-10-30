# Dokumentasi Struktur Basis Data & Kamus Data Relasional (PostgreSQL)
**Aplikasi:** TalentSync  
**Sistem:** Hybrid Wallet (TimeCoin & Rupiah) & Multi-Role Architecture  
**Database Management System:** PostgreSQL  
**ORM:** Laravel Eloquent (Migrations & Seeders)  

---

## 1. Ikhtisar Arsitektur Basis Data

Basis data TalentSync dirancang menggunakan model relasional normal (3NF) pada PostgreSQL untuk memastikan integritas data (ACID), keamanan pencatatan kredit internal TimeCoin (*immutable ledger*), serta fleksibilitas akun *multi-role* (Mahasiswa, Mitra UMKM, Mentor) dengan fitur transisi *Switch as a Mentor*.

---

## 2. Kamus Data 14 Entitas Inti (Data Dictionary)

### 2.1 Modul Pengguna & Profil (User & Profile Management)

#### 1. Tabel `users`
Menyimpan data kredensial akun terpusat untuk seluruh jenis pengguna.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `name` | `VARCHAR(150)` | Nama lengkap pengguna |
| `email` | `VARCHAR(150)` | Alamat email unik (`UNIQUE`) |
| `password` | `VARCHAR(255)` | Hash kata sandi (`bcrypt`) |
| `role_id` | `BIGINT` | Foreign Key $\rightarrow$ `roles.id` |
| `avatar_url` | `VARCHAR(255)` | Tautan berkas foto profil (nullable) |
| `phone_number` | `VARCHAR(25)` | Nomor telepon aktif |
| `is_verified` | `BOOLEAN` | Status verifikasi identitas (default: `FALSE`) |
| `created_at` / `updated_at` | `TIMESTAMP` | Timestamps Laravel |

#### 2. Tabel `roles`
Master data peran pengguna dalam sistem.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `name` | `VARCHAR(50)` | Nama role (`student`, `msme`, `mentor`, `admin`) |
| `description` | `VARCHAR(255)` | Deskripsi kewenangan |

#### 3. Tabel `student_profiles`
Profil khusus bagi pengguna dengan peran Mahasiswa.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `user_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (`UNIQUE`) |
| `university` | `VARCHAR(150)` | Nama perguruan tinggi (misal: Universitas Negeri Surabaya) |
| `major` | `VARCHAR(100)` | Program studi (misal: S1 Sistem Informasi) |
| `student_id_number` | `VARCHAR(50)` | Nomor Induk Mahasiswa (NIM) |
| `ktm_document_url` | `VARCHAR(255)` | Tautan berkas bukti KTM untuk verifikasi |
| `is_mentor_eligible` | `BOOLEAN` | Menandai apakah mahasiswa memenuhi syarat *Switch as a Mentor* (lulus $\ge 5$ proyek) |
| `completed_projects_count` | `INTEGER` | Jumlah total proyek UMKM yang berhasil diselesaikan |

#### 4. Tabel `umkm_profiles`
Profil pelaku usaha atau Mitra UMKM.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `user_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (`UNIQUE`) |
| `business_name` | `VARCHAR(150)` | Nama usaha atau toko |
| `business_sector` | `VARCHAR(100)` | Sektor usaha (Kuliner, Fashion, Kriya, Jasa, dll.) |
| `address` | `TEXT` | Alamat fisik tempat usaha |
| `business_document_url` | `VARCHAR(255)` | Bukti legalitas / izin usaha (nullable) |
| `is_premium` | `BOOLEAN` | Status langganan paket Premium UMKM (default: `FALSE`) |
| `monthly_quota_tc` | `INTEGER` | Kuota TimeCoin bulanan untuk mempublikasikan proyek |

#### 5. Tabel `mentor_profiles`
Profil profesional atau mahasiswa berprestasi yang berperan sebagai Mentor.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `user_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (`UNIQUE`) |
| `title_headline` | `VARCHAR(150)` | Jabatan/spesialisasi (contoh: "Senior Flutter Dev @ TechCorp") |
| `bio` | `TEXT` | Deskripsi pengalaman dan rekam jejak bimbingan |
| `hourly_rate_tc` | `INTEGER` | Tarif bimbingan per jam dalam satuan TimeCoin (default: 3 TC) |
| `is_premium` | `BOOLEAN` | Status langganan Premium Mentor (bebas potongan admin cash-out) |
| `rating_average` | `DECIMAL(3,2)` | Nilai rata-rata ulasan bintang murid (0.00 - 5.00) |

---

### 2.2 Modul Proyek UMKM & Kolaborasi (Projects & Workspace)

#### 6. Tabel `projects`
Daftar pekerjaan/proyek yang dipublikasikan oleh Mitra UMKM.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `msme_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (pemilik proyek) |
| `title` | `VARCHAR(200)` | Judul lowongan proyek |
| `category` | `VARCHAR(100)` | Kategori (Mobile Dev, Web, Desain Grafis, Digital Marketing) |
| `description` | `TEXT` | Rincian tugas pekerjaan |
| `reward_tc` | `INTEGER` | Nominal imbalan TimeCoin yang dialokasikan (contoh: 150 TC) |
| `deadline` | `DATE` | Tenggat waktu penyelesaian tugas |
| `requires_endorsement` | `BOOLEAN` | Filter pelamar: Wajib memiliki Badge Rekomendasi Mentor (fitur Premium UMKM) |
| `status` | `VARCHAR(50)` | Status: `open`, `in_progress`, `review`, `completed`, `cancelled` |

#### 7. Tabel `project_applications`
Lamaran yang dikirimkan oleh Mahasiswa untuk proyek tertentu.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `project_id` | `BIGINT` | Foreign Key $\rightarrow$ `projects.id` |
| `student_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` |
| `cover_letter` | `TEXT` | Surat pengantar / penjelasan kesiapan pengerjaan |
| `portfolio_link` | `VARCHAR(255)` | Tautan portofolio eksternal (GitHub / Figma / Behance) |
| `status` | `VARCHAR(50)` | Status lamaran: `pending`, `accepted`, `rejected` |
| `applied_at` | `TIMESTAMP` | Waktu pengajuan lamaran |

#### 8. Tabel `project_deliverables`
Hasil pekerjaan (*deliverable*) yang dikirimkan Mahasiswa untuk dinilai UMKM.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `project_id` | `BIGINT` | Foreign Key $\rightarrow$ `projects.id` |
| `student_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` |
| `submission_notes` | `TEXT` | Catatan penyerahan tugas |
| `deliverable_file_url` | `VARCHAR(255)` | Tautan berkas hasil kerja / repositori |
| `revision_count` | `INTEGER` | Jumlah iterasi revisi yang telah dilakukan |
| `is_approved` | `BOOLEAN` | Persetujuan UMKM atas hasil kerja |
| `submitted_at` | `TIMESTAMP` | Waktu penyerahan tugas |

---

### 2.3 Modul Mentoring & Kelas Bimbingan

#### 9. Tabel `mentoring_classes`
Sesi atau kelas bimbingan yang dibuka oleh Mentor.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `mentor_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` |
| `topic` | `VARCHAR(200)` | Topik bimbingan (contoh: "Arsitektur Clean Feature-First Flutter") |
| `description` | `TEXT` | Silabus dan rincian bimbingan |
| `scheduled_time` | `TIMESTAMP` | Jadwal pelaksanaan sesi |
| `duration_minutes` | `INTEGER` | Durasi sesi bimbingan dalam menit (default: 45 / 60 menit) |
| `price_tc` | `INTEGER` | Biaya pendaftaran kelas dalam TimeCoin |
| `meeting_link` | `VARCHAR(255)` | Tautan ruang virtual bimbingan (Google Meet / Zoom) |
| `status` | `VARCHAR(50)` | Status: `open`, `booked`, `completed`, `cancelled` |

#### 10. Tabel `mentoring_enrollments`
Pendaftaran mahasiswa ke dalam sesi bimbingan mentor.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `class_id` | `BIGINT` | Foreign Key $\rightarrow$ `mentoring_classes.id` |
| `student_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` |
| `paid_tc` | `INTEGER` | Nominal TimeCoin yang dibayarkan |
| `has_endorsement` | `BOOLEAN` | Penanda apakah mahasiswa menerima *Badge Rekomendasi Kerja (Endorse)* |
| `endorsement_notes` | `TEXT` | Catatan rekomendasi dari mentor atas kompetensi murid |
| `status` | `VARCHAR(50)` | Status bimbingan: `enrolled`, `attended`, `absent` |

---

### 2.4 Modul Portofolio & Penilaian (Reputation & Reviews)

#### 11. Tabel `reviews`
Ulasan dan penilaian bintang timbal balik (UMKM ke Mahasiswa, Mahasiswa ke Mentor).
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `reviewer_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (pemberi ulasan) |
| `reviewee_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (penerima ulasan) |
| `project_id` | `BIGINT` | Foreign Key $\rightarrow$ `projects.id` (nullable jika ulasan mentoring) |
| `mentoring_class_id` | `BIGINT` | Foreign Key $\rightarrow$ `mentoring_classes.id` (nullable jika ulasan proyek) |
| `rating` | `INTEGER` | Skor bintang (1 s/d 5) |
| `review_text` | `TEXT` | Komentar ulasan performa |
| `created_at` | `TIMESTAMP` | Waktu ulasan diberikan |

#### 12. Tabel `portfolios`
Katalog portofolio karya mahasiswa yang terverifikasi dari hasil pengerjaan proyek.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `student_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` |
| `project_id` | `BIGINT` | Foreign Key $\rightarrow$ `projects.id` (nullable jika portofolio mandiri) |
| `title` | `VARCHAR(200)` | Judul karya portofolio |
| `category` | `VARCHAR(100)` | Kategori karya |
| `preview_image_url` | `VARCHAR(255)` | Gambar tangkapan layar / thumbnail karya |
| `case_study_url` | `VARCHAR(255)` | Tautan studi kasus / repository |

---

### 2.5 Modul Finansial & Dompet Internal (Wallet & Ledger)

#### 13. Tabel `time_coin_wallets`
Saldo kredit internal yang dimiliki setiap pengguna.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `user_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (`UNIQUE`) |
| `balance` | `INTEGER` | Jumlah saldo TimeCoin aktif (default: 0) |
| `locked_balance` | `INTEGER` | Saldo dalam penahanan garansi transaksi (*escrow*) |
| `updated_at` | `TIMESTAMP` | Waktu mutasi saldo terakhir |

#### 14. Tabel `time_coin_transactions`
Buku besar audit (*audit ledger*) mutasi kredit TimeCoin.
| Nama Kolom | Tipe Data | Keterangan / Atribut |
|---|---|---|
| `id` | `BIGSERIAL` | Primary Key |
| `wallet_id` | `BIGINT` | Foreign Key $\rightarrow$ `time_coin_wallets.id` |
| `sender_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` (nullable jika transaksi sistem) |
| `recipient_id` | `BIGINT` | Foreign Key $\rightarrow$ `users.id` |
| `transaction_type` | `VARCHAR(50)` | `project_reward`, `mentoring_payment`, `top_up`, `voucher_redeem`, `cash_out` |
| `amount` | `INTEGER` | Jumlah kredit TimeCoin yang bermutasi |
| `admin_fee_amount` | `INTEGER` | Potongan biaya admin platform (0 untuk Mahasiswa / Premium Mentor, 10% untuk Freemium Mentor) |
| `reference_type` | `VARCHAR(100)` | Polimorfik: `App\Models\Project`, `App\Models\MentoringClass`, dll. |
| `reference_id` | `BIGINT` | ID record relasi |
| `status` | `VARCHAR(50)` | `pending`, `completed`, `failed`, `cancelled` |
| `created_at` | `TIMESTAMP` | Waktu transaksi dicatat |

---

## 3. Aturan Integritas & Transaksi ACID

1. **Prinsip Double-Entry / Ledger Audit:**
   - Saldo pada `time_coin_wallets` tidak boleh diubah tanpa adanya record transaksi yang valid pada `time_coin_transactions`.
2. **Database Row-Level Locking:**
   - Setiap operasi pengurangan saldo TimeCoin wajib menggunakan klausa `SELECT ... FOR UPDATE` dalam blok transaksi (`DB::transaction`) di Laravel untuk mencegah kondisi *race condition*.
3. **Integritas Relasional (Foreign Key Constraints):**
   - Menggunakan aturan `ON DELETE RESTRICT` pada tabel finansial dan ulasan guna mencegah hilangnya jejak transaksi bersejarah saat ada pembersihan akun.
