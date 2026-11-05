import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_cashout_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';

class MentorWalletScreen extends StatefulWidget {
  const MentorWalletScreen({
    super.key,
    required this.availableTc,
    this.onSelectTab,
  });

  final ValueNotifier<int> availableTc;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorWalletScreen> createState() => _MentorWalletScreenState();
}

class _MentorWalletScreenState extends State<MentorWalletScreen> {
  int get _availableTc => widget.availableTc.value;
  static const _escrowTc = 60;
  final List<_CashoutRequest> _requests = [];

  Future<void> _openCashOut() async {
    if (_availableTc < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo TimeCoin belum tersedia untuk dicairkan.'),
        ),
      );
      return;
    }
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.mentorCashOut,
      arguments: MentorCashOutArgs(
        availableTc: _availableTc,
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (result is MentorCashOutResult && mounted) {
      setState(() {
        widget.availableTc.value -= result.amountTc;
        _requests.insert(
          0,
          _CashoutRequest(amountTc: result.amountTc, account: result.account),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan cash-out berhasil dikirim.'),
        ),
      );
    } else if (result is int) {
      widget.onSelectTab?.call(result);
    }
  }

  void _openFeatured() {
    Navigator.pushNamed(
      context,
      AppRoutes.mentorFeaturedUpgrade,
      arguments: MentorFeaturedUpgradeArgs(
        balanceTc: _availableTc,
        onSelectTab: widget.onSelectTab,
      ),
    );
  }

  String _rupiah(int amount) {
    final digits = amount.toString();
    final result = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) result.write('.');
      result.write(digits[i]);
    }
    return 'Rp$result';
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header matching screenshot
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'Earnings Wallet',
            style: TextStyle(
              color: AppColors.darkSlate,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Scrollable content with bottom padding 120
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            children: [
              // 1. Solid Royal Navy Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo bisa dicairkan',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.toll_rounded,
                          color: AppColors.accentAmberGold,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$_availableTc TC',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${_rupiah(_availableTc * 1000)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: Colors.white24, height: 1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Di escrow',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '$_escrowTc TC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Admin cash-out',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '15%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
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
              const SizedBox(height: 14),

              // 2. Withdraw to Bank (Cash-Out) Button matching screenshot
              Semantics(
                button: true,
                label: 'Withdraw to Bank (Cash-Out)',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _openCashOut,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Withdraw to Bank (Cash-Out)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Featured Mentor Promo Card matching screenshot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.borderSlate.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _openFeatured,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFD97706),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Saat ini kamu kehilangan ${_rupiah((_availableTc * 1000 * .15).round())} untuk admin. Featured Mentor 0%.',
                          style: const TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.secondarySlate,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Pendapatan 6 Minggu Chart Card matching screenshot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.borderSlate.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pendapatan 6 minggu',
                      style: TextStyle(
                        color: AppColors.darkSlate,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 80), // Chart space
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('M1', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        Text('M2', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        Text('M3', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        Text('M4', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        Text('M5', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        Text('M6', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Transaction Mutations List Card matching Screenshot 2
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.borderSlate.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Item 1: Sesi Struktur BLoC
                    _MutationItem(
                      icon: Icons.south_west_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: 'Sesi Struktur BLoC',
                      subtitle: 'Arya Pratama · escrow dilepas · 8 Jul',
                      amount: '+30 TC',
                      amountColor: const Color(0xFF059669),
                    ),
                    const Divider(color: AppColors.borderSlate, height: 20),

                    // Item 2: Cash-out ke BCA
                    _MutationItem(
                      icon: Icons.north_east_rounded,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      title: 'Cash-out ke BCA',
                      subtitle: 'Admin 15% · Rp15.300 · 1 Jul',
                      amount: '-102 TC',
                      amountColor: AppColors.darkSlate,
                    ),
                    const Divider(color: AppColors.borderSlate, height: 20),

                    // Item 3: Sesi review arsitektur
                    _MutationItem(
                      icon: Icons.south_west_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: 'Sesi review arsitektur',
                      subtitle: 'Arya Pratama · 24 Jun',
                      amount: '+30 TC',
                      amountColor: const Color(0xFF059669),
                    ),
                    const Divider(color: AppColors.borderSlate, height: 20),

                    // Item 4: Sesi persiapan portofolio
                    _MutationItem(
                      icon: Icons.south_west_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: 'Sesi persiapan portofolio',
                      subtitle: 'Dewi Lestari · 20 Jun',
                      amount: '+30 TC',
                      amountColor: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MutationItem extends StatelessWidget {
  const _MutationItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
        ),
      ],
    ),
  );
}

class _CashoutRequest {
  const _CashoutRequest({required this.amountTc, required this.account});
  final int amountTc;
  final String account;
}
