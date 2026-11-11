import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';

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
  bool _obscurePassword = true;
  bool _isSubmitting = false;

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
        nim.isEmpty ||
        password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi seluruh kolom dan gunakan kata sandi minimal 8 karakter.',
          ),
        ),
      );
      return;
    }
    if (password != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
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
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.studentSetupProfileStep2,
        (route) => false,
        arguments: StudentSetupArgs(
          university: univ,
          major: major,
          studentIdNumber: nim,
          ktmFileName: _ktmFileName,
          isAuthenticated: true,
        ),
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
            content: Text('Pendaftaran gagal diproses. Periksa koneksi Anda.'),
          ),
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
