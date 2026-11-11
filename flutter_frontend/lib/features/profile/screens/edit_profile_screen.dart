import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
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
  String? _error;
  String? _avatarUrl;
  String? _pickedAvatarName;
  Uint8List? _pickedAvatarBytes;

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
      _avatarUrl = ApiClient.resolveMediaUrl(profile['avatar_url'] as String?);
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

  Future<void> _pickAvatar() async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Pilih Foto Profil',
        type: FileType.image,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        _showSnack('Ukuran foto maksimal 2 MB.', isError: true);
        return;
      }
      setState(() {
        _pickedAvatarName = file.name;
        _pickedAvatarBytes = bytes;
      });
    } catch (_) {
      _showSnack('Gagal memilih foto profil.', isError: true);
    }
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
      _showSnack(
        'Nama, universitas, dan program studi wajib diisi.',
        isError: true,
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
      };
      final updated = await _api.updateProfile(
        body,
        fileField: _pickedAvatarBytes != null ? 'avatar_file' : null,
        fileName: _pickedAvatarName,
        fileBytes: _pickedAvatarBytes,
      );
      await ApiClient.instance.updateSessionUser({
        'name': updated['name'],
        if (updated['avatar_url'] != null) 'avatar_url': updated['avatar_url'],
        if (updated['university'] != null) 'university': updated['university'],
        if (updated['major'] != null) 'major': updated['major'],
      });
      if (!mounted) return;
      _showSnack('Profil mahasiswa berhasil disimpan.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal menyimpan perubahan profil.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
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
                            onPressed: _isSaving ? null : _save,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.lightBlueSurface,
              child: _pickedAvatarBytes != null
                  ? Image.memory(
                      _pickedAvatarBytes!,
                      width: 60,
                      height: 60,
                      cacheWidth: 160,
                      fit: BoxFit.cover,
                    )
                  : _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? Image.network(
                      _avatarUrl!,
                      width: 60,
                      height: 60,
                      cacheWidth: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Profil Publik',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _pickAvatar,
                    icon: const Icon(Icons.photo_camera_rounded, size: 17),
                    label: Text(
                      _pickedAvatarName ?? 'Ganti Foto',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
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
