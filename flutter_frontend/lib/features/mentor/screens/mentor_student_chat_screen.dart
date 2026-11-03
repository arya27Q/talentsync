import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorStudentChatScreen extends StatefulWidget {
  const MentorStudentChatScreen({super.key, required this.student});

  final MentorStudent student;

  @override
  State<MentorStudentChatScreen> createState() =>
      _MentorStudentChatScreenState();
}

class _MentorStudentChatScreenState extends State<MentorStudentChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  static const _quickReplies = [
    'Materi baru sudah saya unggah',
    'Tugasmu sudah saya nilai',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.student.initials == 'AP') {
      _messages.addAll(const [
        _ChatMessage(
          text:
              'Arya, materi struktur BLoC sudah saya unggah di ruang belajar.',
          isMine: true,
          time: 'Kemarin',
        ),
        _ChatMessage(
          text: 'Siap, Mas. Kalau ada yang bingung saya tanya di sini.',
          isMine: false,
          time: 'Kemarin',
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? suggested]) {
    final message = (suggested ?? _messageController.text).trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(text: message, isMine: true, time: 'Baru saja'),
      );
      if (suggested == null) _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _shareMaterial() async {
    final titleController = TextEditingController();
    final linkController = TextEditingController();
    final shared = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bagikan materi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Nama materi'),
            ),
            TextField(
              controller: linkController,
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
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (shared == true && mounted) {
      final title = titleController.text.trim();
      final link = linkController.text.trim();
      if (title.isEmpty || link.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi nama dan tautan materi.')),
        );
      } else {
        _sendMessage('Saya membagikan $title: $link');
      }
    }
    titleController.dispose();
    linkController.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leadingWidth: 56,
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkSlate,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          MentorAvatar(
            initials: widget.student.initials,
            size: 42,
            color: AppColors.primaryNavy,
            textColor: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkSlate,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (widget.student.initials == 'AP')
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF059669), size: 8),
                      SizedBox(width: 5),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const MentorTag(
            'Murid',
            color: AppColors.lightBlueSurface,
            textColor: AppColors.primaryNavy,
          ),
          const SizedBox(width: 10),
        ],
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.mentorStudentLearningRoom,
                  arguments: widget.student,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueSurface,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.menu_book_outlined,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Ruang belajar murid: materi, tugas, proyek',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.secondarySlate,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Gunakan chat untuk koordinasi materi dan sesi.',
              style: TextStyle(color: AppColors.secondarySlate, fontSize: 12),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Mulai percakapan dengan murid.',
                      style: TextStyle(color: AppColors.secondarySlate),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              18,
              10,
              18,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderSlate)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final reply in _quickReplies)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton(
                            onPressed: () => _sendMessage(reply),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkSlate,
                              side: const BorderSide(
                                color: AppColors.borderSlate,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: Text(reply, maxLines: 1),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Bagikan materi',
                      onPressed: _shareMaterial,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.canvasWhite,
                        foregroundColor: AppColors.secondarySlate,
                      ),
                      icon: const Icon(Icons.attach_file_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan',
                          filled: true,
                          fillColor: AppColors.canvasWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.borderSlate,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.borderSlate,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Kirim pesan',
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
  });

  final String text;
  final bool isMine;
  final String time;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) => Align(
    alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 9),
          decoration: BoxDecoration(
            color: message.isMine ? AppColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(19),
              topRight: const Radius.circular(19),
              bottomLeft: Radius.circular(message.isMine ? 19 : 5),
              bottomRight: Radius.circular(message.isMine ? 5 : 19),
            ),
            border: message.isMine
                ? null
                : Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: message.isMine ? Colors.white : AppColors.darkSlate,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message.time,
                style: TextStyle(
                  color: message.isMine
                      ? Colors.white70
                      : AppColors.secondarySlate,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
