import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';

String formatRupiah(int amount) {
  final raw = amount.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${amount < 0 ? '-' : ''}Rp${buffer.toString()}';
}

String formatShortDateId(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final parsed = DateTime.tryParse(iso)?.toLocal();
  if (parsed == null) return '-';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year} · $hour:$minute';
}

class MsmeTopUpSheet {
  MsmeTopUpSheet._();

  static Future<bool> show(
    BuildContext context, {
    required bool isPremium,
    MsmeApi? msmeApi,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MsmeTopUpSheetBody(
        isPremium: isPremium,
        msmeApi: msmeApi ?? MsmeApi.instance,
      ),
    );
    return result == true;
  }
}

class _MsmeTopUpSheetBody extends StatefulWidget {
  const _MsmeTopUpSheetBody({
    required this.isPremium,
    required this.msmeApi,
  });

  final bool isPremium;
  final MsmeApi msmeApi;

  @override
  State<_MsmeTopUpSheetBody> createState() => _MsmeTopUpSheetBodyState();
}

class _MsmeTopUpSheetBodyState extends State<_MsmeTopUpSheetBody> {
  static const _quickAmounts = [50, 100, 250, 500, 1000];
  static const _channels = [
    (id: 'qris_sandbox', label: 'QRIS', icon: Icons.qr_code_2_rounded),
    (id: 'va_bca', label: 'VA BCA', icon: Icons.account_balance_rounded),
    (
      id: 'va_mandiri',
      label: 'VA Mandiri',
      icon: Icons.account_balance_rounded,
    ),
    (id: 'gopay', label: 'GoPay', icon: Icons.account_balance_wallet_rounded),
  ];

  final _amountController = TextEditingController(text: '100');
  String _selectedChannel = 'qris_sandbox';
  bool _isSubmitting = false;

  int get _amountTc =>
      int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
      0;

  int get _adminFeePercent => widget.isPremium ? 0 : 5;
  int get _baseIdr => _amountTc * 1000;
  int get _adminFeeIdr => (_baseIdr * _adminFeePercent / 100).round();
  int get _totalPayableIdr => _baseIdr + _adminFeeIdr;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitTopUp() async {
    if (_isSubmitting) return;
    if (_amountTc < 10) {
      await AppStatusDialog.showError(
        context,
        title: 'Nominal Belum Valid',
        message: 'Minimal top-up saldo usaha adalah 10 TC (Rp10.000).',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await widget.msmeApi.topUp(
        amountTc: _amountTc,
        paymentChannel: _selectedChannel,
      );
      final data = response['data'] as Map<String, dynamic>? ?? const {};
      final newBalance = (data['balance_tc'] as num?)?.toInt();
      final reference = (data['payment_reference'] as String?) ?? '';
      if (newBalance != null) {
        await ApiClient.instance.updateSessionUser({'balance_tc': newBalance});
      }
      if (!mounted) return;
      await AppStatusDialog.showSuccess(
        context,
        title: 'Top-Up $_amountTc TC Berhasil',
        message:
            'Total bayar ${formatRupiah(_totalPayableIdr)} telah terkonfirmasi${reference.isNotEmpty ? ' (Ref: $reference)' : ''}. Saldo usaha siap dipakai mendanai proyek.',
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Top-Up Gagal',
        message: err.message,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Koneksi Bermasalah',
        message: 'Tidak dapat memproses top-up saat ini. Coba lagi sebentar.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSlate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: AppColors.primaryNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top-Up TimeCoin Usaha',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isPremium
                            ? 'Partner Pro aktif · bebas biaya admin 0%'
                            : '1 TC = Rp1.000 · biaya admin paket Gratis 5%',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isPremium
                              ? const Color(0xFF047857)
                              : AppColors.secondarySlate,
                          fontWeight: widget.isPremium
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Pilih Nominal Cepat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((tc) {
                final selected = _amountTc == tc;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _amountController.text = '$tc';
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryNavy : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryNavy
                            : AppColors.borderSlate,
                      ),
                    ),
                    child: Text(
                      '$tc TC',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.darkSlate,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Atau Masukkan Jumlah TimeCoin',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.toll_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                suffixText: 'TC',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkSlate,
                ),
                hintText: 'Minimal 10 TC',
                filled: true,
                fillColor: AppColors.canvasWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSlate),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryNavy,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _channels.map((ch) {
                final selected = _selectedChannel == ch.id;
                return InkWell(
                  onTap: () => setState(() => _selectedChannel = ch.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEFF6FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryNavy
                            : AppColors.borderSlate,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ch.icon,
                          size: 16,
                          color: selected
                              ? AppColors.primaryNavy
                              : AppColors.secondarySlate,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ch.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.primaryNavy
                                : AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Nominal ($_amountTc TC)',
                    value: formatRupiah(_baseIdr),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Biaya Admin ($_adminFeePercent%)',
                    value: _adminFeeIdr == 0
                        ? 'Rp0 (Gratis Pro)'
                        : formatRupiah(_adminFeeIdr),
                    valueColor: _adminFeeIdr == 0
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                  ),
                  const Divider(height: 18, color: AppColors.borderSlate),
                  _SummaryRow(
                    label: 'Total Pembayaran',
                    value: formatRupiah(_totalPayableIdr),
                    isBold: true,
                  ),
                ],
              ),
            ),
            if (!widget.isPremium) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                  Navigator.pushNamed(context, AppRoutes.msmeUpgradePro);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 16,
                        color: Color(0xFFB45309),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Aktifkan Partner Pro agar top-up 0% biaya admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.primaryNavy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primaryNavy.withValues(
                    alpha: 0.5,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Bayar ${formatRupiah(_totalPayableIdr)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13.5 : 12.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? AppColors.darkSlate : AppColors.secondarySlate,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: isBold ? 15 : 13,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
          color: valueColor ?? AppColors.darkSlate,
        ),
      ),
    ],
  );
}

class MsmeTransactionHistorySheet {
  MsmeTransactionHistorySheet._();

