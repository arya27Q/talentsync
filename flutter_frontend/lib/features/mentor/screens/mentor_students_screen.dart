import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_student_learning_room_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorStudentsScreen extends StatefulWidget {
  const MentorStudentsScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorStudentsScreen> createState() => _MentorStudentsScreenState();
}

class _MentorStudentsScreenState extends State<MentorStudentsScreen> {
  final _students = <MentorStudent>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final enrollments = await MentorApi.instance.enrollments();
      final byStudent = <int, MentorStudent>{};
      for (final enrollment in enrollments) {
        final student = MentorStudent.fromEnrollment(enrollment);
        if (student.id != null)
          byStudent.putIfAbsent(student.id!, () => student);
      }
      if (mounted)
        setState(() {
          _students
            ..clear()
            ..addAll(byStudent.values);
        });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
    final candidates = _students
        .where((item) => (item.assessmentScore ?? 0) >= 80 && !item.recommended)
        .toList();
    final eligible = student ?? (candidates.isEmpty ? null : candidates.first);
    if (eligible == null || eligible.enrollmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada murid selesai dengan nilai minimal 80 yang menunggu endorsement.',
          ),
        ),
      );
      return;
    }
    final notesController = TextEditingController();
    final notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Endorse ${eligible.name}'),
        content: TextField(
          controller: notesController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Catatan rekomendasi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = notesController.text.trim();
              if (value.length >= 10) Navigator.pop(dialogContext, value);
            },
            child: const Text('Kirim endorsement'),
          ),
        ],
      ),
    );
    notesController.dispose();
    if (notes == null || !mounted) return;
    try {
      await MentorApi.instance.endorse(eligible.enrollmentId!, notes);
      await _loadStudents();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Endorsement untuk ${eligible.name} berhasil dikirim.',
            ),
          ),
        );
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _students;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header matching design
          MentorPageHeader(
            title: 'Murid Saya',
            subtitle: '${students.length} murid dari booking mentoring',
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: _loadStudents,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : students.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada murid yang terdaftar.',
                      style: TextStyle(color: AppColors.secondarySlate),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentCard(
                        student: student,
                        recommended: student.recommended,
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
    _ => AppColors.primaryNavy, // Deep Royal Navy
  };

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.8)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
