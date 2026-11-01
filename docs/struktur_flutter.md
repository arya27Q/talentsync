# Struktur Folder & Arsitektur Direktori Flutter (Feature-First Clean Architecture)
**Aplikasi:** TalentSync — Mobile Platform Kolaborasi Mahasiswa, UMKM, dan Mentor  
**Pola Arsitektur:** Feature-First Architecture dengan Pemisahan Tanggung Jawab (Separation of Concerns)  

Untuk proyek berskala menengah ke atas dengan *multi-role* (Mahasiswa, UMKM, dan Mentor), struktur direktori disusun menggunakan pendekatan **Feature-First Architecture**. Setiap fitur utama diisolasi secara mandiri dalam direktori khusus sehingga mudah dirawat, diskalakan, dan dikembangkan secara paralel oleh tim tanpa konflik kode.

---

## 📁 1. Struktur Direktori Standar Per Fitur (`features/nama_fitur/`)

Setiap folder fitur di dalam `lib/features/` wajib mengikuti pola struktur terstandar berikut:

```text
features/nama_fitur/
├── data/ (atau services/)  # Pemanggilan API / repository / datasource khusus fitur tersebut
├── models/                 # Data model & JSON serialization (fromJson / toJson)
├── controllers/            # Logika bisnis & state management (pengganti nama 'logic/' atau 'providers/')
├── screens/ (atau views/)  # Halaman utama & modal full-page (pengganti nama 'ui/')
├── widgets/                # Komponen UI pecahan modular (kartu, list item, custom badge, header)
└── utils/ (opsional)       # Helper, validator, konstanta, atau formatter khusus fitur itu
```

### 📋 Peran & Tanggung Jawab Sub-Direktori Fitur:

| Sub-Direktori | Peran Utama | Contoh Berkas |
|---|---|---|
| **`data/`** *(atau `services/`)* | Menangani pemanggilan endpoint backend (RESTful API Laravel), integrasi database lokal, atau abstraksi *repository pattern* khusus fitur. | `project_api_service.dart`, `mentoring_repository.dart` |
| **`models/`** | Mendefinisikan struktur data entitas, tipe atribut, validasi null safety, dan serialisasi data JSON. | `project_model.dart`, `mentor_class_model.dart`, `wallet_transaction_model.dart` |
| **`controllers/`** | Pusat logika bisnis, pemrosesan event, dan pengelolaan status (*state management*) reaktif. Menggantikan penamaan lama `logic/` atau `providers/`. | `project_controller.dart`, `booking_session_controller.dart`, `wallet_controller.dart` |
| **`screens/`** *(atau `views/`)* | Lapisan antarmuka pengguna level halaman (screen/page) yang terhubung ke rute navigasi dan mengikat *controller* ke UI. | `explore_projects_screen.dart`, `find_mentors_screen.dart`, `wallet_dashboard_screen.dart` |
| **`widgets/`** | Potongan komponen antarmuka yang dapat digunakan kembali (*reusable components*) dalam cakupan fitur terkait. | `project_card.dart`, `mentor_stat_badge.dart`, `coin_balance_banner.dart` |
| **`utils/`** *(opsional)* | Berkas utilitas, kalkulator nilai, atau pemformat teks spesifik untuk fitur tersebut. | `project_date_formatter.dart`, `timecoin_calculator.dart` |

---

## 📁 2. Peta Lengkap Struktur `lib/` TalentSync

Berikut adalah arsitektur direktori lengkap aplikasi `flutter_frontend/lib/`:

