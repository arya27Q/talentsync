import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/in_app_guide_section.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_live_mentoring_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_recommendation_screen.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({
    super.key,
    this.onOpenWallet,
    this.onOpenBookings,
    this.onOpenServices,
    this.onOpenProfile,
    this.onOpenLiveSession,
  });

  final VoidCallback? onOpenWallet;
  final VoidCallback? onOpenBookings;
  final VoidCallback? onOpenServices;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenLiveSession;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        // Generous bottom padding (120) ensures content is never blocked by floating bottom navigation
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'DP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat sore',
                      style: TextStyle(
                        color: AppColors.secondarySlate,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Dimas Prasetyo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.darkSlate,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _TopAction(
                icon: Icons.chat_bubble_rounded,
                label: 'Pesan',
                onTap: () => Navigator.pushNamed(context, AppRoutes.inbox),
              ),
              const SizedBox(width: 8),
              _TopAction(
                icon: Icons.notifications_rounded,
                label: 'Notifikasi',
                badge: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hero Navy Card: Total Pendapatan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total pendapatan',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Admin cash-out 15%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.accentAmberGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.toll_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '420 TC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Setara Rp420.000 \u00B7 Siap dicairkan',
                  style: TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _WalletButton(
                        label: 'Cash-out',
                        icon: Icons.account_balance_wallet_rounded,
                        onTap: () {
                          if (onOpenWallet != null) {
                            onOpenWallet!();
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.mentorCashOut,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WalletButton(
                        label: 'Layanan Baru',
                        icon: Icons.add_circle_rounded,
                        quiet: true,
                        onTap: onOpenServices,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Featured Upgrade Banner
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.mentorFeaturedUpgrade),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSlate),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkSlate.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: Color(0xFFB45309),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hemat Rp63.000 saat cash-out',
                          style: TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Featured Mentor bebas admin dan tampil teratas',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondarySlate,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3 Metric Cards (Pajangan / Stat Display Seragam)
          const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.calendar_month_rounded,
                    value: '2',
                    label: 'Booking baru',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.rate_review_rounded,
                    value: '1',
                    label: 'Perlu dinilai',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.thumb_up_alt_rounded,
                    value: '2',
                    label: 'Minta rekomendasi',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Navigasi & Menu Aksi Kerja Mentor
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderSlate),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkSlate.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Navigasi Kerja Mentor',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildQuickNavButton(
                  icon: Icons.calendar_month_rounded,
                  title: 'Jadwal Booking & Evaluasi Sesi',
                  subtitle: '2 booking baru \u00B7 1 sesi perlu penilaian',
                  buttonLabel: 'Buka Jadwal',
                  onTap: onOpenBookings,
                ),
                const Divider(color: AppColors.borderSlate, height: 20),
                _buildQuickNavButton(
                  icon: Icons.thumb_up_alt_rounded,
                  title: 'Rekomendasi Kerja Mahasiswa',
                  subtitle: '2 mahasiswa meminta endorse untuk proyek UMKM',
                  buttonLabel: 'Kelola Endorse',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.mentorRecommendation,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Visual Collaboration Showcase Banner
          _buildVisualCollaborationBanner(context),

          const SizedBox(height: 24),

          // Section 1: Jadwal Hari Ini
          const Text(
            'Jadwal hari ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 12),

          // Schedule Card 1 (Hari ini 19.00 - Arya Pratama)
          _buildScheduleCard(
            context: context,
            dayLabel: 'Hari ini',
            timeLabel: '19.00',
            topic: 'Persiapan wawancara Flutter',
            studentName: 'Arya Pratama · UNESA',
            student: mentorStudentArya,
            onJoin: () {
              if (onOpenLiveSession != null) {
                onOpenLiveSession!();
              } else {
                Navigator.pushNamed(
                  context,
                  AppRoutes.mentorLiveMentoring,
                  arguments: MentorLiveMentoringArgs(
                    student: mentorStudentArya,
                    meetingUrl: 'https://meet.google.com/tsy-arya-019',
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),

          // Schedule Card 2 (Besok 20.00 - Dewi Lestari)
          _buildScheduleCard(
            context: context,
            dayLabel: 'Besok',
            timeLabel: '20.00',
            topic: 'Dasar BLoC & Cubit',
            studentName: 'Dewi Lestari · ITS',
            student: mentorStudentDewi,
            onJoin: () {
              Navigator.pushNamed(
                context,
                AppRoutes.mentorLiveMentoring,
                arguments: MentorLiveMentoringArgs(
                  student: mentorStudentDewi,
                  meetingUrl: 'https://meet.google.com/tsy-dewi-020',
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Section 2: UMKM butuh rekomendasimu
          const Text(
            'UMKM butuh rekomendasimu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 12),

          // UMKM Card 1: Kopi Tepi Kali
          _buildUmkmCard(
            context: context,
            name: 'Kopi Tepi Kali',
            projectDesc: 'Aplikasi Menu & Pre-order K...',
            onSelectStudent: () {
              Navigator.pushNamed(
                context,
                AppRoutes.mentorRecommendation,
                arguments: const MentorRecommendationArgs(
                  initialStudent: mentorStudentArya,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // UMKM Card 2: Batik Warisan Nusantara
          _buildUmkmCard(
            context: context,
            name: 'Batik Warisan Nusantara',
            projectDesc: 'Landing Page Pemesanan B...',
            onSelectStudent: () {
              Navigator.pushNamed(
                context,
                AppRoutes.mentorRecommendation,
                arguments: const MentorRecommendationArgs(
                  initialStudent: mentorStudentDewi,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Section 3: Panduan & Wawasan Mentor TalentSync
          _buildMentorGuideSection(),
        ],
      ),
    );
  }

  Widget _buildVisualCollaborationBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primaryNavy,
                child: const Center(
                  child: Icon(
                    Icons.groups_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              color: Color(0xFF38BDF8),
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Ruang Sesi Virtual',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Sesi Hari Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bimbingan 1-on-1 & Code Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Bimbing mahasiswa menuntaskan proyek nyata UMKM secara interaktif.',
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onOpenLiveSession,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmberGold,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentAmberGold.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Mulai',
                                style: TextStyle(
                                  color: AppColors.darkSlate,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.darkSlate,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryNavy, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard({
    required BuildContext context,
    required String dayLabel,
    required String timeLabel,
    required String topic,
    required String studentName,
    required MentorStudent student,
    required VoidCallback onJoin,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel,
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkSlate,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primaryNavy,
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName.substring(0, 1)
                                : 'M',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            studentName,
                            style: const TextStyle(
                              color: AppColors.secondarySlate,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.mentorStudentChat,
                    arguments: student,
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColors.darkSlate,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onJoin,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Join Virtual Workspace (GMeet)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUmkmCard({
    required BuildContext context,
    required String name,
    required String projectDesc,
    required VoidCallback onSelectStudent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFFB45309),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  projectDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSelectStudent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pilih murid',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorGuideSection() {
    const mentorArticles = [
      InAppArticle(
        id: 'mentor_guide_qa_standard',
        title: 'Pedoman Objektif Evaluasi Murid & Penerbitan Badge Rekomendasi (Skor >= 80)',
        subtitle: 'Standar baku penjaminan mutu: cara menguji tugas studi kasus dan memberikan feedback konstruktif.',
        category: 'Standar Mutu',
        readTime: '4 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=800&q=80',
        icon: Icons.fact_check_rounded,
        accentColor: AppColors.primaryNavy,
        keyPoints: [
          'Mentor adalah garda depan penjamin mutu (Quality Assurance) proyek UMKM.',
          'Komponen penilaian: Ketepatan Solusi (40%), Kerapian & Teknis (30%), Kedisiplinan Brief (30%).',
          'Skor minimal 80 untuk menerbitkan Badge Rekomendasi resmi ke profil mahasiswa.',
          'Jika skor < 80, berikan ulasan perbaikan konkret pada rubrik evaluasi.',
        ],
        fullContent: 'Peran utama Peer Mentor di TalentSync bukan sekadar mengajar teori, melainkan menjadi kurator kualitas yang memastikan mahasiswa siap diterjunkan ke proyek nyata UMKM.\\n\\nDalam Ruang Belajar, ujilah mahasiswa dengan simulasi tugas riil. Lakukan review menyeluruh terhadap kode program, desain, atau naskah yang dikerjakan. Berikan skor objektif pada form rekomendasi. Bila mahasiswa mencapai skor 80 ke atas, terbitkan Badge Rekomendasi Kerja yang otomatis terverifikasi di sistem.',
        proTip: 'Sertakan catatan personal keunggulan murid (misal: "Sangat teliti dalam arsitektur BLoC dan penanganan error state") agar UMKM semakin yakin saat merekrut mereka.',
      ),
      InAppArticle(
        id: 'mentor_guide_premium_cashout',
        title:
            'Keistimewaan Akun Premium Mentor: Bebas 0% Biaya Admin Cash-Out',
        subtitle: 'Maksimalkan pendapatan bimbinganmu dengan pencairan koin utuh dan sorotan profil prioritas.',
        category: 'Pendapatan & Karir',
        readTime: '3 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?auto=format&fit=crop&w=800&q=80',
        icon: Icons.workspace_premium_rounded,
        accentColor: Color(0xFFD97706),
        keyPoints: [
          'Akun Reguler: Potongan administrasi 10-15% saat mencairkan TimeCoin ke Rupiah.',
          'Akun Premium Mentor: 100% bebas biaya potongan admin (0% admin fee).',
          'Profil ber-badge emas dan diprioritaskan di hasil pencarian katalog mahasiswa.',
          'Mendapatkan akses dashboard analitik performa bimbingan dan rating murid.',
        ],
        fullContent: 'Sebagai Peer Mentor berdedikasi, kamu layak memperoleh imbalan terbaik atas waktu dan ilmu yang kamu bagikan. TalentSync menghadirkan tingkatan Akun Premium khusus mentor aktif.\\n\\nDengan akun Premium, seluruh TimeCoin yang kamu kumpulkan dari sesi konsultasi dan evaluasi dapat dicairkan langsung ke rekening bankmu secara utuh tanpa potongan biaya administrasi sepeser pun. Profilmu juga akan mendapatkan badge terverifikasi khusus yang menarik lebih banyak mahasiswa untuk memesan jadwal bimbinganmu.',
        proTip: 'Rutin buka slot jadwal di jam produktif mahasiswa (pukul 19.00 - 21.00 WIB) untuk memaksimalkan okupansi bimbingan harianmu.',
      ),
      InAppArticle(
        id: 'mentor_guide_interactive_mentoring',
        title:
            'Teknik Bimbingan Interaktif: Live Review & Ruang Belajar Efektif',
        subtitle: 'Cara memimpin sesi bimbingan 1-on-1 yang menarik dan solutif bagi mahasiswa pemula.',
        category: 'Metodologi',
        readTime: '3 mnt baca',
        imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=800&q=80',
        icon: Icons.video_camera_front_rounded,
        accentColor: Color(0xFF0D9488),
        keyPoints: [
          'Gunakan Google Meet terintegrasi untuk sesi konsultasi tatap muka dan screen share.',
          'Manfaatkan fitur Ruang Belajar untuk berbagi materi, tautan Figma, dan repositori Git.',
          'Fokus pada penyelesaian kendala teknis nyata (blocker-solving), bukan sekadar ceramah.',
          'Pantau progres belajar murid secara berkala lewat tab Murid Aktif di dashboard.',
        ],
        fullContent: 'Mahasiswa yang memesan sesi mentoring biasanya menghadapi kendala teknis spesifik yang menghambat mereka dalam mengerjakan proyek UMKM. Awali sesi dengan mendengarkan kendala utama mereka, lalu gunakan metode Live Screen Review untuk membedah akar permasalahan secara langsung.\\n\\nBimbing mahasiswa agar memahami alur logika perbaikan (mengapa bug terjadi dan bagaimana best practice mengatasinya), bukan sekadar mendiktekan jawaban. Pendekatan interaktif ini terbukti meningkatkan kepuasan murid hingga rating 4.9/5.0.',
        proTip: 'Luangkan 5 menit di akhir sesi untuk menyimpulkan action-items yang harus diselesaikan murid sebelum pengumpulan tugas berikutnya.',
      ),
    ];

    return const InAppGuideSection(
      padding: EdgeInsets.zero,
      title: 'Panduan & Wawasan Mentor',
      subtitle: 'Kiat membimbing, menguji tugas, dan meningkatkan kredibilitas di TalentSync',
      articles: mentorArticles,
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: IconButton(
            onPressed: onTap,
            tooltip: label,
            icon: Icon(icon, color: AppColors.darkSlate, size: 20),
          ),
        ),
        if (badge)
          const Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.accentAmberGold,
            ),
          ),
      ],
    ),
  );
}

class _WalletButton extends StatelessWidget {
  const _WalletButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.quiet = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: quiet ? Colors.white.withValues(alpha: .15) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: quiet ? Colors.white : AppColors.primaryNavy,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: quiet ? Colors.white : AppColors.primaryNavy,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderSlate),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryNavy, size: 22),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 28,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondarySlate,
              fontSize: 11,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
