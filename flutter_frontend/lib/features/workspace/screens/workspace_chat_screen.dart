import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';
import 'package:flutter_frontend/features/workspace/widgets/meeting_link_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkspaceChatScreen extends StatefulWidget {
  const WorkspaceChatScreen({
    super.key,
    this.projectId,
    this.workspaceApi,
    this.projectApi,
  });

  final int? projectId;
  final WorkspaceApi? workspaceApi;
  final ProjectApi? projectApi;

  @override
  State<WorkspaceChatScreen> createState() => _WorkspaceChatScreenState();
}

class _WorkspaceChatScreenState extends State<WorkspaceChatScreen> {
  late final WorkspaceApi _api = widget.workspaceApi ?? WorkspaceApi.instance;
  late final ProjectApi _projectApi = widget.projectApi ?? ProjectApi.instance;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  bool _canSend = true;
  String? _applicationStatus;
  String? _chatClosedReason;
  String? _error;
  int? _resolvedProjectId;
  int? _currentUserId;
  Map<String, dynamic> _project = const {};
  Map<String, dynamic>? _activeMilestone;
  List<Map<String, dynamic>> _messages = const [];

  final List<String> _quickChips = const [
    'Halo, saya kirim pratinjau terbarunya',
    'Tahap milestone sudah siap ditinjau',
    'Apakah ada catatan revisi untuk bagian ini?',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
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
        final mine = await _projectApi.myProjects();
        final active = (mine['active_projects'] as List?) ?? const [];
        if (active.isNotEmpty) {
          targetId = ((active.first as Map<String, dynamic>)['id'] as num)
              .toInt();
        } else {
          final explore = await _projectApi.explore();
          final open = (explore['data'] as List?) ?? const [];
          if (open.isEmpty) {
            throw const ApiException('Belum ada proyek untuk ruang obrolan.');
          }
          targetId = ((open.first as Map<String, dynamic>)['id'] as num)
              .toInt();
        }
      }

