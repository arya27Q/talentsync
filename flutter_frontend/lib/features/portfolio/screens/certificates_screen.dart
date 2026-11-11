import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/portfolio/data/portfolio_api.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key, this.portfolioApi});

  final PortfolioApi? portfolioApi;

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late final PortfolioApi _api = widget.portfolioApi ?? PortfolioApi.instance;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _certificates = const [];
  List<Map<String, dynamic>> _lockedMilestones = const [];

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
      final res = await _api.certificates();
      if (!mounted) return;
      setState(() {
        _certificates = (res['certificates'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        _lockedMilestones = (res['locked_milestones'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
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
          _error = 'Gagal memuat daftar sertifikat.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCertificate(Map<String, dynamic> cert) async {
    final fileUrl = cert['file_url'] as String?;
    if (fileUrl != null && fileUrl.trim().isNotEmpty) {
      final uri = Uri.tryParse(fileUrl.trim());
      if (uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }

    final sourceType = (cert['source_type'] as String?) ?? '';
    final refId = (cert['reference_id'] as num?)?.toInt();
    if (!mounted) return;
    if (sourceType.startsWith('mentoring') && refId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.mentoringResult,
        arguments: MentoringEnrollmentArgs(enrollmentId: refId),
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.portfolio);
  }

  @override
  Widget build(BuildContext context) {
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
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                        children: [
                          if (_certificates.isEmpty && _lockedMilestones.isEmpty)
                            _buildEmpty()
                          else ...[
                            ..._certificates.map(_buildCertCard),
                            if (_lockedMilestones.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Target Lencana Berikutnya',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._lockedMilestones.map(_buildLockedCard),
                            ],
                          ],
                        ],
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
            child: Text(
              'Sertifikat & Rekomendasi',
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

  Widget _buildCertCard(Map<String, dynamic> cert) {
    final category = (cert['category_label'] as String?) ?? 'TalentSync';
    final isEndorse = category.toLowerCase().contains('endorse');

    return InkWell(
      onTap: () => _openCertificate(cert),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEndorse
                    ? const Color(0xFFFEF3C7)
                    : AppColors.lightBlueSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isEndorse
                    ? Icons.military_tech_rounded
                    : Icons.storefront_rounded,
                color: isEndorse
                    ? AppColors.accentAmberDeep
                    : AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isEndorse
                          ? const Color(0xFFFEF3C7)
                          : AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isEndorse
                            ? AppColors.accentAmberDeep
                            : AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (cert['title'] as String?) ?? 'Sertifikat TalentSync',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cert['issuer_name'] ?? 'TalentSync'} | ${cert['certificate_code'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondarySlate,
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
    );
  }

  Widget _buildLockedCard(Map<String, dynamic> item) {
    final current = (item['current_count'] as num?)?.toInt() ?? 0;
    final requiredCount = (item['required_count'] as num?)?.toInt() ?? 5;
    final ratio = requiredCount > 0
        ? (current / requiredCount).clamp(0.0, 1.0)
        : 0.0;

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.canvasWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['title'] as String?) ?? 'Target Pencapaian',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    Text(
                      (item['subtitle'] as String?) ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            size: 46,
            color: AppColors.secondarySlate,
          ),
          const SizedBox(height: 10),
          const Text(
            'Belum Ada Sertifikat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selesaikan proyek UMKM atau sesi bimbingan mentor untuk memperoleh sertifikat terverifikasi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 14),
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
                  Navigator.pushNamed(context, AppRoutes.exploreProjects),
              child: const Text('Cari Proyek UMKM'),
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
              Icons.workspace_premium_rounded,
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
}
