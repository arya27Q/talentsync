import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_skill_picker.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';

class RejectToMentorResult {
  const RejectToMentorResult({
    required this.feedback,
    this.recommendedMentorId,
    this.recommendedMentorName,
    this.allowCatalogChoice = false,
  });

  final String feedback;
  final int? recommendedMentorId;
  final String? recommendedMentorName;
  final bool allowCatalogChoice;
}

class MsmeRejectMentorDialog extends StatefulWidget {
  const MsmeRejectMentorDialog({
    super.key,
    required this.studentName,
    this.msmeApi,
  });

  final String studentName;
  final MsmeApi? msmeApi;

  static Future<RejectToMentorResult?> show(
    BuildContext context, {
    required String studentName,
    MsmeApi? msmeApi,
  }) => showDialog<RejectToMentorResult>(
    context: context,
    barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.55),
    builder: (ctx) => MsmeRejectMentorDialog(
      studentName: studentName,
      msmeApi: msmeApi,
    ),
  );

  @override
  State<MsmeRejectMentorDialog> createState() => _MsmeRejectMentorDialogState();
}

class _MsmeRejectMentorDialogState extends State<MsmeRejectMentorDialog> {
  static const int _catalogOptionId = -1;

  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;
  late final TextEditingController _feedbackController;

  bool _isLoadingMentors = true;
  String _selectedCategory = 'Semua';
  List<Map<String, dynamic>> _mentors = const [];
  int? _selectedOptionId; // null = belum dipilih, -1 = katalog mentor lain, >0 = ID mentor spesifik
  String? _selectedMentorName;
  int? _selectedTemplateIndex = 0;
  String? _mentorError;
  String? _validationError;

  static const List<String> _templateLabels = [
    'Perkuat Portofolio',
    'Pendalaman Teknis',
    'Kesiapan Alur Kerja',
  ];

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController(
      text: _buildTemplateText(0),
    );
    _loadMentors();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _mentorTargetPhrase() {
    if (_selectedOptionId != null &&
        _selectedOptionId != _catalogOptionId &&
        _selectedMentorName != null &&
        _selectedMentorName!.trim().isNotEmpty) {
      return 'Mentor ${_selectedMentorName!.trim()}';
    }
    return 'mentor yang sesuai di katalog TalentSync';
  }

  String _buildTemplateText(int index) {
    final target = _mentorTargetPhrase();
    return switch (index) {
      0 =>
        'Terima kasih atas lamaran dan antusiasme Anda. Saat ini portofolio/CV yang dilampirkan masih perlu pendalaman agar sesuai dengan kebutuhan proyek kami. Kami menyarankan Anda mengikuti bimbingan bersama $target terlebih dahulu untuk mematangkan studi kasus dan hasil karya sebelum melamar kembali.',
      1 =>
        'Terima kasih telah melamar proyek kami. Dasar keahlian Anda sudah baik, namun proyek ini membutuhkan pengalaman teknis yang lebih mendalam pada ruang lingkup pekerjaan terkait. Silakan berkonsultasi bersama $target untuk memperkuat kompetensi teknis dan memperbarui portofolio Anda.',
      _ =>
        'Terima kasih atas ketertarikan Anda pada proyek kami. Untuk penugasan ini kami memerlukan pelamar yang sudah terbiasa dengan alur kerja milestone dan target pengerjaan yang ketat. Kami merekomendasikan sesi pendampingan bersama $target agar kesiapan teknis serta manajemen proyek Anda semakin optimal.',
    };
  }

  void _applyTemplate(int index) {
    setState(() {
      _selectedTemplateIndex = index;
      _feedbackController.text = _buildTemplateText(index);
      _validationError = null;
    });
  }

