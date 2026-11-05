import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';
import 'package:flutter_frontend/core/widgets/in_app_guide_section.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_applicants_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_submission_screen.dart';

class MsmeDashboardScreen extends StatelessWidget {
  const MsmeDashboardScreen({
    super.key,
    required this.onCreateProject,
    required this.onOpenPostings,
    required this.onOpenBarter,
    required this.onOpenProfile,
  });

  final VoidCallback onCreateProject;
  final VoidCallback onOpenPostings;
  final VoidCallback onOpenBarter;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderSlate,
                          width: 1.5,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=150&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat pagi, Bu Rina',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.secondarySlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kopi Tepi Kali',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkSlate,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.darkSlate,
                            size: 24,
                          ),
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Blue Saldo Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo TimeCoin usaha',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(
                            Icons.toll_rounded,
                            color: Color(0xFFF59E0B),
                            size: 26,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '520 TC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Setara Rp520.000',
                        style: TextStyle(
                          color: const Color(0xFF93C5FD),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSaldoAction(
                              label: 'Top Up',
                              icon: Icons.add_circle_outline_rounded,
                              isPrimary: true,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Menu Top Up TimeCoin dibuka.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSaldoAction(
                              label: 'Barter',
                              icon: Icons.swap_horiz_rounded,
                              isPrimary: false,
                              onTap: onOpenBarter,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSaldoAction(
                              label: 'Riwayat',
                              icon: Icons.history_rounded,
                              isPrimary: false,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Riwayat mutasi TimeCoin.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Verified Partner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderSlate.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
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
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verified Partner',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Slot proyek 2/2 \u00B7 admin top up 5%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.msmeUpgradePro,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Upgrade',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 2-segment progress bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Slot penuh. Upgrade untuk posting proyek baru ke mahasiswa.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Navigasi Cepat & Status Pekerjaan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Navigasi Cepat & Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 12,
                            color: AppColors.primaryNavy,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Pilih Aksi',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 3 Metric Quick-Nav Cards
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.assignment_rounded,
                          count: '2',
                          label: 'Proyek aktif',
                          buttonLabel: 'Kelola',
                          accentColor: AppColors.primaryNavy,
                          onTap: onOpenPostings,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.person_add_rounded,
                          count: '2',
                          label: 'Pelamar baru',
                          buttonLabel: 'Review',
                          badgeLabel: 'Baru',
                          accentColor: const Color(0xFF0284C7),
                          onTap: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MsmeReviewApplicantsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.rate_review_rounded,
                          count: '1',
                          label: 'Perlu ditinjau',
                          buttonLabel: 'Tinjau',
                          badgeLabel: 'Tugas',
                          accentColor: const Color(0xFFD97706),
                          onTap: () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MsmeReviewSubmissionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Showcase Carousel: Talenta Mahasiswa Siap Diberdayakan
                InteractiveImageCarousel(
                  margin: EdgeInsets.zero,
                  height: 180,
                  items: [
                    CarouselSlideItem(
                      imageUrl: 'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=800&q=80',
                      tag: 'Talenta Desain',
                      tagColor: AppColors.primaryNavy,
                      title: 'Desain Kemasan & Mockup Produk',
                      subtitle: 'Mahasiswa DKV & Desain siap merancang identitas visual kemasan produk tokomu.',
                      buttonText: 'Buat Tugas',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.msmeCreateTask,
                      ),
                    ),
                    CarouselSlideItem(
                      imageUrl: 'https://images.unsplash.com/photo-1556742049-0a67c5574f73?auto=format&fit=crop&w=800&q=80',
                      tag: 'Aplikasi & Web',
                      tagColor: const Color(0xFF0284C7),
                      title: 'Aplikasi Kasir & Sistem Reservasi',
                      subtitle: 'Digitalisasi sistem kasir dan inventaris bersama mahasiswa Sistem Informasi.',
                      buttonText: 'Buat Tugas',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.msmeCreateTask,
                      ),
                    ),
                    CarouselSlideItem(
                      imageUrl: 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=800&q=80',
                      tag: 'Garansi Escrow',
                      tagColor: const Color(0xFF10B981),
                      title: 'Kemitraan Aman & Terlindungi',
                      subtitle: 'Imbalan TimeCoin hanya cair setelah kamu memvalidasi hasil kerja mahasiswa.',
                      buttonText: 'Pelajari',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.msmeUpgradePro,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Section: Perlu tindakan
                const Text(
                  'Perlu tindakan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Card 1: Salsa Putri
                _buildActionItem(
                  context,
                  avatarWidget: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2410C),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'SP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  title: 'Salsa Putri mengajukan hasil',
                  subtitle: 'Tahap 2: Menu board final \u00B7 45 TC',
                  buttonLabel: 'Tinjau',
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MsmeReviewSubmissionScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Action Card 2: 2 Pelamar baru
                _buildActionItem(
                  context,
                  avatarWidget: SizedBox(
                    width: 58,
                    height: 38,
                    child: Stack(
                      children: [
                        _buildMiniAvatar('RH', const Color(0xFF9A3412), 30),
                        _buildMiniAvatar('DL', const Color(0xFF0D9488), 15),
                        _buildMiniAvatar('AR', AppColors.primaryNavy, 0),
                      ],
                    ),
                  ),
                  title: '2 pelamar baru',
                  subtitle: 'Aplikasi Menu & Pre-ord...',
                  buttonLabel: 'Review',
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MsmeReviewApplicantsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Section: Proyek berjalan
                const Text(
                  'Proyek berjalan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Ongoing Project Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(14),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=150&q=80',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Desain Menu Board & Fee...',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Salsa Putri \u00B7 UNESA',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: 'Chat',
                              onPressed: () {
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MsmeChatScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppColors.darkSlate,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.33,
                                minHeight: 6,
                                backgroundColor: Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryNavy,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Tahap 1/3',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section: Panduan & Wawasan Mitra UMKM
                _buildMsmeGuideSection(),
              ],
            ),
          ),

          // Floating Action Button: "+ Buat Proyek Baru"
          Positioned(
            right: 20,
            bottom: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCreateProject,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Buat Proyek Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSaldoAction({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) => Container(
    height: 44,
    decoration: BoxDecoration(
      color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? AppColors.primaryNavy : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppColors.primaryNavy : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildMetricCard({
    required IconData icon,
    required String count,
    required String label,
    required String buttonLabel,
    required VoidCallback onTap,
    Color accentColor = AppColors.primaryNavy,
    String? badgeLabel,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    if (badgeLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondarySlate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6.5),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildActionItem(
    BuildContext context, {
    required Widget avatarWidget,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderSlate),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        avatarWidget,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildMiniAvatar(String text, Color bg, double left) => Positioned(
    left: left,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Widget _buildMsmeGuideSection() {
    const msmeArticles = [
      InAppArticle(
        id: 'msme_guide_post_task',
        title:
            'Panduan Memposting Tugas & Menentukan Imbalan TimeCoin yang Tepat',
        subtitle: 'Tips merumuskan brief deliverable yang jelas dan menetapkan alokasi TC yang proporsional.',
        category: 'Manajemen Proyek',
        readTime: '3 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1556740758-90de374c12ad?auto=format&fit=crop&w=800&q=80',
        icon: Icons.assignment_rounded,
        accentColor: AppColors.primaryNavy,
        keyPoints: [
          'Rumuskan deliverable spesifik (contoh: 1 Master Logo vector, 10 foto katalog 4K, atau 1 landing page responsif).',
          '1 TC bernilai setara Rp1.000. Gunakan patokan template wizard atau ajukan proyek kustom sesuai anggaran.',
          'Top-Up TimeCoin via Rupiah (Transfer Bank / QRIS) tanpa kerumitan administrasi.',
          'Imbalan disimpan aman di escrow dan hanya dicairkan setelah tugas kamu setujui.',
        ],
        fullContent: 'Membuat tugas di TalentSync sangat mudah berkat fitur Wizard Template dan Proyek Kustom. Kunci utama mendapatkan hasil terbaik dari mahasiswa adalah menulis deskripsi tugas yang lugas serta melampirkan contoh referensi (moodboard/foto produk eksisting).\n\nSesuaikan alokasi imbalan TimeCoin (TC) dengan bobot pekerjaan (misal: 80-150 TC untuk Desain Logo, 40-90 TC untuk Foto Produk UMKM). Dana TC yang kamu siapkan akan masuk ke sistem escrow TalentSync, memberikan rasa aman bagi kedua belah pihak.',
        proTip: 'Tentukan tenggat waktu (deadline) yang realistis minimal 3-5 hari agar mahasiswa memiliki waktu memadai untuk konsultasi dengan mentor sebelum pengumpulan final.',
      ),
      InAppArticle(
        id: 'msme_guide_badge_talents',
        title: 'Mengapa Harus Memilih Pelamar Ber-Badge Rekomendasi Mentor?',
        subtitle: 'Jaminan kualitas kerja nyata: mahasiswa yang telah diuji dan divalidasi oleh mentor senior.',
        category: 'Seleksi Talenta',
        readTime: '4 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=800&q=80',
        icon: Icons.verified_user_rounded,
        accentColor: Color(0xFF0D9488),
        keyPoints: [
          'Mahasiswa ber-badge telah menyelesaikan uji studi kasus dengan skor minimal 80 dari Peer Mentor.',
          'Meminimalkan risiko hasil kerja tidak sesuai standar atau kesalahan teknis fatal.',
          'Gunakan fitur "Tolak & Arahkan Bimbingan" untuk membina pelamar yang potensial namun belum siap.',
          'Fitur filter pelamar ber-badge otomatis tersedia bagi pemegang akun Premium UMKM.',
        ],
        fullContent: 'Di TalentSync, mahasiswa tidak hanya mengunggah klaim keahlian sepihak. Mahasiswa yang memiliki Badge Rekomendasi Mentor telah melalui proses uji kualifikasi ketat di Ruang Belajar bersama Peer Mentor berpengalaman.\n\nJika kamu menerima lamaran dari mahasiswa yang belum ber-badge dan hasil portofolionya belum meyakinkan, kamu bisa menggunakan tombol "Tolak & Arahkan Bimbingan". Sistem akan mengirimkan pesan edukatif yang membimbing mahasiswa tersebut untuk mengikuti mentoring terlebih dahulu sebelum melamar kembali di usahamu.',
        proTip: 'Pelamar ber-badge mentor memiliki tingkat keberhasilan menyelesaikan proyek tepat waktu sebesar 96% tanpa perlu revisi berulang.',
      ),
      InAppArticle(
        id: 'msme_guide_smart_escrow',
        title: 'Sistem Smart Escrow: Cara Aman Kolaborasi Tanpa Risiko',
        subtitle: 'Proteksi transaksi 100%: dana imbalan baru ditransfer setelah hasil pekerjaan disetujui.',
        category: 'Keamanan Transaksi',
        readTime: '3 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=800&q=80',
        icon: Icons.shield_rounded,
        accentColor: Color(0xFFD97706),
        keyPoints: [
          'Dana TimeCoin terkunci di brankas escrow selama masa pengerjaan proyek.',
          'UMKM memegang kendali penuh validasi hasil kerja sebelum dana dilepas.',
          'Tersedia hak pengajuan revisi hingga 2x bila deliverable belum sesuai brief kesepakatan.',
          'Layanan mediasi bantuan mentor pendamping jika terjadi kendala komunikasi teknis.',
        ],
        fullContent: 'Kekhawatiran terbesar pemilik UMKM saat bekerjasama dengan pekerja lepas adalah risiko dana hangus sementara hasil pekerjaan tidak selesai. TalentSync menghapus risiko tersebut melalui sistem Smart Escrow.\n\nSaat kamu menerima pelamar, TimeCoin sesuai imbalan proyek akan dibekukan sementara di rekening penampung (escrow). Mahasiswa hanya menerima transfer koin setelah kamu menekan tombol "Validasi Hasil & Transfer Imbalan". Jika ada ketidaksesuaian, kamu bisa meminta revisi atau menyarankan mahasiswa berkonsultasi dengan mentor pendamping.',
        proTip: 'Jangan ragu memberikan review dan rating bintang 5 jika mahasiswa memberikan hasil kerja di atas ekspektasi untuk membantu membangun reputasi digital mereka.',
      ),
    ];

    return const InAppGuideSection(
      padding: EdgeInsets.zero,
      title: 'Panduan & Wawasan Mitra UMKM',
      subtitle: 'Kiat posting proyek berkualitas, sistem garansi escrow, dan seleksi mahasiswa',
      articles: msmeArticles,
    );
  }
}
