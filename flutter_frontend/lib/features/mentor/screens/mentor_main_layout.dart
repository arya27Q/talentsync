import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_bookings_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_dashboard_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_profile_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_services_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_wallet_screen.dart';

class MentorMainLayout extends StatefulWidget {
  const MentorMainLayout({super.key});

  @override
  State<MentorMainLayout> createState() => _MentorMainLayoutState();
}

class _MentorMainLayoutState extends State<MentorMainLayout> {
  int _index = 0;
  final _servicesKey = GlobalKey<MentorServicesScreenState>();

  late final List<Widget> _pages = [
    MentorDashboardScreen(
      onOpenWallet: _openWallet,
      onOpenBookings: _openBookings,
      onOpenServices: _openServices,
      onOpenProfile: _openProfile,
    ),
    MentorBookingsScreen(onOpenServices: _openServices),
    MentorServicesScreen(key: _servicesKey),
    const MentorWalletScreen(),
    const MentorProfileScreen(),
  ];

  void _openWallet() => setState(() => _index = 3);
  void _openBookings() => setState(() => _index = 1);
  void _openServices() {
    setState(() => _index = 2);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _servicesKey.currentState?.startCreating(),
    );
  }

  void _openProfile() => setState(() => _index = 4);

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Beranda'),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Booking'),
    (
      Icons.cast_for_education_rounded,
      Icons.cast_for_education_outlined,
      'Jasa',
    ),
    (
      Icons.account_balance_wallet_rounded,
      Icons.account_balance_wallet_outlined,
      'Wallet',
    ),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: IndexedStack(index: _index, children: _pages),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final selected = i == _index;
            final item = _items[i];
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.$3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _index = i),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 11 : 6,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryNavy
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.$1 : item.$2,
                          color: selected
                              ? Colors.white
                              : AppColors.secondarySlate,
                          size: 21,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: ExcludeSemantics(
                              child: Text(
                                item.$3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
