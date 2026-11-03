import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';
import 'package:flutter_frontend/features/mentor/widgets/mentor_ui.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({
    super.key,
    required this.availableTc,
    this.onSelectTab,
  });

  final ValueListenable<int> availableTc;
  final ValueChanged<int>? onSelectTab;

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  String _name = 'Dimas Prasetyo';
  String _headline = 'Senior Flutter Engineer';

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final headlineController = TextEditingController(text: _headline);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: headlineController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Profesi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      if (nameController.text.trim().isEmpty ||
          headlineController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan profesi perlu diisi.')),
        );
      } else {
        setState(() {
          _name = nameController.text.trim();
          _headline = headlineController.text.trim();
        });
      }
    }
    nameController.dispose();
    headlineController.dispose();
  }

  void _openUpgrade() => Navigator.pushNamed(
    context,
    AppRoutes.mentorFeaturedUpgrade,
    arguments: MentorFeaturedUpgradeArgs(
      balanceTc: widget.availableTc.value,
      onSelectTab: widget.onSelectTab,
    ),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'My Profile',
                style: TextStyle(
                  color: AppColors.darkSlate,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit profil',
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined, color: AppColors.darkSlate),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(48, 48),
                side: const BorderSide(color: AppColors.borderSlate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MentorCard(
          child: Column(
            children: [
              const MentorAvatar(
                initials: 'DP',
                size: 84,
                color: AppColors.lightBlueSurface,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkSlate,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.primaryNavy,
                    size: 19,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _headline,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              const MentorTag(
                'Top Rated',
                color: Color(0xFFFFF6E8),
                textColor: AppColors.accentAmberDeep,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.canvasWhite,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        value: '312',
                        label: 'Jam mengajar',
                      ),
                    ),
                    _MetricDivider(),
                    Expanded(
                      child: _ProfileMetric(value: '4.9', label: 'Rating'),
                    ),
                    _MetricDivider(),
                    Expanded(
                      child: _ProfileMetric(value: '74', label: 'Murid'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: _openUpgrade,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.accentAmberDeep,
                    size: 25,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadi Featured Mentor',
                          style: TextStyle(
                            color: AppColors.darkSlate,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '0% admin cash-out dan tampil teratas',
                          style: TextStyle(
                            color: AppColors.secondarySlate,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _openUpgrade,
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const MentorSectionTitle('Layanan mentoring'),
        const _ProfileServiceCard(
          title: 'Code Review & Arsitektur Flutter',
          duration: '60 menit · 86 sesi terjual',
          price: '30 TC',
          tags: ['Flutter', 'BLoC', 'Clean Architecture'],
        ),
        const SizedBox(height: 12),
        const _ProfileServiceCard(
          title: 'Simulasi Wawancara Mobile Developer',
          duration: '45 menit · 31 sesi terjual',
          price: '25 TC',
          tags: ['Flutter', 'Interview'],
        ),
        const SizedBox(height: 22),
        const MentorSectionTitle('Ulasan murid'),
        const MentorCard(
          child: Text(
            'Ulasan murid akan tampil setelah sesi selesai dinilai.',
            style: TextStyle(color: AppColors.secondarySlate),
          ),
        ),
        const SizedBox(height: 18),
        MentorCard(
          padding: const EdgeInsets.all(0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: ListTile(
              onTap: () => _confirmLogout(context),
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFB42318),
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Keluar dari akun mentor ini',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondarySlate,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari akun?',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Anda perlu masuk kembali untuk mengakses dashboard mentor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.roleSelection,
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppColors.darkSlate,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.secondarySlate, fontSize: 11),
      ),
    ],
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 42, color: AppColors.borderSlate);
}

class _ProfileServiceCard extends StatelessWidget {
  const _ProfileServiceCard({
    required this.title,
    required this.duration,
    required this.price,
    required this.tags,
  });

  final String title;
  final String duration;
  final String price;
  final List<String> tags;

  @override
  Widget build(BuildContext context) => MentorCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          duration,
          style: const TextStyle(color: AppColors.secondarySlate, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final tag in tags)
              MentorTag(
                tag,
                color: AppColors.lightBlueSurface,
                textColor: AppColors.primaryNavy,
              ),
          ],
        ),
      ],
    ),
  );
}
