import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class ApplyProjectScreen extends StatefulWidget {
  const ApplyProjectScreen({super.key});

  @override
  State<ApplyProjectScreen> createState() => _ApplyProjectScreenState();
}

class _ApplyProjectScreenState extends State<ApplyProjectScreen> {
  final TextEditingController _coverLetterController = TextEditingController(
    text: 'Yth. Sambal Bu Rudi, perkenalkan saya mahasiswa Sistem Informasi dengan pengalaman relevan dalam perancangan desain kemasan dan branding digital...',
  );

  int _selectedPortfolioIndex = 0; // 0 for item 1, 1 for item 2

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 32),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Lamaran Terkirim!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkSlate),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lamaran Anda telah diteruskan ke Sambal Bu Rudi. Silakan pantau status seleksi di My Tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondarySlate, height: 1.4),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.studentDashboard, (route) => false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Buka Dashboard',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSelectItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedPortfolioIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPortfolioIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.task_alt_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primaryNavy : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Bar
                    Row(
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
                                size: 24,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Kirim Lamaran Proyek',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Card 1: Target Project Summary Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 16,
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
                                  color: AppColors.lightBlueSurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Row(
                                children: [
                                  Text(
                                    'Sambal Bu R...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.verified_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 15,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Terverifikasi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.toll_rounded,
                                      color: AppColors.accentAmberGold,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '300 TC',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Redesain Kemasan & Katalog Online',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.secondarySlate,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '2 Minggu kerja',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.secondarySlate,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Smart Escrow aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Card 2: Cover Letter Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Pesan lamaran singkat ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlueSurface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Wajib formal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.canvasWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: TextField(
                              controller: _coverLetterController,
                              maxLines: 5,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkSlate,
                                height: 1.4,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppColors.secondarySlate,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Gunakan bahasa Indonesia yang formal dan sopan agar peluang diterima lebih tinggi.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '0/500',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Card 3: Portofolio terverifikasi
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Portofolio terverifikasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Color(0xFFB45309),
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Terverifikasi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pilih karya yang ingin dilampirkan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildPortfolioSelectItem(
                            index: 0,
                            title: 'Sistem reservasi meja',
                            subtitle: 'Warung Pak Gito · Rating 5.0',
                          ),
                          _buildPortfolioSelectItem(
                            index: 1,
                            title: 'Katalog digital produk',
                            subtitle: 'Kerajinan Anyam Ayu · Rating 4.8',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: Kirim Lamaran (300 TC)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28, top: 12),
              child: GestureDetector(
                onTap: _submitApplication,
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
                        'Kirim Lamaran (300 TC)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 16,
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

