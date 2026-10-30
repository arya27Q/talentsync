import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorProfileScreen extends StatelessWidget {
  const MentorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(bottom: false, child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 22, 28), children: [
    Row(children: [const Expanded(child: Text('Profil mentor', style: TextStyle(color: AppColors.darkBrown, fontSize: 24, fontWeight: FontWeight.w800))), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan profil akan tersedia segera.'))), icon: const Icon(Icons.settings_outlined, color: AppColors.darkBrown))]),
    const SizedBox(height: 13),
    MentorCard(child: Column(children: [
      const MentorAvatar(initials: 'BB', size: 82, color: Color(0xFFE8D7C5)),
      const SizedBox(height: 12),
      const Text('Budi Santoso', style: TextStyle(color: AppColors.darkBrown, fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text('Senior Software Engineer · Jakarta', style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      const MentorTag('Mentor terverifikasi', color: Color(0xFFEAF4ED), textColor: Color(0xFF38845B)),
      const SizedBox(height: 18),
      Row(children: [Expanded(child: _ProfileMetric(value: '4.9', caption: 'Rating', icon: Icons.star_rounded)), _divider(), Expanded(child: _ProfileMetric(value: '28', caption: 'Sesi selesai', icon: Icons.school_outlined)), _divider(), const Expanded(child: _ProfileMetric(value: '96%', caption: 'Kepuasan', icon: Icons.favorite_border_rounded))]),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil publik siap dibagikan.'))), icon: const Icon(Icons.ios_share_rounded, size: 17), label: const Text('Bagikan profil'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.tertiaryCaramel, side: const BorderSide(color: Color(0xFFE5D6C6)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))))),
    ])),
    const SizedBox(height: 20),
    const MentorSectionTitle('Keahlian'),
    const Wrap(spacing: 8, runSpacing: 8, children: [MentorTag('Flutter'), MentorTag('Laravel'), MentorTag('REST API'), MentorTag('Software Architecture')]),
    const SizedBox(height: 22),
    MentorSectionTitle('Ulasan murid', action: 'Lihat semua'),
    const _ReviewCard(initials: 'NP', name: 'Nadia Putri', date: '28 Okt 2026', text: 'Penjelasannya runtut dan mudah dipahami. Saya jadi lebih percaya diri menyusun struktur project Flutter.', rating: '5.0'),
    const SizedBox(height: 11),
    const _ReviewCard(initials: 'DA', name: 'Dimas Akbar', date: '24 Okt 2026', text: 'Sesi sangat membantu untuk memahami alur API dan autentikasi Laravel.', rating: '5.0'),
    const SizedBox(height: 21),
    const MentorSectionTitle('Tingkatkan profil'),
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF5EBDD), Color(0xFFE8D1B7)]), borderRadius: BorderRadius.circular(21)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFAD7839))), const SizedBox(width: 11), const Expanded(child: Text('Featured Mentor', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 15))), const MentorTag('Premium')]),
      const SizedBox(height: 12),
      const Text('Tampil lebih menonjol di pencarian, dapatkan kuota endorsement lebih besar, dan nikmati cash-out tanpa biaya admin.', style: TextStyle(color: AppColors.darkBrown, fontSize: 12, height: 1.45)),
      const SizedBox(height: 13),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket Featured Mentor akan segera tersedia.'))), child: const Text('Pelajari paket →', style: TextStyle(color: AppColors.tertiaryCaramel, fontWeight: FontWeight.w800)))),
    ])),
    const SizedBox(height: 20),
    const MentorSectionTitle('Tentang saya'),
    const MentorCard(child: Text('Membantu mahasiswa membangun fondasi software engineering, membuat aplikasi Flutter, dan menghubungkan frontend dengan REST API Laravel.', style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.55))),
  ]));

  Widget _divider() => Container(width: 1, height: 36, color: const Color(0xFFEDE6DE));
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.caption, required this.icon});
  final String value, caption;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, size: 16, color: const Color(0xFFD49B45)), const SizedBox(height: 5), Text(value, style: const TextStyle(color: AppColors.darkBrown, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(caption, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 10))]);
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.initials, required this.name, required this.date, required this.text, required this.rating});
  final String initials, name, date, text, rating;
  @override
  Widget build(BuildContext context) => MentorCard(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [MentorAvatar(initials: initials, size: 39), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 12)), const SizedBox(height: 3), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10))])), const Icon(Icons.star_rounded, color: Color(0xFFE6AE48), size: 17), const SizedBox(width: 3), Text(rating, style: const TextStyle(color: AppColors.darkBrown, fontSize: 12, fontWeight: FontWeight.w800))]), const SizedBox(height: 12), Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.45))]));
}
