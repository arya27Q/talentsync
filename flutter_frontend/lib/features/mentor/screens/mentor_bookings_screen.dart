import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorBookingsScreen extends StatefulWidget {
  const MentorBookingsScreen({super.key});

  @override
  State<MentorBookingsScreen> createState() => _MentorBookingsScreenState();
}

class _MentorBookingsScreenState extends State<MentorBookingsScreen> {
  int _filter = 0;
  final Map<String, String> _decisions = {};

  final _bookings = const [
    _Booking(name: 'Rizky Ramadhan', initials: 'RR', title: 'Konsultasi dasar Laravel API', date: 'Besok, 10.00–11.00', price: '3 TC', note: 'Saya ingin memahami struktur endpoint dan autentikasi Sanctum.'),
    _Booking(name: 'Siti Rahma', initials: 'SR', title: 'Review portofolio UI/UX', date: '2 Nov, 13.00–14.00', price: '4 TC', note: 'Mohon masukan untuk case study aplikasi mobile yang sedang saya susun.'),
    _Booking(name: 'Nadia Putri', initials: 'NP', title: 'Review UI Flutter', date: 'Hari ini, 14.00–15.00', price: '5 TC', note: 'Sesi sudah dikonfirmasi. Tautan meeting tersedia untuk peserta.'),
  ];

  void _decide(_Booking booking, String decision) {
    setState(() => _decisions[booking.name] = decision);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decision == 'accepted' ? 'Booking ${booking.name} dikonfirmasi.' : 'Permintaan booking ${booking.name} ditolak.')));
  }

  @override
  Widget build(BuildContext context) {
    final shown = _bookings.where((booking) {
      final status = _decisions[booking.name] ?? (booking.name == 'Nadia Putri' ? 'upcoming' : 'pending');
      return _filter == 0 ? status == 'pending' : _filter == 1 ? status == 'upcoming' || status == 'accepted' : status == 'completed';
    }).toList();
    return SafeArea(bottom: false, child: Column(children: [
      const MentorPageHeader(title: 'Kelola booking', subtitle: 'Atur permintaan dan jadwal sesi mentoring.'),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFEFE9E2), borderRadius: BorderRadius.circular(15)), child: Row(children: [
        _FilterButton(label: 'Permintaan', count: '2', selected: _filter == 0, onTap: () => setState(() => _filter = 0)),
        _FilterButton(label: 'Mendatang', selected: _filter == 1, onTap: () => setState(() => _filter = 1)),
        _FilterButton(label: 'Selesai', selected: _filter == 2, onTap: () => setState(() => _filter = 2)),
      ]))),
      const SizedBox(height: 14),
      Expanded(child: shown.isEmpty ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.event_available_outlined, color: Colors.brown.shade200, size: 48), const SizedBox(height: 10), Text('Belum ada sesi di kategori ini', style: TextStyle(color: Colors.grey.shade600))])) : ListView.separated(padding: const EdgeInsets.fromLTRB(22, 4, 22, 24), itemCount: shown.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (context, index) {
        final booking = shown[index];
        final status = _decisions[booking.name] ?? (booking.name == 'Nadia Putri' ? 'upcoming' : 'pending');
        return _BookingCard(booking: booking, status: status, onAccept: () => _decide(booking, 'accepted'), onDecline: () => _decide(booking, 'declined'));
      })),
    ]));
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.selected, required this.onTap, this.count});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? count;
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3), decoration: BoxDecoration(color: selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 6)] : null), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: selected ? AppColors.darkBrown : Colors.grey.shade600, fontWeight: FontWeight.w700))), if (count != null) ...[const SizedBox(width: 4), MentorTag(count!, color: const Color(0xFFF5E4D5), textColor: AppColors.tertiaryCaramel)]]))));
}

class _Booking {
  const _Booking({required this.name, required this.initials, required this.title, required this.date, required this.price, required this.note});
  final String name, initials, title, date, price, note;
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.status, required this.onAccept, required this.onDecline});
  final _Booking booking;
  final String status;
  final VoidCallback onAccept, onDecline;

  @override
  Widget build(BuildContext context) => MentorCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [MentorAvatar(initials: booking.initials), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.name, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(booking.title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))])), MentorTag(status == 'pending' ? 'Menunggu' : status == 'declined' ? 'Ditolak' : 'Terkonfirmasi', color: status == 'pending' ? const Color(0xFFFFF4E5) : status == 'declined' ? const Color(0xFFFCE8E6) : const Color(0xFFEAF4ED), textColor: status == 'pending' ? const Color(0xFFB77727) : status == 'declined' ? const Color(0xFFB74C45) : const Color(0xFF38845B))]),
    const SizedBox(height: 16),
    Row(children: [const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.tertiaryCaramel), const SizedBox(width: 7), Text(booking.date, style: const TextStyle(color: AppColors.darkBrown, fontSize: 12, fontWeight: FontWeight.w600)), const Spacer(), const Icon(Icons.toll_rounded, size: 15, color: Color(0xFFD99B3E)), const SizedBox(width: 5), Text(booking.price, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 12))]),
    const SizedBox(height: 13),
    Text(booking.note, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.45)),
    if (status == 'pending') ...[
      const SizedBox(height: 16),
      Row(children: [Expanded(child: OutlinedButton(onPressed: onDecline, style: OutlinedButton.styleFrom(foregroundColor: AppColors.darkBrown, side: BorderSide(color: Colors.brown.shade100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: const Text('Tolak'))), const SizedBox(width: 10), Expanded(child: ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: AppColors.tertiaryCaramel, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: const Text('Konfirmasi')))]),
    ] else if (status == 'upcoming' || status == 'accepted') ...[
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tautan sesi akan tersedia mendekati jadwal.'))), icon: const Icon(Icons.video_call_outlined), label: const Text('Buka ruang sesi'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.tertiaryCaramel, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))))),
    ],
  ]));
}
