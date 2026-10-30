import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key, this.onOpenWallet, this.onOpenBookings});

  final VoidCallback? onOpenWallet;
  final VoidCallback? onOpenBookings;

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Selamat pagi,', style: TextStyle(color: Colors.grey, fontSize: 13)),
                SizedBox(height: 3),
                Text('Pak Budi 👋', style: TextStyle(color: AppColors.darkBrown, fontSize: 23, fontWeight: FontWeight.w800)),
              ])),
              _RoundAction(Icons.chat_bubble_outline_rounded, onTap: () => Navigator.pushNamed(context, AppRoutes.inbox)),
              const SizedBox(width: 10),
              _RoundAction(Icons.notifications_none_rounded, onTap: () => Navigator.pushNamed(context, AppRoutes.notifications), badge: true),
            ]),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9A6A45), Color(0xFF4D332D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: AppColors.darkBrown.withValues(alpha: .22), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('PENDAPATAN MENTOR', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withValues(alpha: .85)),
                ]),
                const SizedBox(height: 8),
                const Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('124', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, height: 1)),
                  SizedBox(width: 8),
                  Padding(padding: EdgeInsets.only(bottom: 4), child: Text('TC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 7),
                const Text('≈ Rp124.000 · 12 TC bulan ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _WalletAction(label: 'Lihat wallet', icon: Icons.receipt_long_outlined, onTap: onOpenWallet ?? () => Navigator.pushNamed(context, AppRoutes.wallet))),
                  const SizedBox(width: 10),
                  Expanded(child: _WalletAction(label: 'Tarik dana', icon: Icons.south_west_rounded, onTap: onOpenWallet ?? () => Navigator.pushNamed(context, AppRoutes.wallet))),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
            const Row(children: [
              Expanded(child: _SummaryCard(value: '3', label: 'Booking baru', icon: Icons.mark_email_unread_outlined, color: Color(0xFFDB8D47))),
              SizedBox(width: 10),
              Expanded(child: _SummaryCard(value: '2', label: 'Sesi hari ini', icon: Icons.video_call_outlined, color: Color(0xFF5B9D7B))),
              SizedBox(width: 10),
              Expanded(child: _SummaryCard(value: '4.9', label: 'Rating', icon: Icons.star_rounded, color: Color(0xFFE6AE48))),
            ]),
            const SizedBox(height: 24),
            MentorSectionTitle('Jadwal berikutnya', action: 'Semua jadwal', onAction: onOpenBookings),
            MentorCard(child: Row(children: [
              Container(width: 54, height: 58, decoration: BoxDecoration(color: const Color(0xFFF5EFE8), borderRadius: BorderRadius.circular(16)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('30', style: TextStyle(color: AppColors.darkBrown, fontSize: 20, fontWeight: FontWeight.w800)), Text('OKT', style: TextStyle(color: AppColors.tertiaryCaramel, fontSize: 10, fontWeight: FontWeight.w800))])),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Review UI Flutter', style: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 14)), SizedBox(height: 5), Text('Nadia Putri · 14.00–15.00', style: TextStyle(color: Colors.grey, fontSize: 12)), SizedBox(height: 8), MentorTag('Hari ini', color: Color(0xFFEAF4ED), textColor: Color(0xFF38845B))])),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ])),
            const SizedBox(height: 23),
            MentorSectionTitle('Perlu ditinjau', action: '3 permintaan', onAction: onOpenBookings),
            const _RequestPreview(name: 'Rizky Ramadhan', initials: 'RR', subject: 'Konsultasi dasar Laravel API', time: 'Besok, 10.00 · 3 TC'),
            const SizedBox(height: 11),
            const _RequestPreview(name: 'Siti Rahma', initials: 'SR', subject: 'Review portofolio UI/UX', time: '2 Nov, 13.00 · 4 TC'),
            const SizedBox(height: 22),
            MentorSectionTitle('Rekomendasi talenta', action: 'Lihat semua'),
            const _EndorsementPreview(name: 'Alya Permata', initials: 'AP', skill: 'UI/UX Design · Figma'),
            const SizedBox(height: 11),
            const _EndorsementPreview(name: 'Fajar Nugraha', initials: 'FN', skill: 'Flutter · REST API'),
            const SizedBox(height: 26),
          ],
        ),
      );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction(this.icon, {required this.onTap, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Stack(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: AppColors.darkBrown, size: 21)), if (badge) Positioned(right: 8, top: 8, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFE15D55), shape: BoxShape.circle)))]));
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .2))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: Colors.white), const SizedBox(width: 7), Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))])));
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.value, required this.label, required this.icon, required this.color});
  final String value, label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 7), Text(value, style: const TextStyle(color: AppColors.darkBrown, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 10))]));
}

class _RequestPreview extends StatelessWidget {
  const _RequestPreview({required this.name, required this.initials, required this.subject, required this.time});
  final String name, initials, subject, time;
  @override
  Widget build(BuildContext context) => MentorCard(padding: const EdgeInsets.all(14), child: Row(children: [MentorAvatar(initials: initials, size: 42), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 3), Text(subject, style: TextStyle(color: Colors.grey.shade700, fontSize: 11)), const SizedBox(height: 5), Text(time, style: const TextStyle(color: AppColors.tertiaryCaramel, fontWeight: FontWeight.w700, fontSize: 11))])), const Icon(Icons.chevron_right_rounded, color: Colors.grey)]));
}

class _EndorsementPreview extends StatefulWidget {
  const _EndorsementPreview({required this.name, required this.initials, required this.skill});
  final String name, initials, skill;

  @override
  State<_EndorsementPreview> createState() => _EndorsementPreviewState();
}

class _EndorsementPreviewState extends State<_EndorsementPreview> {
  bool _endorsed = false;

  @override
  Widget build(BuildContext context) => MentorCard(padding: const EdgeInsets.all(14), child: Row(children: [
    MentorAvatar(initials: widget.initials, size: 42),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.name, style: const TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 4), Text(widget.skill, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))])),
    TextButton(onPressed: () => setState(() => _endorsed = !_endorsed), style: TextButton.styleFrom(foregroundColor: _endorsed ? const Color(0xFF38845B) : AppColors.tertiaryCaramel), child: Text(_endorsed ? 'Direkomendasikan ✓' : 'Endorse', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
  ]));
}
