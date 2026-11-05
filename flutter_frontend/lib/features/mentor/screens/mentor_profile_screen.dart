import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';

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

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu akan dialihkan kembali ke halaman masuk mentor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mentorAuth,
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        // Header matching screenshot
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
            Semantics(
              button: true,
              label: 'Edit profil',
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _editProfile,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkSlate.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.darkSlate,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Profile Main Card matching Screenshot 1
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderSlate.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkSlate.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar Squircle matching Screenshot 3
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300',
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Name + Verified Badge
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
                        fontSize: 20,
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
              const SizedBox(height: 3),
              Text(
                _headline,
                style: const TextStyle(
                  color: AppColors.secondarySlate,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // Top Rated Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFC2410C),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Top Rated',
                      style: TextStyle(
                        color: Color(0xFFC2410C),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3 Metrics Box Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: const [
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
        const SizedBox(height: 14),

        // Featured Mentor Promo Banner matching Screenshot 1
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderSlate.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkSlate.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFC2410C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Jadi Featured Mentor',
                      style: TextStyle(
                        color: AppColors.darkSlate,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    SizedBox(height: 3),
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
              Semantics(
                button: true,
                label: 'Upgrade ke Featured Mentor',
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _openUpgrade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Upgrade',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section: Layanan mentoring
        const Text(
          'Layanan mentoring',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        // Service Card 1
        const _ProfileServiceCard(
          title: 'Code Review & Arsitektur Flutter',
          duration: '60 menit · 86 sesi terjual',
          price: '30 TC',
          tags: ['Flutter', 'BLoC', 'Clean Architecture'],
        ),
        const SizedBox(height: 12),

        // Service Card 2
        const _ProfileServiceCard(
          title: 'Simulasi Wawancara Mobile Developer',
          duration: '45 menit · 31 sesi terjual',
          price: '25 TC',
          tags: [],
        ),
        const SizedBox(height: 22),

        // Section: Ulasan murid matching Screenshot 2
        const Text(
          'Ulasan murid',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        // Review 1: Arya Pratama
        const _ReviewCard(
          initials: 'AP',
          avatarColor: AppColors.primaryNavy,
          name: 'Arya Pratama',
          date: '8 Jul',
          stars: 5,
          review: '"Penjelasan BLoC-nya sangat detail dan langsung dipraktikkan ke proyek kasir saya."',
        ),
        const SizedBox(height: 12),

        // Review 2: Dewi Lestari
        const _ReviewCard(
          initials: 'DL',
          avatarColor: Color(0xFF0F766E),
          name: 'Dewi Lestari',
          date: '20 Jun',
          stars: 5,
          review: '"Feedback konstruktif, action plan jelas. Portofolio saya lolos kurasi."',
        ),
        const SizedBox(height: 12),

        // Review 3: Rafi Hakim
        const _ReviewCard(
          initials: 'RH',
          avatarColor: Color(0xFFA03B1E),
          name: 'Rafi Hakim',
          date: '2 Jun',
          stars: 4,
          review: '"Sangat membantu pemula, hanya sesi terasa cepat."',
        ),
        const SizedBox(height: 24),

        // Keluar (Logout) button matching Screenshot 2
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _confirmLogout,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
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
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: const TextStyle(
          color: AppColors.secondarySlate,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.borderSlate);
}

class _ProfileServiceCard extends StatelessWidget {
  const _ProfileServiceCard({
    required this.title,
    required this.duration,
    required this.price,
    this.tags = const [],
  });

  final String title;
  final String duration;
  final String price;
  final List<String> tags;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSlate,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.darkSlate,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          duration,
          style: const TextStyle(color: AppColors.secondarySlate, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final tag in tags)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.date,
    required this.stars,
    required this.review,
  });

  final String initials;
  final Color avatarColor;
  final String name;
  final String date;
  final int stars;
  final String review;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderSlate.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkSlate.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: avatarColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 17,
                  color: index < stars
                      ? AppColors.accentAmberGold
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}
