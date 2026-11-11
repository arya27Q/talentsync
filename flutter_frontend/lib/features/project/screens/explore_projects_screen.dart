import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';

class ExploreProjectsScreen extends StatefulWidget {
  const ExploreProjectsScreen({super.key, this.projectApi});

  final ProjectApi? projectApi;

  @override
  State<ExploreProjectsScreen> createState() => _ExploreProjectsScreenState();
}

class _ExploreProjectsScreenState extends State<ExploreProjectsScreen> {
  late final ProjectApi _api = widget.projectApi ?? ProjectApi.instance;

  int _selectedCategoryIndex = 0;
  bool _mentorCertificateOnly = false;
  String _sortKey = 'recommended';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _projects = const [];
  int _totalVerified = 0;
  String _headerSubtitle = 'Talenta Mahasiswa · TalentSync';

  final List<String> _categories = const [
    'Semua',
    'Terdekat',
    'UI/UX Design',
    'Frontend',
    'Backend',
    'Marketing',
  ];

  final Map<String, String> _sortLabels = const {
    'recommended': 'Rekomendasi',
    'highest_reward': 'Imbalan Tertinggi',
    'nearest_deadline': 'Tenggat Terdekat',
  };

  @override
  void initState() {
    super.initState();
    _loadSessionHeader();
    _fetchProjects();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionHeader() async {
    final user = await ApiClient.instance.readSessionUser();
    if (!mounted || user == null) return;
    final name = (user['name'] as String?) ?? 'Mahasiswa';
    final univ = (user['university'] as String?) ?? 'UNESA';
    final major = (user['major'] as String?) ?? 'Sistem Informasi';
    setState(() {
      _headerSubtitle = 'Halo, ${name.split(' ').first} · $univ $major';
    });
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _api.explore(
        search: _searchController.text,
        category: _categories[_selectedCategoryIndex],
        sort: _sortKey,
        mentorCertificateOnly: _mentorCertificateOnly,
      );
      if (!mounted) return;
      final rows = (response['data'] as List?) ?? const [];
      final meta = (response['meta'] as Map<String, dynamic>?) ?? const {};
      setState(() {
        _projects = rows.whereType<Map<String, dynamic>>().toList();
        _totalVerified =
            (meta['total_verified_projects'] as num?)?.toInt() ??
            _projects.length;
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
          _error = 'Gagal memuat daftar proyek UMKM.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _fetchProjects);
  }

  void _showSortModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urutkan Proyek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 12),
              ..._sortLabels.entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: _sortKey == entry.key
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _sortKey == entry.key
                          ? AppColors.primaryNavy
                          : AppColors.darkSlate,
                    ),
                  ),
                  trailing: _sortKey == entry.key
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryNavy,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_sortKey != entry.key) {
                      setState(() => _sortKey = entry.key);
                      _fetchProjects();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final msme = (project['msme'] as Map<String, dynamic>?) ?? const {};
    final projectId = (project['id'] as num?)?.toInt();
    final umkmName = (msme['business_name'] as String?) ?? 'Mitra UMKM';
    final category = (project['category'] as String?) ?? 'Proyek UMKM';
    final skills = ((project['skills'] as List?) ?? const [])
        .map((e) => '$e')
        .where((e) => e.isNotEmpty)
        .toList();
    final primarySkill = skills.isNotEmpty ? skills.first : category;
    final daysLeft = (project['days_left'] as num?)?.toInt() ?? 0;
    final location = (project['location_label'] as String?) ?? 'Surabaya';
    final workMode = (project['work_mode'] as String?) ?? 'Hybrid';
    final requiresEndorse = project['requires_endorsement'] == true;
    final benefit = (project['benefit_badge'] as String?) ??
        (requiresEndorse ? 'Wajib Badge Mentor' : 'Sertifikat & Portofolio');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primaryNavy,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            umkmName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (msme['business_sector'] as String?) ?? category,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.toll_rounded,
                      size: 14,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project['reward_tc'] ?? 0} TC',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            (project['title'] as String?) ?? '',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (project['description'] as String?) ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(category, bg: const Color(0xFFEFF6FF), fg: AppColors.primaryNavy),
              _chip(primarySkill, bg: const Color(0xFFF1F5F9), fg: AppColors.darkSlate),
              _chip(
                benefit,
                bg: requiresEndorse
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFDCFCE7),
                fg: requiresEndorse
                    ? const Color(0xFFB45309)
                    : const Color(0xFF15803D),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.borderSlate, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.secondarySlate,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Tenggat: $daysLeft hari · $workMode · $location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.projectDetail,
                  arguments: ProjectRouteArgs(projectId: projectId),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProjects,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.keyboard_arrow_left_rounded,
                              size: 26,
                              color: AppColors.darkSlate,
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
                              'Jelajahi Proyek UMKM',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _headerSubtitle,
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
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
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
                ),

                // Search Bar + Sort Trigger
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            onSubmitted: (_) => _fetchProjects(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkSlate,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Cari proyek web, desain, kasir...',
                              hintStyle: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13.5,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.secondarySlate,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showSortModal,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final selected = _selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategoryIndex = index);
                          _fetchProjects();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryNavy
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryNavy
                                  : AppColors.borderSlate,
                            ),
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : AppColors.secondarySlate,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Status & Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_totalVerified Proyek UMKM Terverifikasi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Urutkan: ${_sortLabels[_sortKey]}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Badge Mentor',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Switch(
                              value: _mentorCertificateOnly,
                              activeThumbColor: AppColors.primaryNavy,
                              onChanged: (val) {
                                setState(() => _mentorCertificateOnly = val);
                                _fetchProjects();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Project List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _error != null
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                ),
                                onPressed: _fetchProjects,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        )
                      : _projects.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Text(
                            'Belum ada proyek yang sesuai filter pencarian Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.secondarySlate),
                          ),
                        )
                      : Column(
                          children: _projects.map(_buildProjectCard).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
