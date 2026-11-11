import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_featured_upgrade_screen.dart';

class PickedAvatarFile {
  const PickedAvatarFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({
    super.key,
    required this.availableTc,
    this.onSelectTab,
    this.mentorApi,
    this.onPickAvatar,
    this.skipInitialLoad = false,
    this.initialName,
    this.initialHeadline,
    this.initialBio,
    this.initialAvatarUrl,
  });

  final ValueListenable<int> availableTc;
  final ValueChanged<int>? onSelectTab;
  final MentorApi? mentorApi;
  final Future<PickedAvatarFile?> Function()? onPickAvatar;
  final bool skipInitialLoad;
  final String? initialName;
  final String? initialHeadline;
  final String? initialBio;
  final String? initialAvatarUrl;

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  late String _name = widget.initialName ?? 'Mentor';
  late String _headline = widget.initialHeadline ?? '';
  late String _bio = widget.initialBio ?? '';
  late String? _avatarUrl = widget.initialAvatarUrl;
  late bool _loading = !widget.skipInitialLoad;
  bool _isDeletingAccount = false;

  MentorApi get _mentorApi => widget.mentorApi ?? MentorApi.instance;

  @override
  void initState() {
    super.initState();
    if (!widget.skipInitialLoad) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final values = await Future.wait([
        _mentorApi.profile(),
        ApiClient.instance.readSessionUser(),
      ]);
      if (!mounted) return;
      final profile = values[0] as Map<String, dynamic>;
      final user = values[1] ?? const <String, dynamic>{};
      setState(() {
        _name =
            (profile['name'] as String?) ??
            (user['name'] as String?) ??
            'Mentor';
        _headline = profile['title_headline'] as String? ?? '';
        _bio = profile['bio'] as String? ?? '';
        _avatarUrl =
            (profile['avatar_url'] as String?) ??
            (user['avatar_url'] as String?);
      });
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editProfile() async {
    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _EditMentorProfileSheet(
        initialName: _name,
        initialHeadline: _headline,
        initialBio: _bio,
        initialAvatarUrl: _avatarUrl,
        mentorApi: _mentorApi,
        onPickAvatar: widget.onPickAvatar,
        syncLocalSession: widget.mentorApi == null,
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        final nextName = updated['name'] as String?;
        if (nextName != null && nextName.trim().isNotEmpty) {
          _name = nextName.trim();
        }
        _headline = updated['title_headline'] as String? ?? _headline;
        _bio = updated['bio'] as String? ?? _bio;
        if (updated.containsKey('avatar_url')) {
          _avatarUrl = updated['avatar_url'] as String?;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mentor berhasil diperbarui.')),
      );
    }
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
              backgroundColor: const Color(0xFFB91C1C),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthApi().logout();
              if (!mounted) return;
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

  Future<void> _confirmDeleteAccount() async {
    if (_isDeletingAccount) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Akun Mentor Permanen?',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Seluruh data profil, foto, CV, kelas mentoring, dan akses akun mentor Anda akan dihapus permanen dan tidak bisa dikembalikan.',
          style: TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Ya, Hapus Akun',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _mentorApi.deleteAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun mentor berhasil dihapus.')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.roleSelection,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun mentor gagal dihapus. Coba lagi nanti.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        if (_loading) const LinearProgressIndicator(),
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
              // Avatar Squircle (tap to change photo / profile)
              Semantics(
                button: true,
                label: 'Ubah foto profil',
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _editProfile,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _MentorAvatar(
                        name: _name,
                        avatarUrl: _avatarUrl,
                        size: 82,
                        radius: 24,
                      ),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
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

        // Keluar (Logout) & Hapus Akun Mentor
        Center(
          child: Semantics(
            button: true,
            label: 'Keluar dari akun',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isDeletingAccount ? null : _confirmLogout,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFB91C1C),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: 'Hapus akun mentor',
          child: Material(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isDeletingAccount ? null : _confirmDeleteAccount,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: _isDeletingAccount
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Menghapus akun mentor...',
                            style: TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_forever_outlined,
                            color: Color(0xFFB91C1C),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Hapus Akun Mentor',
                            style: TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return 'M';
  return parts.map((part) => part[0].toUpperCase()).join();
}

class _MentorAvatar extends StatelessWidget {
  const _MentorAvatar({
    required this.name,
    this.avatarUrl,
    this.memoryBytes,
    required this.size,
    required this.radius,
  });

  final String name;
  final String? avatarUrl;
  final Uint8List? memoryBytes;
  final double size;
  final double radius;

  Widget _fallbackBox() => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.primaryNavy,
      borderRadius: BorderRadius.circular(radius),
    ),
    alignment: Alignment.center,
    child: Text(
      _initialsForName(name),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: size * 0.34,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final decodedCacheWidth = (size * 3).round();
    if (memoryBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          memoryBytes!,
          width: size,
          height: size,
          cacheWidth: decodedCacheWidth,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackBox(),
        ),
      );
    }
    final resolvedUrl = ApiClient.resolveMediaUrl(avatarUrl);
    if (resolvedUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          resolvedUrl,
          width: size,
          height: size,
          cacheWidth: decodedCacheWidth,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackBox(),
        ),
      );
    }
    return _fallbackBox();
  }
}

class _EditMentorProfileSheet extends StatefulWidget {
  const _EditMentorProfileSheet({
    required this.initialName,
    required this.initialHeadline,
    required this.initialBio,
    required this.initialAvatarUrl,
    required this.mentorApi,
    required this.syncLocalSession,
    this.onPickAvatar,
  });

