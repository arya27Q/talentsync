import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class LogBimbinganScreen extends StatelessWidget {
  const LogBimbinganScreen({super.key});

  Widget _buildNavIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSlate.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.keyboard_arrow_left_rounded,
                                color: AppColors.darkSlate,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Log Bimbingan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Timeline List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Card 1: Review Studi Kasus (Dimas Prasetyo)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      color: const Color(0xFFEFF6FF),
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => const Center(
                                          child: Text('DP', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Dimas Prasetyo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                                        SizedBox(height: 2),
                                        Text('8 Jun 2025', style: TextStyle(fontSize: 11, color: AppColors.secondarySlate)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.check_rounded, size: 12, color: Color(0xFF16A34A)),
                                        SizedBox(width: 4),
                                        Text('Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Kurasi studi kasus portofolio tender',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkSlate),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Text(
                                  'Catatan mentor: Tambahkan metrik hasil di setiap studi kasus dan perjelas peranmu.',
                                  style: TextStyle(fontSize: 12, color: AppColors.secondarySlate, height: 1.4),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondarySlate),
                                  const SizedBox(width: 4),
                                  const Text('45 mnt', style: TextStyle(fontSize: 11, color: AppColors.secondarySlate)),
                                  const SizedBox(width: 14),
                                  const Icon(Icons.toll_rounded, size: 14, color: AppColors.accentAmberGold),
                                  const SizedBox(width: 4),
                                  const Text('25 TC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.mentoringResult),
                                    child: const Text(
                                      'Lihat hasil bimbingan >',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Card 2: Rizky Hidayat (Selesai)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(alpha: 0.04),
                                blurRadius: 14,
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
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6A1B9A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('RH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Rizky Hidayat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                                        SizedBox(height: 2),
                                        Text('20 Mei 2025', style: TextStyle(fontSize: 11, color: AppColors.secondarySlate)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.check_rounded, size: 12, color: Color(0xFF16A34A)),
                                        SizedBox(width: 4),
                                        Text('Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Desain database reservasi',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkSlate),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Text(
                                  'Catatan mentor: Gunakan indeks pada kolom tanggal dan status reservasi.',
                                  style: TextStyle(fontSize: 12, color: AppColors.secondarySlate, height: 1.4),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondarySlate),
                                  const SizedBox(width: 4),
                                  const Text('45 mnt', style: TextStyle(fontSize: 11, color: AppColors.secondarySlate)),
                                  const SizedBox(width: 14),
                                  const Icon(Icons.toll_rounded, size: 14, color: AppColors.accentAmberGold),
                                  const SizedBox(width: 4),
                                  const Text('35 TC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.mentoringResult),
                                    child: const Text(
                                      'Lihat hasil bimbingan >',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Card 3: Dimas Prasetyo (Terjadwal)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(alpha: 0.04),
                                blurRadius: 14,
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
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E3A8A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('DP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Dimas Prasetyo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                                        SizedBox(height: 2),
                                        Text('15 Jul 2025 · 19.00', style: TextStyle(fontSize: 11, color: AppColors.secondarySlate)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Terjadwal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Persiapan wawancara Flutter',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkSlate),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: const [
                                  Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondarySlate),
                                  SizedBox(width: 4),
                                  Text('45 mnt', style: TextStyle(fontSize: 11, color: AppColors.secondarySlate)),
                                  SizedBox(width: 14),
                                  Icon(Icons.toll_rounded, size: 14, color: AppColors.accentAmberGold),
                                  SizedBox(width: 4),
                                  Text('30 TC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkSlate)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, AppRoutes.mentoringSession),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                                      Text('Masuk Ruang Sesi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      SizedBox(width: 6),
                                      Icon(Icons.videocam_outlined, color: Colors.white, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Capsule Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _buildNavIcon(
                    icon: Icons.explore_outlined,
                    onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.studentDashboard, (route) => false),
                  ),
                  _buildNavIcon(
                    icon: Icons.assignment_outlined,
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.myProjects),
                  ),
                  _buildNavIcon(
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
                  ),
                  _buildNavIcon(
                    icon: Icons.person_outline_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
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

