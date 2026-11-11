import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';

class MyMentorsScreen extends StatefulWidget {
  const MyMentorsScreen({super.key, this.mentoringApi});

  final StudentMentoringApi? mentoringApi;

  @override
  State<MyMentorsScreen> createState() => _MyMentorsScreenState();
}

class _MyMentorsScreenState extends State<MyMentorsScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.studentMentors();
  }

  Future<void> _reload() async {
    final f = _api.studentMentors();
    setState(() => _future = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.studentDashboard,
              );
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: const Text(
          'Mentor & Bimbingan Saya',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cari Mentor',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.findMentors),
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Gagal memuat jadwal mentoring.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? const {};
            final summary =
                (data['summary'] as Map<String, dynamic>?) ?? const {};
            final nextSession = data['next_session'] as Map<String, dynamic>?;
            final mentors = ((data['mentors'] as List?) ?? const [])
                .whereType<Map<String, dynamic>>()
                .toList();

            return RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _summaryBox('${summary['mentors_count'] ?? 0}', 'Mentor'),
                        const SizedBox(width: 10),
                        _summaryBox('${summary['materials_count'] ?? 0}', 'Materi'),
                        const SizedBox(width: 10),
                        _summaryBox(
                          '${summary['certificates_count'] ?? 0}',
                          'Sertifikat',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.certificates,
                          ),
                        ),
                      ],
                    ),

                    if (nextSession != null) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'SESI BERIKUTNYA',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _nextSessionCard(context, nextSession),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Mentor Terhubung',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.logBimbingan,
                          ),
                          child: const Text('Log Sesi'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (mentors.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Anda belum memiliki riwayat bimbingan mentor.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.secondarySlate),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.findMentors,
                              ),
                              child: const Text('Cari Peer Mentor'),
                            ),
                          ],
                        ),
                      )
                    else
                      ...mentors.map((m) => _mentorGroupCard(context, m)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryBox(String value, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextSessionCard(
    BuildContext context,
    Map<String, dynamic> enrollment,
  ) {
    final cls = (enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final enrollmentId = (enrollment['id'] as num).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (cls['mentor_name'] as String?) ?? 'Mentor',
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  (cls['topic'] as String?) ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.mentoringSession,
              arguments: MentoringEnrollmentArgs(enrollmentId: enrollmentId),
            ),
            child: const Text(
              'Masuk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mentorGroupCard(BuildContext context, Map<String, dynamic> m) {
    final enrollmentId = (m['latest_enrollment_id'] as num?)?.toInt();
    final mentorId = (m['mentor_id'] as num?)?.toInt();
    final avatarUrl = ApiClient.resolveMediaUrl(m['avatar_url'] as String?);
    final pendingTasks = (m['pending_tasks_count'] as num?)?.toInt() ?? 0;

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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        width: 48,
                        height: 48,
                        cacheWidth: 144,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryNavy,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryNavy,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (m['mentor_name'] as String?) ?? 'Mentor',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    Text(
                      (m['title_headline'] as String?) ?? '',
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
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Topik: ${m['topic'] ?? '-'}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _miniChip(
                'Hasil (${m['results_count'] ?? 0})',
                onTap: enrollmentId == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.mentoringResult,
                        arguments: MentoringEnrollmentArgs(
                          enrollmentId: enrollmentId,
                        ),
                      ),
              ),
              _miniChip(
                'Sertifikat (${m['certificates_count'] ?? 0})',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.certificates),
              ),
              _miniChip(
                'Tugas (${m['tasks_done'] ?? 0}/${m['tasks_total'] ?? 0})',
                onTap: enrollmentId == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.ruangBelajar,
                        arguments: MentoringEnrollmentArgs(
                          enrollmentId: enrollmentId,
                          initialTab: 1,
                        ),
                      ),
              ),
            ],
          ),
          if (pendingTasks > 0) ...[
            const SizedBox(height: 10),
            Text(
              '$pendingTasks tugas perlu dikerjakan',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB45309),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton(
                tooltip: 'Chat Mentor',
                onPressed: enrollmentId == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.mentorChat,
                        arguments: MentoringEnrollmentArgs(
                          enrollmentId: enrollmentId,
                        ),
                      ),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primaryNavy,
                ),
              ),
              OutlinedButton(
                onPressed: mentorId == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.mentorProfile,
                        arguments: MentorDetailArgs(mentorId: mentorId),
                      ),
                child: const Text('Sewa lagi'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                  ),
                  onPressed: enrollmentId == null
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          AppRoutes.ruangBelajar,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: enrollmentId,
                          ),
                        ),
                  child: const Text('Ruang Belajar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.darkSlate,
          ),
        ),
      ),
    );
  }
}
