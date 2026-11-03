import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorCashOutArgs {
  const MentorCashOutArgs({required this.availableTc, this.onSelectTab});

  final int availableTc;
  final ValueChanged<int>? onSelectTab;
}

class MentorCashOutResult {
  const MentorCashOutResult({required this.amountTc, required this.account});

  final int amountTc;
  final String account;
}

class MentorCashOutScreen extends StatefulWidget {
  const MentorCashOutScreen({
    super.key,
    this.availableTc = 420,
    this.onSelectTab,
  });

  final int availableTc;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorCashOutScreen> createState() => _MentorCashOutScreenState();
}

class _MentorCashOutScreenState extends State<MentorCashOutScreen> {
  final _amountController = TextEditingController(text: '200');
  static const _accounts = [
    ('BCA', '7721', Icons.account_balance_outlined),
    ('Mandiri', '0394', Icons.account_balance_outlined),
    ('GoPay', '0812', Icons.account_balance_wallet_outlined),
  ];
  String _selectedAccount = 'BCA';

  int get _amountTc => int.tryParse(_amountController.text) ?? 0;
  int get _grossRupiah => _amountTc * 1000;
  int get _feeRupiah => (_grossRupiah * .15).round();
  int get _netRupiah => _grossRupiah - _feeRupiah;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _rupiah(int value) {
    final digits = value.toString();
    final result = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) result.write('.');
      result.write(digits[i]);
    }
    return 'Rp$result';
  }

  Future<void> _confirmCashOut() async {
    if (_amountTc < 1 || _amountTc > widget.availableTc) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan jumlah 1–${widget.availableTc} TC.')),
      );
      return;
    }
    final account = _accounts.firstWhere(
      (entry) => entry.$1 == _selectedAccount,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi cash-out'),
        content: Text(
          '$_amountTc TC akan dicairkan ke ${account.$1} ·· ${account.$2}. Perkiraan diterima ${_rupiah(_netRupiah)} setelah biaya admin 15%.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Buat pengajuan'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(
        context,
        MentorCashOutResult(
          amountTc: _amountTc,
          account: '${account.$1} ·· ${account.$2}',
        ),
      );
    }
  }

  void _setAmount(int value) {
    setState(() => _amountController.text = value.toString());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cash-Out Funds',
            style: TextStyle(
              color: AppColors.darkSlate,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Saldo ${widget.availableTc} TC',
            style: const TextStyle(
              color: AppColors.secondarySlate,
              fontSize: 12,
            ),
          ),
        ],
      ),
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkSlate,
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CashOutHeading('Rekening tujuan'),
                for (final account in _accounts) ...[
                  _AccountChoice(
                    bank: account.$1,
                    number: account.$2,
                    icon: account.$3,
                    selected: _selectedAccount == account.$1,
                    onTap: () => setState(() => _selectedAccount = account.$1),
                  ),
                  if (account != _accounts.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CashOutHeading('Jumlah TimeCoin ditukar'),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.circle,
                      color: AppColors.accentAmberGold,
                    ),
                    suffixText: 'TC',
                    filled: true,
                    fillColor: AppColors.canvasWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final amount in [
                      50,
                      100,
                      200,
                      widget.availableTc,
                    ]) ...[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: amount == widget.availableTc ? 0 : 7,
                          ),
                          child: _AmountPreset(
                            label: amount == widget.availableTc
                                ? 'Semua'
                                : '$amount TC',
                            selected: _amountTc == amount,
                            onTap: () => _setAmount(amount),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                _SummaryRow(label: 'Nilai kotor', value: _rupiah(_grossRupiah)),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Biaya admin 15%',
                  value: '−${_rupiah(_feeRupiah)}',
                  valueColor: const Color(0xFFB42318),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.borderSlate),
                ),
                _SummaryRow(
                  label: 'Diterima di rekening',
                  value: _rupiah(_netRupiah),
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.mentorFeaturedUpgrade,
                arguments: MentorFeaturedUpgradeArgs(
                  balanceTc: widget.availableTc,
                  onSelectTab: widget.onSelectTab,
                ),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: AppColors.accentAmberDeep,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hemat ${_rupiah(_feeRupiah)} dengan Featured Mentor',
                        style: const TextStyle(
                          color: AppColors.darkSlate,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.secondarySlate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _confirmCashOut,
              icon: const Icon(Icons.account_balance_outlined),
              label: const Text('Withdraw to Bank (Cash-Out)'),
            ),
          ),
        ),
        MentorBottomNav(
          selectedIndex: -1,
          onSelected: (index) {
            if (widget.onSelectTab == null) {
              Navigator.pop(context, index);
              return;
            }
            widget.onSelectTab!(index);
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    ),
  );
}

class _AccountChoice extends StatelessWidget {
  const _AccountChoice({
    required this.bank,
    required this.number,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String bank;
  final String number;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.lightBlueSurface : Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$bank ·· $number',
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            ),
          ],
        ),
      ),
    ),
  );
}

class _AmountPreset extends StatelessWidget {
  const _AmountPreset({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        backgroundColor: selected ? AppColors.primaryNavy : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.darkSlate,
        side: BorderSide(
          color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.darkSlate,
    this.strong = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: strong ? AppColors.darkSlate : AppColors.secondarySlate,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
          fontSize: strong ? 18 : 14,
        ),
      ),
    ],
  );
}

class _CashOutHeading extends StatelessWidget {
  const _CashOutHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.darkSlate,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
