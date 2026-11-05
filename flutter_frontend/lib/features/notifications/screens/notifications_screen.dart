import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class NotificationItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String time;
  final String desc;
  bool isUnread;
  final String? routeDestination;

  NotificationItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.time,
    required this.desc,
    this.isUnread = false,
    this.routeDestination,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFE8F7EE),
      title: 'Application Accepted',
      time: '10 mnt',
      desc: 'Toko Bu Sri menerima lamaranmu untuk proyek aplikasi kasir.',
      isUnread: true,
      routeDestination: AppRoutes.myProjects,
    ),
    NotificationItem(
      id: '2',
      icon: Icons.toll_rounded,
      iconColor: AppColors.accentAmberGold,
      iconBg: const Color(0xFFFEF3C7),
      title: '+80 TC diterima',
      time: '2 jam',
      desc: 'Warung Pak Gito telah memvalidasi hasil kerjamu.',
      isUnread: true,
      routeDestination: AppRoutes.wallet,
    ),
    NotificationItem(
      id: '3',
      icon: Icons.star_rounded,
      iconColor: AppColors.accentAmberGold,
      iconBg: const Color(0xFFFFF7ED),
      title: 'Ulasan baru',
      time: 'Kemarin',
      desc: '"Rapi dan komunikatif, hasilnya langsung dipakai." Rating 5.0',
      isUnread: false,
      routeDestination: AppRoutes.portfolio,
    ),
    NotificationItem(
      id: '4',
      icon: Icons.calendar_today_rounded,
      iconColor: AppColors.primaryNavy,
      iconBg: const Color(0xFFEFF6FF),
      title: 'Sesi mentoring besok',
      time: 'Kemarin',
      desc: 'Bersama Dimas Prasetyo, 19.00 WIB.',
      isUnread: false,
      routeDestination: AppRoutes.findMentors,
    ),
    NotificationItem(
      id: '5',
      icon: Icons.system_update_rounded,
      iconColor: const Color(0xFF64748B),
      iconBg: const Color(0xFFF1F5F9),
      title: 'System Update',
      time: '3 hari',
      desc: 'Pencairan TC kini diproses kurang dari 1 hari kerja.',
      isUnread: false,
      routeDestination: null,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isUnread = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai dibaca.'),
        backgroundColor: AppColors.darkSlate,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          item.isUnread = false;
        });
        if (item.routeDestination != null) {
          Navigator.pushNamed(context, item.routeDestination!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Squircle Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            // Middle Content: Title, Time, Unread Dot, Desc
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      if (item.isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNavy,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondarySlate,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: Icon(icon, color: AppColors.secondarySlate, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.studentDashboard,
                            );
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSlate.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.keyboard_arrow_left_rounded,
                              color: AppColors.darkSlate,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: const Text(
                          'Tandai dibaca',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notifications List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 8,
                      bottom: 120,
                    ),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_notifications[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Floating Capsule Bottom Navigation Bar (Explore, Tasks, Wallet, Profile)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkSlate.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(
                    icon: Icons.explore_rounded,
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.studentDashboard,
                        (route) => false,
                      );
                    },
                  ),
                  _buildNavIcon(
                    icon: Icons.assignment_rounded,
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.myProjects,
                      );
                    },
                  ),
                  _buildNavIcon(
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.wallet);
                    },
                  ),
                  _buildNavIcon(
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
