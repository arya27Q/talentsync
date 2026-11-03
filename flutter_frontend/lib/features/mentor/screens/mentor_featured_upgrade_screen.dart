import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorFeaturedUpgradeArgs {
  const MentorFeaturedUpgradeArgs({required this.balanceTc, this.onSelectTab});

  final int balanceTc;
  final ValueChanged<int>? onSelectTab;
}

class MentorFeaturedUpgradeScreen extends StatelessWidget {
  const MentorFeaturedUpgradeScreen({
    super.key,
    this.balanceTc = 420,
    this.onSelectTab,
  });

  final int balanceTc;
  final ValueChanged<int>? onSelectTab;

  int get _estimatedSaving => (balanceTc * 1000 * .15).round();

  Future<void> _showPaymentState(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Featured Mentor'),
      content: const Text(
        'Paket Rp50.000 per bulan belum dapat diaktifkan karena pembayaran belum terhubung.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Mengerti'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        'Upgrade Premium',
        style: TextStyle(
          color: AppColors.darkSlate,
          fontWeight: FontWeight.w700,
        ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmberGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.darkSlate,
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Featured Mentor',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cairkan semua TimeCoin tanpa potongan.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Rp50.000 / bulan · batalkan kapan saja',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MentorCard(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                _FeatureRow(
                  icon: Icons.money_off_csred_outlined,
                  title: '0% biaya admin cash-out',
                  detail:
                      'Paket gratis dipotong 15% setiap penukaran TC ke Rupiah',
                ),
                Divider(height: 1, color: AppColors.borderSlate),
                _FeatureRow(
                  icon: Icons.trending_up_rounded,
                  title: 'Top search visibility',
                  detail: 'Tampil di urutan teratas Cari Mentor mahasiswa',
                ),
                Divider(height: 1, color: AppColors.borderSlate),
                _FeatureRow(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Badge Featured Mentor',
                  detail: 'Tanda Featured Mentor di profil dan kartu mentor',
                ),
                Divider(height: 1, color: AppColors.borderSlate),
                _FeatureRow(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Prioritas permintaan UMKM',
                  detail: 'Rekomendasimu tampil pertama di profil pelamar',
                ),
                Divider(height: 1, color: AppColors.borderSlate),
                _FeatureRow(
                  icon: Icons.all_inclusive_rounded,
                  title: 'Layanan tanpa batas',
                  detail: 'Paket gratis maksimal 3 layanan aktif',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hitung penghematanmu',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saldo saat ini: $balanceTc TC (≈ Rp${(balanceTc * 1000).toString()})',
                  style: const TextStyle(color: AppColors.secondarySlate),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Perkiraan admin yang dihemat',
                        style: TextStyle(color: AppColors.secondarySlate),
                      ),
                    ),
                    Text(
                      'Rp${_estimatedSaving.toString()}',
                      style: const TextStyle(
                        color: AppColors.darkSlate,
                        fontWeight: FontWeight.w800,
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
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => _showPaymentState(context),
              child: const Text('Upgrade Featured Mentor · Rp50.000/bulan'),
            ),
          ),
        ),
        MentorBottomNav(
          selectedIndex: -1,
          onSelected: (index) {
            if (onSelectTab == null) {
              Navigator.pop(context, index);
              return;
            }
            onSelectTab!(index);
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.accentAmberDeep, size: 21),
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
                ),
              ),
              const SizedBox(height: 4),
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
