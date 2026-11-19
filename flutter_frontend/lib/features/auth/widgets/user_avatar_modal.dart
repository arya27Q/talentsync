import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
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

class UserAvatarHelper {
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

    // 3. Gambar network / link cloud
    if (avatarUrl != null &&
        (avatarUrl.startsWith('http://') ||
            avatarUrl.startsWith('https://') ||
            avatarUrl.startsWith('/'))) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _defaultPlaceholder(size, clipRadius, initial),
        ),
      );
    }

    return _defaultPlaceholder(size, clipRadius, initial);
  }

  static Widget _defaultPlaceholder(
    double size,
    BorderRadius clipRadius,
    String? initial,
  ) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: clipRadius,
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Center(
          child: initial != null && initial.isNotEmpty
              ? Text(
                  initial.toUpperCase(),
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  size: size * 0.52,
                  color: AppColors.secondarySlate,
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
        return 'Gunakan foto galeri atau pilih avatar tematik keahlianmu';
      case UserAvatarRole.mentor:
        return 'Gunakan foto profesional atau pilih avatar kepakaranmu';
      case UserAvatarRole.msme:
        return 'Gunakan foto galeri atau pilih avatar toko tematik';
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: _title,
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
          UserAvatarSelectionResult(
            pickedBytes: confirmedBytes,
            fileName: picked.name,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppStatusDialog.showError(
        context,
        title: 'Kesalahan Pemilihan',
        message:
            'Terjadi kendala saat memilih foto dari galeri. Pastikan izin akses media telah diberikan.',
      );
    }
  }

  /// Dialog penyesuaian posisi foto / square crop framing interaktif
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
                              'Sesuaikan Posisi Foto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              'Cubit atau geser untuk memposisikan foto',
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 19,
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

            // Optional Reset / Clear Avatar Button
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildPresetsTab() {
    final presets = UserAvatarHelper.getPresets(widget.role);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        final isSelected = _selectedPresetId == preset.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedPresetId = preset.id;
            });
            Navigator.pop(
              context,
              UserAvatarSelectionResult(presetAvatarId: preset.id),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryNavy
                    : AppColors.borderSlate.withValues(alpha: 0.8),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryNavy.withValues(alpha: 0.12)
                      : const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: isSelected ? 10 : 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: preset.bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: preset.primaryColor.withValues(alpha: 0.35),
                          width: 1.4,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          preset.icon,
                          size: 26,
                          color: preset.primaryColor,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  preset.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryNavy
                        : AppColors.darkSlate,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryUploadTab() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImageFromGallery,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.canvasWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryNavy.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 32,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pilih Foto dari Galeri Ponsel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Format didukung: JPG, PNG, WEBP (Maksimal 3 MB)\nDilengkapi fitur sesuaikan posisi & crop frame interaktif',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                        height: 1.35,
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
