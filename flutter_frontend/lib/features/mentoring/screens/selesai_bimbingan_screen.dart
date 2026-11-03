import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class SelesaiBimbinganScreen extends StatefulWidget {
  const SelesaiBimbinganScreen({super.key});

  @override
  State<SelesaiBimbinganScreen> createState() => _SelesaiBimbinganScreenState();
}

class _SelesaiBimbinganScreenState extends State<SelesaiBimbinganScreen> {
  int _starRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  final List<Map<String, dynamic>> _strengths = [
    {'label': 'Penjelasan sangat detail', 'selected': true},
    {'label': 'Feedback konstruktif', 'selected': true},
    {'label': 'Tepat waktu', 'selected': true},
    {'label': 'Action plan jelas', 'selected': false},
    {'label': 'Membantu pemula', 'selected': false},
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _confirmReleaseEscrow() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Escrow Berhasil Dilepas!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '30 TC telah ditransfer ke Dimas Prasetyo dan ulasanmu telah dipublikasikan. Portofolio kamu kini berstatus Terverifikasi Siap Tender!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.mentoringResult,
                );
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
                    'Lihat Lembar Evaluasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return 'Sangat memuaskan (5/5)';
      case 4:
        return 'Memuaskan (4/5)';
      case 3:
        return 'Cukup baik (3/5)';
      case 2:
        return 'Kurang memuaskan (2/5)';
      default:
        return 'Perlu perbaikan (1/5)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar: Back, Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
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
                                  color: AppColors.darkSlate.withValues(
                                    alpha: 0.05,
                                  ),
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
                          'Selesai Bimbingan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Status Row: Sesi selesai & Terverifikasi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                size: 7,
                                color: Color(0xFF16A34A),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sesi selesai · konfirmasi mahasiswa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: AppColors.primaryNavy,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Card 1: Mentor & Sesi Info (Figma 26)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.05),
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color(0xFFEFF6FF),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) =>
                                        const Center(
                                          child: Text(
                                            'DP',
                                            style: TextStyle(
                                              color: AppColors.primaryNavy,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                                      'Dimas Prasetyo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Senior Flutter Engineer · Fintech lokal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Mentor utama TalentSync',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Sesi Inner Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bimbingan 1-on-1: Kurasi portofolio tender UMKM',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 13,
                                      color: AppColors.secondarySlate,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Besok, 25 Jun',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: AppColors.secondarySlate,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '60 menit (Meet selesai)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. Card 2: Pelepasan Escrow (Figma 26)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: AppColors.secondarySlate,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'PELEPASAN ESCROW',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.toll_rounded,
                                  color: AppColors.accentAmberGold,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(color: AppColors.darkSlate),
                              children: [
                                TextSpan(
                                  text: '30 TC ',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'terkunci',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Dana diteruskan otomatis ke dompet Dimas Prasetyo setelah kamu mengirim konfirmasi pelepasan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Smart Escrow aman & terenkripsi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Card 3: Portofolio Terverifikasi Siap Digunakan (Figma 26)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFEF3C7)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFFD97706),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Portofolio terverifikasi siap digunakan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Skor evaluasi 88/100 tercatat di profil dan otomatis dilampirkan saat melamar proyek UMKM.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 6. Card 4: Evaluasi Kualitas Sesi (Figma 26 - Scrolled down)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Evaluasi kualitas sesi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ulasanmu membantu menjaga integritas komunitas belajar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Star Rating Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starNum = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _starRating = starNum;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 36,
                                    color: starNum <= _starRating
                                        ? AppColors.accentAmberGold
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 8),

                          // Rating Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              _getRatingText(_starRating),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Strengths Section
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Kelebihan mentor yang paling terasa',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Multi-select Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_strengths.length, (index) {
                              final item = _strengths[index];
                              final isSelected = item['selected'] as bool;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    item['selected'] = !isSelected;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_rounded
                                            : Icons.add_rounded,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.darkSlate,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item['label'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.darkSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // Review Textarea
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tulis ulasan untuk mentor',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              Text(
                                '${_reviewController.text.length}/300',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: TextField(
                              controller: _reviewController,
                              maxLines: 4,
                              maxLength: 300,
                              onChanged: (text) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkSlate,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Bagikan pengalaman bimbinganmu agar mahasiswa lain lebih mudah memilih mentor',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Ulasan publik tampil di profil bimbingan Dimas Prasetyo.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondarySlate,
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
          ),

          // Primary Sticky Bottom Bar (Figma 26)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkSlate.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _confirmReleaseEscrow,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Konfirmasi Selesai & Lepas Escrow (30 TC)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.help_outline_rounded,
                        size: 14,
                        color: AppColors.secondarySlate,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Butuh bantuan? Laporkan kendala sesi',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
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
