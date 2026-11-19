import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';

class MentorAuthScreen extends StatefulWidget {
  const MentorAuthScreen({super.key});

  @override
  State<MentorAuthScreen> createState() => _MentorAuthScreenState();
}

class _MentorAuthScreenState extends State<MentorAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authApi = AuthApi();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty) {
      AppStatusDialog.showError(
        context,
        title: 'Akun Belum Terdaftar',
        message:
            'Akun belum terdaftar. Silakan lakukan pendaftaran terlebih dahulu.',
        buttonText: 'Daftar Sekarang',
        onConfirm: () =>
            Navigator.pushNamed(context, AppRoutes.mentorRegister),
      );
      return;
    }
    if (password.isEmpty) {
      AppStatusDialog.showError(
        context,
        title: 'Kata Sandi Salah',
        message: 'Kata sandi yang Anda masukkan salah. Harap periksa kembali.',
        buttonText: 'Coba Lagi',
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _authApi.login(
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (user['role'] != 'mentor') {
        await _authApi.logout();
        if (!mounted) return;
        AppStatusDialog.showError(
          context,
          title: 'Akses Ditolak',
          message:
              'Akun ini bukan akun Mentor. Silakan gunakan portal masuk sesuai peran Anda (Mahasiswa atau Mitra UMKM).',
          buttonText: 'Pilih Peran Lain',
          onConfirm: () => AppRoutes.popOrRoleSelection(context),
        );
        return;
      }

      await AppStatusDialog.showSuccess(
        context,
        title: 'Berhasil Masuk!',
        message: 'Selamat datang kembali di Portal Mentor TalentSync.',
        buttonText: 'Buka Dashboard',
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mentorDashboard,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        final isNotRegistered =
            error.message.toLowerCase().contains('belum terdaftar') ||
            (error.errors != null && error.errors!.containsKey('email'));
        if (isNotRegistered) {
          AppStatusDialog.showError(
            context,
            title: 'Akun Belum Terdaftar',
            message:
                'Akun belum terdaftar. Silakan lakukan pendaftaran terlebih dahulu.',
            buttonText: 'Daftar Sekarang',
            onConfirm: () =>
                Navigator.pushNamed(context, AppRoutes.mentorRegister),
          );
        } else {
          final isPasswordWrong =
              error.message.toLowerCase().contains('kata sandi') ||
              error.message.toLowerCase().contains('password') ||
              (error.errors != null && error.errors!.containsKey('password'));
          AppStatusDialog.showError(
            context,
            title: isPasswordWrong ? 'Kata Sandi Salah' : 'Gagal Masuk',
            message: isPasswordWrong
                ? 'Kata sandi yang Anda masukkan salah. Harap periksa kembali.'
                : error.message,
            buttonText: 'Coba Lagi',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        AppStatusDialog.showError(
          context,
          title: 'Kendala Koneksi',
          message:
              'Login gagal diproses. Periksa koneksi internet Anda dan coba kembali.',
          buttonText: 'Mengerti',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _forgotPassword() {
    AppStatusDialog.show(
      context,
      type: AppStatusDialogType.info,
      title: 'Reset Kata Sandi',
      message:
          'Masukkan alamat email terdaftar melalui layanan bantuan TalentSync untuk menerima tautan pemulihan kata sandi akun mentor.',
      primaryButtonText: 'Mengerti',
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: Navigator.canPop(context),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        AppRoutes.popOrRoleSelection(context);
      }
    },
    child: Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        title: const Text(
          'Portal Mentor',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.darkSlate,
          ),
        ),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => AppRoutes.popOrRoleSelection(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkSlate,
          ),
        ),
      ),
    body: SafeArea(
      top: false,
      child: AbsorbPointer(
        absorbing: _isLoading,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: AppColors.primaryNavy,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Masuk sebagai Mentor',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Atur jadwal sesi dan pantau perkembangan murid.',
                    style: TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _FieldLabel('Email'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      Icons.mail_outline_rounded,
                      'nama@email.com',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('Kata sandi'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _signIn(),
                    decoration:
                        _inputDecoration(
                          Icons.lock_outline_rounded,
                          'Minimal 8 karakter',
                        ).copyWith(
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Lupa kata sandi?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _isLoading
                            ? AppColors.primaryNavy.withValues(alpha: 0.85)
                            : AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Memverifikasi Mentor...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Masuk Sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.borderSlate)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau',
                          style: TextStyle(color: AppColors.secondarySlate),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.borderSlate)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.mentorRegister,
                      ),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text(
                        'Daftar jadi Mentor (Unggah Portofolio)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderSlate),
                        foregroundColor: AppColors.darkSlate,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    ),
  );

  InputDecoration _inputDecoration(
    IconData icon,
    String hint,
  ) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.secondarySlate, fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.secondarySlate),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.borderSlate),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.borderSlate),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.darkSlate,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
