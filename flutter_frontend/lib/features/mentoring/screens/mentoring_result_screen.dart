import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';

class MentoringResultScreen extends StatefulWidget {
  const MentoringResultScreen({
    super.key,
    this.enrollmentId,
    this.mentoringApi,
  });

  final int? enrollmentId;
  final StudentMentoringApi? mentoringApi;

  @override
  State<MentoringResultScreen> createState() => _MentoringResultScreenState();
}

class _MentoringResultScreenState extends State<MentoringResultScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;

  bool _argsParsed = false;
  int? _routeEnrollmentId;
  int? _resolvedEnrollmentId;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _enrollment = const {};
  List<Map<String, dynamic>> _actionItems = const [];
  final Set<int> _expandedIds = {};

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
          throw const ApiException('Belum ada evaluasi bimbingan tersedia.');
        }
        final prioritized = mine.firstWhere(
          (e) =>
              e['status'] == 'pending_confirmation' ||
              e['status'] == 'completed',
          orElse: () => mine.first,
        );
        targetId = (prioritized['id'] as num?)?.toInt();
      }
      if (targetId == null) {
        throw const ApiException('Evaluasi sesi tidak ditemukan.');
      }
      final detail = await _api.enrollmentDetail(targetId);
      final items = (detail['action_items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;
      setState(() {
        _resolvedEnrollmentId = targetId;
        _enrollment = detail;
        _actionItems = items;
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
          _error = 'Gagal memuat hasil evaluasi bimbingan.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleActionItem(int idx) async {
    final enrollmentId = _resolvedEnrollmentId;
    if (enrollmentId == null) return;
    final item = _actionItems[idx];
    final itemId = (item['id'] as num?)?.toInt();
    if (itemId == null) return;

    final previous = item['is_completed'] == true;
    setState(() {
      _actionItems[idx]['is_completed'] = !previous;
    });
    try {
      final updated = await _api.toggleActionItem(enrollmentId, itemId);
      if (!mounted) return;
      setState(() {
        _actionItems[idx]['is_completed'] = updated['is_completed'] == true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _actionItems[idx]['is_completed'] = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _actionItems[idx]['is_completed'] = previous;
      });
    }
  }

  List<({String label, int score})> _parseRubricScores() {
    final raw = _enrollment['rubric_scores'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => (
              label: (e['label'] ?? e['aspect'] ?? 'Aspek').toString(),
              score: (e['score'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
    }
    if (raw is Map) {
      return raw.entries
          .map(
            (e) => (
              label: e.key.toString(),
              score: (e.value as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final classData =
        (_enrollment['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (classData['mentor_name'] as String?) ?? 'Mentor';
    final topic =
        (_enrollment['topic_focus'] as String?) ??
        (classData['topic'] as String?) ??
        'Hasil Bimbingan';
    final status = (_enrollment['status'] as String?) ?? 'accepted';
    final score = (_enrollment['assessment_score'] as num?)?.toInt();
    final paidTc = (_enrollment['paid_tc'] as num?)?.toInt() ?? 0;
    final hasEndorsement = _enrollment['has_endorsement'] == true;
    final rubric = _parseRubricScores();

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
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                        children: [
                          _buildScoreCard(
                            mentorName: mentorName,
                            topic: topic,
                            score: score,
                            status: status,
                            hasEndorsement: hasEndorsement,
                            endorsementNotes:
                                _enrollment['endorsement_notes'] as String?,
                          ),
                          if (rubric.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildRubricSection(rubric),
                          ],
                          const SizedBox(height: 16),
                          _buildFeedbackCard(
                            (_enrollment['mentor_feedback'] as String?) ??
                                'Mentor belum menambahkan ringkasan evaluasi tertulis.',
                          ),
                          const SizedBox(height: 16),
                          _buildActionItemsSection(),
                          const SizedBox(height: 20),
                          _buildBottomAction(status, paidTc),
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
              'Lembar Evaluasi Mentoring',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String mentorName,
    required String topic,
    required int? score,
    required String status,
    required bool hasEndorsement,
    String? endorsementNotes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(22),
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
                    Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mentor: $mentorName',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFDBEAFE),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      score != null ? '$score' : '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentAmberGold,
                      ),
                    ),
                    const Text(
                      'Skor',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasEndorsement) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.accentAmberGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Badge Rekomendasi Mentor Tersemat',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (endorsementNotes != null &&
                            endorsementNotes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            endorsementNotes,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDBEAFE),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            status == 'completed'
                ? 'Status: Selesai & Escrow Tervalidasi'
                : status == 'pending_confirmation'
                ? 'Status: Menunggu Konfirmasi Mahasiswa'
                : 'Status: Evaluasi Aktif',
            style: const TextStyle(fontSize: 12, color: Color(0xFFDBEAFE)),
          ),
        ],
      ),
    );
  }

  Widget _buildRubricSection(List<({String label, int score})> rubric) {
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
            'Rincian Rubrik Penilaian',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 12),
          ...rubric.map((entry) {
            final ratio = (entry.score / 100).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.score}/100',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String feedback) {
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
          const Row(
            children: [
              Icon(
                Icons.rate_review_rounded,
                color: AppColors.primaryNavy,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Catatan Evaluasi Mentor',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.secondarySlate,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Tindak Lanjut',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              Text(
                '${_actionItems.where((e) => e['is_completed'] == true).length}/${_actionItems.length} selesai',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_actionItems.isEmpty)
            const Text(
              'Belum ada action items tambahan dari mentor.',
              style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
            )
          else
            ...List.generate(_actionItems.length, (idx) {
              final item = _actionItems[idx];
              final itemId = (item['id'] as num?)?.toInt() ?? idx;
              final done = item['is_completed'] == true;
              final expanded = _expandedIds.contains(itemId);
              final detail = (item['detail'] as String?) ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                        InkWell(
                          onTap: () => _toggleActionItem(idx),
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              done
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: done
                                  ? AppColors.successGreen
                                  : AppColors.secondarySlate,
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              if (expanded) {
                                _expandedIds.remove(itemId);
                              } else {
                                _expandedIds.add(itemId);
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (item['title'] as String?) ?? 'Tindak lanjut',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      decoration: done
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: done
                                          ? AppColors.secondarySlate
                                          : AppColors.darkSlate,
                                    ),
                                  ),
                                  if (((item['tag'] as String?) ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item['tag'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (expanded && detail.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 44, right: 8),
                        child: Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondarySlate,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBottomAction(String status, int paidTc) {
    if (status == 'pending_confirmation' && _resolvedEnrollmentId != null) {
      return SizedBox(
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
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.selesaiBimbingan,
            arguments: MentoringEnrollmentArgs(
              enrollmentId: _resolvedEnrollmentId,
            ),
          ),
          child: Text(
            'Konfirmasi Selesai & Lepas $paidTc TC',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );
    }

    if (status == 'completed') {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightGreenSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.successGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Escrow $paidTc TC sudah diteruskan ke mentor dan sertifikat tersedia.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              onPressed: () => Navigator.pushNamed(context, AppRoutes.portfolio),
              child: const Text(
                'Lihat Portofolio & Sertifikat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
          side: const BorderSide(color: AppColors.primaryNavy),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.ruangBelajar,
          arguments: MentoringEnrollmentArgs(
            enrollmentId: _resolvedEnrollmentId,
          ),
        ),
        child: const Text(
          'Buka Ruang Belajar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              Icons.assessment_outlined,
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
