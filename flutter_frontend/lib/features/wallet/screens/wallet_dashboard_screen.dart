import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  void _showTopUpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              const Text(
                'Isi Ulang TimeCoin (Top Up)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Konversi resmi: 1 TC ≈ Rp1.000. Pilih paket TimeCoin yang ingin dibeli.',
                style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildTopUpOption(ctx, '50 TC', 'Rp50.000'),
                  const SizedBox(width: 10),
                  _buildTopUpOption(ctx, '100 TC', 'Rp100.000'),
                  const SizedBox(width: 10),
                  _buildTopUpOption(ctx, '200 TC', 'Rp200.000'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopUpOption(BuildContext ctx, String tc, String price) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permintaan Top Up $tc ($price) sedang diproses.'),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.canvasWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            children: [
              Text(
                tc,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCashOutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              const Text(
                'Pencairan Saldo (Cash-out)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bebas biaya admin (0%) untuk mahasiswa! Dana akan ditransfer ke rekening bank Anda.',
                style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.canvasWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primaryNavy,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank Central Asia (BCA)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '8291029102 · Arya Pratama',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondarySlate,
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
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pengajuan pencairan 150 TC (Rp150.000) berhasil dikirim.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Cairkan 150 TC ke Rekening',
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

  Widget _buildQuickCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFB45309), size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.lightGreenSurface
                  : AppColors.canvasWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive
                  ? Icons.call_received_rounded
                  : Icons.call_made_rounded,
              color: isPositive
                  ? AppColors.successGreen
                  : AppColors.secondarySlate,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.successGreen : AppColors.darkSlate,
            ),
          ),
        ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Time Wallet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: AppColors.darkSlate,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero Navy Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total TimeCoin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.toll_rounded,
                              color: AppColors.accentAmberGold,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '150 TC',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '≈ Rp150.000',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total masuk',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '+130 TC',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total keluar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '-80 TC',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons Row (Top Up & Cash-out)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTopUpModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryNavy.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Top Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showCashOutModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderSlate),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSlate.withValues(
                                    alpha: 0.03,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppColors.darkSlate,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Cash-out',
                                  style: TextStyle(
                                    color: AppColors.darkSlate,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Navigation Cards (Reward, Cari Mentor, Mentor Saya)
                  Row(
                    children: [
                      _buildQuickCard(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Reward',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.rewardHub),
                      ),
                      const SizedBox(width: 10),
                      _buildQuickCard(
                        icon: Icons.school_outlined,
                        label: 'Cari Mentor',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.findMentors),
                      ),
                      const SizedBox(width: 10),
                      _buildQuickCard(
                        icon: Icons.menu_book_outlined,
                        label: 'Mentor Saya',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookingSession,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Section Riwayat Transaksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat transaksi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Transaction List
                  _buildTransactionItem(
                    title: 'Proyek sistem reservasi',
                    subtitle: 'Warung Pak Gito · 2 Jun',
                    amount: '+80 TC',
                    isPositive: true,
                  ),
                  _buildTransactionItem(
                    title: 'Sesi mentoring Flutter',
                    subtitle: 'Dimas Prasetyo · 8 Jun',
                    amount: '-30 TC',
                    isPositive: false,
                  ),
                  _buildTransactionItem(
                    title: 'Pencairan ke BCA',
                    subtitle: 'Biaya admin Rp0 · 3 Jun',
                    amount: '-50 TC',
                    isPositive: false,
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
