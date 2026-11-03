import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorServicesScreen extends StatefulWidget {
  const MentorServicesScreen({super.key});

  @override
  MentorServicesScreenState createState() => MentorServicesScreenState();
}

class MentorServicesScreenState extends State<MentorServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Kurasi Portofolio Proyek UMKM');
  final _descriptionController = TextEditingController(
    text: 'Bedah portofolio dan kode proyek nyata agar siap lolos seleksi proyek UMKM.',
  );
  final _priceController = TextEditingController(text: '30');

  final List<_MentorService> _services = [
    _MentorService(
      title: 'Kurasi Portofolio Proyek UMKM',
      description: 'Bedah portofolio dan kode proyek nyata agar siap lolos seleksi proyek UMKM.',
      skills: const ['Flutter', 'Portofolio'],
      duration: 60,
      price: 30,
      format: '1-on-1',
    ),
    _MentorService(
      title: 'Review arsitektur aplikasi',
      description: 'Diskusi struktur aplikasi dan rencana pengembangan.',
      skills: const ['Dart', 'Flutter'],
      duration: 60,
      price: 30,
      format: '1-on-1',
    ),
  ];

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
  final Set<String> _availableDays = {'Sel', 'Kam', 'Sab'};
  final List<String> _allDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  final Map<String, bool> _studentOutputs = {
    'Rekaman sesi': true,
    'Action plan': true,
    'Materi PDF': true,
    'Sertifikat kelulusan': false,
    'Kesempatan direkomendasikan ke UMKM': false,
  };

  bool _creating = false;

  void startCreating() => setState(() => _creating = true);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveService() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu tag keahlian.')),
      );
      return;
    }
    setState(() {
      _services.insert(
        0,
        _MentorService(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          skills: _selectedSkills.toList(),
          duration: _duration,
          price: int.tryParse(_priceController.text) ?? 30,
          format: _format,
        ),
      );
      _creating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Layanan mentoring berhasil diterbitkan.')),
    );
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
                            style: const TextStyle(fontSize: 14, color: AppColors.darkSlate),
                            decoration: _fieldDecoration('Kurasi Portofolio Proyek UMKM'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Isi judul kelas.' : null,
                          ),
                          const SizedBox(height: 16),

                          const _FieldTitle('Deskripsi singkat'),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13, color: AppColors.darkSlate, height: 1.4),
                            decoration: _fieldDecoration('Bedah portofolio dan kode proyek nyata...'),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Isi deskripsi kelas.' : null,
                          ),
                          const SizedBox(height: 16),

                          const _FieldTitle('Tag keahlian'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _skills.map((skill) {
                              final isSelected = _selectedSkills.contains(skill);
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryNavy : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.darkSlate,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryNavy : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Text(
                                    '$dur menit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.darkSlate,
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.borderSlate),
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
                                              keyboardType: TextInputType.number,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkSlate,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasWhite,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: AppColors.borderSlate),
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
                              final amount = int.tryParse(_priceController.text) ?? 30;
                              final rupiah = amount * 1000;
                              final bersih = (rupiah * 0.85).toInt();
                              final formattedBersih = bersih.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]}.',
                                  );
                              return Text(
                                'Kamu terima bersih Rp$formattedBersih per sesi saat cash-out (admin 15%).',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryNavy : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Text(
                                    fmt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.darkSlate,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // Hari Tersedia
                          const _FieldTitle('Hari tersedia'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allDays.map((day) {
                              final isSelected = _availableDays.contains(day);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _availableDays.remove(day);
                                    } else {
                                      _availableDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryNavy : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppColors.darkSlate,
                                      ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderSlate),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isChecked ? AppColors.primaryNavy : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isChecked ? AppColors.primaryNavy : AppColors.borderSlate,
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
                                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
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
          title: 'Layanan mentoring',
          subtitle: 'Atur kelas, durasi, dan tarif TimeCoin.',
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
              const MentorSectionTitle('Layanan saya'),
              if (_services.isEmpty)
                const MentorCard(
                  child: Text(
                    'Belum ada layanan. Tambahkan kelas agar murid bisa membuat booking.',
                    style: TextStyle(color: AppColors.secondarySlate),
                  ),
                ),
              for (final service in _services) ...[
                _ServiceCard(
                  service: service,
                  onChanged: (active) => setState(() => service.active = active),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
    required this.title,
    required this.description,
    required this.skills,
    required this.duration,
    required this.price,
    required this.format,
  }) : active = true;
  final String title;
  final String description;
  final List<String> skills;
  final int duration;
  final int price;
  final String format;
  bool active;
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
                Icons.school_outlined,
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
              Icons.schedule_outlined,
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
