import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Arya Pratama');
  final TextEditingController _headlineController = TextEditingController(text: 'Flutter Developer');
  final TextEditingController _bioController = TextEditingController(
    text: 'Mahasiswa Sistem Informasi yang suka membangun aplikasi mobile untuk usaha kecil.',
  );
  final TextEditingController _linkedInController = TextEditingController(
    text: 'https://linkedin.com/in/arya-pratama',
  );
  final TextEditingController _gitHubController = TextEditingController(
    text: 'https://github.com/aryapratama',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _linkedInController.dispose();
    _gitHubController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan profil berhasil disimpan!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.darkSlate,
            ),
            decoration: InputDecoration(
              icon: Icon(prefixIcon, color: AppColors.secondarySlate, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 12 : 14),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildBottomNavFloating(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.explore_outlined, color: AppColors.secondarySlate, size: 24),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.submission),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.assignment_outlined, color: AppColors.secondarySlate, size: 24),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.wallet),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.secondarySlate, size: 24),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: AppColors.darkSlate,
                            size: 24,
                          ),
                        ),
                      ),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      GestureDetector(
                        onTap: _saveProfile,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar with Camera Badge
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: const Center(
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.accentAmberGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ketuk ikon kamera untuk mengganti foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Informasi dasar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkSlate.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi dasar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nama Lengkap
                        _buildFormField(
                          label: 'Nama lengkap',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                        ),

                        // Headline
                        _buildFormField(
                          label: 'Headline',
                          controller: _headlineController,
                          prefixIcon: Icons.badge_outlined,
                        ),

                        // Bio
                        _buildFormField(
                          label: 'Bio',
                          controller: _bioController,
                          prefixIcon: Icons.notes_rounded,
                          maxLines: 3,
                        ),

                        // Locked Campus Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.canvasWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlueSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.school_outlined,
                                  color: AppColors.primaryNavy,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Universitas Negeri Surabaya',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'S1 Sistem Informasi · NIM terverifikasi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.secondarySlate,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // LinkedIn
                        _buildFormField(
                          label: 'LinkedIn',
                          controller: _linkedInController,
                          prefixIcon: Icons.business_center_outlined,
                        ),

                        // GitHub
                        _buildFormField(
                          label: 'GitHub',
                          controller: _gitHubController,
                          prefixIcon: Icons.terminal_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Floating Navigation
          _buildBottomNavFloating(context),
        ],
      ),
    );
  }
}
