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
  final List<Widget?> _builtPages = List<Widget?>.filled(6, null);
  late final TextTheme _mentorTextTheme = Typography.material2021().black.apply(
    bodyColor: AppColors.darkSlate,
    displayColor: AppColors.darkSlate,
  );

  Widget _buildPage(int index) {
    return switch (index) {
      0 => MentorDashboardScreen(
          availableTc: _availableTc,
          onOpenWallet: () => _selectTab(3),
          onOpenBookings: () => _selectTab(1),
          onOpenServices: _openServices,
          onOpenProfile: () => _selectTab(4),
          onOpenStudents: () => _selectTab(2),
          onOpenLiveSession: _openLiveSession,
        ),
      1 => MentorBookingsScreen(
          onOpenServices: _openServices,
          onSelectTab: _selectTab,
        ),
      2 => MentorStudentsScreen(onSelectTab: _selectTab),
      3 => MentorWalletScreen(availableTc: _availableTc, onSelectTab: _selectTab),
      4 => MentorProfileScreen(availableTc: _availableTc, onSelectTab: _selectTab),
      5 => MentorServicesScreen(key: _servicesKey),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _pageFor(int index) => _builtPages[index] ??= _buildPage(index);

  @override
  void initState() {
    super.initState();
    _builtPages[0] = _buildPage(0);
  }

  void _selectTab(int index) {
    setState(() {
      _index = index;
      _pageFor(index);
    });
  }

  @override
  void dispose() {
    _availableTc.dispose();
    super.dispose();
  }

  void _openServices() {
    setState(() {
      _index = 5;
      _pageFor(5);
    });
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        // Font bawaan Flutter Material Typography resmi (gaya ke-2 yang elegan & presisi)
        textTheme: _mentorTextTheme,
      ),
      child: Scaffold(
        backgroundColor: AppColors.canvasWhite,
        body: IndexedStack(
          index: _index,
          children: List<Widget>.generate(
            _builtPages.length,
            (i) => _builtPages[i] ?? const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: MentorBottomNav(
          selectedIndex: _index,
          onSelected: _selectTab,
        ),
      ),
    );
  }
}
