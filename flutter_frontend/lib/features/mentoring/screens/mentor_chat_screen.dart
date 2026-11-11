import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorChatScreen extends StatefulWidget {
  const MentorChatScreen({
    super.key,
    this.enrollmentId,
    this.mentoringApi,
  });

  final int? enrollmentId;
  final StudentMentoringApi? mentoringApi;

  @override
  State<MentorChatScreen> createState() => _MentorChatScreenState();
}

class _MentorChatScreenState extends State<MentorChatScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int? _resolvedEnrollmentId;
  int? _currentUserId;
  Map<String, dynamic> _enrollment = const {};
  List<Map<String, dynamic>> _messages = const [];

  final List<String> _suggestions = const [
    'Saya mau tanya materi',
    'Tugas sudah saya kirim',
    'Bisa reschedule sesi?',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await ApiClient.instance.readSessionUser();
      _currentUserId = (user?['id'] as num?)?.toInt();

      var targetId = widget.enrollmentId ?? _resolvedEnrollmentId;
      if (targetId == null) {
        final mine = await _api.myEnrollments();
        if (mine.isEmpty) {
          throw const ApiException('Belum ada sesi mentoring untuk chat.');
        }
        targetId = (mine.first['id'] as num).toInt();
      }
      final results = await Future.wait([
        _api.enrollmentDetail(targetId),
        _api.messages(targetId),
      ]);
      if (!mounted) return;
      setState(() {
        _resolvedEnrollmentId = targetId;
        _enrollment = results[0] as Map<String, dynamic>;
        _messages = (results[1] as List).whereType<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat obrolan mentor.';
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
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

  Future<void> _send([String? preset]) async {
    final enrollmentId = _resolvedEnrollmentId;
    final text = (preset ?? _messageController.text).trim();
    if (enrollmentId == null || text.isEmpty || _isSending) return;
    if (preset == null) _messageController.clear();

    setState(() => _isSending = true);
    try {
      final msg = await _api.sendMessage(enrollmentId, message: text);
      if (!mounted) return;
      setState(() => _messages = [..._messages, msg]);
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndSendFile() async {
    final enrollmentId = _resolvedEnrollmentId;
    if (enrollmentId == null || _isSending) return;

    final file = await FilePicker.pickFile(
      dialogTitle: 'Pilih Lampiran',
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'zip'],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();

    setState(() => _isSending = true);
    try {
      final msg = await _api.sendMessage(
        enrollmentId,
        fileName: file.name,
        fileBytes: bytes,
      );
      if (!mounted) return;
      setState(() => _messages = [..._messages, msg]);
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cls = (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (cls['mentor_name'] as String?) ?? 'Mentor';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mentorName,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
              ),
            ),
            const Text(
              'Peer Mentor · Bimbingan Aktif',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Coba lagi')),
                  ],
                ),
              )
            : Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.ruangBelajar,
                      arguments: MentoringEnrollmentArgs(
                        enrollmentId: _resolvedEnrollmentId,
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      color: const Color(0xFFEFF6FF),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 16,
                            color: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Buka Ruang Belajar: ${cls['topic'] ?? 'Materi & Tugas'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primaryNavy,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length,
                        itemBuilder: (_, index) {
                          final msg = _messages[index];
                          final isMe =
                              (msg['sender_id'] as num?)?.toInt() ==
                              _currentUserId;
                          final attachment = ApiClient.resolveMediaUrl(
                            msg['attachment_url'] as String?,
                          );
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: const BoxConstraints(maxWidth: 270),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primaryNavy : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isMe
                                    ? null
                                    : Border.all(color: AppColors.borderSlate),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((msg['message'] as String?) != null)
                                    Text(
                                      msg['message'] as String,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : AppColors.darkSlate,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  if (attachment != null)
                                    GestureDetector(
                                      onTap: () async {
                                        final uri = Uri.tryParse(attachment);
                                        if (uri != null) {
                                          await launchUrl(
                                            uri,
                                            mode: LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Lihat Lampiran',
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : AppColors.primaryNavy,
                                          decoration: TextDecoration.underline,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ActionChip(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderSlate),
                        label: Text(
                          _suggestions[i],
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        onPressed: () => _send(_suggestions[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: AppColors.borderSlate),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _isSending ? null : _pickAndSendFile,
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Tulis pesan ke mentor...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isSending ? null : () => _send(),
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
