import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';
import 'transfer_screen.dart';

class WalletDashboardScreen extends StatelessWidget {
  const WalletDashboardScreen({super.key});

  Widget _buildTransaction(String title, String date, String amount, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isPositive ? const Color(0xFF388E3C) : const Color(0xFFD32F2F),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkBrown)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            isPositive ? '+$amount TC' : '-$amount TC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isPositive ? const Color(0xFF388E3C) : const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Time Wallet',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
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
                  child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.rewardHub),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.card_giftcard_rounded, color: Color(0xFFFF8F00), size: 16),
                              SizedBox(width: 8),
                              Text('Rewards', style: TextStyle(color: Color(0xFFFF8F00), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
              children: [
                // E-Wallet Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D332D), Color(0xFF2D1E1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4D332D).withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB300), size: 36),
                          SizedBox(width: 8),
                          Text('125.00', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()));
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
                const SizedBox(height: 16),
                
                _buildTransaction('Project: E-commerce Redesign', 'Today, 10:42 AM', '15', true),
                _buildTransaction('Transfer to Mentorship', 'Yesterday, 14:20 PM', '5', false),
                _buildTransaction('Project: Company Profile', 'Oct 12, 2026', '20', true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
