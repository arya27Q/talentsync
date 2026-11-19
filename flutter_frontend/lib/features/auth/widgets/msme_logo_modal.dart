import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';

/// Definisi preset avatar logo UMKM
class MsmeAvatarPreset {
  const MsmeAvatarPreset({
    required this.id,
    required this.title,
    required this.icon,
    required this.primaryColor,
    required this.bgColor,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color bgColor;
}

class MsmeLogoHelper {
  static const List<MsmeAvatarPreset> presets = [
    MsmeAvatarPreset(
      id: 'avatar:coffee',
      title: 'Kopi & Kafe',
      icon: Icons.coffee_rounded,
      primaryColor: Color(0xFF6D4C41),
      bgColor: Color(0xFFEFEBE9),
    ),
    MsmeAvatarPreset(
      id: 'avatar:food',
      title: 'Kuliner & Resto',
      icon: Icons.restaurant_rounded,
      primaryColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFF7ED),
    ),
    MsmeAvatarPreset(
      id: 'avatar:fashion',
      title: 'Fesyen & Butik',
      icon: Icons.checkroom_rounded,
      primaryColor: Color(0xFF4F46E5),
      bgColor: Color(0xFFEEF2FF),
    ),
    MsmeAvatarPreset(
      id: 'avatar:craft',
      title: 'Kriya & Seni',
      icon: Icons.palette_rounded,
      primaryColor: Color(0xFFE11D48),
      bgColor: Color(0xFFFFF1F2),
    ),
    MsmeAvatarPreset(
      id: 'avatar:retail',
      title: 'Ritel & Toko',
      icon: Icons.storefront_rounded,
      primaryColor: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    MsmeAvatarPreset(
      id: 'avatar:service',
      title: 'Jasa & Digital',
      icon: Icons.devices_rounded,
      primaryColor: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
    ),
    MsmeAvatarPreset(
      id: 'avatar:bakery',
      title: 'Roti & Bakery',
      icon: Icons.bakery_dining_rounded,
      primaryColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    MsmeAvatarPreset(
      id: 'avatar:agro',
      title: 'Agro & Organik',
      icon: Icons.eco_rounded,
      primaryColor: Color(0xFF16A34A),
      bgColor: Color(0xFFF0FDF4),
    ),
  ];

  static MsmeAvatarPreset? getPreset(String? id) {
    if (id == null) return null;
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Render avatar logo UMKM secara seragam
  static Widget buildLogoWidget({
    String? logoUrl,
    Uint8List? logoBytes,
    double size = 56,
    double borderRadius = 16,
  }) {
    if (logoBytes != null && logoBytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          logoBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (logoUrl != null && logoUrl.startsWith('avatar:')) {
      final preset = getPreset(logoUrl);
      if (preset != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: preset.bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: preset.primaryColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              preset.icon,
              size: size * 0.52,
              color: preset.primaryColor,
            ),
          ),
        );
      }
    }

    if (logoUrl != null &&
        (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _defaultPlaceholder(size, borderRadius),
        ),
      );
    }

    return _defaultPlaceholder(size, borderRadius);
  }

  static Widget _defaultPlaceholder(double size, double borderRadius) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Icon(
          Icons.add_photo_alternate_rounded,
          size: size * 0.5,
          color: AppColors.secondarySlate,
        ),
      );
}

/// Hasil pemilihan logo dari modal
class MsmeLogoSelectionResult {
  const MsmeLogoSelectionResult({
    this.pickedBytes,
    this.fileName,
    this.presetAvatarId,
    this.isCleared = false,
  });

  final Uint8List? pickedBytes;
  final String? fileName;
  final String? presetAvatarId;
  final bool isCleared;

  bool get hasSelection =>
      isCleared || (pickedBytes != null) || (presetAvatarId != null);
}

/// Modal Sheet Pilihan Logo Toko UMKM:
/// 1. Unggah dari Galeri + Penyesuaian/Crop Frame
/// 2. Pilihan Avatar Toko Tematik Siap Pakai
class MsmeLogoPickerSheet extends StatefulWidget {
  const MsmeLogoPickerSheet({
    super.key,
    this.currentPresetId,
    this.hasExistingPhoto = false,
  });

  final String? currentPresetId;
  final bool hasExistingPhoto;

