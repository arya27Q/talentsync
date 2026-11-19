import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';
import 'package:flutter_frontend/features/workspace/widgets/meeting_link_sheet.dart';

class WorkspaceKanbanScreen extends StatefulWidget {
  const WorkspaceKanbanScreen({
    super.key,
    this.projectId,
    this.readOnly = false,
    this.workspaceApi,
    this.projectApi,
  });

  final int? projectId;
  final bool readOnly;
  final WorkspaceApi? workspaceApi;
  final ProjectApi? projectApi;

  @override
  State<WorkspaceKanbanScreen> createState() => _WorkspaceKanbanScreenState();
}

class _WorkspaceKanbanScreenState extends State<WorkspaceKanbanScreen> {
  late final WorkspaceApi _api = widget.workspaceApi ?? WorkspaceApi.instance;
  late final ProjectApi _projectApi = widget.projectApi ?? ProjectApi.instance;

  bool _isLoading = true;
  bool _apiReadOnly = false;
  String? _error;
  int? _resolvedProjectId;
  Map<String, dynamic> _project = const {};
  Map<String, dynamic> _stats = const {};
  Map<String, dynamic>? _acceptedStudent;
  List<Map<String, dynamic>> _tasks = const [];

  bool get _isReadOnly => widget.readOnly || _apiReadOnly;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.projectId ?? _resolvedProjectId;
      if (targetId == null) {
        final mine = await _projectApi.myProjects();
        final active = (mine['active_projects'] as List?) ?? const [];
        if (active.isEmpty) {
          throw const ApiException('Belum ada proyek aktif pada workspace.');
        }
        targetId = ((active.first as Map<String, dynamic>)['id'] as num).toInt();
      }
      final res = await _api.kanban(targetId);
      if (!mounted) return;
      final loadedTasks = ((res['tasks'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final rawStats = (res['stats'] as Map<String, dynamic>?) ?? const {};
      final computedDone =
          loadedTasks.where((t) => t['status'] == 'done').length;
      final computedTotal = loadedTasks.length;
      final fallbackPct = (res['progress_percent'] as num?)?.toInt() ??
          (computedTotal > 0 ? ((computedDone / computedTotal) * 100).round() : 0);

      setState(() {
        _resolvedProjectId = targetId;
        _apiReadOnly = res['is_read_only'] == true;
        _project = (res['project'] as Map<String, dynamic>?) ?? const {};
        _acceptedStudent = res['accepted_student'] as Map<String, dynamic>?;
        _stats = rawStats.isNotEmpty
            ? rawStats
            : {
                'done_count': computedDone,
                'total_count': computedTotal,
                'progress_percent': fallbackPct,
              };
        _tasks = loadedTasks;
        _isLoading = false;
      });
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
          _error = 'Gagal memuat papan Kanban proyek.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddTaskDialog() async {
    final projectId = _resolvedProjectId;
    if (projectId == null || _isReadOnly) return;

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _TaskEditorDialog(
        dialogTitle: 'Tambah Tugas Kanban',
        confirmLabel: 'Simpan',
        onSave: (title, tag, deadline) async {
          await _api.createTask(
            projectId,
            title: title,
            tag: tag,
            deadlineLabel: deadline.isEmpty ? null : deadline,
          );
        },
      ),
    );
    if (created == true && mounted) {
      await _load();
    }
  }

  Future<void> _showEditTaskDialog(Map<String, dynamic> task) async {
    final taskId = (task['id'] as num).toInt();
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _TaskEditorDialog(
        dialogTitle: 'Edit Tugas Kanban',
        confirmLabel: 'Perbarui',
        initialTitle: (task['title'] as String?) ?? '',
        initialTag: (task['tag'] as String?) ?? 'Fitur',
        initialDeadline: (task['deadline_label'] as String?) ?? '',
        onSave: (title, tag, deadline) async {
          await _api.updateTask(taskId, {
            'title': title,
            'tag': tag,
            if (deadline.isNotEmpty) 'deadline_label': deadline,
          });
        },
      ),
    );
    if (updated == true && mounted) {
      await _load();
    }
  }

