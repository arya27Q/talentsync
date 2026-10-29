import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';

class BookingSessionScreen extends StatelessWidget {
  const BookingSessionScreen({super.key});

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

  Widget _buildBubble(String text, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(color: Color(0xFF7B1FA2), shape: BoxShape.circle),
              child: const Center(child: Text('BS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryTan : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  if (!isMe)
                    BoxShadow(color: AppColors.darkBrown.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                text,
                style: TextStyle(color: isMe ? Colors.white : AppColors.darkBrown, fontSize: 14, height: 1.4),
              ),
            ),
          ),
        ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                            'Mentoring Session',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                          ),
                        ],
                      ),
                      const Icon(Icons.videocam_rounded, color: AppColors.darkBrown),
                    ],
                  ),
                ),

                // Timer Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF8C5E3C).withValues(alpha: 0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8C5E3C).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text('Session in Progress', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('45:00', style: TextStyle(color: Color(0xFF8C5E3C), fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      Text('mins remaining', style: TextStyle(color: Color(0xFF8C5E3C), fontSize: 12)),
                    ],
                  ),
                ),

                // Chat
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildBubble('Hi Arya, how can I help you today with your Flutter architecture?', false),
                      _buildBubble('Hello Pak Budi! I am confused about where to put my business logic in Feature-First approach.', true),
                      _buildBubble('No problem! Let\'s start a quick video call so I can share my screen.', false),
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
