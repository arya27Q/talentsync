import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/widgets/msme_finance_modals.dart';

class MsmeUpgradeProScreen extends StatefulWidget {
  const MsmeUpgradeProScreen({super.key, this.msmeApi});

  final MsmeApi? msmeApi;

  @override
  State<MsmeUpgradeProScreen> createState() => _MsmeUpgradeProScreenState();
}

class _MsmeUpgradeProScreenState extends State<MsmeUpgradeProScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;

  int _selectedPlanIndex = 0; // 0: Bulanan, 1: Tahunan
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isPremium = false;
  bool _didUpgrade = false;
  Map<String, dynamic>? _activeSubscription;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final data = await _msmeApi.getSubscription();
      if (!mounted) return;
      setState(() {
        _isPremium = (data['is_premium'] as bool?) ?? false;
        _activeSubscription =
            data['active_subscription'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? iso) {
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
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  Future<void> _onUpgrade() async {
    if (_isSubmitting) return;
    final planType = _selectedPlanIndex == 0 ? 'monthly' : 'yearly';
    final planLabel = _selectedPlanIndex == 0 ? 'Bulanan' : 'Tahunan';
    final priceIdr = _selectedPlanIndex == 0 ? 49000 : 490000;

    final channel = await _pickPaymentChannel(
      planLabel: planLabel,
      priceIdr: priceIdr,
    );
    if (channel == null || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await _msmeApi.subscribePro(
        planType: planType,
        paymentChannel: channel,
      );
      final data = response['data'] as Map<String, dynamic>? ?? const {};
      await ApiClient.instance.updateSessionUser({
        'is_premium': true,
        'monthly_quota_tc': (data['monthly_quota_tc'] as num?)?.toInt() ?? 500,
      });

      if (!mounted) return;
      setState(() {
        _isPremium = true;
        _didUpgrade = true;
        _activeSubscription =
            data['active_subscription'] as Map<String, dynamic>?;
        _isSubmitting = false;
      });

      await AppStatusDialog.showSuccess(
        context,
        title: 'Partner Pro Aktif!',
        message:
            (response['message'] as String?) ??
            'Akun tokomu kini aktif sebagai Partner Pro. Nikmati 10 slot proyek & 0% biaya admin top-up.',
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Upgrade Gagal',
        message: err.message,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Koneksi Bermasalah',
        message: 'Tidak dapat memproses langganan saat ini. Coba lagi.',
      );
    }
  }

  Future<String?> _pickPaymentChannel({
    required String planLabel,
    required int priceIdr,
  }) async {
    const channels = [
      (id: 'qris_sandbox', label: 'QRIS Instan', icon: Icons.qr_code_2_rounded),
      (id: 'va_bca', label: 'Virtual Account BCA', icon: Icons.account_balance_rounded),
      (id: 'va_mandiri', label: 'Virtual Account Mandiri', icon: Icons.account_balance_rounded),
      (id: 'gopay', label: 'GoPay', icon: Icons.account_balance_wallet_rounded),
    ];
    String selected = 'qris_sandbox';

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
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
                const Text(
                  'Konfirmasi Langganan Partner Pro',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paket $planLabel · Total ${formatRupiah(priceIdr)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 10),
                ...channels.map((ch) {
                  final isPicked = selected == ch.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setModalState(() => selected = ch.id),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isPicked
                              ? const Color(0xFFEFF6FF)
                              : AppColors.canvasWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPicked
                                ? AppColors.primaryNavy
                                : AppColors.borderSlate,
                            width: isPicked ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              ch.icon,
                              size: 20,
                              color: isPicked
                                  ? AppColors.primaryNavy
                                  : AppColors.secondarySlate,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ch.label,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isPicked
                                      ? AppColors.primaryNavy
                                      : AppColors.darkSlate,
                                ),
                              ),
                            ),
                            Icon(
                              isPicked
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 20,
                              color: isPicked
                                  ? AppColors.primaryNavy
                                  : AppColors.secondarySlate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: Text(
                      'Aktifkan Pro · ${formatRupiah(priceIdr)}',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeExpiry = _formatDate(
      _activeSubscription?['expires_at'] as String?,
    );
    final activePlanLabel =
        (_activeSubscription?['plan_label'] as String?) ?? 'Partner Pro';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSlate),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0F172A,
                              ).withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          tooltip: 'Kembali',
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.maybePop(
                            context,
                            _didUpgrade,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: AppColors.darkSlate,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _isPremium
                              ? 'Status Partner Pro'
                              : 'Tingkatkan ke Partner Pro',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  if (!_isLoading && _isPremium) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF047857),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Partner Pro Aktif ($activePlanLabel)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '10 slot proyek aktif · 0% biaya admin top-up${activeExpiry != '-' ? ' · berlaku s.d. $activeExpiry' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Hero Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech_rounded,
                                color: Color(0xFF78350F),
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Partner Pro',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Lebih banyak proyek, tanpa biaya admin.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buka hingga 10 slot proyek aktif untuk mahasiswa, top-up TimeCoin 0% admin, dan prioritas pelamar ber-endorse mentor.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Plan Selector: Bulanan vs Tahunan
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedPlanIndex = 0),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedPlanIndex == 0
                                    ? AppColors.primaryNavy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Bulanan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedPlanIndex == 0
                                        ? Colors.white
                                        : AppColors.secondarySlate,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedPlanIndex = 1),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedPlanIndex == 1
                                    ? AppColors.primaryNavy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Tahunan · hemat 2 bulan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedPlanIndex == 1
                                          ? Colors.white
                                          : AppColors.secondarySlate,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Comparison Table
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                'Fitur',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  'Gratis',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  'Pro',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.borderSlate),
                        _buildTableRow(
                          'Slot proyek aktif',
                          '2 proyek',
                          '10 proyek',
                        ),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildTableRow('Biaya admin top up TC', '5%', '0%'),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildTableRow(
                          'Kuota sosial bulanan',
                          '20 TC',
                          '500 TC',
                        ),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildTableRow(
                          'Rekomendasi mentor',
                          '1 per bulan',
                          'Tanpa batas',
                        ),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildTableRow(
                          'Prioritas pelamar ber-endorse',
                          '-',
                          'Ya',
                        ),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _buildTableRow('Laporan dampak bulanan', '-', 'Ya'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Simulasi Penghematan Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulasi penghematan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Top up 1.000 TC per bulan untuk membayar mahasiswa:',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin paket Gratis',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF991B1B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Rp50.000',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin Partner Pro',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF065F46),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Rp0',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderSlate.withValues(alpha: 0.8),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isSubmitting
                        ? AppColors.primaryNavy.withValues(alpha: 0.65)
                        : AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSubmitting ? null : _onUpgrade,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.3,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _isPremium
                                            ? (_selectedPlanIndex == 0
                                                  ? 'Perpanjang Bulanan · Rp49.000'
                                                  : 'Perpanjang Tahunan · Rp490.000')
                                            : (_selectedPlanIndex == 0
                                                  ? 'Berlangganan Rp49.000/bulan'
                                                  : 'Berlangganan Rp490.000/tahun'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String feature, String freeVal, String proVal) => Row(
    children: [
      Expanded(
        flex: 5,
        child: Text(
          feature,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Center(
          child: Text(
            freeVal,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.secondarySlate,
            ),
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Center(
          child: Text(
            proVal,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
        ),
      ),
    ],
  );
}
