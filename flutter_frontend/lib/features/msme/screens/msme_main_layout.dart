import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/msme/screens/msme_barter_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_create_task_wizard_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_dashboard_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_postings_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_store_profile_screen.dart';
import 'package:flutter_frontend/features/msme/widgets/msme_bottom_nav.dart';

class MsmeMainLayout extends StatefulWidget {
  const MsmeMainLayout({super.key});

  @override
  State<MsmeMainLayout> createState() => _MsmeMainLayoutState();
}

class _MsmeMainLayoutState extends State<MsmeMainLayout> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCreateTaskWizard() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MsmeCreateTaskWizardScreen(
          onCompleted: () {
            Navigator.pop(context);
            _selectTab(1); // Go to Postingan tab
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MsmeDashboardScreen(
        onCreateProject: _openCreateTaskWizard,
        onOpenPostings: () => _selectTab(1),
        onOpenBarter: () => _selectTab(2),
        onOpenProfile: () => _selectTab(3),
      ),
      MsmePostingsScreen(onCreatePosting: _openCreateTaskWizard),
      const MsmeBarterScreen(),
      const MsmeStoreProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: MsmeBottomNav(
        selectedIndex: _currentIndex,
        onSelected: _selectTab,
      ),
    );
  }
}
