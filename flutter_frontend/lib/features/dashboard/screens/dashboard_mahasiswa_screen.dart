import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';
import 'package:flutter_frontend/core/widgets/in_app_guide_section.dart';

class DashboardMahasiswaScreen extends StatelessWidget {
  const DashboardMahasiswaScreen({super.key});

  Widget _buildTaskCard({
    required String businessName,
    required String title,
    required String tcReward,
    required String stageText,
    required double progress,
    required String nextStep,
    required String daysLeft,
    required IconData businessIcon,
    Color? deadlineColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Icon, Business, Title, and TC
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    businessIcon,
                    color: AppColors.primaryNavy,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Business & Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.timelapse_rounded,
                          size: 15,
                          color: AppColors.primaryNavy,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Aktif \u00B7 $businessName',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // TC Badge
              Row(
                children: [
                  const Icon(
                    Icons.toll_rounded,
                    color: AppColors.accentAmberGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$tcReward TC',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar & Stage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderSlate,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryNavy,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                stageText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Meta Row: Next step & Days left
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Berikutnya: $nextStep',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: deadlineColor ?? AppColors.secondarySlate,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysLeft,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: deadlineColor != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: deadlineColor ?? AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text(
              'Keluar dari Akun?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun mahasiswa? Anda harus masuk kembali dengan NIM dan kata sandi.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.secondarySlate,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondarySlate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.roleSelection,
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvasWhite,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Info
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat pagi',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Arya Pratama',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        // Notification Icon with Yellow Dot
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.notifications,
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSlate.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 24,
                                  color: AppColors.darkSlate,
                                ),
                                Positioned(
                                  top: 11,
                                  right: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentAmberGold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Quick Logout Button
                        GestureDetector(
                          onTap: () => _showLogoutConfirmation(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5)
                                    .withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSlate.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 22,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Main Balance & SKS Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Row: Saldo TC & SKS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saldo TimeCoin',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF93C5FD),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentAmberGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.toll_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '150 TC',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Setara Rp150.000',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF93C5FD),
                                ),
                              ),
                            ],
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Proyek Selesai',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF93C5FD),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '3 Proyek',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Quick Action Shortcuts
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.exploreProjects,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Cari Proyek',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.findMentors,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Mentor Saya',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.rewardHub,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Reward',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Showcase Carousel: Kolaborasi UMKM & Peluang Proyek
              InteractiveImageCarousel(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                height: 180,
                items: [
                  CarouselSlideItem(
                    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                    tag: 'Kemitraan UMKM',
                    tagColor: AppColors.primaryNavy,
                    title: 'Dapur Produksi Sambal & Kuliner',
                    subtitle: 'Bantu digitalisasi UMKM lokal Surabaya: desain label kemasan & katalog online.',
                    buttonText: 'Eksplorasi',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.exploreProjects),
                  ),
                  CarouselSlideItem(
                    imageUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
                    tag: 'Bimbingan 1-on-1',
                    tagColor: AppColors.accentAmberGold,
                    title: 'Review Portofolio Bersama Mentor',
                    subtitle: 'Dapatkan badge verifikasi keahlian sebelum melamar tender proyek UMKM.',
                    buttonText: 'Cari Mentor',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.findMentors),
                  ),
                  CarouselSlideItem(
                    imageUrl: 'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=800&q=80',
                    tag: 'Proyek Baru',
                    tagColor: const Color(0xFF10B981),
                    title: 'Aplikasi Menu & Kasir Tepi Kali',
                    subtitle: 'Imbalan 380 TC dengan sistem pencairan fleksibel 0% biaya admin.',
                    buttonText: 'Detail',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.exploreProjects),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Section: Proyek aktif (2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Proyek aktif (2)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.myProjects);
                      },
                      child: const Text(
                        'Tugas Saya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Task Cards List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildTaskCard(
                      businessName: 'Toko Bu Sri',
                      title: 'Aplikasi Kasir Sederhan...',
                      tcReward: '120',
                      stageText: 'Tahap 1/3',
                      progress: 0.33,
                      nextStep: 'Fitur stok & transaksi',
                      daysLeft: '11 hari lagi',
                      businessIcon: Icons.storefront_rounded,
                    ),
                    _buildTaskCard(
                      businessName: 'Keripik Tempe Mak Nah',
                      title: 'Logo dan Kemasan Baru ...',
                      tcReward: '35',
                      stageText: 'Tahap 1/3',
                      progress: 0.33,
                      nextStep: 'Panduan brand & aset grafis',
                      daysLeft: '4 hari lagi',
                      businessIcon: Icons.shopping_bag_rounded,
                      deadlineColor: const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section: Layanan Konsultasi & Mentoring
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Konsultasi & Bimbingan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.findMentors);
                      },
                      child: const Text(
                        'Cari mentor',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Active Mentoring / Consultation Banner Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkSlate.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.school_rounded,
                                color: AppColors.primaryNavy,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Dimas Prasetyo, S.Kom',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Senior Peer',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Sesi Bimbingan Proyek & Review Portofolio',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 14,
                              color: AppColors.primaryNavy,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Jadwal Konsultasi: Hari ini \u00B7 19.30 WIB',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.myMentors,
                                );
                              },
                              icon: const Icon(
                                Icons.list_alt_rounded,
                                size: 16,
                                color: AppColors.primaryNavy,
                              ),
                              label: const Text(
                                'Jadwal Saya',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primaryNavy,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.ruangBelajar,
                                );
                              },
                              icon: const Icon(
                                Icons.meeting_room_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Masuk Sesi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Section: Rekomendasi untukmu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rekomendasi untukmu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.exploreProjects);
                      },
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Recommended Project Preview Card (Sambal Bu Rudi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkSlate.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant_rounded,
                                color: AppColors.primaryNavy,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Sambal Bu Rudi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.primaryNavy,
                                      size: 14,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Klaster Kuliner',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.toll_rounded,
                                  color: AppColors.accentAmberGold,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '300 TC',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Redesain Kemasan & Katalog Online',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tenggat: 3 hari lagi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.projectDetail,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. Section: Panduan & Tips Mahasiswa TalentSync
              _buildStudentGuideSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGuideSection() {
    const studentArticles = [
      InAppArticle(
        id: 'student_guide_cashout',
        title: 'Panduan Aman Mencairkan TimeCoin ke Rupiah (0% Biaya Admin)',
        subtitle: 'Ketahui cara menarik TC hasil proyek langsung ke rekening bank atau e-wallet tanpa potongan.',
        category: 'Keuangan',
        readTime: '3 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=800&q=80',
        icon: Icons.payments_rounded,
        accentColor: Color(0xFF0D9488),
        keyPoints: [
          '1 TC setara Rp1.000 utuh tanpa manipulasi kurs.',
          'Pencairan dana bagi Mahasiswa 100% bebas biaya administrasi (0% admin fee).',
          'Sistem Escrow menjamin dana aman tersimpan hingga UMKM menyetujui tugas akhirmu.',
          'Waktu pemrosesan transfer maksimal 1x24 jam kerja.',
        ],
        fullContent: 'Setiap kali kamu menyelesaikan proyek UMKM dan hasil deliverable telah disetujui, dana TimeCoin (TC) yang tersimpan di brankas Escrow akan otomatis ditransfer ke Dompet TalentSync milikmu.\n\nKamu dapat mencairkan saldo TC kapan saja melalui menu Dompet > Tarik Rupiah. Pilih bank tujuan (BCA, Mandiri, BNI, BRI) atau e-wallet (GoPay, OVO, DANA). Mahasiswa mendapatkan keistimewaan 0% potongan biaya administrasi, sehingga seluruh hasil jerih payahmu diterima 100% utuh.',
        proTip: 'Pastikan nama pemilik rekening bank atau e-wallet sesuai dengan nama lengkap pada Kartu Tanda Mahasiswa (KTM) agar verifikasi transfer berjalan otomatis tanpa penundaan.',
      ),
      InAppArticle(
        id: 'student_guide_badge',
        title: 'Belum Punya Portofolio? Raih Badge Rekomendasi Mentor',
        subtitle: 'Syarat wajib melamar proyek UMKM: portofolio terverifikasi atau badge rekomendasi mentor.',
        category: 'Karier & Mentor',
        readTime: '4 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80',
        icon: Icons.verified_rounded,
        accentColor: AppColors.primaryNavy,
        keyPoints: [
          'UMKM memprioritaskan pelamar dengan Portofolio Terverifikasi atau Badge Mentor.',
          'Sesi bimbingan 1-on-1 dengan Peer Mentor bertarif terjangkau menggunakan TimeCoin.',
          'Selesaikan latihan studi kasus dan raih skor evaluasi minimal >= 80 untuk membuka badge.',
          'Badge otomatis terpasang di profil dan langsung membuka akses seluruh proyek UMKM.',
        ],
        fullContent: 'Jika kamu baru bergabung dan belum memiliki rekam jejak portofolio proyek riil, jangan khawatir! TalentSync menyediakan jalur percepatan bimbingan bersama Peer Mentor (mahasiswa senior berprestasi atau praktisi muda).\n\nCukup buka menu Mentoring, pilih mentor dengan spesialisasi yang kamu minati (UI/UX, Web Dev, Mobile Flutter, Copywriting, Desain Grafis), lalu pesan sesi bimbingan. Di Ruang Belajar, mentor akan menguji kemampuanmu melalui simulasi kasus nyata UMKM. Begitu kamu meraih nilai minimal 80, mentor akan menerbitkan Badge Rekomendasi yang membuktikan bahwa kamu siap kerja!',
        proTip: 'Pelamar yang menyertakan Badge Rekomendasi Mentor memiliki tingkat penerimaan 3.5x lebih tinggi oleh mitra UMKM dibanding pelamar tanpa verifikasi.',
      ),
      InAppArticle(
        id: 'student_guide_switch_mentor',
        title: 'Peluang Switch as a Mentor Setelah Selesaikan 5 Proyek',
        subtitle: 'Tingkatkan peranmu menjadi Peer Mentor dan dapatkan penghasilan TimeCoin tambahan.',
        category: 'Peluang',
        readTime: '3 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=80',
        icon: Icons.school_rounded,
        accentColor: Color(0xFFD97706),
        keyPoints: [
          'Syarat: Menyelesaikan minimal 5 proyek UMKM nyata dengan reputasi baik.',
          'Fleksibilitas mengatur tarif sesi bimbingan TimeCoin sendiri.',
          'Bantu adik tingkat atau mahasiswa baru menguasai keahlian praktis.',
          'Tersedia opsi upgrade ke Akun Mentor Premium untuk 0% biaya admin cash-out.',
        ],
        fullContent: 'TalentSync dirancang sebagai ekosistem pertumbuhan talenta yang berkelanjutan. Ketika kamu telah membuktikan keahlianmu dengan menuntaskan 5 proyek UMKM nyata dan mendapatkan rating positif, kamu memenuhi kualifikasi untuk beralih peran menjadi Peer Mentor.\n\nMelalui menu Profil > Beralih Menjadi Mentor (Switch as a Mentor), daftarkan keahlian utamamu, unggah bukti portofolio terbaik, dan tentukan jadwal serta tarif bimbinganmu. Kamu bisa mengajar adik tingkat, memberikan review tugas, dan mencairkan imbalan TimeCoin yang kamu dapatkan.',
        proTip: 'Menjadi Peer Mentor tidak hanya menambah saldo TimeCoin, tetapi juga memperkuat portofolio kepemimpinan (leadership & mentoring) saat kamu melamar kerja di industri nanti.',
      ),
    ];

    return const InAppGuideSection(
      title: 'Panduan & Kiat Sukses Mahasiswa',
      subtitle: 'Pelajari alur pengerjaan proyek, pencairan TimeCoin, dan bimbingan mentor',
      articles: studentArticles,
    );
  }
}
