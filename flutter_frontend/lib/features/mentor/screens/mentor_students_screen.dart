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
          MentorPageHeader(
            title: 'Murid Saya',
            subtitle: _drafts.isEmpty
                ? '${mentorStudents.length} murid aktif'
                : '${mentorStudents.length} murid aktif · ${_drafts.length} draft',
            trailing: IconButton(
              tooltip: 'Buat rekomendasi ke UMKM',
              onPressed: () => _openRecommendation(),
              icon: const Icon(
                Icons.thumb_up_alt_outlined,
                color: AppColors.darkSlate,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(48, 48),
                side: const BorderSide(color: AppColors.borderSlate),
              ),
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada murid yang direkomendasikan.',
                      style: TextStyle(color: AppColors.secondarySlate),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
            const Icon(Icons.assignment_outlined, color: AppColors.primaryNavy),
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
    'DL' => const Color(0xFF147D76),
    'RH' => const Color(0xFFAA3D17),
    _ => AppColors.primaryNavy,
  };

  @override
  Widget build(BuildContext context) => MentorCard(
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MentorAvatar(
              initials: student.initials,
              size: 52,
              color: _avatarColor,
              textColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.study,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.focus,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (student.needsReview > 0)
              MentorTag(
                '${student.needsReview} perlu dinilai',
                color: const Color(0xFFFFF6E8),
                textColor: AppColors.accentAmberDeep,
              ),
          ],
        ),
        const SizedBox(height: 16),
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
        if (recommended) ...[
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.thumb_up_alt_rounded,
                color: Color(0xFF047857),
                size: 17,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Sudah kamu rekomendasikan ke UMKM',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: onChat,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.darkSlate,
                  side: const BorderSide(color: AppColors.borderSlate),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  semanticLabel: 'Chat dengan ${student.name}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onRecommend,
                  icon: Icon(
                    recommended
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_alt_outlined,
                    size: 18,
                  ),
                  label: Text(
                    recommended ? 'Direkomendasikan' : 'Rekomendasikan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: AppColors.borderSlate),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onOpenRoom,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
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

class _StudentMetric extends StatelessWidget {
  const _StudentMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 66),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.canvasWhite,
      borderRadius: BorderRadius.circular(15),
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
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondarySlate, fontSize: 11),
        ),
      ],
    ),
  );
}
