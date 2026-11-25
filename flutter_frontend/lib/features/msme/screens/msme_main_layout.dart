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
  int _dashboardVersion = 0;
  int _postingsVersion = 0;
  int _barterVersion = 0;
  int _profileVersion = 0;

  void _selectTab(int index) {
    setState(() {
      if (index != _currentIndex) {
        if (index == 0) _dashboardVersion++;
        if (index == 2) _barterVersion++;
        if (index == 3) _profileVersion++;
      }
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
            setState(() {
              _dashboardVersion++;
              _postingsVersion++;
              _currentIndex = 1; // Langsung arahkan ke Postingan tugas
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MsmeDashboardScreen(
        key: ValueKey('dash_$_dashboardVersion'),
        onCreateProject: _openCreateTaskWizard,
        onOpenPostings: () => _selectTab(1),
        onOpenBarter: () => _selectTab(2),
        onOpenProfile: () => _selectTab(3),
      ),
      MsmePostingsScreen(
        key: ValueKey('post_$_postingsVersion'),
        onCreatePosting: _openCreateTaskWizard,
      ),
      MsmeBarterScreen(
        key: ValueKey('barter_$_barterVersion'),
        onBalanceChanged: () {
          setState(() {
            _dashboardVersion++;
            _profileVersion++;
          });
        },
      ),
      MsmeStoreProfileScreen(key: ValueKey('profile_$_profileVersion')),
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
