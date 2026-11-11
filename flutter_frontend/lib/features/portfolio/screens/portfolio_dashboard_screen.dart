import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/portfolio/data/portfolio_api.dart';

class PortfolioDashboardScreen extends StatefulWidget {
  const PortfolioDashboardScreen({
    super.key,
    this.portfolioApi,
    this.authApi,
  });

  final PortfolioApi? portfolioApi;
  final AuthApi? authApi;

  @override
  State<PortfolioDashboardScreen> createState() =>
      _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState extends State<PortfolioDashboardScreen> {
  late final PortfolioApi _api = widget.portfolioApi ?? PortfolioApi.instance;
  late final AuthApi _authApi = widget.authApi ?? AuthApi();

  bool _isLoading = true;
  bool _isSyncingGithub = false;
  String? _error;
  Map<String, dynamic> _data = const {};

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
      final res = await _api.portfolio();
      if (!mounted) return;
      setState(() {
        _data = res;
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
          _error = 'Gagal memuat data portofolio mahasiswa.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openGithubSyncDialog(String? currentUsername) async {
    final controller = TextEditingController(text: currentUsername ?? '');
    final submitted = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sinkronkan Akun GitHub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Username GitHub',
            hintText: 'contoh: arya-pratama',
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
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Sinkronkan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (submitted == null) return;

    setState(() => _isSyncingGithub = true);
    try {
      await _api.syncGithub(username: submitted);
      if (!mounted) return;
      _showSnack('Repository GitHub berhasil disinkronkan.');
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal menyinkronkan GitHub.', isError: true);
    } finally {
      if (mounted) setState(() => _isSyncingGithub = false);
    }
  }

  Future<void> _disconnectGithub() async {
    setState(() => _isSyncingGithub = true);
    try {
      await _api.disconnectGithub();
      if (!mounted) return;
      _showSnack('Integrasi GitHub diputuskan.');
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal memutuskan integrasi GitHub.', isError: true);
    } finally {
      if (mounted) setState(() => _isSyncingGithub = false);
    }
  }

  Future<void> _verifySkill(int skillId) async {
    try {
      await _api.verifySkill(skillId);
      if (!mounted) return;
      _showSnack('Keahlian berhasil diverifikasi.');
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal memverifikasi keahlian.', isError: true);
    }
  }

  void _shareCvModal(String publicCvUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              'Bagikan Portofolio & CV Terverifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tautan portofolio ini memuat proyek UMKM, rekomendasi mentor, dan sertifikat terverifikasi.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      publicCvUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: publicCvUrl));
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _showSnack('Tautan CV berhasil disalin ke clipboard.');
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text(
                  'Salin Tautan CV',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        content: const Text(
          'Sesi akun Anda akan berakhir dan Anda dapat masuk kembali kapan saja.',
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
    final profile =
        (_data['profile'] as Map<String, dynamic>?) ?? const {};
    final radarMetrics = (_data['radar_metrics'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final endorsements = (_data['endorsements'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final verifiedProjects = (_data['verified_projects'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final skills = (profile['skills'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final github =
        (profile['github_integration'] as Map<String, dynamic>?) ?? const {};
    final publicCvUrl =
        (_data['public_cv_url'] as String?) ?? 'https://talentsync.id/cv/profil';

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
                    _buildTopBar(publicCvUrl),
                    const SizedBox(height: 16),
                    _buildProfileCard(profile),
                    const SizedBox(height: 16),
                    _buildStatsRow(profile),
                    const SizedBox(height: 16),
                    if (radarMetrics.isNotEmpty) ...[
                      _buildRadarCard(radarMetrics),
                      const SizedBox(height: 16),
                    ],
                    _buildGithubCard(github),
                    const SizedBox(height: 16),
                    _buildSkillsCard(skills),
                    const SizedBox(height: 16),
                    _buildQuickLinksRow(),
                    const SizedBox(height: 16),
                    if (endorsements.isNotEmpty) ...[
                      _buildEndorsementsCard(endorsements),
                      const SizedBox(height: 16),
                    ],
                    _buildProjectsSection(verifiedProjects),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar(String publicCvUrl) {
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
            'Portofolio & Profil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
        ),
        _headerAction(
          icon: Icons.share_rounded,
          onTap: () => _shareCvModal(publicCvUrl),
        ),
        const SizedBox(width: 8),
        _headerAction(
          icon: Icons.settings_rounded,
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
        const SizedBox(width: 8),
        _headerAction(
          icon: Icons.logout_rounded,
          iconColor: const Color(0xFFB91C1C),
          onTap: _confirmLogout,
        ),
      ],
    );
  }

  Widget _headerAction({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = AppColors.darkSlate,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final name = (profile['name'] as String?) ?? 'Mahasiswa';
    final headline =
        (profile['headline'] as String?) ?? 'Mahasiswa Talenta Digital';
    final university = (profile['university'] as String?) ?? 'Universitas';
    final major = (profile['major'] as String?) ?? 'Program Studi';
    final avatarUrl = ApiClient.resolveMediaUrl(
      profile['avatar_url'] as String?,
    );
    final ktmStatus =
        (profile['ktm_verification_status'] as String?) ?? 'approved';
    final hasEndorsement = profile['has_mentor_endorsement'] == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.lightBlueSurface,
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          width: 56,
                          height: 56,
                          cacheWidth: 168,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'M',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'M',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$major | $university',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit Profil',
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.editProfile);
                  if (mounted) _load();
                },
                icon: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _badgeChip(
                Icons.badge_rounded,
                ktmStatus == 'approved' ? 'KTM Terverifikasi' : 'KTM Menunggu',
                AppColors.lightGreenSurface,
                const Color(0xFF15803D),
              ),
              if (hasEndorsement)
                _badgeChip(
                  Icons.verified_rounded,
                  'Rekomendasi Mentor',
                  const Color(0xFFFEF3C7),
                  AppColors.accentAmberDeep,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeChip(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> profile) {
    final completed = (profile['completed_projects_count'] as num?)?.toInt() ?? 0;
    final certs = (_data['certificates_count'] as num?)?.toInt() ?? 0;
    final sessions = (_data['mentoring_sessions_count'] as num?)?.toInt() ?? 0;
    final hours = _data['mentoring_hours'] ?? 0;

    return Row(
      children: [
        _statBox('$completed', 'Proyek Selesai'),
        const SizedBox(width: 8),
        _statBox('$certs', 'Sertifikat'),
        const SizedBox(width: 8),
        _statBox('$sessions (${hours}j)', 'Mentoring'),
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarCard(List<Map<String, dynamic>> metrics) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peta Kompetensi Skill',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarChartPainter(metrics: metrics),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGithubCard(Map<String, dynamic> github) {
    final connected = github['connected'] == true;
    final username = github['username'] as String?;
    final repos = (github['repos_count'] as num?)?.toInt() ?? 0;
    final commits = (github['commits_count'] as num?)?.toInt() ?? 0;
    final langs = (github['languages'] as List? ?? const [])
        .map(
          (e) => e is Map
              ? '${e['name'] ?? ''} ${e['percent'] != null ? '${e['percent']}%' : ''}'
                    .trim()
              : e.toString(),
        )
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, color: AppColors.primaryNavy),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Integrasi GitHub',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
              TextButton(
                onPressed: _isSyncingGithub
                    ? null
                    : () => _openGithubSyncDialog(username),
                child: Text(connected ? 'Sinkronkan Ulang' : 'Hubungkan'),
              ),
            ],
          ),
          if (connected) ...[
            Text(
              '@${username ?? '-'} | $repos repositori | $commits kontribusi',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
              ),
            ),
            if (langs.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: langs
                    .map(
                      (lang) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lang,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isSyncingGithub ? null : _disconnectGithub,
                child: const Text(
                  'Putuskan GitHub',
                  style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                ),
              ),
            ),
          ] else
            const Text(
              'Hubungkan akun GitHub untuk memvalidasi kontribusi kode secara otomatis.',
              style: TextStyle(fontSize: 12.5, color: AppColors.secondarySlate),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(List<Map<String, dynamic>> skills) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Keahlian Terverifikasi',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.editProfile);
                  if (mounted) _load();
                },
                child: const Text('Kelola'),
              ),
            ],
          ),
          if (skills.isEmpty)
            const Text(
              'Belum ada keahlian ditambahkan.',
              style: TextStyle(fontSize: 12.5, color: AppColors.secondarySlate),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((s) {
                final id = (s['id'] as num?)?.toInt();
                final verified = s['is_verified'] == true;
                return InkWell(
                  onTap: (!verified && id != null)
                      ? () => _verifySkill(id)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: verified
                          ? AppColors.lightBlueSurface
                          : AppColors.canvasWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          verified
                              ? Icons.verified_rounded
                              : Icons.add_task_rounded,
                          size: 15,
                          color: verified
                              ? AppColors.primaryNavy
                              : AppColors.secondarySlate,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${s['name']} (${s['score']}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: verified
                                ? AppColors.primaryNavy
                                : AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _quickCard(
                icon: Icons.workspace_premium_rounded,
                title: 'Sertifikat Saya',
                subtitle: 'Lencana proyek & mentor',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.certificates),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickCard(
                icon: Icons.history_edu_rounded,
                title: 'Log Bimbingan',
                subtitle: 'Riwayat & evaluasi',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.logBimbingan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.switchToMentor),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: AppColors.accentAmberGold,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beralih Menjadi Peer Mentor',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Syarat minimal 5 proyek selesai & reputasi baik',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDBEAFE),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryNavy, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndorsementsCard(List<Map<String, dynamic>> endorsements) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekomendasi Mentor',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          ...endorsements.map((item) {
            final enrollmentId = (item['enrollment_id'] as num?)?.toInt();
            return InkWell(
              onTap: enrollmentId == null
                  ? null
                  : () => Navigator.pushNamed(
                      context,
                      AppRoutes.mentoringResult,
                      arguments: MentoringEnrollmentArgs(
                        enrollmentId: enrollmentId,
                      ),
                    ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['mentor_name']} (Skor ${item['score'] ?? '-'})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (item['notes'] as String?) ?? '',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(List<Map<String, dynamic>> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Studi Kasus Proyek Terverifikasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        if (projects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: const Text(
              'Selesaikan proyek UMKM atau validasi bimbingan mentor untuk mengisi portofolio terverifikasi Anda.',
              style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
            ),
          )
        else
          ...projects.map((p) {
            final id = (p['id'] as num?)?.toInt();
            final tags = (p['tags'] as List? ?? const [])
                .map((e) => e.toString())
                .take(3)
                .toList();
            return InkWell(
              onTap: id == null
                  ? null
                  : () => Navigator.pushNamed(
                      context,
                      AppRoutes.caseStudy,
                      arguments: CaseStudyArgs(portfolioId: id),
                    ),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (p['title'] as String?) ?? 'Portofolio Proyek',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.accentAmberGold,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${p['rating'] ?? 5.0}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p['client_name'] ?? 'UMKM'} | ${p['role_title'] ?? 'Kontributor'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasWhite,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
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
              Icons.work_outline_rounded,
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
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({required this.metrics});

  final List<Map<String, dynamic>> metrics;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.length < 3) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.34;
    final count = metrics.length;
    final step = (2 * math.pi) / count;

    final gridPaint = Paint()
      ..color = AppColors.borderSlate
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var ring = 1; ring <= 4; ring++) {
      final r = radius * (ring / 4);
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = -math.pi / 2 + step * i;
        final pt = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final valuePath = Path();
    for (var i = 0; i < count; i++) {
      final score = ((metrics[i]['score'] as num?)?.toDouble() ?? 60.0).clamp(
        0.0,
        100.0,
      );
      final r = radius * (score / 100.0);
      final angle = -math.pi / 2 + step * i;
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        valuePath.moveTo(pt.dx, pt.dy);
      } else {
        valuePath.lineTo(pt.dx, pt.dy);
      }

      final labelPos = Offset(
        center.dx + (radius + 22) * math.cos(angle),
        center.dy + (radius + 16) * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${metrics[i]['label']}',
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.darkSlate,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }
    valuePath.close();

    canvas.drawPath(
      valuePath,
      Paint()
        ..color = AppColors.primaryNavy.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      valuePath,
      Paint()
        ..color = AppColors.primaryNavy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) =>
      oldDelegate.metrics != metrics;
}
