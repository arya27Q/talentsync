import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/auth/widgets/msme_logo_modal.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';

class MsmeStoreProfileScreen extends StatefulWidget {
  const MsmeStoreProfileScreen({super.key, this.msmeApi, this.authApi});

  final MsmeApi? msmeApi;
  final AuthApi? authApi;

  @override
  State<MsmeStoreProfileScreen> createState() => _MsmeStoreProfileScreenState();
}

class _MsmeStoreProfileScreenState extends State<MsmeStoreProfileScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;
  late final AuthApi _authApi = widget.authApi ?? AuthApi();
  Map<String, dynamic>? _sessionUser;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = await ApiClient.instance.readSessionUser();
    if (mounted && session != null) {
      setState(() {
        _sessionUser = session;
      });
    }
    try {
      final data = await _msmeApi.getProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
        });
      }
    } catch (_) {}
  }

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
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _authApi.logout();
              if (!context.mounted) return;
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

  Future<void> _showEditBusinessDetailsModal() async {
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.msmeEditProfile,
    );
    if (updated == true || mounted) {
      await _loadProfile();
    }
  }

  Future<void> _promptInputNib() async {
    final nibCtrl = TextEditingController(
      text: (_profileData?['nib'] as String?) ??
          (_sessionUser?['nib'] as String?) ??
          '',
    );
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Nomor Induk Berusaha (NIB)',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan 13 digit NIB terdaftar dari OSS untuk status Verified Partner.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nibCtrl,
                keyboardType: TextInputType.number,
                decoration: _editInputDecoration(
                  Icons.badge_rounded,
                  'Contoh: 1289004521001',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.secondarySlate),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final val = nibCtrl.text.trim();
                      if (val.isEmpty) {
                        Navigator.pop(dialogCtx);
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      try {
                        await _msmeApi.updateProfile({'nib': val});
                        await ApiClient.instance.updateSessionUser({'nib': val});
                        if (!dialogCtx.mounted) return;
                        Navigator.pop(dialogCtx);
                        await _loadProfile();
                        if (!mounted) return;
                        AppStatusDialog.showSuccess(
                          context,
                          title: 'NIB Tersimpan',
                          message: 'Nomor Induk Berusaha berhasil diverifikasi.',
                        );
                      } catch (err) {
                        setDialogState(() => isSaving = false);
                        if (!dialogCtx.mounted) return;
                        AppStatusDialog.showError(
                          dialogCtx,
                          title: 'Gagal Menyimpan NIB',
                          message: '$err',
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
    nibCtrl.dispose();
  }

  void _showDocumentsModal(BuildContext context) {
    final businessName = (_profileData?['business_name'] as String?) ??
        (_sessionUser?['business_name'] as String?) ??
        'Kemitraan UMKM';
    final nib = (_profileData?['nib'] as String?) ??
        (_sessionUser?['nib'] as String?);
    final hasNib = nib != null && nib.trim().isNotEmpty;

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
              Text(
                'Status legalitas kemitraan $businessName',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 20),
              _buildDocItem(
                icon: Icons.assignment_turned_in_rounded,
                title: 'NIB (Nomor Induk Berusaha)',
                subtitle: hasNib
                    ? 'NIB: $nib · Terverifikasi OSS / KBLI'
                    : 'NIB belum didaftarkan (Ketuk untuk mendaftarkan NIB)',
                status: hasNib ? 'Terverifikasi' : 'Daftarkan',
                isVerified: hasNib,
                onTap: () async {
                  Navigator.pop(modalContext);
                  await _promptInputNib();
                },
              ),
              const SizedBox(height: 12),
              _buildDocItem(
                icon: Icons.workspace_premium_rounded,
                title: 'Lencana Verified Partner',
                subtitle: 'Kemitraan resmi TalentSync terverifikasi aktif',
                status: 'Aktif',
                isVerified: true,
              ),
              const SizedBox(height: 12),
              _buildDocItem(
                icon: Icons.account_balance_rounded,
                title: 'Rekening Bank Terdaftar',
                subtitle: 'Rekening Usaha Mitra · Terhubung Smart Escrow',
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
    final balanceTc = (_profileData?['balance_tc'] as num?)?.toInt() ??
        (_sessionUser?['balance_tc'] as num?)?.toInt() ??
        0;

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
                'Saldo aktif setara Rp${balanceTc * 1000} · Smart Escrow',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 18),
              if (balanceTc == 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.secondarySlate,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum Ada Transaksi TimeCoin',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'TimeCoin adalah kredit kolaborasi TalentSync untuk imbalan proyek mahasiswa. Saldo akan bertambah saat Anda melakukan Top Up atau program insentif.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildMutationTile(
                  title: 'Alokasi Saldo Kemitraan Aktif',
                  date: 'Hari ini · Dompet Usaha Terverifikasi',
                  amount: '+$balanceTc TC',
                  isIncome: true,
                ),
                const Divider(color: AppColors.borderSlate, height: 16),
                _buildMutationTile(
                  title: 'Kuota Sosial Bulanan Mahasiswa',
                  date: 'Tersedia · Subsidi TalentSync',
                  amount: '+20 TC',
                  isIncome: true,
                ),
              ],
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
                  '+62 821-2345-6789 · Jam kerja 08.00 - 18.00 WIB',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menghubungkan ke WhatsApp Care Mitra (+62 821-2345-6789)...'),
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
                  'Buka Layanan Bantuan & FAQ Lengkap',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.darkSlate,
                  ),
                ),
                subtitle: const Text(
                  'Panduan validasi escrow, FAQ kemitraan, & syarat ketentuan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  Navigator.pushNamed(context, AppRoutes.helpSupport);
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

  static InputDecoration _editInputDecoration(IconData icon, String hint) =>
      InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.secondarySlate, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13.5,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryNavy, width: 1.5),
        ),
      );

  static Widget _buildDocItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required bool isVerified,
    VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              color: isVerified
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isVerified
                    ? const Color(0xFF059669)
                    : AppColors.secondarySlate,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.secondarySlate,
            ),
          ],
        ],
      ),
    ),
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
  Widget build(BuildContext context) {
    final businessName = (_profileData?['business_name'] as String?) ??
        (_sessionUser?['business_name'] as String?) ??
        'Usaha Anda';
    final sector = (_profileData?['business_sector'] as String?) ??
        (_sessionUser?['business_sector'] as String?) ??
        'Kuliner';
    final city = (_profileData?['city'] as String?) ??
        (_sessionUser?['city'] as String?) ??
        'Surabaya';
    final logoUrl = (_profileData?['logo_url'] as String?) ??
        (_sessionUser?['logo_url'] as String?) ??
        (_sessionUser?['avatar_url'] as String?);
    final completedProjectsCount =
        (_profileData?['completed_projects_count'] as num?)?.toInt() ?? 0;
    final ratingNum = (_profileData?['rating'] as num?)?.toDouble() ?? 0.0;
    final ratingStr = ratingNum > 0 ? ratingNum.toStringAsFixed(1) : '0';
    final mentoredStudentsCount =
        (_profileData?['mentored_students_count'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: AppColors.primaryNavy,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // Screen Header matching Screenshot 1
              const Text(
                'Profil Toko & Usaha',
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
                        InkWell(
                          onTap: _showEditBusinessDetailsModal,
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              MsmeLogoHelper.buildLogoWidget(
                                logoUrl: logoUrl,
                                size: 70,
                                borderRadius: 20,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryNavy,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                businessName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkSlate,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Klaster $sector · $city',
                                style: const TextStyle(
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
                              Flexible(
                                child: Text(
                                  'Verified Partner',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                  ),
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
                  children: [
                    Expanded(
                      child: _StoreMetricCol(
                        value: '$completedProjectsCount',
                        label: 'Proyek selesai',
                      ),
                    ),
                    const _StoreMetricDivider(),
                    Expanded(
                      child: _StoreMetricCol(
                        value: ratingStr,
                        label: 'Penilaian mahasiswa',
                      ),
                    ),
                    const _StoreMetricDivider(),
                    Expanded(
                      child: _StoreMetricCol(
                        value: '$mentoredStudentsCount',
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

        // Showcase Carousel: Galeri Foto Suasana Toko & Produk
        const InteractiveImageCarousel(
          margin: EdgeInsets.zero,
          height: 180,
          items: [
            CarouselSlideItem(
              imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
              tag: 'Suasana Toko',
              tagColor: AppColors.primaryNavy,
              title: 'Barista & Area Seduh Kopi Tepi Kali',
              subtitle: 'Area pelayanan ramah pelanggan dengan standar higienis dan racikan kopi berkualitas.',
              buttonText: 'Galeri',
            ),
            CarouselSlideItem(
              imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
              tag: 'Produk Unggulan',
              tagColor: Color(0xFFB45309),
              title: 'Biji Kopi Sangrai & Kemasan Kraft',
              subtitle: 'Hasil desain kemasan karya mahasiswa yang meningkatkan daya tarik penjualan online.',
              buttonText: 'Produk',
            ),
            CarouselSlideItem(
              imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
              tag: 'Ruang Kolaborasi',
              tagColor: Color(0xFF10B981),
              title: 'Dapur Kerja & Diskusi Proyek',
              subtitle: 'Ruang temu kreatif mahasiswa dan pemilik toko saat perancangan prototipe produk.',
              buttonText: 'Lokasi',
            ),
          ],
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
                children: [
                  const Expanded(
                    child: Text(
                      'Subscription Plan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          'Tingkatkan',
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
                icon: Icons.edit_rounded,
                title: 'Ubah Detail Usaha',
                onTap: _showEditBusinessDetailsModal,
              ),
              const Divider(
                color: AppColors.borderSlate,
                height: 1,
                indent: 64,
              ),

              // 2. Dokumen & Verifikasi
              _buildStoreMenuRow(
                icon: Icons.badge_rounded,
                title: 'Dokumen & Verifikasi',
                onTap: () => _showDocumentsModal(context),
              ),
              const Divider(
                color: AppColors.borderSlate,
                height: 1,
                indent: 64,
              ),

              // 3. Riwayat TimeCoin
              _buildStoreMenuRow(
                icon: Icons.receipt_long_rounded,
                title: 'Riwayat TimeCoin',
                onTap: () => _showTimeCoinHistoryModal(context),
              ),
              const Divider(
                color: AppColors.borderSlate,
                height: 1,
                indent: 64,
              ),

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
  ),
  ),
  );
}

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
              child: Icon(icon, color: AppColors.darkSlate, size: 20),
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
  const _StoreMetricCol({required this.value, required this.label});

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
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: AppColors.borderSlate);
}
