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
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header matching screenshot
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Kembali',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cash-Out Funds',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saldo ${widget.availableTc} TC',
                        style: const TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content with bottom padding 120
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
              children: [
                // 1. Rekening Tujuan Card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rekening tujuan',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final account in _accounts) ...[
                        _AccountChoice(
                          bank: account.$1,
                          number: account.$2,
                          icon: account.$3,
                          selected: _selectedAccount == account.$1,
                          onTap: () =>
                              setState(() => _selectedAccount = account.$1),
                        ),
                        if (account != _accounts.last) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Jumlah TimeCoin Ditukar Card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jumlah TimeCoin ditukar',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Input Box matching Screenshot 3 & 4
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.toll_rounded,
                              color: AppColors.accentAmberGold,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  color: AppColors.darkSlate,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const Text(
                              'TC',
                              style: TextStyle(
                                color: AppColors.secondarySlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick Preset Chips (50 TC, 100 TC, 200 TC, Semua)
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

                // 3. Ringkasan Card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        label: 'Nilai kotor',
                        value: _rupiah(_grossRupiah),
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Biaya admin 15%',
                        value: '-${_rupiah(_feeRupiah)}',
                        valueColor: const Color(0xFFDC2626),
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

                // 4. Hemat Rp30.000 Sekarang Card matching Screenshot 4
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
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.mentorFeaturedUpgrade,
                      arguments: MentorFeaturedUpgradeArgs(
                        balanceTc: widget.availableTc,
                        onSelectTab: widget.onSelectTab,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Hemat Rp30.000 sekarang',
                              style: TextStyle(
                                color: AppColors.darkSlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Featured Mentor Rp50.000/bulan menghapus biaya admin. Untung sejak cash-out di atas Rp333.000 per bulan.',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _confirmCashOut,
              icon: const Icon(Icons.account_balance_outlined),
              label: const Text(
                'Withdraw to Bank (Cash-Out)',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        MentorBottomNav(
          selectedIndex: 3,
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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFF0F7FF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: selected
            ? AppColors.primaryNavy
            : AppColors.borderSlate.withValues(alpha: 0.8),
        width: selected ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primaryNavy, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$bank ·· $number',
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primaryNavy : const Color(0xFFCBD5E1),
              size: 22,
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
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
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
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: strong ? AppColors.darkSlate : AppColors.secondarySlate,
          fontSize: strong ? 15 : 13.5,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: strong ? 18 : 14,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
        ),
      ),
    ],
  );
}
