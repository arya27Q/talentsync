import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class FindMentorsScreen extends StatelessWidget {
  const FindMentorsScreen({super.key});

  Widget _buildMentorCard(BuildContext context, String name, String role, String company, String rating) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.mentorProfile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF7B1FA2), size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkBrown)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                          const SizedBox(width: 4),
                          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFF8F00))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$role @ $company', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag('Flutter'),
                      _buildTag('Firebase'),
                      _buildTag('Clean Arch'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryTan),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Book Session', style: TextStyle(color: AppColors.primaryTan, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warmOffWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
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
                  'Mentors',
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
                  child: const Icon(Icons.tune_rounded, color: AppColors.darkBrown, size: 20),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
              children: [
                _buildMentorCard(context, 'Budi Santoso', 'Senior Dev', 'Gojek', '4.9'),
                _buildMentorCard(context, 'Siti Aminah', 'UI/UX Lead', 'Tokopedia', '5.0'),
                _buildMentorCard(context, 'Andi Wijaya', 'Product Manager', 'Traveloka', '4.8'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
