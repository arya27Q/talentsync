import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MsmeStoreProfileScreen extends StatelessWidget {
  const MsmeStoreProfileScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Akun Mitra?',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Kamu perlu masuk kembali dengan nomor telepon atau email terdaftar untuk mengelola tokomu.',
          style: TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.secondarySlate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.roleSelection,
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentsModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
              const SizedBox(height: 18),
              const Text(
                'Dokumen & Verifikasi Usaha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Status legalitas kemitraan Kopi Tepi Kali',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 20),
              _buildDocItem(
                icon: Icons.assignment_turned_in_rounded,
                title: 'NIB (Nomor Induk Berusaha)',
                subtitle: 'NIB: 1289004521 · Terverifikasi KBLI 56303',
                status: 'Aktif',
                isVerified: true,
              ),
              const SizedBox(height: 12),
              _buildDocItem(
                icon: Icons.account_balance_rounded,
                title: 'Rekening Bank Terdaftar',
                subtitle: 'BCA · **** 4912 a.n. Rina Suryani',
                status: 'Terhubung',
                isVerified: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(modalContext),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  void _showTimeCoinHistoryModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat TimeCoin Usaha',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '520 TC',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Mutasi kredit proyek & kuota sosial',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 18),
              _buildMutationTile(
                title: 'Kuota Sosial Bulanan Mahasiswa',
                date: '1 Jul 2026 · Subsidi pemerintah',
                amount: '+100 TC',
                isIncome: true,
              ),
              const Divider(color: AppColors.borderSlate, height: 16),
              _buildMutationTile(
                title: 'Barter 5 Voucher Minum Kopi',
                date: '28 Jun 2026 · Terdistribusi ke Reward Hub',
                amount: '+75 TC',
                isIncome: true,
              ),
              const Divider(color: AppColors.borderSlate, height: 16),
              _buildMutationTile(
                title: 'Pembayaran Tahap 1 · Salsa Putri',
                date: '20 Jun 2026 · Desain Feed & Menu',
                amount: '-45 TC',
                isIncome: false,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(modalContext),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  void _showHelpCenterModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
              const SizedBox(height: 18),
              const Text(
                'Pusat Bantuan Mitra UMKM',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dukungan dan panduan kemitraan TalentSync',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primaryNavy,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'WhatsApp Care Mitra UMKM',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.darkSlate,
                  ),
                ),
                subtitle: const Text(
                  'Respons cepat jam operasional 08.00 - 18.00 WIB',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menghubungkan ke WhatsApp Care Mitra...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(color: AppColors.borderSlate, height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.darkSlate,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Panduan & Standar Validasi Deliverable',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.darkSlate,
                  ),
                ),
                subtitle: const Text(
                  'Kriteria persetujuan hasil kerja mahasiswa',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka dokumen panduan mitra...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(modalContext),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  static Widget _buildDocItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool isVerified,
  }) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryNavy, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isVerified ? const Color(0xFF059669) : AppColors.secondarySlate,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    ],
  );

  static Widget _buildMutationTile({
    required String title,
    required String date,
    required String amount,
    required bool isIncome,
  }) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
      Text(
        amount,
        style: TextStyle(
          color: isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626),
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Screen Header matching Screenshot 1
        const Text(
          'Store Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkSlate,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // 1. Store Profile Info Card matching Screenshot 1
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderSlate.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Header Row
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.storefront_rounded,
                            size: 34,
                            color: AppColors.primaryNavy,
                          ),
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
                          'Kopi Tepi Kali',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Klaster Kuliner · Ketintang, Surabaya',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFFB45309),
                                size: 14,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Verified Partner',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3-Column Metrics Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: _StoreMetricCol(
                        value: '6',
                        label: 'Proyek selesai',
                      ),
                    ),
                    _StoreMetricDivider(),
                    Expanded(
                      child: _StoreMetricCol(
                        value: '4.9',
                        label: 'Rating mahasiswa',
                      ),
                    ),
                    _StoreMetricDivider(),
                    Expanded(
                      child: _StoreMetricCol(
                        value: '8',
                        label: 'Mahasiswa dibina',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Subscription Plan Card matching Screenshot 1
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderSlate.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Subscription Plan + Aktif: Gratis badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subscription Plan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Aktif: Gratis',
                      style: TextStyle(
                        color: Color(0xFF4338CA),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Checklist Features
              _buildPlanFeature('Kuota sosial 100 TC per bulan'),
              const SizedBox(height: 10),
              _buildPlanFeature('2 slot proyek aktif'),
              const SizedBox(height: 10),
              _buildPlanFeature('Admin top up 5%'),
              const SizedBox(height: 16),

              // Navy Promotion Box for Partner Pro
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Partner Pro · Rp49.000/bulan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '10 slot proyek, 0% admin top up, perpanjang kolaborasi, dan rekomendasi mentor tanpa batas.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.msmeUpgradePro);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Upgrade',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Menu List Card matching Screenshot 2
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderSlate.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Edit Detail Usaha
              _buildStoreMenuRow(
                icon: Icons.edit_outlined,
                title: 'Edit Detail Usaha',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.msmeRegister);
                },
              ),
              const Divider(color: AppColors.borderSlate, height: 1, indent: 64),

              // 2. Dokumen & Verifikasi
              _buildStoreMenuRow(
                icon: Icons.badge_outlined,
                title: 'Dokumen & Verifikasi',
                onTap: () => _showDocumentsModal(context),
              ),
              const Divider(color: AppColors.borderSlate, height: 1, indent: 64),

              // 3. Riwayat TimeCoin
              _buildStoreMenuRow(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat TimeCoin',
                onTap: () => _showTimeCoinHistoryModal(context),
              ),
              const Divider(color: AppColors.borderSlate, height: 1, indent: 64),

              // 4. Pusat Bantuan
              _buildStoreMenuRow(
                icon: Icons.help_outline_rounded,
                title: 'Pusat Bantuan',
                onTap: () => _showHelpCenterModal(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. Centered Logout Action matching Screenshot 2
        Center(
          child: InkWell(
            onTap: () => _confirmLogout(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );

  static Widget _buildPlanFeature(String text) => Row(
    children: [
      const Icon(
        Icons.check_circle_rounded,
        color: Color(0xFF10B981),
        size: 18,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkSlate,
          ),
        ),
      ),
    ],
  );

  static Widget _buildStoreMenuRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.darkSlate,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkSlate,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondarySlate,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

class _StoreMetricCol extends StatelessWidget {
  const _StoreMetricCol({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppColors.darkSlate,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.secondarySlate,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _StoreMetricDivider extends StatelessWidget {
  const _StoreMetricDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 30,
    color: AppColors.borderSlate,
  );
}

