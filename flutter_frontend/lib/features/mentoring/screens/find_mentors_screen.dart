import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';

class FindMentorsScreen extends StatefulWidget {
  const FindMentorsScreen({
    super.key,
    this.mentoringApi,
    this.walletApi,
  });

  final StudentMentoringApi? mentoringApi;
  final WalletApi? walletApi;

  @override
  State<FindMentorsScreen> createState() => _FindMentorsScreenState();
}

class _FindMentorsScreenState extends State<FindMentorsScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;
  late final WalletApi _walletApi = widget.walletApi ?? WalletApi.instance;

  int _selectedCategoryIndex = 0;
  String _sortKey = 'rating_desc';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  String? _error;
  int _balanceTc = 0;
  List<Map<String, dynamic>> _mentors = const [];

  final List<String> _categories = const [
    'Semua',
    'Mobile',
    'UI/UX Design',
    'Backend',
    'Product',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.mentors(
          search: _searchController.text,
          category: _categories[_selectedCategoryIndex],
          sort: _sortKey,
        ),
        _walletApi.summary().catchError((_) => const <String, dynamic>{}),
      ]);
      if (!mounted) return;
      final mentorRes = results[0];
      final walletRes = results[1];
      final rows = (mentorRes['data'] as List?) ?? const [];
      setState(() {
        _mentors = rows.whereType<Map<String, dynamic>>().toList();
        _balanceTc = (walletRes['balance_tc'] as num?)?.toInt() ?? 0;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat daftar mentor.';
          _isLoading = false;
        });
      }
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'M';
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    final mentorId = (mentor['id'] as num).toInt();
    final name = (mentor['name'] as String?) ?? 'Mentor';
    final headline =
        (mentor['title_headline'] as String?) ?? 'Peer Mentor TalentSync';
    final bio =
        (mentor['focus_summary'] as String?) ??
        (mentor['bio'] as String?) ??
        '';
    final avatarUrl = ApiClient.resolveMediaUrl(mentor['avatar_url'] as String?);
    final rating = ((mentor['rating'] as num?)?.toDouble() ?? 0.0);
    final reviewsCount = (mentor['reviews_count'] as num?)?.toInt() ?? 0;
    final priceTc = (mentor['hourly_rate_tc'] as num?)?.toInt() ?? 30;
    final tags = ((mentor['tags'] as List?) ?? const [])
        .map((e) => '$e')
        .toList();
    final nearestClass = mentor['nearest_class'] as Map<String, dynamic>?;
    final nearestClassId = (nearestClass?['id'] as num?)?.toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        width: 52,
                        height: 52,
                        cacheWidth: 156,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            _initials(name),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.primaryNavy,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.accentAmberGold,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating > 0 ? rating.toStringAsFixed(1) : '4.9',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (reviewsCount > 0)
                    Text(
                      ' ($reviewsCount)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${nearestClass?['price_tc'] ?? priceTc} TC / ${nearestClass?['duration_minutes'] ?? 60} mnt',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                  fontSize: 13.5,
                ),
              ),
              if (nearestClass != null)
                Flexible(
                  child: Text(
                    'Slot: ${nearestClass['topic']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderSlate),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.mentorProfile,
                    arguments: MentorDetailArgs(
                      mentorId: mentorId,
                      classId: nearestClassId,
                    ),
                  ),
                  child: const Text(
                    'Lihat Profil',
                    style: TextStyle(
                      color: AppColors.darkSlate,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (nearestClassId != null) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookingSession,
                        arguments: BookingSessionArgs(
                          classId: nearestClassId,
                          mentorId: mentorId,
                          mentorName: name,
                          headline: headline,
                          topic: nearestClass?['topic'] as String?,
                          priceTc:
                              (nearestClass?['price_tc'] as num?)?.toInt() ??
                              priceTc,
                        ),
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.mentorProfile,
                        arguments: MentorDetailArgs(mentorId: mentorId),
                      );
                    }
                  },
                  child: const Text(
                    'Sewa Mentor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    children: [
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            size: 26,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cari Peer Mentor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              'Bimbingan 1-on-1 & Badge Rekomendasi',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Mentor Saya',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.myMentors),
                        icon: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),

                // Wallet Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.toll_rounded,
                          color: AppColors.accentAmberGold,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Saldo Tersedia: $_balanceTc TC',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.wallet),
                          child: const Text(
                            'Top Up',
                            style: TextStyle(
                              color: AppColors.accentAmberGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 350),
                          _load,
                        );
                      },
                      decoration: const InputDecoration(
                        hintText: 'Cari nama mentor, keahlian, atau topik...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13.5,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.secondarySlate,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Categories
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = _selectedCategoryIndex == i;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategoryIndex = i);
                          _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryNavy
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryNavy
                                  : AppColors.borderSlate,
                            ),
                          ),
                          child: Text(
                            _categories[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : AppColors.secondarySlate,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${_mentors.length} mentor siap · 96% lolos kurasi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          setState(() => _sortKey = v);
                          _load();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'rating_desc',
                            child: Text('Rating tertinggi'),
                          ),
                          PopupMenuItem(
                            value: 'lowest_price',
                            child: Text('Tarif terendah'),
                          ),
                        ],
                        child: Text(
                          _sortKey == 'lowest_price'
                              ? 'Tarif terendah'
                              : 'Rating tertinggi',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _error != null
                      ? Center(
                          child: Column(
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: _load,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        )
                      : _mentors.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'Belum ada mentor yang sesuai pencarian.',
                              style: TextStyle(color: AppColors.secondarySlate),
                            ),
                          ),
                        )
                      : Column(
                          children: _mentors.map(_buildMentorCard).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
