import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorServicesScreen extends StatefulWidget {
  const MentorServicesScreen({super.key});

  @override
  State<MentorServicesScreen> createState() => _MentorServicesScreenState();
}

class _MentorServicesScreenState extends State<MentorServicesScreen> {
  final List<_MentorService> _services = [
    _MentorService(title: 'Konsultasi Laravel API', category: 'Backend Development', duration: '60 menit', price: 3, active: true),
    _MentorService(title: 'Review UI Flutter', category: 'Mobile Development', duration: '60 menit', price: 5, active: true),
    _MentorService(title: 'Bedah portofolio developer', category: 'Career Preparation', duration: '45 menit', price: 4, active: false),
  ];

  Future<void> _addService() async {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController(text: '3');
    final saved = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Tambah jasa mentoring', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _FormField(controller: titleController, label: 'Nama sesi', hint: 'Contoh: Review portofolio'),
        const SizedBox(height: 12),
        _FormField(controller: categoryController, label: 'Bidang keahlian', hint: 'Contoh: UI/UX Design'),
        const SizedBox(height: 12),
        _FormField(controller: priceController, label: 'Tarif (TC)', hint: '3', keyboardType: TextInputType.number),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.tertiaryCaramel, foregroundColor: Colors.white), child: const Text('Simpan'))],
    ));
    if (saved == true && titleController.text.trim().isNotEmpty && mounted) {
      final amount = int.tryParse(priceController.text) ?? 3;
      setState(() => _services.insert(0, _MentorService(title: titleController.text.trim(), category: categoryController.text.trim().isEmpty ? 'Mentoring' : categoryController.text.trim(), duration: '60 menit', price: amount.clamp(1, 100).toInt(), active: true)));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jasa mentoring berhasil ditambahkan.')));
    }
    titleController.dispose();
    categoryController.dispose();
    priceController.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(bottom: false, child: Column(children: [
    MentorPageHeader(title: 'Jasa mentoring', subtitle: 'Atur kelas, durasi, dan tarif TimeCoin.', trailing: IconButton.filled(onPressed: _addService, style: IconButton.styleFrom(backgroundColor: AppColors.tertiaryCaramel, foregroundColor: Colors.white), icon: const Icon(Icons.add_rounded))),
    Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(22, 0, 22, 24), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF3E8DC), borderRadius: BorderRadius.circular(18)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lightbulb_outline_rounded, color: AppColors.tertiaryCaramel), SizedBox(width: 11), Expanded(child: Text('Buat layanan yang jelas agar murid tahu topik, durasi, dan biaya sesi sebelum booking.', style: TextStyle(color: AppColors.darkBrown, fontSize: 12, height: 1.45)))])),
      const SizedBox(height: 18),
      MentorSectionTitle('Layanan saya', action: '${_services.length} layanan'),
      for (var i = 0; i < _services.length; i++) ...[
        _ServiceCard(service: _services[i], onChanged: (active) => setState(() => _services[i].active = active)),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 6),
      const MentorSectionTitle('Pengaturan ketersediaan'),
      const MentorCard(child: Row(children: [Icon(Icons.schedule_rounded, color: AppColors.tertiaryCaramel), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Jam konsultasi', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Senin–Jumat · 09.00–17.00 WIB', style: TextStyle(color: Colors.grey, fontSize: 12))])), Icon(Icons.chevron_right_rounded, color: Colors.grey)])),
    ])),
  ]));
}

class _MentorService {
  _MentorService({required this.title, required this.category, required this.duration, required this.price, required this.active});
  final String title, category, duration;
  final int price;
  bool active;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onChanged});
  final _MentorService service;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => MentorCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF5EFE8), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.school_outlined, color: AppColors.tertiaryCaramel)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(service.title, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(height: 4), Text(service.category, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))])), Switch.adaptive(value: service.active, activeTrackColor: AppColors.primaryTan, onChanged: onChanged)]),
    const SizedBox(height: 14),
    Row(children: [Icon(Icons.schedule_outlined, size: 15, color: Colors.grey.shade600), const SizedBox(width: 5), Text(service.duration, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)), const Spacer(), const Icon(Icons.toll_rounded, size: 17, color: Color(0xFFD99B3E)), const SizedBox(width: 5), Text('${service.price} TC / sesi', style: const TextStyle(color: AppColors.darkBrown, fontSize: 12, fontWeight: FontWeight.w800))]),
    const SizedBox(height: 12),
    Row(children: [MentorTag(service.active ? 'Tayang' : 'Disembunyikan', color: service.active ? const Color(0xFFEAF4ED) : const Color(0xFFF1F1F1), textColor: service.active ? const Color(0xFF38845B) : Colors.grey.shade600), const Spacer(), TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form edit layanan akan tersedia pada integrasi berikutnya.'))), icon: const Icon(Icons.edit_outlined, size: 15), label: const Text('Edit'), style: TextButton.styleFrom(foregroundColor: AppColors.tertiaryCaramel))]),
  ]));
}

class _FormField extends StatelessWidget {
  const _FormField({required this.controller, required this.label, required this.hint, this.keyboardType});
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: AppColors.warmOffWhite, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12)));
}
