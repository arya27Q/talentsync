import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorBookingsScreen extends StatefulWidget {
  const MentorBookingsScreen({super.key, this.onOpenServices});

  final VoidCallback? onOpenServices;

  @override
  State<MentorBookingsScreen> createState() => _MentorBookingsScreenState();
}

class _MentorBookingsScreenState extends State<MentorBookingsScreen> {
  int _filter = 0;
  final Map<String, String> _decisions = {};
  final _bookings = const [
    _Booking(
      name: 'Dewi Lestari',
      initials: 'DL',
      study: 'Informatika · ITS',
      title: 'Review arsitektur aplikasi antrean',
      date: 'Kam, 26 Jun · 19.00 · 60 menit',
      price: '30 TC',
      color: Color(0xFF147D76),
    ),
    _Booking(
      name: 'Rafi Hakim',
      initials: 'RH',
      study: 'Sistem Informasi · UNAIR',
      title: 'Migrasi React Native ke Flutter',
      date: 'Jum, 27 Jun · 16.00 · 60 menit',
      price: '30 TC',
      color: Color(0xFFAA3D17),
    ),
  ];

  String _status(_Booking booking) => _decisions[booking.name] ?? 'pending';

  void _decide(_Booking booking, String status) {
    setState(() => _decisions[booking.name] = status);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'accepted'
              ? 'Booking ${booking.name} dikonfirmasi.'
              : 'Permintaan booking ${booking.name} ditolak.',
        ),
      ),
    );
  }

  void _complete(_Booking booking) {
    setState(() => _decisions[booking.name] = 'completed');
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sesi dengan ${booking.name} ditandai selesai.')),
    );
  }

  List<_Booking> get _visibleBookings => _bookings.where((booking) {
    final status = _status(booking);
    if (_filter == 0) return status == 'pending';
    if (_filter == 1) return status == 'accepted';
    return status == 'completed';
  }).toList();

  @override
  Widget build(BuildContext context) {
    final bookings = _visibleBookings;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          MentorPageHeader(
            title: 'Manage Bookings',
            subtitle: '2 layanan aktif',
            trailing: IconButton(
              tooltip: 'Tambah layanan',
              onPressed: widget.onOpenServices,
              icon: const Icon(
                Icons.add_rounded,
                color: AppColors.darkSlate,
                size: 28,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(48, 48),
                side: const BorderSide(color: AppColors.borderSlate),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                children: [
                  _FilterButton(
                    label: 'Permintaan',
                    count:
                        '${_bookings.where((b) => _status(b) == 'pending').length}',
                    selected: _filter == 0,
                    onTap: () => setState(() => _filter = 0),
                  ),
                  _FilterButton(
                    label: 'Terjadwal',
                    count:
                        '${_bookings.where((b) => _status(b) == 'accepted').length}',
                    selected: _filter == 1,
                    onTap: () => setState(() => _filter = 1),
                  ),
                  _FilterButton(
                    label: 'Selesai',
                    count:
                        '${_bookings.where((b) => _status(b) == 'completed').length}',
                    selected: _filter == 2,
                    onTap: () => setState(() => _filter = 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_available_outlined,
                          color: AppColors.secondarySlate,
                          size: 42,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _filter == 2
                              ? 'Belum ada sesi selesai.'
                              : 'Tidak ada booking di tab ini.',
                          style: const TextStyle(
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => _BookingCard(
                      booking: bookings[index],
                      status: _status(bookings[index]),
                      onMessage: () =>
                          Navigator.pushNamed(context, AppRoutes.inbox),
                      onOpen: () => _showBooking(bookings[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showBooking(_Booking booking) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          booking.name,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.study,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 18),
            Text(
              booking.title,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              booking.date,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 8),
            Text(
              '${booking.price} · 1-on-1',
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          if (_status(booking) == 'pending') ...[
            TextButton(
              onPressed: () => _decide(booking, 'declined'),
              child: const Text('Tolak'),
            ),
            FilledButton(
              onPressed: () => _decide(booking, 'accepted'),
              child: const Text('Terima booking'),
            ),
          ],
          if (_status(booking) == 'accepted')
            FilledButton(
              onPressed: () => _complete(booking),
              child: const Text('Tandai selesai'),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      selected: selected,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: selected
              ? AppColors.primaryNavy
              : Colors.transparent,
          foregroundColor: selected ? Colors.white : AppColors.secondarySlate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$label ($count)',
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ),
  );
}

class _Booking {
  const _Booking({
    required this.name,
    required this.initials,
    required this.study,
    required this.title,
    required this.date,
    required this.price,
    required this.color,
  });
  final String name, initials, study, title, date, price;
  final Color color;
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.status,
    required this.onMessage,
    required this.onOpen,
  });
  final _Booking booking;
  final String status;
  final VoidCallback onMessage;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => MentorCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MentorAvatar(
              initials: booking.initials,
              size: 54,
              color: booking.color,
              textColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    booking.study,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.circle, size: 12, color: AppColors.primaryNavy),
            const SizedBox(width: 5),
            Text(
              booking.price,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.canvasWhite,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: AppColors.secondarySlate,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      booking.date,
                      style: const TextStyle(
                        color: AppColors.secondarySlate,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            SizedBox(
              width: 52,
              height: 48,
              child: OutlinedButton(
                onPressed: onMessage,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.darkSlate,
                  side: const BorderSide(color: AppColors.borderSlate),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  semanticLabel: 'Kirim pesan kepada ${booking.name}',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: onOpen,
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    status == 'pending'
                        ? Icons.arrow_forward_rounded
                        : Icons.video_call_outlined,
                  ),
                  label: Text(
                    status == 'pending' ? 'Lihat Permintaan' : 'Lihat Jadwal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
