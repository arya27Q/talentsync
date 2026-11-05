import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MentorOnboardingScreen extends StatelessWidget {
  const MentorOnboardingScreen({super.key});

  void _openPortal(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.mentorAuth);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _openPortal(context),
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'Lewati',
                  style: TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MentorPathCard(),
                  const SizedBox(height: 28),
                  const Text(
                    'Ubah keahlianmu jadi\nRupiah.',
                    style: TextStyle(
                      color: AppColors.darkSlate,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mahasiswa membayar sesi dengan TimeCoin. Kamu mengajar, memberi materi, dan merekomendasikan talenta terbaik ke UMKM.',
                    style: TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Container(
              width: double.infinity,
              height: 52,
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPortal(context),
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
            ),
          ),
        ],
      ),
    ),
  );
}

class _MentorPathCard extends StatelessWidget {
  const _MentorPathCard();

  static const _steps = [
    (
      Icons.storefront_rounded,
      'Buka layanan mentoring',
      'Atur topik, durasi, dan harga TC',
    ),
    (
      Icons.calendar_today_rounded,
      'Terima booking & GMeet',
      'Jadwal fleksibel, tautan otomatis',
    ),
    (
      Icons.menu_book_rounded,
      'Ajar, beri materi & tugas',
      'Langsung masuk ruang belajar murid',
    ),
    (
      Icons.thumb_up_alt_rounded,
      'Rekomendasikan murid ke UMKM',
      'Bantu murid terbaik dapat proyek nyata',
    ),
    (
      Icons.payments_rounded,
      'Tukar TimeCoin jadi Rupiah',
      'Cash-out ke rekening kapan saja',
    ),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.borderSlate.withValues(alpha: 0.8),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rata-rata pendapatan mentor aktif',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Rp1,2 jt/bln',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFF59E0B),
                size: 32,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < _steps.length; i++) ...[
          _PathStep(
            icon: _steps[i].$1,
            title: _steps[i].$2,
            subtitle: _steps[i].$3,
            last: i == _steps.length - 1,
          ),
        ],
      ],
    ),
  );
}

class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.last,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final isAmber = last;
    final bgColor = isAmber ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF);
    final iconColor = isAmber ? const Color(0xFFD97706) : AppColors.primaryNavy;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            if (!last)
              Container(
                width: 1.5,
                height: 16,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
