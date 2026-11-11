import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, this.projectId, this.projectApi});

  final int? projectId;
  final ProjectApi? projectApi;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final ProjectApi _api = widget.projectApi ?? ProjectApi.instance;

  bool _isLoading = true;
  bool _isBookmarkBusy = false;
  String? _error;
  Map<String, dynamic>? _project;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.projectId;
      if (targetId == null) {
        final listRes = await _api.explore();
        final rows = (listRes['data'] as List?) ?? const [];
        if (rows.isEmpty) {
          throw const ApiException('Belum ada proyek UMKM terbuka.');
        }
        targetId = ((rows.first as Map<String, dynamic>)['id'] as num).toInt();
      }
      final detail = await _api.detail(targetId);
      if (!mounted) return;
      setState(() {
        _project = detail;
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
          _error = 'Gagal memuat detail proyek UMKM.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final id = (_project?['id'] as num?)?.toInt();
    if (id == null || _isBookmarkBusy) return;
    setState(() => _isBookmarkBusy = true);
    try {
      final isBookmarked = await _api.toggleBookmark(id);
      if (!mounted) return;
      setState(() {
        _project = {...?_project, 'is_bookmarked': isBookmarked};
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isBookmarkBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _project == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error ?? 'Proyek tidak ditemukan.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.secondarySlate),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Kembali'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                            ),
                            onPressed: _loadDetail,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : _buildDetailBody(context, _project!),
      ),
    );
  }

  Widget _buildDetailBody(BuildContext context, Map<String, dynamic> p) {
    final projectId = (p['id'] as num).toInt();
    final msme = (p['msme'] as Map<String, dynamic>?) ?? const {};
    final atmosphere =
        (p['atmosphere'] as Map<String, dynamic>?) ?? const {};
    final eligibility =
        (p['eligibility'] as Map<String, dynamic>?) ?? const {};
    final milestones = ((p['milestones'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final checklist = ((p['deliverables_checklist'] as List?) ?? const [])
        .map((e) => '$e')
        .toList();
    final skills = ((p['skills'] as List?) ?? const [])
        .map((e) => '$e')
        .toList();

    final isBookmarked = p['is_bookmarked'] == true;
    final hasApplied = p['has_applied'] == true;
    final canApply = eligibility['can_apply'] != false;
    final photoUrl = ApiClient.resolveMediaUrl(
      atmosphere['photo_url'] as String?,
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_left_rounded,
                          size: 26,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Detail Proyek UMKM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleBookmark,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked
                              ? AppColors.primaryNavy
                              : AppColors.darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueSurface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (msme['business_name'] as String?) ??
                                      'Mitra UMKM',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${msme['business_sector'] ?? p['category']} · ${p['location_label'] ?? msme['city'] ?? 'Surabaya'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (p['title'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                          height: 1.25,
                        ),
                      ),
                      if ((p['division'] as String?) != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          p['division'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _metricBox(
                            '${p['reward_tc'] ?? 0} TC',
                            'Rp${((p['estimated_idr'] as num?)?.toInt() ?? 0)} escrow',
                          ),
                          const SizedBox(width: 8),
                          _metricBox(
                            (p['duration_label'] as String?) ?? '2 Minggu',
                            '${milestones.length} milestone',
                          ),
                          const SizedBox(width: 8),
                          _metricBox(
                            (p['work_mode'] as String?) ?? 'Hybrid',
                            '${p['days_left'] ?? 0} hari tersisa',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Eligibility Alert Banner
                if (!canApply)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: Color(0xFFB45309),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Syarat Melamar Proyek Belum Terpenuhi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (eligibility['reason'] as String?) ??
                              'Ikuti bimbingan mentor terlebih dahulu untuk mendapatkan Badge Rekomendasi Kerja.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF78350F),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.findMentors,
                          ),
                          icon: const Icon(Icons.school_rounded, size: 16),
                          label: const Text('Cari Mentor & Raih Badge'),
                        ),
                      ],
                    ),
                  ),

                // Skills & Summary
                const Text(
                  'Keahlian yang Dibutuhkan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Deskripsi Proyek & Hasil Akhir',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (p['description'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.secondarySlate,
                          height: 1.5,
                        ),
                      ),
                      if (checklist.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...checklist.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (photoUrl != null) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Suasana Mitra UMKM',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      photoUrl,
                      height: 160,
                      width: double.infinity,
                      cacheWidth: 900,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],

                if (milestones.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Pembagian Tahap (Smart Escrow)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...milestones.map(
                    (m) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.lightBlueSurface,
                            child: Text(
                              '${m['step_order']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (m['title'] as String?) ?? '',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                          Text(
                            '${m['reward_tc'] ?? 0} TC',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom Bar
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderSlate)),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryNavy),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.workspaceChat,
                  arguments: ProjectRouteArgs(projectId: projectId),
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: AppColors.primaryNavy,
                ),
                label: const Text(
                  'Chat UMKM',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: hasApplied
                        ? AppColors.secondarySlate
                        : AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: hasApplied
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          AppRoutes.applyProject,
                          arguments: ProjectRouteArgs(projectId: projectId),
                        ),
                  child: Text(
                    hasApplied
                        ? 'Lamaran Sudah Dikirim'
                        : 'Lamar Proyek Ini',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricBox(String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.canvasWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
