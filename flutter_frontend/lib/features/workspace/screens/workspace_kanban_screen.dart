import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';

class WorkspaceKanbanScreen extends StatefulWidget {
  const WorkspaceKanbanScreen({
    super.key,
    this.projectId,
    this.workspaceApi,
    this.projectApi,
  });

  final int? projectId;
  final WorkspaceApi? workspaceApi;
  final ProjectApi? projectApi;

  @override
  State<WorkspaceKanbanScreen> createState() => _WorkspaceKanbanScreenState();
}

class _WorkspaceKanbanScreenState extends State<WorkspaceKanbanScreen> {
  late final WorkspaceApi _api = widget.workspaceApi ?? WorkspaceApi.instance;
  late final ProjectApi _projectApi = widget.projectApi ?? ProjectApi.instance;

  bool _isLoading = true;
  String? _error;
  int? _resolvedProjectId;
  Map<String, dynamic> _project = const {};
  Map<String, dynamic> _stats = const {};
  List<Map<String, dynamic>> _tasks = const [];

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
      setState(() {
        _resolvedProjectId = targetId;
        _project = (res['project'] as Map<String, dynamic>?) ?? const {};
        _stats = (res['stats'] as Map<String, dynamic>?) ?? const {};
        _tasks = ((res['tasks'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
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
    if (projectId == null) return;

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _AddTaskDialog(
        onSave: (title, tag) async {
          await _api.createTask(projectId, title: title, tag: tag);
        },
      ),
    );
    if (created == true && mounted) {
      await _load();
    }
  }

  Future<void> _moveTaskStatus(Map<String, dynamic> task) async {
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
              _statusOption(ctx, 'done', 'Done (Selesai)', currentStatus),
              const Divider(),
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
    );

    if (selected == null) return;
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

  Widget _buildColumn(String title, String statusKey, Color badgeColor) {
    final items = _tasks.where((t) => t['status'] == statusKey).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
              Text(
                '$title (${items.length})',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
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
                onTap: () => _moveTaskStatus(task),
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
                            Row(
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
                                const SizedBox(width: 8),
                                Text(
                                  (task['deadline_label'] as String?) ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                                const Text(
                                  'Workspace Kanban',
                                  style: TextStyle(
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
                            tooltip: 'Chat UMKM',
                            onPressed: _resolvedProjectId == null
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.workspaceChat,
                                    arguments: ProjectRouteArgs(
                                      projectId: _resolvedProjectId,
                                    ),
                                  ),
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

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

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ketuk kartu untuk ubah status',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                            ),
                            onPressed: _showAddTaskDialog,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Tambah tugas'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      _buildColumn('To-Do', 'todo', AppColors.secondarySlate),
                      _buildColumn(
                        'In Progress',
                        'in_progress',
                        AppColors.primaryNavy,
                      ),
                      _buildColumn('Done', 'done', const Color(0xFF16A34A)),

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
                                    child: const Text('Konsultasi Mentor'),
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

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog({required this.onSave});

  final Future<void> Function(String title, String tag) onSave;

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedTag = 'Fitur';
  bool _isSaving = false;

  static const List<String> _tags = ['UI', 'Fitur', 'QA', 'Backend'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.length < 2 || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(title, _selectedTag);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Tambah Tugas Kanban',
        style: TextStyle(
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
                  hintText: 'Contoh: Implementasi cetak struk',
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
                children: _tags
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
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
