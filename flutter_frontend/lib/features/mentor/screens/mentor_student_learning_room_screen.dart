import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
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
  List<Map<String, dynamic>> _assignments = const [];
  bool _loadingAssignments = true;
  String? _assignmentError;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final enrollmentId = widget.student.enrollmentId;
    if (enrollmentId == null) {
      setState(() {
        _loadingAssignments = false;
        _assignmentError = 'Data pendaftaran sesi tidak tersedia.';
      });
      return;
    }
    try {
      final assignments = await MentorApi.instance.assignments(enrollmentId);
      if (!mounted) return;
      setState(() {
        _assignments = assignments;
        _loadingAssignments = false;
        _assignmentError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingAssignments = false;
        _assignmentError = error.message;
      });
    }
  }

  List<String> get _tabs => [
    'Materi',
    'Tugas (${_assignments.length})',
    'Proyek',
    'Sertifikat',
  ];

  Color get _studentColor => switch (widget.student.initials) {
    'DL' => const Color(0xFF0F766E),
    'RH' => const Color(0xFFA03B1E),
    _ => AppColors.primaryNavy,
  };

  Future<void> _toggleRecommendation() async {
    final enrollmentId = widget.student.enrollmentId;
    if (enrollmentId == null || _recommended) return;
    final notes = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri endorsement'),
        content: TextField(
          controller: notes,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Catatan untuk murid'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await MentorApi.instance.endorse(enrollmentId, notes.text.trim());
        if (!mounted) return;
        setState(() => _recommended = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endorsement berhasil disimpan.')),
        );
      } on ApiException catch (error) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
    notes.dispose();
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
                    children: List.generate(_tabs.length, (index) {
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
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                // Tab Content List
                if (_selectedTab == 1) ...[
                  if (_loadingAssignments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_assignmentError != null)
                    _LearningEmptyState(
                      message: _assignmentError!,
                      onRetry: _loadAssignments,
                    )
                  else if (_assignments.isEmpty)
                    const _LearningEmptyState(
                      message: 'Belum ada tugas untuk sesi ini.',
                    )
                  else
                    for (final assignment in _assignments) ...[
                      _AssignmentCard(assignment: assignment),
                      const SizedBox(height: 12),
                    ],
                ] else ...[
                  _LearningEmptyState(
                    message: _selectedTab == 0
                        ? 'Materi dibagikan lewat chat sesi. Buka chat untuk melihat tautan materi yang dikirim.'
                        : _selectedTab == 2
                        ? 'Data proyek murid belum tersedia di backend mentor.'
                        : 'Data sertifikat murid belum tersedia di backend mentor.',
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

class _LearningEmptyState extends StatelessWidget {
  const _LearningEmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderSlate),
    ),
    child: Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondarySlate),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});
  final Map<String, dynamic> assignment;

  @override
  Widget build(BuildContext context) {
    final submissions = (assignment['submissions'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final due = DateTime.tryParse(assignment['due_at'] as String? ?? '');
    return Container(
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
            assignment['title'] as String? ?? 'Tugas',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
            ),
          ),
          if ((assignment['description'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              assignment['description'] as String,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            due == null
                ? 'Tanpa tenggat'
                : 'Tenggat ${due.toLocal().toString().substring(0, 16)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondarySlate,
            ),
          ),
          const Divider(height: 20),
          if (submissions.isEmpty)
            const Text(
              'Belum ada pengumpulan tugas.',
              style: TextStyle(color: AppColors.secondarySlate),
            )
          else
            for (final submission in submissions)
              _SubmissionRow(submission: submission),
        ],
      ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({required this.submission});
  final Map<String, dynamic> submission;

  @override
  Widget build(BuildContext context) {
    final status = submission['status'] as String? ?? 'submitted';
    return Row(
      children: [
        Expanded(
          child: Text(
            '${submission['student_name'] ?? 'Murid'} · $status${submission['score'] == null ? '' : ' · ${submission['score']}/100'}',
            style: const TextStyle(fontSize: 13, color: AppColors.darkSlate),
          ),
        ),
        if (submission['id'] is int && status == 'submitted')
          TextButton(
            onPressed: () => _review(context, submission['id'] as int),
            child: const Text('Nilai'),
          ),
      ],
    );
  }

  Future<void> _review(BuildContext context, int id) async {
    final scoreController = TextEditingController();
    final feedbackController = TextEditingController();
    var decision = 'reviewed';
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nilai pengumpulan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nilai (0–100)'),
              ),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Umpan balik'),
              ),
              DropdownButton<String>(
                value: decision,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'reviewed',
                    child: Text('Selesai dinilai'),
                  ),
                  DropdownMenuItem(
                    value: 'revision_requested',
                    child: Text('Minta revisi'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => decision = value ?? 'reviewed'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    if (result == true && context.mounted) {
      final score = int.tryParse(scoreController.text);
      if (score == null || feedbackController.text.trim().length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Isi nilai dan umpan balik minimal 3 karakter.'),
          ),
        );
      } else {
        try {
          await MentorApi.instance.reviewSubmission(
            submissionId: id,
            score: score,
            feedback: feedbackController.text.trim(),
            decision: decision,
          );
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Penilaian tersimpan. Muat ulang halaman untuk melihat status terbaru.',
                ),
              ),
            );
        } on ApiException catch (error) {
          if (context.mounted)
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.message)));
        }
      }
    }
    scoreController.dispose();
    feedbackController.dispose();
  }
}
