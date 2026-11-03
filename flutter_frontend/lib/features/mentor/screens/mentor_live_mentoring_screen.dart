import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorLiveMentoringArgs {
  const MentorLiveMentoringArgs({
    this.student = mentorStudentArya,
    this.meetingUrl,
    this.onSelectTab,
  });

  final MentorStudent student;
  final String? meetingUrl;
  final ValueChanged<int>? onSelectTab;
}

class MentorLiveMentoringScreen extends StatefulWidget {
  const MentorLiveMentoringScreen({
    super.key,
    this.student = mentorStudentArya,
    this.meetingUrl,
    this.onSelectTab,
  });

  final MentorStudent student;
  final String? meetingUrl;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorLiveMentoringScreen> createState() =>
      _MentorLiveMentoringScreenState();
}

class _MentorLiveMentoringScreenState extends State<MentorLiveMentoringScreen> {
  final _noteController = TextEditingController();
  late final List<String> _notes;
  final _materials = <String>[];
  final _tasks = <String>[];
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _notes = widget.student.initials == 'AP'
        ? ['Murid sudah menyiapkan CV versi terbaru.']
        : [];
    _secondsRemaining = widget.student.initials == 'AP'
        ? 44 * 60 + 42
        : 60 * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _secondsRemaining == 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get _meetingDisplayUrl {
    final raw = widget.meetingUrl;
    if (raw == null || raw.isEmpty) {
      return 'meet.google.com/tsy-arya-019';
    }
    return raw.replaceAll('https://', '').replaceAll('http://', '');
  }

  Future<void> _copyMeetingLink() async {
    final url = _meetingDisplayUrl;
    await Clipboard.setData(ClipboardData(text: 'https://$url'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan Google Meet disalin.')),
      );
    }
  }

  Future<void> _addMaterial() async {
    final title = TextEditingController();
    final url = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bagikan materi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Nama materi'),
            ),
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Tautan materi'),
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
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      if (title.text.trim().isEmpty || url.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi nama dan tautan materi.')),
        );
      } else {
        setState(() => _materials.add(title.text.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi ditambahkan ke ruang belajar murid.'),
          ),
        );
      }
    }
    title.dispose();
    url.dispose();
  }

  Future<void> _addTask() async {
    final title = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Beri tugas'),
        content: TextField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Nama tugas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan tugas'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      if (title.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Isi nama tugas.')));
      } else {
        setState(() => _tasks.add(title.text.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas ditambahkan ke ruang belajar murid.'),
          ),
        );
      }
    }
    title.dispose();
  }

  void _saveNote() {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    setState(() {
      _notes.add(note);
      _noteController.clear();
    });
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
                        'Live Mentoring',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.student.initials == 'AP'
                            ? 'Arya Pratama · Persiapan wawancara Flutter'
                            : '${widget.student.name} · ${widget.student.focus}',
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
              ],
            ),
          ),

          // Scrollable content with proper bottom padding to clear floating nav
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
              children: [
                // 1. Dark Video Container
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Stack(
                    children: [
                      // Meeting Link Pill
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _meetingDisplayUrl,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Student Avatar in Center
                      Center(
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.student.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),

                      // Mentor Camera Thumbnail at Bottom-Right
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 64,
                          height: 74,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'DP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Stopwatch Sisa Waktu Card
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
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.timer_outlined,
                          color: Color(0xFFD97706),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sisa waktu sesi',
                              style: TextStyle(
                                color: AppColors.secondarySlate,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _timeLabel,
                              style: const TextStyle(
                                color: AppColors.darkSlate,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '30 TC',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Quick Action Buttons Row (Bagikan materi, Bagikan tautan, Beri tugas)
                Row(
                  children: [
                    Expanded(
                      child: _SessionAction(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Bagikan materi',
                        onTap: _addMaterial,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SessionAction(
                        icon: Icons.link_rounded,
                        label: 'Bagikan tautan',
                        onTap: _copyMeetingLink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SessionAction(
                        icon: Icons.assignment_outlined,
                        label: 'Beri tugas',
                        onTap: _addTask,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Catatan Sesi Card
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
                        'Catatan sesi',
                        style: TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Existing Notes
                      for (final note in _notes) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            note,
                            style: const TextStyle(
                              color: AppColors.darkSlate,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Input Row: TextField + External Blue + button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _saveNote(),
                              decoration: InputDecoration(
                                hintText: 'Tambah catatan',
                                hintStyle: const TextStyle(
                                  color: AppColors.secondarySlate,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSlate,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderSlate,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryNavy,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Semantics(
                            button: true,
                            label: 'Simpan catatan sesi',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _saveNote,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNavy,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryNavy
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_materials.isNotEmpty || _tasks.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          '${_materials.length} materi · ${_tasks.length} tugas ditambahkan',
                          style: const TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
      selectedIndex: 0,
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

class _SessionAction extends StatelessWidget {
  const _SessionAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderSlate.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryNavy, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
