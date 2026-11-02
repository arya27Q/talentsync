import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/dashboard/screens/dashboard_mahasiswa_screen.dart';
import 'package:flutter_frontend/features/project/screens/my_projects_screen.dart';
import 'package:flutter_frontend/features/wallet/screens/wallet_dashboard_screen.dart';
import 'package:flutter_frontend/features/profile/screens/student_settings_screen.dart';

class StudentMainLayout extends StatefulWidget {
  const StudentMainLayout({super.key});

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardMahasiswaScreen(),
    const MyProjectsScreen(),
    const WalletDashboardScreen(),
    const StudentSettingsScreen(),
  ];

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: Icon(
          icon,
          color: AppColors.secondarySlate,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          // Current Screen
          _screens[_currentIndex],

          // Floating Pill Bottom Navigation Bar
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
                    color: AppColors.darkSlate.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.explore_rounded,
                    label: 'Explore',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.assignment_outlined,
                    label: 'Tasks',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    index: 3,
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