  Future<void> _moveTaskStatus(Map<String, dynamic> task) async {
    if (_isReadOnly) return;
    final taskId = (task['id'] as num).toInt();
    final currentStatus = (task['status'] as String?) ?? 'todo';
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (task['title'] as String?) ?? 'Tugas',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 12),
                _statusOption(ctx, 'todo', 'To-Do (Menunggu)', currentStatus),
                _statusOption(
                  ctx,
                  'in_progress',
                  'In Progress (Dikerjakan)',
                  currentStatus,
                ),
                _statusOption(
                  ctx,
                  'review',
                  'Review (Siap Dicek)',
                  currentStatus,
                ),
                _statusOption(ctx, 'done', 'Done (Selesai)', currentStatus),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.primaryNavy,
                  ),
                  title: const Text(
                    'Edit Judul & Tag Tugas',
                    style: TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, '__edit__'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                  ),
                  title: const Text(
                    'Hapus Tugas',
                    style: TextStyle(color: Color(0xFFDC2626)),
                  ),
                  onTap: () => Navigator.pop(ctx, '__delete__'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selected == null) return;
    if (selected == '__edit__') {
      await _showEditTaskDialog(task);
      return;
    }

    try {
      if (selected == '__delete__') {
        await _api.deleteTask(taskId);
      } else if (selected != currentStatus) {
        await _api.updateTask(taskId, {'status': selected});
      }
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Widget _statusOption(
    BuildContext ctx,
    String value,
    String label,
    String current,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        current == value
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: AppColors.primaryNavy,
      ),
      title: Text(label),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  void _openChat() {
    final projectId = _resolvedProjectId;
    if (projectId == null) return;
    if (_isReadOnly) {
      final studentName =
          (_acceptedStudent?['name'] as String?) ?? 'Mahasiswa Pelaksana';
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => MsmeChatScreen(
            projectId: projectId,
            studentName: studentName,
          ),
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.workspaceChat,
      arguments: ProjectRouteArgs(projectId: projectId),
    );
  }

  Future<void> _openVideoSync() async {
    final projectId = _resolvedProjectId;
    if (projectId == null) return;
    final msme = (_project['msme'] as Map<String, dynamic>?) ?? const {};
    final partnerName = _isReadOnly
        ? ((_acceptedStudent?['name'] as String?) ?? 'Mahasiswa Pelaksana')
        : ((msme['business_name'] as String?) ?? 'Mitra UMKM');

    final result = await MeetingLinkHelper.showSendSheet(
      context,
      partnerName: partnerName,
    );
    if (result == null || !mounted) return;

    try {
      await _api.sendMessage(projectId, message: result.toChatMessage());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tautan ${result.platform} berhasil dikirim ke obrolan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _openChat();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Widget _buildColumn(String title, String statusKey, Color badgeColor) {
    final items = _tasks.where((t) => t['status'] == statusKey).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${items.length})',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'Belum ada tugas di tahap ini.',
              style: TextStyle(fontSize: 12.5, color: AppColors.secondarySlate),
            )
          else
            ...items.map(
              (task) => GestureDetector(
                onTap: _isReadOnly ? null : () => _moveTaskStatus(task),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.canvasWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (task['title'] as String?) ?? '',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (task['tag'] as String?) ?? 'Fitur',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryNavy,
                                    ),
                                  ),
                                ),
                                if (((task['deadline_label'] as String?) ?? '')
                                    .isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: AppColors.secondarySlate,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        (task['deadline_label'] as String?) ??
                                            '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.secondarySlate,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!_isReadOnly)
                        const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.secondarySlate,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msme = (_project['msme'] as Map<String, dynamic>?) ?? const {};
    final doneCount = (_stats['done_count'] as num?)?.toInt() ?? 0;
    final totalCount = (_stats['total_count'] as num?)?.toInt() ?? 0;
    final pct = (_stats['progress_percent'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Kembali'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderSlate),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_left_rounded,
                                size: 26,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isReadOnly
                                      ? 'Pantau Kanban Proyek'
                                      : 'Workspace Kanban',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                Text(
                                  '${_project['title'] ?? ''} · ${msme['business_name'] ?? ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Kirim Link Google Meet / Zoom',
                            onPressed: _resolvedProjectId == null
                                ? null
                                : _openVideoSync,
                            icon: const Icon(
                              Icons.videocam_rounded,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          IconButton(
                            tooltip: _isReadOnly
                                ? 'Chat Mahasiswa'
                                : 'Chat UMKM',
                            onPressed: _resolvedProjectId == null
                                ? null
                                : _openChat,
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (_isReadOnly && _acceptedStudent != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.lightBlueSurface,
                                child: Text(
                                  ((_acceptedStudent!['name'] as String?) ?? 'M')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (_acceptedStudent!['name'] as String?) ??
                                          'Mahasiswa Pelaksana',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    Text(
                                      '${_acceptedStudent!['university'] ?? 'UNESA'} · Mode Pantau Progres',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Progress Summary
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: (pct / 100).clamp(0.0, 1.0),
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.accentAmberGold,
                                        ),
                                    strokeWidth: 5,
                                  ),
                                  Center(
                                    child: Text(
                                      '$pct%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$doneCount dari $totalCount tugas selesai',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sisa ${_project['days_left'] ?? 0} hari · Imbalan ${_project['reward_tc'] ?? 0} TC',
                                    style: const TextStyle(
                                      color: Color(0xFF93C5FD),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Quick Workspace Actions
                      if (!_isReadOnly)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryNavy,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _resolvedProjectId == null
                                      ? null
                                      : () async {
                                          await Navigator.pushNamed(
                                            context,
                                            AppRoutes.submission,
                                            arguments: ProjectRouteArgs(
                                              projectId: _resolvedProjectId,
                                            ),
                                          );
                                          _load();
                                        },
                                  icon: const Icon(
                                    Icons.upload_file_rounded,
                                    size: 18,
                                  ),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Kumpulkan Hasil',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryNavy,
                                  side: const BorderSide(
                                    color: AppColors.borderSlate,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _showAddTaskDialog,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text(
                                  'Tambah tugas',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _openChat,
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Diskusi dengan Mahasiswa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),
                      if (!_isReadOnly)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Ketuk kartu tugas untuk memindahkan tahap atau mengubah detail',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ),

                      _buildColumn('To-Do', 'todo', AppColors.secondarySlate),
                      _buildColumn(
                        'In Progress',
                        'in_progress',
                        AppColors.primaryNavy,
                      ),
                      _buildColumn(
                        'Review',
                        'review',
                        const Color(0xFFD97706),
                      ),
                      _buildColumn('Done', 'done', const Color(0xFF16A34A)),

                      if (!_isReadOnly)
                        // Mentor Help Banner
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mengalami Kendala Teknis Proyek?',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Diskusikan bug atau arsitektur langsung bersama Peer Mentor agar revisi berjalan cepat.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primaryNavy,
                                      ),
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.findMentors,
                                      ),
                                      child: const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text('Konsultasi Mentor'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.myMentors,
                                    ),
                                    child: const Text('Sesi Aktif'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog({
    required this.dialogTitle,
    required this.confirmLabel,
    required this.onSave,
    this.initialTitle = '',
    this.initialTag = 'Fitur',
    this.initialDeadline = '',
  });

  final String dialogTitle;
  final String confirmLabel;
  final String initialTitle;
  final String initialTag;
  final String initialDeadline;
  final Future<void> Function(String title, String tag, String deadline) onSave;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.initialTitle,
  );
  late final TextEditingController _deadlineController = TextEditingController(
    text: widget.initialDeadline,
  );
  late String _selectedTag = widget.initialTag;
  bool _isSaving = false;

  static const List<String> _tags = [
    'Tahap 1',
    'Tahap 2',
    'Tahap 3',
    'UI',
    'Fitur',
    'QA',
    'Backend',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.length < 2 || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        title,
        _selectedTag,
        _deadlineController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableTags = _tags.contains(_selectedTag)
        ? _tags
        : [..._tags, _selectedTag];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.dialogTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkSlate,
          fontSize: 17,
        ),
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  hintText: 'Contoh: Implementasi cetak struk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  labelText: 'Target Waktu (Opsional)',
                  hintText: 'Contoh: 3 Hari / 25 Nov',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kategori Tag',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: availableTags
                    .map(
                      (tag) => ChoiceChip(
                        label: Text(tag),
                        selected: _selectedTag == tag,
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          color: _selectedTag == tag
                              ? Colors.white
                              : AppColors.darkSlate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _selectedTag = tag),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryNavy),
          onPressed: _isSaving ? null : _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
