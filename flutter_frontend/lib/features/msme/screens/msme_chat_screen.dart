import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_submission_screen.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';
import 'package:flutter_frontend/features/workspace/screens/workspace_kanban_screen.dart';
import 'package:flutter_frontend/features/workspace/widgets/meeting_link_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class MsmeChatScreen extends StatefulWidget {
  const MsmeChatScreen({
    super.key,
    this.projectId,
    this.studentName = 'Mahasiswa',
    this.workspaceApi,
    this.msmeApi,
  });

  final int? projectId;
  final String studentName;
  final WorkspaceApi? workspaceApi;
  final MsmeApi? msmeApi;

  @override
  State<MsmeChatScreen> createState() => _MsmeChatScreenState();
}

class _MsmeChatScreenState extends State<MsmeChatScreen> {
  late final WorkspaceApi _workspaceApi =
      widget.workspaceApi ?? WorkspaceApi.instance;
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  int? _resolvedProjectId;
  int? _currentUserId;
  Map<String, dynamic> _project = const {};
  Map<String, dynamic>? _acceptedStudent;
  Map<String, dynamic>? _activeMilestone;
  List<Map<String, dynamic>> _messages = const [];

  final List<String> _quickReplies = const [
    'Kapan bisa mulai?',
    'Hasilnya sudah saya cek',
    'Ada revisi minor',
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

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MH';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await ApiClient.instance.readSessionUser();
      _currentUserId = (user?['id'] as num?)?.toInt();

      var targetId = widget.projectId ?? _resolvedProjectId;
      if (targetId == null) {
        final projects = await _msmeApi.getMyProjects();
        if (projects.isNotEmpty) {
          final ongoing = projects.where(
            (p) => p['status'] == 'in_progress' || p['status'] == 'review',
          );
          final picked = ongoing.isNotEmpty ? ongoing.first : projects.first;
          targetId = (picked['id'] as num?)?.toInt();
        }
      }

      if (targetId == null) {
        if (!mounted) return;
        setState(() {
          _resolvedProjectId = null;
          _messages = const [];
          _isLoading = false;
        });
        return;
      }

      final res = await _workspaceApi.messages(targetId);
      if (!mounted) return;
      setState(() {
        _resolvedProjectId = targetId;
        _project = (res['project'] as Map<String, dynamic>?) ?? const {};
        _acceptedStudent = res['accepted_student'] as Map<String, dynamic>?;
        _activeMilestone = res['active_milestone'] as Map<String, dynamic>?;
        _messages = ((res['messages'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
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
          _error = 'Belum ada percakapan proyek yang aktif.';
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

  Future<void> _sendMessage([String? customText]) async {
    final projectId = _resolvedProjectId;
    final text = (customText ?? _messageController.text).trim();
    if (projectId == null || text.isEmpty || _isSending) return;

    if (customText == null) {
      _messageController.clear();
    }
    setState(() => _isSending = true);
    try {
      final created = await _workspaceApi.sendMessage(
        projectId,
        message: text,
        milestoneId: (_activeMilestone?['id'] as num?)?.toInt(),
      );
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, created];
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAndSendFile() async {
    final projectId = _resolvedProjectId;
    if (projectId == null || _isSending) return;

    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih Lampiran Proyek',
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'zip'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran lampiran maksimal 5 MB.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);
    try {
      final created = await _workspaceApi.sendMessage(
        projectId,
        fileName: picked.name,
        fileBytes: bytes,
        milestoneId: (_activeMilestone?['id'] as num?)?.toInt(),
      );
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, created];
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _openReviewSubmission() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => const MsmeReviewSubmissionScreen(),
      ),
    );
  }

  void _openKanbanMonitor() {
    final projectId = _resolvedProjectId;
    if (projectId == null) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkspaceKanbanScreen(
          projectId: projectId,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _sendMeetingLink(String studentName) async {
    if (_resolvedProjectId == null || _isSending) return;
    final result = await MeetingLinkHelper.showSendSheet(
      context,
      partnerName: studentName,
    );
    if (result == null || !mounted) return;
    await _sendMessage(result.toChatMessage());
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStudentName =
        (_acceptedStudent?['name'] as String?) ?? widget.studentName;
    final projectTitle = (_project['title'] as String?) ?? 'Proyek UMKM';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Kembali',
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _initials(resolvedStudentName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedStudentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          projectTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondarySlate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_resolvedProjectId != null) ...[
                    IconButton(
                      tooltip: 'Kirim Link Google Meet / Zoom',
                      onPressed: () => _sendMeetingLink(resolvedStudentName),
                      icon: const Icon(
                        Icons.videocam_rounded,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Pantau Kanban',
                      onPressed: _openKanbanMonitor,
                      icon: const Icon(
                        Icons.view_kanban_rounded,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Top Banner: Active milestone / review shortcut
            if (_resolvedProjectId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: InkWell(
                  onTap: _openReviewSubmission,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.rate_review_rounded,
                            color: AppColors.primaryNavy,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _activeMilestone != null
                                ? 'Tahap ${_activeMilestone!['step_order']}: ${_activeMilestone!['title']}'
                                : 'Tinjau hasil tahap yang diajukan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
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

            // Encrypted note
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Percakapan tersimpan sebagai riwayat kolaborasi proyek',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondarySlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Chat Message List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                              ),
                              onPressed: _load,
                              child: const Text('Muat Ulang'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _resolvedProjectId == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada proyek berjalan. Terima pelamar mahasiswa terlebih dahulu untuk mulai berkolaborasi di ruang obrolan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: _messages.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(24),
                              children: const [
                                SizedBox(height: 50),
                                Center(
                                  child: Text(
                                    'Belum ada pesan. Sapa mahasiswa pelaksana untuk memulai koordinasi pengerjaan proyek.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.secondarySlate,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) =>
                                  _buildMessageBubble(_messages[index]),
                            ),
                    ),
            ),

            // Quick Reply Chips
            if (_resolvedProjectId != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Row(
                  children: _quickReplies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: _isSending ? null : () => _sendMessage(reply),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: Text(
                            reply,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Bottom Input Row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderSlate.withValues(alpha: 0.8),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: IconButton(
                      tooltip: 'Lampirkan file',
                      padding: EdgeInsets.zero,
                      onPressed:
                          (_isSending || _resolvedProjectId == null)
                          ? null
                          : _pickAndSendFile,
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: AppColors.secondarySlate,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _messageController,
                        enabled: _resolvedProjectId != null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _resolvedProjectId != null
                          ? AppColors.primaryNavy
                          : AppColors.borderSlate,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Kirim pesan',
                      padding: EdgeInsets.zero,
                      onPressed:
                          (_isSending || _resolvedProjectId == null)
                          ? null
                          : () => _sendMessage(),
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
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

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = (msg['sender_id'] as num?)?.toInt() == _currentUserId;
    final text = (msg['message'] as String?) ?? '';
    final attachmentUrl = ApiClient.resolveMediaUrl(
      msg['attachment_url'] as String?,
    );
    final attachmentName = (msg['attachment_name'] as String?) ?? 'Lampiran';
    final time = _formatTime(msg['created_at'] as String?);
    final parsedMeeting = MeetingLinkHelper.parse(text);
    if (parsedMeeting != null && attachmentUrl == null) {
      return MeetingLinkHelper.buildMeetingCard(
        context,
        meeting: parsedMeeting,
        isMe: isMe,
        timeLabel: time,
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe ? null : Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: (isMe ? AppColors.primaryNavy : const Color(0xFF0F172A))
                  .withValues(alpha: isMe ? 0.18 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isMe ? Colors.white : AppColors.darkSlate,
                  height: 1.4,
                ),
              ),
            if (attachmentUrl != null) ...[
              if (text.isNotEmpty) const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(attachmentUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 16,
                      color: isMe ? Colors.white : AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        attachmentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isMe ? Colors.white : AppColors.primaryNavy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (time.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.72)
                      : AppColors.secondarySlate,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
