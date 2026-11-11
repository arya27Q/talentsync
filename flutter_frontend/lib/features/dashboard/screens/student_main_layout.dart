import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/dashboard/screens/dashboard_mahasiswa_screen.dart';
import 'package:flutter_frontend/features/portfolio/screens/portfolio_dashboard_screen.dart';
import 'package:flutter_frontend/features/project/screens/my_projects_screen.dart';
import 'package:flutter_frontend/features/wallet/screens/wallet_dashboard_screen.dart';

class StudentMainLayout extends StatefulWidget {
  final int initialIndex;
  const StudentMainLayout({super.key, this.initialIndex = 0});

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  late int _currentIndex;
  late final List<Widget?> _builtScreens;

  Widget _buildTab(int index) {
    return switch (index) {
      0 => const DashboardMahasiswaScreen(),
      1 => const MyProjectsScreen(),
      2 => const WalletDashboardScreen(),
      3 => const PortfolioDashboardScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _builtScreens = List<Widget?>.filled(4, null);
    _builtScreens[_currentIndex] = _buildTab(_currentIndex);
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      _builtScreens[index] ??= _buildTab(index);
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    return Expanded(
      flex: isActive ? 2 : 1,
      child: GestureDetector(
        onTap: () => _selectTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 10 : 4,
            vertical: 8,
          ),
          decoration: isActive
              ? BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          child: Center(
            child: isActive
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    color: AppColors.secondarySlate,
                    size: 22,
                  ),
          ),
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
          IndexedStack(
            index: _currentIndex,
            children: List<Widget>.generate(
              _builtScreens.length,
              (i) => _builtScreens[i] ?? const SizedBox.shrink(),
            ),
          ),

          // Floating Pill Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                children: [
                  _buildNavItem(
                    icon: Icons.explore_rounded,
                    label: 'Eksplorasi',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.assignment_rounded,
                    label: 'Tugas Saya',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Dompet',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profil',
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
