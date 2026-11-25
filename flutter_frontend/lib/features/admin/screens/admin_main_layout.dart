import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/admin/data/admin_api.dart';
import 'package:flutter_frontend/features/admin/widgets/admin_catalog_panel.dart';
import 'package:flutter_frontend/features/admin/widgets/admin_csv_dialog.dart';
import 'package:flutter_frontend/features/admin/widgets/admin_security_panel.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key, this.adminApi});

  final AdminApi? adminApi;

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  static const Color _softCanvas = Color(0xFFEFF3F9);
  static const Color _softSurfaceMuted = Color(0xFFF7F9FC);
  static const Color _softBorder = Color(0xFFE3EAF4);
  static const Color _softActiveBg = Color(0xFFEEF2FF);
  static const Color _captionSlate = Color(0xFF475569);

  late final AdminApi _api = widget.adminApi ?? AdminApi.instance;

  int _selectedSection = 0;
  int _projectLedgerTab = 0; // 0 = Moderasi Proyek, 1 = Audit Ledger
  bool _loading = true;
  String? _error;

  Map<String, dynamic> _dashboard = const {};
  List<Map<String, dynamic>> _cashOuts = const [];
  List<Map<String, dynamic>> _premiumSubs = const [];
  List<Map<String, dynamic>> _disputes = const [];
  List<Map<String, dynamic>> _users = const [];
  int _usersPage = 1;
  int _usersLastPage = 1;
  int _usersTotal = 0;
  List<Map<String, dynamic>> _projects = const [];
  int _projectsPage = 1;
  int _projectsLastPage = 1;
  int _projectsTotal = 0;
  List<Map<String, dynamic>> _transactions = const [];
  int _txPage = 1;
  int _txLastPage = 1;
  int _txTotal = 0;

  String _disputeStatus = 'all';
  String _userRoleFilter = 'all';
  String _projectStatusFilter = 'all';
  String _txTypeFilter = 'all';
  final _userSearchCtrl = TextEditingController();
  final _projectSearchCtrl = TextEditingController();
  Timer? _idleTimer;
  static const Duration _idleTimeout = Duration(minutes: 20);

  static const _navItems =
      <({String label, String subtitle, String group, IconData icon})>[
        (
          label: 'Ringkasan',
          subtitle: 'Pantau kesehatan ekosistem Mahasiswa, UMKM, dan Mentor',
          group: 'OPERASIONAL',
          icon: Icons.dashboard_rounded,
        ),
        (
          label: 'Persetujuan',
          subtitle:
              'Verifikasi pencairan dana Cash-Out dan aktivasi Mentor Premium',
          group: 'OPERASIONAL',
          icon: Icons.fact_check_rounded,
        ),
        (
          label: 'Sengketa',
          subtitle: 'Mediasi laporan kendala proyek, mentoring, dan escrow',
          group: 'OPERASIONAL',
          icon: Icons.gavel_rounded,
        ),
        (
          label: 'Pengguna 3 POV',
          subtitle: 'Kelola verifikasi identitas Mahasiswa, UMKM, dan Mentor',
          group: 'EKOSISTEM',
          icon: Icons.groups_rounded,
        ),
        (
          label: 'Proyek & Ledger',
          subtitle: 'Moderasi lowongan proyek UMKM dan audit mutasi TimeCoin',
          group: 'EKOSISTEM',
          icon: Icons.account_balance_wallet_rounded,
        ),
        (
          label: 'Keamanan & Audit',
          subtitle:
              'Deteksi anomali TimeCoin, audit log, broadcast, dan sesi admin',
          group: 'KEAMANAN',
          icon: Icons.shield_rounded,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _resetIdleTimer();
    _loadCurrentSection();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _userSearchCtrl.dispose();
    _projectSearchCtrl.dispose();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, () {
      if (!mounted) return;
      _showSnack(
        'Sesi admin berakhir otomatis karena tidak ada aktivitas selama 20 menit.',
        isError: true,
      );
      _logout();
    });
  }

  Future<void> _loadCurrentSection() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      switch (_selectedSection) {
        case 0:
          final dash = await _api.dashboard();
          if (!mounted) return;
          setState(() => _dashboard = dash);
        case 1:
          final results = await Future.wait([
            _api.pendingCashOuts(),
            _api.pendingMentorPremium(),
          ]);
          if (!mounted) return;
          setState(() {
            _cashOuts = results[0];
            _premiumSubs = results[1];
          });
        case 2:
          final list = await _api.disputes(status: _disputeStatus);
          if (!mounted) return;
          setState(() => _disputes = list);
        case 3:
          final pageRes = await _api.usersPage(
            role: _userRoleFilter,
            search: _userSearchCtrl.text,
            page: _usersPage,
          );
          if (!mounted) return;
          setState(() {
            _users = pageRes.items;
            _usersPage = pageRes.currentPage;
            _usersLastPage = pageRes.lastPage;
            _usersTotal = pageRes.total;
          });
        case 4:
          final results = await Future.wait([
            _api.projectsPage(
              status: _projectStatusFilter,
              search: _projectSearchCtrl.text,
              page: _projectsPage,
            ),
            _api.transactionsPage(type: _txTypeFilter, page: _txPage),
          ]);
          if (!mounted) return;
          final projRes = results[0];
          final txRes = results[1];
          setState(() {
            _projects = projRes.items;
            _projectsPage = projRes.currentPage;
            _projectsLastPage = projRes.lastPage;
            _projectsTotal = projRes.total;
            _transactions = txRes.items;
            _txPage = txRes.currentPage;
            _txLastPage = txRes.lastPage;
            _txTotal = txRes.total;
          });
        case 5:
          break;
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Gagal memuat data dari server admin.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectSection(int index) {
    if (_selectedSection == index) return;
    setState(() => _selectedSection = index);
    _loadCurrentSection();
  }

  Future<void> _logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Clear local session regardless of network state.
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.adminLogin,
      (_) => false,
    );
  }

  Future<bool> _confirmCriticalPassword(String title) async {
    final pwdCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi ini berdampak langsung pada dana atau akses pengguna. Masukkan kata sandi administrator untuk melanjutkan.',
              style: TextStyle(fontSize: 12.5, color: _captionSlate),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwdCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Admin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
            ),
            onPressed: () async {
              try {
                await _api.confirmAdminPassword(pwdCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx, true);
              } on ApiException catch (e) {
                _showSnack(e.message, isError: true);
              }
            },
            child: const Text('Verifikasi & Lanjutkan'),
          ),
        ],
      ),
    );
    pwdCtrl.dispose();
    return confirmed == true;
  }

  Future<void> _handleCashOut(int id, String status, {int amountTc = 0}) async {
    if (status == 'completed' && amountTc >= 300) {
      final ok = await _confirmCriticalPassword(
        'Konfirmasi Pencairan Tinggi ($amountTc TC)',
      );
      if (!ok) return;
    }
    try {
      await _api.resolveCashOut(id, status);
      if (!mounted) return;
      _showSnack(
        status == 'completed'
            ? 'Pencairan dana berhasil disetujui.'
            : 'Pencairan ditolak dan saldo TC dikembalikan.',
      );
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _handleMentorPremium(int id, String paymentStatus) async {
    try {
      await _api.resolveMentorPremium(id, paymentStatus);
      if (!mounted) return;
      _showSnack(
        paymentStatus == 'paid'
            ? 'Status Mentor Premium berhasil diaktifkan.'
            : 'Pengajuan Mentor Premium ditolak.',
      );
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _openResolveDisputeDialog(Map<String, dynamic> dispute) async {
    final notesCtrl = TextEditingController();
    String selectedStatus = 'resolved';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Putuskan Sengketa #${dispute['id']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dispute['category'] ?? 'Sengketa'} · ${dispute['reporter_name'] ?? 'Pengguna'}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (dispute['description'] as String?) ?? '',
                  style: const TextStyle(fontSize: 12.5, color: _captionSlate),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: _softInputDecoration('Keputusan Resolusi'),
                  items: const [
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Selesaikan (Resolved)'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Tolak Laporan (Rejected)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: _softInputDecoration(
                    'Tuliskan dasar keputusan mediasi (min. 10 karakter)...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (notesCtrl.text.trim().length < 10) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Simpan Keputusan'),
            ),
          ],
        ),
      ),
    );
    final notes = notesCtrl.text.trim();
    notesCtrl.dispose();
    if (confirmed != true || !mounted) return;

    try {
      await _api.resolveDispute(
        (dispute['id'] as num).toInt(),
        status: selectedStatus,
        resolutionNotes: notes,
      );
      if (!mounted) return;
      _showSnack('Keputusan sengketa berhasil disimpan.');
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _updateUserVerification(
    Map<String, dynamic> user,
    String nextStatus,
  ) async {
    try {
      await _api.updateUserVerification(
        (user['id'] as num).toInt(),
        status: nextStatus,
        targetRole: (user['role'] as String?) ?? 'student',
      );
      if (!mounted) return;
      _showSnack('Verifikasi ${user['name']} diperbarui menjadi $nextStatus.');
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _toggleProjectStatus(Map<String, dynamic> project) async {
    final current = (project['status'] as String?) ?? 'open';
    final nextStatus = current == 'cancelled' ? 'open' : 'cancelled';
    try {
      await _api.updateProjectStatus(
        (project['id'] as num).toInt(),
        status: nextStatus,
        reason: nextStatus == 'cancelled'
            ? 'Dinonaktifkan melalui moderasi Admin.'
            : 'Diaktifkan kembali oleh Admin.',
      );
      if (!mounted) return;
      _showSnack('Status proyek diperbarui menjadi $nextStatus.');
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _toggleUserSuspension(Map<String, dynamic> user) async {
    final isSuspended = user['is_suspended'] == true;
    final userId = (user['id'] as num).toInt();
    final userName = (user['name'] as String?) ?? 'Pengguna';

    if (isSuspended) {
      try {
        await _api.updateUserSuspension(userId, isSuspended: false);
        if (!mounted) return;
        _showSnack('Pembekuan akun $userName berhasil dibuka kembali.');
        await _loadCurrentSection();
      } on ApiException catch (e) {
        if (mounted) _showSnack(e.message, isError: true);
      }
      return;
    }

    final reasonCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Bekukan Akun $userName',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seluruh sesi login pengguna akan langsung dicabut paksa dan akses masuk diblokir hingga blokir dibuka.',
                style: TextStyle(fontSize: 12.5, color: _captionSlate),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: _softInputDecoration(
                  'Alasan pembekuan akun (min. 5 karakter)...',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pwdCtrl,
                obscureText: true,
                decoration: _softInputDecoration(
                  'Kata Sandi Admin (konfirmasi keamanan)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            onPressed: () {
              if (reasonCtrl.text.trim().length < 5) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Bekukan & Cabut Sesi'),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text.trim();
    final adminPwd = pwdCtrl.text;
    reasonCtrl.dispose();
    pwdCtrl.dispose();
    if (confirmed != true || !mounted) return;

    try {
      await _api.updateUserSuspension(
        userId,
        isSuspended: true,
        reason: reason,
        adminPassword: adminPwd.isEmpty ? null : adminPwd,
      );
      if (!mounted) return;
      _showSnack('Akun $userName dibekukan dan seluruh sesinya telah dicabut.');
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _forceLogoutUser(Map<String, dynamic> user) async {
    final userId = (user['id'] as num).toInt();
    final userName = (user['name'] as String?) ?? 'Pengguna';
    try {
      final revoked = await _api.forceLogoutUser(userId);
      if (!mounted) return;
      _showSnack(
        revoked > 0
            ? '$revoked sesi aktif milik $userName berhasil dicabut paksa.'
            : '$userName tidak memiliki sesi aktif.',
      );
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  Future<void> _openWalletAdjustmentDialog(Map<String, dynamic> user) async {
    final userId = (user['id'] as num).toInt();
    final userName = (user['name'] as String?) ?? 'Pengguna';
    String direction = 'credit';
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Sesuaikan Saldo: $userName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo bebas saat ini: ${user['balance_tc'] ?? 0} TC',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: direction,
                    decoration: _softInputDecoration('Jenis Penyesuaian'),
                    items: const [
                      DropdownMenuItem(
                        value: 'credit',
                        child: Text('Tambah / Refund (+TC)'),
                      ),
                      DropdownMenuItem(
                        value: 'debit',
                        child: Text('Potong / Koreksi (-TC)'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => direction = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _softInputDecoration('Nominal TimeCoin (TC)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    decoration: _softInputDecoration(
                      'Alasan penyesuaian / nomor sengketa (min. 5 karakter)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pwdCtrl,
                    obscureText: true,
                    decoration: _softInputDecoration(
                      'Kata Sandi Admin (wajib)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan Penyesuaian'),
            ),
          ],
        ),
      ),
    );

    final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
    final reason = reasonCtrl.text.trim();
    final pwd = pwdCtrl.text;
    amountCtrl.dispose();
    reasonCtrl.dispose();
    pwdCtrl.dispose();

    if (confirmed != true || !mounted) return;
    if (amount < 1 || reason.length < 5 || pwd.isEmpty) {
      _showSnack(
        'Isi nominal valid, alasan minimal 5 karakter, dan kata sandi admin.',
        isError: true,
      );
      return;
    }

    try {
      await _api.adjustUserWallet(
        userId,
        direction: direction,
        amountTc: amount,
        reason: reason,
        adminPassword: pwd,
      );
      if (!mounted) return;
      _showSnack('Saldo TimeCoin $userName berhasil disesuaikan.');
      await _loadCurrentSection();
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : AppColors.darkSlate,
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetIdleTimer(),
      onPointerSignal: (_) => _resetIdleTimer(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1024;
          final isTablet = width >= 640 && width < 1024;

          final bodyContent = Column(
            children: [
              _buildTopBar(
                showMenuButton: !isDesktop && !isTablet,
                isDesktop: isDesktop,
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryNavy,
                              strokeWidth: 2.6,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Memuat data portal admin...',
                              style: TextStyle(color: _captionSlate),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 420),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_off_rounded,
                                    size: 24,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: _captionSlate),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryNavy,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _loadCurrentSection,
                                  child: const Text('Muat Ulang'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 24 : 16,
                          isDesktop ? 20 : 14,
                          isDesktop ? 24 : 16,
                          28,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: _buildActiveSection(width),
                          ),
                        ),
                      ),
              ),
            ],
          );

          final canvasDecoration = const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F7FC), Color(0xFFEEF2F9), Color(0xFFF7F5F0)],
            ),
          );

          if (isDesktop) {
            return Scaffold(
              backgroundColor: _softCanvas,
              body: Container(
                decoration: canvasDecoration,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      child: _buildSidebar(),
                    ),
                    Expanded(child: bodyContent),
                  ],
                ),
              ),
            );
          }

          if (isTablet) {
            return Scaffold(
              backgroundColor: _softCanvas,
              body: Container(
                decoration: canvasDecoration,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _softBorder.withValues(alpha: 0.8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkSlate.withValues(
                                alpha: 0.045,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: NavigationRail(
                            backgroundColor: Colors.white,
                            selectedIndex: _selectedSection,
                            onDestinationSelected: _selectSection,
                            indicatorColor: _softActiveBg,
                            labelType: NavigationRailLabelType.all,
                            unselectedIconTheme: const IconThemeData(
                              color: _captionSlate,
                            ),
                            selectedIconTheme: const IconThemeData(
                              color: AppColors.primaryNavy,
                            ),
                            unselectedLabelTextStyle: const TextStyle(
                              color: _captionSlate,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            selectedLabelTextStyle: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            destinations: _navItems
                                .map(
                                  (item) => NavigationRailDestination(
                                    icon: Icon(item.icon),
                                    label: Text(item.label),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: bodyContent),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: _softCanvas,
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: SafeArea(child: _buildSidebar(isDrawer: true)),
            ),
            body: Container(
              decoration: canvasDecoration,
              child: SafeArea(child: bodyContent),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    final queues = (_dashboard['queues'] as Map<String, dynamic>?) ?? const {};
    final pendingApprovals =
        ((queues['pending_cash_outs'] as num?)?.toInt() ?? 0) +
        ((queues['pending_mentor_premium'] as num?)?.toInt() ?? 0);
    final openDisputes = (queues['open_disputes'] as num?)?.toInt() ?? 0;

    return Container(
      width: isDrawer ? double.infinity : 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDrawer ? null : BorderRadius.circular(24),
        border: isDrawer ? null : Border.all(color: _softBorder),
        boxShadow: isDrawer
            ? null
            : [
                BoxShadow(
                  color: AppColors.darkSlate.withValues(alpha: 0.055),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.accentAmberGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TalentSync',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Admin Web Portal',
                        style: TextStyle(
                          color: _captionSlate,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildGroupedNavItems(
                  isDrawer: isDrawer,
                  pendingApprovals: pendingApprovals,
                  openDisputes: openDisputes,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _softSurfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _softBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _softActiveBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin TalentSync',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'admin@talentsync.id',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: _captionSlate),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Keluar Admin',
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedNavItems({
    required bool isDrawer,
    required int pendingApprovals,
    required int openDisputes,
  }) {
    final widgets = <Widget>[];
    String? lastGroup;
    for (var i = 0; i < _navItems.length; i++) {
      final item = _navItems[i];
      if (item.group != lastGroup) {
        if (lastGroup != null) widgets.add(const SizedBox(height: 14));
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Text(
              item.group,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: _captionSlate,
                letterSpacing: 0.6,
              ),
            ),
          ),
        );
        lastGroup = item.group;
      }

      final active = _selectedSection == i;
      final badgeCount = i == 1
          ? pendingApprovals
          : (i == 2 ? openDisputes : 0);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: active ? _softActiveBg : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                hoverColor: _softSurfaceMuted,
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  _selectSection(i);
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 46),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 3.5,
                          height: active ? 20 : 0,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Icon(
                          item.icon,
                          size: 20,
                          color: active ? AppColors.primaryNavy : _captionSlate,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: active
                                  ? AppColors.primaryNavy
                                  : AppColors.darkSlate,
                              fontSize: 13.5,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (badgeCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildTopBar({required bool showMenuButton, bool isDesktop = true}) {
    final current = _navItems[_selectedSection];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 24 : 16,
        isDesktop ? 16 : 12,
        isDesktop ? 24 : 16,
        0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _softBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkSlate.withValues(alpha: 0.045),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                if (showMenuButton)
                  Builder(
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        tooltip: 'Buka menu admin',
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _softActiveBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      current.icon,
                      size: 20,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                          letterSpacing: -0.25,
                        ),
                      ),
                      Text(
                        current.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _captionSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isDesktop) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text(
                          'Sistem Aktif',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: _softBorder),
                    backgroundColor: _softSurfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  onPressed: _loadCurrentSection,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    'Segarkan',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
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

  Widget _buildActiveSection(double width) {
    return switch (_selectedSection) {
      0 => _buildDashboardSection(width),
      1 => _buildApprovalsSection(width),
      2 => _buildDisputesSection(),
      3 => _buildUsersSection(width),
      4 => _buildProjectsAndLedgerSection(width),
      _ => AdminSecurityPanel(api: _api, onNotify: _showSnack),
    };
  }

  Widget _buildDashboardSection(double width) {
    final users = (_dashboard['users'] as Map<String, dynamic>?) ?? const {};
    final projects =
        (_dashboard['projects'] as Map<String, dynamic>?) ?? const {};
    final economy =
        (_dashboard['economy'] as Map<String, dynamic>?) ?? const {};
    final queues = (_dashboard['queues'] as Map<String, dynamic>?) ?? const {};
    final recentTx = ((_dashboard['recent_transactions'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final isWide = width >= 960;
    final cols = isWide ? 4 : (width >= 600 ? 2 : 1);

    final recentTxCard = _panelCard(
      title: 'Mutasi TimeCoin Terbaru',
      subtitle: 'Catatan buku besar terbaru di seluruh peran',
      child: recentTx.isEmpty
          ? _emptyStateBox(
              Icons.receipt_long_rounded,
              'Belum ada transaksi TimeCoin tercatat.',
            )
          : Column(
              children: recentTx
                  .map((tx) => _transactionRow(tx))
                  .toList(growable: false),
            ),
    );

    final distributionCard = _panelCard(
      title: 'Komposisi Ekosistem 3 POV',
      subtitle: 'Distribusi aktual pengguna dan status proyek',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ratioBar(
            label: 'Mahasiswa',
            count: (users['students'] as num?)?.toInt() ?? 0,
            total: (users['total'] as num?)?.toInt() ?? 0,
            color: AppColors.primaryNavy,
          ),
          const SizedBox(height: 12),
          _ratioBar(
            label: 'Mitra UMKM',
            count: (users['msmes'] as num?)?.toInt() ?? 0,
            total: (users['total'] as num?)?.toInt() ?? 0,
            color: AppColors.accentAmberGold,
          ),
          const SizedBox(height: 12),
          _ratioBar(
            label: 'Peer Mentor',
            count: (users['mentors'] as num?)?.toInt() ?? 0,
            total: (users['total'] as num?)?.toInt() ?? 0,
            color: const Color(0xFF0F766E),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: _softBorder, height: 1),
          ),
          const Text(
            'Status Proyek UMKM',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _softStatPill(
                'Terbuka: ${projects['open'] ?? 0}',
                const Color(0xFFEEF2FF),
                AppColors.primaryNavy,
              ),
              _softStatPill(
                'Berjalan: ${projects['in_progress'] ?? 0}',
                const Color(0xFFFEF3C7),
                const Color(0xFF92400E),
              ),
              _softStatPill(
                'Selesai: ${projects['completed'] ?? 0}',
                const Color(0xFFDCFCE7),
                const Color(0xFF166534),
              ),
            ],
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionQueueBanner(queues),
        const SizedBox(height: 18),
        GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 144,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _metricCard(
              'Pengguna 3 POV',
              '${users['total'] ?? 0}',
              'Mhs ${users['students'] ?? 0} · UMKM ${users['msmes'] ?? 0} · Mentor ${users['mentors'] ?? 0}',
              Icons.groups_rounded,
              AppColors.primaryNavy,
              const Color(0xFFEEF2FF),
            ),
            _metricCard(
              'Proyek UMKM',
              '${projects['total'] ?? 0}',
              'Buka ${projects['open'] ?? 0} · Jalan ${projects['in_progress'] ?? 0} · Selesai ${projects['completed'] ?? 0}',
              Icons.work_outline_rounded,
              const Color(0xFF0F766E),
              const Color(0xFFECFDF5),
            ),
            _metricCard(
              'TimeCoin Beredar',
              '${economy['total_circulating_tc'] ?? 0} TC',
              'Saldo bebas di seluruh dompet',
              Icons.toll_rounded,
              const Color(0xFFB45309),
              const Color(0xFFFFFBEB),
            ),
            _metricCard(
              'Dana Smart Escrow',
              '${economy['total_locked_escrow_tc'] ?? 0} TC',
              'Tertahan aman pada proyek & sesi',
              Icons.lock_clock_rounded,
              AppColors.darkSlate,
              const Color(0xFFF1F5F9),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: recentTxCard),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: distributionCard),
            ],
          )
        else ...[
          recentTxCard,
          const SizedBox(height: 16),
          distributionCard,
        ],
      ],
    );
  }

  Widget _buildActionQueueBanner(Map<String, dynamic> queues) {
    final cashOuts = (queues['pending_cash_outs'] as num?)?.toInt() ?? 0;
    final premium = (queues['pending_mentor_premium'] as num?)?.toInt() ?? 0;
    final disputes = (queues['open_disputes'] as num?)?.toInt() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2345A3)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Antrean Tindakan Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _bannerPill('$cashOuts Cash-Out pending'),
                  _bannerPill('$premium Mentor Premium pending'),
                  _bannerPill('$disputes Sengketa terbuka'),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () => _selectSection(1),
                child: const Text(
                  'Buka Persetujuan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () => _selectSection(2),
                child: const Text(
                  'Tinjau Sengketa',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerPill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildApprovalsSection(double width) {
    final cashOutCard = _panelCard(
      title: 'Antrean Pencairan Dana Cash-Out (${_cashOuts.length})',
      subtitle: 'Transfer Rupiah ke rekening mahasiswa atau mentor',
      child: _cashOuts.isEmpty
          ? _emptyStateBox(
              Icons.check_circle_outline_rounded,
              'Semua pengajuan pencairan dana sudah diproses.',
            )
          : Column(
              children: _cashOuts.map((item) {
                final user =
                    (item['user'] as Map<String, dynamic>?) ?? const {};
                final id = (item['id'] as num).toInt();
                final amountTc = (item['amount_tc'] as num?)?.toInt() ?? 0;
                return _approvalTile(
                  initials: _initials((user['name'] as String?) ?? 'P'),
                  title: '${user['name'] ?? 'Pengguna'} · $amountTc TC',
                  subtitle:
                      '${item['bank_name'] ?? '-'} ${item['account_number'] ?? ''} (${item['account_holder_name'] ?? ''}) · Cair Rp${item['disbursed_amount_idr'] ?? 0}',
                  onApprove: () =>
                      _handleCashOut(id, 'completed', amountTc: amountTc),
                  onReject: () => _handleCashOut(id, 'failed'),
                  approveLabel: 'Setujui Transfer',
                  rejectLabel: 'Tolak & Refund',
                );
              }).toList(),
            ),
    );

    final premiumCard = _panelCard(
      title: 'Antrean Upgrade Mentor Premium (${_premiumSubs.length})',
      subtitle: 'Konfirmasi pembayaran paket 0% potongan admin',
      child: _premiumSubs.isEmpty
          ? _emptyStateBox(
              Icons.workspace_premium_rounded,
              'Tidak ada pengajuan Mentor Premium yang menunggu.',
            )
          : Column(
              children: _premiumSubs.map((item) {
                final mentor =
                    (item['mentor'] as Map<String, dynamic>?) ?? const {};
                final id = (item['id'] as num).toInt();
                return _approvalTile(
                  initials: _initials((mentor['name'] as String?) ?? 'M'),
                  title:
                      '${mentor['name'] ?? 'Mentor'} · ${mentor['email'] ?? ''}',
                  subtitle:
                      'Tagihan Rp${item['price_idr'] ?? 0} · Status: ${item['payment_status'] ?? 'pending'}',
                  onApprove: () => _handleMentorPremium(id, 'paid'),
                  onReject: () => _handleMentorPremium(id, 'failed'),
                  approveLabel: 'Aktifkan Premium',
                  rejectLabel: 'Tolak',
                );
              }).toList(),
            ),
    );

    if (width >= 960) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cashOutCard),
          const SizedBox(width: 16),
          Expanded(child: premiumCard),
        ],
      );
    }

    return Column(
      children: [cashOutCard, const SizedBox(height: 16), premiumCard],
    );
  }

  Widget _buildDisputesSection() {
    return _panelCard(
      title: 'Laporan Sengketa & Mediasi (${_disputes.length})',
      subtitle: 'Tinjau laporan kendala dan kirim keputusan tertulis',
      trailing: SizedBox(
        width: 180,
        child: DropdownButtonFormField<String>(
          initialValue: _disputeStatus,
          isExpanded: true,
          decoration: _softInputDecoration('Status'),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Semua Status')),
            DropdownMenuItem(value: 'open', child: Text('Terbuka')),
            DropdownMenuItem(value: 'resolved', child: Text('Selesai')),
            DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _disputeStatus = v);
            _loadCurrentSection();
          },
        ),
      ),
      child: _disputes.isEmpty
          ? _emptyStateBox(
              Icons.gavel_rounded,
              'Belum ada laporan sengketa pada filter ini.',
            )
          : Column(
              children: _disputes.map((d) {
                final isOpen = d['status'] == 'open';
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _softCanvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _softBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${d['id']} · ${d['category'] ?? 'Sengketa'} (${d['reference_type_label'] ?? ''})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          _statusBadge((d['status'] as String?) ?? 'open'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pelapor: ${d['reporter_name'] ?? '-'} (${d['reporter_email'] ?? ''})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _captionSlate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (d['description'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkSlate,
                          height: 1.45,
                        ),
                      ),
                      if ((d['resolution_notes'] as String?)?.isNotEmpty ==
                          true) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Keputusan: ${d['resolution_notes']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                      if (isOpen) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _openResolveDisputeDialog(d),
                          icon: const Icon(Icons.gavel_rounded, size: 17),
                          label: const Text('Putuskan Sengketa'),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildUsersSection(double width) {
    final isTable = width >= 900;
    return _panelCard(
      title: 'Direktori Pengguna 3 POV ($_usersTotal)',
      subtitle:
          'Saring berdasarkan peran dan kelola verifikasi serta akses akun',
      trailing: _tonalActionButton(
        label: 'Unduh CSV',
        icon: Icons.download_rounded,
        bg: const Color(0xFFEEF2FF),
        fg: AppColors.primaryNavy,
        height: 38,
        onPressed: () => showAdminCsvExportDialog(
          context,
          api: _api,
          resource: 'users',
          title: 'Daftar Pengguna 3 POV',
          onNotify: _showSnack,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _userSearchCtrl,
                  onSubmitted: (_) => _loadCurrentSection(),
                  decoration: _softInputDecoration('Cari nama atau email...')
                      .copyWith(
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      ),
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  initialValue: _userRoleFilter,
                  isExpanded: true,
                  decoration: _softInputDecoration('Peran'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua Peran')),
                    DropdownMenuItem(
                      value: 'student',
                      child: Text('Mahasiswa'),
                    ),
                    DropdownMenuItem(value: 'msme', child: Text('Mitra UMKM')),
                    DropdownMenuItem(value: 'mentor', child: Text('Mentor')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _userRoleFilter = v;
                      _usersPage = 1;
                    });
                    _loadCurrentSection();
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _usersPage = 1);
                    _loadCurrentSection();
                  },
                  child: const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_users.isEmpty)
            _emptyStateBox(
              Icons.person_search_rounded,
              'Tidak ada pengguna ditemukan pada filter ini.',
            )
          else ...[
            if (isTable)
              _tableHeaderBar([
                (label: 'PENGGUNA', flex: 4, width: null, alignEnd: false),
                (label: 'PERAN', flex: 2, width: null, alignEnd: false),
                (
                  label: 'SALDO & ESCROW',
                  flex: 2,
                  width: null,
                  alignEnd: false,
                ),
                (label: 'STATUS', flex: 2, width: null, alignEnd: false),
                (label: 'AKSI', flex: null, width: 248, alignEnd: true),
              ]),
            ..._users.map((u) {
              final ver = (u['verification_status'] as String?) ?? 'pending';
              final role = (u['role'] as String?) ?? 'student';
              final isSuspended = u['is_suspended'] == true;
              final roleLabel = switch (role) {
                'msme' => 'Mitra UMKM',
                'mentor' => 'Peer Mentor',
                _ => 'Mahasiswa',
              };

              final actionsWidget = Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _tonalActionButton(
                    label: isSuspended ? 'Buka' : 'Bekukan',
                    bg: isSuspended
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    fg: isSuspended
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                    onPressed: () => _toggleUserSuspension(u),
                  ),
                  const SizedBox(width: 6),
                  _tonalActionButton(
                    label: 'Saldo',
                    bg: const Color(0xFFEEF2FF),
                    fg: AppColors.primaryNavy,
                    onPressed: () => _openWalletAdjustmentDialog(u),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    tooltip: 'Aksi lainnya',
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'verify') {
                        _updateUserVerification(
                          u,
                          ver == 'approved' ? 'pending' : 'approved',
                        );
                      } else if (value == 'force_logout') {
                        _forceLogoutUser(u);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'verify',
                        child: Text(
                          ver == 'approved'
                              ? 'Tandai Pending'
                              : 'Verifikasi Akun',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'force_logout',
                        child: Text('Cabut Sesi Paksa'),
                      ),
                    ],
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        size: 18,
                        color: _captionSlate,
                      ),
                    ),
                  ),
                ],
              );

              if (isTable) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _roleBg(role),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials((u['name'] as String?) ?? 'U'),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _roleFg(role),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${u['name']} ($role)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  Text(
                                    '${u['email']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: _captionSlate,
                                    ),
                                  ),
                                  if (isSuspended)
                                    Text(
                                      'Dibekukan: ${u['suspended_reason'] ?? '-'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB91C1C),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _roleBg(role),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              roleLabel,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _roleFg(role),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${u['balance_tc'] ?? 0} TC',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              'Escrow ${u['locked_balance_tc'] ?? 0} TC',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _captionSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _statusBadge(isSuspended ? 'suspended' : ver),
                        ),
                      ),
                      SizedBox(
                        width: 248,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: actionsWidget,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${u['name']} ($role)',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        Text(
                          '${u['email']} · ${u['balance_tc'] ?? 0} TC',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _captionSlate,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _statusBadge(isSuspended ? 'suspended' : ver),
                        actionsWidget,
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          _paginationBar(
            currentPage: _usersPage,
            lastPage: _usersLastPage,
            total: _usersTotal,
            label: 'pengguna',
            onPageChanged: (p) {
              setState(() => _usersPage = p);
              _loadCurrentSection();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsAndLedgerSection(double width) {
    final isTable = width >= 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _softBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkSlate.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _segmentedPill(
                0,
                'Moderasi Proyek (${_projects.length})',
                Icons.work_outline_rounded,
              ),
              _segmentedPill(
                1,
                'Audit Buku Besar (${_transactions.length})',
                Icons.receipt_long_rounded,
              ),
              _segmentedPill(2, 'Kelas Mentoring', Icons.school_rounded),
              _segmentedPill(3, 'Katalog Reward', Icons.card_giftcard_rounded),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_projectLedgerTab == 0)
          _panelCard(
            title: 'Moderasi Proyek UMKM (${_projects.length})',
            subtitle: 'Pantau lowongan aktif dan nonaktifkan bila melanggar',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 230,
                      child: TextField(
                        controller: _projectSearchCtrl,
                        onSubmitted: (_) => _loadCurrentSection(),
                        decoration:
                            _softInputDecoration('Cari judul/bidang proyek...')
                                .copyWith(
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(
                      width: 175,
                      child: DropdownButtonFormField<String>(
                        initialValue: _projectStatusFilter,
                        isExpanded: true,
                        decoration: _softInputDecoration('Status'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Semua')),
                          DropdownMenuItem(
                            value: 'open',
                            child: Text('Terbuka'),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('Berjalan'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Selesai'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('Dibatalkan'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _projectStatusFilter = v);
                          _loadCurrentSection();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_projects.isEmpty)
                  _emptyStateBox(
                    Icons.work_off_outlined,
                    'Tidak ada proyek ditemukan pada filter ini.',
                  )
                else ...[
                  if (isTable)
                    _tableHeaderBar([
                      (
                        label: 'PROYEK & MITRA',
                        flex: 4,
                        width: null,
                        alignEnd: false,
                      ),
                      (label: 'BIDANG', flex: 2, width: null, alignEnd: false),
                      (label: 'IMBALAN', flex: 2, width: null, alignEnd: false),
                      (label: 'STATUS', flex: 2, width: null, alignEnd: false),
                      (label: 'AKSI', flex: null, width: 120, alignEnd: true),
                    ]),
                  ..._projects.map((p) {
                    final st = (p['status'] as String?) ?? 'open';
                    final actionWidget = st == 'completed'
                        ? const Text(
                            '-',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          )
                        : _tonalActionButton(
                            label: st == 'cancelled'
                                ? 'Aktifkan'
                                : 'Nonaktifkan',
                            bg: st == 'cancelled'
                                ? const Color(0xFFEEF2FF)
                                : const Color(0xFFFEF2F2),
                            fg: st == 'cancelled'
                                ? AppColors.primaryNavy
                                : const Color(0xFFB91C1C),
                            onPressed: () => _toggleProjectStatus(p),
                          );

                    if (isTable) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFF1F5F9)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: st == 'completed'
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      st == 'completed'
                                          ? Icons.task_alt_rounded
                                          : Icons.work_outline_rounded,
                                      size: 17,
                                      color: st == 'completed'
                                          ? const Color(0xFF15803D)
                                          : AppColors.primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (p['title'] as String?) ??
                                              'Proyek UMKM',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkSlate,
                                          ),
                                        ),
                                        Text(
                                          '${p['msme_name'] ?? '-'} · ${p['applications_count'] ?? 0} pelamar',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: _captionSlate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${p['category'] ?? '-'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _captionSlate,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${p['reward_tc'] ?? 0} TC',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _statusBadge(st),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: actionWidget,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (p['title'] as String?) ?? 'Proyek UMKM',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              Text(
                                '${p['msme_name'] ?? '-'} · ${p['reward_tc'] ?? 0} TC',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _captionSlate,
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [_statusBadge(st), actionWidget],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 12),
                _paginationBar(
                  currentPage: _projectsPage,
                  lastPage: _projectsLastPage,
                  total: _projectsTotal,
                  label: 'proyek',
                  onPageChanged: (p) {
                    setState(() => _projectsPage = p);
                    _loadCurrentSection();
                  },
                ),
              ],
            ),
          )
        else if (_projectLedgerTab == 1)
          _panelCard(
            title: 'Audit Buku Besar TimeCoin ($_txTotal)',
            subtitle: 'Seluruh transaksi masuk dan keluar lintas pengguna',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 175,
                  child: DropdownButtonFormField<String>(
                    initialValue: _txTypeFilter,
                    isExpanded: true,
                    decoration: _softInputDecoration('Jenis'),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Semua Jenis'),
                      ),
                      DropdownMenuItem(value: 'top_up', child: Text('Top-Up')),
                      DropdownMenuItem(
                        value: 'voucher_barter',
                        child: Text('Barter Voucher'),
                      ),
                      DropdownMenuItem(
                        value: 'project_escrow_hold',
                        child: Text('Escrow Proyek'),
                      ),
                      DropdownMenuItem(
                        value: 'project_reward',
                        child: Text('Imbalan Proyek'),
                      ),
                      DropdownMenuItem(
                        value: 'cash_out',
                        child: Text('Cash-Out'),
                      ),
                      DropdownMenuItem(
                        value: 'admin_adjustment',
                        child: Text('Penyesuaian Admin'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _txTypeFilter = v;
                        _txPage = 1;
                      });
                      _loadCurrentSection();
                    },
                  ),
                ),
                _tonalActionButton(
                  label: 'Unduh CSV',
                  icon: Icons.download_rounded,
                  bg: const Color(0xFFEEF2FF),
                  fg: AppColors.primaryNavy,
                  height: 38,
                  onPressed: () => showAdminCsvExportDialog(
                    context,
                    api: _api,
                    resource: 'transactions',
                    title: 'Audit Buku Besar TimeCoin',
                    onNotify: _showSnack,
                  ),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_transactions.isEmpty)
                  _emptyStateBox(
                    Icons.receipt_long_rounded,
                    'Belum ada mutasi tercatat pada filter ini.',
                  )
                else
                  ..._transactions.map((tx) => _transactionRow(tx)),
                const SizedBox(height: 12),
                _paginationBar(
                  currentPage: _txPage,
                  lastPage: _txLastPage,
                  total: _txTotal,
                  label: 'transaksi',
                  onPageChanged: (p) {
                    setState(() => _txPage = p);
                    _loadCurrentSection();
                  },
                ),
              ],
            ),
          )
        else if (_projectLedgerTab == 2)
          AdminMentoringModerationPanel(api: _api, onNotify: _showSnack)
        else
          AdminRewardsCatalogPanel(api: _api, onNotify: _showSnack),
      ],
    );
  }

  Widget _paginationBar({
    required int currentPage,
    required int lastPage,
    required int total,
    required String label,
    required ValueChanged<int> onPageChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _softSurfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBorder),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Halaman $currentPage dari $lastPage · Total $total $label',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _captionSlate,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: _softBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 16),
                label: const Text('Sebelumnya'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: _softBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: currentPage < lastPage
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 16),
                label: const Text('Berikutnya'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segmentedPill(int index, String label, IconData icon) {
    final active = _projectLedgerTab == index;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _projectLedgerTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : _captionSlate,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.darkSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color iconBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _captionSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkSlate,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: _captionSlate),
          ),
        ],
      ),
    );
  }

  Widget _ratioBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final pct = (ratio * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkSlate,
              ),
            ),
            Text(
              '$count akun ($pct%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _captionSlate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: _softCanvas,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _softStatPill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
    ),
  );

  Widget _emptyStateBox(IconData icon, String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    decoration: BoxDecoration(
      color: _softCanvas,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _softBorder),
    ),
    child: Column(
      children: [
        Icon(icon, size: 28, color: _captionSlate),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _captionSlate),
        ),
      ],
    ),
  );

  Widget _panelCard({
    required String title,
    String? subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _captionSlate,
                      ),
                    ),
                  ],
                ],
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _approvalTile({
    required String initials,
    required String title,
    required String subtitle,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required String approveLabel,
    required String rejectLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _softActiveBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _captionSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _tonalActionButton(
                label: rejectLabel,
                bg: const Color(0xFFFEF2F2),
                fg: const Color(0xFFB91C1C),
                onPressed: onReject,
              ),
              _tonalActionButton(
                label: approveLabel,
                bg: AppColors.primaryNavy,
                fg: Colors.white,
                onPressed: onApprove,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(Map<String, dynamic> tx) {
    final isCredit = tx['direction'] == 'credit';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _softBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 16,
              color: isCredit
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx['label'] ?? tx['transaction_type'] ?? 'Transaksi'} · ${tx['owner_name'] ?? 'Pengguna'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  '${tx['owner_email'] ?? ''} · ${tx['status'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: _captionSlate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isCredit ? '+' : '-'}${tx['amount'] ?? 0} TC',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isCredit
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _softInputDecoration(String hint) => InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _softBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _softBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.4),
    ),
  );

  Widget _tableHeaderBar(
    List<({String label, int? flex, double? width, bool alignEnd})> columns,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _softSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: columns.map((col) {
          final text = Text(
            col.label,
            textAlign: col.alignEnd ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          );
          if (col.width != null) {
            return SizedBox(width: col.width, child: text);
          }
          return Expanded(flex: col.flex ?? 1, child: text);
        }).toList(),
      ),
    );
  }

  Widget _tonalActionButton({
    required String label,
    IconData? icon,
    required Color bg,
    required Color fg,
    double height = 34,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleBg(String role) => switch (role) {
    'msme' => const Color(0xFFFFFBEB),
    'mentor' => const Color(0xFFECFDF5),
    _ => _softActiveBg,
  };

  Color _roleFg(String role) => switch (role) {
    'msme' => const Color(0xFFB45309),
    'mentor' => const Color(0xFF0F766E),
    _ => AppColors.primaryNavy,
  };

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();
    final (bg, fg, dot, label) = switch (normalized) {
      'approved' => (
        const Color(0xFFECFDF5),
        const Color(0xFF047857),
        const Color(0xFF10B981),
        'Terverifikasi',
      ),
      'completed' => (
        const Color(0xFFECFDF5),
        const Color(0xFF047857),
        const Color(0xFF10B981),
        'Selesai',
      ),
      'resolved' => (
        const Color(0xFFECFDF5),
        const Color(0xFF047857),
        const Color(0xFF10B981),
        'Selesai',
      ),
      'open' => (
        const Color(0xFFEEF2FF),
        AppColors.primaryNavy,
        AppColors.primaryNavy,
        'Terbuka',
      ),
      'in_progress' => (
        const Color(0xFFFFFBEB),
        const Color(0xFFB45309),
        const Color(0xFFF59E0B),
        'Berjalan',
      ),
      'suspended' => (
        const Color(0xFFFEF2F2),
        const Color(0xFFB91C1C),
        const Color(0xFFEF4444),
        'Dibekukan',
      ),
      'rejected' || 'failed' => (
        const Color(0xFFFEF2F2),
        const Color(0xFFB91C1C),
        const Color(0xFFEF4444),
        'Ditolak',
      ),
      'cancelled' => (
        const Color(0xFFFEF2F2),
        const Color(0xFFB91C1C),
        const Color(0xFFEF4444),
        'Dibatalkan',
      ),
      _ => (
        const Color(0xFFFFFBEB),
        const Color(0xFFB45309),
        const Color(0xFFF59E0B),
        'Menunggu',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
