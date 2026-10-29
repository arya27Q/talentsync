import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import '../../wallet/screens/transfer_screen.dart';
import '../../wallet/screens/history_screen.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class DashboardMahasiswaScreen extends StatelessWidget {
  const DashboardMahasiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.warmOffWhite,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 120,
          ), // padding for floating nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // White Floating Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkBrown.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Good morning ',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 16),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildHeaderIcon(context, Icons.chat_bubble_outline_rounded, route: AppRoutes.inbox),
                        const SizedBox(width: 12),
                        _buildHeaderIcon(context, Icons.notifications_none_rounded, route: AppRoutes.notifications),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // E-Wallet Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8C5E3C),
                            Color(0xFF4D332D),
                          ], // Lighter brown to dark brown
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4D332D)
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TimeCoin Balance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        '10',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 6.0),
                                        child: Text(
                                          'TC',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '≈Rp 50,000 in rewards value',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.monetization_on_rounded,
                                  color: AppColors.primaryTan,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildWalletButton('Transfer', onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()));
                                }),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildWalletButton('History', onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.rocket_launch_rounded,
                            const Color(0xFFE57373),
                            '2',
                            'Active',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.verified_rounded,
                            const Color(0xFF81C784),
                            '8',
                            'Completed',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            Icons.workspace_premium_rounded,
                            const Color(0xFFFFD54F),
                            '4.8',
                            'Rating',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recommended Projects Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Recommended Projects',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        Text(
                          'See All →',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTan.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recommended Projects Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    _buildRecommendedCard(
                      'Web Dev',
                      '5 TC',
                      'Redesign Landing Page',
                      'Kopitiam Sari',
                      'Due in 3 days',
                      true,
                    ),
                    _buildRecommendedCard(
                      'Barter',
                      '',
                      'Social Media Content',
                      'Batik Nusantara',
                      'Due in 5 days',
                      false,
                    ),
                    _buildRecommendedCard(
                      'Design',
                      '3 TC',
                      'Logo Remake',
                      'Warung Bu Ani',
                      'Due in 2 days',
                      true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // In Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Workspace',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInProgressCard(context, 
                      'Digitalisasi UMKM Batik Solo',
                      'Batik Nusantara',
                      '5 TC',
                      0.68,
                      '68% complete',
                      '5 days left',
                    ),
                    _buildInProgressCard(context, 
                      'Update Katalog Produk',
                      'Toko Kue Enak',
                      'Barter',
                      0.25,
                      '25% complete',
                      '2 days left',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, {String? route}) {
    return GestureDetector(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.warmOffWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.darkBrown, size: 20),
      ),
    );
  }

  Widget _buildWalletButton(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(
    String category,
    String reward,
    String title,
    String client,
    String due,
    bool isTc,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmOffWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              if (reward.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isTc
                        ? const Color(0xFFB88656)
                        : AppColors.warmOffWhite,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reward,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isTc ? Colors.white : AppColors.darkBrown,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            client,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Text(due, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInProgressCard(BuildContext context, 
    String title,
    String client,
    String reward,
    double progress,
    String progressText,
    String timeLeft,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.workspaceKanban),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryTan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: reward == 'Barter'
                        ? AppColors.warmOffWhite
                        : const Color(0xFFB88656),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reward,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: reward == 'Barter'
                          ? AppColors.darkBrown
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Progress bar
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.warmOffWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (progress * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8C5E3C), // Solid brown
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ((1 - progress) * 100).toInt(),
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progressText,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  timeLeft,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
