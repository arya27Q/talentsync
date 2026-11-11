import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectCompletedScreen extends StatefulWidget {
  const ProjectCompletedScreen({super.key, this.projectId, this.projectApi});

  final int? projectId;
  final ProjectApi? projectApi;

  @override
  State<ProjectCompletedScreen> createState() => _ProjectCompletedScreenState();
}

class _ProjectCompletedScreenState extends State<ProjectCompletedScreen> {
  late final ProjectApi _api = widget.projectApi ?? ProjectApi.instance;

  int _userRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.projectId;
      if (targetId == null) {
        final mine = await _api.myProjects();
        final completed = (mine['completed_projects'] as List?) ?? const [];
        final active = (mine['active_projects'] as List?) ?? const [];
        final pool = completed.isNotEmpty ? completed : active;
        if (pool.isEmpty) {
          throw const ApiException('Belum ada data penyelesaian proyek.');
        }
        targetId = ((pool.first as Map<String, dynamic>)['id'] as num).toInt();
      }
      final res = await _api.completionSummary(targetId);
      if (!mounted) return;
      final existingReview = res['student_review'] as Map<String, dynamic>?;
      if (existingReview != null) {
        _userRating = (existingReview['rating'] as num?)?.toInt() ?? 5;
        _reviewController.text =
            (existingReview['review_text'] as String?) ?? '';
      }
      setState(() {
        _summary = res;
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
          _error = 'Gagal memuat ringkasan proyek selesai.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitAndOpenPortfolio() async {
    if (_isSubmitting || _summary == null) return;
    final project = (_summary!['project'] as Map<String, dynamic>?) ?? const {};
    final projectId = (project['id'] as num?)?.toInt();
    final hasReviewed = _summary!['has_reviewed_client'] == true;
    final isCompleted = project['status'] == 'completed';

    if (projectId == null || hasReviewed || !isCompleted) {
      Navigator.pushReplacementNamed(context, AppRoutes.portfolio);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _api.reviewClient(
        projectId,
        rating: _userRating,
        reviewText: _reviewController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ulasan mitra disimpan & hasil tercatat di portofolio.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.portfolio);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: const Text(
          'Proyek Selesai',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _summary == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error ?? 'Data tidak ditemukan.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : _buildBody(context, _summary!),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> data) {
    final project = (data['project'] as Map<String, dynamic>?) ?? const {};
    final msme = (project['msme'] as Map<String, dynamic>?) ?? const {};
    final deliverables = ((data['deliverables'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final clientReview = data['client_testimonial'] as Map<String, dynamic>?;
    final hasReviewed = data['has_reviewed_client'] == true;
    final skills = ((project['skills'] as List?) ?? const [])
        .map((e) => '$e')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${project['reward_tc'] ?? 0} TC',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${msme['business_name'] ?? 'Mitra UMKM'} · #${project['code'] ?? ''}',
                  style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  (project['title'] as String?) ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          if (skills.isNotEmpty) ...[
            const Text(
              'Keahlian Terverifikasi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (s) => Chip(
                      label: Text(s),
                      backgroundColor: const Color(0xFFEFF6FF),
                      labelStyle: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (deliverables.isNotEmpty) ...[
            const Text(
              'Berkas Deliverable Terkirim',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            ...deliverables.map((d) {
              final rawUrl = d['deliverable_url'] as String?;
              final resolved = ApiClient.resolveMediaUrl(rawUrl);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (d['file_name'] as String?) ??
                            (d['deliverable_url'] as String?) ??
                            'Hasil Proyek',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (resolved != null)
                      TextButton(
                        onPressed: () async {
                          final uri = Uri.tryParse(resolved);
                          if (uri != null) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: const Text('Buka'),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          if (clientReview != null) ...[
            const Text(
              'Testimoni Mitra UMKM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Text(
                '"${clientReview['comment'] ?? ''}" - ${clientReview['author_name'] ?? 'UMKM'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkSlate,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          const Text(
            'Beri Ulasan untuk Mitra UMKM',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: hasReviewed
                    ? null
                    : () => setState(() => _userRating = i + 1),
                icon: Icon(
                  i < _userRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.accentAmberGold,
                  size: 32,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: TextField(
              controller: _reviewController,
              enabled: !hasReviewed,
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Bagikan pengalaman kolaborasi dengan mitra UMKM...',
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isSubmitting ? null : _submitAndOpenPortfolio,
              child: Text(
                hasReviewed
                    ? 'Lihat di Portofolio'
                    : 'Selesaikan & Lihat di Portofolio',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