  static Future<void> show(
    BuildContext context, {
    MsmeApi? msmeApi,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MsmeTransactionHistoryBody(
      msmeApi: msmeApi ?? MsmeApi.instance,
    ),
  );
}

class _MsmeTransactionHistoryBody extends StatefulWidget {
  const _MsmeTransactionHistoryBody({required this.msmeApi});

  final MsmeApi msmeApi;

  @override
  State<_MsmeTransactionHistoryBody> createState() =>
      _MsmeTransactionHistoryBodyState();
}

class _MsmeTransactionHistoryBodyState
    extends State<_MsmeTransactionHistoryBody> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _data = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.msmeApi.getTransactions();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err is ApiException
            ? err.message
            : 'Gagal memuat riwayat mutasi TimeCoin.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceTc = (_data['balance_tc'] as num?)?.toInt() ?? 0;
    final lockedTc = (_data['locked_balance_tc'] as num?)?.toInt() ?? 0;
    final rawTxs = _data['transactions'];
    final transactions = rawTxs is List
        ? rawTxs.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Riwayat Mutasi TimeCoin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$balanceTc TC',
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Saldo aktif ${formatRupiah(balanceTc * 1000)}${lockedTc > 0 ? ' · Escrow terkunci $lockedTc TC' : ''}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Muat Ulang'),
                      ),
                    ],
                  ),
                )
              else if (transactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.canvasWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.secondarySlate,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum Ada Transaksi TimeCoin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mutasi saldo dari Top-Up, Barter Voucher Sosial, atau pembayaran proyek mahasiswa akan tercatat di sini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: AppColors.borderSlate, height: 16),
                    itemBuilder: (_, index) {
                      final tx = transactions[index];
                      final title = (tx['title'] as String?) ?? 'Transaksi TC';
                      final direction = (tx['direction'] as String?) ?? 'debit';
                      final isCredit = direction == 'credit';
                      final amount = (tx['amount'] as num?)?.toInt() ?? 0;
                      final createdAt = formatShortDateId(
                        tx['created_at'] as String?,
                      );

                      return Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              isCredit
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded,
                              size: 18,
                              color: isCredit
                                  ? const Color(0xFF047857)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  createdAt,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isCredit ? '+' : '-'}$amount TC',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isCredit
                                  ? const Color(0xFF047857)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
