import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/auth/widgets/user_avatar_modal.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key, this.authApi});

  final AuthApi? authApi;

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _universityController = TextEditingController(
    text: 'Universitas Negeri Surabaya',
  );
  final _majorController = TextEditingController(text: 'S1 Sistem Informasi');
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final AuthApi _authApi = widget.authApi ?? AuthApi();

  String? _ktmFileName;
  Uint8List? _ktmBytes;
  String? _pickedAvatarFileName;
  Uint8List? _pickedAvatarBytes;
  String? _selectedPresetAvatarId;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _hasAvatar =>
      _pickedAvatarBytes != null || _selectedPresetAvatarId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _nimController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickKtm() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih Berkas KTM',
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto/berkas KTM maksimal 5 MB.')),
        );
      }
      return;
    }
    setState(() {
      _ktmFileName = picked.name;
      _ktmBytes = bytes;
    });
  }

  Future<void> _openAvatarModal() async {
    final result = await UserAvatarPickerSheet.show(
      context,
      role: UserAvatarRole.student,
      currentPresetId: _selectedPresetAvatarId,
      hasExistingPhoto: _hasAvatar,
    );

    if (result != null && mounted) {
      setState(() {
        if (result.isCleared) {
          _pickedAvatarBytes = null;
          _pickedAvatarFileName = null;
          _selectedPresetAvatarId = null;
        } else if (result.pickedBytes != null) {
          _pickedAvatarBytes = result.pickedBytes;
          _pickedAvatarFileName = result.fileName;
          _selectedPresetAvatarId = null;
        } else if (result.presetAvatarId != null) {
          _selectedPresetAvatarId = result.presetAvatarId;
          _pickedAvatarBytes = null;
          _pickedAvatarFileName = null;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final univ = _universityController.text.trim();
    final major = _majorController.text.trim();
    final nim = _nimController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        univ.isEmpty ||
        major.isEmpty ||
        nim.isEmpty) {
      AppStatusDialog.showError(
        context,
        title: 'Data Belum Lengkap',
        message: 'Harap lengkapi seluruh kolom data pendaftaran mahasiswa.',
        buttonText: 'Lengkapi Data',
      );
      return;
    }
    if (password.length < 8) {
      AppStatusDialog.showError(
        context,
        title: 'Kata Sandi Kurang Aman',
        message:
            'Kata sandi akun minimal harus terdiri dari 8 karakter demi keamanan akun Anda.',
        buttonText: 'Perbaiki Kata Sandi',
      );
      return;
    }
    if (password != _confirmController.text) {
      AppStatusDialog.showError(
        context,
        title: 'Kata Sandi Tidak Cocok',
        message:
            'Konfirmasi kata sandi tidak cocok dengan kata sandi yang Anda masukkan.',
        buttonText: 'Periksa Kembali',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _authApi.registerStudent(
        name: name,
        email: email,
        password: password,
        university: univ,
        major: major,
        studentIdNumber: nim,
        ktmFileName: _ktmFileName,
        ktmBytes: _ktmBytes,
        avatarFileName: _pickedAvatarFileName,
        avatarBytes: _pickedAvatarBytes,
        avatarUrl: _selectedPresetAvatarId,
      );
      if (!mounted) return;

      await AppStatusDialog.showSuccess(
        context,
        title: 'Pendaftaran Berhasil!',
        message:
            'Akun mahasiswa "$name" telah aktif. Selamat datang di portal kolaborasi TalentSync!',
        buttonText: 'Masuk ke Dashboard',
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.studentDashboard,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        final isTaken = error.message.toLowerCase().contains('terdaftar') ||
            (error.errors != null &&
                (error.errors!.containsKey('email') ||
                    error.errors!.containsKey('student_id_number')));
        if (isTaken) {
          AppStatusDialog.showError(
            context,
            title: 'Akun Sudah Terdaftar',
            message: error.message,
            buttonText: 'Masuk Sekarang',
            onConfirm: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.studentAuth,
            ),
          );
        } else {
          AppStatusDialog.showError(
            context,
            title: 'Pendaftaran Gagal',
            message: error.message,
            buttonText: 'Coba Lagi',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        AppStatusDialog.showError(
          context,
          title: 'Kendala Koneksi',
          message: 'Pendaftaran gagal diproses. Periksa koneksi internet Anda.',
          buttonText: 'Coba Lagi',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => AppRoutes.popOrRoleSelection(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: const Text(
          'Daftar Mahasiswa',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AbsorbPointer(
          absorbing: _isSubmitting,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Akun Mahasiswa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Lengkapi identitas akademik dan unggah KTM untuk mengakses proyek UMKM dan bimbingan mentor.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondarySlate,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Foto Profil / Avatar Card
                InkWell(
                  onTap: _openAvatarModal,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hasAvatar
                            ? AppColors.primaryNavy
                            : AppColors.borderSlate,
                        width: _hasAvatar ? 1.6 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(
                            alpha: _hasAvatar ? 0.06 : 0.03,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        UserAvatarHelper.buildAvatarWidget(
                          avatarUrl: _selectedPresetAvatarId,
                          avatarBytes: _pickedAvatarBytes,
                          size: 58,
                          borderRadius: 16,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _pickedAvatarFileName != null
                                          ? _pickedAvatarFileName!
                                          : (_selectedPresetAvatarId != null
                                              ? (UserAvatarHelper.getPreset(_selectedPresetAvatarId)?.title ??
                                                  'Avatar Terpasang')
                                              : 'Foto Profil & Avatar'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                  ),
                                  if (_hasAvatar)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 13,
                                            color: Color(0xFF10B981),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Terpasang',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF047857),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _hasAvatar
                                    ? 'Ketuk untuk mengganti, sesuaikan crop, atau hapus'
                                    : 'Pilih foto galeri & crop atau gunakan avatar tematik',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _hasAvatar
                              ? Icons.tune_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: _hasAvatar
                              ? AppColors.primaryNavy
                              : AppColors.secondarySlate,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _field('Nama Lengkap', _nameController, Icons.person_outline_rounded, 'Contoh: Arya Pratama'),
                _field('Email Kampus / Pribadi', _emailController, Icons.mail_outline_rounded, 'arya@mhs.unesa.ac.id', keyboardType: TextInputType.emailAddress),
                _field('Perguruan Tinggi', _universityController, Icons.account_balance_rounded, 'Universitas Negeri Surabaya'),
                _field('Program Studi', _majorController, Icons.school_outlined, 'S1 Sistem Informasi'),
                _field('NIM (Nomor Induk Mahasiswa)', _nimController, Icons.badge_outlined, '24051214017', keyboardType: TextInputType.number),
                _field(
                  'Kata Sandi',
                  _passwordController,
                  Icons.lock_outline_rounded,
                  'Minimal 8 karakter',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ),
                _field(
                  'Konfirmasi Kata Sandi',
                  _confirmController,
                  Icons.lock_reset_rounded,
                  'Ulangi kata sandi',
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Foto / Dokumen KTM (Opsional saat daftar)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickKtm,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _ktmFileName != null
                              ? Icons.check_circle_rounded
                              : Icons.upload_file_rounded,
                          color: _ktmFileName != null
                              ? const Color(0xFF16A34A)
                              : AppColors.primaryNavy,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _ktmFileName ?? 'Pilih Foto / PDF KTM (Maks. 5 MB)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
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
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sudah punya akun? Masuk di sini'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 14, color: AppColors.darkSlate),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: Icon(icon, color: AppColors.secondarySlate, size: 20),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
