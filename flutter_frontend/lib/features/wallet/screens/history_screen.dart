import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.warmOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildTransaction('Project: E-commerce Redesign', 'Today, 10:42 AM', '15', true),
          _buildTransaction('Transfer to Mentorship', 'Yesterday, 14:20 PM', '5', false),
          _buildTransaction('Project: Company Profile', 'Oct 12, 2026', '20', true),
          _buildTransaction('Digitalise UMK Batik', 'Oct 10, 2026', '30', true),
          _buildTransaction('Transfer to Design Help', 'Oct 05, 2026', '10', false),
        ],
      ),
    );
  }

  Widget _buildTransaction(String title, String date, String amount, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}$amount TC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }
}
