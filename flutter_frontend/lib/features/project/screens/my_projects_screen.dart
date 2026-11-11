import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';

class MyProjectsScreen extends StatefulWidget {
  final bool showBottomNav;
  final ProjectApi? projectApi;
  const MyProjectsScreen({
    super.key,
    this.showBottomNav = false,
    this.projectApi,
  });

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  late final ProjectApi _api = widget.projectApi ?? ProjectApi.instance;

  int _selectedTabIndex = 0; // 0: Aktif, 1: Menunggu, 2: Selesai
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.myProjects();
  }

  Future<void> _reload() async {
    final f = _api.myProjects();
    setState(() => _future = f);
    await f;
  }

  Widget _buildFilterTab(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.secondarySlate,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.canvasWhite,
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.error is ApiException
                            ? (snapshot.error as ApiException).message
                            : 'Gagal memuat daftar proyek Anda.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.secondarySlate),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                        ),
                        onPressed: _reload,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data ?? const {};
            final summary =
                (data['summary'] as Map<String, dynamic>?) ?? const {};
            final active = ((data['active_projects'] as List?) ?? const [])
                .whereType<Map<String, dynamic>>()
                .toList();
            final pending =
                ((data['pending_applications'] as List?) ?? const [])
                    .whereType<Map<String, dynamic>>()
                    .toList();
            final completed =
                ((data['completed_projects'] as List?) ?? const [])
                    .whereType<Map<String, dynamic>>()
                    .toList();

            return RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tugas & Proyek Saya',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Kelola milestone, kanban, dan status lamaran',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.notifications,
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Summary Metrics
                    Row(
                      children: [
                        _metricCard(
                          '${summary['active_count'] ?? active.length}',
                          'Proyek aktif',
                        ),
                        const SizedBox(width: 10),
                        _metricCard(
                          '${summary['escrow_total_tc'] ?? 0} TC',
                          'Di escrow',
                        ),
                        const SizedBox(width: 10),
                        _metricCard(
                          '${summary['completed_count'] ?? completed.length} Proyek',
                          'Selesai',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Row(
                        children: [
                          _buildFilterTab('Aktif (${active.length})', 0),
                          _buildFilterTab('Menunggu (${pending.length})', 1),
                          _buildFilterTab('Selesai (${completed.length})', 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (_selectedTabIndex == 0)
                      _buildActiveList(active)
                    else if (_selectedTabIndex == 1)
                      _buildPendingList(pending)
                    else
                      _buildCompletedList(completed),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _metricCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
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

  Widget _buildActiveList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _emptyBox('Belum ada proyek UMKM yang sedang aktif.');
    }
    return Column(
      children: items.map((proj) {
        final projectId = (proj['id'] as num).toInt();
        final msme = (proj['msme'] as Map<String, dynamic>?) ?? const {};
        final stage = (proj['current_stage'] as num?)?.toInt() ?? 1;
        final total = (proj['total_stages'] as num?)?.toInt() ?? 1;
        final pct = ((proj['progress_percent'] as num?)?.toInt() ?? 0);
        final releasedTc = (proj['released_tc'] as num?)?.toInt() ?? 0;
        final escrowTc = (proj['escrow_tc'] as num?)?.toInt() ?? 0;
        final isUrgent = proj['is_urgent'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (msme['business_name'] as String?) ?? 'Mitra UMKM',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (proj['title'] as String?) ?? '',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${proj['reward_tc'] ?? 0} TC',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: AppColors.borderSlate,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tahap $stage/$total · $pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  Text(
                    '$releasedTc TC cair · $escrowTc TC escrow',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Berikutnya: ${proj['next_milestone'] ?? '-'} · ${proj['days_left'] ?? 0} hari',
                style: TextStyle(
                  fontSize: 12,
                  color: isUrgent
                      ? const Color(0xFFDC2626)
                      : AppColors.secondarySlate,
                  fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Chat UMKM',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.workspaceChat,
                      arguments: ProjectRouteArgs(projectId: projectId),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kanban Workspace',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.workspaceKanban,
                      arguments: ProjectRouteArgs(projectId: projectId),
                    ),
                    icon: const Icon(
                      Icons.view_kanban_rounded,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.submission,
                        arguments: ProjectRouteArgs(projectId: projectId),
                      ),
                      child: const Text('Status & Milestone'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _emptyBox('Tidak ada lamaran proyek yang sedang menunggu.');
    }
    return Column(
      children: items.map((app) {
        final proj = (app['project'] as Map<String, dynamic>?) ?? const {};
        final msme = (proj['msme'] as Map<String, dynamic>?) ?? const {};
        final projectId = (proj['id'] as num?)?.toInt();
        final status = (app['status'] as String?) ?? 'pending';
        final statusLabel = status == 'rejected_referred_mentor'
            ? 'Disarankan Bimbingan Mentor'
            : status == 'rejected'
            ? 'Belum Terpilih'
            : 'Menunggu Seleksi';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (msme['business_name'] as String?) ?? 'Mitra UMKM',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                (proj['title'] as String?) ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: projectId == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.projectDetail,
                        arguments: ProjectRouteArgs(projectId: projectId),
                      ),
                child: const Text('Lihat Detail Proyek'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompletedList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _emptyBox('Belum ada proyek UMKM yang selesai.');
    }
    return Column(
      children: items.map((proj) {
        final projectId = (proj['id'] as num?)?.toInt();
        final msme = (proj['msme'] as Map<String, dynamic>?) ?? const {};
        return GestureDetector(
          onTap: projectId == null
              ? null
              : () => Navigator.pushNamed(
                  context,
                  AppRoutes.projectCompleted,
                  arguments: ProjectRouteArgs(projectId: projectId),
                ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: Color(0xFF16A34A),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (msme['business_name'] as String?) ?? 'Mitra UMKM',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      Text(
                        (proj['title'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${proj['reward_tc'] ?? 0} TC',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accentAmberGold,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${proj['rating'] ?? 5.0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyBox(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.secondarySlate, fontSize: 13),
      ),
    );
  }
}
