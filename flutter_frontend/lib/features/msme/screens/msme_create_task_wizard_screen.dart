import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class MsmeCreateTaskWizardScreen extends StatefulWidget {
  const MsmeCreateTaskWizardScreen({
    super.key,
    this.onCompleted,
  });

  final VoidCallback? onCompleted;

  @override
  State<MsmeCreateTaskWizardScreen> createState() =>
      _MsmeCreateTaskWizardScreenState();
}

class _MsmeCreateTaskWizardScreenState extends State<MsmeCreateTaskWizardScreen> {
  int _selectedTemplateIndex = 1; // Default to Setup Media Sosial (Populer)

  final List<_TemplateItem> _templates = const [
    _TemplateItem(
      title: 'Desain Logo',
      subtitle: 'Logo dan panduan warna',
      price: '80–150 TC',
      icon: Icons.draw_outlined,
    ),
    _TemplateItem(
      title: 'Setup Media Sosial',
      subtitle: 'Feed, bio, dan template',
      price: '60–120 TC',
      icon: Icons.tag_rounded,
      isPopular: true,
    ),
    _TemplateItem(
      title: 'Foto Produk',
      subtitle: 'Foto katalog siap jual',
      price: '40–90 TC',
      icon: Icons.camera_alt_outlined,
    ),
    _TemplateItem(
      title: 'Landing Page',
      subtitle: 'Halaman pemesanan online',
      price: '150–300 TC',
      icon: Icons.language_rounded,
    ),
    _TemplateItem(
      title: 'Aplikasi Mobile',
      subtitle: 'Kasir, menu, atau pre-order',
      price: '250–450 TC',
      icon: Icons.smartphone_rounded,
    ),
    _TemplateItem(
      title: 'Dashboard Data',
      subtitle: 'Laporan penjualan rapi',
      price: '100–200 TC',
      icon: Icons.bar_chart_rounded,
    ),
  ];

  void _onNext() {
    final selected = _templates[_selectedTemplateIndex];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Template "${selected.title}" dipilih. Melanjutkan ke detail tugas...',
        ),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: 'Kembali',
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: AppColors.darkSlate,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Task Wizard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Langkah 1 dari 3 · Pilih template',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondarySlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3-Segment Step Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih kebutuhan usahamu. Detail, deliverable, dan kisaran imbalan sudah kami siapkan.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.secondarySlate,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Slot warning banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFB45309),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Slot proyek aktif 2/2',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Buka halaman Upgrade Slot proyek.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text(
                            'Tambah slot',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2-Column Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _templates.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.88,
                        ),
                    itemBuilder: (context, index) {
                      final item = _templates[index];
                      final bool isSelected = _selectedTemplateIndex == index;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTemplateIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : AppColors.borderSlate,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.primaryNavy.withValues(
                                        alpha: 0.1,
                                      )
                                    : const Color(0xFF0F172A).withValues(
                                        alpha: 0.03,
                                      ),
                                blurRadius: isSelected ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Squircle Icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.lightBlueSurface,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primaryNavy,
                                      size: 22,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.secondarySlate,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.price,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                ],
                              ),

                              // Optional "Populer" badge
                              if (item.isPopular)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Populer',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action: "Lanjut ➔"
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                  onTap: _onNext,
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lanjut',
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

class _TemplateItem {
  const _TemplateItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    this.isPopular = false,
  });

  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final bool isPopular;
}

