import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class StudentAuthScreen extends StatefulWidget {
  const StudentAuthScreen({super.key});

  @override
  State<StudentAuthScreen> createState() => _StudentAuthScreenState();
}

class _StudentAuthScreenState extends State<StudentAuthScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _nimController = TextEditingController(
    text: '24051214017',
  );
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Back & Title Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
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
                      child: Text(
                        'Portal Mahasiswa',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Cap Icon Squircle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.badge_rounded,
                      color: AppColors.primaryNavy,
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Heading
                const Text(
                  'Masuk dengan KTM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gunakan Nomor Induk Mahasiswa (NIM) / Nomor KTM yang terverifikasi untuk mengakses proyek dan mentoring.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondarySlate,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                // Form Field 1: NIM / Nomor KTM
                const Text(
                  'Nomor Induk Mahasiswa (NIM) / Nomor KTM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: TextField(
                    controller: _nimController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 24051214017',
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.badge_rounded,
                        color: AppColors.secondarySlate,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Form Field 2: Kata Sandi
                const Text(
                  'Kata sandi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkSlate,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi akun',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.secondarySlate,
                        size: 20,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.secondarySlate,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Lupa kata sandi
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Silakan hubungi administrator kampus / Pusat Bantuan untuk reset PIN/kata sandi.',
                          ),
                          backgroundColor: AppColors.darkSlate,
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Primary CTA: Masuk Sekarang
                GestureDetector(
                  onTap: _isLoading ? null : _onSignIn,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? AppColors.primaryNavy.withValues(alpha: 0.85)
                          : AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
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
                                  'Memverifikasi Mahasiswa...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Masuk Sekarang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Divider "atau"
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: AppColors.borderSlate),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'atau',
                        style: TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: AppColors.borderSlate),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Secondary: Verifikasi & Aktivasi dengan Foto KTM
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.studentSetupProfile);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_rounded,
                            color: AppColors.primaryNavy,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Aktivasi Akun Baru dengan Foto KTM',
                                style: TextStyle(
                                  color: AppColors.darkSlate,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Footnote
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Verifikasi KTM resmi untuk perlindungan Smart Escrow 0% biaya',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
