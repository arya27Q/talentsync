import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_skill_picker.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorServicesScreen extends StatefulWidget {
  const MentorServicesScreen({super.key, this.mentorApi});

  final MentorApi? mentorApi;

  @override
  MentorServicesScreenState createState() => MentorServicesScreenState();
}

class MentorServicesScreenState extends State<MentorServicesScreen> {
  static const Color _accessibleCaptionSlate = Color(0xFF475569);
  static const List<String> _durationUnits = ['Hari', 'Minggu', 'Bulan'];

  late final MentorApi _api = widget.mentorApi ?? MentorApi.instance;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController(text: '30');
  final _meetingLinkController = TextEditingController();

  final List<_MentorService> _services = [];

  final Set<String> _selectedSkills = {'Flutter', 'Portofolio'};

  String _durationUnit = 'Hari';
  String _format = '1-on-1';

  final Map<String, bool> _studentOutputs = {
    'Rekaman sesi': true,
    'Action plan': true,
    'Materi PDF': true,
    'Sertifikat kelulusan': false,
    'Kesempatan direkomendasikan ke UMKM': false,
  };

  bool _creating = false;
  bool _loading = true;
  bool _saving = false;
  int _cashoutFeePercent = 10;
  String? _error;
  DateTime? _scheduledAt;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.classes(),
        _api.profile(),
      ]);
      final classes = results[0] as List<Map<String, dynamic>>;
      final profile = results[1] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _cashoutFeePercent = profile['cashout_fee_percent'] as int? ?? 10;
        _services
          ..clear()
          ..addAll(classes.map(_MentorService.fromJson));
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void startCreating() => setState(() => _creating = true);

  int? _computedDurationDays() {
    final parsed = int.tryParse(_durationController.text.trim());
    if (parsed == null || parsed <= 0) return null;
    return switch (_durationUnit) {
      'Minggu' => parsed * 7,
      'Bulan' => parsed * 30,
      _ => parsed,
    };
  }

  String _computedDurationLabel() {
    final parsed = int.tryParse(_durationController.text.trim());
    if (parsed == null || parsed <= 0) return '';
    return '$parsed $_durationUnit';
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (selectedDate == null || !mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledAt ?? now.add(const Duration(hours: 2)),
      ),
    );
    if (selectedTime == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _toggleClass(_MentorService service, bool active) async {
    try {
      await _api.updateClass(service.id, {
        'status': active ? 'open' : 'cancelled',
      });
      await _loadClasses();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    final durationDays = _computedDurationDays();
    final durationLabel = _computedDurationLabel();
    if (durationDays == null || durationDays < 2 || durationLabel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Durasi pendampingan minimal 2 hari sesuai target kinerja murid.',
          ),
        ),
      );
      return;
    }
    if (_scheduledAt == null || !_scheduledAt!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal dan waktu mulai pendampingan.'),
        ),
      );
      return;
    }
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu tag keahlian.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final selectedOutputs = _studentOutputs.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      final descriptionParts = [
        _descriptionController.text.trim(),
        if (_selectedSkills.isNotEmpty)
          'Keahlian: ${_selectedSkills.join(', ')}.',
        if (selectedOutputs.isNotEmpty)
          'Termasuk: ${selectedOutputs.join(', ')}.',
      ];
      await _api.createClass({
        'topic': _titleController.text.trim(),
        'description': descriptionParts
            .where((part) => part.isNotEmpty)
            .join('\n'),
        'scheduled_time': _scheduledAt!.toIso8601String(),
        'duration_minutes': 60,
        'duration_days': durationDays,
        'duration_label': durationLabel,
        'price_tc': int.parse(_priceController.text.trim()),
        'capacity': _format == '1-on-1' ? 1 : 5,
        if (_meetingLinkController.text.trim().isNotEmpty)
          'meeting_link': _meetingLinkController.text.trim(),
      });
      if (!mounted) return;
      _durationController.clear();
      setState(() => _creating = false);
      await _loadClasses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Layanan pendampingan ($durationLabel) berhasil diterbitkan.',
            ),
          ),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: _creating ? _buildCreateFormView() : _buildServiceListView(),
    );
  }

  Widget _buildCreateFormView() {
    final computedDays = _computedDurationDays();
    final computedLabel = _computedDurationLabel();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Kembali ke daftar layanan mentoring',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _creating = false),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: AppColors.darkSlate,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat Layanan Mentoring',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Atur topik, durasi kinerja, dan tarif TimeCoin',
                      style: TextStyle(
                        fontSize: 12,
                        color: _accessibleCaptionSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldTitle('Judul program bimbingan'),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkSlate,
                            ),
                            decoration: _fieldDecoration(
                              'Contoh: Kurasi Portofolio Proyek UMKM',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Isi judul program bimbingan.'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const _FieldTitle('Deskripsi & target kinerja'),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkSlate,
                              height: 1.4,
                            ),
                            decoration: _fieldDecoration(
                              'Jelaskan ruang lingkup review kode, revisi portofolio, dan target kesiapan murid...',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Isi deskripsi bimbingan.'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const _FieldTitle('Bidang & tag keahlian'),
                          MentorSkillPicker(
                            selectedSkills: _selectedSkills,
                            onChanged: (next) {
                              setState(() {
                                _selectedSkills
                                  ..clear()
                                  ..addAll(next);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldTitle('Durasi pendampingan'),
                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkSlate,
                            ),
                            decoration: _fieldDecoration('Misal: 7').copyWith(
                              prefixIcon: const Icon(
                                Icons.event_repeat_rounded,
                                color: AppColors.primaryNavy,
                                size: 20,
                              ),
                              suffixText: _durationUnit,
                              suffixStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: (val) {
                              final parsed = int.tryParse((val ?? '').trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Isi angka durasi pendampingan.';
                              }
                              final days = switch (_durationUnit) {
                                'Minggu' => parsed * 7,
                                'Bulan' => parsed * 30,
                                _ => parsed,
                              };
                              if (days < 2) {
                                return 'Minimal 2 hari sesuai target kinerja murid.';
                              }
                              if (days > 365) {
                                return 'Maksimal durasi 365 hari (12 bulan).';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(_durationUnits.length, (i) {
                              final unit = _durationUnits[i];
                              final isSelected = _durationUnit == unit;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i < _durationUnits.length - 1 ? 8 : 0,
                                  ),
                                  child: Semantics(
                                    button: true,
                                    selected: isSelected,
                                    label: 'Satuan durasi $unit',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () =>
                                          setState(() => _durationUnit = unit),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 44,
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryNavy
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryNavy
                                                  : AppColors.borderSlate,
                                            ),
                                          ),
                                          child: Text(
                                            unit,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppColors.darkSlate,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            computedDays != null && computedDays >= 2
                                ? 'Target durasi: $computedLabel (setara $computedDays hari pendampingan sesuai kinerja murid).'
                                : 'Isi sendiri lama bimbingan sesuai target kinerja murid (minimal 2 hari).',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _accessibleCaptionSlate,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldTitle('Harga TimeCoin'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
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
                                            Icons.toll_rounded,
                                            color: AppColors.accentAmberGold,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _priceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkSlate,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              validator: (val) {
                                                final p = int.tryParse(
                                                  (val ?? '').trim(),
                                                );
                                                if (p == null || p < 1) {
                                                  return 'Min 1 TC';
                                                }
                                                return null;
                                              },
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          const Text(
                                            'TC',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _accessibleCaptionSlate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldTitle('Setara Rupiah'),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasWhite,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.borderSlate,
                                        ),
                                      ),
                                      child: Text(
                                        'Rp${((int.tryParse(_priceController.text) ?? 0) * 1000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkSlate,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              final amount =
                                  int.tryParse(_priceController.text) ?? 30;
                              final rupiah = amount * 1000;
                              final bersih =
                                  (rupiah * (100 - _cashoutFeePercent) / 100)
                                      .round();
                              final formattedBersih = bersih
                                  .toString()
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]}.',
                                  );
                              return Text(
                                'Perkiraan bersih Rp$formattedBersih per program setelah biaya admin $_cashoutFeePercent%.',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _accessibleCaptionSlate,
                                  height: 1.3,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          const _FieldTitle('Tipe bimbingan'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: ['1-on-1', 'Grup (maks. 5)'].map((fmt) {
                              final isSelected = _format == fmt;
                              return ChoiceChip(
                                label: Text(
                                  fmt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkSlate,
                                  ),
                                ),
                                selected: isSelected,
                                showCheckmark: false,
                                selectedColor: AppColors.primaryNavy,
                                backgroundColor: Colors.white,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : AppColors.borderSlate,
                                  ),
                                ),
                                onSelected: (_) =>
                                    setState(() => _format = fmt),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          const _FieldTitle('Tanggal dan waktu mulai'),
                          SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: _pickSchedule,
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: Text(
                                _scheduledAt == null
                                    ? 'Pilih jadwal mulai'
                                    : '${_scheduledAt!.day.toString().padLeft(2, '0')}/${_scheduledAt!.month.toString().padLeft(2, '0')}/${_scheduledAt!.year} · ${_scheduledAt!.hour.toString().padLeft(2, '0')}:${_scheduledAt!.minute.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _FieldTitle('Tautan Google Meet (opsional)'),
                          TextFormField(
                            controller: _meetingLinkController,
                            keyboardType: TextInputType.url,
                            decoration: _fieldDecoration(
                              'https://meet.google.com/...',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final uri = Uri.tryParse(value.trim());
                              if (uri == null ||
                                  !uri.hasScheme ||
                                  !uri.hasAuthority) {
                                return 'Masukkan tautan yang valid.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldTitle('Output yang murid dapatkan'),
                          const SizedBox(height: 6),
                          ..._studentOutputs.keys.map((key) {
                            final isChecked = _studentOutputs[key] ?? false;
                            return Semantics(
                              button: true,
                              checked: isChecked,
                              label: key,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _studentOutputs[key] = !isChecked;
                                  });
                                },
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.canvasWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.borderSlate,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: isChecked
                                                ? AppColors.primaryNavy
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: isChecked
                                                  ? AppColors.primaryNavy
                                                  : AppColors.borderSlate,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: isChecked
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            key,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isChecked
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: AppColors.darkSlate,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      disabledBackgroundColor: _accessibleCaptionSlate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _saving ? null : _saveService,
                    icon: Icon(
                      _saving
                          ? Icons.hourglass_top_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    label: Text(
                      _saving ? 'Menerbitkan Layanan...' : 'Terbitkan Layanan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceListView() {
    return Column(
      children: [
        MentorPageHeader(
          title: 'Kelas mentoring',
          subtitle:
              'Kelola jadwal, durasi kinerja, dan tarif kelas yang bisa dibooking murid.',
          trailing: IconButton.filled(
            tooltip: 'Tambah layanan',
            onPressed: () => setState(() => _creating = true),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              const MentorSectionTitle('Kelas saya'),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                MentorCard(
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: _accessibleCaptionSlate),
                      ),
                      TextButton(
                        onPressed: _loadClasses,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              if (!_loading && _error == null && _services.isEmpty)
                const MentorCard(
                  child: Text(
                    'Belum ada layanan. Tambahkan kelas agar murid bisa membuat booking.',
                    style: TextStyle(color: _accessibleCaptionSlate),
                  ),
                ),
              for (final service in _services) ...[
                _ServiceCard(
                  service: service,
                  onChanged: (active) => _toggleClass(service, active),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              const MentorSectionTitle('Pengaturan ketersediaan'),
              const MentorCard(
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: AppColors.primaryNavy),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jam konsultasi',
                            style: TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Senin sampai Jumat · 09.00 sampai 17.00 WIB',
                            style: TextStyle(
                              color: _accessibleCaptionSlate,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.borderSlate),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.borderSlate),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
    ),
  );
}

class _MentorService {
  _MentorService({
    required this.id,
    required this.title,
    required this.description,
    required this.skills,
    required this.duration,
    required this.durationLabel,
    required this.price,
    required this.format,
    required this.scheduledAt,
    required this.enrolledCount,
    required this.active,
  });

  factory _MentorService.fromJson(Map<String, dynamic> data) {
    final capacity = data['capacity'] as int? ?? 1;
    final durationMinutes = data['duration_minutes'] as int? ?? 60;
    final rawLabel = (data['duration_label'] as String?)?.trim();
    final durationDays = (data['duration_days'] as num?)?.toInt();
    final resolvedLabel = (rawLabel != null && rawLabel.isNotEmpty)
        ? rawLabel
        : (durationDays != null && durationDays >= 2
              ? '$durationDays Hari'
              : '$durationMinutes menit');

    final description = data['description'] as String? ?? '';
    final parsedSkills = <String>[];
    final skillMatch = RegExp(
      r'Keahlian:\s*([^\n.]+)',
      caseSensitive: false,
    ).firstMatch(description);
    if (skillMatch != null) {
      parsedSkills.addAll(
        skillMatch
            .group(1)!
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    return _MentorService(
      id: data['id'] as int,
      title: data['topic'] as String? ?? 'Kelas mentoring',
      description: description,
      skills: parsedSkills,
      duration: durationMinutes,
      durationLabel: resolvedLabel,
      price: data['price_tc'] as int? ?? 0,
      format: capacity == 1 ? '1-on-1' : 'Grup (maks. $capacity)',
      scheduledAt: DateTime.tryParse(data['scheduled_time'] as String? ?? ''),
      enrolledCount: data['enrolled_count'] as int? ?? 0,
      active: data['status'] == 'open',
    );
  }

  final int id;
  final String title;
  final String description;
  final List<String> skills;
  final int duration;
  final String durationLabel;
  final int price;
  final String format;
  final DateTime? scheduledAt;
  final int enrolledCount;
  final bool active;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onChanged});
  final _MentorService service;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MentorCard(
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Tampilkan ${service.title}',
              child: Switch.adaptive(
                value: service.active,
                activeTrackColor: AppColors.primaryNavy,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        if (service.scheduledAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Mulai ${service.scheduledAt!.toLocal().day.toString().padLeft(2, '0')}/${service.scheduledAt!.toLocal().month.toString().padLeft(2, '0')}/${service.scheduledAt!.toLocal().year} · ${service.scheduledAt!.toLocal().hour.toString().padLeft(2, '0')}:${service.scheduledAt!.toLocal().minute.toString().padLeft(2, '0')} · ${service.enrolledCount} murid',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
            ),
          ),
        ],
        if (service.skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: service.skills
                .map(
                  (skill) => MentorTag(
                    skill,
                    color: AppColors.lightBlueSurface,
                    textColor: AppColors.primaryNavy,
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.event_repeat_rounded,
              size: 16,
              color: Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${service.durationLabel} · ${service.format}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.toll_rounded,
              size: 14,
              color: AppColors.accentAmberGold,
            ),
            const SizedBox(width: 5),
            Text(
              '${service.price} TC',
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _FieldTitle extends StatelessWidget {
  const _FieldTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.darkSlate,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
  );
}
