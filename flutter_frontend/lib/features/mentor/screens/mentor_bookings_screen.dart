import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_booking.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_booking_detail_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_live_mentoring_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_student_learning_room_screen.dart';
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
  int _filter = 0; // 0: Permintaan, 1: Terjadwal, 2: Selesai

  late List<MentorBooking> _pendingBookings;
  late List<MentorBooking> _scheduledBookings;
  late List<MentorBooking> _completedBookings;

  @override
  void initState() {
    super.initState();
    _pendingBookings = List.from(mentorBookingRequests);
    _scheduledBookings = List.from(mentorScheduledBookings);
    _completedBookings = List.from(mentorCompletedBookings);
  }

  List<MentorBooking> get _currentBookings {
    switch (_filter) {
      case 0:
        return _pendingBookings;
      case 1:
        return _scheduledBookings;
      case 2:
        return _completedBookings;
      default:
        return _pendingBookings;
    }
  }

  Future<void> _openBooking(MentorBooking booking) async {
    final result = await Navigator.pushNamed<Object?>(
      context,
      AppRoutes.mentorBookingDetail,
      arguments: MentorBookingDetailArgs(
        booking: booking,
        status: booking.status,
        onSelectTab: widget.onSelectTab,
      ),
    );
    if (!mounted) return;

    if (result is String) {
      setState(() {
        if (result == 'accepted') {
          _pendingBookings.removeWhere(
            (b) => b.student.name == booking.student.name,
          );
          _scheduledBookings.insert(
            0,
            MentorBooking(
              student: booking.student,
              topic: booking.topic,
              date: booking.date,
              time: booking.time,
              durationMinutes: booking.durationMinutes,
              price: booking.price,
              meetingUrl: 'meet.google.com/tsy-${booking.student.initials.toLowerCase()}-101',
              status: 'accepted',
            ),
          );
        } else if (result == 'declined') {
          _pendingBookings.removeWhere(
            (b) => b.student.name == booking.student.name,
          );
        } else if (result == 'completed') {
          _scheduledBookings.removeWhere(
            (b) => b.student.name == booking.student.name,
          );
          _completedBookings.insert(
            0,
            MentorBooking(
              student: booking.student,
              topic: booking.topic,
              date: booking.date,
              durationMinutes: booking.durationMinutes,
              price: booking.price,
              score: 'Nilai 85/100',
              status: 'completed',
            ),
          );
        }
      });

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

  void _openLiveMentoring(MentorBooking booking) {
    Navigator.pushNamed(
      context,
      AppRoutes.mentorLiveMentoring,
      arguments: MentorLiveMentoringArgs(
        student: booking.student,
        meetingUrl: booking.meetingUrl != null
            ? 'https://${booking.meetingUrl}'
            : 'https://meet.google.com/tsy-arya-019',
        onSelectTab: widget.onSelectTab,
      ),
    );
  }

  void _openStudentLearningRoom(MentorBooking booking) {
    Navigator.pushNamed(
      context,
      AppRoutes.mentorStudentLearningRoom,
      arguments: MentorStudentLearningRoomArgs(
        student: booking.student,
        onSelectTab: widget.onSelectTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _currentBookings;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header: Manage Bookings & + action button
          MentorPageHeader(
            title: 'Manage Bookings',
            subtitle: '2 layanan aktif',
            trailing: GestureDetector(
              onTap: widget.onOpenServices,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSlate),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkSlate.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.darkSlate,
                  size: 26,
                ),
              ),
            ),
          ),

          // Segmented Tabs: Permintaan (2), Terjadwal (2), Selesai (2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                children: [
                  _FilterTabButton(
                    label: 'Permintaan',
                    count: _pendingBookings.length,
                    selected: _filter == 0,
                    onTap: () => setState(() => _filter = 0),
                  ),
                  _FilterTabButton(
                    label: 'Terjadwal',
                    count: _scheduledBookings.length,
                    selected: _filter == 1,
                    onTap: () => setState(() => _filter = 1),
                  ),
                  _FilterTabButton(
                    label: 'Selesai',
                    count: _completedBookings.length,
                    selected: _filter == 2,
                    onTap: () => setState(() => _filter = 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Booking List with Scroll Padding for Bottom Navigation Bar
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
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(
                        booking: booking,
                        filterIndex: _filter,
                        onMessage: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mentorStudentChat,
                          arguments: booking.student,
                        ),
                        onOpen: () => _openBooking(booking),
                        onJoinLive: () => _openLiveMentoring(booking),
                        onOpenLearningRoom: () =>
                            _openStudentLearningRoom(booking),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabButton extends StatelessWidget {
  const _FilterTabButton({
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
      button: true,
      selected: selected,
      label: '$label $count item',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$label ($count)',
              maxLines: 1,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.secondarySlate,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.filterIndex,
    required this.onMessage,
    required this.onOpen,
    required this.onJoinLive,
    required this.onOpenLearningRoom,
  });

  final MentorBooking booking;
  final int filterIndex; // 0: Permintaan, 1: Terjadwal, 2: Selesai
  final VoidCallback onMessage;
  final VoidCallback onOpen;
  final VoidCallback onJoinLive;
  final VoidCallback onOpenLearningRoom;

  Color get _avatarBgColor {
    final initials = booking.student.initials;
    if (initials == 'RH') {
      return const Color(0xFFA03B1E); // Terracotta/Rust brown
    } else if (initials == 'DL') {
      return const Color(0xFF0F766E); // Deep Teal
    }
    return AppColors.primaryNavy; // Deep Royal Navy for AP / others
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: AppColors.borderSlate.withValues(alpha: 0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header: Avatar + Student info + 30 TC
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _avatarBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                booking.student.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
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
                      fontSize: 15.5,
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
              Icons.toll_rounded,
              size: 16,
              color: AppColors.accentAmberGold,
            ),
            const SizedBox(width: 5),
            Text(
              '${booking.price} TC',
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Topic & Schedule Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
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
                    size: 14,
                    color: AppColors.secondarySlate,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.time.isNotEmpty
                          ? '${booking.date} · ${booking.time} · ${booking.durationMinutes} menit'
                          : '${booking.date} · ${booking.durationMinutes} menit',
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

        // Meeting URL (for Terjadwal tab)
        if (filterIndex == 1 && booking.meetingUrl != null) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 16,
                  color: AppColors.primaryNavy,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.meetingUrl!,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 13),

        // Bottom Actions per tab
        if (filterIndex == 0) ...[
          // Tab 0: Permintaan (Chat button + Lihat Permintaan ➔)
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Kirim pesan kepada ${booking.student.name}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onMessage,
                  child: Container(
                    width: 50,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.darkSlate,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Lihat Permintaan',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: onOpen,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Lihat Permintaan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else if (filterIndex == 1) ...[
          // Tab 1: Terjadwal (Chat button + Join Virtual Workspace 📹)
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Kirim pesan kepada ${booking.student.name}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onMessage,
                  child: Container(
                    width: 50,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.darkSlate,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Join Virtual Workspace',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: onJoinLive,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Join Virtual Workspace',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.videocam_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Tab 2: Selesai (Nilai pill badge + Ruang belajar murid >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.score ?? 'Nilai 88/100',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Buka ruang belajar murid ${booking.student.name}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onOpenLearningRoom,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Ruang belajar murid',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.primaryNavy,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