  static Future<MsmeLogoSelectionResult?> show(
    BuildContext context, {
    String? currentPresetId,
    bool hasExistingPhoto = false,
  }) =>
      showModalBottomSheet<MsmeLogoSelectionResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => MsmeLogoPickerSheet(
          currentPresetId: currentPresetId,
          hasExistingPhoto: hasExistingPhoto,
        ),
      );

  @override
  State<MsmeLogoPickerSheet> createState() => _MsmeLogoPickerSheetState();
}

class _MsmeLogoPickerSheetState extends State<MsmeLogoPickerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedPresetId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedPresetId = widget.currentPresetId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Pilih Foto Logo Usaha',
        type: FileType.image,
      );

      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      if (bytes.lengthInBytes > 3 * 1024 * 1024) {
        if (!mounted) return;
        AppStatusDialog.showError(
          context,
          title: 'Ukuran Foto Terlalu Besar',
          message:
              'Ukuran foto maksimal adalah 3 MB. Harap perkecil atau pilih foto yang lebih ringkas.',
        );
        return;
      }

      if (!mounted) return;

      // Buka dialog penyesuaian posisi / crop framing
      final confirmedBytes = await _showCropFramingDialog(
        context,
        bytes,
        picked.name,
      );

      if (confirmedBytes != null && mounted) {
        Navigator.pop(
          context,
          MsmeLogoSelectionResult(
            pickedBytes: confirmedBytes,
            fileName: picked.name,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        AppStatusDialog.showError(
          context,
          title: 'Kesalahan Pemilihan',
          message:
              'Terjadi kendala saat memilih foto dari galeri. Pastikan izin akses media telah diberikan.',
        );
      }
    }
  }

  /// Dialog penyesuaian posisi logo / square crop framing interaktif
  Future<Uint8List?> _showCropFramingDialog(
    BuildContext context,
    Uint8List rawBytes,
    String fileName,
  ) =>
      showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.75),
        builder: (dialogCtx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.crop_rounded,
                          size: 20,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sesuaikan Posisi Logo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              'Cubit atau geser untuk memposisikan logo',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSlate),

                // Interactive Crop Viewport Frame
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryNavy,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.15),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 3.5,
                          boundaryMargin: const EdgeInsets.all(40),
                          child: Center(
                            child: Image.memory(
                              rawBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Corner Guides Overlay
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // File name & Tip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 15,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondarySlate,
                            side: const BorderSide(color: AppColors.borderSlate),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Ganti Foto',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogCtx, rawBytes),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Gunakan Foto',
                            style: TextStyle(fontWeight: FontWeight.w800),
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
      );

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.borderSlate,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Logo Usaha',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Gunakan foto galeri atau pilih avatar toko tematik',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tabs Segment
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primaryNavy,
                unselectedLabelColor: AppColors.secondarySlate,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.palette_rounded, size: 18),
                    text: 'Avatar Toko Tematik',
                  ),
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.cloud_upload_rounded, size: 18),
                    text: 'Unggah Galeri',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab Content
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Preset Avatars
                  _buildPresetsTab(),

                  // Tab 2: Gallery Upload Option
                  _buildGalleryUploadTab(),
                ],
              ),
            ),

            // Optional Reset / Clear Logo Button
            if (widget.hasExistingPhoto || widget.currentPresetId != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        const MsmeLogoSelectionResult(isCleared: true),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                    label: const Text(
                      'Hapus Logo / Gunakan Placeholder Default',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildPresetsTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih identitas visual yang paling pas dengan bidang usahamu:',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MsmeLogoHelper.presets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final preset = MsmeLogoHelper.presets[index];
                final isSelected = _selectedPresetId == preset.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPresetId = preset.id;
                    });
                    Navigator.pop(
                      context,
                      MsmeLogoSelectionResult(presetAvatarId: preset.id),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? preset.bgColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? preset.primaryColor
                            : AppColors.borderSlate,
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(
                            alpha: isSelected ? 0.08 : 0.03,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: preset.bgColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  preset.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            preset.icon,
                            color: preset.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                preset.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? preset.primaryColor
                                      : AppColors.darkSlate,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSelected ? 'Dipilih' : 'Ketuk pilih',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? preset.primaryColor
                                      : AppColors.secondarySlate,
                                ),
                              ),
                            ],
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
      );

  Widget _buildGalleryUploadTab() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                size: 40,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unggah Foto Logo Asli Tokomu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih gambar berformat PNG, JPG, atau WEBP persegi dengan ukuran maksimal 3 MB. Kamu dapat mengatur dan memposisikan crop frame setelah memilih.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.file_upload_rounded, size: 20),
                label: const Text(
                  'Buka Galeri & Pilih Foto',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
}
