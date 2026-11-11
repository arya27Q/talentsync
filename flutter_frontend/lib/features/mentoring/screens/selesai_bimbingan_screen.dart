import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';

class SelesaiBimbinganScreen extends StatefulWidget {
  const SelesaiBimbinganScreen({
    super.key,
    this.enrollmentId,
    this.mentoringApi,
    this.workspaceApi,
  });

  final int? enrollmentId;
  final StudentMentoringApi? mentoringApi;
  final WorkspaceApi? workspaceApi;

  @override
  State<SelesaiBimbinganScreen> createState() => _SelesaiBimbinganScreenState();
}

class _SelesaiBimbinganScreenState extends State<SelesaiBimbinganScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;
  late final WorkspaceApi _workspaceApi =
      widget.workspaceApi ?? WorkspaceApi.instance;

  final TextEditingController _reviewController = TextEditingController();
  final List<Map<String, dynamic>> _strengths = [
    {'label': 'Penjelasan sangat detail', 'selected': true},
    {'label': 'Feedback konstruktif', 'selected': true},
    {'label': 'Tepat waktu', 'selected': true},
    {'label': 'Action plan jelas', 'selected': false},
    {'label': 'Membantu pemula', 'selected': false},
  ];

  bool _argsParsed = false;
  int? _routeEnrollmentId;
  int? _resolvedEnrollmentId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  int _starRating = 5;
  Map<String, dynamic> _enrollment = const {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MentoringEnrollmentArgs) {
      _routeEnrollmentId = args.enrollmentId;
    }
    _load();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.enrollmentId ?? _routeEnrollmentId;
      if (targetId == null) {
        final mine = await _api.myEnrollments();
        if (mine.isEmpty) {
          throw const ApiException('Belum ada sesi bimbingan yang dapat dikonfirmasi.');
        }
        final pendingConfirm = mine.firstWhere(
          (e) => e['status'] == 'pending_confirmation',
          orElse: () => mine.first,
        );
        targetId = (pendingConfirm['id'] as num?)?.toInt();
      }
      if (targetId == null) {
        throw const ApiException('Data sesi bimbingan tidak ditemukan.');
      }

      final detail = await _api.enrollmentDetail(targetId);
      if (!mounted) return;
      setState(() {
        _resolvedEnrollmentId = targetId;
        _enrollment = detail;
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
          _error = 'Gagal memuat detail konfirmasi sesi.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmReleaseEscrow() async {
    final enrollmentId = _resolvedEnrollmentId;
    if (enrollmentId == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final selectedTags = _strengths
          .where((s) => s['selected'] == true)
          .map((s) => s['label'] as String)
          .toList();
      await _api.confirmCompletion(
        enrollmentId,
        rating: _starRating,
        reviewText: _reviewController.text.trim(),
        strengthTags: selectedTags,
      );
      if (!mounted) return;
      _showSuccessDialog(enrollmentId);
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal mengonfirmasi penyelesaian sesi.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(int enrollmentId) {
    final classData =
        (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (classData['mentor_name'] as String?) ?? 'Mentor';
    final paidTc = (_enrollment['paid_tc'] as num?)?.toInt() ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escrow Berhasil Dilepas!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$paidTc TC telah diteruskan ke $mentorName dan sertifikat kelulusan sesi telah terbit.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.mentoringResult,
                    arguments: MentoringEnrollmentArgs(
                      enrollmentId: enrollmentId,
                    ),
                  );
                },
                child: const Text(
                  'Lihat Lembar Evaluasi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDisputeModal() {
    final enrollmentId = _resolvedEnrollmentId;
    if (enrollmentId == null) return;
    final descController = TextEditingController();
    String category = 'quality';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laporkan Kendala Sesi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tim mediasi TalentSync akan meninjau laporan sebelum escrow dilepas.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori Kendala',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'quality',
                      child: Text('Kualitas Bimbingan'),
                    ),
                    DropdownMenuItem(
                      value: 'no_show',
                      child: Text('Mentor Tidak Hadir'),
                    ),
                    DropdownMenuItem(
                      value: 'escrow',
                      child: Text('Selisih Escrow TimeCoin'),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('Kendala Lainnya'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => category = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ceritakan kronologi kendala (minimal 10 karakter)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final desc = descController.text.trim();
                      if (desc.length < 10) {
                        _showSnack(
                          'Deskripsi kendala minimal 10 karakter.',
                          isError: true,
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await _workspaceApi.fileDispute(
                          referenceType: 'mentoring_enrollment',
                          referenceId: enrollmentId,
                          category: category,
                          description: desc,
                        );
                        _showSnack('Laporan kendala dikirim ke tim mediasi.');
                      } on ApiException catch (e) {
                        _showSnack(e.message, isError: true);
                      } catch (_) {
                        _showSnack('Gagal mengirim laporan.', isError: true);
                      }
                    },
                    child: const Text(
                      'Kirim Laporan Mediasi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(descController.dispose);
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classData =
        (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (classData['mentor_name'] as String?) ?? 'Mentor';
    final topic =
        (_enrollment['topic_focus'] as String?) ??
        (classData['topic'] as String?) ??
        'Sesi Mentoring';
    final paidTc = (_enrollment['paid_tc'] as num?)?.toInt() ?? 0;
    final avatarUrl = ApiClient.resolveMediaUrl(
      classData['mentor_avatar_url'] as String?,
    );
    final status = (_enrollment['status'] as String?) ?? 'pending_confirmation';
    final canConfirm = status == 'pending_confirmation';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      children: [
                        _buildSummaryCard(
                          mentorName: mentorName,
                          topic: topic,
                          paidTc: paidTc,
                          avatarUrl: avatarUrl,
                        ),
                        const SizedBox(height: 16),
                        _buildRatingCard(),
                        const SizedBox(height: 16),
                        _buildReviewCard(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: (!canConfirm || _isSubmitting)
                                ? null
                                : _confirmReleaseEscrow,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    canConfirm
                                        ? 'Konfirmasi Selesai & Lepas $paidTc TC'
                                        : 'Status Sesi: $status',
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _openDisputeModal,
                            icon: const Icon(
                              Icons.report_problem_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Laporkan Kendala Sesi',
                              style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildHeader() {
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
          const Expanded(
            child: Text(
              'Konfirmasi Selesai Bimbingan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String mentorName,
    required String topic,
    required int paidTc,
    required String? avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              color: AppColors.lightBlueSurface,
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      width: 52,
                      height: 52,
                      cacheWidth: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          mentorName.isNotEmpty
                              ? mentorName[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        mentorName.isNotEmpty
                            ? mentorName[0].toUpperCase()
                            : 'M',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentorName,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Escrow Tertahan: $paidTc TC (Rp${paidTc * 1000})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentAmberDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beri Penilaian Mentor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (idx) {
              final starValue = idx + 1;
              final active = starValue <= _starRating;
              return InkWell(
                onTap: () => setState(() => _starRating = starValue),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.star_rounded,
                    size: 34,
                    color: active
                        ? AppColors.accentAmberGold
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          const Text(
            'Kelebihan Mentor',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _strengths.map((item) {
              final selected = item['selected'] == true;
              return InkWell(
                onTap: () => setState(() => item['selected'] = !selected),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryNavy
                        : AppColors.canvasWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryNavy
                          : AppColors.borderSlate,
                    ),
                  ),
                  child: Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.darkSlate,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ulasan Singkat (Opsional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Bagikan manfaat yang kamu dapatkan dari sesi mentoring ini...',
              filled: true,
              fillColor: AppColors.canvasWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSlate),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSlate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.task_alt_rounded,
              size: 46,
              color: AppColors.secondarySlate,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),
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
                onPressed: _load,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
