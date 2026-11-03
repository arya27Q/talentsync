import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({
    super.key,
    this.onOpenWallet,
    this.onOpenBookings,
    this.onOpenServices,
    this.onOpenProfile,
    this.onOpenLiveSession,
  });

  final VoidCallback? onOpenWallet;
  final VoidCallback? onOpenBookings;
  final VoidCallback? onOpenServices;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenLiveSession;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            const MentorAvatar(initials: 'DP', size: 48, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat sore',
                    style: TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Dimas Prasetyo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.darkSlate,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _TopAction(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Pesan',
              onTap: () => Navigator.pushNamed(context, AppRoutes.inbox),
            ),
            const SizedBox(width: 8),
            _TopAction(
              icon: Icons.notifications_none_rounded,
              label: 'Notifikasi',
              badge: true,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total pendapatan',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Text(
                      'Admin cash-out 15%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Rp420.000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: AppColors.accentAmberGold,
                    size: 13,
                  ),
                  SizedBox(width: 7),
                  Text(
                    '420 TC siap ditukar',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _WalletButton(
                      label: 'Cash-out',
                      icon: Icons.payments_outlined,
                      onTap:
                          onOpenWallet ??
                          () => Navigator.pushNamed(context, AppRoutes.wallet),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WalletButton(
                      label: 'Layanan Baru',
                      icon: Icons.add_circle_outline_rounded,
                      quiet: true,
                      onTap: onOpenServices,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          child: InkWell(
            onTap: onOpenProfile,
            borderRadius: BorderRadius.circular(23),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: AppColors.accentAmberDeep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hemat Rp63.000 saat cash-out',
                          style: TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Featured Mentor bebas admin dan tampil teratas',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondarySlate,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.calendar_month_outlined,
                value: '2',
                label: 'Booking baru',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.rate_review_outlined,
                value: '1',
                label: 'Perlu dinilai',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.thumb_up_alt_outlined,
                value: '2',
                label: 'Minta rekomendasi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const MentorSectionTitle('Jadwal hari ini'),
        MentorCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 66,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hari ini',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '19.00',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Persiapan wawancara Flutter',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Arya Pratama · UNESA',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.inbox),
                    tooltip: 'Buka pesan',
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onOpenLiveSession,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Join Virtual Workspace (GMeet)'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onOpenBookings,
            child: const Text('Lihat semua booking'),
          ),
        ),
      ],
    ),
  );
}

class _TopAction extends StatelessWidget {
  const _TopAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    height: 48,
    child: Stack(
      alignment: Alignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.darkSlate,
          ),
          icon: Icon(icon),
        ),
        if (badge)
          const Positioned(
            right: 11,
            top: 10,
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.accentAmberGold,
            ),
          ),
      ],
    ),
  );
}

class _WalletButton extends StatelessWidget {
  const _WalletButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.quiet = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(
        backgroundColor: quiet
            ? Colors.white.withValues(alpha: .12)
            : Colors.white,
        foregroundColor: quiet ? Colors.white : AppColors.primaryNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 126),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryNavy, size: 21),
        const SizedBox(height: 20),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkSlate,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 11,
            height: 1.25,
          ),
        ),
      ],
    ),
  );
}