      final res = await _api.messages(targetId);
      if (!mounted) return;
      setState(() {
        _resolvedProjectId = targetId;
        _project = (res['project'] as Map<String, dynamic>?) ?? const {};
        _activeMilestone = res['active_milestone'] as Map<String, dynamic>?;
        _canSend = res['can_send'] != false;
        _applicationStatus = res['application_status'] as String?;
        _chatClosedReason = res['chat_closed_reason'] as String?;
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
          _error = 'Gagal memuat obrolan workspace.';
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

  Future<void> _sendMessage([String? presetText]) async {
    final projectId = _resolvedProjectId;
    final text = (presetText ?? _textController.text).trim();
    if (projectId == null || text.isEmpty || _isSending) return;

    if (presetText == null) _textController.clear();
    setState(() => _isSending = true);
    try {
      final created = await _api.sendMessage(
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
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
          const SnackBar(content: Text('Ukuran lampiran maksimal 5 MB.')),
        );
      }
      return;
    }

    setState(() => _isSending = true);
    try {
      final created = await _api.sendMessage(
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMeetingLink(String partnerName) async {
    if (_resolvedProjectId == null || _isSending) return;
    final result = await MeetingLinkHelper.showSendSheet(
      context,
      partnerName: partnerName,
    );
    if (result == null || !mounted) return;
    await _sendMessage(result.toChatMessage());
  }

  @override
  Widget build(BuildContext context) {
    final msme = (_project['msme'] as Map<String, dynamic>?) ?? const {};
    final partnerName = (msme['business_name'] as String?) ?? 'Mitra UMKM';

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
              partnerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
              ),
            ),
            const Text(
              'Mitra UMKM · Obrolan Proyek',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Kirim Link Google Meet / Zoom',
            onPressed: _resolvedProjectId == null
                ? null
                : () => _sendMeetingLink(partnerName),
            icon: const Icon(
              Icons.videocam_rounded,
              color: AppColors.primaryNavy,
            ),
          ),
          IconButton(
            tooltip: 'Papan Kanban',
            onPressed: _resolvedProjectId == null
                ? null
                : () => Navigator.pushNamed(
                    context,
                    AppRoutes.workspaceKanban,
                    arguments: ProjectRouteArgs(projectId: _resolvedProjectId),
                  ),
            icon: const Icon(
              Icons.view_kanban_rounded,
              color: AppColors.primaryNavy,
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang pesan',
            onPressed: _isLoading ? null : _load,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.secondarySlate,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  if (_activeMilestone != null)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.submission,
                        arguments: ProjectRouteArgs(
                          projectId: _resolvedProjectId,
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
                              Icons.flag_rounded,
                              size: 16,
                              color: AppColors.primaryNavy,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tahap ${_activeMilestone!['step_order']}: ${_activeMilestone!['title']}',
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
                      child: _messages.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(24),
                              children: const [
                                SizedBox(height: 60),
                                Center(
                                  child: Text(
                                    'Belum ada pesan. Mulai diskusikan detail proyek dengan mitra UMKM.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                final isMe =
                                    (msg['sender_id'] as num?)?.toInt() ==
                                    _currentUserId;
                                final attachmentUrl = ApiClient.resolveMediaUrl(
                                  msg['attachment_url'] as String?,
                                );
                                final attachmentName =
                                    (msg['attachment_name'] as String?) ??
                                    'Lampiran berkas';
                                final timeLabel = _formatTime(
                                  msg['created_at'] as String?,
                                );
                                final parsedMeeting = MeetingLinkHelper.parse(
                                  msg['message'] as String?,
                                );
                                if (parsedMeeting != null &&
                                    attachmentUrl == null) {
                                  return MeetingLinkHelper.buildMeetingCard(
                                    context,
                                    meeting: parsedMeeting,
                                    isMe: isMe,
                                    timeLabel: timeLabel,
                                  );
                                }

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
                                    constraints: const BoxConstraints(
                                      maxWidth: 270,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppColors.primaryNavy
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isMe
                                          ? null
                                          : Border.all(
                                              color: AppColors.borderSlate,
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if ((msg['message'] as String?) != null)
                                          Text(
                                            msg['message'] as String,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : AppColors.darkSlate,
                                              fontSize: 13.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        if (attachmentUrl != null)
                                          GestureDetector(
                                            onTap: () async {
                                              final uri = Uri.tryParse(
                                                attachmentUrl,
                                              );
                                              if (uri != null) {
                                                await launchUrl(
                                                  uri,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.attach_file_rounded,
                                                  size: 16,
                                                  color: isMe
                                                      ? Colors.white
                                                      : AppColors.primaryNavy,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    attachmentName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: isMe
                                                          ? Colors.white
                                                          : AppColors
                                                                .primaryNavy,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (timeLabel.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            timeLabel,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white70
                                                  : AppColors.secondarySlate,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  if (_canSend) ...[
                    // Quick Chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _quickChips.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ActionChip(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.borderSlate),
                          label: Text(
                            _quickChips[i],
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          onPressed: () => _sendMessage(_quickChips[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input Bar
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
                            tooltip: 'Lampirkan berkas',
                            onPressed: _isSending ? null : _pickAndSendFile,
                            icon: const Icon(
                              Icons.attach_file_rounded,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Tulis pesan ke mitra UMKM...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Kirim pesan',
                            onPressed:
                                _isSending ? null : () => _sendMessage(),
                            icon: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: AppColors.primaryNavy,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFBEB),
                        border: Border(
                          top: BorderSide(color: Color(0xFFFDE68A)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 18,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _chatClosedReason ??
                                      'Obrolan ini ditutup karena lamaran tidak dilanjutkan. Baca pesan evaluasi dari Mitra UMKM di atas sebagai bahan belajar.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF92400E),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_applicationStatus == 'rejected') ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.findMentors,
                                ),
                                icon: const Icon(
                                  Icons.school_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Cari Mentor untuk Tingkatkan Keahlian',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
