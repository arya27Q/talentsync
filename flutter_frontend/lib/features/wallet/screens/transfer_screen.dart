import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('Transfer TimeCoin', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.warmOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkBrown),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount to Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0 TC',
                prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppColors.primaryTan),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryTan, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recipient Username / Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: '@username',
                prefixIcon: const Icon(Icons.person, color: AppColors.primaryTan),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryTan, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Implement transfer logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Send Transfer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
