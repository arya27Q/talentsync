import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/portfolio/data/portfolio_api.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseStudyScreen extends StatefulWidget {
  const CaseStudyScreen({super.key, this.portfolioId, this.portfolioApi});

  final int? portfolioId;
  final PortfolioApi? portfolioApi;

  @override
  State<CaseStudyScreen> createState() => _CaseStudyScreenState();
}

class _CaseStudyScreenState extends State<CaseStudyScreen> {
  late final PortfolioApi _api = widget.portfolioApi ?? PortfolioApi.instance;

  bool _argsParsed = false;
  int? _routePortfolioId;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _study = const {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CaseStudyArgs) {
      _routePortfolioId = args.portfolioId;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.portfolioId ?? _routePortfolioId;
      if (targetId == null) {
        final portfolio = await _api.portfolio();
        final list = (portfolio['verified_projects'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        if (list.isEmpty) {
          throw const ApiException('Belum ada studi kasus portofolio.');
        }
        targetId = (list.first['id'] as num?)?.toInt();
      }
      if (targetId == null) {
        throw const ApiException('Studi kasus tidak ditemukan.');
      }
      final detail = await _api.caseStudy(targetId);
      if (!mounted) return;
      setState(() {
        _study = detail;
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
          _error = 'Gagal memuat detail studi kasus.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportOrOpenLink() async {
    final caseUrl = _study['case_study_url'] as String?;
    if (caseUrl != null && caseUrl.trim().isNotEmpty) {
      final uri = Uri.tryParse(caseUrl.trim());
      if (uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }
    final fallbackShare =
        'Studi Kasus: ${_study['title'] ?? 'Portofolio'} - ${_study['client_name'] ?? 'UMKM'}';
    await Clipboard.setData(ClipboardData(text: fallbackShare));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ringkasan tautan studi kasus disalin ke clipboard.'),
        backgroundColor: AppColors.primaryNavy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tags = (_study['tags'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    final highlights = (_study['deliverable_highlights'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    final imageUrl = ApiClient.resolveMediaUrl(
      _study['preview_image_url'] as String?,
    );

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              imageUrl,
                              height: 170,
                              width: double.infinity,
                              cacheWidth: 720,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Text(
                          (_study['title'] as String?) ?? 'Studi Kasus Proyek',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_study['client_name'] ?? 'UMKM'} | ${_study['role_title'] ?? 'Kontributor'}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
                                .map(
                                  (t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightBlueSurface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _metricBox(
                              Icons.schedule_rounded,
                              'Durasi',
                              '${_study['duration_label'] ?? '-'}',
                            ),
                            const SizedBox(width: 8),
                            _metricBox(
                              Icons.toll_rounded,
                              'Imbalan',
                              '${_study['reward_tc'] ?? 0} TC',
                            ),
                            const SizedBox(width: 8),
                            _metricBox(
                              Icons.star_rounded,
                              'Rating',
                              '${_study['rating'] ?? 5.0}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (((_study['problem_summary'] as String?) ?? '')
                            .isNotEmpty)
                          _sectionCard(
                            Icons.flag_rounded,
                            'Tantangan Mitra UMKM',
                            _study['problem_summary'] as String,
                          ),
                        if (((_study['solution_summary'] as String?) ?? '')
                            .isNotEmpty)
                          _sectionCard(
                            Icons.lightbulb_rounded,
                            'Solusi & Implementasi',
                            _study['solution_summary'] as String,
                          ),
                        if (((_study['result_summary'] as String?) ?? '')
                            .isNotEmpty)
                          _sectionCard(
                            Icons.trending_up_rounded,
                            'Dampak & Hasil',
                            _study['result_summary'] as String,
                          ),
                        if (highlights.isNotEmpty)
                          _highlightsCard(highlights),
                        if (((_study['testimonial_quote'] as String?) ?? '')
                            .isNotEmpty)
                          _testimonialCard(
                            _study['testimonial_quote'] as String,
                            (_study['testimonial_author'] as String?) ??
                                'Mitra UMKM',
                          ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _exportOrOpenLink,
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Bagikan / Buka Tautan Studi Kasus',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
            child: Text(
              'Detail Studi Kasus',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryNavy),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(IconData icon, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryNavy),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightsCard(List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deliverable Utama',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
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
        ],
      ),
    );
  }

  Widget _testimonialCard(String quote, String author) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlueSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: const TextStyle(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              color: AppColors.darkSlate,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ulasan dari $author',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
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
              Icons.article_outlined,
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
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _load,
                  child: const Text('Coba Lagi'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.exploreProjects),
                  child: const Text('Eksplorasi Proyek'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
