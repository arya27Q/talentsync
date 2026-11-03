import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_booking.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_live_mentoring_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_student_learning_room_screen.dart';
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
  bool get isCompleted => args.status == 'completed';

  void _finish(BuildContext context, String decision) {
    Navigator.pop(context, decision);
  }

  Color get _avatarBgColor {
    final initials = booking.student.initials;
    if (initials == 'RH') {
      return const Color(0xFFA03B1E); // Terracotta / Rust brown
    } else if (initials == 'DL') {
      return const Color(0xFF0F766E); // Deep Teal
    }
    return AppColors.primaryNavy; // Deep Royal Navy
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Custom Clean Header matching screenshot
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Kembali',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
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
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Booking Detail',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'Chat dengan ${booking.student.name}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.mentorStudentChat,
                      arguments: booking.student,
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
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
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.darkSlate,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 140),
              children: [
                // Card 1: Student Profile & Metrics
                Container(
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
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
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
                          const SizedBox(width: 14),
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
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  booking.student.study,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.secondarySlate,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.accentAmberGold,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (booking.rating ?? 4.7).toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: AppColors.darkSlate,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1,
                                      height: 14,
                                      color: AppColors.borderSlate,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${booking.completedProjects ?? 2} proyek UMKM',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.darkSlate,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3 Metric Boxes (Kam, 26 Jun | 19.00 · 60 mnt | 30 TC escrow)
                      Row(
                        children: [
                          Expanded(
                            child: _MetricBox(
                              icon: Icons.calendar_today_outlined,
                              iconColor: AppColors.primaryNavy,
                              line1: booking.date,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricBox(
                              icon: Icons.access_time_rounded,
                              iconColor: AppColors.primaryNavy,
                              line1: booking.time.isNotEmpty
                                  ? '${booking.time} · ${booking.durationMinutes}'
                                  : '${booking.durationMinutes} mnt',
                              line2: 'mnt',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricBox(
                              icon: Icons.toll_rounded,
                              iconColor: AppColors.accentAmberGold,
                              line1: '${booking.price} TC escrow',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card 2: Topik, Pesan Murid, Target Sesi, Repository
                Container(
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
                      const _DetailSectionLabel('TOPIK'),
                      const SizedBox(height: 6),
                      Text(
                        booking.topic,
                        style: const TextStyle(
                          color: AppColors.darkSlate,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),

                      const _DetailSectionLabel('PESAN MURID'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          booking.message.isEmpty
                              ? 'Murid belum menambahkan pesan untuk sesi ini.'
                              : booking.message,
                          style: const TextStyle(
                            color: AppColors.darkSlate,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const _DetailSectionLabel('TARGET SESI'),
                      const SizedBox(height: 10),
                      if (booking.sessionGoals.isEmpty)
                        const Text(
                          'Target sesi belum ditambahkan.',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 13,
                          ),
                        )
                      else
                        ...booking.sessionGoals.map(
                          (goal) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.adjust_rounded,
                                  color: AppColors.primaryNavy,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    goal,
                                    style: const TextStyle(
                                      color: AppColors.darkSlate,
                                      fontSize: 13.5,
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
                        Semantics(
                          button: true,
                          label: 'Salin tautan GitHub ${booking.repositoryUrl}',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
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
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderSlate),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.link_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 20,
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
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    color: AppColors.secondarySlate,
                                    size: 18,
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
                const SizedBox(height: 14),

                // Card 3: Escrow Notice Card matching screenshot
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDCEAFE),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.primaryNavy,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '30 TC sudah ditahan di escrow. Dana masuk ke dompetmu setelah sesi selesai dan murid mengonfirmasi.',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 12,
                            height: 1.45,
                          ),
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

    // Fixed Bottom Action Bar & Navigation
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: AppColors.canvasWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Tolak permintaan booking',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _finish(context, 'declined'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Semantics(
                      button: true,
                      label: 'Terima dan jadwalkan sesi',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _finish(context, 'accepted'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryNavy.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Accept & Schedule',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.calendar_month_outlined,
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
            )
          else if (isAccepted)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Tandai sesi selesai',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _finish(context, 'completed'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Tandai selesai',
                            style: TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Semantics(
                      button: true,
                      label: 'Buka ruang virtual',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mentorLiveMentoring,
                          arguments: MentorLiveMentoringArgs(
                            student: booking.student,
                            meetingUrl: booking.meetingUrl,
                            onSelectTab: args.onSelectTab,
                          ),
                        ),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primaryNavy.withValues(alpha: 0.25),
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
            )
          else if (isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Semantics(
                button: true,
                label: 'Buka ruang belajar murid',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.mentorStudentLearningRoom,
                    arguments: MentorStudentLearningRoomArgs(
                      student: booking.student,
                      onSelectTab: args.onSelectTab,
                    ),
                  ),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Ruang Belajar Murid',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
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
    ),
  );
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.icon,
    required this.iconColor,
    required this.line1,
    this.line2,
  });

  final IconData icon;
  final Color iconColor;
  final String line1;
  final String? line2;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 7),
        Text(
          line1,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        if (line2 != null)
          Text(
            line2!,
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

class _DetailSectionLabel extends StatelessWidget {
  const _DetailSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.secondarySlate,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}
