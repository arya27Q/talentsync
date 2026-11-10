import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorFeaturedUpgradeArgs {
  const MentorFeaturedUpgradeArgs({required this.balanceTc, this.onSelectTab});

  final int balanceTc;
  final ValueChanged<int>? onSelectTab;
}

class MentorFeaturedUpgradeScreen extends StatefulWidget {
  const MentorFeaturedUpgradeScreen({
    super.key,
    this.balanceTc = 420,
    this.onSelectTab,
  });

  final int balanceTc;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorFeaturedUpgradeScreen> createState() =>
      _MentorFeaturedUpgradeScreenState();
}

class _MentorFeaturedUpgradeScreenState
    extends State<MentorFeaturedUpgradeScreen> {
  bool _submitting = false;

  int get _estimatedSaving => (widget.balanceTc * 1000 * .10).round();

  Future<void> _requestPremium() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await MentorApi.instance.requestPremium();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pengajuan Premium terkirim'),
          content: Text(
            'Referensi ${result['payment_reference']}. Aktivasi dilakukan setelah admin memverifikasi pembayaran Rp${result['amount_idr']}.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                const Expanded(
                  child: Text(
                    'Upgrade Premium',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.darkSlate,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
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
                // 1. Hero Banner Card matching Screenshot 3
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
                  child: Stack(
                    children: [
                      // Abstract circular overlay
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 22,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmberGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppColors.darkSlate,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Featured Mentor',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.darkSlate,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Cairkan semua TimeCoin\ntanpa potongan.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Rp50.000 / bulan · batalkan kapan saja',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Benefits List Card matching Screenshot 3
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    children: const [
                      _BenefitItem(
                        icon: Icons.money_off_csred_rounded,
                        title: '0% biaya admin cash-out',
                        detail: 'Paket gratis dipotong 10% setiap cash-out TimeCoin',
                      ),
                      Divider(height: 1, color: AppColors.borderSlate),
                      _BenefitItem(
                        icon: Icons.trending_up_rounded,
                        title: 'Top search visibility',
                        detail:
                            'Tampil di urutan teratas Cari Mentor mahasiswa',
                      ),
                      Divider(height: 1, color: AppColors.borderSlate),
                      _BenefitItem(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Badge Featured Mentor',
                        detail: 'Tanda kepercayaan di profil dan kartu mentor',
                      ),
                      Divider(height: 1, color: AppColors.borderSlate),
                      _BenefitItem(
                        icon: Icons.thumb_up_alt_rounded,
                        title: 'Prioritas permintaan UMKM',
                        detail:
                            'Rekomendasimu tampil pertama di profil pelamar',
                      ),
                      Divider(height: 1, color: AppColors.borderSlate),
                      _BenefitItem(
                        icon: Icons.all_inclusive_rounded,
                        title: 'Layanan tanpa batas',
                        detail: 'Paket gratis maksimal 3 layanan aktif',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Calculator Card matching Screenshot 4
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
                        'Hitung penghematanmu',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saldo saat ini ${widget.balanceTc} TC (Rp${widget.balanceTc * 1000})',
                        style: const TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Two Comparison Boxes Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Admin paket gratis',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _rupiah(_estimatedSaving),
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Admin Featured',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Rp0',
                                    style: TextStyle(
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Premium aktif setelah pembayaran dikonfirmasi admin.',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _submitting ? null : _requestPremium,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Ajukan Premium · Rp50.000 / bulan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: MentorBottomNav(
      selectedIndex: 4,
      onSelected: (index) {
        if (widget.onSelectTab == null) {
          Navigator.pop(context, index);
          return;
        }
        widget.onSelectTab!(index);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    ),
  );
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFFC2410C), size: 21),
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
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
