import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class PortfolioDashboardScreen extends StatelessWidget {
  const PortfolioDashboardScreen({super.key});

  Widget _buildProjectCard(BuildContext context, String title, String role, String rating) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.caseStudy),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFF8F00))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkBrown), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(role, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                              child: const Icon(Icons.keyboard_arrow_left_rounded, color: AppColors.darkBrown),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'My Portfolio',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                          ),
                        ],
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
                        child: const Icon(Icons.share_rounded, color: AppColors.darkBrown, size: 20),
                      ),
                    ],
                  ),
                ),

                // Spider Graph Mock (Tech Stack)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                      const Text('Skill Matrix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
                      const SizedBox(height: 24),
                      // Mocking spider graph with a customized icon layout
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.warmOffWhite, width: 2),
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.warmOffWhite, width: 2),
                              ),
                            ),
                            Icon(Icons.polyline_rounded, size: 100, color: AppColors.primaryTan.withValues(alpha: 0.5)),
                            const Positioned(top: 0, child: Text('UI/UX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            const Positioned(bottom: 0, child: Text('Dev', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            const Positioned(left: 0, child: Text('Copy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            const Positioned(right: 0, child: Text('SEO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Grid of Completed Projects
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Completed Projects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildProjectCard(context, 'E-commerce Redesign', 'UI/UX Designer', '5.0'),
                      _buildProjectCard(context, 'Social Media Campaign', 'Copywriter', '4.8'),
                      _buildProjectCard(context, 'Company Profile Web', 'Web Dev', '4.9'),
                    ],
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
}
