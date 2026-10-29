import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  bool _isMentorMode = false;

  Widget _buildMenuItem(IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.darkBrown, size: 24),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown, fontSize: 16)),
            ],
          ),
          trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
              children: [
                // Profile Card
                Container(
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
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF388E3C).withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF388E3C), size: 40),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Arya', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                            const SizedBox(height: 4),
                            const Text('Information Systems', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, color: Color(0xFFF57C00), size: 14),
                                  SizedBox(width: 4),
                                  Text('Top Talent', style: TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.portfolio),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBrown,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('View Public Portfolio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                // Switch Mode
                _buildMenuItem(
                  Icons.switch_account_rounded,
                  'Switch to Mentor Mode',
                  trailing: Switch(
                    value: _isMentorMode,
                    activeThumbColor: AppColors.primaryTan,
                    onChanged: (val) {
                      setState(() {
                        _isMentorMode = val;
                      });
                    },
                  ),
                ),
                
                _buildMenuItem(Icons.edit_rounded, 'Edit Profile', onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile)),
                _buildMenuItem(Icons.security_rounded, 'Privacy & Security', onTap: () => Navigator.pushNamed(context, AppRoutes.privacySecurity)),
                _buildMenuItem(Icons.help_outline_rounded, 'Help & Support', onTap: () => Navigator.pushNamed(context, AppRoutes.helpSupport)),
                _buildMenuItem(Icons.logout_rounded, 'Logout', onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.roleSelection, (route) => false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