  Future<void> _loadMentors() async {
    setState(() => _isLoadingMentors = true);
    try {
      final list = await _msmeApi.getRecommendedMentors(
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _mentors = list;
        _isLoadingMentors = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMentors = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _feedbackController.text.trim().length;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tolak & Arahkan Mentor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih mentor yang kamu rekomendasikan dan sampaikan pesan evaluasi formal untuk ${widget.studentName} sebagai bahan belajar.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.secondarySlate,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pilih Mentor yang Direkomendasikan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Wajib',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                isExpanded: true,
                dropdownColor: Colors.white,
                elevation: 6,
                menuMaxHeight: 320,
                borderRadius: BorderRadius.circular(14),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.canvasWhite,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSlate),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSlate),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryNavy,
                      width: 1.4,
                    ),
                  ),
                ),
                items: MentorSkillPicker.filterLabels.map((cat) {
                  final label = cat == 'Semua' ? 'Semua Bidang Mentor' : cat;
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(
                          MentorSkillPicker.iconForLabel(cat),
                          size: 16,
                          color: AppColors.primaryNavy,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null || value == _selectedCategory) return;
                  setState(() => _selectedCategory = value);
                  _loadMentors();
                },
              ),
              const SizedBox(height: 8),
              if (_isLoadingMentors)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 175),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ..._mentors.map((m) {
                          final mentorId = (m['id'] as num?)?.toInt();
                          final mentorName =
                              (m['name'] as String?) ?? 'Mentor TalentSync';
                          final headline =
                              (m['title_headline'] as String?) ??
                              'Peer Mentor TalentSync';
                          final nearest =
                              m['nearest_class'] as Map<String, dynamic>?;
                          final displayPrice =
                              (nearest?['price_tc'] as num?)?.toInt() ??
                              (m['hourly_rate_tc'] as num?)?.toInt();
                          final rawDur =
                              (nearest?['duration_label'] as String?)?.trim();
                          final subtitleWithDuration =
                              (rawDur != null && rawDur.isNotEmpty)
                              ? '$headline · Durasi $rawDur'
                              : headline;
                          return _buildMentorOption(
                            optionId: mentorId ?? 0,
                            name: mentorName,
                            subtitle: subtitleWithDuration,
                            rateLabel: displayPrice != null
                                ? '$displayPrice TC'
                                : null,
                          );
                        }),
                        _buildMentorOption(
                          optionId: _catalogOptionId,
                          name: 'Pilih mentor lain di katalog',
                          subtitle:
                              'Arahkan mahasiswa memilih sendiri mentor sesuai bidangnya',
                          rateLabel: 'Katalog',
                        ),
                      ],
                    ),
                  ),
                ),
              if (_mentorError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _mentorError!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pesan Evaluasi ke Chat Mahasiswa',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Wajib',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Usahakan pesan mengandung alasan teknis maupun non-teknis secara jelas (misal: keahlian tools, studi kasus portofolio, atau kesiapan waktu) agar mahasiswa mudah belajar. Pesan terkirim otomatis ke ruang chat sebelum obrolan ditutup.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondarySlate,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(_templateLabels.length, (i) {
                  final active = _selectedTemplateIndex == i;
                  return InkWell(
                    onTap: () => _applyTemplate(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryNavy
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active
                              ? AppColors.primaryNavy
                              : AppColors.borderSlate,
                        ),
                      ),
                      child: Text(
                        _templateLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: active ? Colors.white : AppColors.darkSlate,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) {
                  setState(() {
                    _selectedTemplateIndex = null;
                    _validationError = null;
                  });
                },
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.darkSlate,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.canvasWhite,
                  errorText: _validationError,
                  hintText:
                      'Tuliskan alasan teknis/non-teknis & saran belajar minimal 40 karakter...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSlate),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSlate),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryNavy),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount/500 karakter (min. 40)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: charCount < 40
                        ? const Color(0xFFDC2626)
                        : AppColors.secondarySlate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.secondarySlate),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoadingMentors
              ? null
              : () {
                  final text = _feedbackController.text.trim();
                  String? mentorErr;
                  String? feedbackErr;
                  if (_selectedOptionId == null) {
                    mentorErr =
                        'Wajib pilih salah satu mentor atau opsi katalog mentor.';
                  }
                  if (text.length < 40) {
                    feedbackErr =
                        'Wajib isi catatan evaluasi minimal 40 karakter (muat alasan teknis/non-teknis secara jelas).';
                  }
                  if (mentorErr != null || feedbackErr != null) {
                    setState(() {
                      _mentorError = mentorErr;
                      _validationError = feedbackErr;
                    });
                    return;
                  }
                  final isCatalog = _selectedOptionId == _catalogOptionId;
                  Navigator.pop(
                    context,
                    RejectToMentorResult(
                      feedback: text,
                      recommendedMentorId: isCatalog ? null : _selectedOptionId,
                      recommendedMentorName: isCatalog
                          ? null
                          : _selectedMentorName,
                      allowCatalogChoice: isCatalog,
                    ),
                  );
                },
          child: const Text(
            'Kirim Arahan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMentorOption({
    required int optionId,
    required String name,
    required String subtitle,
    required String? rateLabel,
  }) {
    final isSelected = _selectedOptionId == optionId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOptionId = optionId;
            _selectedMentorName = optionId == _catalogOptionId ? null : name;
            _mentorError = null;
            if (_selectedTemplateIndex != null) {
              _feedbackController.text = _buildTemplateText(
                _selectedTemplateIndex!,
              );
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFFBEB)
                : AppColors.canvasWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF59E0B)
                  : AppColors.borderSlate,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 18,
                color: isSelected
                    ? const Color(0xFFD97706)
                    : AppColors.secondarySlate,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              if (rateLabel != null) ...[
                const SizedBox(width: 6),
                Text(
                  rateLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
