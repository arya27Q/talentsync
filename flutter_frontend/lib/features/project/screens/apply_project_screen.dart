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
  final TextEditingController _externalPortfolioController =
      TextEditingController();

  final Set<int> _selectedPortfolios = {0}; // multi-select or single select
  int _selectedTimelineIndex = 0; // 0: 2 Minggu, 1: Lebih cepat, 2: Fleksibel
  bool _isCommitted = true;

  String get _dedicationHours {
    switch (_selectedTimelineIndex) {
      case 0:
        return '10–15 jam / minggu';
      case 1:
        return '20–25 jam / minggu';
      case 2:
        return 'Fleksibel / Sesuai diskusi';
      default:
        return '10–15 jam / minggu';
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _externalPortfolioController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (!_isCommitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap centang persetujuan komitmen profesional terlebih dahulu.',
          ),
          backgroundColor: AppColors.darkSlate,
        ),
      );
      return;
    }

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
                child: Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A34A),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Lamaran Terkirim!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lamaran Anda telah diteruskan ke Sambal Bu Rudi. Silakan pantau status seleksi di My Tasks.',
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
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.studentDashboard,
                  (route) => false,
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
                    'Buka Dashboard',
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

  Widget _buildPortfolioSelectItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedPortfolios.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPortfolios.remove(index);
          } else {
            _selectedPortfolios.add(index);
          }
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
                  color: isSelected
                      ? AppColors.primaryNavy
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineOption({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedTimelineIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimelineIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryNavy
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.darkSlate,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.secondarySlate,
                  ),
                ),
              ),
            ],
          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
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
                          'Kirim Lamaran Proyek',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Card 1: Project Summary Card
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  color: AppColors.lightBlueSurface,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.storefront_rounded,
                                              size: 20,
                                              color: AppColors.primaryNavy,
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Sambal Bu R...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppColors.primaryNavy,
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                'Terverifikasi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
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
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Redesain Kemasan & Katalog Online',
                            style: TextStyle(
                              fontSize: 17,
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
                              SizedBox(width: 4),
                              Text(
                                '2 Minggu kerja',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                              SizedBox(width: 14),
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 4),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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

                          // Item 1
                          _buildPortfolioSelectItem(
                            index: 0,
                            title: 'Sistem reservasi meja',
                            subtitle: 'Warung Pak Gito · Rating 5.0',
                          ),

                          // Item 2
                          _buildPortfolioSelectItem(
                            index: 1,
                            title: 'Katalog digital produk',
                            subtitle: 'Kerajinan Anyam Ayu · Rating 4.8',
                          ),

                          // Item 3 (New from Screenshot)
                          _buildPortfolioSelectItem(
                            index: 2,
                            title: 'Landing page promo',
                            subtitle: 'Laundry Bersih · Rating 4.9',
                          ),

                          const SizedBox(height: 10),

                          // Link: Belum punya portofolio yang relevan? Cari Mentor ↗
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Belum punya portofolio yang relevan?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.findMentors,
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Cari Mentor',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.north_east_rounded,
                                      size: 13,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // External Portfolio Input (Tautan portofolio luar opsional)
                          const Row(
                            children: [
                              Icon(
                                Icons.link_rounded,
                                size: 16,
                                color: AppColors.darkSlate,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Tautan portofolio luar (opsional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.canvasWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: TextField(
                              controller: _externalPortfolioController,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkSlate,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'https://figma.com/@username',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondarySlate,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Card 4: Komitmen waktu pengerjaan (New from Screenshot)
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
                          const Text(
                            'Komitmen waktu pengerjaan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pilih kesiapan timeline kerjamu',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 3 Options Row
                          Row(
                            children: [
                              _buildTimelineOption(
                                index: 0,
                                title: '2 Minggu',
                                subtitle: 'Standar',
                              ),
                              const SizedBox(width: 8),
                              _buildTimelineOption(
                                index: 1,
                                title: 'Lebih cepat',
                                subtitle: 'Prioritas',
                              ),
                              const SizedBox(width: 8),
                              _buildTimelineOption(
                                index: 2,
                                title: 'Fleksibel',
                                subtitle: 'Diskusi',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Estimation Box
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 15,
                                  color: AppColors.secondarySlate,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Estimasi waktu didedikasikan ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondarySlate,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: _dedicationHours,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkSlate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Card 5: Smart Escrow proteksi (300 TC) Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 22,
                            color: AppColors.primaryNavy,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Escrow proteksi (300 TC)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Pencairan bertahap otomatis per milestone yang disetujui.',
                                  style: TextStyle(
                                    fontSize: 11,
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

                    const SizedBox(height: 14),

                    // Card 6: Commitment Agreement Checkbox Card
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCommitted = !_isCommitted;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkSlate.withValues(
                                alpha: 0.03,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _isCommitted
                                    ? AppColors.primaryNavy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isCommitted
                                      ? AppColors.primaryNavy
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: _isCommitted
                                  ? const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Saya berkomitmen menjaga komunikasi profesional dan tenggat waktu mitra.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkSlate,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: Kirim Lamaran (300 TC)
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 28,
                top: 12,
              ),
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
                      Icon(Icons.send_rounded, color: Colors.white, size: 16),
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
