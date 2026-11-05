import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class MsmeCreateTaskWizardScreen extends StatefulWidget {
  const MsmeCreateTaskWizardScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<MsmeCreateTaskWizardScreen> createState() =>
      _MsmeCreateTaskWizardScreenState();
}

class _MsmeCreateTaskWizardScreenState
    extends State<MsmeCreateTaskWizardScreen> {
  int _selectedTemplateIndex = 1; // Default to Setup Media Sosial (Populer)
  String? _customProjectTitle;
  String? _customProjectCategory;
  String? _customProjectPrice;
  String? _customProjectDesc;

  void _showCustomProjectDialog() {
    final titleController = TextEditingController(
      text: _customProjectTitle ?? '',
    );
    final priceController = TextEditingController(
      text: _customProjectPrice ?? '100',
    );
    final descController = TextEditingController(
      text: _customProjectDesc ?? '',
    );
    String selectedCategory = _customProjectCategory ?? 'Lainnya';

    final categories = [
      'Desain & Grafis',
      'Video & Media',
      'Web & Aplikasi',
      'Penulisan & Konten',
      'Administrasi & Data',
      'Pemasaran Digital',
      'Lainnya',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSlate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: AppColors.primaryNavy,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Buat Proyek Kustom UMKM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tentukan detail kebutuhan pekerjaan dan alokasi imbalan TimeCoin yang sesuai untuk usahamu.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // Judul Proyek
                const Text(
                  'Nama / Judul Kebutuhan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Video Reels Menu Resto',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondarySlate,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Kategori
                const Text(
                  'Kategori Bidang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSel = selectedCategory == cat;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedCategory = cat;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primaryNavy
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppColors.darkSlate,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Anggaran TC
                const Text(
                  'Alokasi Imbalan TimeCoin (TC)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 120',
                    suffixText:
                        'TC (~Rp${(int.tryParse(priceController.text) ?? 100) * 1000})',
                    suffixStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                  ),
                  onChanged: (_) => setModalState(() {}),
                ),
                const SizedBox(height: 14),

                // Deskripsi Singkat
                const Text(
                  'Deskripsi Singkat / Kebutuhan Utama',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Tulis ringkasan hasil yang diharapkan dari mahasiswa...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondarySlate,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Silakan masukkan nama/judul proyek kustom.',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _customProjectTitle = title;
                        _customProjectCategory = selectedCategory;
                        _customProjectPrice =
                            priceController.text.trim().isEmpty
                            ? '100'
                            : priceController.text.trim();
                        _customProjectDesc = descController.text.trim();
                        _selectedTemplateIndex =
                            _templates.length - 1; // custom index
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Gunakan Proyek Kustom Ini',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final List<_TemplateItem> _templates = const [
    _TemplateItem(
      title: 'Desain Logo',
      subtitle: 'Logo dan panduan warna',
      price: '80–150 TC',
      icon: Icons.draw_rounded,
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
      icon: Icons.camera_alt_rounded,
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
    _TemplateItem(
      title: 'Kebutuhan Kustom',
      subtitle: 'Tentukan judul, tugas, & imbalan sendiri',
      price: 'Bebas / Fleksibel',
      icon: Icons.tune_rounded,
      isCustom: true,
    ),
  ];

  void _onNext() {
    final selected = _templates[_selectedTemplateIndex];
    final String chosenTitle = selected.isCustom && _customProjectTitle != null
        ? _customProjectTitle!
        : selected.title;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Proyek "$chosenTitle" dipilih. Melanjutkan ke detail tugas...',
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
                      border: Border.all(color: const Color(0xFFFDE68A)),
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
                                content: Text(
                                  'Buka halaman Upgrade Slot proyek.',
                                ),
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
                          if (item.isCustom) {
                            _showCustomProjectDialog();
                          }
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
                                    : const Color(0xFF0F172A)
                                          .withValues(alpha: 0.03),
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
                                    item.isCustom && _customProjectTitle != null
                                        ? _customProjectTitle!
                                        : item.title,
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
                                    item.isCustom &&
                                            _customProjectCategory != null
                                        ? 'Kategori: $_customProjectCategory'
                                        : item.subtitle,
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
                                    item.isCustom && _customProjectPrice != null
                                        ? '$_customProjectPrice TC'
                                        : item.price,
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

                  const SizedBox(height: 18),

                  // Callout Banner: "Tidak menemukan yang sesuai?"
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.primaryNavy,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tidak menemukan kebutuhan usahamu?',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kamu bisa membuat proyek kustom dengan menentukan nama pekerjaan, bidang keahlian, dan anggaran imbalan TimeCoin sendiri.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTemplateIndex = _templates.length - 1;
                            });
                            _showCustomProjectDialog();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryNavy),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 16,
                                  color: AppColors.primaryNavy,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tulis Proyek Kustom Sendiri',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
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
    this.isCustom = false,
  });

  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final bool isPopular;
  final bool isCustom;
}
