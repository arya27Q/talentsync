import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/core/widgets/in_app_guide_section.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/dashboard/data/student_dashboard_api.dart';

class DashboardMahasiswaScreen extends StatefulWidget {
  const DashboardMahasiswaScreen({super.key, this.dashboardApi});

  final StudentDashboardApi? dashboardApi;

  @override
  State<DashboardMahasiswaScreen> createState() =>
      _DashboardMahasiswaScreenState();
}

class _DashboardMahasiswaScreenState extends State<DashboardMahasiswaScreen> {
  late final StudentDashboardApi _api =
      widget.dashboardApi ?? StudentDashboardApi.instance;
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _api.dashboard();
  }

  Future<void> _reload() async {
    final future = _api.dashboard();
    setState(() {
      _dashboardFuture = future;
    });
    await future;
  }

  String _formatIdr(int amount) {
    final chars = amount.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(chars[i]);
    }
    return 'Rp${buffer.toString().split('').reversed.join()}';
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required int? projectId,
    required String businessName,
    required String title,
    required String tcReward,
    required String stageText,
    required double progress,
    required String nextStep,
    required String daysLeft,
    required IconData businessIcon,
    Color? deadlineColor,
  }) {
    return GestureDetector(
      onTap: projectId == null
          ? null
          : () => Navigator.pushNamed(
              context,
              AppRoutes.workspaceKanban,
              arguments: ProjectRouteArgs(projectId: projectId),
            ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
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
                      businessIcon,
                      color: AppColors.primaryNavy,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timelapse_rounded,
                            size: 15,
                            color: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Aktif \u00B7 $businessName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.toll_rounded,
                      color: AppColors.accentAmberGold,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$tcReward TC',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.borderSlate,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryNavy,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  stageText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.radio_button_unchecked,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Berikutnya: $nextStep',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: deadlineColor ?? AppColors.secondarySlate,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      daysLeft,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: deadlineColor != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: deadlineColor ?? AppColors.secondarySlate,
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
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text(
              'Keluar dari Akun?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun mahasiswa? Anda harus masuk kembali dengan NIM atau email dan kata sandi.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.secondarySlate,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondarySlate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthApi().logout();
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
          future: _dashboardFuture,
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
                            : 'Dasbor mahasiswa gagal dimuat.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),
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
            return _buildContent(context, snapshot.data ?? const {});
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final user = (data['user'] as Map<String, dynamic>?) ?? const {};
    final wallet = (data['wallet'] as Map<String, dynamic>?) ?? const {};
    final unreadCount = (data['unread_notifications_count'] as num?)?.toInt() ?? 0;
    final activeProjects = ((data['active_projects'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final nextMentoring = data['next_mentoring'] as Map<String, dynamic>?;
    final recommended = ((data['recommended_projects'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final name = (user['name'] as String?) ?? 'Mahasiswa';
    final avatarUrl = ApiClient.resolveMediaUrl(user['avatar_url'] as String?);
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'M';
    final balanceTc = (wallet['balance_tc'] as num?)?.toInt() ?? 0;
    final estimatedIdr = (wallet['estimated_idr'] as num?)?.toInt() ?? balanceTc * 1000;
    final completedCount = (user['completed_projects_count'] as num?)?.toInt() ?? 0;

    final nextClass =
        (nextMentoring?['class'] as Map<String, dynamic>?) ?? const {};
    final nextEnrollmentId = (nextMentoring?['id'] as num?)?.toInt();

    final firstRec = recommended.isNotEmpty ? recommended.first : null;
    final recUmkm = (firstRec?['msme'] as Map<String, dynamic>?) ?? const {};
    final recId = (firstRec?['id'] as num?)?.toInt();

    return RefreshIndicator(
      onRefresh: _reload,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: avatarUrl != null
                              ? Image.network(
                                  avatarUrl,
                                  width: 44,
                                  height: 44,
                                  cacheWidth: 132,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greetingText(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
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
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                size: 24,
                                color: AppColors.darkSlate,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 11,
                                  right: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentAmberGold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showLogoutConfirmation(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFCA5A5)
                                  .withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 22,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Main Balance & Proyek Selesai Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saldo TimeCoin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF93C5FD),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentAmberGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.toll_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$balanceTc TC',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Setara ${_formatIdr(estimatedIdr)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF93C5FD),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Proyek Selesai',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF93C5FD),
                                ),
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$completedCount Proyek',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _shortcutButton(
                          context,
                          icon: Icons.search_rounded,
                          label: 'Cari Proyek',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.exploreProjects,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _shortcutButton(
                          context,
                          icon: Icons.school_rounded,
                          label: 'Mentor Saya',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.myMentors,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _shortcutButton(
                          context,
                          icon: Icons.card_giftcard_rounded,
                          label: 'Reward',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.rewardHub,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Showcase Carousel
            InteractiveImageCarousel(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              height: 180,
              items: [
                CarouselSlideItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                  tag: 'Kemitraan UMKM',
                  tagColor: AppColors.primaryNavy,
                  title: 'Dapur Produksi Sambal & Kuliner',
                  subtitle:
                      'Bantu digitalisasi UMKM lokal Surabaya: desain label kemasan & katalog online.',
                  buttonText: 'Eksplorasi',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.exploreProjects),
                ),
                CarouselSlideItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
                  tag: 'Bimbingan 1-on-1',
                  tagColor: AppColors.accentAmberGold,
                  title: 'Review Portofolio Bersama Mentor',
                  subtitle:
                      'Dapatkan badge verifikasi keahlian sebelum melamar tender proyek UMKM.',
                  buttonText: 'Cari Mentor',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.findMentors),
                ),
                CarouselSlideItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=800&q=80',
                  tag: 'Proyek Baru',
                  tagColor: const Color(0xFF10B981),
                  title: 'Aplikasi Menu & Kasir Tepi Kali',
                  subtitle:
                      'Imbalan TC aman di escrow dengan pencairan 0% biaya admin.',
                  buttonText: 'Detail',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.exploreProjects),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. Proyek Aktif
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Proyek aktif (${activeProjects.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.myProjects),
                    child: const Text(
                      'Tugas Saya',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: activeProjects.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: const Text(
                        'Belum ada proyek aktif. Jelajahi lowongan proyek UMKM atau ikuti bimbingan mentor terlebih dahulu.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondarySlate,
                          height: 1.4,
                        ),
                      ),
                    )
                  : Column(
                      children: activeProjects.map((proj) {
                        final msme =
                            (proj['msme'] as Map<String, dynamic>?) ?? const {};
                        final stage = (proj['current_stage'] as num?)?.toInt() ?? 1;
                        final total = (proj['total_stages'] as num?)?.toInt() ?? 1;
                        final pct =
                            ((proj['progress_percent'] as num?)?.toDouble() ?? 0) /
                            100;
                        final daysLeft = (proj['days_left'] as num?)?.toInt() ?? 0;
                        final isUrgent = proj['is_urgent'] == true;
                        return _buildTaskCard(
                          context: context,
                          projectId: (proj['id'] as num?)?.toInt(),
                          businessName:
                              (msme['business_name'] as String?) ?? 'Mitra UMKM',
                          title: (proj['title'] as String?) ?? 'Proyek UMKM',
                          tcReward: '${proj['reward_tc'] ?? 0}',
                          stageText: 'Tahap $stage/$total',
                          progress: pct.clamp(0.0, 1.0),
                          nextStep:
                              (proj['next_milestone'] as String?) ?? 'Lanjutkan tugas',
                          daysLeft: '$daysLeft hari lagi',
                          businessIcon: Icons.storefront_rounded,
                          deadlineColor:
                              isUrgent ? const Color(0xFFDC2626) : null,
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 24),

            // 4. Konsultasi & Bimbingan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Konsultasi & Bimbingan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.findMentors),
                    child: const Text(
                      'Cari mentor',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSlate),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school_rounded,
                              color: AppColors.primaryNavy,
                              size: 22,
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
                                      (nextClass['mentor_name'] as String?) ??
                                          'Belum ada sesi aktif',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Peer Mentor',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                (nextClass['topic'] as String?) ??
                                    'Pesan sesi bimbingan untuk raih Badge Rekomendasi',
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.myMentors,
                            ),
                            icon: const Icon(
                              Icons.list_alt_rounded,
                              size: 16,
                              color: AppColors.primaryNavy,
                            ),
                            label: const Text(
                              'Jadwal Saya',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryNavy),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              nextEnrollmentId != null
                                  ? AppRoutes.ruangBelajar
                                  : AppRoutes.findMentors,
                              arguments: nextEnrollmentId != null
                                  ? MentoringEnrollmentArgs(
                                      enrollmentId: nextEnrollmentId,
                                    )
                                  : null,
                            ),
                            icon: const Icon(
                              Icons.meeting_room_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              nextEnrollmentId != null ? 'Masuk Sesi' : 'Cari Mentor',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. Rekomendasi untukmu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Rekomendasi untukmu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.exploreProjects,
                    ),
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (firstRec != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkSlate.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant_rounded,
                                color: AppColors.primaryNavy,
                                size: 22,
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
                                        (recUmkm['business_name'] as String?) ??
                                            'Mitra UMKM',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkSlate,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.primaryNavy,
                                      size: 14,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (recUmkm['business_sector'] as String?) ??
                                      (firstRec['category'] as String? ?? 'UMKM'),
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
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.toll_rounded,
                                  color: AppColors.accentAmberGold,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${firstRec['reward_tc'] ?? 0} TC',
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
                      const SizedBox(height: 12),
                      Text(
                        (firstRec['title'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Tenggat: ${firstRec['days_left'] ?? 0} hari lagi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.projectDetail,
                              arguments: ProjectRouteArgs(projectId: recId),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            _buildStudentGuideSection(),
          ],
        ),
      ),
    );
  }

  Widget _shortcutButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGuideSection() {
    const studentArticles = [
      InAppArticle(
        id: 'student_guide_cashout',
        title: 'Panduan Aman Mencairkan TimeCoin ke Rupiah (0% Biaya Admin)',
        subtitle:
            'Ketahui cara menarik TC hasil proyek langsung ke rekening bank atau e-wallet tanpa potongan.',
        category: 'Keuangan',
        readTime: '3 mnt baca',
        imageUrl:
            'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=800&q=80',
        icon: Icons.payments_rounded,
        accentColor: Color(0xFF0D9488),
        keyPoints: [
          '1 TC setara Rp1.000 utuh tanpa manipulasi kurs.',
          'Pencairan dana bagi Mahasiswa 100% bebas biaya administrasi (0% admin fee).',
          'Sistem Escrow menjamin dana aman tersimpan hingga UMKM menyetujui tugas akhirmu.',
          'Waktu pemrosesan transfer maksimal 1x24 jam kerja.',
        ],
        fullContent:
            'Setiap kali kamu menyelesaikan proyek UMKM dan hasil deliverable telah disetujui, dana TimeCoin (TC) yang tersimpan di brankas Escrow akan otomatis ditransfer ke Dompet TalentSync milikmu.\n\nKamu dapat mencairkan saldo TC kapan saja melalui menu Dompet > Tarik Rupiah. Pilih bank tujuan (BCA, Mandiri, BNI, BRI) atau e-wallet (GoPay, OVO, DANA). Mahasiswa mendapatkan keistimewaan 0% potongan biaya administrasi, sehingga seluruh hasil jerih payahmu diterima 100% utuh.',
        proTip:
            'Pastikan nama pemilik rekening bank atau e-wallet sesuai dengan nama lengkap pada Kartu Tanda Mahasiswa (KTM) agar verifikasi transfer berjalan otomatis tanpa penundaan.',
      ),
      InAppArticle(
        id: 'student_guide_badge',
        title: 'Belum Punya Portofolio? Raih Badge Rekomendasi Mentor',
        subtitle:
            'Syarat wajib melamar proyek UMKM: portofolio terverifikasi atau badge rekomendasi mentor.',
        category: 'Karier & Mentor',
        readTime: '4 mnt baca',
        imageUrl:
            'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80',
        icon: Icons.verified_rounded,
        accentColor: AppColors.primaryNavy,
        keyPoints: [
          'UMKM memprioritaskan pelamar dengan Portofolio Terverifikasi atau Badge Mentor.',
          'Sesi bimbingan 1-on-1 dengan Peer Mentor bertarif terjangkau menggunakan TimeCoin.',
          'Selesaikan latihan studi kasus dan raih skor evaluasi minimal >= 80 untuk membuka badge.',
          'Badge otomatis terpasang di profil dan langsung membuka akses seluruh proyek UMKM.',
        ],
        fullContent:
            'Jika kamu baru bergabung dan belum memiliki rekam jejak portofolio proyek riil, jangan khawatir! TalentSync menyediakan jalur percepatan bimbingan bersama Peer Mentor (mahasiswa senior berprestasi atau praktisi muda).\n\nCukup buka menu Mentoring, pilih mentor dengan spesialisasi yang kamu minati (UI/UX, Web Dev, Mobile Flutter, Copywriting, Desain Grafis), lalu pesan sesi bimbingan. Di Ruang Belajar, mentor akan menguji kemampuanmu melalui simulasi kasus nyata UMKM. Begitu kamu meraih nilai minimal 80, mentor akan menerbitkan Badge Rekomendasi yang membuktikan bahwa kamu siap kerja!',
        proTip:
            'Pelamar yang menyertakan Badge Rekomendasi Mentor memiliki tingkat penerimaan 3.5x lebih tinggi oleh mitra UMKM dibanding pelamar tanpa verifikasi.',
      ),
      InAppArticle(
        id: 'student_guide_switch_mentor',
        title: 'Peluang Switch as a Mentor Setelah Selesaikan 5 Proyek',
        subtitle:
            'Tingkatkan peranmu menjadi Peer Mentor dan dapatkan penghasilan TimeCoin tambahan.',
        category: 'Peluang',
        readTime: '3 mnt baca',
        imageUrl:
            'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=80',
        icon: Icons.school_rounded,
        accentColor: Color(0xFFD97706),
        keyPoints: [
          'Syarat: Menyelesaikan minimal 5 proyek UMKM nyata dengan reputasi baik.',
          'Fleksibilitas mengatur tarif sesi bimbingan TimeCoin sendiri.',
          'Bantu adik tingkat atau mahasiswa baru menguasai keahlian praktis.',
          'Tersedia opsi upgrade ke Akun Mentor Premium untuk 0% biaya admin cash-out.',
        ],
        fullContent:
            'TalentSync dirancang sebagai ekosistem pertumbuhan talenta yang berkelanjutan. Ketika kamu telah membuktikan keahlianmu dengan menuntaskan 5 proyek UMKM nyata dan mendapatkan rating positif, kamu memenuhi kualifikasi untuk beralih peran menjadi Peer Mentor.\n\nMelalui menu Profil > Beralih Menjadi Mentor (Switch as a Mentor), daftarkan keahlian utamamu, unggah bukti portofolio terbaik, dan tentukan jadwal serta tarif bimbinganmu. Kamu bisa mengajar adik tingkat, memberikan review tugas, dan mencairkan imbalan TimeCoin yang kamu dapatkan.',
        proTip:
            'Menjadi Peer Mentor tidak hanya menambah saldo TimeCoin, tetapi juga memperkuat portofolio kepemimpinan (leadership & mentoring) saat kamu melamar kerja di industri nanti.',
      ),
    ];

    return const InAppGuideSection(
      title: 'Panduan & Kiat Sukses Mahasiswa',
      subtitle:
          'Pelajari alur pengerjaan proyek, pencairan TimeCoin, dan bimbingan mentor',
      articles: studentArticles,
    );
  }
}
