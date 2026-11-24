import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/widgets/msme_logo_modal.dart';

/// Peran pengguna untuk kurasi preset avatar tematik
enum UserAvatarRole {
  student,
  mentor,
  msme,
}

/// Definisi preset avatar tematik pengguna
class UserAvatarPreset {
  const UserAvatarPreset({
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

class CroppedPhotoResult {
  const CroppedPhotoResult({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

class UserAvatarHelper {
  static const List<String> allowedPhotoExtensions = ['png', 'jpg', 'jpeg'];
  static const int maxPhotoBytes = 3 * 1024 * 1024;

  // Preset Avatar Mahasiswa
  static const List<UserAvatarPreset> studentPresets = [
    UserAvatarPreset(
      id: 'avatar:student_tech',
      title: 'Teknologi & IT',
      icon: Icons.terminal_rounded,
      primaryColor: Color(0xFF1E3A8A),
      bgColor: Color(0xFFEFF6FF),
    ),
    UserAvatarPreset(
      id: 'avatar:student_design',
      title: 'Desain & Kreatif',
      icon: Icons.palette_rounded,
      primaryColor: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    UserAvatarPreset(
      id: 'avatar:student_business',
      title: 'Bisnis & Manajemen',
      icon: Icons.trending_up_rounded,
      primaryColor: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    UserAvatarPreset(
      id: 'avatar:student_media',
      title: 'Media & Komunikasi',
      icon: Icons.videocam_rounded,
      primaryColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    UserAvatarPreset(
      id: 'avatar:student_data',
      title: 'Data & Riset',
      icon: Icons.analytics_rounded,
      primaryColor: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
    ),
    UserAvatarPreset(
      id: 'avatar:student_creative',
      title: 'Penulis & Konten',
      icon: Icons.draw_rounded,
      primaryColor: Color(0xFFE11D48),
      bgColor: Color(0xFFFFF1F2),
    ),
    UserAvatarPreset(
      id: 'avatar:student_male',
      title: 'Mahasiswa Putra',
      icon: Icons.face_rounded,
      primaryColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    UserAvatarPreset(
      id: 'avatar:student_female',
      title: 'Mahasiswa Putri',
      icon: Icons.face_3_rounded,
      primaryColor: Color(0xFFDB2777),
      bgColor: Color(0xFFFDF2F8),
    ),
  ];

  // Preset Avatar Mentor
  static const List<UserAvatarPreset> mentorPresets = [
    UserAvatarPreset(
      id: 'avatar:mentor_tech',
      title: 'Tech Lead & Engineer',
      icon: Icons.code_rounded,
      primaryColor: Color(0xFF1E3A8A),
      bgColor: Color(0xFFEFF6FF),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_design',
      title: 'Design Lead & UI/UX',
      icon: Icons.brush_rounded,
      primaryColor: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_business',
      title: 'Business Founder',
      icon: Icons.workspace_premium_rounded,
      primaryColor: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_marketing',
      title: 'Growth & Marketing',
      icon: Icons.campaign_rounded,
      primaryColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFF7ED),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_data',
      title: 'Data & AI Specialist',
      icon: Icons.psychology_rounded,
      primaryColor: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_advisor',
      title: 'Academic Advisor',
      icon: Icons.school_rounded,
      primaryColor: Color(0xFF6D4C41),
      bgColor: Color(0xFFEFEBE9),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_expert',
      title: 'Senior Consultant',
      icon: Icons.verified_user_rounded,
      primaryColor: Color(0xFF0D9488),
      bgColor: Color(0xFFF0FDFA),
    ),
    UserAvatarPreset(
      id: 'avatar:mentor_coach',
      title: 'Agile & Product Coach',
      icon: Icons.groups_rounded,
      primaryColor: Color(0xFF4F46E5),
      bgColor: Color(0xFFEEF2FF),
    ),
  ];

  /// Validasi ketat: hanya menerima berkas gambar PNG atau JPG/JPEG asli
  /// (ekstensi + magic bytes) agar file PDF/DOC/GIF/lainnya otomatis tertolak.
  static String? validatePngJpg(
    String fileName,
    Uint8List bytes, {
    int maxBytes = maxPhotoBytes,
  }) {
    final cleanName = fileName.trim();
    final ext = cleanName.contains('.')
        ? cleanName.split('.').last.toLowerCase()
        : '';
    if (!allowedPhotoExtensions.contains(ext)) {
      return 'Format foto harus PNG atau JPG.';
    }
    if (bytes.isEmpty) {
      return 'Berkas foto kosong dan tidak dapat diunggah.';
    }
    if (bytes.lengthInBytes > maxBytes) {
      final mb = (maxBytes / (1024 * 1024)).round();
      return 'Ukuran foto profil maksimal $mb MB.';
    }
    final isPng = bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isJpeg = bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    if (!isPng && !isJpeg) {
      return 'Isi berkas bukan gambar PNG atau JPG yang valid.';
    }
    return null;
  }

  /// Membuka dialog crop interaktif 1:1 (zoom + geser) yang menghasilkan
  /// byte PNG hasil potongan nyata.
  static Future<CroppedPhotoResult?> showCropDialog(
    BuildContext context, {
    required Uint8List rawBytes,
    required String fileName,
    String title = 'Potong & Sesuaikan Foto',
  }) =>
      showDialog<CroppedPhotoResult>(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.75),
        builder: (_) => _RealCropDialog(
          rawBytes: rawBytes,
          fileName: fileName,
          title: title,
        ),
      );

  static List<UserAvatarPreset> getPresets(UserAvatarRole role) {
    switch (role) {
      case UserAvatarRole.student:
        return studentPresets;
      case UserAvatarRole.mentor:
        return mentorPresets;
      case UserAvatarRole.msme:
        return MsmeLogoHelper.presets
            .map(
              (p) => UserAvatarPreset(
                id: p.id,
                title: p.title,
                icon: p.icon,
                primaryColor: p.primaryColor,
                bgColor: p.bgColor,
              ),
            )
            .toList();
    }
  }

  static UserAvatarPreset? getPreset(String? id) {
    if (id == null) return null;
    try {
      final inStudent = studentPresets.where((p) => p.id == id);
      if (inStudent.isNotEmpty) return inStudent.first;

      final inMentor = mentorPresets.where((p) => p.id == id);
      if (inMentor.isNotEmpty) return inMentor.first;

      final msmePreset = MsmeLogoHelper.getPreset(id);
      if (msmePreset != null) {
        return UserAvatarPreset(
          id: msmePreset.id,
          title: msmePreset.title,
          icon: msmePreset.icon,
          primaryColor: msmePreset.primaryColor,
          bgColor: msmePreset.bgColor,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Membangun widget avatar secara responsif dan seragam
  static Widget buildAvatarWidget({
    String? avatarUrl,
    Uint8List? avatarBytes,
    double size = 56,
    double borderRadius = 18,
    bool isCircle = false,
    String? initial,
    Color? fallbackBgColor,
    Color? fallbackTextColor,
  }) {
    final clipRadius = isCircle
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(borderRadius);

    // 1. Gambar memori lokal hasil pemilihan/crop
    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Image.memory(
          avatarBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // 2. Preset avatar tematik
    if (avatarUrl != null && avatarUrl.startsWith('avatar:')) {
      final preset = getPreset(avatarUrl);
      if (preset != null) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: preset.bgColor,
            borderRadius: clipRadius,
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

    // 3. Gambar network / link cloud (resolve /storage/... otomatis)
    final resolved = ApiClient.resolveMediaUrl(avatarUrl);
    if (resolved != null && resolved.isNotEmpty) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Image.network(
          resolved,
          width: size,
          height: size,
          cacheWidth: (size * 3).round(),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultPlaceholder(
            size,
            clipRadius,
            initial,
            fallbackBgColor: fallbackBgColor,
            fallbackTextColor: fallbackTextColor,
          ),
        ),
      );
    }

    return _defaultPlaceholder(
      size,
      clipRadius,
      initial,
      fallbackBgColor: fallbackBgColor,
      fallbackTextColor: fallbackTextColor,
    );
  }

  static Widget _defaultPlaceholder(
    double size,
    BorderRadius clipRadius,
    String? initial, {
    Color? fallbackBgColor,
    Color? fallbackTextColor,
  }) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fallbackBgColor ?? const Color(0xFFF1F5F9),
          borderRadius: clipRadius,
          border: fallbackBgColor == null
              ? Border.all(color: AppColors.borderSlate)
              : null,
        ),
        child: Center(
          child: initial != null && initial.isNotEmpty
              ? Text(
                  initial.toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w800,
                    color: fallbackTextColor ?? AppColors.primaryNavy,
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  size: size * 0.52,
                  color: fallbackTextColor ?? AppColors.secondarySlate,
                ),
        ),
      );
}

/// Hasil pemilihan avatar/foto dari modal
class UserAvatarSelectionResult {
  const UserAvatarSelectionResult({
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

/// Modal Sheet Pemilihan Foto Profil & Avatar Tematik
class UserAvatarPickerSheet extends StatefulWidget {
  const UserAvatarPickerSheet({
    super.key,
    required this.role,
    this.currentPresetId,
    this.hasExistingPhoto = false,
  });

  final UserAvatarRole role;
  final String? currentPresetId;
  final bool hasExistingPhoto;

  static Future<UserAvatarSelectionResult?> show(
    BuildContext context, {
    required UserAvatarRole role,
    String? currentPresetId,
    bool hasExistingPhoto = false,
  }) =>
      showModalBottomSheet<UserAvatarSelectionResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => UserAvatarPickerSheet(
          role: role,
          currentPresetId: currentPresetId,
          hasExistingPhoto: hasExistingPhoto,
        ),
      );

  @override
  State<UserAvatarPickerSheet> createState() => _UserAvatarPickerSheetState();
}

class _UserAvatarPickerSheetState extends State<UserAvatarPickerSheet>
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

  String get _title {
    switch (widget.role) {
      case UserAvatarRole.student:
        return 'Pilih Foto Profil Mahasiswa';
      case UserAvatarRole.mentor:
        return 'Pilih Foto Profil Mentor';
      case UserAvatarRole.msme:
        return 'Pilih Logo Usaha';
    }
  }

  String get _subtitle {
    switch (widget.role) {
      case UserAvatarRole.student:
        return 'Unggah foto PNG/JPG (bisa crop) atau pilih avatar tematik';
      case UserAvatarRole.mentor:
        return 'Unggah foto PNG/JPG (bisa crop) atau pilih avatar kepakaran';
      case UserAvatarRole.msme:
        return 'Unggah logo PNG/JPG (bisa crop) atau pilih avatar toko';
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: '$_title (PNG/JPG)',
        type: FileType.custom,
        allowedExtensions: UserAvatarHelper.allowedPhotoExtensions,
      );

      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      final validationError = UserAvatarHelper.validatePngJpg(
        picked.name,
        bytes,
      );
      if (validationError != null) {
        if (!mounted) return;
        AppStatusDialog.showError(
          context,
          title: 'Berkas Tidak Didukung',
          message:
              '$validationError Berkas selain gambar PNG/JPG (seperti PDF atau dokumen lain) tidak diperbolehkan.',
        );
        return;
      }

      if (!mounted) return;

      final cropped = await UserAvatarHelper.showCropDialog(
        context,
        rawBytes: bytes,
        fileName: picked.name,
      );

      if (cropped != null && mounted) {
        Navigator.pop(
          context,
          UserAvatarSelectionResult(
            pickedBytes: cropped.bytes,
            fileName: cropped.fileName,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppStatusDialog.showError(
        context,
        title: 'Kesalahan Pemilihan',
        message:
            'Terjadi kendala saat memilih foto dari galeri. Pastikan berkas berupa gambar PNG atau JPG.',
      );
    }
  }

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle,
                          style: const TextStyle(
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
                    text: 'Avatar Tematik',
                  ),
                  Tab(
                    iconMargin: EdgeInsets.only(bottom: 2),
                    icon: Icon(Icons.cloud_upload_rounded, size: 18),
                    text: 'Unggah PNG/JPG',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPresetsTab(),
                  _buildGalleryUploadTab(),
                ],
              ),
            ),

            if (widget.hasExistingPhoto || widget.currentPresetId != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        const UserAvatarSelectionResult(isCleared: true),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                    label: const Text(
                      'Hapus Foto / Gunakan Avatar Default',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      );

  Widget _buildPresetsTab() {
    final presets = UserAvatarHelper.getPresets(widget.role);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        final isSelected = _selectedPresetId == preset.id;

        return GestureDetector(
          onTap: () {
            Navigator.pop(
              context,
              UserAvatarSelectionResult(presetAvatarId: preset.id),
            );
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: preset.bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryNavy
                        : preset.primaryColor.withValues(alpha: 0.28),
                    width: isSelected ? 2.5 : 1.4,
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
                child: Center(
                  child: Icon(
                    preset.icon,
                    size: 28,
                    color: preset.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                preset.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryNavy
                      : AppColors.secondarySlate,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryUploadTab() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImageFromGallery,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primaryNavy.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 32,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pilih Foto dari Perangkat',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hanya mendukung format PNG atau JPG/JPEG (maks. 3 MB).\nAnda dapat memotong & menyesuaikan bingkai foto sebelum disimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondarySlate,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.crop_rounded, size: 18),
                        label: const Text(
                          'Pilih & Potong Foto',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
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
      );
}

class _RealCropDialog extends StatefulWidget {
  const _RealCropDialog({
    required this.rawBytes,
    required this.fileName,
    required this.title,
  });

  final Uint8List rawBytes;
  final String fileName;
  final String title;

  @override
  State<_RealCropDialog> createState() => _RealCropDialogState();
}

class _RealCropDialogState extends State<_RealCropDialog> {
  final GlobalKey _cropBoundaryKey = GlobalKey();
  final TransformationController _transformController =
      TransformationController();
  double _zoom = 1.0;
  bool _isExporting = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _applyZoom(double scale) {
    final clamped = scale.clamp(1.0, 3.5);
    setState(() => _zoom = clamped);
    const viewport = 240.0;
    final offset = (viewport * (1 - clamped)) / 2;
    _transformController.value = Matrix4.identity()
      ..setEntry(0, 3, offset)
      ..setEntry(1, 3, offset)
      ..setEntry(0, 0, clamped)
      ..setEntry(1, 1, clamped);
  }

  void _resetCrop() {
    setState(() => _zoom = 1.0);
    _transformController.value = Matrix4.identity();
  }

  Future<void> _confirmCrop() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final renderObject = _cropBoundaryKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        final image = await renderObject.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        if (byteData != null) {
          final croppedBytes = byteData.buffer.asUint8List();
          final baseName = widget.fileName.contains('.')
              ? widget.fileName.substring(0, widget.fileName.lastIndexOf('.'))
              : widget.fileName;
          final croppedName =
              '${baseName.isEmpty ? 'avatar' : baseName}_cropped.png';
          if (mounted) {
            Navigator.pop(
              context,
              CroppedPhotoResult(bytes: croppedBytes, fileName: croppedName),
            );
          }
          return;
        }
      }
      if (mounted) {
        Navigator.pop(
          context,
          CroppedPhotoResult(bytes: widget.rawBytes, fileName: widget.fileName),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(
          context,
          CroppedPhotoResult(bytes: widget.rawBytes, fileName: widget.fileName),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.22),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const Text(
                            'Geser & perbesar foto di dalam kotak 1:1',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reset posisi',
                      onPressed: _isExporting ? null : _resetCrop,
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSlate),

              // Square Crop Frame (RepaintBoundary produces actual cropped PNG)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Container(
                  width: 244,
                  height: 244,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryNavy,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RepaintBoundary(
                          key: _cropBoundaryKey,
                          child: Container(
                            width: 240,
                            height: 240,
                            color: const Color(0xFF0F172A),
                            child: InteractiveViewer(
                              transformationController: _transformController,
                              minScale: 1.0,
                              maxScale: 3.5,
                              boundaryMargin: const EdgeInsets.all(140),
                              onInteractionEnd: (_) {
                                final currentScale =
                                    _transformController.value.getMaxScaleOnAxis();
                                if (mounted) {
                                  setState(
                                    () => _zoom = currentScale.clamp(1.0, 3.5),
                                  );
                                }
                              },
                              child: Image.memory(
                                widget.rawBytes,
                                width: 240,
                                height: 240,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Guide overlay (excluded from RepaintBoundary)
                        IgnorePointer(
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Zoom Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.zoom_out_rounded,
                      size: 18,
                      color: AppColors.secondarySlate,
                    ),
                    Expanded(
                      child: Slider(
                        value: _zoom,
                        min: 1.0,
                        max: 3.5,
                        activeColor: AppColors.primaryNavy,
                        onChanged: _isExporting ? null : _applyZoom,
                      ),
                    ),
                    const Icon(
                      Icons.zoom_in_rounded,
                      size: 18,
                      color: AppColors.primaryNavy,
                    ),
                  ],
                ),
              ),

              // File name
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
                        widget.fileName,
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
              const SizedBox(height: 16),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isExporting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondarySlate,
                          side: const BorderSide(color: AppColors.borderSlate),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isExporting ? null : _confirmCrop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Potong & Pakai',
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
  }
}
