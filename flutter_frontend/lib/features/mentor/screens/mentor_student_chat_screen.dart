import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';

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
      elevation: 0,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Semantics(
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
        ),
      ),
      titleSpacing: 10,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.student.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(Icons.circle, color: Color(0xFF059669), size: 7),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Murid',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          // Banner Ruang Belajar Murid
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
            child: Semantics(
              button: true,
              label: 'Buka ruang belajar murid',
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.mentorStudentLearningRoom,
                  arguments: widget.student,
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primaryNavy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Ruang belajar murid: materi, tugas, proye...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.secondarySlate,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Security notice
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Percakapan terenkripsi · tersimpan sebagai bukti kerja',
              style: TextStyle(
                color: AppColors.secondarySlate,
                fontSize: 11.5,
              ),
            ),
          ),

          // Chat messages list
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
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),

          // Quick Replies & Input Container
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderSlate),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final reply in _quickReplies)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _sendMessage(reply),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderSlate),
                              ),
                              child: Text(
                                reply,
                                style: const TextStyle(
                                  color: AppColors.darkSlate,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Input Row: Attachment + TextField + Solid Navy Send
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Bagikan materi',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _shareMaterial,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.darkSlate,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan',
                          hintStyle: const TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Kirim pesan',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _sendMessage(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryNavy.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
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
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.76,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: message.isMine ? AppColors.primaryNavy : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(message.isMine ? 18 : 4),
          bottomRight: Radius.circular(message.isMine ? 4 : 18),
        ),
        border: message.isMine
            ? null
            : Border.all(color: AppColors.borderSlate.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: message.isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: message.isMine ? Colors.white : AppColors.darkSlate,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.time,
            style: TextStyle(
              color: message.isMine ? Colors.white70 : AppColors.secondarySlate,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    ),
  );
}
