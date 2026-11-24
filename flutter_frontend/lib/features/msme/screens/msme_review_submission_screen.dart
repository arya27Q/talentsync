import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/widgets/user_avatar_modal.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';
import 'package:flutter_frontend/features/workspace/screens/workspace_kanban_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MsmeReviewSubmissionScreen extends StatefulWidget {
  const MsmeReviewSubmissionScreen({
    super.key,
    this.projectId,
    this.milestoneId,
    this.msmeApi,
  });

  final int? projectId;
  final int? milestoneId;
  final MsmeApi? msmeApi;

  @override
  State<MsmeReviewSubmissionScreen> createState() =>
      _MsmeReviewSubmissionScreenState();
}

class _MsmeReviewSubmissionScreenState
    extends State<MsmeReviewSubmissionScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;

  String _statusFilter = 'submitted';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  Map<String, int> _counts = const {
    'submitted': 0,
    'revision_requested': 0,
    'approved': 0,
  };
  List<Map<String, dynamic>> _items = const [];
  int _selectedIndex = 0;

  final Map<int, Set<int>> _checkedIndicesByMilestone = {};
  int _selectedRating = 5;
  final TextEditingController _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _activeItem {
    if (_items.isEmpty) return null;
    if (_selectedIndex < 0 || _selectedIndex >= _items.length) {
      return _items.first;
    }
    return _items[_selectedIndex];
  }

  Future<void> _loadSubmissions({String? nextStatus}) async {
    final targetStatus = nextStatus ?? _statusFilter;
    setState(() {
      _statusFilter = targetStatus;
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _msmeApi.getSubmissions(
        projectId: widget.projectId,
        status: targetStatus,
      );
      if (!mounted) return;

      final rawCounts = (data['counts'] as Map<String, dynamic>?) ?? const {};
      final rawItems = ((data['items'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      var nextIndex = 0;
      if (widget.milestoneId != null) {
        final matchIdx = rawItems.indexWhere(
          (item) => (item['milestone_id'] as num?)?.toInt() == widget.milestoneId,
        );
        if (matchIdx >= 0) nextIndex = matchIdx;
      }

      setState(() {
        _counts = {
          'submitted': (rawCounts['submitted'] as num?)?.toInt() ?? 0,
          'revision_requested':
              (rawCounts['revision_requested'] as num?)?.toInt() ?? 0,
          'approved': (rawCounts['approved'] as num?)?.toInt() ?? 0,
        };
        _items = rawItems;
        _selectedIndex = nextIndex;
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
          _error = 'Gagal memuat pengajuan hasil mahasiswa. Silakan coba lagi.';
          _isLoading = false;
        });
      }
    }
  }

  List<String> _checklistFor(Map<String, dynamic> item) {
    final raw = ((item['deliverables_checklist'] as List?) ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (raw.isNotEmpty) return raw;
    return const [
      'Hasil pengerjaan sesuai brief & spesifikasi proyek',
      'Tautan atau berkas deliverable dapat dibuka dengan baik',
      'Kualitas pengerjaan layak untuk tahap ini',
    ];
  }

  Set<int> _checkedSetFor(int milestoneId) {
    return _checkedIndicesByMilestone.putIfAbsent(milestoneId, () => <int>{});
  }

  Future<void> _openUrl(String rawUrl) async {
    final resolved = ApiClient.resolveMediaUrl(rawUrl) ?? rawUrl.trim();
    final uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme) {
      await AppStatusDialog.showError(
        context,
        title: 'Tautan Tidak Valid',
        message: 'Alamat tautan hasil tidak dapat dibuka secara langsung.',
      );
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Membuka Tautan',
          message: 'Salin tautan lalu buka di browser perangkat Anda.',
        );
      }
    } catch (_) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Membuka Tautan',
          message: 'Salin tautan lalu buka di browser perangkat Anda.',
        );
      }
    }
  }

  Future<void> _copyText(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin ke clipboard.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openRevisionSheet(Map<String, dynamic> item) async {
    final milestoneId = (item['milestone_id'] as num?)?.toInt();
    if (milestoneId == null || _isSubmitting) return;

    final student = (item['student'] as Map<String, dynamic>?) ?? const {};
    final studentName = (student['name'] as String?) ?? 'Mahasiswa';
    final milestoneTitle =
        (item['milestone_title'] as String?) ?? 'Tahap Proyek';
    final notesCtrl = TextEditingController();
    var recommendMentor = false;

    final payload = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          final bottomInset = MediaQuery.of(sheetCtx).viewInsets.bottom;
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderSlate,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Minta Revisi Pengerjaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim catatan perbaikan untuk $studentName pada $milestoneTitle.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Catatan revisi teknis',
                      hintText:
                          'Contoh: Mohon sesuaikan kontras tombol utama dan lengkapi file master.',
                      filled: true,
                      fillColor: AppColors.canvasWhite,
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
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      activeThumbColor: AppColors.primaryNavy,
                      title: const Text(
                        'Sarankan Konsultasi Mentor Pendamping',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      subtitle: const Text(
                        'Mahasiswa akan menerima tombol pintas konsultasi mentor bersama catatan revisi ini.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      value: recommendMentor,
                      onChanged: (v) =>
                          setSheetState(() => recommendMentor = v),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            side: const BorderSide(
                              color: AppColors.borderSlate,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: const Color(0xFFB91C1C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            final text = notesCtrl.text.trim();
                            if (text.length < 5) {
                              ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tuliskan catatan revisi minimal 5 karakter.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(sheetCtx, {
                              'revision_notes': text,
                              'recommend_mentor_consultation': recommendMentor,
                            });
                          },
                          child: const Text(
                            'Kirim Revisi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    notesCtrl.dispose();

    if (payload == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await _msmeApi.requestMilestoneRevision(
        milestoneId,
        revisionNotes: payload['revision_notes'] as String,
        recommendMentorConsultation:
            payload['recommend_mentor_consultation'] == true,
      );
      if (!mounted) return;
      await AppStatusDialog.showSuccess(
        context,
        title: 'Permintaan Revisi Terkirim',
        message:
            'Catatan perbaikan telah dikirim ke $studentName dan status tahap diperbarui menjadi Perlu Revisi.',
      );
      if (!mounted) return;
      await _loadSubmissions();
    } on ApiException catch (e) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Mengirim Revisi',
          message: e.message,
        );
      }
    } catch (_) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Mengirim Revisi',
          message: 'Terjadi gangguan koneksi saat mengirim catatan revisi.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmAndApprove(Map<String, dynamic> item) async {
    final milestoneId = (item['milestone_id'] as num?)?.toInt();
    if (milestoneId == null || _isSubmitting) return;

    final isFinal = item['is_final_stage'] == true;
    final rewardTc = (item['milestone_reward_tc'] as num?)?.toInt() ?? 0;
    final milestoneTitle =
        (item['milestone_title'] as String?) ?? 'Tahap Proyek';
    final student = (item['student'] as Map<String, dynamic>?) ?? const {};
    final studentName = (student['name'] as String?) ?? 'Mahasiswa';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isFinal
              ? 'Validasi Akhir & Transfer $rewardTc TC?'
              : 'Setujui Tahap & Transfer $rewardTc TC?',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.darkSlate,
          ),
        ),
        content: Text(
          isFinal
              ? 'Menyetujui $milestoneTitle akan mencairkan $rewardTc TC ke dompet $studentName, menandai proyek selesai, menyimpan ulasan bintang $_selectedRating, serta menerbitkan portofolio & sertifikat proyek.'
              : 'Menyetujui $milestoneTitle akan mencairkan $rewardTc TC ke dompet $studentName dan otomatis membuka tahap pengerjaan berikutnya.',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondarySlate,
            height: 1.45,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isFinal ? 'Ya, Selesaikan Proyek' : 'Ya, Transfer $rewardTc TC',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final response = await _msmeApi.approveMilestone(
        milestoneId,
        rating: isFinal ? _selectedRating : null,
        reviewText: isFinal ? _reviewCtrl.text.trim() : null,
      );
      if (!mounted) return;

      final message = (response['message'] as String?) ??
          'Tahap disetujui dan $rewardTc TC telah ditransfer ke $studentName.';
      _reviewCtrl.clear();
      _selectedRating = 5;

      await AppStatusDialog.showSuccess(
        context,
        title: isFinal
            ? 'Proyek Selesai & TimeCoin Cair!'
            : 'Tahap Disetujui & TimeCoin Cair!',
        message: message,
      );
      if (!mounted) return;
      await _loadSubmissions();
    } on ApiException catch (e) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Memvalidasi Hasil',
          message: e.message,
        );
      }
    } catch (_) {
      if (mounted) {
        await AppStatusDialog.showError(
          context,
          title: 'Gagal Memvalidasi Hasil',
          message: 'Terjadi gangguan jaringan saat merilis escrow TimeCoin.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openChat(Map<String, dynamic> item) {
    final pId = (item['project_id'] as num?)?.toInt();
    final student = (item['student'] as Map<String, dynamic>?) ?? const {};
    final studentName = (student['name'] as String?) ?? 'Mahasiswa';
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MsmeChatScreen(
          projectId: pId,
          studentName: studentName,
        ),
      ),
    );
  }

  void _openKanbanMonitor(Map<String, dynamic> item) {
    final pId = (item['project_id'] as num?)?.toInt();
    if (pId == null) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkspaceKanbanScreen(
          projectId: pId,
          readOnly: true,
        ),
      ),
    );
  }

  String _formatDateLabel(String? iso) {
    if (iso == null || iso.isEmpty) return 'Baru saja';
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) return iso;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final h = parsed.hour.toString().padLeft(2, '0');
    final m = parsed.minute.toString().padLeft(2, '0');
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final activeItem = _activeItem;

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                      ? _buildErrorState()
                      : activeItem == null
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadSubmissions,
                              color: AppColors.primaryNavy,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  32,
                                ),
                                children: [
                                  if (_items.length > 1) ...[
                                    _buildSubmissionSelector(),
                                    const SizedBox(height: 14),
                                  ],
                                  _buildStudentProjectCard(activeItem),
                                  const SizedBox(height: 14),
                                  _buildDeliverableCard(activeItem),
                                  const SizedBox(height: 14),
                                  _buildChecklistCard(activeItem),
                                  if (activeItem['is_final_stage'] == true &&
                                      activeItem['milestone_status'] ==
                                          'submitted') ...[
                                    const SizedBox(height: 14),
                                    _buildFinalRatingCard(),
                                  ],
                                  if (activeItem['milestone_status'] ==
                                      'approved') ...[
                                    const SizedBox(height: 14),
                                    _buildApprovedSummaryBanner(activeItem),
                                  ],
                                  const SizedBox(height: 18),
                                  _buildQuickCollabRow(activeItem),
                                  if (activeItem['milestone_status'] ==
                                      'submitted') ...[
                                    const SizedBox(height: 14),
                                    _buildDecisionActions(activeItem),
                                  ],
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final pendingTotal = _counts['submitted'] ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.maybePop(context),
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
                color: AppColors.darkSlate,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tinjau Pengajuan Hasil',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  pendingTotal > 0
                      ? '$pendingTotal tahap menunggu validasi Anda'
                      : 'Pantau dan validasi deliverable proyek UMKM',
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
            tooltip: 'Muat ulang',
            onPressed: _isLoading ? null : _loadSubmissions,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.darkSlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      ('submitted', 'Menunggu', _counts['submitted'] ?? 0),
      ('revision_requested', 'Revisi', _counts['revision_requested'] ?? 0),
      ('approved', 'Disetujui', _counts['approved'] ?? 0),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        children: filters.map((entry) {
          final key = entry.$1;
          final label = entry.$2;
          final count = entry.$3;
          final active = _statusFilter == key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isLoading ? null : () => _loadSubmissions(nextStatus: key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryNavy : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        active ? AppColors.primaryNavy : AppColors.borderSlate,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.white : AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color:
                              active ? Colors.white : AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final row = _items[idx];
          final active = idx == _selectedIndex;
          final step = (row['step_order'] as num?)?.toInt() ?? (idx + 1);
          final pTitle = (row['project_title'] as String?) ?? 'Proyek';
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _selectedIndex = idx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFEFF6FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppColors.primaryNavy : AppColors.borderSlate,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers_rounded,
                    size: 15,
                    color:
                        active ? AppColors.primaryNavy : AppColors.secondarySlate,
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      'Tahap $step · $pTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            active ? AppColors.primaryNavy : AppColors.darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentProjectCard(Map<String, dynamic> item) {
    final student = (item['student'] as Map<String, dynamic>?) ?? const {};
    final studentName = (student['name'] as String?) ?? 'Mahasiswa Pelaksana';
    final avatarUrl = student['avatar_url'] as String?;
    final university =
        (student['university'] as String?) ?? 'Universitas Negeri Surabaya';
    final projectTitle = (item['project_title'] as String?) ?? 'Proyek UMKM';
    final milestoneTitle =
        (item['milestone_title'] as String?) ?? 'Tahap Pengerjaan';
    final stepOrder = (item['step_order'] as num?)?.toInt() ?? 1;
    final totalStages = (item['total_stages'] as num?)?.toInt() ?? 3;
    final rewardTc = (item['milestone_reward_tc'] as num?)?.toInt() ?? 0;
    final isFinal = item['is_final_stage'] == true;
    final status = (item['milestone_status'] as String?) ?? 'submitted';

    final (statusLabel, statusBg, statusFg) = switch (status) {
      'approved' => (
        'Disetujui',
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      ),
      'revision_requested' => (
        'Perlu Revisi',
        const Color(0xFFFEF2F2),
        const Color(0xFFB91C1C),
      ),
      _ => (
        'Menunggu Validasi',
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatarHelper.buildAvatarWidget(
                avatarUrl: avatarUrl,
                initial: studentName,
                size: 48,
                borderRadius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      university,
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: AppColors.borderSlate),
          Text(
            projectTitle,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            milestoneTitle,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.secondarySlate,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(
                icon: Icons.flag_rounded,
                label: isFinal
                    ? 'Tahap Akhir ($stepOrder/$totalStages)'
                    : 'Tahap $stepOrder dari $totalStages',
                bg: const Color(0xFFEFF6FF),
                fg: AppColors.primaryNavy,
              ),
              _metaChip(
                icon: Icons.toll_rounded,
                label: 'Escrow $rewardTc TC',
                bg: const Color(0xFFFFFBEB),
                fg: const Color(0xFFB45309),
              ),
              _metaChip(
                icon: Icons.access_time_rounded,
                label: _formatDateLabel(item['submitted_at'] as String?),
                bg: const Color(0xFFF1F5F9),
                fg: AppColors.secondarySlate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverableCard(Map<String, dynamic> item) {
    final format = (item['submission_format'] as String?) ?? 'link';
    final url = (item['deliverable_url'] as String?)?.trim();
    final fileName = (item['file_name'] as String?)?.trim();
    final fileSize = (item['file_size_label'] as String?)?.trim();
    final notes = (item['submission_notes'] as String?)?.trim();
    final revisionNotes = (item['revision_notes'] as String?)?.trim();
    final recommendMentor = item['recommend_mentor_consultation'] == true;
    final attachments = ((item['attachment_links'] as List?) ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              const Icon(
                Icons.inventory_2_rounded,
                size: 20,
                color: AppColors.primaryNavy,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Berkas & Tautan Deliverable',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  format == 'file' ? 'Berkas' : 'Tautan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (url != null && url.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        format == 'file'
                            ? Icons.insert_drive_file_rounded
                            : Icons.link_rounded,
                        size: 18,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName != null && fileName.isNotEmpty
                              ? '$fileName${fileSize != null && fileSize.isNotEmpty ? ' ($fileSize)' : ''}'
                              : url,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openUrl(url),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            side: const BorderSide(
                              color: AppColors.primaryNavy,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: AppColors.primaryNavy,
                          ),
                          label: const Text(
                            'Buka Hasil',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _copyText(url, 'Tautan hasil'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          side: const BorderSide(color: AppColors.borderSlate),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: AppColors.darkSlate,
                        ),
                        label: const Text(
                          'Salin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else
            const Text(
              'Belum ada berkas atau tautan yang dilampirkan pada pengajuan ini.',
              style: TextStyle(fontSize: 12.5, color: AppColors.secondarySlate),
            ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Lampiran Tambahan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 6),
            ...attachments.map(
              (link) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => _openUrl(link),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_file_rounded,
                        size: 15,
                        color: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          link,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryNavy,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Catatan dari Mahasiswa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notes,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.45,
              ),
            ),
          ],
          if (revisionNotes != null && revisionNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 16,
                        color: Color(0xFFB91C1C),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Catatan Revisi Terakhir Anda',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    revisionNotes,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF7F1D1D),
                      height: 1.4,
                    ),
                  ),
                  if (recommendMentor) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Disertai saran konsultasi bersama Peer Mentor.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
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

  Widget _buildChecklistCard(Map<String, dynamic> item) {
    final milestoneId = (item['milestone_id'] as num?)?.toInt() ?? 0;
    final checklist = _checklistFor(item);
    final checked = _checkedSetFor(milestoneId);
    final isApproved = item['milestone_status'] == 'approved';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.fact_check_rounded,
                size: 20,
                color: AppColors.primaryNavy,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ceklis Pemeriksaan Kualitas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunakan daftar periksa ini untuk memastikan hasil sesuai kesepakatan.',
            style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 8),
          ...List.generate(checklist.length, (idx) {
            final isChecked = isApproved || checked.contains(idx);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: AppColors.primaryNavy,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                checklist[idx],
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              value: isChecked,
              onChanged: isApproved
                  ? null
                  : (v) {
                      setState(() {
                        if (v == true) {
                          checked.add(idx);
                        } else {
                          checked.remove(idx);
                        }
                      });
                    },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinalRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.accentAmberGold,
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tahap Akhir: Penilaian & Ulasan UMKM',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Menyetujui tahap ini menyelesaikan proyek serta otomatis menerbitkan portofolio & sertifikat untuk mahasiswa.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF78350F),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final filled = starValue <= _selectedRating;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () => setState(() => _selectedRating = starValue),
                icon: Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: filled
                      ? AppColors.accentAmberGold
                      : const Color(0xFFCBD5E1),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Tulis testimoni singkat untuk portofolio mahasiswa (opsional)...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFDE68A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFDE68A)),
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
        ],
      ),
    );
  }

  Widget _buildApprovedSummaryBanner(Map<String, dynamic> item) {
    final rewardTc = (item['milestone_reward_tc'] as num?)?.toInt() ?? 0;
    final review = item['existing_review'] as Map<String, dynamic>?;
    return Container(
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
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF15803D),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tahap Disetujui · +$rewardTc TC Telah Dicairkan',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),
              ),
            ],
          ),
          if (review != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.accentAmberGold,
                ),
                const SizedBox(width: 4),
                Text(
                  'Penilaian Anda: ${review['rating']}/5',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
            if ((review['review_text'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                review['review_text'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildQuickCollabRow(Map<String, dynamic> item) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openChat(item),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.borderSlate),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: AppColors.darkSlate,
            ),
            label: const Text(
              'Obrolan',
              style: TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openKanbanMonitor(item),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.borderSlate),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.view_kanban_rounded,
              size: 18,
              color: AppColors.primaryNavy,
            ),
            label: const Text(
              'Pantau Kanban',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionActions(Map<String, dynamic> item) {
    final rewardTc = (item['milestone_reward_tc'] as num?)?.toInt() ?? 0;
    final isFinal = item['is_final_stage'] == true;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
            onPressed: _isSubmitting ? null : () => _confirmAndApprove(item),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.task_alt_rounded, size: 20),
            label: Text(
              isFinal
                  ? 'Validasi Akhir & Transfer $rewardTc TC'
                  : 'Setujui Tahap & Transfer $rewardTc TC',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB91C1C),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              backgroundColor: const Color(0xFFFEF2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isSubmitting ? null : () => _openRevisionSheet(item),
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: const Text(
              'Minta Revisi & Catatan Perbaikan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final (title, subtitle) = switch (_statusFilter) {
      'revision_requested' => (
        'Tidak Ada Revisi Aktif',
        'Semua tahap proyek yang perlu revisi sudah diperbaiki atau belum ada permintaan revisi.',
      ),
      'approved' => (
        'Belum Ada Tahap Disetujui',
        'Riwayat tahap proyek yang sudah divalidasi dan dicairkan akan tampil di sini.',
      ),
      _ => (
        'Belum Ada Pengajuan Hasil',
        'Saat mahasiswa mengumpulkan deliverable pada tahap proyek berjalan, pengajuannya akan langsung muncul di sini untuk Anda validasi.',
      ),
    };

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      color: AppColors.primaryNavy,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.rate_review_rounded,
                    color: AppColors.primaryNavy,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Gagal memuat data pengajuan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadSubmissions,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
