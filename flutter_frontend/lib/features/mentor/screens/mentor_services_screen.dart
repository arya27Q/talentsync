import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorServicesScreen extends StatefulWidget {
  const MentorServicesScreen({super.key});

  @override
  MentorServicesScreenState createState() => MentorServicesScreenState();
}

class MentorServicesScreenState extends State<MentorServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '30');
  final _meetingLinkController = TextEditingController();

  final List<_MentorService> _services = [];

  final _skills = const [
    'Flutter',
    'Dart',
    'BLoC',
    'Portofolio',
    'Interview',
    'Laravel',
    'UI/UX',
  ];
  final Set<String> _selectedSkills = {'Flutter', 'Portofolio'};

  int _duration = 60;
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
        MentorApi.instance.classes(),
        MentorApi.instance.profile(),
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
      await MentorApi.instance.updateClass(service.id, {
        'status': active ? 'open' : 'cancelled',
      });
      await _loadClasses();
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledAt == null || !_scheduledAt!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal dan waktu kelas yang akan dibuka.'),
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
      await MentorApi.instance.createClass({
        'topic': _titleController.text.trim(),
        'description': descriptionParts
            .where((part) => part.isNotEmpty)
            .join('\n'),
        'scheduled_time': _scheduledAt!.toIso8601String(),
        'duration_minutes': _duration,
        'price_tc': int.parse(_priceController.text),
        'capacity': _format == '1-on-1' ? 1 : 5,
        if (_meetingLinkController.text.trim().isNotEmpty)
          'meeting_link': _meetingLinkController.text.trim(),
      });
      if (!mounted) return;
      setState(() => _creating = false);
      await _loadClasses();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kelas mentoring berhasil diterbitkan.'),
          ),
        );
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
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
    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _creating = false),
                child: Container(
                  width: 40,
                  height: 40,
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
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Create Mentoring Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Buka lapak mentoring',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Form & Floating Launch Button
        Expanded(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                  children: [
                    // Card 1: Identitas Kelas
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
                          const _FieldTitle('Judul kelas'),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkSlate,
                            ),
                            decoration: _fieldDecoration(
                              'Kurasi Portofolio Proyek UMKM',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Isi judul kelas.'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          const _FieldTitle('Deskripsi singkat'),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkSlate,
                              height: 1.4,
                            ),
                            decoration: _fieldDecoration(
                              'Bedah portofolio dan kode proyek nyata...',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Isi deskripsi kelas.'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          const _FieldTitle('Tag keahlian'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _skills.map((skill) {
                              final isSelected = _selectedSkills.contains(
                                skill,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedSkills.remove(skill);
                                    } else {
                                      _selectedSkills.add(skill);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkSlate,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Durasi, Tarif, Format & Jadwal
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
                          const _FieldTitle('Durasi sesi'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [30, 45, 60, 90].map((dur) {
                              final isSelected = _duration == dur;
                              return GestureDetector(
                                onTap: () => setState(() => _duration = dur),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Text(
                                    '$dur menit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkSlate,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // Harga TimeCoin & Setara Rupiah
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
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          const Text(
                                            'TC',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondarySlate,
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

                          // Keterangan potongan admin cash-out
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
                                'Perkiraan bersih Rp$formattedBersih per sesi setelah biaya admin $_cashoutFeePercent%.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondarySlate,
                                  height: 1.3,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),

                          // Tipe Sesi
                          const _FieldTitle('Tipe sesi'),
                          Wrap(
                            spacing: 8,
                            children: ['1-on-1', 'Grup (maks. 5)'].map((fmt) {
                              final isSelected = _format == fmt;
                              return GestureDetector(
                                onTap: () => setState(() => _format = fmt),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Text(
                                    fmt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkSlate,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          const _FieldTitle('Tanggal dan waktu kelas'),
                          OutlinedButton.icon(
                            onPressed: _pickSchedule,
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: Text(
                              _scheduledAt == null
                                  ? 'Pilih jadwal'
                                  : '${_scheduledAt!.day.toString().padLeft(2, '0')}/${_scheduledAt!.month.toString().padLeft(2, '0')}/${_scheduledAt!.year} · ${_scheduledAt!.hour.toString().padLeft(2, '0')}:${_scheduledAt!.minute.toString().padLeft(2, '0')}',
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
                              if (value == null || value.trim().isEmpty)
                                return null;
                              final uri = Uri.tryParse(value.trim());
                              if (uri == null ||
                                  !uri.hasScheme ||
                                  !uri.hasAuthority)
                                return 'Masukkan tautan yang valid.';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Output yang murid dapatkan
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
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _studentOutputs[key] = !isChecked;
                                });
                              },
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
                                        borderRadius: BorderRadius.circular(6),
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
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed / Floating Launch Service Button
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: GestureDetector(
                  onTap: _saveService,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Launch Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
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
          subtitle: 'Kelola jadwal dan tarif kelas yang bisa dibooking murid.',
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
                        style: const TextStyle(color: AppColors.secondarySlate),
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
                    style: TextStyle(color: AppColors.secondarySlate),
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
                            'Senin–Jumat · 09.00–17.00 WIB',
                            style: TextStyle(
                              color: AppColors.secondarySlate,
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
    required this.price,
    required this.format,
    required this.scheduledAt,
    required this.enrolledCount,
    required this.active,
  });

  factory _MentorService.fromJson(Map<String, dynamic> data) {
    final capacity = data['capacity'] as int? ?? 1;
    return _MentorService(
      id: data['id'] as int,
      title: data['topic'] as String? ?? 'Kelas mentoring',
      description: data['description'] as String? ?? '',
      skills: const [],
      duration: data['duration_minutes'] as int? ?? 60,
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
                      color: AppColors.secondarySlate,
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
            'Jadwal ${service.scheduledAt!.toLocal().day.toString().padLeft(2, '0')}/${service.scheduledAt!.toLocal().month.toString().padLeft(2, '0')}/${service.scheduledAt!.toLocal().year} · ${service.scheduledAt!.toLocal().hour.toString().padLeft(2, '0')}:${service.scheduledAt!.toLocal().minute.toString().padLeft(2, '0')} · ${service.enrolledCount} murid',
            style: const TextStyle(
              color: AppColors.secondarySlate,
              fontSize: 12,
            ),
          ),
        ],
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
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: AppColors.secondarySlate,
            ),
            const SizedBox(width: 5),
            Text(
              '${service.duration} menit · ${service.format}',
              style: const TextStyle(
                color: AppColors.secondarySlate,
                fontSize: 12,
              ),
            ),
            const Spacer(),
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
