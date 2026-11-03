import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_booking.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_live_mentoring_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorBookingDetailArgs {
  const MentorBookingDetailArgs({
    required this.booking,
    required this.status,
    this.onSelectTab,
  });

  final MentorBooking booking;
  final String status;
  final ValueChanged<int>? onSelectTab;
}

class MentorBookingDetailScreen extends StatelessWidget {
  const MentorBookingDetailScreen({super.key, required this.args});

  final MentorBookingDetailArgs args;

  MentorBooking get booking => args.booking;
  bool get isPending => args.status == 'pending';
  bool get isAccepted => args.status == 'accepted';

  void _finish(BuildContext context, String decision) {
    Navigator.pop(context, decision);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        'Booking Detail',
        style: TextStyle(
          color: AppColors.darkSlate,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkSlate,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Chat dengan ${booking.student.name}',
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.mentorStudentChat,
            arguments: booking.student,
          ),
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          MentorCard(
            child: Column(
              children: [
                Row(
                  children: [
                    MentorAvatar(
                      initials: booking.student.initials,
                      size: 54,
                      color: const Color(0xFF147D76),
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.student.name,
                            style: const TextStyle(
                              color: AppColors.darkSlate,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            booking.student.study,
                            style: const TextStyle(
                              color: AppColors.secondarySlate,
                              fontSize: 13,
                            ),
                          ),
                          if (booking.rating != null ||
                              booking.completedProjects != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (booking.rating != null) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.accentAmberDeep,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.darkSlate,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                if (booking.rating != null &&
                                    booking.completedProjects != null) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 1,
                                    height: 18,
                                    color: AppColors.borderSlate,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (booking.completedProjects != null)
                                  Flexible(
                                    child: Text(
                                      '${booking.completedProjects} proyek UMKM',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.darkSlate,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _BookingMetric(
                        icon: Icons.calendar_month_outlined,
                        value: booking.date,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BookingMetric(
                        icon: Icons.schedule_rounded,
                        value:
                            '${booking.time} · ${booking.durationMinutes} mnt',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BookingMetric(
                        icon: Icons.circle,
                        iconColor: AppColors.accentAmberGold,
                        value: '${booking.price} TC escrow',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MentorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DetailLabel('TOPIK'),
                const SizedBox(height: 6),
                Text(
                  booking.topic,
                  style: const TextStyle(
                    color: AppColors.darkSlate,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 20),
                const _DetailLabel('PESAN MURID'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.canvasWhite,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    booking.message.isEmpty
                        ? 'Murid belum menambahkan pesan untuk sesi ini.'
                        : booking.message,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _DetailLabel('TARGET SESI'),
                const SizedBox(height: 8),
                if (booking.sessionGoals.isEmpty)
                  const Text(
                    'Target sesi belum ditambahkan.',
                    style: TextStyle(color: AppColors.secondarySlate),
                  )
                else
                  ...booking.sessionGoals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.radio_button_checked_rounded,
                            color: AppColors.primaryNavy,
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              goal,
                              style: const TextStyle(
                                color: AppColors.darkSlate,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (booking.repositoryUrl != null) ...[
                  const SizedBox(height: 14),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: 'https://${booking.repositoryUrl}',
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tautan GitHub disalin.'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              color: AppColors.primaryNavy,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                booking.repositoryUrl!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.darkSlate,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              color: AppColors.secondarySlate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isAccepted)
            MentorCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_outlined,
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${booking.date} · ${booking.time}',
                      style: const TextStyle(
                        color: AppColors.darkSlate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const MentorTag(
                    'Terjadwal',
                    color: AppColors.lightBlueSurface,
                    textColor: AppColors.primaryNavy,
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isPending)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _finish(context, 'declined'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkSlate,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderSlate),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => _finish(context, 'accepted'),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.event_available_rounded),
                      label: const Text(
                        'Accept & Schedule',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (isAccepted)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _finish(context, 'completed'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkSlate,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.borderSlate),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text('Tandai selesai'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.mentorLiveMentoring,
                        arguments: MentorLiveMentoringArgs(
                          student: booking.student,
                          meetingUrl: booking.meetingUrl,
                          onSelectTab: args.onSelectTab,
                        ),
                      ),
                      icon: const Icon(Icons.videocam_outlined),
                      label: Text(
                        booking.meetingUrl == null ? 'Buka sesi' : 'Join GMeet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        MentorBottomNav(
          selectedIndex: 1,
          onSelected: (index) {
            if (args.onSelectTab == null) {
              Navigator.pop(context, index);
              return;
            }
            args.onSelectTab!(index);
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    ),
  );
}

class _BookingMetric extends StatelessWidget {
  const _BookingMetric({
    required this.icon,
    required this.value,
    this.iconColor = AppColors.primaryNavy,
  });

  final IconData icon;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 80),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.canvasWhite,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 9),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _DetailLabel extends StatelessWidget {
  const _DetailLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.secondarySlate,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );
}
