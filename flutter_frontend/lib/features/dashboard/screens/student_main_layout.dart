import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/widgets/gradient_background.dart';
import 'package:skillswap_frontend/features/dashboard/screens/dashboard_mahasiswa_screen.dart';
import 'package:skillswap_frontend/features/project/screens/explore_projects_screen.dart';
import 'package:skillswap_frontend/features/wallet/screens/wallet_dashboard_screen.dart';
import 'package:skillswap_frontend/features/mentoring/screens/find_mentors_screen.dart';
import 'package:skillswap_frontend/features/profile/screens/student_settings_screen.dart';

class StudentMainLayout extends StatefulWidget {
  const StudentMainLayout({super.key});

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardMahasiswaScreen(),
    const ExploreProjectsScreen(),
    const FindMentorsScreen(),
    const WalletDashboardScreen(),
    const StudentSettingsScreen(),
  ];

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFB88656) : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFFB88656) : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: GradientBackground(
        child: Stack(
        children: [
          // The current screen
          _screens[_currentIndex],
          
          // Floating Capsule Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Explore', 0),
                  _buildNavItem(Icons.work_outline_rounded, 'My Tasks', 1),
                  _buildNavItem(Icons.people_outline_rounded, 'Mentors', 2),
                  _buildNavItem(Icons.account_balance_wallet_outlined, 'Wallet', 3),
                  _buildNavItem(Icons.person_outline_rounded, 'Profile', 4),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
