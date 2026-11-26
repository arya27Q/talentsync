import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/admin/data/admin_api.dart';
import 'package:flutter_frontend/features/admin/widgets/admin_csv_dialog.dart';

class AdminSecurityPanel extends StatefulWidget {
  const AdminSecurityPanel({
    super.key,
    required this.api,
    required this.onNotify,
  });

  final AdminApi api;
  final void Function(String message, {bool isError}) onNotify;

  @override
  State<AdminSecurityPanel> createState() => _AdminSecurityPanelState();
}

class _AdminSecurityPanelState extends State<AdminSecurityPanel> {
  static const Color _softBorder = Color(0xFFE6EDF6);
  static const Color _captionSlate = Color(0xFF475569);

  int _subTab = 0; // 0: Anomali, 1: Audit Log, 2: Broadcast, 3: Sesi Admin
  bool _loading = true;
  String? _error;

  Map<String, dynamic> _anomalyData = const {};
  List<Map<String, dynamic>> _auditLogs = const [];
  int _auditPage = 1;
  int _auditLastPage = 1;
  int _auditTotal = 0;
  List<Map<String, dynamic>> _sessions = const [];
  String _auditActionFilter = 'all';

  // Broadcast form
  String _broadcastTarget = 'all';
  final _broadcastTitleCtrl = TextEditingController();
  final _broadcastBodyCtrl = TextEditingController();
  bool _sendingBroadcast = false;
  bool _revokingSessions = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _broadcastTitleCtrl.dispose();
    _broadcastBodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.api.securityAnomalies(),
        widget.api.auditLogsPage(action: _auditActionFilter, page: _auditPage),
        widget.api.activeSessions(),
      ]);
      if (!mounted) return;
      final auditRes = results[1] as AdminPageResult;
      setState(() {
        _anomalyData = results[0] as Map<String, dynamic>;
        _auditLogs = auditRes.items;
        _auditPage = auditRes.currentPage;
        _auditLastPage = auditRes.lastPage;
        _auditTotal = auditRes.total;
        _sessions = results[2] as List<Map<String, dynamic>>;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Gagal memuat data keamanan dari server.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadAuditLogs({int? page}) async {
    try {
      final res = await widget.api.auditLogsPage(
        action: _auditActionFilter,
        page: page ?? _auditPage,
      );
      if (mounted) {
        setState(() {
          _auditLogs = res.items;
          _auditPage = res.currentPage;
          _auditLastPage = res.lastPage;
          _auditTotal = res.total;
        });
      }
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    }
  }

  Future<void> _sendBroadcast() async {
    final title = _broadcastTitleCtrl.text.trim();
    final body = _broadcastBodyCtrl.text.trim();
    if (title.length < 5) {
      widget.onNotify('Judul pengumuman minimal 5 karakter.', isError: true);
      return;
    }
    if (body.length < 10) {
      widget.onNotify('Isi pengumuman minimal 10 karakter.', isError: true);
      return;
    }

    setState(() => _sendingBroadcast = true);
    try {
      final count = await widget.api.broadcastAnnouncement(
        targetRole: _broadcastTarget,
        title: title,
        body: body,
      );
      if (!mounted) return;
      _broadcastTitleCtrl.clear();
      _broadcastBodyCtrl.clear();
      widget.onNotify('Pengumuman terkirim ke $count pengguna aktif.');
      await _reloadAuditLogs();
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _sendingBroadcast = false);
    }
  }

  Future<void> _revokeOtherSessions() async {
    setState(() => _revokingSessions = true);
    try {
      final msg = await widget.api.revokeOtherSessions();
      if (!mounted) return;
      widget.onNotify(msg);
      final sessions = await widget.api.activeSessions();
      if (mounted) setState(() => _sessions = sessions);
    } on ApiException catch (e) {
      widget.onNotify(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _revokingSessions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
      );
    }

    if (_error != null) {
      return _softCard(
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 12),
            Expanded(child: Text(_error!)),
            TextButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final summary =
        (_anomalyData['summary'] as Map<String, dynamic>?) ?? const {};
    final alertsCount = (summary['total_alerts'] as num?)?.toInt() ?? 0;

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
              _tabChip(0, 'Deteksi Anomali ($alertsCount)', Icons.radar_rounded),
              _tabChip(
                1,
                'Log Audit Admin (${_auditLogs.length})',
                Icons.history_edu_rounded,
              ),
              _tabChip(2, 'Broadcast Pengumuman', Icons.campaign_rounded),
              _tabChip(
                3,
                'Sesi Admin (${_sessions.length})',
                Icons.devices_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        switch (_subTab) {
          0 => _buildAnomaliesTab(),
          1 => _buildAuditLogsTab(),
          2 => _buildBroadcastTab(),
          _ => _buildSessionsTab(),
        },
      ],
    );
  }

  Widget _tabChip(int index, String label, IconData icon) {
    final selected = _subTab == index;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _subTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
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
                color: selected ? Colors.white : _captionSlate,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.darkSlate,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnomaliesTab() {
    final summary =
        (_anomalyData['summary'] as Map<String, dynamic>?) ?? const {};
    final alerts = ((_anomalyData['alerts'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _miniStatCard(
              'Peringatan Aktif',
              '${summary['total_alerts'] ?? 0}',
              Icons.warning_amber_rounded,
              const Color(0xFFB45309),
              const Color(0xFFFFFBEB),
            ),
            _miniStatCard(
              'Risiko Tinggi',
              '${summary['high_severity_count'] ?? 0}',
              Icons.gpp_maybe_rounded,
              const Color(0xFFDC2626),
              const Color(0xFFFEF2F2),
            ),
            _miniStatCard(
              'Akun Dibekukan',
              '${summary['suspended_users_count'] ?? 0}',
              Icons.block_rounded,
              AppColors.darkSlate,
              const Color(0xFFF1F5F9),
            ),
            _miniStatCard(
              'Sengketa Terbuka',
              '${summary['open_disputes_count'] ?? 0}',
              Icons.gavel_rounded,
              AppColors.primaryNavy,
              const Color(0xFFEEF2FF),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _softCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pemantauan Anomali Ekonomi TimeCoin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Muat ulang',
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                ],
              ),
              const Text(
                'Pemeriksaan otomatis langsung dari basis data lokal: Cash-Out >= 300 TC, frekuensi pencairan >= 2x/24 jam, dan transfer >= 500 TC.',
                style: TextStyle(fontSize: 12.5, color: _captionSlate),
              ),
              const SizedBox(height: 14),
              if (alerts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF15803D),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tidak ada aktivitas transaksi anomali saat ini. Seluruh arus TimeCoin dalam batas normal.',
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...alerts.map((a) {
                  final isHigh = a['severity'] == 'high';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isHigh
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isHigh
                            ? const Color(0xFFFECACA)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isHigh
                              ? Icons.error_rounded
                              : Icons.warning_amber_rounded,
                          color: isHigh
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (a['title'] as String?) ?? 'Peringatan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (a['description'] as String?) ?? '',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: _captionSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogsTab() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Rekam Jejak Audit Administrator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: _auditActionFilter,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _softBorder),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua Aksi')),
                    DropdownMenuItem(
                      value: 'user_suspended',
                      child: Text('Pembekuan Akun'),
                    ),
                    DropdownMenuItem(
                      value: 'user_force_logout',
                      child: Text('Cabut Sesi Paksa'),
                    ),
                    DropdownMenuItem(
                      value: 'cash_out_approved',
                      child: Text('Persetujuan Cash-Out'),
                    ),
                    DropdownMenuItem(
                      value: 'dispute_resolved',
                      child: Text('Resolusi Sengketa'),
                    ),
                    DropdownMenuItem(
                      value: 'announcement_broadcast',
                      child: Text('Broadcast Pengumuman'),
                    ),
                    DropdownMenuItem(
                      value: 'wallet_adjustment',
                      child: Text('Penyesuaian Saldo'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _auditActionFilter = v);
                    _reloadAuditLogs(page: 1);
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => showAdminCsvExportDialog(
                  context,
                  api: widget.api,
                  resource: 'audit-logs',
                  title: 'Log Audit Admin',
                  onNotify: widget.onNotify,
                ),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Unduh CSV'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_auditLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Belum ada catatan audit pada filter ini.',
                style: TextStyle(color: _captionSlate),
              ),
            )
          else
            ..._auditLogs.map((log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _softBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${log['action'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                        Text(
                          '${log['target_label'] ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                    if ((log['details'] as String?)?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${log['details']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _captionSlate,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Oleh: ${log['admin_name'] ?? 'Admin'} · IP: ${log['ip_address'] ?? '-'} · ${log['created_at'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Halaman $_auditPage dari $_auditLastPage (Total $_auditTotal log)',
                style: const TextStyle(fontSize: 12, color: _captionSlate),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _auditPage > 1
                        ? () => _reloadAuditLogs(page: _auditPage - 1)
                        : null,
                    child: const Text('Sebelumnya'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _auditPage < _auditLastPage
                        ? () => _reloadAuditLogs(page: _auditPage + 1)
                        : null,
                    child: const Text('Berikutnya'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastTab() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kirim Pengumuman & Peringatan Keamanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Terkirim langsung ke kotak notifikasi dalam aplikasi secara gratis melalui server TalentSync.',
            style: TextStyle(fontSize: 12.5, color: _captionSlate),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            child: DropdownButtonFormField<String>(
              initialValue: _broadcastTarget,
              decoration: InputDecoration(
                labelText: 'Target Penerima',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua 3 POV')),
                DropdownMenuItem(value: 'student', child: Text('Mahasiswa')),
                DropdownMenuItem(value: 'msme', child: Text('Mitra UMKM')),
                DropdownMenuItem(value: 'mentor', child: Text('Peer Mentor')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _broadcastTarget = v);
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _broadcastTitleCtrl,
            decoration: InputDecoration(
              labelText: 'Judul Pengumuman',
              hintText: 'Contoh: Peringatan Keamanan Transaksi Escrow',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _broadcastBodyCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Isi Pesan',
              hintText:
                  'Tulis informasi pemeliharaan atau imbauan keamanan untuk pengguna...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _sendingBroadcast ? null : _sendBroadcast,
            icon: _sendingBroadcast
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(
              _sendingBroadcast ? 'Mengirim...' : 'Kirim Pengumuman Sekarang',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.timer_rounded, color: AppColors.primaryNavy),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Proteksi Idle Auto-Logout aktif: portal admin akan otomatis keluar jika tidak ada aktivitas selama 20 menit.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Perangkat Login Administrator Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _revokingSessions ? null : _revokeOtherSessions,
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: Text(
                  _revokingSessions
                      ? 'Mencabut...'
                      : 'Keluar dari Perangkat Lain',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_sessions.isEmpty)
            const Text(
              'Tidak ada daftar sesi aktif yang dikembalikan server.',
              style: TextStyle(color: _captionSlate),
            )
          else
            ..._sessions.map((s) {
              final isCurrent = s['is_current'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _softBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCurrent
                          ? Icons.laptop_mac_rounded
                          : Icons.devices_other_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s['device_name'] ?? 'Perangkat'}${isCurrent ? ' (Sesi Ini)' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          Text(
                            'Dibuat: ${s['created_at'] ?? '-'} · Terakhir aktif: ${s['last_used_at'] ?? '-'}',
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
              );
            }),
        ],
      ),
    );
  }

  Widget _miniStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: _captionSlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _softCard({required Widget child}) {
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
      child: child,
    );
  }
}
