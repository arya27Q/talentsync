import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isBookmarked = false;

  Widget _buildInfoBox({
    required String label,
    required Widget valueWidget,
    required String subtext,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.canvasWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            valueWidget,
            const SizedBox(height: 4),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightBlueSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkSlate,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Header Bar
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
                        const Expanded(
                          child: Text(
                            'Detail Proyek UMKM',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBookmarked = !_isBookmarked;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: Icon(
                              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              size: 20,
                              color: _isBookmarked ? AppColors.primaryNavy : AppColors.darkSlate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            size: 20,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 2. Verified Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryNavy,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Proyek Terverifikasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3. Main Project Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          // Business Info Row
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
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
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sambal Bu Rudi',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Klaster Kuliner · Rungkut',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                '3 hari tersisa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Project Title
                          const Text(
                            'Redesain Kemasan & Katalog Online',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Division Info
                          const Row(
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 16,
                                color: AppColors.secondarySlate,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Divisi Branding & Pemasaran',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 3 Info Boxes
                          Row(
                            children: [
                              _buildInfoBox(
                                label: 'Imbalan',
                                valueWidget: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.toll_rounded,
                                      color: AppColors.accentAmberGold,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '300 TC',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                  ],
                                ),
                                subtext: 'Rp300.000 escrow',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoBox(
                                label: 'Durasi',
                                valueWidget: const Text(
                                  '2 Minggu',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                subtext: '3 milestone',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoBox(
                                label: 'Metode',
                                valueWidget: const Text(
                                  'Hybrid',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                subtext: '1x pertemuan',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. Section: Keahlian dibutuhkan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keahlian dibutuhkan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildSkillTag('UI/UX Design'),
                              _buildSkillTag('Figma'),
                              _buildSkillTag('Packaging'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.school_outlined, size: 14, color: AppColors.darkSlate),
                                SizedBox(width: 6),
                                Text(
                                  'Konversi 2 SKS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Section: Ringkasan proyek
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan proyek',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Merancang ulang label kemasan sambal botol dan membuat katalog online sederhana yang bisa memamerkan produk UMKM secara profesional di platform digital.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondarySlate,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildChecklistItem('Label kemasan 4 varian rasa siap cetak'),
                          _buildChecklistItem('Template feed Instagram untuk peluncuran'),
                          _buildChecklistItem('File master Figma & aset resolusi tinggi'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Action Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Chat UMKM Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.workspaceChat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: AppColors.darkSlate,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chat UMKM',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Primary CTA: Lamar Proyek Ini
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.applyProject);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(14),
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
                                'Lamar Proyek Ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
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
            ),
          ],
        ),
      ),
    );
  }
}
