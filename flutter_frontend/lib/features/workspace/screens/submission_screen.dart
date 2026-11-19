import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({
    super.key,
    this.projectId,
    this.workspaceApi,
    this.projectApi,
  });

  final int? projectId;
  final WorkspaceApi? workspaceApi;
  final ProjectApi? projectApi;

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  late final WorkspaceApi _api = widget.workspaceApi ?? WorkspaceApi.instance;
  late final ProjectApi _projectApi = widget.projectApi ?? ProjectApi.instance;

  int _selectedFormatIndex = 0; // 0: Tautan, 1: Berkas, 2: Catatan
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _pickedFileName;
  Uint8List? _pickedFileBytes;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  int? _resolvedProjectId;
  Map<String, dynamic> _project = const {};
  Map<String, dynamic> _summary = const {};
  List<Map<String, dynamic>> _milestones = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
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
          throw const ApiException('Belum ada proyek aktif untuk pengumpulan.');
        }
        targetId = ((active.first as Map<String, dynamic>)['id'] as num)
            .toInt();
      }
      final res = await _api.milestones(targetId);
      if (!mounted) return;
      setState(() {
        _resolvedProjectId = targetId;
        _project = (res['project'] as Map<String, dynamic>?) ?? const {};
        _summary = (res['summary'] as Map<String, dynamic>?) ?? const {};
        _milestones = ((res['milestones'] as List?) ?? const [])
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
          _error = 'Gagal memuat daftar milestone proyek.';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic>? get _targetMilestone {
    for (final m in _milestones) {
      final st = m['status'] as String?;
      if (st == 'open' || st == 'revision_requested') return m;
    }
    return null;
  }

  bool get _hasSubmittedMilestone =>
      _milestones.any((m) => m['status'] == 'submitted');

  bool get _allMilestonesApproved =>
      _milestones.isNotEmpty &&
      _milestones.every((m) => m['status'] == 'approved');

  Future<void> _openExternalUrl(String rawUrl) async {
    final resolved = ApiClient.resolveMediaUrl(rawUrl) ?? rawUrl.trim();
    final uri = Uri.tryParse(resolved);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan berkas.')),
      );
    }
  }

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Pilih Berkas Deliverable',
      type: FileType.custom,
      allowedExtensions: const ['zip', 'pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 10 * 1024 * 1024) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Berkas Terlalu Besar',
          message: 'Ukuran berkas deliverable maksimal 10 MB.',
        );
      }
      return;
    }
    setState(() {
      _pickedFileName = file.name;
      _pickedFileBytes = bytes;
    });
  }

  Future<void> _submitDeliverable() async {
    final target = _targetMilestone;
    if (target == null || _isSubmitting) {
      await AppStatusDialog.showWarning(
        context,
        title: 'Belum Ada Tahap Aktif',
        message: 'Tidak ada tahap aktif yang dapat dikirim saat ini.',
      );
      return;
    }
    final milestoneId = (target['id'] as num).toInt();

    final format = switch (_selectedFormatIndex) {
      1 => 'file',
      2 => 'note',
      _ => 'link',
    };
    if (format == 'file' && _pickedFileBytes == null) {
      await AppStatusDialog.showError(
        context,
        title: 'Berkas Belum Dipilih',
        message:
            'Pilih berkas deliverable (ZIP, PDF, atau gambar) terlebih dahulu.',
      );
      return;
    }
    if (format == 'link' && _urlController.text.trim().isEmpty) {
      await AppStatusDialog.showError(
        context,
        title: 'Tautan Masih Kosong',
        message: 'Masukkan tautan hasil pekerjaan (Google Drive, Figma, atau GitHub).',
      );
      return;
    }
    if (format == 'note' && _notesController.text.trim().isEmpty) {
      await AppStatusDialog.showError(
        context,
        title: 'Catatan Masih Kosong',
        message: 'Tuliskan ringkasan hasil pengerjaan Anda untuk mitra UMKM.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _api.submitDeliverable(
        milestoneId,
        submissionFormat: format,
        deliverableUrl: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        submissionNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        fileName: _pickedFileName,
        fileBytes: _pickedFileBytes,
      );
      if (!mounted) return;
      _urlController.clear();
      _notesController.clear();
      setState(() {
        _pickedFileName = null;
        _pickedFileBytes = null;
      });
      await _load();
      if (!mounted) return;

      await AppStatusDialog.show(
        context,
        type: AppStatusDialogType.success,
        title: 'Hasil Pengerjaan Terkirim',
        message:
            'Hasil tahap "${target['title'] ?? 'Milestone'}" sudah tercatat di sistem dan menunggu tinjauan mitra UMKM.',
        primaryButtonText: 'Tetap di Sini',
        secondaryButtonText: 'Buka Kanban',
        onSecondaryPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.workspaceKanban,
            arguments: ProjectRouteArgs(projectId: _resolvedProjectId),
          );
        },
        barrierDismissible: false,
      );
    } on ApiException catch (e) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Mengirim Hasil',
          message: e.message,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showAddStageDialog() async {
    final projectId = _resolvedProjectId;
    if (projectId == null) return;
    final nameCtrl = TextEditingController();
    final tcCtrl = TextEditingController(text: '15');

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tambah Tahap Baru',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Tahap',
                hintText: 'Contoh: Integrasi Notifikasi',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tcCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Alokasi Imbalan (TC)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
            ),
            onPressed: () async {
              final tc = int.tryParse(tcCtrl.text.trim()) ?? 0;
              if (nameCtrl.text.trim().length < 3 || tc < 1) return;
              try {
                await _api.addMilestone(
                  projectId,
                  title: nameCtrl.text.trim(),
                  rewardTc: tc,
                );
                if (ctx.mounted) Navigator.pop(ctx, true);
              } on ApiException catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    tcCtrl.dispose();
    if (added == true) _load();
  }

  Future<void> _showDisputeDialog() async {
    final projectId = _resolvedProjectId;
    if (projectId == null) return;
    final descCtrl = TextEditingController();

    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ajukan Resolusi Escrow',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: descCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Jelaskan kendala review atau sengketa milestone...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
            ),
            onPressed: () async {
              if (descCtrl.text.trim().length < 10) return;
              await _api.fileDispute(
                referenceType: 'project',
                referenceId: projectId,
                category: 'escrow_resolution',
                description: descCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Kirim Laporan'),
          ),
        ],
      ),
    );
    descCtrl.dispose();
    if (sent == true && mounted) {
      await AppStatusDialog.showSuccess(
        context,
        title: 'Laporan Terkirim',
        message: 'Laporan resolusi escrow telah dikirim ke tim TalentSync.',
        buttonText: 'Mengerti',
      );
    }
  }

  Widget _buildMilestoneCard(Map<String, dynamic> m) {
    final st = (m['status'] as String?) ?? 'locked';
    final latest = m['latest_deliverable'] as Map<String, dynamic>?;
    final deliverableUrl = latest?['deliverable_url'] as String?;
    final fileName = latest?['file_name'] as String?;
    final fileSize = latest?['file_size_label'] as String?;
    final notes = latest?['submission_notes'] as String?;
    final revisionNotes = latest?['revision_notes'] as String?;
    final recommendMentor = latest?['recommend_mentor_consultation'] == true;

    final badge = switch (st) {
      'approved' => (
        'Selesai',
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      ),
      'submitted' => (
        'Menunggu Review',
        const Color(0xFFDBEAFE),
        AppColors.primaryNavy,
      ),
      'open' => (
        'Siap Diisi',
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
      ),
      'revision_requested' => (
        'Perlu Revisi',
        const Color(0xFFFEE2E2),
        const Color(0xFFB91C1C),
      ),
      _ => ('Terkunci', const Color(0xFFF1F5F9), AppColors.secondarySlate),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: st == 'revision_requested'
              ? const Color(0xFFFECACA)
              : AppColors.borderSlate,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.lightBlueSurface,
                child: Text(
                  '${m['step_order']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (m['title'] as String?) ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    Text(
                      '${m['reward_tc'] ?? 0} TC',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badge.$2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.$1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badge.$3,
                  ),
                ),
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (deliverableUrl != null && deliverableUrl.isNotEmpty)
                    InkWell(
                      onTap: () => _openExternalUrl(deliverableUrl),
                      child: Row(
                        children: [
                          Icon(
                            fileName != null
                                ? Icons.attach_file_rounded
                                : Icons.link_rounded,
                            size: 15,
                            color: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              fileName != null
                                  ? '$fileName${fileSize != null ? ' ($fileSize)' : ''}'
                                  : deliverableUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (notes != null && notes.trim().isNotEmpty) ...[
                    if (deliverableUrl != null && deliverableUrl.isNotEmpty)
                      const SizedBox(height: 6),
                    Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (revisionNotes != null && revisionNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.rate_review_rounded,
                        size: 14,
                        color: Color(0xFFB91C1C),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Catatan Revisi Mitra UMKM',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    revisionNotes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F1D1D),
                      height: 1.35,
                    ),
                  ),
                  if (recommendMentor) ...[
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.findMentors),
                      child: const Text(
                        'Mitra menyarankan konsultasi Peer Mentor ->',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msme = (_project['msme'] as Map<String, dynamic>?) ?? const {};
    final releasedTc = (_summary['released_tc'] as num?)?.toInt() ?? 0;
    final escrowTc = (_summary['escrow_tc'] as num?)?.toInt() ?? 0;
    final pct = (_summary['progress_percent'] as num?)?.toInt() ?? 0;
    final target = _targetMilestone;

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
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
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
                                border: Border.all(
                                  color: AppColors.borderSlate,
                                ),
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
                                  'Status & Pengumpulan Hasil',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                Text(
                                  '${msme['business_name'] ?? 'UMKM'} · ${_project['title'] ?? ''}',
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
                            tooltip: 'Kanban Workspace',
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.workspaceKanban,
                              arguments: ProjectRouteArgs(
                                projectId: _resolvedProjectId,
                              ),
                            ),
                            icon: const Icon(
                              Icons.view_kanban_rounded,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Escrow Progress Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progres Milestone: $pct% ($releasedTc TC cair · $escrowTc TC di escrow)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (pct / 100).clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accentAmberGold,
                                ),
                                minHeight: 7,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Milestones List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tahapan Pengerjaan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showAddStageDialog,
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Tambah tahap'),
                          ),
                        ],
                      ),
                      ..._milestones.map(_buildMilestoneCard),

                      if (target != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Kumpulkan Hasil: ${target['title']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _formatTab('Tautan', 0),
                            const SizedBox(width: 8),
                            _formatTab('Berkas', 1),
                            const SizedBox(width: 8),
                            _formatTab('Catatan', 2),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedFormatIndex == 0)
                          TextField(
                            controller: _urlController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'https://github.com/... atau Google Drive / Figma',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        if (_selectedFormatIndex == 1)
                          InkWell(
                            onTap: _pickFile,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.borderSlate,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.upload_file_rounded,
                                    color: AppColors.primaryNavy,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _pickedFileName ?? 'Pilih berkas ZIP/PDF/Gambar (Maks 10 MB)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Catatan pengerjaan untuk mitra UMKM...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : _submitDeliverable,
                            child: Text(
                              _isSubmitting
                                  ? 'Mengirim Hasil...'
                                  : 'Simpan & Ajukan Hasil Pengerjaan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ] else if (_hasSubmittedMilestone) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_top_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Menunggu Tinjauan Mitra UMKM',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Hasil tahap Anda telah diterima sistem. Mitra UMKM akan memeriksa berkas dan mencairkan TimeCoin escrow atau memberikan catatan revisi.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.secondarySlate,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryNavy,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.workspaceChat,
                                    arguments: ProjectRouteArgs(
                                      projectId: _resolvedProjectId,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Konfirmasi via Obrolan UMKM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_allMilestonesApproved) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.task_alt_rounded,
                                    color: Color(0xFF15803D),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Seluruh Tahap Disetujui',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF14532D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF15803D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.projectCompleted,
                                    arguments: ProjectRouteArgs(
                                      projectId: _resolvedProjectId,
                                    ),
                                  ),
                                  child: const Text(
                                    'Lihat Ringkasan & Ulasan Proyek',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),
                      // Pre-submission Mentor Consultation Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Konsultasi Sebelum Mengumpulkan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Minta review mutu ke Peer Mentor agar hasil kerja langsung disetujui UMKM.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.findMentors,
                                    ),
                                    child: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('Review Mentor'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.workspaceChat,
                                      arguments: ProjectRouteArgs(
                                        projectId: _resolvedProjectId,
                                      ),
                                    ),
                                    child: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('Obrolan UMKM'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: _showDisputeDialog,
                          child: const Text(
                            'Butuh bantuan / ajukan resolusi escrow',
                            style: TextStyle(color: AppColors.secondarySlate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _formatTab(String label, int idx) {
    final selected = _selectedFormatIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFormatIndex = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryNavy : AppColors.borderSlate,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppColors.darkSlate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
