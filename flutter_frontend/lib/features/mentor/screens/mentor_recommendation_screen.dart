import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_recommendation.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorRecommendationArgs {
  const MentorRecommendationArgs({this.initialStudent, this.onSelectTab});

  final MentorStudent? initialStudent;
  final ValueChanged<int>? onSelectTab;
}

class MentorRecommendationScreen extends StatefulWidget {
  const MentorRecommendationScreen({
    super.key,
    this.initialStudent,
    this.onSelectTab,
  });

  final MentorStudent? initialStudent;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorRecommendationScreen> createState() =>
      _MentorRecommendationScreenState();
}

class _MentorRecommendationScreenState
    extends State<MentorRecommendationScreen> {
  final _reasonController = TextEditingController();
  int _projectIndex = 0;
  late String _studentName;

  MentorUmkmProject get _project => mentorUmkmProjects[_projectIndex];

  MentorRecommendationCandidate get _candidate =>
      mentorRecommendationCandidates.firstWhere(
        (candidate) => candidate.student.name == _studentName,
        orElse: () => mentorRecommendationCandidates.first,
      );

  @override
  void initState() {
    super.initState();
    _studentName = widget.initialStudent?.name ?? mentorStudentDewi.name;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _prepareRecommendation() {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan alasan rekomendasi terlebih dahulu.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      MentorRecommendationDraft(
        project: _project,
        candidate: _candidate,
        reason: _reasonController.text.trim(),
      ),
    );
  }

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
            'Rekomendasi ke UMKM',
            style: TextStyle(
              color: AppColors.darkSlate,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Bantu murid terbaikmu dapat proyek nyata',
            style: TextStyle(color: AppColors.secondarySlate, fontSize: 12),
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
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        children: [
          const _StepHeading('1. Permintaan dari UMKM'),
          for (var index = 0; index < mentorUmkmProjects.length; index++) ...[
            _ProjectChoice(
              project: mentorUmkmProjects[index],
              selected: index == _projectIndex,
              onTap: () => setState(() => _projectIndex = index),
            ),
            if (index != mentorUmkmProjects.length - 1)
              const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
          const _StepHeading('2. Pilih murid yang paling cocok'),
          for (final candidate in mentorRecommendationCandidates) ...[
            _CandidateChoice(
              candidate: candidate,
              selected: candidate.student.name == _studentName,
              onTap: () =>
                  setState(() => _studentName = candidate.student.name),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3. Alasan rekomendasi',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Ceritakan kenapa ${_candidate.student.name} cocok untuk ${_project.title}: hasil sesi, proyek nyata, sikap kerja',
                    filled: true,
                    fillColor: AppColors.canvasWhite,
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(
                        color: AppColors.primaryNavy,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dipilih: ${_candidate.matchPercent}% kecocokan · ${_project.rewardTc} TC',
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
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _prepareRecommendation,
              icon: const Icon(Icons.thumb_up_alt_outlined),
              label: const Text('Siapkan rekomendasi'),
            ),
          ),
        ),
        MentorBottomNav(
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
      ],
    ),
  );
}

class _StepHeading extends StatelessWidget {
  const _StepHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.darkSlate,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ProjectChoice extends StatelessWidget {
  const _ProjectChoice({
    required this.project,
    required this.selected,
    required this.onTap,
  });

  final MentorUmkmProject project;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.lightBlueSurface : Colors.white,
    borderRadius: BorderRadius.circular(21),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: AppColors.accentAmberDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    project.businessName,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${project.skills.join(' · ')} · ${project.rewardTc} TC',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CandidateChoice extends StatelessWidget {
  const _CandidateChoice({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final MentorRecommendationCandidate candidate;
  final bool selected;
  final VoidCallback onTap;

  Color get _avatarColor => switch (candidate.student.initials) {
    'DL' => const Color(0xFF147D76),
    'RH' => const Color(0xFFAA3D17),
    _ => AppColors.primaryNavy,
  };

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.lightBlueSurface : Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            MentorAvatar(
              initials: candidate.student.initials,
              size: 48,
              color: _avatarColor,
              textColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    candidate.student.name,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${candidate.skills.join(', ')} · ${candidate.certificates} sertifikat',
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '${candidate.matchPercent}%',
                style: const TextStyle(
                  color: AppColors.accentAmberDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
