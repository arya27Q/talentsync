import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class CaseStudyScreen extends StatelessWidget {
  const CaseStudyScreen({super.key});

  Widget _buildSkillTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightBlueSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }

  Widget _buildMetric(
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.canvasWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryNavy, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavFloating(BuildContext context) {
    return Positioned(
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
                  Icons.explore_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.submission),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.assignment_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.wallet),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.portfolio),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const Text(
                        'Case Study',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mengunduh Case Study PDF...'),
                              backgroundColor: AppColors.darkSlate,
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: AppColors.darkSlate,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Top Case Study Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkSlate.withValues(alpha: 0.03),
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
                            _buildSkillTag('Laravel'),
                            const SizedBox(width: 8),
                            _buildSkillTag('MySQL'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Sistem reservasi meja',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'untuk Warung Pak Gito',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _buildMetric(
                              Icons.access_time_rounded,
                              AppColors.primaryNavy,
                              'Duration',
                              '3 minggu',
                            ),
                            const SizedBox(width: 10),
                            _buildMetric(
                              Icons.star_rounded,
                              AppColors.accentAmberGold,
                              'Rating',
                              '5.0',
                            ),
                            const SizedBox(width: 10),
                            _buildMetric(
                              Icons.toll_rounded,
                              AppColors.accentAmberGold,
                              'Imbalan',
                              '80 TC',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Problem Section
                  _buildSectionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Problem',
                    description: 'Warung Pak Gito masih mencatat pesanan secara manual di buku, sehingga sering terjadi pesanan ganda saat jam ramai.',
                  ),

                  // Solution Section
                  _buildSectionCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Solution',
                    description: 'Membangun sistem reservasi sederhana dengan konfirmasi otomatis dan tampilan meja kosong secara real-time untuk kasir.',
                  ),

                  // Result Section
                  _buildSectionCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Hasil',
                    description: 'Waktu tunggu pesanan berkurang hingga 45%, tidak ada lagi pesanan ganda yang terlewat, dan kepuasan pelanggan warung naik menjadi 5.0 bintang.',
                  ),

                  // Testimonial Card (Pak Gito) — From User Screenshot
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
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
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9A4B1A),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'PG',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Pak Gito',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pemilik usaha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: AppColors.accentAmberGold,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '5.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '"Arya cepat paham kebutuhan warung kecil seperti kami. Sistemnya mudah dipakai karyawan."',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkSlate,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Floating Navigation
          _buildBottomNavFloating(context),
        ],
      ),
    );
  }
}
