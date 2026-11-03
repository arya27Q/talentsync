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
  double _confidence = 0.90; // 90% cocok by default matching screenshot

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
                    children: const [
                      Text(
                        'Rekomendasi ke UMKM',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bantu murid terbaikmu dapat proyek nyata',
                        style: TextStyle(
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

          // Scrollable list with bottom padding 120
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
              children: [
                // 1. Permintaan dari UMKM
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

                // 2. Pilih murid yang paling cocok
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
                const SizedBox(height: 14),

                // 3. Alasan rekomendasi Card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3. Alasan rekomendasi',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reasonController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _prepareRecommendation(),
                        minLines: 4,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText:
                              'Ceritakan kenapa ${_candidate.student.name} cocok untuk ${_project.title}: hasil sesi, proyek nyata, sikap kerja',
                          hintStyle: const TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 13,
                            height: 1.45,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primaryNavy,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tingkat Keyakinan Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tingkat keyakinan',
                            style: TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${(_confidence * 100).toInt()}% cocok',
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primaryNavy,
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: AppColors.primaryNavy,
                          overlayColor: AppColors.primaryNavy.withValues(alpha: 0.15),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 9,
                          ),
                        ),
                        child: Slider(
                          value: _confidence,
                          min: 0.5,
                          max: 1.0,
                          onChanged: (val) => setState(() => _confidence = val),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Dilampirkan otomatis: ${_candidate.certificates} sertifikat, ${_candidate.student.completedProjects} proyek nyata terverifikasi, riwayat nilai sesi.',
                        style: const TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Rekomendasi Terkirim Section matching Screenshot 5
                const Text(
                  'Rekomendasi terkirim',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'AP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Arya Pratama',
                              style: TextStyle(
                                color: AppColors.darkSlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '95% cocok · 2 hari lalu',
                              style: TextStyle(
                                color: AppColors.secondarySlate,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Dilihat UMKM',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
        fontSize: 16,
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
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFF0F7FF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: selected
            ? AppColors.primaryNavy
            : AppColors.borderSlate.withValues(alpha: 0.8),
        width: selected ? 1.5 : 1,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFFC2410C),
                size: 22,
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
                      fontSize: 11.5,
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
              color: selected ? AppColors.primaryNavy : const Color(0xFFCBD5E1),
              size: 22,
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
    'DL' => const Color(0xFF0F766E), // Deep Teal
    'RH' => const Color(0xFFA03B1E), // Terracotta/Rust
    _ => AppColors.primaryNavy,      // Deep Royal Navy
  };

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFF0F7FF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: selected
            ? AppColors.primaryNavy
            : AppColors.borderSlate.withValues(alpha: 0.8),
        width: selected ? 1.5 : 1,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _avatarColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                candidate.student.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
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
                      fontSize: 15,
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
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${candidate.matchPercent}%',
                style: const TextStyle(
                  color: Color(0xFFC2410C),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
