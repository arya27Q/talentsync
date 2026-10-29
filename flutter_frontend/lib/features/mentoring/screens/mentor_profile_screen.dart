import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class MentorProfileScreen extends StatelessWidget {
  const MentorProfileScreen({super.key});

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
            _buildNavItem(Icons.people_rounded),
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
              padding: const EdgeInsets.only(bottom: 180),
              child: Column(
                children: [
                  // Header
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
                          'Mentor Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                      ],
                    ),
                  ),

                  // Profile Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7B1FA2).withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: const Icon(Icons.person_rounded, color: Color(0xFF7B1FA2), size: 50),
                        ),
                        const SizedBox(height: 16),
                        const Text('Budi Santoso', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                        const SizedBox(height: 4),
                        const Text('Senior Mobile Developer @ Gojek', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat('Rating', '4.9/5.0'),
                            Container(width: 1, height: 40, color: AppColors.warmOffWhite),
                            _buildStat('Teaching', '120 hrs'),
                            Container(width: 1, height: 40, color: AppColors.warmOffWhite),
                            _buildStat('Students', '45+'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Skills & About
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expertise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildSkillTag('Flutter & Dart'),
                            _buildSkillTag('Clean Architecture'),
                            _buildSkillTag('Firebase'),
                            _buildSkillTag('System Design'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
                        const SizedBox(height: 12),
                        Text(
                          'I have over 7 years of experience building scalable mobile applications. I specialize in Flutter and have led multiple teams. Happy to help you with code reviews, architecture planning, and career advice.',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Book Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 110,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.mentorChat);
              },
              child: Container(
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
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Book for 3 TC / hr',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          
          _buildBottomNavBarDummy(context),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSkillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryTan)),
    );
  }
}
