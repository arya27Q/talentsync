import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorStudentLearningRoomArgs {
  const MentorStudentLearningRoomArgs({
    required this.student,
    this.onSelectTab,
  });

  final MentorStudent student;
  final ValueChanged<int>? onSelectTab;
}

class MentorStudentLearningRoomScreen extends StatefulWidget {
  const MentorStudentLearningRoomScreen({
    super.key,
    required this.student,
    this.onSelectTab,
  });

  final MentorStudent student;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorStudentLearningRoomScreen> createState() =>
      _MentorStudentLearningRoomScreenState();
}

class _MentorStudentLearningRoomScreenState
    extends State<MentorStudentLearningRoomScreen> {
  int _selectedTab = 0;
  late bool _recommended = widget.student.recommended;
  final Set<String> _openedResources = {
    'Panduan struktur folder feature-first',
  };

  static const _materials = [
    _LearningResource(
      title: 'Panduan struktur folder feature-first',
      detail: 'PDF · 2,4 MB · 8 Jul',
      type: 'PDF',
    ),
    _LearningResource(
      title: 'Rekaman: refactor kasir kecil',
      detail: 'Video · 25 mnt · 8 Jul',
      type: 'Video',
    ),
    _LearningResource(
      title: 'Repo contoh clean architecture',
      detail: 'github.com · 9 Jul',
      type: 'Tautan',
    ),
  ];

  List<String> get _tabs => [
    'Materi (${widget.student.materials})',
    'Tugas (${widget.student.totalTasks})',
    'Proyek (${widget.student.completedProjects})',
    'Sertifikat (${widget.student.certificates})',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ruang Belajar Murid',
            style: TextStyle(
              color: AppColors.darkSlate,
              fontWeight: FontWeight.w700,
            ),
          ),
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
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkSlate,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Chat dengan ${widget.student.name}',
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.mentorStudentChat,
            arguments: widget.student,
          ),
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(width: 10),
      ],
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              children: [
                MentorCard(
                  child: Row(
                    children: [
                      MentorAvatar(
                        initials: widget.student.initials,
                        size: 58,
                        color: _studentColor,
                        textColor: Colors.white,
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
                      FilledButton.icon(
                        onPressed: _toggleRecommendation,
                        style: FilledButton.styleFrom(
                          backgroundColor: _recommended
                              ? const Color(0xFFFFF6E8)
                              : AppColors.primaryNavy,
                          foregroundColor: _recommended
                              ? AppColors.accentAmberDeep
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        icon: Icon(
                          _recommended
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_alt_outlined,
                          size: 17,
                        ),
                        label: Text(
                          _recommended ? 'Ke UMKM' : 'Rekomendasikan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Row(
                    children: List.generate(
                      _tabs.length,
                      (index) => Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _selectedTab = index),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            backgroundColor: _selectedTab == index
                                ? AppColors.primaryNavy
                                : Colors.transparent,
                            foregroundColor: _selectedTab == index
                                ? Colors.white
                                : AppColors.secondarySlate,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _tabs[index],
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ..._tabContent,
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: MentorBottomNav(
      selectedIndex: -1,
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

  Color get _studentColor => switch (widget.student.initials) {
    'DL' => const Color(0xFF147D76),
    'RH' => const Color(0xFFAA3D17),
    _ => AppColors.primaryNavy,
  };

  List<Widget> get _tabContent => switch (_selectedTab) {
    0 =>
      widget.student.name == 'Arya Pratama'
          ? _materials.map(_buildMaterialCard).toList()
          : [
              MentorCard(
                child: Text(
                  widget.student.materials == 0
                      ? 'Belum ada materi di ruang belajar ini.'
                      : '${widget.student.materials} materi tersedia untuk murid ini.',
                  style: const TextStyle(color: AppColors.secondarySlate),
                ),
              ),
            ],
    1 => _buildTasks(),
    2 => [
      MentorCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proyek murid',
              style: TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.student.completedProjects > 0
                  ? '${widget.student.completedProjects} proyek tercatat pada profil murid.'
                  : 'Belum ada detail proyek yang dibagikan di ruang belajar.',
              style: const TextStyle(
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
    _ => [
      MentorCard(
        child: Text(
          widget.student.certificates == 0
              ? 'Belum ada sertifikat di ruang belajar ini.'
              : '${widget.student.certificates} sertifikat tersimpan pada portofolio murid.',
          style: const TextStyle(color: AppColors.secondarySlate),
        ),
      ),
    ],
  };

  List<Widget> _buildTasks() {
    if (widget.student.totalTasks == 0) {
      return [
        const MentorCard(
          child: Text(
            'Belum ada tugas untuk murid ini.',
            style: TextStyle(color: AppColors.secondarySlate),
          ),
        ),
      ];
    }
    final titles = widget.student.name == 'Arya Pratama'
        ? [
            'Refactor repository kasir',
            'Terapkan struktur folder feature-first',
            'Review state BLoC',
          ]
        : ['Review bottleneck performa aplikasi'];
    return [
      for (var index = 0; index < titles.length; index++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MentorCard(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Icon(
                  index < widget.student.completedTasks
                      ? Icons.task_alt_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: index < widget.student.completedTasks
                      ? AppColors.primaryNavy
                      : AppColors.secondarySlate,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    titles[index],
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  index < widget.student.completedTasks
                      ? 'Selesai'
                      : 'Berjalan',
                  style: const TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _buildMaterialCard(_LearningResource resource) {
    final opened = _openedResources.contains(resource.title);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MentorCard(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightBlueSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(resource.icon, color: AppColors.primaryNavy),
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
                  const SizedBox(height: 4),
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
              opened ? 'Dibuka murid' : 'Belum dibuka',
              style: TextStyle(
                color: opened
                    ? const Color(0xFF047857)
                    : AppColors.secondarySlate,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRecommendation() {
    setState(() => _recommended = !_recommended);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _recommended
              ? '${widget.student.name} direkomendasikan ke UMKM.'
              : 'Rekomendasi ${widget.student.name} dibatalkan.',
        ),
      ),
    );
  }
}

class _LearningResource {
  const _LearningResource({
    required this.title,
    required this.detail,
    required this.type,
  });

  final String title;
  final String detail;
  final String type;

  IconData get icon => switch (type) {
    'PDF' => Icons.picture_as_pdf_outlined,
    'Video' => Icons.play_circle_outline_rounded,
    _ => Icons.link_rounded,
  };
}
