import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _selectedRoleIndex = 0; // 0: Mahasiswa, 1: UMKM, 2: Mentor

  void _onProceed() {
    switch (_selectedRoleIndex) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.studentOnboarding);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.msmeAuth);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.mentorAuth);
        break;
    }
  }

  Widget _buildRoleCard({
    required int index,
    required String title,
    required String roleTag,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRoleIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoleIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryNavy.withValues(alpha: 0.08)
                  : AppColors.darkSlate.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Squircle Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy : AppColors.lightBlueSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected ? Colors.white : AppColors.primaryNavy,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                      children: [
                        TextSpan(
                          text: ' · $roleTag',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Radio Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryNavy : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryNavy : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Top Sync Icon Button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title & Subtitle
                    const Text(
                      'Selamat datang di\nTalentSync',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih peranmu untuk memulai. Kamu bisa mengubahnya nanti.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondarySlate,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3 Role Cards
                    _buildRoleCard(
                      index: 0,
                      title: 'Mahasiswa',
                      roleTag: 'Student',
                      subtitle: 'Kerjakan proyek UMKM, kumpulkan TimeCoin, dan bangun portofolio.',
                      icon: Icons.school_rounded,
                    ),
                    _buildRoleCard(
                      index: 1,
                      title: 'Mitra UMKM',
                      roleTag: 'Business',
                      subtitle: 'Posting kebutuhan proyek dan temukan talenta mahasiswa terverifikasi.',
                      icon: Icons.storefront_rounded,
                    ),
                    _buildRoleCard(
                      index: 2,
                      title: 'Mentor',
                      roleTag: 'Professional',
                      subtitle: 'Buka sesi bimbingan berbayar TC dan beri rekomendasi kerja.',
                      icon: Icons.work_outline_rounded,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28, top: 12),
              child: GestureDetector(
                onTap: _onProceed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjutkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
