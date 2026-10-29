import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
    required String desc,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : AppColors.warmOffWhite,
        borderRadius: BorderRadius.circular(24),
        border: isUnread ? Border.all(color: AppColors.primaryTan.withValues(alpha: 0.3)) : null,
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: AppColors.darkBrown.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkBrown),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
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
            _buildNavItem(Icons.home_rounded, context),
            _buildNavItem(Icons.search_rounded, context),
            _buildNavItem(Icons.assignment_rounded, context),
            _buildNavItem(Icons.account_balance_wallet_rounded, context),
            _buildNavItem(Icons.person_rounded, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.grey.shade400,
        size: 26,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
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
                        'Notifications',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 120),
                    children: [
                      const Text('TODAY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 16),
                      _buildNotificationItem(
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF388E3C),
                        iconBg: const Color(0xFFE8F5E9),
                        title: 'Application Accepted!',
                        time: '10 mins ago',
                        desc: 'Batik Nusantara has accepted your application for Redesign Landing Page. Click here to open workspace.',
                        isUnread: true,
                      ),
                      _buildNotificationItem(
                        icon: Icons.message_rounded,
                        iconColor: const Color(0xFF1976D2),
                        iconBg: const Color(0xFFE3F2FD),
                        title: 'New Message',
                        time: '1 hour ago',
                        desc: 'Pak Budi from Cafe Rindu sent you a message: "Can we have a meeting this afternoon?"',
                        isUnread: true,
                      ),
                      const SizedBox(height: 16),
                      const Text('YESTERDAY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 16),
                      _buildNotificationItem(
                        icon: Icons.monetization_on_rounded,
                        iconColor: const Color(0xFFF57C00),
                        iconBg: const Color(0xFFFFF3E0),
                        title: 'Payment Received',
                        time: '1 day ago',
                        desc: 'You received 5 TC from Toko Sepatu Juara for project Copywriting.',
                        isUnread: false,
                      ),
                      _buildNotificationItem(
                        icon: Icons.system_update_rounded,
                        iconColor: AppColors.darkBrown,
                        iconBg: Colors.white,
                        title: 'System Update',
                        time: '1 day ago',
                        desc: 'SkillSwap v2.0 is out! Check out the new collaboration features.',
                        isUnread: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          _buildBottomNavBarDummy(context),
        ],
      ),
    );
  }
}
