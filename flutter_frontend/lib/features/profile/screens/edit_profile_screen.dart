import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/widgets/user_avatar_modal.dart';
import 'package:flutter_frontend/features/profile/data/student_profile_api.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.profileApi});

  final StudentProfileApi? profileApi;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final StudentProfileApi _api =
      widget.profileApi ?? StudentProfileApi.instance;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _headlineCtrl = TextEditingController();
  final TextEditingController _universityCtrl = TextEditingController();
  final TextEditingController _majorCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _linkedInCtrl = TextEditingController();
  final TextEditingController _gitHubCtrl = TextEditingController();
  final TextEditingController _skillInputCtrl = TextEditingController();

  final List<String> _skills = [];
  bool _isPublicProfile = true;
  bool _isOpenForProjects = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeletingAccount = false;
  String? _error;

  String? _avatarUrl;
  String? _selectedPresetAvatarId;
  String? _pickedAvatarName;
  Uint8List? _pickedAvatarBytes;
  bool _removeAvatar = false;

  bool get _hasAnyAvatar =>
      _pickedAvatarBytes != null ||
      _selectedPresetAvatarId != null ||
      (!_removeAvatar && _avatarUrl != null && _avatarUrl!.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _headlineCtrl.dispose();
    _universityCtrl.dispose();
    _majorCtrl.dispose();
    _bioCtrl.dispose();
    _linkedInCtrl.dispose();
    _gitHubCtrl.dispose();
    _skillInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await _api.profile();
      if (!mounted) return;
      _nameCtrl.text = (profile['name'] as String?) ?? '';
      _headlineCtrl.text = (profile['headline'] as String?) ?? '';
      _universityCtrl.text = (profile['university'] as String?) ?? '';
      _majorCtrl.text = (profile['major'] as String?) ?? '';
      _bioCtrl.text = (profile['bio'] as String?) ?? '';
      _linkedInCtrl.text = (profile['linkedin_url'] as String?) ?? '';
      _gitHubCtrl.text = (profile['github_username'] as String?) ?? '';
      final rawAvatar = profile['avatar_url'] as String?;
      _avatarUrl = rawAvatar;
      _selectedPresetAvatarId =
          (rawAvatar != null && rawAvatar.startsWith('avatar:'))
          ? rawAvatar
          : null;
      _removeAvatar = false;
      _isPublicProfile = profile['is_public_profile'] != false;
      _isOpenForProjects = profile['is_open_for_projects'] != false;

      _skills
        ..clear()
        ..addAll(
          (profile['skills'] as List? ?? const [])
              .whereType<Map>()
              .map((s) => (s['name'] ?? '').toString())
              .where((name) => name.isNotEmpty),
        );

      setState(() => _isLoading = false);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data profil mahasiswa.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAvatarModal() async {
    final result = await UserAvatarPickerSheet.show(
      context,
      role: UserAvatarRole.student,
      currentPresetId: _selectedPresetAvatarId,
      hasExistingPhoto: _hasAnyAvatar,
    );
    if (result == null || !mounted) return;

    setState(() {
      if (result.isCleared) {
        _pickedAvatarBytes = null;
        _pickedAvatarName = null;
        _selectedPresetAvatarId = null;
        _removeAvatar = true;
      } else if (result.pickedBytes != null) {
        _pickedAvatarBytes = result.pickedBytes;
        _pickedAvatarName = result.fileName;
        _selectedPresetAvatarId = null;
        _removeAvatar = false;
      } else if (result.presetAvatarId != null) {
        _selectedPresetAvatarId = result.presetAvatarId;
        _pickedAvatarBytes = null;
        _pickedAvatarName = null;
        _removeAvatar = false;
      }
    });
  }

  void _addSkill() {
    final val = _skillInputCtrl.text.trim();
    if (val.isEmpty) return;
    final exists = _skills.any((s) => s.toLowerCase() == val.toLowerCase());
    if (!exists) {
      setState(() => _skills.add(val));
    }
    _skillInputCtrl.clear();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _universityCtrl.text.trim().isEmpty ||
        _majorCtrl.text.trim().isEmpty) {
      await AppStatusDialog.showError(
        context,
        title: 'Data Belum Lengkap',
        message: 'Nama lengkap, universitas, dan program studi wajib diisi.',
        buttonText: 'Lengkapi Data',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final body = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'headline': _headlineCtrl.text.trim(),
        'university': _universityCtrl.text.trim(),
        'major': _majorCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'linkedin_url': _linkedInCtrl.text.trim(),
        'github_username': _gitHubCtrl.text.trim().replaceFirst('@', ''),
        'is_public_profile': _isPublicProfile,
        'is_open_for_projects': _isOpenForProjects,
        'skills': _skills,
        if (_removeAvatar && _pickedAvatarBytes == null) 'remove_avatar': true,
        if (_selectedPresetAvatarId != null && _pickedAvatarBytes == null)
          'avatar_url': _selectedPresetAvatarId,
      };
      final updated = await _api.updateProfile(
        body,
        fileField: _pickedAvatarBytes != null ? 'avatar_file' : null,
        fileName: _pickedAvatarName,
        fileBytes: _pickedAvatarBytes,
      );
      await ApiClient.instance.updateSessionUser({
        'name': updated['name'] ?? _nameCtrl.text.trim(),
        'avatar_url': updated['avatar_url'],
        if (updated['university'] != null) 'university': updated['university'],
        if (updated['major'] != null) 'major': updated['major'],
      });
      if (!mounted) return;
      await AppStatusDialog.showSuccess(
        context,
        title: 'Profil Tersimpan!',
        message: 'Perubahan profil dan foto/avatar mahasiswa Anda berhasil disimpan ke database.',
        buttonText: 'Kembali ke Profil',
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Menyimpan Profil',
        message: e.message,
        buttonText: 'Coba Lagi',
      );
    } catch (_) {
      if (!mounted) return;
      await AppStatusDialog.showError(
        context,
        title: 'Kendala Koneksi',
        message: 'Gagal menyimpan perubahan profil. Coba lagi.',
        buttonText: 'Mengerti',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      children: [
                        _buildAvatarPicker(),
                        const SizedBox(height: 16),
                        _buildField('Nama Lengkap', _nameCtrl),
                        _buildField('Headline Profil', _headlineCtrl),
                        _buildField('Universitas', _universityCtrl),
                        _buildField('Program Studi / Jurusan', _majorCtrl),
                        _buildField('Bio Singkat', _bioCtrl, maxLines: 3),
                        _buildField(
                          'Tautan LinkedIn',
                          _linkedInCtrl,
                          hint: 'https://linkedin.com/in/username',
                        ),
                        _buildField(
                          'Username GitHub',
                          _gitHubCtrl,
                          hint: 'arya-pratama',
                        ),
                        const SizedBox(height: 6),
                        _buildSkillsEditor(),
                        const SizedBox(height: 14),
                        _buildVisibilityToggles(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isSaving || _isDeletingAccount
                                ? null
                                : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDangerZoneCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.darkSlate,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Edit Profil Mahasiswa',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker() {
    final displayName = _nameCtrl.text.trim();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';
    final effectiveUrl = _removeAvatar
        ? null
        : (_selectedPresetAvatarId ?? _avatarUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _openAvatarModal,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatarHelper.buildAvatarWidget(
                      avatarUrl: effectiveUrl,
                      avatarBytes: _pickedAvatarBytes,
                      size: 68,
                      borderRadius: 18,
                      initial: initial,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto & Avatar Profil',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Unggah PNG/JPG (bisa crop) atau pilih avatar tematik',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNavy,
                          side: const BorderSide(color: AppColors.primaryNavy),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openAvatarModal,
                        icon: const Icon(Icons.crop_rounded, size: 16),
                        label: Text(
                          _pickedAvatarName != null
                              ? 'Ganti Foto Terpilih'
                              : 'Unggah & Potong Foto',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Atau pilih cepat avatar tematik:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondarySlate,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: UserAvatarHelper.studentPresets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = UserAvatarHelper.studentPresets[index];
                final isSelected =
                    _pickedAvatarBytes == null &&
                    !_removeAvatar &&
                    _selectedPresetAvatarId == preset.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPresetAvatarId = preset.id;
                      _pickedAvatarBytes = null;
                      _pickedAvatarName = null;
                      _removeAvatar = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: preset.bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : preset.primaryColor.withValues(alpha: 0.3),
                        width: isSelected ? 2.4 : 1.2,
                      ),
                    ),
                    child: Icon(
                      preset.icon,
                      size: 24,
                      color: preset.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSlate),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSlate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Keahlian',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputCtrl,
                  onSubmitted: (_) => _addSkill(),
                  decoration: InputDecoration(
                    hintText: 'Tambah skill (contoh: Laravel)',
                    filled: true,
                    fillColor: AppColors.canvasWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addSkill,
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map(
                    (s) => Chip(
                      label: Text(s),
                      backgroundColor: AppColors.lightBlueSurface,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      onDeleted: () => setState(() => _skills.remove(s)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisibilityToggles() {
    return Material(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSlate),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Profil & Portofolio Publik',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Dapat diakses melalui tautan CV TalentSync',
              style: TextStyle(fontSize: 12),
            ),
            activeThumbColor: AppColors.primaryNavy,
            value: _isPublicProfile,
            onChanged: (v) => setState(() => _isPublicProfile = v),
          ),
          const Divider(height: 1, color: AppColors.borderSlate),
          SwitchListTile(
            title: const Text(
              'Terbuka untuk Proyek UMKM',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Tampilkan status siap menerima tawaran proyek',
              style: TextStyle(fontSize: 12),
            ),
            activeThumbColor: AppColors.primaryNavy,
            value: _isOpenForProjects,
            onChanged: (v) => setState(() => _isOpenForProjects = v),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    if (_isDeletingAccount) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Akun Mahasiswa Permanen?',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Seluruh data profil, foto, KTM, dan akses akun mahasiswa Anda akan dihapus permanen dan tidak bisa dikembalikan. Pastikan tidak ada proyek aktif atau saldo escrow tertahan.',
          style: TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.secondarySlate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Hapus Akun',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _api.deleteAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.roleSelection,
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      await AppStatusDialog.showError(
        context,
        title: 'Tidak Dapat Menghapus Akun',
        message: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Menghapus Akun',
        message: 'Terjadi kendala saat menghapus akun. Coba lagi nanti.',
      );
    }
  }

  Widget _buildDangerZoneCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB91C1C),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Hapus Akun Permanen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Menghapus akun akan menonaktifkan profil dan menghapus akses login secara permanen.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7F1D1D),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB91C1C),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSaving || _isDeletingAccount
                  ? null
                  : _confirmDeleteAccount,
              icon: _isDeletingAccount
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFB91C1C),
                      ),
                    )
                  : const Icon(Icons.delete_forever_rounded, size: 18),
              label: Text(
                _isDeletingAccount
                    ? 'Menghapus akun...'
                    : 'Hapus Akun Mahasiswa',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                ),
                onPressed: _load,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