```text
lib/
│
├── core/                                 # 1. Fondasi Global Aplikasi (Shared Across Features)
│   ├── constants/                        # Konstanta global (AppColors, AppFonts, AppStrings)
│   │   └── app_colors.dart
│   ├── network/                          # Konfigurasi HTTP Client, Base URL, Auth Interceptor
│   ├── routes/                           # Navigasi rute terpusat berbasis peran (AppRoutes)
│   │   └── app_routes.dart
│   ├── utils/                            # Helper global (format Rupiah, format tanggal, currency)
│   └── widgets/                          # Widget global yang dipakai lintas fitur (TimeCoinIcon, GradientBackground)
│       ├── gradient_background.dart
│       └── time_coin_icon.dart
│
├── features/                             # 2. Modul Fitur Mandiri (Feature-First)
│   │
│   ├── auth/                             # Fitur Otentikasi & Registrasi Multi-Role
│   │   ├── controllers/                  # State login, register, dan verifikasi dokumen
│   │   ├── data/                         # API login, register, upload KTM/identitas usaha
│   │   ├── models/                       # UserModel, AuthTokenModel
│   │   ├── screens/                      # student_auth_screen, mentor_auth_screen, msme_auth_screen, onboarding
│   │   └── widgets/                      # shared_auth_layout, auth_text_field
│   │
│   ├── dashboard/                        # Fitur Dasbor Utama Berdasarkan Peran
│   │   ├── controllers/                  # Summary data & metric tracker controller
│   │   ├── data/                         # API fetch status proyek & kuota TimeCoin
│   │   ├── models/                       # DashboardStatsModel
│   │   ├── screens/                      # dashboard_mahasiswa_screen, student_main_layout
│   │   └── widgets/                      # stat_card, recent_activity_list
│   │
│   ├── project/                          # Fitur Eksplorasi & Manajemen Proyek UMKM
│   │   ├── controllers/                  # ProjectFilterController, ApplicationController
│   │   ├── data/                         # ProjectApiService (CRUD Proyek & Submit Lamaran)
│   │   ├── models/                       # ProjectModel, ProjectApplicationModel, DeliverableModel
│   │   ├── screens/                      # explore_projects_screen, my_projects_screen, project_detail_screen
│   │   └── widgets/                      # project_card, applicant_item, submission_modal
│   │
│   ├── mentoring/                        # Fitur Mentoring Mahasiswa (Find & Book Mentor)
│   │   ├── controllers/                  # MentorSearchController, BookingController
│   │   ├── data/                         # MentoringApiService (Daftar mentor, book session, review)
│   │   ├── models/                       # MentorModel, MentoringSessionModel
│   │   ├── screens/                      # find_mentors_screen, mentor_profile_screen, booking_session_screen, mentor_chat_screen
│   │   └── widgets/                      # mentor_card, skill_chip, review_tile
│   │
│   ├── mentor/                           # Fitur POV Khusus Pengajar / Mentor
│   │   ├── controllers/                  # MentorScheduleController, EndorsementController
│   │   ├── data/                         # MentorDashboardApiService (kelola murid & tarif)
│   │   ├── models/                       # StudentEnrollmentModel, ServicePriceModel
│   │   ├── screens/                      # mentor_dashboard_screen, mentor_bookings_screen, mentor_services_screen, mentor_wallet_screen
│   │   └── widgets/                      # mentor_ui, student_eval_card, badge_stamp_widget
│   │
│   ├── wallet/                           # Fitur Dompet TimeCoin, Mutasi & Cash-Out
│   │   ├── controllers/                  # WalletController, CashOutController
│   │   ├── data/                         # WalletApiService (saldo, ledger transaksi, withdraw)
│   │   ├── models/                       # WalletSummaryModel, TransactionLedgerModel
│   │   ├── screens/                      # wallet_dashboard_screen, reward_hub_screen, transfer_screen, history_screen
│   │   └── widgets/                      # balance_card, transaction_item, voucher_card
│   │
│   ├── workspace/                        # Fitur Kanban Workspace, Deliverable & Chat Proyek
│   │   ├── controllers/                  # KanbanController, WorkspaceChatController
│   │   ├── data/                         # WorkspaceApiService (update task stage, send deliverable)
│   │   ├── models/                       # KanbanTaskModel, WorkspaceMessageModel
│   │   ├── screens/                      # workspace_kanban_screen, workspace_chat_screen, submission_screen, inbox_screen
│   │   └── widgets/                      # kanban_column, task_card, chat_bubble
│   │
│   ├── portfolio/                        # Fitur Galeri Portofolio & Case Study Mahasiswa
│   │   ├── controllers/                  # PortfolioController
│   │   ├── data/                         # PortfolioApiService
│   │   ├── models/                       # PortfolioModel, CaseStudyModel
│   │   ├── screens/                      # portfolio_dashboard_screen, case_study_screen
│   │   └── widgets/                      # portfolio_gallery_card, verified_badge
│   │
│   ├── profile/                          # Fitur Profil Pengguna, Pengaturan & Switch Mode
│   │   ├── controllers/                  # ProfileController, SwitchMentorController
│   │   ├── data/                         # ProfileApiService
│   │   ├── models/                       # UserProfileModel
│   │   ├── screens/                      # edit_profile_screen, student_settings_screen, help_support_screen, privacy_security_screen
│   │   └── widgets/                      # profile_header, settings_tile, switch_mentor_dialog
│   │
│   ├── notifications/                    # Fitur Notifikasi Real-Time & Riwayat Pengingat
│   │   ├── controllers/                  # NotificationController
│   │   ├── data/                         # NotificationApiService
│   │   ├── models/                       # AppNotificationModel
│   │   ├── screens/                      # notifications_screen.dart
│   │   └── widgets/                      # notification_item_tile
│   │
│   ├── chat/                             # Fitur Ruang Virtual & Video Call
│   │   ├── controllers/                  # VideoCallController
│   │   ├── data/                         # CallSignalingService
│   │   ├── models/                       # CallSessionModel
│   │   ├── screens/                      # video_call_screen.dart
│   │   └── widgets/                      # call_controls_bar
│   │
│   └── gamification/                     # Fitur Badge Prestasi & Pencapaian
│       ├── controllers/                  # AchievementController
│       ├── data/                         # AchievementApiService
│       ├── models/                       # BadgeModel
│       ├── screens/                      # .gitkeep
│       └── widgets/                      # achievement_popup.dart
│
├── main.dart                             # Titik masuk utama aplikasi (Entry Point)
├── role_selection_screen.dart            # Layar pemilihan peran awal (Mahasiswa / UMKM / Mentor)
└── splash_screen.dart                    # Layar splash pembuka aplikasi
```

---

## 📝 3. Mengapa Menggunakan Arsitektur Ini?

1. **Pemisahan Logika & Tampilan (Separation of Concerns):**
   - File antarmuka di `screens/` dan `widgets/` hanya berfokus pada rendering visual, penataan tata letak, dan interaksi pengguna.
   - Semua pemanggilan HTTP, validasi form, dan manipulasi state berada di `controllers/` dan `data/`.
2. **Skalabilitas Tinggi (Scalability):**
   - Menambahkan fitur baru (misalnya modul pelatihan baru atau integrasi QRIS) cukup dengan menduplikasi struktur 5 folder standar tanpa menyentuh fitur lain yang sudah berjalan.
3. **Pengujian Lebih Mudah (Testability):**
   - `controllers/` dan `data/` dapat diuji menggunakan *unit test* dan *mock test* tanpa memerlukan rendering *widget tree* Flutter.
   - `widgets/` dan `screens/` dapat diuji secara terpisah menggunakan *widget test*.
4. **Anti "Spaghetti Code" & AI Slop:**
   - Menghindari pembuatan berkas monolitik raksasa yang menumpuk logika API, state, dan widget dalam satu file 1000+ baris.
