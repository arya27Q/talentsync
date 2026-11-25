import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/admin/data/admin_api.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key, this.adminApi});

  final AdminApi? adminApi;

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  static const Color _softCanvas = Color(0xFFF4F7FB);
  static const Color _softBorder = Color(0xFFE6EDF6);
  static const Color _captionSlate = Color(0xFF475569);

  late final AdminApi _api = widget.adminApi ?? AdminApi.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final admin = await _api.currentAdminSession();
      if (!mounted || admin == null) return;
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } catch (_) {
      // Ignore storage read errors in test or restricted environments.
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _api.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Tidak dapat terhubung ke server Laravel. Pastikan backend aktif di port 8000.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softCanvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 880;
            if (!isWide) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _buildLoginCard(),
                  ),
                ),
              );
            }

            return Row(
              children: [
                Expanded(flex: 5, child: _buildBrandShowcasePanel()),
                Expanded(
                  flex: 6,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(36),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _buildLoginCard(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandShowcasePanel() {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 36,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentAmberGold.withValues(alpha: 0.12),
                  width: 32,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 36),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.accentAmberGold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'TalentSync',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Pusat Kendali Ekosistem 3 POV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kelola verifikasi pengguna, persetujuan pencairan dana, mediasi sengketa, dan audit buku besar TimeCoin dari satu ruang kerja terpusat.',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _featureLine(
                      Icons.verified_user_rounded,
                      'Verifikasi Mahasiswa, Mitra UMKM, dan Peer Mentor',
                    ),
                    const SizedBox(height: 14),
                    _featureLine(
                      Icons.fact_check_rounded,
                      'Persetujuan Cash-Out & Langganan Mentor Premium',
                    ),
                    const SizedBox(height: 14),
                    _featureLine(
                      Icons.account_balance_wallet_rounded,
                      'Transparansi Smart Escrow & Mutasi Buku Besar TimeCoin',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureLine(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.accentAmberGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primaryNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TalentSync Admin',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'Masuk untuk mengelola operasional',
                        style: TextStyle(fontSize: 12.5, color: _captionSlate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFB91C1C),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Email Administrator',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                'admin@talentsync.id',
                Icons.mail_outline_rounded,
              ),
              validator: (val) {
                final v = (val ?? '').trim();
                if (v.isEmpty || !v.contains('@')) {
                  return 'Masukkan email administrator yang valid.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Kata Sandi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration:
                  _inputDecoration(
                    'Masukkan kata sandi',
                    Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Tampilkan sandi'
                          : 'Sembunyikan sandi',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _captionSlate,
                      ),
                    ),
                  ),
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Masukkan kata sandi.' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Masuk ke Portal Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sesi administrator dilindungi autentikasi token Sanctum dengan otorisasi peran khusus.',
              style: TextStyle(
                fontSize: 11.5,
                color: _captionSlate,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 19, color: _captionSlate),
        filled: true,
        fillColor: _softCanvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryNavy,
            width: 1.5,
          ),
        ),
      );
}
