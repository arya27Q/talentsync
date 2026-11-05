import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_recommendation.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_recommendation_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_student_learning_room_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorStudentsScreen extends StatefulWidget {
  const MentorStudentsScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorStudentsScreen> createState() => _MentorStudentsScreenState();
}

class _MentorStudentsScreenState extends State<MentorStudentsScreen> {
  final _recommended = <String>{
    for (final student in mentorStudents.where(
      (student) => student.recommended,
    ))
      student.name,
  };
  final _drafts = <MentorRecommendationDraft>[];

  List<MentorStudent> get _visibleStudents => mentorStudents;

  Future<void> _openLearningRoom(MentorStudent student) async {
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.mentorStudentLearningRoom,
      arguments: MentorStudentLearningRoomArgs(
        student: student,
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (result is int) widget.onSelectTab?.call(result);
  }

  Future<void> _openRecommendation([MentorStudent? student]) async {
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.mentorRecommendation,
      arguments: MentorRecommendationArgs(
        initialStudent: student,
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (!mounted) return;
    if (result is MentorRecommendationDraft) {
      setState(() => _drafts.add(result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Draft ${result.candidate.student.name} → ${result.project.businessName} disiapkan. Pengiriman belum terhubung.',
          ),
        ),
      );
    } else if (result is int) {
      widget.onSelectTab?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _visibleStudents;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header matching design
          MentorPageHeader(
            title: 'Murid Saya',
            subtitle: _drafts.isEmpty
                ? '${mentorStudents.length} murid aktif'
                : '${mentorStudents.length} murid aktif · ${_drafts.length} draft',
            trailing: GestureDetector(
              onTap: () => _openRecommendation(),
              child: Container(
                width: 46,
                height: 46,
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
                  Icons.thumb_up_alt_rounded,
                  color: AppColors.darkSlate,
                  size: 22,
                ),
              ),
            ),
          ),

          // Scrollable student list with bottom padding 120 so Rafi Hakim card is fully clear of bottom nav
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada murid yang terdaftar.',
                      style: TextStyle(color: AppColors.secondarySlate),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: students.length + _drafts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index < _drafts.length) {
                        return _RecommendationDraftCard(draft: _drafts[index]);
                      }
                      final student = students[index - _drafts.length];
                      return _StudentCard(
                        student: student,
                        recommended: _recommended.contains(student.name),
                        onChat: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mentorStudentChat,
                          arguments: student,
                        ),
                        onRecommend: () => _openRecommendation(student),
                        onOpenRoom: () => _openLearningRoom(student),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationDraftCard extends StatelessWidget {
  const _RecommendationDraftCard({required this.draft});

  final MentorRecommendationDraft draft;

  @override
  Widget build(BuildContext context) => MentorCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment_rounded, color: AppColors.primaryNavy),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'Draft rekomendasi',
                style: TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const MentorTag(
              'Siap ditinjau',
              color: AppColors.lightBlueSurface,
              textColor: AppColors.primaryNavy,
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          '${draft.candidate.student.name} · ${draft.project.businessName}',
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          draft.reason,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Pengiriman ke UMKM belum terhubung.',
          style: TextStyle(color: AppColors.secondarySlate, fontSize: 11),
        ),
      ],
    ),
  );
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.recommended,
    required this.onChat,
    required this.onRecommend,
    required this.onOpenRoom,
  });

  final MentorStudent student;
  final bool recommended;
  final VoidCallback onChat;
  final VoidCallback onRecommend;
  final VoidCallback onOpenRoom;

  Color get _avatarColor => switch (student.initials) {
    'DL' => const Color(0xFF0F766E), // Deep Teal
    'RH' => const Color(0xFFA03B1E), // Terracotta/Rust
    _ => AppColors.primaryNavy,      // Deep Royal Navy
  };

  @override
  Widget build(BuildContext context) => Container(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + Name + Subtitle + Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _avatarColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                student.initials,
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
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.study,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.focus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (student.needsReview > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${student.needsReview} perlu dinilai',
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // 4 Metric items (Sesi, Materi, Tugas, Sertifikat)
        Row(
          children: [
            Expanded(
              child: _StudentMetric(
                value: '${student.sessions}',
                label: 'Sesi',
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _StudentMetric(
                value: '${student.materials}',
                label: 'Materi',
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _StudentMetric(
                value: '${student.completedTasks}/${student.totalTasks}',
                label: 'Tugas',
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _StudentMetric(
                value: '${student.certificates}',
                label: 'Sertifikat',
              ),
            ),
          ],
        ),

        // Recommendation status indicator (green)
        if (recommended) ...[
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFF059669),
                size: 16,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sudah kamu rekomendasikan ke UMKM',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 14),

        // Action Buttons Row: Chat, Rekomendasikan, Ruang Belajar
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Chat dengan ${student.name}',
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onChat,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.borderSlate),
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
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Rekomendasikan ${student.name}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onRecommend,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          color: AppColors.primaryNavy,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rekomendasikan',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Buka ruang belajar ${student.name}',
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onOpenRoom,
                child: Container(
                  width: 84,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Ruang\nBelajar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _StudentMetric extends StatelessWidget {
  const _StudentMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 64),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondarySlate,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}
