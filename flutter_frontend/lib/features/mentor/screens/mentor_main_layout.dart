import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/models/mentor_student.dart';
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
  final _availableTc = ValueNotifier<int>(420);
  final _servicesKey = GlobalKey<MentorServicesScreenState>();

  late final List<Widget> _pages = [
    MentorDashboardScreen(
      onOpenWallet: () => _selectTab(3),
      onOpenBookings: () => _selectTab(1),
      onOpenServices: _openServices,
      onOpenProfile: () => _selectTab(4),
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

  void _openLiveSession() {
    Navigator.pushNamed(
      context,
      AppRoutes.mentorLiveMentoring,
      arguments: MentorLiveMentoringArgs(
        student: mentorStudentArya,
        meetingUrl: 'https://meet.google.com/tsy-arya-019',
        onSelectTab: _selectTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: IndexedStack(index: _index, children: _pages),
    bottomNavigationBar: MentorBottomNav(
      selectedIndex: _index,
      onSelected: _selectTab,
    ),
  );
}