  final String initialName;
  final String initialHeadline;
  final String initialBio;
  final String? initialAvatarUrl;
  final MentorApi mentorApi;
  final bool syncLocalSession;
  final Future<PickedAvatarFile?> Function()? onPickAvatar;

  @override
  State<_EditMentorProfileSheet> createState() =>
      _EditMentorProfileSheetState();
}

class _EditMentorProfileSheetState extends State<_EditMentorProfileSheet> {
  static const int _maxAvatarBytes = 2 * 1024 * 1024;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _headlineController = TextEditingController(
    text: widget.initialHeadline,
  );
  late final TextEditingController _bioController = TextEditingController(
    text: widget.initialBio,
  );

  String? _pickedAvatarName;
  Uint8List? _pickedAvatarBytes;
  bool _removeAvatar = false;
  bool _isPickingPhoto = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<PickedAvatarFile?> _defaultPickAvatar() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih Foto Profil',
      type: FileType.image,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return PickedAvatarFile(name: picked.name, bytes: bytes);
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto || _isSaving) return;
    setState(() {
      _isPickingPhoto = true;
      _errorMessage = null;
    });
    try {
      final picked = await (widget.onPickAvatar ?? _defaultPickAvatar)();
      if (!mounted || picked == null) return;
      final ext = picked.name.contains('.')
          ? picked.name.split('.').last.toLowerCase()
          : '';
      if (!_allowedExtensions.contains(ext)) {
        setState(() {
          _errorMessage = 'Format foto harus JPG, PNG, atau WEBP.';
        });
        return;
      }
      if (picked.bytes.isEmpty) {
        setState(() {
          _errorMessage = 'Berkas foto kosong dan tidak dapat diunggah.';
        });
        return;
      }
      if (picked.bytes.length > _maxAvatarBytes) {
        setState(() {
          _errorMessage = 'Ukuran foto profil maksimal 2 MB.';
        });
        return;
      }
      setState(() {
        _pickedAvatarName = picked.name;
        _pickedAvatarBytes = picked.bytes;
        _removeAvatar = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal membuka foto profil. Coba pilih foto lain.';
        });
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _clearPhoto() {
    if (_isSaving || _isPickingPhoto) return;
    setState(() {
      _pickedAvatarName = null;
      _pickedAvatarBytes = null;
      _removeAvatar = true;
      _errorMessage = null;
    });
  }

  Future<void> _save() async {
    if (_isSaving || _isPickingPhoto) return;
    final name = _nameController.text.trim();
    final headline = _headlineController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama lengkap wajib diisi.');
      return;
    }
    if (headline.isEmpty) {
      setState(() => _errorMessage = 'Profesi atau headline wajib diisi.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final payload = <String, dynamic>{
        'name': name,
        'title_headline': headline,
        'bio': bio,
        if (_removeAvatar && _pickedAvatarBytes == null) 'remove_avatar': true,
      };
      final updated = await widget.mentorApi.updateProfile(
        payload,
        avatarFileName: _pickedAvatarName,
        avatarBytes: _pickedAvatarBytes,
      );
      if (widget.syncLocalSession) {
        await ApiClient.instance.updateSessionUser({
          'name': updated['name'] ?? name,
          if (updated.containsKey('avatar_url'))
            'avatar_url': updated['avatar_url'],
        });
      }
      if (!mounted) return;
      Navigator.pop(context, updated);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menyimpan perubahan profil. Coba lagi.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int minLines = 1,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.darkSlate,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        minLines: minLines,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.darkSlate,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF64748B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primaryNavy,
              width: 1.6,
            ),
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final hasAnyPhoto =
        _pickedAvatarBytes != null ||
        (!_removeAvatar &&
            widget.initialAvatarUrl != null &&
            widget.initialAvatarUrl!.trim().isNotEmpty);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSlate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Profil Mentor',
                    style: TextStyle(
                      color: AppColors.darkSlate,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: 'Tutup',
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Photo Picker Section
            Row(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, value, child) => _MentorAvatar(
                    name: value.text.trim().isEmpty
                        ? widget.initialName
                        : value.text,
                    avatarUrl: _removeAvatar ? null : widget.initialAvatarUrl,
                    memoryBytes: _pickedAvatarBytes,
                    size: 72,
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                              foregroundColor: AppColors.primaryNavy,
                              side: const BorderSide(color: Color(0xFF64748B)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isPickingPhoto || _isSaving
                                ? null
                                : _pickPhoto,
                            icon: _isPickingPhoto
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryNavy,
                                    ),
                                  )
                                : const Icon(
                                    Icons.photo_library_outlined,
                                    size: 18,
                                  ),
                            label: Text(
                              hasAnyPhoto ? 'Ganti Foto' : 'Pilih Foto',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (hasAnyPhoto)
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                foregroundColor: const Color(0xFFB91C1C),
                              ),
                              onPressed: _isPickingPhoto || _isSaving
                                  ? null
                                  : _clearPhoto,
                              child: const Text(
                                'Hapus Foto',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Format JPG, PNG, atau WEBP · Maks. 2 MB',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            _buildLabeledInput(
              label: 'Nama Lengkap',
              controller: _nameController,
              hint: 'Masukkan nama lengkap',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            _buildLabeledInput(
              label: 'Profesi / Headline',
              controller: _headlineController,
              hint: 'Contoh: Mentor Flutter & Dart',
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            _buildLabeledInput(
              label: 'Tentang Saya',
              controller: _bioController,
              hint: 'Jelaskan keahlian dan pengalaman membimbingmu',
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFB91C1C),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSaving || _isPickingPhoto ? null : _save,
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Menyimpan...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
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
