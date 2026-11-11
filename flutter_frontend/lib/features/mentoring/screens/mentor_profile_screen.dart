import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({
    super.key,
    this.mentorId,
    this.classId,
    this.mentoringApi,
  });

  final int? mentorId;
  final int? classId;
  final StudentMentoringApi? mentoringApi;

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _mentor;
  int _selectedClassIndex = 0;
  bool _isBookmarkBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.mentorId;
      if (targetId == null) {
        final list = await _api.mentors();
        final rows = (list['data'] as List?) ?? const [];
        if (rows.isEmpty) {
          throw const ApiException('Belum ada mentor tersedia.');
        }
        targetId = ((rows.first as Map<String, dynamic>)['id'] as num).toInt();
      }
      final detail = await _api.mentorDetail(targetId);
      if (!mounted) return;
      final classes = ((detail['classes'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      var initialIdx = 0;
      if (widget.classId != null) {
        final found = classes.indexWhere(
          (c) => (c['id'] as num?)?.toInt() == widget.classId,
        );
        if (found >= 0) initialIdx = found;
      }
      setState(() {
        _mentor = detail;
        _selectedClassIndex = initialIdx;
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
          _error = 'Gagal memuat profil mentor.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final id = (_mentor?['id'] as num?)?.toInt();
    if (id == null || _isBookmarkBusy) return;
    setState(() => _isBookmarkBusy = true);
    try {
      final isBookmarked = await _api.toggleMentorBookmark(id);
      if (!mounted) return;
      setState(() {
        _mentor = {...?_mentor, 'is_bookmarked': isBookmarked};
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isBookmarkBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _mentor == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error ?? 'Mentor tidak ditemukan.'),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _load, child: const Text('Coba lagi')),
                    ],
                  ),
                ),
              )
            : _buildBody(context, _mentor!),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> m) {
    final classes = ((m['classes'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final reviews = ((m['reviews'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final deliverables = ((m['deliverables'] as List?) ?? const [])
        .map((e) => '$e')
        .toList();
    final isBookmarked = m['is_bookmarked'] == true;
    final avatarUrl = ApiClient.resolveMediaUrl(m['avatar_url'] as String?);
    final selectedClass =
        classes.isNotEmpty ? classes[_selectedClassIndex] : null;
    final displayPrice =
        (selectedClass?['price_tc'] as num?)?.toInt() ??
        (m['hourly_rate_tc'] as num?)?.toInt() ??
        30;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                    const Expanded(
                      child: Text(
                        'Profil Peer Mentor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleBookmark,
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isBookmarked
                            ? AppColors.primaryNavy
                            : AppColors.darkSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Identity Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueSurface,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: avatarUrl != null
                                ? Image.network(
                                    avatarUrl,
                                    width: 60,
                                    height: 60,
                                    cacheWidth: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primaryNavy,
                                      size: 30,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (m['name'] as String?) ?? '',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  (m['title_headline'] as String?) ?? '',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statBox(
                            ((m['rating'] as num?)?.toDouble() ?? 4.9)
                                .toStringAsFixed(1),
                            'Rating',
                          ),
                          const SizedBox(width: 8),
                          _statBox('${m['sessions_count'] ?? 0}', 'Sesi'),
                          const SizedBox(width: 8),
                          _statBox(
                            '${m['portfolio_pass_rate'] ?? 96}%',
                            'Lolos Kurasi',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        (m['bio'] as String?) ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondarySlate,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Deliverables
                if (deliverables.isNotEmpty) ...[
                  const Text(
                    'Yang Kamu Dapatkan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...deliverables.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Available Class Slots
                const Text(
                  'Pilih Jadwal & Topik Bimbingan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 10),
                if (classes.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: const Text(
                      'Mentor belum membuka slot jadwal baru saat ini.',
                      style: TextStyle(color: AppColors.secondarySlate),
                    ),
                  )
                else
                  ...List.generate(classes.length, (i) {
                    final cls = classes[i];
                    final selected = _selectedClassIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedClassIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryNavy
                                : AppColors.borderSlate,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (cls['topic'] as String?) ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cls['duration_minutes'] ?? 60} menit · Kapasitas ${cls['enrolled_count'] ?? 0}/${cls['capacity'] ?? 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${cls['price_tc'] ?? 30} TC',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                if (reviews.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Ulasan Mahasiswa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...reviews.map(
                    (r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (r['reviewer_name'] as String?) ?? 'Mahasiswa',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${r['rating'] ?? 5} / 5',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentAmberGold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                          if ((r['review_text'] as String?) != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              r['review_text'] as String,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom Bar
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderSlate)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayPrice TC',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const Text(
                    'Ditahan via Smart Escrow',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: selectedClass == null
                        ? AppColors.secondarySlate
                        : AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: selectedClass == null
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookingSession,
                          arguments: BookingSessionArgs(
                            classId: (selectedClass['id'] as num).toInt(),
                            mentorId: (m['id'] as num).toInt(),
                            mentorName: m['name'] as String?,
                            headline: m['title_headline'] as String?,
                            topic: selectedClass['topic'] as String?,
                            priceTc:
                                (selectedClass['price_tc'] as num?)?.toInt() ??
                                displayPrice,
                          ),
                        ),
                  child: Text(
                    selectedClass == null
                        ? 'Jadwal Belum Tersedia'
                        : 'Sewa Mentor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.canvasWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkSlate,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
