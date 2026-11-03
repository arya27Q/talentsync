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
        ? 44 * 60 + 36
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

  Future<void> _copyMeetingLink() async {
    final meetingUrl = widget.meetingUrl;
    if (meetingUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan sesi belum ditambahkan.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: meetingUrl));
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
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Mentoring',
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
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          Container(
            height: 210,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSlate,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29364F),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      widget.meetingUrl == null
                          ? 'Tautan Google Meet belum ditambahkan'
                          : Uri.parse(widget.meetingUrl!).host +
                                Uri.parse(widget.meetingUrl!).path,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 4,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'DP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MentorCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6E8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.timer_outlined,
                    color: AppColors.accentAmberDeep,
                    size: 30,
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
                          fontSize: 32,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  icon: Icons.playlist_add_rounded,
                  label: 'Beri tugas',
                  onTap: _addTask,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan sesi',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                for (final note in _notes) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.canvasWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        color: AppColors.darkSlate,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveNote(),
                  decoration: InputDecoration(
                    hintText: 'Tambah catatan',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    suffixIcon: IconButton(
                      tooltip: 'Simpan catatan',
                      onPressed: _saveNote,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),
                if (_materials.isNotEmpty || _tasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryNavy, size: 22),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
