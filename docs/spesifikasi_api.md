# Spesifikasi Endpoint RESTful API TalentSync
**Protokol:** HTTPS  
**Format Pertukaran Data:** JSON (`Content-Type: application/json`, `Accept: application/json`)  
**Mekanisme Autentikasi:** Bearer Token (*Laravel Sanctum*)  

Dokumen ini mendefinisikan kontrak antarmuka API antara aplikasi seluler Flutter (*Client*) dan backend Laravel (*Server*).

---

## 1. Modul Autentikasi & Akun (`/api/auth`)

### 1.1 Registrasi Pengguna Baru
* **Endpoint:** `POST /api/auth/register`
* **Akses:** Publik
* **Request Body:**
  ```json
  {
    "name": "Arya Pratama",
    "email": "arya@mhs.unesa.ac.id",
    "password": "Password123!",
    "password_confirmation": "Password123!",
    "role": "student",
    "university": "Universitas Negeri Surabaya",
    "major": "S1 Sistem Informasi",
    "student_id_number": "24051214017"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "message": "Registrasi berhasil.",
    "data": {
      "user": {
        "id": 1,
        "name": "Arya Pratama",
        "email": "arya@mhs.unesa.ac.id",
        "role": "student"
      },
      "token": "1|sanctum_token_string_here"
    }
  }
  ```

### 1.2 Login Pengguna
* **Endpoint:** `POST /api/auth/login`
* **Akses:** Publik
* **Request Body:**
  ```json
  {
    "email": "arya@mhs.unesa.ac.id",
    "password": "Password123!"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Login berhasil.",
    "data": {
      "token": "2|sanctum_token_string_here",
      "user": {
        "id": 1,
        "name": "Arya Pratama",
        "role": "student",
        "is_mentor": false,
        "balance_tc": 150
      }
    }
  }
  ```

---

## 2. Modul Proyek UMKM (`/api/projects`)

### 2.1 Menjelajahi Daftar Proyek (Explore Projects)
* **Endpoint:** `GET /api/projects`
* **Akses:** Terautentikasi (Semua Peran)
* **Query Parameters:** `?category=Mobile&search=flutter&page=1`
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": 101,
        "title": "Redesain UI Aplikasi Kasir Toko Berkah",
        "category": "Mobile Dev",
        "description": "Membuat antarmuka kasir Android responsif dan rapi.",
        "reward_tc": 150,
        "deadline": "2026-11-15",
        "requires_endorsement": false,
        "msme": {
          "id": 5,
          "business_name": "Toko Berkah Mandiri",
          "city": "Surabaya"
        }
      }
    ],
    "meta": { "current_page": 1, "last_page": 4 }
  }
  ```

### 2.2 Melamar Proyek (Apply Project)
* **Endpoint:** `POST /api/projects/{id}/apply`
* **Akses:** Khusus Mahasiswa
* **Request Body:**
  ```json
  {
    "cover_letter": "Saya berpengalaman membangun UI Flutter selama 2 semester.",
    "portfolio_link": "https://github.com/arya/pos-app"
  }
  ```
* **Response (201 Created):**
  ```json
  {
    "status": "success",
    "message": "Lamaran berhasil diajukan dan menunggu kurasi UMKM."
  }
  ```

### 2.3 Evaluasi & Validasi Hasil Kerja (Approve & Transfer TC)
* **Endpoint:** `POST /api/projects/{id}/approve-and-transfer`
* **Akses:** Khusus Pemilik Proyek (UMKM)
* **Request Body:**
  ```json
  {
    "rating": 5,
    "review_text": "Pengerjaan rapi, cepat, dan kode sangat modular!",
    "transfer_tc": 150
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Hasil kerja disetujui, proyek selesai, dan 150 TC berhasil ditransfer ke mahasiswa."
  }
  ```

---

## 3. Modul Mentoring & Kelas Bimbingan (`/api/mentoring`)

### 3.1 Daftar Mentor & Kelas Terbuka
* **Endpoint:** `GET /api/mentoring/classes`
* **Akses:** Terautentikasi
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": 201,
        "mentor_name": "Budi Santoso",
        "title_headline": "Senior Dev @ Gojek",
        "topic": "Clean Feature-First Flutter Architecture",
        "scheduled_time": "2026-11-05 19:30:00",
        "price_tc": 3,
        "rating": 4.9
      }
    ]
  }
  ```

### 3.2 Pemesanan Sesi Mentoring (Book Session)
* **Endpoint:** `POST /api/mentoring/classes/{id}/book`
* **Akses:** Khusus Mahasiswa
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Pendaftaran bimbingan berhasil. Saldo dipotong 3 TC.",
    "data": {
      "meeting_link": "https://meet.google.com/xyz-abcd-qwe",
      "scheduled_time": "2026-11-05 19:30:00"
    }
  }
  ```

### 3.3 Pemberian Badge Rekomendasi (Endorse Student)
* **Endpoint:** `POST /api/mentoring/enrollments/{id}/endorse`
* **Akses:** Khusus Mentor
* **Request Body:**
  ```json
  {
    "endorsement_notes": "Mahasiswa menguasai state management Provider dan BLoC dengan sangat baik."
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Badge Rekomendasi Kerja berhasil disematkan ke portofolio mahasiswa."
  }
  ```

---

## 4. Modul Dompet Internal & Finansial (`/api/wallet`)

### 4.1 Cek Saldo & Mutasi Buku Besar
* **Endpoint:** `GET /api/wallet/summary`
* **Akses:** Terautentikasi
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "data": {
      "balance_tc": 150,
      "estimated_idr": 150000,
      "recent_transactions": [
        {
          "id": 501,
          "type": "project_reward",
          "amount": 150,
          "description": "Imbalan Proyek Redesain UI Toko Berkah",
          "created_at": "2026-10-29 14:00:00"
        }
      ]
    }
  }
  ```

### 4.2 Penarikan Dana ke Rupiah (Cash-Out)
* **Endpoint:** `POST /api/wallet/cash-out`
* **Akses:** Mahasiswa & Mentor
* **Request Body:**
  ```json
  {
    "amount_tc": 150,
    "bank_name": "BCA",
    "account_number": "1234567890",
    "account_holder_name": "Arya Pratama"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Pengajuan pencairan berhasil. Mahasiswa bebas biaya admin (0%). Dana bersih: Rp150.000.",
    "data": {
      "disbursed_amount_idr": 150000,
      "admin_fee_idr": 0,
      "status": "pending_transfer"
    }
  }
  ```

---

## 5. Standar Format Kesalahan (Error Responses)

Semua endpoint mengembalikan struktur error yang seragam jika validasi atau otorisasi gagal:

### Error Validasi (422 Unprocessable Entity):
```json
{
  "status": "error",
  "message": "Validasi formulir gagal.",
  "errors": {
    "reward_tc": ["Nominal imbalan TimeCoin minimal 10 TC."]
  }
}
```

### Error Otorisasi Peran (403 Forbidden):
```json
{
  "status": "error",
  "message": "Anda tidak memiliki kewenangan untuk mengakses tindakan ini."
}
```

