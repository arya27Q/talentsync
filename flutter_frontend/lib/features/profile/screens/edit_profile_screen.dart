import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _linkedInController = TextEditingController(
    text: 'linkedin.cosantosom/in/budi ',
  );
  final TextEditingController _gitHubController = TextEditingController(
    text: 'budi',
  );
  final TextEditingController _skillInputController = TextEditingController();

  final List<String> _skills = ['Flutter', 'Laravel', 'MySQL', 'Dart', 'Figma'];

  bool _isPublicProfil = true;
  bool _isOpenForProjects = true;

  @override
  void dispose() {
    _linkedInController.dispose();
    _gitHubController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _skillInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _saveProfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan profil berhasil disimpan!'),
        backgroundColor: AppColors.darkSlate,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
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
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.studentDashboard,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.explore_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.submission),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.assignment_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.wallet),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
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
                    'Profil',
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: AppColors.darkSlate,
                            size: 24,
                          ),
                        ),
                      ),
                      const Text(
                        'Edit Profil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      GestureDetector(
                        onTap: _saveProfil,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // LinkedIn Field
                  const Text(
                    'LinkedIn',
                    style: TextStyle(
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
                      controller: _linkedInController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkSlate,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.link_rounded,
                          color: AppColors.secondarySlate,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Username GitHub Field
                  const Text(
                    'Username GitHub',
                    style: TextStyle(
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
                      controller: _gitHubController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkSlate,
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.code_rounded,
                          color: AppColors.secondarySlate,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Card Keahlian
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                          'Keahlian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Keahlian jadi terverifikasi setelah divalidasi proyek, mentor, atau GitHub.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Skill Chips List
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    skill,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _removeSkill(skill),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 15,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Input Tambah Keahlian + Button
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: TextField(
                                  controller: _skillInputController,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkSlate,
                                  ),
                                  onSubmitted: (_) => _addSkill(),
                                  decoration: const InputDecoration(
                                    hintText: 'Tambah keahlian',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondarySlate,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _addSkill,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNavy,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Toggles (Profil publik & Terbuka untuk proyek)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      children: [
                        // Toggle 1: Profil publik
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Profil publik',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'UMKM dan rekruter bisa melihat CV lewat link',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPublicProfil,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.primaryNavy,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                              onChanged: (val) {
                                setState(() {
                                  _isPublicProfil = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderSlate, height: 1),
                        const SizedBox(height: 12),

                        // Toggle 2: Terbuka untuk proyek
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Terbuka untuk proyek',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tampilkan status siap kerja di profil',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isOpenForProjects,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.primaryNavy,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                              onChanged: (val) {
                                setState(() {
                                  _isOpenForProjects = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button Simpan Perubahan
                  GestureDetector(
                    onTap: _saveProfil,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
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
