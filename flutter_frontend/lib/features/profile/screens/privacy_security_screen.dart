import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/profile/data/student_profile_api.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({
    super.key,
    this.profileApi,
    this.authApi,
  });

  final StudentProfileApi? profileApi;
  final AuthApi? authApi;

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  late final StudentProfileApi _profileApi =
      widget.profileApi ?? StudentProfileApi.instance;
  late final AuthApi _authApi = widget.authApi ?? AuthApi();

  bool _isLoading = true;
  String? _error;

  bool _twoFactorEnabled = false;
  bool _publicPortfolio = true;
  bool _showOnlineStatus = true;
  bool _showEndorseBadge = true;
  bool _hasPin = false;
  List<Map<String, dynamic>> _sessions = const [];

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
        _profileApi.privacy(),
        _authApi.sessions(),
      ]);
      if (!mounted) return;
      final privacy = results[0] as Map<String, dynamic>;
      setState(() {
        _twoFactorEnabled = privacy['two_factor_enabled'] == true;
        _publicPortfolio = privacy['is_public_profile'] != false;
        _showOnlineStatus = privacy['show_online_status'] != false;
        _showEndorseBadge = privacy['show_endorse_badge'] != false;
        _hasPin = privacy['has_transaction_pin'] == true;
        _sessions = results[1] as List<Map<String, dynamic>>;
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
          _error = 'Gagal memuat pengaturan privasi dan keamanan.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePrivacy(String field, bool nextValue) async {
    final prev2fa = _twoFactorEnabled;
    final prevPub = _publicPortfolio;
    final prevOnline = _showOnlineStatus;
    final prevEndorse = _showEndorseBadge;

    setState(() {
      if (field == 'two_factor_enabled') _twoFactorEnabled = nextValue;
      if (field == 'is_public_profile') _publicPortfolio = nextValue;
      if (field == 'show_online_status') _showOnlineStatus = nextValue;
      if (field == 'show_endorse_badge') _showEndorseBadge = nextValue;
    });

    try {
      await _profileApi.updatePrivacy({field: nextValue});
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _twoFactorEnabled = prev2fa;
        _publicPortfolio = prevPub;
        _showOnlineStatus = prevOnline;
        _showEndorseBadge = prevEndorse;
      });
      _showSnack(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _twoFactorEnabled = prev2fa;
        _publicPortfolio = prevPub;
        _showOnlineStatus = prevOnline;
        _showEndorseBadge = prevEndorse;
      });
      _showSnack('Gagal memperbarui preferensi privasi.', isError: true);
    }
  }

  void _openPinDialog() {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _hasPin ? 'Ubah PIN Transaksi' : 'Buat PIN Transaksi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'PIN 6 Digit Angka',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final pin = pinCtrl.text.trim();
              if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                _showSnack('PIN harus terdiri dari 6 digit angka.', isError: true);
                return;
              }
              Navigator.pop(ctx);
              try {
                await _profileApi.updatePin(pin);
                if (!mounted) return;
                setState(() => _hasPin = true);
                _showSnack('PIN keamanan transaksi berhasil disimpan.');
              } on ApiException catch (e) {
                _showSnack(e.message, isError: true);
              } catch (_) {
                _showSnack('Gagal menyimpan PIN.', isError: true);
              }
            },
            child: const Text('Simpan PIN'),
          ),
        ],
      ),
    ).whenComplete(pinCtrl.dispose);
  }

  Future<void> _revokeOtherSessions() async {
    try {
      final msg = await _authApi.revokeOtherSessions();
      if (!mounted) return;
      _showSnack(msg);
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal mengeluarkan perangkat lain.', isError: true);
    }
  }

  Future<void> _logout() async {
    await _authApi.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (_) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Akun Permanen?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFB91C1C),
          ),
        ),
        content: const Text(
          'Tindakan ini akan menonaktifkan akun, menghapus sesi akses, dan memutus koneksi profil Anda.',
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
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _profileApi.deleteAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.roleSelection,
        (_) => false,
      );
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal menghapus akun mahasiswa.', isError: true);
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
                          _buildSecuritySwitches(),
                          const SizedBox(height: 16),
                          _buildPinCard(),
                          const SizedBox(height: 16),
                          _buildSessionsCard(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryNavy,
                                side: const BorderSide(
                                  color: AppColors.primaryNavy,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _logout,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text(
                                'Keluar dari Akun Ini',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB91C1C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _confirmDeleteAccount,
                              icon: const Icon(Icons.delete_forever_rounded),
                              label: const Text(
                                'Hapus Akun Permanen',
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
              'Privasi & Keamanan',
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

  Widget _buildSecuritySwitches() {
    return Material(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSlate),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Verifikasi Dua Langkah (2FA)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Tambahan konfirmasi saat masuk perangkat baru',
              style: TextStyle(fontSize: 12),
            ),
            activeThumbColor: AppColors.primaryNavy,
            value: _twoFactorEnabled,
            onChanged: (v) => _togglePrivacy('two_factor_enabled', v),
          ),
          const Divider(height: 1, color: AppColors.borderSlate),
          SwitchListTile(
            title: const Text(
              'Portofolio Dapat Dilihat UMKM',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            activeThumbColor: AppColors.primaryNavy,
            value: _publicPortfolio,
            onChanged: (v) => _togglePrivacy('is_public_profile', v),
          ),
          const Divider(height: 1, color: AppColors.borderSlate),
          SwitchListTile(
            title: const Text(
              'Tampilkan Status Online',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            activeThumbColor: AppColors.primaryNavy,
            value: _showOnlineStatus,
            onChanged: (v) => _togglePrivacy('show_online_status', v),
          ),
          const Divider(height: 1, color: AppColors.borderSlate),
          SwitchListTile(
            title: const Text(
              'Tampilkan Lencana Rekomendasi Mentor',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            activeThumbColor: AppColors.primaryNavy,
            value: _showEndorseBadge,
            onChanged: (v) => _togglePrivacy('show_endorse_badge', v),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pin_rounded, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PIN Transaksi TimeCoin',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  _hasPin ? 'PIN 6-digit sudah aktif' : 'Belum diatur',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
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
              onPressed: _openPinDialog,
              child: Text(_hasPin ? 'Ubah PIN' : 'Atur PIN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sesi Perangkat Aktif',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          if (_sessions.isEmpty)
            const Text(
              'Hanya perangkat ini yang tercatat aktif.',
              style: TextStyle(fontSize: 12.5, color: AppColors.secondarySlate),
            )
          else
            ..._sessions.map((s) {
              final current = s['is_current'] == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.smartphone_rounded,
                      size: 18,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (s['device_name'] as String?) ?? 'Perangkat',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (current)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Perangkat Ini',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _revokeOtherSessions,
              child: const Text('Keluarkan Semua Perangkat Lain'),
            ),
          ),
        ],
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
