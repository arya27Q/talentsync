import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/features/gamification/widgets/achievement_popup.dart';

class SubmissionScreen extends StatelessWidget {
  const SubmissionScreen({super.key});

  Widget _buildInput(String label, String hint, {int maxLines = 1, IconData? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              suffixIcon: suffix != null ? Icon(suffix, color: Colors.grey) : null,
              contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 16 : 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBarDummy(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_rounded),
            _buildNavItem(Icons.search_rounded),
            _buildNavItem(Icons.assignment_rounded),
            _buildNavItem(Icons.account_balance_wallet_rounded),
            _buildNavItem(Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.grey.shade400, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floating Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warmOffWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.keyboard_arrow_left_rounded, color: AppColors.darkBrown),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Submit Work',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Final Submission',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please provide the final deliverables and log your time below.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildInput('Project Link (Figma, GitHub, etc)', 'https://...', suffix: Icons.link_rounded),
                        const SizedBox(height: 20),
                        
                        _buildInput('Time Logged (Hours)', 'e.g. 15', suffix: Icons.access_time_rounded),
                        const SizedBox(height: 20),
                        
                        _buildInput('Message to MSME (Optional)', 'Write a short message...', maxLines: 4),
                        
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        GestureDetector(
                          onTap: () {
                            AchievementPopup.show(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB88656), Color(0xFF8C5E3C)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8C5E3C).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Submit to MSME',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          _buildBottomNavBarDummy(context),
        ],
      ),
    );
  }
}
