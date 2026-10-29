import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class StudentSetupProfileScreen extends StatelessWidget {
  const StudentSetupProfileScreen({super.key});

  Widget _buildSkillChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryTan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTan, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.primaryTan, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          const Icon(Icons.close, size: 16, color: AppColors.primaryTan),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: maxLines == 1 ? Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, color: AppColors.primaryTan),
          ) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(maxLines == 1 ? 16 : 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Floating Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkBrown.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, color: AppColors.darkBrown),
                      SizedBox(width: 12),
                      Text(
                        'Setup Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Upload Photo
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryTan.withValues(alpha: 0.2),
                        child: const Icon(Icons.person, size: 50, color: AppColors.primaryTan),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.darkBrown,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Inputs
                _buildInputField('Program Studi (ex: Information Systems)', Icons.school_outlined),
                _buildInputField('Tahun Kelulusan (ex: 2026)', Icons.calendar_today_outlined),
                _buildInputField('Tulis bio singkat tentang dirimu...', Icons.edit, maxLines: 4),
                
                const Text(
                  'Top Skills',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                ),
                const SizedBox(height: 12),
                
                // Floating Tag Container
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkBrown.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Wrap(
                    children: [
                      _buildSkillChip('Information Systems'),
                      _buildSkillChip('Flutter'),
                      _buildSkillChip('Laravel'),
                      _buildSkillChip('UI/UX Design'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                // Finish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTan,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 5,
                      shadowColor: AppColors.primaryTan.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Finish Setup',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
