import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class CertificateItem {
  final String title;
  final String issuer;
  final String category;
  final String date;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color badgeBg;
  final Color badgeTextColor;
  final bool isLocked;
  final String? lockSubtitle;

  CertificateItem({
    required this.title,
    required this.issuer,
    required this.category,
    required this.date,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBg,
    required this.badgeTextColor,
    this.isLocked = false,
    this.lockSubtitle,
  });
}

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CertificateItem> certificates = [
      CertificateItem(
        title: 'Penyelesaian Proyek: Sistem Reservasi Meja',
        issuer: 'Warung Pak Gito via TalentSync',
        category: 'Proyek UMKM',
        date: '2 Jun 2025',
        icon: Icons.storefront_outlined,
        iconBg: AppColors.lightBlueSurface,
        iconColor: AppColors.primaryNavy,
        badgeBg: const Color(0xFFEFF6FF),
        badgeTextColor: AppColors.primaryNavy,
      ),
      CertificateItem(
        title: 'Rekomendasi Kerja: Flutter Developer',
        issuer: 'Dimas Prasetyo, Mentor',
        category: 'Endorse Mentor',
        date: '8 Jul 2025',
        icon: Icons.military_tech_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFB45309),
        badgeBg: const Color(0xFFEEF2FF),
        badgeTextColor: const Color(0xFF4338CA),
      ),
      CertificateItem(
        title: 'Penyelesaian Proyek: Katalog Digital',
        issuer: 'Kerajinan Anyam Ayu via TalentSync',
        category: 'Proyek UMKM',
        date: '18 Mei 2025',
        icon: Icons.storefront_outlined,
        iconBg: AppColors.lightBlueSurface,
        iconColor: AppColors.primaryNavy,
        badgeBg: const Color(0xFFEFF6FF),
        badgeTextColor: AppColors.primaryNavy,
      ),
      CertificateItem(
        title: 'Sertifikat Mentor TalentSync',
        issuer: '',
        category: '',
        date: '',
        icon: Icons.lock_outline_rounded,
        iconBg: AppColors.canvasWhite,
        iconColor: AppColors.secondarySlate,
        badgeBg: Colors.transparent,
        badgeTextColor: Colors.transparent,
        isLocked: true,
        lockSubtitle: 'Terbuka setelah 5 proyek selesai · 4/5',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: AppColors.darkSlate,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Sertifikat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Diterbitkan dan diverifikasi TalentSync',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // List of Certificate Cards
                  ...certificates.map((cert) {
                    if (cert.isLocked) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.borderSlate,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.canvasWhite,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                cert.icon,
                                color: cert.iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cert.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    cert.lockSubtitle ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.caseStudy);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSlate),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkSlate.withValues(
                                alpha: 0.03,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: cert.iconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                cert.icon,
                                color: cert.iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cert.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    cert.issuer,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cert.badgeBg,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          cert.category,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: cert.badgeTextColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 11,
                                            color: AppColors.secondarySlate,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            cert.date,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.secondarySlate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Floating Navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkSlate.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.studentDashboard,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.explore_outlined,
                        color: AppColors.secondarySlate,
                        size: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.submission,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.assignment_outlined,
                        color: AppColors.secondarySlate,
                        size: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.wallet,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.secondarySlate,
                        size: 24,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
