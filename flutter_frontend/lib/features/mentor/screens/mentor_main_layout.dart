import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_booking.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_bookings_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_dashboard_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_live_mentoring_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_profile_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_services_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_students_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_wallet_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorMainLayout extends StatefulWidget {
  const MentorMainLayout({super.key});

  @override
  State<MentorMainLayout> createState() => _MentorMainLayoutState();
}

class _MentorMainLayoutState extends State<MentorMainLayout> {
  int _index = 0;
  final _availableTc = ValueNotifier<int>(0);
  final _mentorApi = MentorApi.instance;
  final _servicesKey = GlobalKey<MentorServicesScreenState>();

  late final List<Widget> _pages = [
    MentorDashboardScreen(
      onOpenWallet: () => _selectTab(3),
      onOpenBookings: () => _selectTab(1),
      onOpenServices: _openServices,
      onOpenProfile: () => _selectTab(4),
      onOpenStudents: () => _selectTab(2),
      onOpenLiveSession: _openLiveSession,
    ),
    MentorBookingsScreen(
      onOpenServices: _openServices,
      onSelectTab: _selectTab,
    ),
    MentorStudentsScreen(onSelectTab: _selectTab),
    MentorWalletScreen(availableTc: _availableTc, onSelectTab: _selectTab),
    MentorProfileScreen(availableTc: _availableTc, onSelectTab: _selectTab),
    MentorServicesScreen(key: _servicesKey),
  ];

  @override
  void initState() {
    super.initState();
    _refreshWalletBalance();
  }

  Future<void> _refreshWalletBalance() async {
    try {
      final wallet = await _mentorApi.walletSummary();
      if (mounted) _availableTc.value = wallet['balance_tc'] as int? ?? 0;
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  void _selectTab(int index) => setState(() => _index = index);

  @override
  void dispose() {
    _availableTc.dispose();
    super.dispose();
  }

  void _openServices() {
    setState(() => _index = 5);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _servicesKey.currentState?.startCreating(),
    );
  }

  Future<void> _openLiveSession() async {
    try {
      final rows = await _mentorApi.enrollments();
      final upcoming = rows
          .where((item) => item['status'] == 'accepted')
          .toList();
      final next = upcoming.isEmpty ? null : upcoming.first;
      if (next == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada sesi terjadwal.')),
          );
        }
        return;
      }
      final booking = MentorBooking.fromEnrollment(next);
      if (booking.meetingUrl == null || booking.meetingUrl!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tautan Meet belum ditambahkan pada sesi ini.'),
            ),
          );
        }
        return;
      }
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.mentorLiveMentoring,
        arguments: MentorLiveMentoringArgs(
          student: booking.student,
          meetingUrl: booking.meetingUrl,
          onSelectTab: _selectTab,
        ),
      );
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        // Font bawaan Flutter Material Typography resmi (gaya ke-2 yang elegan & presisi)
        textTheme: Typography.material2021().black.apply(
          bodyColor: AppColors.darkSlate,
          displayColor: AppColors.darkSlate,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.canvasWhite,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: MentorBottomNav(
          selectedIndex: _index,
          onSelected: _selectTab,
        ),
      ),
    );
  }
}
