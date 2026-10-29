# 🚀 Skenario Presentasi Demo (TalentSync)

Untuk memberikan presentasi yang memukau (mind-blowing) kepada Dosen/Penguji, gunakan trik **"Mock Mode / Fake It Till You Make It"**. Aplikasi tidak harus memiliki backend yang mahal (seperti Zoom SDK atau Firebase aktif penuh), tetapi harus bisa mensimulasikan *Output Nyata* di depan mata Dosen.

Berikut adalah 5 fitur utama yang bisa didemokan beserta output nyatanya:

### 1. Sesi Mentoring (Output: Buka Google Meet)
* **Deskripsi**: Saat Mahasiswa ingin bergabung ke sesi mentoring yang sudah dipesan.
* **Cara Demo**: Di layar *Upcoming Sessions* (atau *Mentor Chat*), klik tombol **"Join Virtual Workspace" / Ikon Video**.
* **Output Nyata**: Aplikasi menggunakan `url_launcher` untuk membuka aplikasi Google Meet bawaan HP (atau browser) langsung menuju link *room meeting* yang sudah disediakan. (Atau buka UI dummy Video Call jika ingin memperlihatkan desain UI).

### 2. Notifikasi Booking (Output: Kirim Email Otomatis)
* **Deskripsi**: Simulasi sistem backend mengirimkan notifikasi.
* **Cara Demo**: Setelah Mahasiswa menekan "Book for 3 TC", atau Mentor melakukan "Confirm Withdrawal".
* **Output Nyata**: Buka tab Gmail di laptop saat presentasi dan tunjukkan notifikasi email betulan yang baru masuk, misalnya: *"TalentSync: Booking Mentoring Anda dengan Arya (Flutter) telah Dikonfirmasi!"* (Bisa dikirim via *NodeMailer/SendGrid* script sederhana yang di-trigger).

### 3. Top-Up & Pembayaran (Output: Payment Gateway Midtrans Sandbox)
* **Deskripsi**: Menunjukkan bahwa aplikasi siap komersialisasi.
* **Cara Demo**: Klik tombol "Upgrade for Rp50.000" atau "Beli Koin".
* **Output Nyata**: Muncul pop-up halaman pembayaran resmi dari **Midtrans** (Mode Sandbox/Testing). Lakukan simulasi pembayaran sukses menggunakan QRIS Simulator. Saldo akan otomatis bertambah setelahnya.

### 4. Kolaborasi Proyek UMKM (Output: Real-Time Chat & Auto-Reply)
* **Deskripsi**: Fitur *Workspace Chat* tempat UMKM dan Mahasiswa bertukar pesan.
* **Cara Demo**: Buka layar *Workspace Chat*, lalu ketik pesan "Halo Pak, desain logonya sudah saya kirim ya", lalu klik *Send*.
* **Output Nyata**: Setelah 2 detik, aplikasi secara otomatis merespons pesan tersebut ("Siap! Ditunggu updatenya ya mas bro..."). Ini mensimulasikan seolah-olah pihak UMKM membalas pesan secara *real-time*, membuat demo terasa sangat interaktif.

### 5. Pencairan Reward (Output: Generate QR Code)
* **Deskripsi**: Mahasiswa menukarkan *TimeCoin* (TC) dengan *voucher* atau barang fisik.
* **Cara Demo**: Masuk ke *Reward Hub*, pilih "Voucher Kopi Gratis", lalu klik *Redeem*.
* **Output Nyata**: Muncul pop-up modal yang me-render **QR Code** unik. Arahkan HP ke Dosen dan s sampaikan: *"QR Code ini nanti langsung di-scan oleh kasir UMKM untuk validasi, Pak."* (Menggunakan `qr_flutter`).

---

### 💡 Alur Demo Urutan (Golden Path):
Biar presentasi mulus, lakukan urutan ini:
1. **UMKM Posing Task**: Buka Emulator (sebagai UMKM), tunjukkan proses *upload* proyek desain.
2. **Mahasiswa Apply & Chat**: Pindah ke HP Fisik (sebagai Mahasiswa), daftar proyeknya, buka *Workspace Chat*, dan demokan fitur *Auto-Reply* Chat.
3. **Mahasiswa Submit Task**: Swipe *"Swipe to Complete Task"*. Dapatkan *TimeCoin*.
4. **Booking Mentor**: Pakai *TimeCoin* tersebut untuk booking mentor.
5. **Show Output**: Buka Gmail untuk tunjukkan email konfirmasi masuk, lalu klik ikon kamera di *Mentor Chat* untuk ngebuka *Video Call UI*.
