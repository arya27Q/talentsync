import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:flutter_frontend/features/portfolio/data/portfolio_api.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:url_launcher/url_launcher.dart';

class RuangBelajarScreen extends StatefulWidget {
  const RuangBelajarScreen({
    super.key,
    this.initialTab = 0,
    this.enrollmentId,
    this.mentoringApi,
    this.projectApi,
    this.portfolioApi,
  });

  final int initialTab;
  final int? enrollmentId;
  final StudentMentoringApi? mentoringApi;
  final ProjectApi? projectApi;
  final PortfolioApi? portfolioApi;

  @override
  State<RuangBelajarScreen> createState() => _RuangBelajarScreenState();
}

class _RuangBelajarScreenState extends State<RuangBelajarScreen> {
  late final StudentMentoringApi _mentoringApi =
      widget.mentoringApi ?? StudentMentoringApi.instance;
  late final ProjectApi _projectApi = widget.projectApi ?? ProjectApi.instance;
  late final PortfolioApi _portfolioApi =
      widget.portfolioApi ?? PortfolioApi.instance;

  static const List<String> _tabs = ['Materi', 'Tugas', 'Proyek', 'Hasil'];

  int _selectedTab = 0;
  int _expandedTaskIndex = 0;
  int? _routeEnrollmentId;
  bool _argsParsed = false;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  int? _resolvedEnrollmentId;
  Map<String, dynamic> _enrollment = const {};
  List<Map<String, dynamic>> _materials = const [];
  List<Map<String, dynamic>> _assignments = const [];
  List<Map<String, dynamic>> _activeProjects = const [];
  List<Map<String, dynamic>> _completedProjects = const [];
  List<Map<String, dynamic>> _certificates = const [];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, _tabs.length - 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MentoringEnrollmentArgs) {
      _routeEnrollmentId = args.enrollmentId;
      _selectedTab = args.initialTab.clamp(0, _tabs.length - 1);
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.enrollmentId ?? _routeEnrollmentId;
      if (targetId == null) {
        final enrollments = await _mentoringApi.myEnrollments();
        if (enrollments.isEmpty) {
          throw const ApiException(
            'Belum ada sesi mentoring aktif. Pesan sesi terlebih dahulu.',
          );
        }
        targetId = (enrollments.first['id'] as num?)?.toInt();
      }
      if (targetId == null) {
        throw const ApiException('Data sesi mentoring tidak ditemukan.');
      }

      final detail = await _mentoringApi.enrollmentDetail(targetId);
      final results = await Future.wait<dynamic>([
        _mentoringApi.materials(targetId),
        _mentoringApi.assignments(targetId),
        _safeProjects(),
        _safeCertificates(),
      ]);

      final projectsData = results[2] as Map<String, dynamic>;
      final active = (projectsData['active_projects'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final completed =
          (projectsData['completed_projects'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList();

      if (!mounted) return;
      setState(() {
        _resolvedEnrollmentId = targetId;
        _enrollment = detail;
        _materials = results[0] as List<Map<String, dynamic>>;
        _assignments = results[1] as List<Map<String, dynamic>>;
        _activeProjects = active;
        _completedProjects = completed;
        _certificates = results[3] as List<Map<String, dynamic>>;
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
          _error = 'Gagal memuat Ruang Belajar.';
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _safeProjects() async {
    try {
      return await _projectApi.myProjects();
    } catch (_) {
      return const {'active_projects': [], 'completed_projects': []};
    }
  }

  Future<List<Map<String, dynamic>>> _safeCertificates() async {
    try {
      final res = await _portfolioApi.certificates();
      return (res['certificates'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _openResource(String? url) async {
    if (url == null || url.trim().isEmpty) {
      _showSnack('Tautan materi belum tersedia.');
      return;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      _showSnack('Format tautan tidak valid.');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack('Tidak dapat membuka tautan materi.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSubmitTaskModal(Map<String, dynamic> assignment) {
    final assignmentId = (assignment['id'] as num?)?.toInt();
    if (assignmentId == null) return;

    final urlController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSlate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Kirim Tugas Mentoring',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (assignment['title'] as String?) ?? 'Tugas',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tautan PR / Figma / Dokumen',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://github.com/username/repo/pull/1',
                    filled: true,
                    fillColor: AppColors.canvasWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Catatan Pengumpulan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Jelaskan ringkasan implementasi atau bagian yang butuh review...',
                    filled: true,
                    fillColor: AppColors.canvasWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderSlate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final url = urlController.text.trim();
                            final notes = notesController.text.trim();
                            if (url.isEmpty && notes.isEmpty) {
                              _showSnack(
                                'Isi tautan hasil atau catatan pengumpulan.',
                              );
                              return;
                            }
                            Navigator.pop(ctx);
                            await _submitAssignment(assignmentId, url, notes);
                          },
                    child: const Text(
                      'Kirim Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      urlController.dispose();
      notesController.dispose();
    });
  }

  Future<void> _submitAssignment(
    int assignmentId,
    String url,
    String notes,
  ) async {
    setState(() => _isSubmitting = true);
    try {
      await _mentoringApi.submitAssignment(
        assignmentId,
        deliverableUrl: url,
        submissionNotes: notes,
      );
      if (!mounted) return;
      _showSnack('Tugas berhasil dikirim ke mentor.');
      await _load();
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack('Gagal mengirim tugas.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classData =
        (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (classData['mentor_name'] as String?) ?? 'Mentor';
    final topic =
        (_enrollment['topic_focus'] as String?) ??
        (classData['topic'] as String?) ??
        'Ruang Belajar Kolaboratif';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(mentorName, topic),
            _buildTabSelector(),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        children: [
                          if (_selectedTab == 0) _buildMaterialsTab(),
                          if (_selectedTab == 1) _buildTasksTab(),
                          if (_selectedTab == 2) _buildProjectsTab(),
                          if (_selectedTab == 3) _buildResultsTab(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String mentorName, String topic) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.darkSlate,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ruang Belajar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  '$mentorName | $topic',
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
          if (_resolvedEnrollmentId != null)
            InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.mentorChat,
                arguments: MentoringEnrollmentArgs(
                  enrollmentId: _resolvedEnrollmentId,
                ),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: List.generate(_tabs.length, (idx) {
          final selected = _selectedTab == idx;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = idx),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _tabs[idx],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppColors.secondarySlate,
                  ),
                ),
              ),
            ),
          );
        }),
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
            const Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: AppColors.secondarySlate,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _load,
                  child: const Text('Coba Lagi'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    minimumSize: const Size(120, 44),
                    side: const BorderSide(color: AppColors.primaryNavy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.findMentors),
                  child: const Text('Cari Mentor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsTab() {
    if (_materials.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.folder_open_rounded,
        title: 'Belum Ada Materi',
        subtitle:
            'Mentor akan mengunggah modul, rekaman, atau referensi studi kasus di sini.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _materials.map((m) {
        final kind = (m['kind'] as String?) ?? 'link';
        final icon = kind == 'pdf'
            ? Icons.picture_as_pdf_rounded
            : kind == 'video'
            ? Icons.play_circle_filled_rounded
            : Icons.link_rounded;
        final isNew = m['is_new'] == true;
        final metaLabel = (m['meta_label'] as String?) ?? kind.toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primaryNavy, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (m['title'] as String?) ?? 'Materi Bimbingan',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.canvasWhite,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                metaLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Baru',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentAmberDeep,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (((m['description'] as String?) ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  m['description'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondarySlate,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      _openResource(m['resource_url'] as String?),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(
                    'Buka Materi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTasksTab() {
    if (_assignments.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.assignment_outlined,
        title: 'Belum Ada Tugas Latihan',
        subtitle:
            'Tugas studi kasus atau latihan dari mentor akan muncul pada tab ini.',
      );
    }

    return Column(
      children: List.generate(_assignments.length, (idx) {
        final item = _assignments[idx];
        final submissions = (item['submissions'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final latestSub = submissions.isNotEmpty ? submissions.first : null;
        final subStatus = (latestSub?['status'] as String?) ?? 'pending';
        final canSubmit =
            latestSub == null || subStatus == 'revision_requested';
        final isExpanded = _expandedTaskIndex == idx;

        final statusMeta = _submissionBadge(subStatus, latestSub?['score']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(
                  () => _expandedTaskIndex = isExpanded ? -1 : idx,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusMeta.bg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusMeta.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusMeta.fg,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (item['title'] as String?) ?? 'Tugas',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondarySlate,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: AppColors.borderSlate, height: 1),
                      const SizedBox(height: 12),
                      Text(
                        (item['description'] as String?) ??
                            'Kerjakan tugas sesuai arahan mentor dan unggah tautan hasil.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondarySlate,
                          height: 1.45,
                        ),
                      ),
                      if (latestSub != null &&
                          ((latestSub['feedback'] as String?) ?? '')
                              .isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlueSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Catatan Mentor: ${latestSub['feedback']}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (canSubmit)
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : () => _showSubmitTaskModal(item),
                            icon: const Icon(
                              Icons.upload_file_rounded,
                              size: 18,
                            ),
                            label: Text(
                              subStatus == 'revision_requested'
                                  ? 'Kirim Revisi Tugas'
                                  : 'Kirim Tugas',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProjectsTab() {
    final all = [..._activeProjects, ..._completedProjects];
    if (all.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.work_outline_rounded,
        title: 'Belum Ada Proyek Terkait',
        subtitle:
            'Proyek UMKM yang sedang atau sudah kamu kerjakan akan tampil di sini.',
        actionLabel: 'Eksplorasi Proyek UMKM',
        onAction: () => Navigator.pushNamed(context, AppRoutes.exploreProjects),
      );
    }

    return Column(
      children: all.map((p) {
        final projectId = (p['id'] as num?)?.toInt();
        final status = (p['status'] as String?) ?? 'in_progress';
        final progress = (p['progress_percent'] as num?)?.toInt() ?? 100;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (p['title'] as String?) ?? 'Proyek UMKM',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'completed'
                          ? AppColors.lightGreenSurface
                          : AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status == 'completed' ? 'Selesai' : '$progress%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: status == 'completed'
                            ? AppColors.successGreen
                            : AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                (p['msme_name'] as String?) ?? 'Mitra UMKM',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 12),
              if (projectId != null)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.workspaceKanban,
                      arguments: ProjectRouteArgs(projectId: projectId),
                    ),
                    icon: const Icon(Icons.view_kanban_rounded, size: 18),
                    label: const Text(
                      'Buka Workspace Proyek',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultsTab() {
    final score = (_enrollment['assessment_score'] as num?)?.toInt();
    final feedback = _enrollment['mentor_feedback'] as String?;
    final hasEndorsement = _enrollment['has_endorsement'] == true;
    final status = (_enrollment['status'] as String?) ?? 'accepted';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evaluasi Sesi Ini',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          score != null
                              ? 'Skor Penilaian: $score / 100'
                              : 'Menunggu evaluasi mentor',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasEndorsement)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.accentAmberDeep,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Endorse Mentor',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentAmberDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (feedback != null && feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkSlate,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _resolvedEnrollmentId == null
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          status == 'pending_confirmation'
                              ? AppRoutes.selesaiBimbingan
                              : AppRoutes.mentoringResult,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: _resolvedEnrollmentId,
                          ),
                        ),
                  icon: const Icon(Icons.fact_check_rounded, size: 18),
                  label: Text(
                    status == 'pending_confirmation'
                        ? 'Konfirmasi Selesai & Lepas Escrow'
                        : 'Lihat Lembar Evaluasi',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sertifikat & Pencapaian',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 10),
        if (_certificates.isEmpty)
          _buildEmptyCard(
            icon: Icons.workspace_premium_rounded,
            title: 'Belum Ada Sertifikat',
            subtitle:
                'Sertifikat otomatis terbit saat sesi mentoring atau proyek selesai.',
          )
        else
          ..._certificates.map(
            (cert) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.accentAmberDeep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (cert['title'] as String?) ?? 'Sertifikat TalentSync',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${cert['issuer_name'] ?? 'TalentSync'} | ${cert['certificate_code'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.secondarySlate),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static ({String label, Color fg, Color bg}) _submissionBadge(
    String status,
    dynamic score,
  ) {
    switch (status) {
      case 'reviewed':
        return (
          label: score != null ? 'Dinilai ($score/100)' : 'Sudah Dinilai',
          fg: const Color(0xFF15803D),
          bg: const Color(0xFFDCFCE7),
        );
      case 'revision_requested':
        return (
          label: 'Perlu Revisi',
          fg: const Color(0xFFB45309),
          bg: const Color(0xFFFEF3C7),
        );
      case 'submitted':
        return (
          label: 'Menunggu Review Mentor',
          fg: AppColors.primaryNavy,
          bg: AppColors.lightBlueSurface,
        );
      default:
        return (
          label: 'Belum Dikirim',
          fg: AppColors.secondarySlate,
          bg: const Color(0xFFF1F5F9),
        );
    }
  }
}
