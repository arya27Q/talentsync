import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
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
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Pesan',
                onTap: () => Navigator.pushNamed(context, AppRoutes.inbox),
              ),
              const SizedBox(width: 8),
              _TopAction(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi',
                badge: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                const Text(
                  'Rp420.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.toll_rounded,
                      size: 15,
                      color: AppColors.accentAmberGold,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '420 TC siap ditukar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _WalletButton(
                        label: 'Cash-out',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () {
                          if (onOpenWallet != null) {
                            onOpenWallet!();
                          } else {
                            Navigator.pushNamed(context, AppRoutes.mentorCashOut);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WalletButton(
                        label: 'Layanan Baru',
                        icon: Icons.add_circle_outline_rounded,
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.mentorFeaturedUpgrade),
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

          // 3 Metric Cards
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpenBookings,
                  child: const _MetricCard(
                    icon: Icons.calendar_month_outlined,
                    value: '2',
                    label: 'Booking baru',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onOpenBookings,
                  child: const _MetricCard(
                    icon: Icons.rate_review_outlined,
                    value: '1',
                    label: 'Perlu dinilai',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.mentorRecommendation),
                  child: const _MetricCard(
                    icon: Icons.thumb_up_alt_outlined,
                    value: '2',
                    label: 'Minta rekomendasi',
                  ),
                ),
              ),
            ],
          ),
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
                arguments: const MentorRecommendationArgs(initialStudent: mentorStudentArya),
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
                arguments: const MentorRecommendationArgs(initialStudent: mentorStudentDewi),
              );
            },
          ),
        ],
      ),
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
                    const SizedBox(height: 4),
                    Text(
                      studentName,
                      style: const TextStyle(
                        color: AppColors.secondarySlate,
                        fontSize: 12,
                      ),
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
                    Icons.chat_bubble_outline_rounded,
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
                  Icon(
                    Icons.videocam_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
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
              Icons.storefront_outlined,
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
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
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
      ],
    ),
  );
}
