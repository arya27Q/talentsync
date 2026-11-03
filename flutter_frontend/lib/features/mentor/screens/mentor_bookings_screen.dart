import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_booking.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_booking_detail_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorBookingsScreen extends StatefulWidget {
  const MentorBookingsScreen({
    super.key,
    this.onOpenServices,
    this.onSelectTab,
  });

  final VoidCallback? onOpenServices;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorBookingsScreen> createState() => _MentorBookingsScreenState();
}

class _MentorBookingsScreenState extends State<MentorBookingsScreen> {
  int _filter = 0;
  final Map<String, String> _decisions = {};

  String _status(MentorBooking booking) =>
      _decisions[booking.student.name] ?? 'pending';

  List<MentorBooking> get _visibleBookings =>
      mentorBookingRequests.where((booking) {
        final status = _status(booking);
        if (_filter == 0) return status == 'pending';
        if (_filter == 1) return status == 'accepted';
        return status == 'completed';
      }).toList();

  Future<void> _openBooking(MentorBooking booking) async {
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.mentorBookingDetail,
      arguments: MentorBookingDetailArgs(
        booking: booking,
        status: _status(booking),
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (!mounted) return;
    if (result is String) {
      setState(() => _decisions[booking.student.name] = result);
      final notice = switch (result) {
        'accepted' => 'Booking ${booking.student.name} dikonfirmasi.',
        'declined' => 'Permintaan booking ${booking.student.name} ditolak.',
        'completed' => 'Sesi dengan ${booking.student.name} ditandai selesai.',
        _ => null,
      };
      if (notice != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(notice)));
      }
    } else if (result is int) {
      widget.onSelectTab?.call(result);
    }
  }

  int _countFor(String status) => mentorBookingRequests
      .where((booking) => _status(booking) == status)
      .length;

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
                    count: _countFor('pending'),
                    selected: _filter == 0,
                    onTap: () => setState(() => _filter = 0),
                  ),
                  _FilterButton(
                    label: 'Terjadwal',
                    count: _countFor('accepted'),
                    selected: _filter == 1,
                    onTap: () => setState(() => _filter = 1),
                  ),
                  _FilterButton(
                    label: 'Selesai',
                    count: _countFor('completed'),
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
                          _filter == 0
                              ? 'Belum ada permintaan booking.'
                              : _filter == 1
                              ? 'Belum ada sesi terjadwal.'
                              : 'Belum ada sesi selesai.',
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
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final status = _status(booking);
                      return _BookingCard(
                        booking: booking,
                        status: status,
                        onMessage: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mentorStudentChat,
                          arguments: booking.student,
                        ),
                        onOpen: () => _openBooking(booking),
                      );
                    },
                  ),
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
  final int count;
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.status,
    required this.onMessage,
    required this.onOpen,
  });

  final MentorBooking booking;
  final String status;
  final VoidCallback onMessage;
  final VoidCallback onOpen;

  Color get _avatarColor => booking.student.initials == 'RH'
      ? const Color(0xFFAA3D17)
      : const Color(0xFF147D76);

  @override
  Widget build(BuildContext context) => MentorCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MentorAvatar(
              initials: booking.student.initials,
              size: 54,
              color: _avatarColor,
              textColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.student.name,
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
                    booking.student.study,
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
            const Icon(
              Icons.circle,
              size: 12,
              color: AppColors.accentAmberDeep,
            ),
            const SizedBox(width: 5),
            Text(
              '${booking.price} TC',
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
                booking.topic,
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
                      '${booking.date} · ${booking.time} · ${booking.durationMinutes} menit',
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
                  semanticLabel: 'Kirim pesan kepada ${booking.student.name}',
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
                    status == 'pending'
                        ? 'Lihat Permintaan'
                        : status == 'accepted'
                        ? 'Lihat Jadwal'
                        : 'Detail Sesi',
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
