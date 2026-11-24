import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorRecommendationArgs {
  const MentorRecommendationArgs({this.initialStudent, this.onSelectTab});
  final MentorStudent? initialStudent;
  final ValueChanged<int>? onSelectTab;
}

class MentorRecommendationScreen extends StatefulWidget {
  const MentorRecommendationScreen({
    super.key,
    this.initialStudent,
    this.onSelectTab,
    this.mentorApi,
  });

  final MentorStudent? initialStudent;
  final ValueChanged<int>? onSelectTab;
  final MentorApi? mentorApi;

  @override
  State<MentorRecommendationScreen> createState() =>
      _MentorRecommendationScreenState();
}

class _MentorRecommendationScreenState
    extends State<MentorRecommendationScreen> {
  late final MentorApi _mentorApi = widget.mentorApi ?? MentorApi.instance;
  final TextEditingController _notesCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  List<Map<String, dynamic>> _enrollments = const [];
  int? _selectedEnrollmentId;

  static const List<(String label, String text)> _noteTemplates = [
    (
      'Siap Proyek UMKM',
      'Murid telah menyelesaikan sesi bimbingan dengan disiplin, menguasai alur teknis dengan baik, dan sangat direkomendasikan untuk mengerjakan proyek mitra UMKM.',
    ),
    (
      'Komunikasi & Teknis Baik',
      'Menunjukkan pemahaman struktur kode, kualitas desain, dan komunikasi kolaborasi yang sangat baik selama bimbingan. Layak mendapatkan Badge Rekomendasi Kerja.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = _noteTemplates.first.$2;
    _loadEnrollments();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rows = await _mentorApi.enrollments();
      if (!mounted) return;
      final eligibleRows = rows
          .where((e) {
            final st = (e['status'] as String?) ?? '';
            return st == 'attended' ||
                st == 'pending_confirmation' ||
                st == 'completed' ||
                st == 'accepted';
          })
          .toList(growable: false);

      int? preselected;
      final initialId = widget.initialStudent?.enrollmentId;
      if (initialId != null &&
          eligibleRows.any(
            (e) => (e['id'] as num?)?.toInt() == initialId,
          )) {
        preselected = initialId;
      } else if (eligibleRows.isNotEmpty) {
        final firstUnendorsed = eligibleRows.firstWhere(
          (e) => e['has_endorsement'] != true,
          orElse: () => eligibleRows.first,
        );
        preselected = (firstUnendorsed['id'] as num?)?.toInt();
      }

      setState(() {
        _enrollments = eligibleRows;
        _selectedEnrollmentId = preselected;
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
          _error = 'Gagal memuat daftar murid bimbingan.';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic>? get _selectedEnrollment {
    if (_selectedEnrollmentId == null) return null;
    for (final row in _enrollments) {
      if ((row['id'] as num?)?.toInt() == _selectedEnrollmentId) {
        return row;
      }
    }
    return null;
  }

  Future<void> _submitEndorsement() async {
    final enrollment = _selectedEnrollment;
    if (enrollment == null || _isSubmitting) return;
    final enrollmentId = (enrollment['id'] as num).toInt();
    final notes = _notesCtrl.text.trim();
    if (notes.length < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan catatan rekomendasi minimal 15 karakter.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _mentorApi.endorse(enrollmentId, notes);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final studentName =
          ((enrollment['student'] as Map<String, dynamic>?)?['name']
              as String?) ??
          'Mahasiswa';
      await AppStatusDialog.showSuccess(
        context,
        title: 'Badge Rekomendasi Diberikan!',
        message:
            '$studentName kini memiliki Badge Rekomendasi Mentor dan akan tampil pada filter Rekomendasi Mentor di pihak UMKM.',
        buttonText: 'Selesai',
      );
      if (mounted) {
        await _loadEnrollments();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Belum Dapat Memberikan Endorsement',
        message: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Mengirim Rekomendasi',
        message: 'Terjadi kendala saat menyimpan rekomendasi mentor.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedEnrollment;
    final alreadyEndorsed = selected?['has_endorsement'] == true;

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: const Text(
          'Rekomendasi ke UMKM',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryNavy),
              )
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
                        style: const TextStyle(color: AppColors.secondarySlate),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                        ),
                        onPressed: _loadEnrollments,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : _enrollments.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.military_tech_rounded,
                          size: 34,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Murid Bimbingan Aktif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Terima booking bimbingan dan berikan penilaian sesi terlebih dahulu untuk memberikan Badge Rekomendasi Kerja ke UMKM.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.secondarySlate,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadEnrollments,
                color: AppColors.primaryNavy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.military_tech_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Badge Rekomendasi Mentor membantu murid tampil prioritas di tab Rekomendasi Mentor saat melamar proyek UMKM.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Pilih Murid Bimbingan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._enrollments.map((item) {
                        final id = (item['id'] as num).toInt();
                        final student =
                            (item['student'] as Map<String, dynamic>?) ??
                            const {};
                        final cls =
                            (item['mentoring_class'] as Map<String, dynamic>?) ??
                            const {};
                        final name =
                            (student['name'] as String?) ?? 'Mahasiswa';
                        final topic =
                            (cls['topic'] as String?) ?? 'Sesi Bimbingan';
                        final score = (item['assessment_score'] as num?)
                            ?.toInt();
                        final endorsed = item['has_endorsement'] == true;
                        final isSelected = _selectedEnrollmentId == id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                setState(() => _selectedEnrollmentId = id),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : AppColors.borderSlate,
                                  width: isSelected ? 1.6 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : AppColors.secondarySlate,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkSlate,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          score != null
                                              ? '$topic · Nilai: $score'
                                              : '$topic · Belum dinilai',
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
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: endorsed
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      endorsed ? 'Endorsed' : 'Belum',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: endorsed
                                            ? const Color(0xFF047857)
                                            : AppColors.secondarySlate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Text(
                        'Catatan Rekomendasi untuk Mitra UMKM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _noteTemplates.map((tpl) {
                          return ActionChip(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: AppColors.borderSlate,
                            ),
                            label: Text(
                              tpl.$1,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () =>
                                setState(() => _notesCtrl.text = tpl.$2),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              'Jelaskan keunggulan teknis dan sikap kerja murid untuk dilihat UMKM...',
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: alreadyEndorsed
                                ? AppColors.secondarySlate
                                : AppColors.primaryNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed:
                              (selected == null ||
                                  alreadyEndorsed ||
                                  _isSubmitting)
                              ? null
                              : _submitEndorsement,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.military_tech_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: Text(
                            alreadyEndorsed
                                ? 'Murid Sudah Mendapat Badge Rekomendasi'
                                : 'Berikan Badge Rekomendasi ke UMKM',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: MentorBottomNav(
        selectedIndex: 2,
        onSelected: (index) {
          if (widget.onSelectTab == null) {
            Navigator.pop(context, index);
            return;
          }
          widget.onSelectTab!(index);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }
}
