import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class RewardItem {
  final String title;
  final String provider;
  final int tcPrice;
  final IconData icon;

  RewardItem({
    required this.title,
    required this.provider,
    required this.tcPrice,
    required this.icon,
  });
}

class RewardHubScreen extends StatefulWidget {
  const RewardHubScreen({super.key});

  @override
  State<RewardHubScreen> createState() => _RewardHubScreenState();
}

class _RewardHubScreenState extends State<RewardHubScreen> {
  int _userTcBalance = 150;

  final List<RewardItem> _rewards = [
    RewardItem(
      title: 'Free Coffee',
      provider: 'Kopi Tepi Kali',
      tcPrice: 15,
      icon: Icons.local_cafe_outlined,
    ),
    RewardItem(
      title: 'E-Wallet Cash\nRp25.000',
      provider: 'GoPay / OVO',
      tcPrice: 25,
      icon: Icons.account_balance_wallet_outlined,
    ),
    RewardItem(
      title: 'Kelas online Flutter',
      provider: 'Mitra edukasi',
      tcPrice: 60,
      icon: Icons.menu_book_outlined,
    ),
    RewardItem(
      title: 'Cetak skripsi 1\neksemplar',
      provider: 'Fotokopi Ketintang',
      tcPrice: 40,
      icon: Icons.print_outlined,
    ),
    RewardItem(
      title: 'Paket makan siang',
      provider: 'Sambal Mbok Jum',
      tcPrice: 20,
      icon: Icons.lunch_dining_outlined,
    ),
    RewardItem(
      title: 'Sertifikat\nkompetensi',
      provider: 'TalentSync',
      tcPrice: 75,
      icon: Icons.military_tech_outlined,
    ),
  ];

  void _redeemReward(RewardItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color: AppColors.primaryNavy,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.replaceAll('\n', ' '),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        Text(
                          item.provider,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.canvasWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Biaya Penukaran:',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.toll_rounded,
                          color: AppColors.accentAmberGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.tcPrice} TC',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (_userTcBalance >= item.tcPrice) {
                    setState(() {
                      _userTcBalance -= item.tcPrice;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Voucher "${item.title.replaceAll('\n', ' ')}" berhasil ditukar!',
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saldo TimeCoin tidak mencukupi.'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Tukarkan Reward Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(RewardItem item) {
    return GestureDetector(
      onTap: () => _redeemReward(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightBlueSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: AppColors.primaryNavy, size: 22),
            ),
            const SizedBox(height: 12),
            // Title & Provider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.provider,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondarySlate,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Price Tag
            Row(
              children: [
                const Icon(
                  Icons.toll_rounded,
                  color: AppColors.accentAmberGold,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.tcPrice} TC',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavFloating(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.studentDashboard,
              ),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.explore_outlined,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.submission),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.assignment_outlined,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.portfolio),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.secondarySlate,
                  size: 24,
                ),
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
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: AppColors.darkSlate,
                            size: 24,
                          ),
                        ),
                      ),
                      const Text(
                        'Reward Hub',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.toll_rounded,
                              color: AppColors.accentAmberGold,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_userTcBalance TC',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2-Column Grid of Rewards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rewards.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.88,
                        ),
                    itemBuilder: (context, index) {
                      return _buildRewardCard(_rewards[index]);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Floating Navigation
          _buildBottomNavFloating(context),
        ],
      ),
    );
  }
}
