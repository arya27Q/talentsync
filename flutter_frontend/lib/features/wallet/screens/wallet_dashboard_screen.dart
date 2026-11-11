import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({super.key, this.walletApi});

  final WalletApi? walletApi;

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  late final WalletApi _api = widget.walletApi ?? WalletApi.instance;

  bool _isLoading = true;
  bool _isActionBusy = false;
  String? _error;
  Map<String, dynamic> _summary = const {};

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
      final data = await _api.summary();
      if (!mounted) return;
      setState(() {
        _summary = data;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat ringkasan dompet TimeCoin.';
          _isLoading = false;
        });
      }
    }
  }

  void _showTopUpModal() {
    final customController = TextEditingController();
    int selectedAmount = 100;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
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
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSlate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Isi Ulang TimeCoin (Top-Up)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kurs resmi: 1 TC = Rp1.000. Pilih nominal paket atau masukkan jumlah kustom.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [50, 100, 200].map((amount) {
                    final active =
                        customController.text.isEmpty &&
                        selectedAmount == amount;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: amount == 200 ? 0 : 8),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedAmount = amount;
                              customController.clear();
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primaryNavy
                                  : AppColors.canvasWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: active
                                    ? AppColors.primaryNavy
                                    : AppColors.borderSlate,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$amount TC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: active
                                        ? Colors.white
                                        : AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp${_formatIdr(amount * 1000)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: active
                                        ? const Color(0xFFDBEAFE)
                                        : AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: customController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Atau masukkan nominal TC kustom',
                    hintText: 'Minimal 10 TC',
                    filled: true,
                    fillColor: AppColors.canvasWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isActionBusy
                        ? null
                        : () async {
                            final parsed =
                                int.tryParse(customController.text.trim()) ??
                                selectedAmount;
                            if (parsed < 10) {
                              _showSnack(
                                'Minimal top-up adalah 10 TC.',
                                isError: true,
                              );
                              return;
                            }
                            Navigator.pop(ctx);
                            await _performTopUp(parsed);
                          },
                    child: const Text(
                      'Proses Top-Up Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(customController.dispose);
  }

  Future<void> _performTopUp(int amountTc) async {
    setState(() => _isActionBusy = true);
    try {
      await _api.topUp(amountTc: amountTc);
      if (!mounted) return;
      _showSnack('Top-Up $amountTc TC berhasil ditambahkan.');
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal memproses top-up.', isError: true);
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  void _showCashOutModal() {
    final accounts = (_summary['bank_accounts'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final primary = accounts.isNotEmpty ? accounts.first : null;
    final balanceTc = (_summary['balance_tc'] as num?)?.toInt() ?? 0;
    final feePercent = (_summary['cashout_fee_percent'] as num?)?.toInt() ?? 0;

    final amountCtrl = TextEditingController(
      text: balanceTc >= 50 ? '50' : (balanceTc >= 10 ? '$balanceTc' : ''),
    );
    final bankCtrl = TextEditingController(
      text: (primary?['bank_name'] as String?) ?? 'Bank BCA',
    );
    final numberCtrl = TextEditingController(
      text: (primary?['account_number'] as String?) ?? '',
    );
    final holderCtrl = TextEditingController(
      text: (primary?['account_holder_name'] as String?) ?? '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tarik Dana ke Rekening (Cash-Out)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feePercent == 0
                        ? 'Biaya Admin: 0% (Gratis untuk Mahasiswa). 1 TC = Rp1.000.'
                        : 'Biaya Admin: $feePercent%. 1 TC = Rp1.000.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
                if (accounts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: accounts.map((acc) {
                      return ActionChip(
                        label: Text(
                          '${acc['bank_name']} (${acc['account_number']})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          bankCtrl.text = '${acc['bank_name'] ?? ''}';
                          numberCtrl.text = '${acc['account_number'] ?? ''}';
                          holderCtrl.text =
                              '${acc['account_holder_name'] ?? ''}';
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Penarikan (TC) | Saldo: $balanceTc TC',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bankCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Bank / E-Wallet',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nomor Rekening / E-Wallet',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: holderCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Pemilik Rekening',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isActionBusy
                        ? null
                        : () async {
                            final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
                            if (amount < 10) {
                              _showSnack(
                                'Minimal penarikan adalah 10 TC.',
                                isError: true,
                              );
                              return;
                            }
                            if (bankCtrl.text.trim().isEmpty ||
                                numberCtrl.text.trim().isEmpty ||
                                holderCtrl.text.trim().isEmpty) {
                              _showSnack(
                                'Lengkapi detail rekening tujuan.',
                                isError: true,
                              );
                              return;
                            }
                            Navigator.pop(ctx);
                            await _performCashOut(
                              amountTc: amount,
                              bankName: bankCtrl.text.trim(),
                              accountNumber: numberCtrl.text.trim(),
                              accountHolderName: holderCtrl.text.trim(),
                            );
                          },
                    child: const Text(
                      'Ajukan Penarikan Dana',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      amountCtrl.dispose();
      bankCtrl.dispose();
      numberCtrl.dispose();
      holderCtrl.dispose();
    });
  }

  Future<void> _performCashOut({
    required int amountTc,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    setState(() => _isActionBusy = true);
    try {
      await _api.cashOut(
        amountTc: amountTc,
        bankName: bankName,
        accountNumber: accountNumber,
        accountHolderName: accountHolderName,
      );
      if (!mounted) return;
      _showSnack(
        'Penarikan $amountTc TC (Rp${_formatIdr(amountTc * 1000)}) berhasil diproses.',
      );
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal memproses penarikan dana.', isError: true);
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceTc = (_summary['balance_tc'] as num?)?.toInt() ?? 0;
    final lockedTc = (_summary['locked_balance_tc'] as num?)?.toInt() ?? 0;
    final estimatedIdr = (_summary['estimated_idr'] as num?)?.toInt() ?? 0;
    final incomeTc = (_summary['total_income_tc'] as num?)?.toInt() ?? 0;
    final expenseTc = (_summary['total_expense_tc'] as num?)?.toInt() ?? 0;
    final txs = (_summary['recent_transactions'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryNavy),
              )
            : _error != null
            ? _buildErrorState()
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.primaryNavy,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 16),
                    _buildBalanceCard(
                      balanceTc: balanceTc,
                      lockedTc: lockedTc,
                      estimatedIdr: estimatedIdr,
                      incomeTc: incomeTc,
                      expenseTc: expenseTc,
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mutasi Terbaru',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.walletHistory,
                            );
                            if (mounted) _load();
                          },
                          child: const Text('Lihat semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (txs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: const Text(
                          'Belum ada riwayat transaksi TimeCoin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      )
                    else
                      ...txs.take(8).map(_buildTransactionRow),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar() {
    final canPop = Navigator.canPop(context);
    return Row(
      children: [
        if (canPop) ...[
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.darkSlate,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        const Expanded(
          child: Text(
            'Dompet TimeCoin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.walletHistory);
            if (mounted) _load();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.darkSlate,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required int balanceTc,
    required int lockedTc,
    required int estimatedIdr,
    required int incomeTc,
    required int expenseTc,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Tersedia',
                style: TextStyle(fontSize: 13, color: Color(0xFFDBEAFE)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Escrow: $lockedTc TC',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentAmberGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$balanceTc TC',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Setara Rp${_formatIdr(estimatedIdr)} (0% Biaya Admin Mahasiswa)',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFFDBEAFE)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Masuk: +$incomeTc TC',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF86EFAC),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Keluar: -$expenseTc TC',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFCA5A5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionTile(
          icon: Icons.add_card_rounded,
          label: 'Top-Up',
          onTap: _isActionBusy ? null : _showTopUpModal,
        ),
        const SizedBox(width: 8),
        _actionTile(
          icon: Icons.account_balance_rounded,
          label: 'Cash-Out',
          onTap: _isActionBusy ? null : _showCashOutModal,
        ),
        const SizedBox(width: 8),
        _actionTile(
          icon: Icons.send_rounded,
          label: 'Transfer',
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.walletTransfer);
            if (mounted) _load();
          },
        ),
        const SizedBox(width: 8),
        _actionTile(
          icon: Icons.card_giftcard_rounded,
          label: 'Reward',
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.rewardHub);
            if (mounted) _load();
          },
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryNavy, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildTransactionRow(Map<String, dynamic> tx) {
    final direction = (tx['direction'] as String?) ?? 'debit';
    final isCredit = direction == 'credit';
    final amount = (tx['amount'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.lightGreenSurface
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit
                  ? AppColors.successGreen
                  : const Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (tx['title'] as String?) ?? 'Transaksi TimeCoin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatIsoDate(tx['created_at'] as String?),
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
              fontWeight: FontWeight.bold,
              color: isCredit
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 46,
              color: AppColors.secondarySlate,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _load,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatIdr(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _formatIsoDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }
}
