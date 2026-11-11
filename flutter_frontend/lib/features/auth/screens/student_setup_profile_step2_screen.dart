import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/profile/data/student_profile_api.dart';

class StudentSetupProfileStep2Screen extends StatefulWidget {
  const StudentSetupProfileStep2Screen({super.key, this.args});

  final StudentSetupArgs? args;

  @override
  State<StudentSetupProfileStep2Screen> createState() =>
      _StudentSetupProfileStep2ScreenState();
}

class _StudentSetupProfileStep2ScreenState
    extends State<StudentSetupProfileStep2Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _cohortController = TextEditingController(
    text: 'Angkatan 2024',
  );
  final TextEditingController _bioController = TextEditingController(
    text: 'Mahasiswa Sistem Informasi yang suka membangun aplikasi mobile untuk usaha kecil.',
  );

  final List<String> _selectedSkills = [
    'Information Systems',
    'Flutter',
    'Laravel',
  ];

  final List<String> _suggestedSkills = [
    'Figma',
    'UI Design',
    'MySQL',
    'Copywriting',
    'Data Analysis',
  ];

  String? _avatarFileName;
  Uint8List? _avatarBytes;
  bool _isAuthenticated = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final user = await ApiClient.instance.readSessionUser();
    if (!mounted) return;
    if (user != null || (widget.args?.isAuthenticated ?? false)) {
      setState(() {
        _isAuthenticated = true;
        if (user?['name'] is String && (user!['name'] as String).isNotEmpty) {
          _nameController.text = user['name'] as String;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _cohortController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih Foto Profil',
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto profil maksimal 2 MB.')),
        );
      }
      return;
    }
    setState(() {
      _avatarFileName = picked.name;
      _avatarBytes = bytes;
    });
  }

  void _addSkill(String skill) {
    if (!_selectedSkills.contains(skill)) {
      setState(() {
        _selectedSkills.add(skill);
        _suggestedSkills.remove(skill);
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _selectedSkills.remove(skill);
      if (!_suggestedSkills.contains(skill)) {
        _suggestedSkills.add(skill);
      }
    });
  }

  void _showAddCustomSkillDialog() {
    final TextEditingController customController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tambah Keahlian',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: customController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Contoh: React, Python...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondarySlate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final text = customController.text.trim();
              if (text.isNotEmpty) {
                _addSkill(text);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Tambah',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSetup() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      if (!_isAuthenticated) {
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        if (name.isEmpty || email.isEmpty || password.length < 8) {
          throw const ApiException(
            'Lengkapi nama, email, dan kata sandi minimal 8 karakter.',
          );
        }
        if (password != _confirmController.text) {
          throw const ApiException('Konfirmasi kata sandi tidak cocok.');
        }

        final setup = widget.args;
        await AuthApi().registerStudent(
          name: name,
          email: email,
          password: password,
          university: setup?.university ?? 'Universitas Negeri Surabaya',
          major: setup?.major ?? 'S1 Sistem Informasi',
          studentIdNumber:
              setup?.studentIdNumber ?? 'NIM-${DateTime.now().millisecondsSinceEpoch}',
          ktmFileName: setup?.ktmFileName,
          ktmBytes: setup?.ktmBytes,
          cohortYear: _cohortController.text.trim(),
          bio: _bioController.text.trim(),
          skills: _selectedSkills,
        );

        if (_avatarFileName != null && _avatarBytes != null) {
          await StudentProfileApi.instance.updateProfile(
            {'bio': _bioController.text.trim()},
            fileField: 'avatar_file',
            fileName: _avatarFileName,
            fileBytes: _avatarBytes,
          );
        }
      } else {
        await StudentProfileApi.instance.updateProfile(
          {
            'bio': _bioController.text.trim(),
            'cohort_year': _cohortController.text.trim(),
            'skills': _selectedSkills,
          },
          fileField: _avatarBytes != null ? 'avatar_file' : null,
          fileName: _avatarFileName,
          fileBytes: _avatarBytes,
        );
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.studentDashboard,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan profil mahasiswa. Coba lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Mahasiswa TalentSync';
    final displayMajor = widget.args?.major ?? 'S1 Sistem Informasi';
    final initialChar = displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isSubmitting,
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
                      // Top Back & Header Title
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
                                      alpha: 0.06,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.keyboard_arrow_left_rounded,
                                  size: 24,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setup Profile',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Langkah 2 dari 2',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Progress Bar (Both segments filled)
                      Row(
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Profile Avatar Card
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavy,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _avatarBytes != null
                                      ? Image.memory(
                                          _avatarBytes!,
                                          width: 76,
                                          height: 76,
                                          cacheWidth: 228,
                                          fit: BoxFit.cover,
                                        )
                                      : Center(
                                          child: Text(
                                            initialChar,
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: -3,
                                  right: -3,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentAmberGold,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$displayMajor · ${_cohortController.text}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: Color(0xFF16A34A),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          widget.args?.ktmFileName != null
                                              ? 'KTM terlampir'
                                              : 'Identitas terverifikasi',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF15803D),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (!_isAuthenticated) ...[
                        const SizedBox(height: 24),
                        _accountField(
                          'Nama Lengkap',
                          _nameController,
                          'Contoh: Arya Pratama',
                        ),
                        _accountField(
                          'Email Kampus / Aktif',
                          _emailController,
                          'arya@mhs.unesa.ac.id',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _accountField(
                          'Kata Sandi Akun',
                          _passwordController,
                          'Minimal 8 karakter',
                          obscure: true,
                        ),
                        _accountField(
                          'Konfirmasi Kata Sandi',
                          _confirmController,
                          'Ulangi kata sandi',
                          obscure: true,
                        ),
                      ],

                      const SizedBox(height: 20),
                      _accountField(
                        'Angkatan',
                        _cohortController,
                        'Contoh: Angkatan 2024',
                      ),

                      const SizedBox(height: 12),

                      // Section 1: Bio Singkat
                      const Text(
                        'Bio singkat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: TextField(
                          controller: _bioController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.darkSlate,
                            height: 1.45,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section 2: Keahlian & Minat
                      const Text(
                        'Keahlian dan minat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ketuk untuk memilih atau tambah keahlian baru',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Selected Skills + Custom Button
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ..._selectedSkills.map(
                            (skill) => GestureDetector(
                              onTap: () => _removeSkill(skill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNavy,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      skill,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: _showAddCustomSkillDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryNavy,
                                  width: 1.5,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 15,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tambah keahlian',
                                    style: TextStyle(
                                      color: AppColors.primaryNavy,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _suggestedSkills
                            .map(
                              (skill) => GestureDetector(
                                onTap: () => _addSkill(skill),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.add_rounded,
                                        color: AppColors.secondarySlate,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        skill,
                                        style: const TextStyle(
                                          color: AppColors.darkSlate,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom CTA Button: Finish Setup
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 28,
                  top: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _finishSetup,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Finish Setup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              style: const TextStyle(fontSize: 14, color: AppColors.darkSlate),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
