import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/profile/data/student_profile_api.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({
    super.key,
    this.profileApi,
    this.walletApi,
    this.authApi,
  });

  final StudentProfileApi? profileApi;
  final WalletApi? walletApi;
  final AuthApi? authApi;

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  late final StudentProfileApi _profileApi =
      widget.profileApi ?? StudentProfileApi.instance;
  late final WalletApi _walletApi = widget.walletApi ?? WalletApi.instance;
  late final AuthApi _authApi = widget.authApi ?? AuthApi();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _profile = const {};
  int _balanceTc = 0;

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
      final results = await Future.wait<dynamic>([
        _profileApi.profile(),
        _safeBalance(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as Map<String, dynamic>;
        _balanceTc = results[1] as int;
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
          _error = 'Gagal memuat pengaturan akun.';
          _isLoading = false;
        });
      }
    }
  }

  Future<int> _safeBalance() async {
    try {
      final summary = await _walletApi.summary();
      return (summary['balance_tc'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return (_profile['balance_tc'] as num?)?.toInt() ?? 0;
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Anda perlu masuk kembali untuk mengakses dasbor mahasiswa.',
          style: TextStyle(color: AppColors.secondarySlate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _authApi.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (_profile['name'] as String?) ?? 'Mahasiswa';
    final email = (_profile['email'] as String?) ?? '-';
    final completed =
        (_profile['completed_projects_count'] as num?)?.toInt() ?? 0;
    final ktmVerified = _profile['ktm_verification_status'] == 'approved';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                        children: [
                          _buildAccountBanner(name, email, ktmVerified),
                          const SizedBox(height: 16),
                          _sectionTitle('AKUN & PORTOFOLIO'),
                          _menuTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profil & Keahlian',
                            subtitle: 'Foto, universitas, GitHub, skill',
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.editProfile,
                              );
                              if (mounted) _load();
                            },
                          ),
                          _menuTile(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Dompet TimeCoin',
                            subtitle: 'Saldo aktif: $_balanceTc TC',
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.wallet),
                          ),
                          _menuTile(
                            icon: Icons.workspace_premium_rounded,
                            title: 'Sertifikat & Rekomendasi',
                            subtitle: 'Lihat lencana proyek dan mentor',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.certificates,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _sectionTitle('PERAN & KEAMANAN'),
                          _menuTile(
                            icon: Icons.school_rounded,
                            title: 'Beralih Menjadi Peer Mentor',
                            subtitle: 'Progres proyek selesai: $completed/5',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.switchToMentor,
                            ),
                          ),
                          _menuTile(
                            icon: Icons.security_rounded,
                            title: 'Privasi, PIN & Keamanan',
                            subtitle: '2FA, PIN 6-digit, sesi perangkat, hapus akun',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.privacySecurity,
                            ),
                          ),
                          _menuTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Bantuan & Pusat Mediasi',
                            subtitle: 'FAQ dan laporan kendala transaksi',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.helpSupport,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFB91C1C),
                                side: const BorderSide(
                                  color: Color(0xFFFCA5A5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _logout,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text(
                                'Keluar dari Sesi Akun',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
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
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pengaturan Mahasiswa',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBanner(String name, String email, bool ktmVerified) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.lightBlueSurface,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'M',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: ktmVerified
                        ? AppColors.lightGreenSurface
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ktmVerified ? 'KTM Terverifikasi' : 'KTM Menunggu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ktmVerified
                          ? const Color(0xFF15803D)
                          : AppColors.accentAmberDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.secondarySlate,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSlate),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightBlueSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryNavy, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.secondarySlate),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.secondarySlate,
        ),
        onTap: onTap,
      ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
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
}
