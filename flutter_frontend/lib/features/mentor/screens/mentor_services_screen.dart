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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '30');
  final List<_MentorService> _services = [
    _MentorService(
      title: 'Kurasi Portofolio Proyek UMKM',
      description: 'Bedah portofolio dan kode proyek nyata agar siap melamar proyek UMKM.',
      skills: const ['Flutter', 'Portfolio'],
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
    'Portfolio',
    'Interview',
    'Laravel',
    'UI/UX',
  ];
  final Set<String> _selectedSkills = {'Flutter', 'Portfolio'};
  int _duration = 60;
  String _format = '1-on-1';
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
          price: int.parse(_priceController.text),
          format: _format,
        ),
      );
      _creating = false;
    });
    _titleController.clear();
    _descriptionController.clear();
    _selectedSkills
      ..clear()
      ..add('Flutter');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Layanan mentoring berhasil diterbitkan.')),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        MentorPageHeader(
          title: _creating ? 'Create Mentoring Service' : 'Layanan mentoring',
          subtitle: _creating
              ? 'Buka lapak mentoring'
              : 'Atur kelas, durasi, dan tarif TimeCoin.',
          trailing: _creating
              ? IconButton(
                  tooltip: 'Tutup formulir',
                  onPressed: () => setState(() => _creating = false),
                  icon: const Icon(Icons.close_rounded),
                )
              : IconButton.filled(
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
        Expanded(child: _creating ? _buildCreateForm() : _buildServiceList()),
      ],
    ),
  );

  Widget _buildCreateForm() => Form(
    key: _formKey,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              MentorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldTitle('Judul kelas'),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _fieldDecoration(
                        'Contoh: Kurasi Portofolio Proyek UMKM',
                        label: 'Judul kelas',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Isi judul kelas.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldTitle('Deskripsi singkat'),
                    TextFormField(
                      controller: _descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 3,
                      maxLines: 4,
                      decoration: _fieldDecoration(
                        'Jelaskan apa yang akan dipelajari murid',
                        label: 'Deskripsi singkat',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Isi deskripsi kelas.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldTitle('Tag keahlian'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        final selected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (value) => setState(
                            () => value
                                ? _selectedSkills.add(skill)
                                : _selectedSkills.remove(skill),
                          ),
                          selectedColor: AppColors.primaryNavy,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? AppColors.primaryNavy
                                : AppColors.borderSlate,
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.darkSlate,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: const StadiumBorder(),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              MentorCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldTitle('Durasi sesi'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [30, 45, 60, 90]
                          .map(
                            (minutes) => ChoiceChip(
                              label: Text('$minutes menit'),
                              selected: _duration == minutes,
                              onSelected: (_) =>
                                  setState(() => _duration = minutes),
                              selectedColor: AppColors.primaryNavy,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: _duration == minutes
                                    ? AppColors.primaryNavy
                                    : AppColors.borderSlate,
                              ),
                              labelStyle: TextStyle(
                                color: _duration == minutes
                                    ? Colors.white
                                    : AppColors.darkSlate,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    const _FieldTitle('Harga TimeCoin'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration(
                              '30 TC',
                              label: 'Harga TimeCoin',
                            ),
                            validator: (value) {
                              final amount = int.tryParse(value ?? '');
                              return amount == null || amount < 1
                                  ? 'Harga minimal 1 TC.'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldTitle('Setara Rupiah'),
                              const SizedBox(height: 14),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _priceController,
                                builder: (context, value, _) {
                                  final amount = int.tryParse(value.text) ?? 0;
                                  return Text(
                                    'Rp${(amount * 1000).toString()}',
                                    style: const TextStyle(
                                      color: AppColors.darkSlate,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _FieldTitle('Format sesi'),
                    Wrap(
                      spacing: 8,
                      children: ['1-on-1', 'Grup (maks. 5)']
                          .map(
                            (format) => ChoiceChip(
                              label: Text(format),
                              selected: _format == format,
                              onSelected: (_) =>
                                  setState(() => _format = format),
                              selectedColor: AppColors.primaryNavy,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: _format == format
                                    ? AppColors.primaryNavy
                                    : AppColors.borderSlate,
                              ),
                              labelStyle: TextStyle(
                                color: _format == format
                                    ? Colors.white
                                    : AppColors.darkSlate,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveService,
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Launch Service'),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildServiceList() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    children: [
      MentorSectionTitle('Layanan saya', action: '${_services.length} layanan'),
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
  );

  InputDecoration _fieldDecoration(String hint, {required String label}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryNavy, width: 2),
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
              Icons.circle,
              size: 10,
              color: AppColors.accentAmberDeep,
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
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.darkSlate,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
