import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  Widget _buildChatItem(BuildContext context, String name, String message, String time, int unreadCount, Color avatarColor, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.workspaceChat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: avatarColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: avatarColor, size: 24),
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
                          name, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkBrown)
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time, style: TextStyle(color: unreadCount > 0 ? AppColors.primaryTan : Colors.grey, fontSize: 12, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0 ? AppColors.darkBrown : Colors.grey.shade600,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTan,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
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
      backgroundColor: AppColors.warmOffWhite,
      body: SafeArea(
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
                    'Inbox',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 12),
                    Text('Search messages...', style: TextStyle(color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
            
            // Chat List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('Active Projects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildChatItem(context, 'Toko Makmur (E-Commerce)', 'Bro, desain bannernya udah jadi?', '10:42 AM', 2, const Color(0xFF1976D2), Icons.store_rounded),
                  _buildChatItem(context, 'PT Angkasa (Company Profile)', 'Tolong revisi fontnya dikit ya.', 'Yesterday', 0, const Color(0xFF388E3C), Icons.business_rounded),
                  
                  const SizedBox(height: 24),
                  const Text('Mentors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _buildChatItem(context, 'Budi Santoso', 'Besok kita mulai sesi jam 8 pagi ya.', 'Yesterday', 1, const Color(0xFF7B1FA2), Icons.person_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
