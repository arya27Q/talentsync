import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
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
  int _lockedTc = 0;
  int _feePercent = 10;
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await MentorApi.instance.walletSummary();
      if (!mounted) return;
      setState(() {
        widget.availableTc.value = summary['balance_tc'] as int? ?? 0;
        _lockedTc = summary['locked_balance_tc'] as int? ?? 0;
        _feePercent = summary['cashout_fee_percent'] as int? ?? 10;
        final recent = summary['recent_transactions'];
        _transactions = recent is List
            ? recent.whereType<Map<String, dynamic>>().toList()
            : [];
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
        adminFeePercent: _feePercent,
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (result is MentorCashOutResult && mounted) {
      await _loadWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan cash-out berhasil dikirim.')),
      );
    } else if (result is int) {
      widget.onSelectTab?.call(result);
    }
  }

  Future<void> _openFeatured() async {
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.mentorFeaturedUpgrade,
      arguments: MentorFeaturedUpgradeArgs(
        balanceTc: _availableTc,
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (result == true && mounted) await _loadWallet();
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

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final direction = transaction['direction'] as String? ?? 'debit';
    final incoming = direction == 'credit';
    final type =
        transaction['type'] as String? ??
        transaction['transaction_type'] as String? ??
        '';
    final label = switch (type) {
      'mentoring_payment' => 'Pembayaran sesi mentoring',
      'mentoring_refund' => 'Pengembalian dana mentoring',
      'cash_out' => 'Pengajuan cash-out',
      'cash_out_refund' => 'Pengembalian cash-out',
      _ => 'Transaksi TimeCoin',
    };
    final amount = transaction['amount'] as int? ?? 0;
    final date = DateTime.tryParse(transaction['created_at'] as String? ?? '')
        ?.toLocal();
    final dateLabel = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final status = transaction['status'] as String? ?? 'completed';

    return _MutationItem(
      icon: incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
      iconBg: incoming ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
      iconColor: incoming ? const Color(0xFF059669) : const Color(0xFF475569),
      title: label,
      subtitle: [status, if (dateLabel.isNotEmpty) dateLabel].join(' · '),
      amount: '${incoming ? '+' : '-'}$amount TC',
      amountColor: incoming ? const Color(0xFF059669) : AppColors.darkSlate,
    );
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
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                MentorCard(
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.secondarySlate),
                      ),
                      TextButton(
                        onPressed: _loadWallet,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
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
                            children: [
                              Text(
                                'Di escrow',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '$_lockedTc TC',
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
                            children: [
                              Text(
                                'Admin cash-out',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '$_feePercent%',
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
                          'Perkiraan biaya admin saat ini ${_rupiah((_availableTc * 1000 * _feePercent / 100).round())}. Premium memberi tarif 0%.',
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

              // Riwayat dimuat dari ledger API.
              const SizedBox(height: 16),

              // 5. Transaction Mutations List Card matching Screenshot 2
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    if (_transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Belum ada transaksi TimeCoin.',
                          style: TextStyle(color: AppColors.secondarySlate),
                        ),
                      ),
                    for (
                      var index = 0;
                      index < _transactions.length;
                      index++
                    ) ...[
                      _buildTransactionItem(_transactions[index]),
                      if (index < _transactions.length - 1)
                        const Divider(color: AppColors.borderSlate, height: 20),
                    ],
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
