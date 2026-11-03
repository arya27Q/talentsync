import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_cashout_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

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
          content: Text('Pengajuan cash-out dicatat di sesi ini.'),
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
      children: [
        const MentorPageHeader(title: 'Earnings Wallet'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo bisa dicairkan',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: AppColors.accentAmberGold,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_availableTc TC',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
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
                        fontSize: 15,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.white24, height: 1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _BalanceDetail(
                            label: 'Di escrow',
                            value: '$_escrowTc TC',
                          ),
                        ),
                        Expanded(
                          child: _BalanceDetail(
                            label: 'Admin cash-out',
                            value: '15%',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _openCashOut,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.account_balance_outlined),
                  label: const Text('Withdraw to Bank (Cash-Out)'),
                ),
              ),
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: _openFeatured,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_outlined,
                            color: AppColors.accentAmberDeep,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Saat ini kamu kehilangan ${_rupiah((_availableTc * 1000 * .15).round())} untuk admin. Featured Mentor 0%.',
                            style: const TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.secondarySlate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              MentorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pendapatan 6 minggu',
                      style: TextStyle(
                        color: AppColors.darkSlate,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 142,
                      alignment: Alignment.center,
                      child: const Text(
                        'Grafik mingguan belum tersedia pada demo ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _WeekLabel('M1'),
                        _WeekLabel('M2'),
                        _WeekLabel('M3'),
                        _WeekLabel('M4'),
                        _WeekLabel('M5'),
                        _WeekLabel('M6'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_requests.isNotEmpty) ...[
                const MentorSectionTitle('Pengajuan cash-out'),
                for (final request in _requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MentorCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.hourglass_top_rounded,
                            color: AppColors.accentAmberDeep,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${request.amountTc} TC · ${request.account}',
                              style: const TextStyle(
                                color: AppColors.darkSlate,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const MentorTag(
                            'Menunggu',
                            color: Color(0xFFFFF6E8),
                            textColor: AppColors.accentAmberDeep,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const MentorSectionTitle('Transaksi terbaru'),
              const _TransactionRow(
                title: 'Sesi Struktur BLoC',
                subtitle: 'Arya Pratama · escrow dilepas · 8 Jul',
                amount: '+30 TC',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BalanceDetail extends StatelessWidget {
  const _BalanceDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(color: AppColors.secondarySlate, fontSize: 11),
  );
}

class _CashoutRequest {
  const _CashoutRequest({required this.amountTc, required this.account});
  final int amountTc;
  final String account;
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: MentorCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.south_west_rounded,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF047857),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}
