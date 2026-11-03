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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _openPortal(context),
              child: const Text('Lewati'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MentorPathCard(),
                  const SizedBox(height: 30),
                  Text(
                    'Ubah keahlianmu jadi Rupiah.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Mahasiswa membayar sesi dengan TimeCoin. Kamu mengajar, memberi materi, dan merekomendasikan talenta terbaik ke UMKM.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondarySlate,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => _openPortal(context),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Mulai Sekarang'),
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
      Icons.storefront_outlined,
      'Buka layanan mentoring',
      'Atur topik, durasi, dan harga TC',
    ),
    (
      Icons.event_available_outlined,
      'Terima booking & GMeet',
      'Jadwal fleksibel, tautan otomatis',
    ),
    (
      Icons.menu_book_outlined,
      'Ajar, beri materi & tugas',
      'Langsung masuk ruang belajar murid',
    ),
    (
      Icons.thumb_up_alt_outlined,
      'Rekomendasikan murid ke UMKM',
      'Bantu murid terbaik dapat proyek nyata',
    ),
    (
      Icons.payments_outlined,
      'Tukar TimeCoin jadi Rupiah',
      'Cash-out ke rekening kapan saja',
    ),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rata-rata pendapatan mentor aktif',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 6),
              Text(
                'Rp1,2 jt/bln',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: last ? const Color(0xFFFFF6E8) : AppColors.lightBlueSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: last ? AppColors.accentAmberDeep : AppColors.primaryNavy,
            size: 22,
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
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
