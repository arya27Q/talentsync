import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';

class LogBimbinganScreen extends StatefulWidget {
  const LogBimbinganScreen({super.key, this.mentoringApi});

  final StudentMentoringApi? mentoringApi;

  @override
  State<LogBimbinganScreen> createState() => _LogBimbinganScreenState();
}

class _LogBimbinganScreenState extends State<LogBimbinganScreen> {
  late final StudentMentoringApi _api =
      widget.mentoringApi ?? StudentMentoringApi.instance;

  static const List<({String key, String label})> _filters = [
    (key: 'all', label: 'Semua'),
    (key: 'pending', label: 'Menunggu'),
    (key: 'accepted', label: 'Aktif'),
    (key: 'pending_confirmation', label: 'Konfirmasi'),
    (key: 'completed', label: 'Selesai'),
  ];

  String _activeFilter = 'all';
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

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
      final list = await _api.myEnrollments();
      if (!mounted) return;
      setState(() {
        _items = list;
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
          _error = 'Gagal memuat riwayat bimbingan.';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_activeFilter == 'all') return _items;
    return _items.where((item) {
      final status = (item['status'] as String?) ?? '';
      if (_activeFilter == 'accepted') {
        return status == 'accepted' || status == 'attended';
      }
      return status == _activeFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : _filteredItems.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _buildLogCard(_filteredItems[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.darkSlate,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Bimbingan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  'Riwayat sesi, evaluasi, dan progres mentoring',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, idx) {
          final f = _filters[idx];
          final active = _activeFilter == f.key;
          return InkWell(
            onTap: () => setState(() => _activeFilter = f.key),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryNavy : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppColors.primaryNavy : AppColors.borderSlate,
                ),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : AppColors.secondarySlate,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> item) {
    final enrollmentId = (item['id'] as num?)?.toInt();
    final classData = (item['class'] as Map<String, dynamic>?) ?? const {};
    final mentorName = (classData['mentor_name'] as String?) ?? 'Mentor';
    final headline = (classData['title_headline'] as String?) ?? 'Peer Mentor';
    final topic =
        (item['topic_focus'] as String?) ??
        (classData['topic'] as String?) ??
        'Sesi Mentoring';
    final status = (item['status'] as String?) ?? 'pending';
    final paidTc = (item['paid_tc'] as num?)?.toInt() ?? 0;
    final score = (item['assessment_score'] as num?)?.toInt();
    final hasEndorsement = item['has_endorsement'] == true;
    final meta = _statusMeta(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.lightBlueSurface,
                child: Text(
                  mentorName.isNotEmpty ? mentorName[0].toUpperCase() : 'M',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: meta.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meta.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: meta.fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            topic,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoPill(Icons.toll_rounded, '$paidTc TC'),
              if (classData['scheduled_time'] != null)
                _infoPill(
                  Icons.calendar_today_rounded,
                  '${classData['scheduled_time']}',
                ),
              if (score != null)
                _infoPill(Icons.analytics_rounded, 'Skor $score/100'),
              if (hasEndorsement)
                _infoPill(Icons.verified_rounded, 'Endorse Mentor'),
            ],
          ),
          if (enrollmentId != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (status == 'accepted' || status == 'attended') ...[
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mentoringSession,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: enrollmentId,
                          ),
                        ),
                        child: const Text(
                          'Ruang Sesi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNavy,
                          side: const BorderSide(color: AppColors.primaryNavy),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.ruangBelajar,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: enrollmentId,
                          ),
                        ),
                        child: const Text(
                          'Ruang Belajar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ] else if (status == 'pending_confirmation') ...[
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.selesaiBimbingan,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: enrollmentId,
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi Selesai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ] else if (status == 'completed') ...[
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mentoringResult,
                          arguments: MentoringEnrollmentArgs(
                            enrollmentId: enrollmentId,
                          ),
                        ),
                        child: const Text(
                          'Lihat Hasil Evaluasi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.canvasWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryNavy),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 46,
              color: AppColors.secondarySlate,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _load,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 48,
              color: AppColors.secondarySlate,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Log Bimbingan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Jadwalkan sesi bimbingan bersama Peer Mentor untuk memulai latihan dan meraih rekomendasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.findMentors),
                child: const Text('Cari Mentor'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ({String label, Color fg, Color bg}) _statusMeta(String status) {
    switch (status) {
      case 'completed':
        return (
          label: 'Selesai',
          fg: const Color(0xFF15803D),
          bg: const Color(0xFFDCFCE7),
        );
      case 'pending_confirmation':
        return (
          label: 'Perlu Konfirmasi',
          fg: const Color(0xFFB45309),
          bg: const Color(0xFFFEF3C7),
        );
      case 'accepted':
      case 'attended':
        return (
          label: 'Sedang Berjalan',
          fg: AppColors.primaryNavy,
          bg: AppColors.lightBlueSurface,
        );
      case 'declined':
      case 'cancelled':
        return (
          label: 'Dibatalkan',
          fg: const Color(0xFFB91C1C),
          bg: const Color(0xFFFEE2E2),
        );
      default:
        return (
          label: 'Menunggu Persetujuan',
          fg: AppColors.secondarySlate,
          bg: const Color(0xFFF1F5F9),
        );
    }
  }
}
