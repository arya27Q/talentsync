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

  late final List<Widget> _pages = [
    MentorDashboardScreen(onOpenWallet: _openWallet, onOpenBookings: _openBookings),
    const MentorBookingsScreen(),
    const MentorServicesScreen(),
    const MentorWalletScreen(),
    const MentorProfileScreen(),
  ];

  void _openWallet() => setState(() => _index = 3);
  void _openBookings() => setState(() => _index = 1);

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Beranda'),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Booking'),
    (Icons.cast_for_education_rounded, Icons.cast_for_education_outlined, 'Jasa'),
    (Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Wallet'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.warmOffWhite,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: AppColors.darkBrown.withValues(alpha: .12), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: List.generate(_items.length, (i) {
                final selected = i == _index;
                final item = _items[i];
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _index = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(selected ? item.$1 : item.$2, color: selected ? AppColors.primaryTan : Colors.grey.shade400, size: 22),
                        const SizedBox(height: 4),
                        Text(item.$3, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? AppColors.primaryTan : Colors.grey.shade500)),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
}
