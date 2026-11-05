import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorStudentLearningRoomArgs {
  const MentorStudentLearningRoomArgs({
    required this.student,
    this.onSelectTab,
    this.initialTab = 1,
  });

  final MentorStudent student;
  final ValueChanged<int>? onSelectTab;
  final int initialTab;
}

class MentorStudentLearningRoomScreen extends StatefulWidget {
  const MentorStudentLearningRoomScreen({
    super.key,
    required this.student,
    this.onSelectTab,
    this.initialTab = 1,
  });

  final MentorStudent student;
  final ValueChanged<int>? onSelectTab;
  final int initialTab;

  @override
  State<MentorStudentLearningRoomScreen> createState() =>
      _MentorStudentLearningRoomScreenState();
}

class _MentorStudentLearningRoomScreenState
    extends State<MentorStudentLearningRoomScreen> {
  late int _selectedTab = widget.initialTab;
  late bool _recommended = widget.student.recommended;
  final Set<String> _openedResources = {
    'Panduan struktur folder feature-first',
  };

  static const _materials = [
    _LearningResource(
      title: 'Panduan struktur folder feature-first',
      detail: 'PDF · 2,4 MB · 8 Jul',
      type: 'PDF',
      isOpened: true,
    ),
    _LearningResource(
      title: 'Rekaman: refactor kasir kecil',
      detail: 'Video · 25 mnt · 8 Jul',
      type: 'Video',
      isOpened: false,
    ),
    _LearningResource(
      title: 'Repo contoh clean architecture',
      detail: 'github.com · 9 Jul',
      type: 'Tautan',
      isOpened: false,
    ),
  ];

  List<String> get _tabs => [
    'Materi (${widget.student.materials})',
    'Tugas (${widget.student.totalTasks})',
    'Proyek (${widget.student.completedProjects})',
    'Sertifikat (${widget.student.certificates})',
  ];

  Color get _studentColor => switch (widget.student.initials) {
    'DL' => const Color(0xFF0F766E),
    'RH' => const Color(0xFFA03B1E),
    _ => AppColors.primaryNavy,
  };

  void _toggleRecommendation() {
    setState(() => _recommended = !_recommended);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _recommended
              ? '${widget.student.name} ditandai direkomendasikan ke UMKM.'
              : 'Rekomendasi ${widget.student.name} dicabut.',
        ),
      ),
    );
  }

  void _openResource(_LearningResource resource) {
    setState(() => _openedResources.add(resource.title));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka ${resource.title}...')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header matching screenshot
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Kembali',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 26,
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
                        'Ruang Belajar Murid',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.student.name} · ${widget.student.focus}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Chat dengan ${widget.student.name}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.mentorStudentChat,
                      arguments: widget.student,
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.darkSlate,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content List with proper bottom padding 120
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
              children: [
                // Top Student Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.borderSlate.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkSlate.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _studentColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.student.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.student.name,
                              style: const TextStyle(
                                color: AppColors.darkSlate,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.student.sessions} sesi · rata-rata 82/100',
                              style: const TextStyle(
                                color: AppColors.secondarySlate,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Status rekomendasi ke UMKM',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _toggleRecommendation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.thumb_up_alt_rounded,
                                  color: Color(0xFFC2410C),
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _recommended ? 'Ke UMKM' : 'Rekomendasikan',
                                  style: const TextStyle(
                                    color: Color(0xFFC2410C),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Segmented Tabs Pill Container
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Row(
                    children: List.generate(
                      _tabs.length,
                      (index) {
                        final selected = _selectedTab == index;
                        return Expanded(
                          child: Semantics(
                            button: true,
                            selected: selected,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setState(() => _selectedTab = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryNavy
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryNavy
                                                .withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _tabs[index],
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.secondarySlate,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Tab Content List
                if (_selectedTab == 0) ...[
                  // 1. Tab Materi (3)
                  for (final item in _materials) ...[
                    _MaterialResourceCard(
                      resource: item,
                      isOpened: _openedResources.contains(item.title) ||
                          item.isOpened,
                      onTap: () => _openResource(item),
                    ),
                    const SizedBox(height: 12),
                  ],
                ] else if (_selectedTab == 1) ...[
                  // 2. Tab Tugas (3) matching Screenshot 1
                  _TaskResourceCard(
                    title: 'Refactor repository stok barang',
                    dueDate: 'Tenggat 14 Jul',
                    status: 'Dikerjakan murid',
                    statusType: _TaskStatusType.inProgress,
                  ),
                  const SizedBox(height: 12),
                  _TaskResourceCard(
                    title: 'Tulis 5 unit test untuk perhitungan laba',
                    dueDate: 'Tenggat 18 Jul',
                    status: 'Dikerjakan murid',
                    statusType: _TaskStatusType.inProgress,
                  ),
                  const SizedBox(height: 12),
                  _TaskResourceCard(
                    title: 'Diagram alur state kasir',
                    dueDate: 'Tenggat 10 Jul',
                    status: 'Dinilai 90',
                    statusType: _TaskStatusType.graded,
                    linkUrl: 'figma.com/file/state-kasir',
                  ),
                ] else if (_selectedTab == 2) ...[
                  // 3. Tab Proyek (2) matching Screenshot 2
                  _ProjectResourceCard(
                    badge: 'Terverifikasi · 92',
                    isVerified: true,
                    rewardTc: '40 TC',
                    title: 'Modul offline-sync aplikasi koperasi',
                    client: 'Klien mentor · Koperasi Pasar Genteng',
                    resultSummary:
                        'Hasil: github.com/arya/offline-sync, Demo APK v1.2, Do...',
                  ),
                  const SizedBox(height: 12),
                  _ProjectResourceCard(
                    badge: 'Dikerjakan murid',
                    isVerified: false,
                    rewardTc: '30 TC',
                    title: 'Code review & refactor fitur laporan',
                    client: 'Tim internal fintech mentor',
                    resultSummary: 'Hasil: PR #142 (draft)',
                  ),
                ] else ...[
                  // 4. Tab Sertifikat (2) matching Screenshot 3
                  _CertificateResourceCard(
                    title: 'Rekomendasi Kerja: Flutter Developer',
                    subtitle: 'Rekomendasi Kerja · 8 Jul 2025 · TS-END-0087',
                    isAmber: true,
                  ),
                  const SizedBox(height: 12),
                  _CertificateResourceCard(
                    title: 'Lulus Bimbingan: Arsitektur Flutter & BLoC',
                    subtitle: 'Kelulusan · 8 Jul 2025 · TS-MNT-0211',
                    isAmber: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: MentorBottomNav(
      selectedIndex: 2,
      onSelected: (index) {
        if (widget.onSelectTab == null) {
          Navigator.pop(context, index);
          return;
        }
        widget.onSelectTab!(index);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    ),
  );
}

class _LearningResource {
  const _LearningResource({
    required this.title,
    required this.detail,
    required this.type,
    this.isOpened = false,
  });

  final String title;
  final String detail;
  final String type;
  final bool isOpened;
}

class _MaterialResourceCard extends StatelessWidget {
  const _MaterialResourceCard({
    required this.resource,
    required this.isOpened,
    required this.onTap,
  });

  final _LearningResource resource;
  final bool isOpened;
  final VoidCallback onTap;

  IconData get _iconData {
    if (resource.type == 'PDF') return Icons.picture_as_pdf_rounded;
    if (resource.type == 'Video') return Icons.play_circle_outline_rounded;
    return Icons.link_rounded;
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.borderSlate.withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconData,
              color: AppColors.primaryNavy,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  resource.detail,
                  style: const TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpened ? 'Dibuka murid' : 'Belum dibuka',
            style: TextStyle(
              color: isOpened
                  ? const Color(0xFF059669)
                  : AppColors.secondarySlate,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

enum _TaskStatusType { inProgress, graded }

class _TaskResourceCard extends StatelessWidget {
  const _TaskResourceCard({
    required this.title,
    required this.dueDate,
    required this.status,
    required this.statusType,
    this.linkUrl,
  });

  final String title;
  final String dueDate;
  final String status;
  final _TaskStatusType statusType;
  final String? linkUrl;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.borderSlate.withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueDate,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusType == _TaskStatusType.graded
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusType == _TaskStatusType.graded
                      ? const Color(0xFF059669)
                      : const Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
        if (linkUrl != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 16,
                  color: AppColors.primaryNavy,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    linkUrl!,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class _ProjectResourceCard extends StatelessWidget {
  const _ProjectResourceCard({
    required this.badge,
    required this.isVerified,
    required this.rewardTc,
    required this.title,
    required this.client,
    required this.resultSummary,
  });

  final String badge;
  final bool isVerified;
  final String rewardTc;
  final String title;
  final String client;
  final String resultSummary;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.borderSlate.withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isVerified
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: isVerified
                      ? const Color(0xFF059669)
                      : AppColors.primaryNavy,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
            Text(
              rewardTc,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          client,
          style: const TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          resultSummary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _CertificateResourceCard extends StatelessWidget {
  const _CertificateResourceCard({
    required this.title,
    required this.subtitle,
    required this.isAmber,
  });

  final String title;
  final String subtitle;
  final bool isAmber;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.borderSlate.withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isAmber ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(
            isAmber
                ? Icons.workspace_premium_rounded
                : Icons.verified_rounded,
            color: isAmber
                ? const Color(0xFFD97706)
                : AppColors.primaryNavy,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
