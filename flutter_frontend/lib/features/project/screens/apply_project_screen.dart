import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';

class ApplyProjectScreen extends StatefulWidget {
  const ApplyProjectScreen({super.key, this.projectId, this.projectApi});

  final int? projectId;
  final ProjectApi? projectApi;

  @override
  State<ApplyProjectScreen> createState() => _ApplyProjectScreenState();
}

class _ApplyProjectScreenState extends State<ApplyProjectScreen> {
  late final ProjectApi _api = widget.projectApi ?? ProjectApi.instance;

  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _cvUrlController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _externalPortfolioController =
      TextEditingController();

  final Set<int> _selectedPortfolioIds = <int>{};
  int _selectedTimelineIndex = 0;
  bool _isCommitted = true;

  String? _cvFileName;
  Uint8List? _cvFileBytes;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  Map<String, dynamic>? _project;
  Map<String, dynamic> _eligibility = const {};
  List<Map<String, dynamic>> _portfolios = const [];

  final List<String> _timelineOptions = const [
    '2 Minggu',
    'Lebih cepat',
    'Fleksibel',
  ];
  final List<String> _dedicationHours = const [
    '10-15 jam / minggu',
    '20-25 jam / minggu',
    'Fleksibel / Sesuai diskusi',
  ];

  @override
  void initState() {
    super.initState();
    _coverLetterController.addListener(() => setState(() {}));
    _loadContext();
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _linkedinController.dispose();
    _cvUrlController.dispose();
    _githubController.dispose();
    _externalPortfolioController.dispose();
    super.dispose();
  }

  String _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
  }

  Future<void> _loadContext() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var targetId = widget.projectId;
      if (targetId == null) {
        final listRes = await _api.explore();
        final rows = (listRes['data'] as List?) ?? const [];
        if (rows.isEmpty) {
          throw const ApiException('Tidak ada proyek terbuka.');
        }
        targetId = ((rows.first as Map<String, dynamic>)['id'] as num).toInt();
      }
      final ctx = await _api.applyContext(targetId);
      if (!mounted) return;
      final portfolios = ((ctx['portfolios'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (portfolios.isNotEmpty) {
        final firstId = (portfolios.first['id'] as num?)?.toInt();
        if (firstId != null) _selectedPortfolioIds.add(firstId);
      }

      final links =
          (ctx['student_profile_links'] as Map<String, dynamic>?) ?? const {};
      final savedLinkedin = (links['linkedin_url'] as String?)?.trim() ?? '';
      final savedGithub = (links['github_url'] as String?)?.trim() ?? '';
      if (_linkedinController.text.isEmpty && savedLinkedin.isNotEmpty) {
        _linkedinController.text = savedLinkedin;
      }
      if (_githubController.text.isEmpty && savedGithub.isNotEmpty) {
        _githubController.text = savedGithub;
      }

      setState(() {
        _project = ctx['project'] as Map<String, dynamic>?;
        _eligibility = (ctx['eligibility'] as Map<String, dynamic>?) ?? const {};
        _portfolios = portfolios;
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
          _error = 'Gagal memuat halaman lamaran.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickCvFile() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih Dokumen CV (PDF/DOC/Gambar)',
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran file CV maksimal 5 MB.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _cvFileName = picked.name;
      _cvFileBytes = bytes;
    });
  }

  Future<void> _submitApplication() async {
    if (_isSubmitting || _project == null) return;

    final hasInternalAccess = _eligibility['can_apply'] == true;
    final canUseExternal =
        _eligibility['can_apply_with_external_credentials'] == true;
    final isBlocked = !hasInternalAccess && !canUseExternal;
    final requiresExternal = !hasInternalAccess && canUseExternal;

    if (isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (_eligibility['reason'] as String?) ??
                'Proyek ini mewajibkan Badge Rekomendasi Kerja dari Mentor.',
          ),
        ),
      );
      return;
    }

    if (!_isCommitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang persetujuan komitmen pengerjaan proyek.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_coverLetterController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan pengantar kesiapan Anda minimal 20 karakter.'),
        ),
      );
      return;
    }

    final linkedin = _normalizeUrl(_linkedinController.text);
    final cvUrl = _normalizeUrl(_cvUrlController.text);
    final github = _normalizeUrl(_githubController.text);
    final externalPortfolio = _normalizeUrl(_externalPortfolioController.text);
    final hasCvFile = _cvFileName != null && _cvFileBytes != null;

    if (requiresExternal) {
      if (linkedin.isEmpty || !_isValidUrl(linkedin)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lampirkan tautan profil LinkedIn yang valid (wajib bagi pelamar tanpa portofolio internal).',
            ),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }
      if (!hasCvFile && (cvUrl.isEmpty || !_isValidUrl(cvUrl))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unggah file CV (PDF) atau tempel tautan CV yang valid (wajib).',
            ),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }
    } else {
      if (linkedin.isNotEmpty && !_isValidUrl(linkedin)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format tautan LinkedIn tidak valid.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }
      if (cvUrl.isNotEmpty && !_isValidUrl(cvUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format tautan CV tidak valid.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }
    }

    if (github.isNotEmpty && !_isValidUrl(github)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format tautan GitHub tidak valid.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final projectId = (_project!['id'] as num).toInt();
    final msme = (_project!['msme'] as Map<String, dynamic>?) ?? const {};
    final umkmName = (msme['business_name'] as String?) ?? 'Mitra UMKM';

    try {
      await _api.apply(
        projectId,
        coverLetter: _coverLetterController.text,
        portfolioIds: _selectedPortfolioIds.toList(),
        portfolioLink: externalPortfolio.isNotEmpty ? externalPortfolio : null,
        linkedinUrl: linkedin.isNotEmpty ? linkedin : null,
        cvUrl: cvUrl.isNotEmpty ? cvUrl : null,
        cvFileName: _cvFileName,
        cvFileBytes: _cvFileBytes,
        githubUrl: github.isNotEmpty ? github : null,
        timelineCommitment: _timelineOptions[_selectedTimelineIndex],
        dedicationHours: _dedicationHours[_selectedTimelineIndex],
        commitmentAccepted: _isCommitted,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 56,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(height: 14),
              const Text(
                'Lamaran Terkirim!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lamaran Anda untuk $umkmName telah diterima sistem dan sedang menunggu kurasi mitra.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondarySlate,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.studentDashboard,
                      (route) => false,
                    );
                  },
                  child: const Text('Buka Dashboard'),
                ),
              ),
            ],
          ),
        ),
      );
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
          'Lamar Proyek UMKM',
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
            : _error != null || _project == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error ?? 'Data lamaran tidak tersedia.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadContext,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              )
            : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final p = _project!;
    final msme = (p['msme'] as Map<String, dynamic>?) ?? const {};
    final rewardTc = (p['reward_tc'] as num?)?.toInt() ?? 0;

    final hasInternalAccess = _eligibility['can_apply'] == true;
    final canUseExternal =
        _eligibility['can_apply_with_external_credentials'] == true;
    final isBlocked = !hasInternalAccess && !canUseExternal;
    final requiresExternal = !hasInternalAccess && canUseExternal;

    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (msme['business_name'] as String?) ?? 'Mitra UMKM',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Text(
                          (p['title'] as String?) ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$rewardTc TC',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),

            if (isBlocked) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (_eligibility['reason'] as String?) ??
                          'Proyek ini mewajibkan Badge Rekomendasi Mentor.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.findMentors),
                      icon: const Icon(Icons.school_rounded, size: 16),
                      label: const Text('Cari Mentor Sekarang'),
                    ),
                  ],
                ),
              ),
            ] else if (requiresExternal) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.badge_rounded,
                      color: AppColors.primaryNavy,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jalur Pelamar Baru (LinkedIn + CV)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Belum punya portofolio proyek di TalentSync? Lampirkan LinkedIn dan CV (wajib), serta GitHub (opsional) agar UMKM bisa menilai kesiapanmu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkSlate,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Surat Pengantar Kesiapan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  '${_coverLetterController.text.length}/500',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: TextField(
                controller: _coverLetterController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText:
                      'Ceritakan rencana pengerjaan, keahlian relevan, dan ketersediaan waktumu...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            ),

            // Kredensial: LinkedIn, CV (Upload/URL), GitHub
            const SizedBox(height: 20),
            const Text(
              'Kredensial & Berkas Pelamar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 10),

            _buildFieldLabel(
              'Tautan Profil LinkedIn',
              required: requiresExternal,
            ),
            const SizedBox(height: 6),
            _buildInputBox(
              controller: _linkedinController,
              icon: Icons.work_outline_rounded,
              hint: 'https://linkedin.com/in/nama-kamu',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 14),
            _buildFieldLabel(
              'Curriculum Vitae (CV)',
              required: requiresExternal,
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _cvFileName != null
                      ? AppColors.primaryNavy
                      : AppColors.borderSlate,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _cvFileName != null
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _cvFileName != null
                              ? Icons.description_rounded
                              : Icons.upload_file_rounded,
                          color: AppColors.primaryNavy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cvFileName ?? 'Unggah File CV (PDF / DOC)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              _cvFileBytes != null
                                  ? '${(_cvFileBytes!.lengthInBytes / 1024).toStringAsFixed(0)} KB · Siap dikirim'
                                  : 'Maks. 5 MB (format PDF sangat disarankan)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_cvFileName != null)
                        IconButton(
                          tooltip: 'Hapus file CV',
                          onPressed: () => setState(() {
                            _cvFileName = null;
                            _cvFileBytes = null;
                          }),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                        )
                      else
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _pickCvFile,
                          child: const Text(
                            'Pilih File',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.borderSlate),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cvUrlController,
                    keyboardType: TextInputType.url,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Atau tempel tautan CV (Google Drive / PDF)...',
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _buildFieldLabel('Tautan GitHub', required: false),
            const SizedBox(height: 6),
            _buildInputBox(
              controller: _githubController,
              icon: Icons.code_rounded,
              hint: 'https://github.com/username (opsional)',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Portofolio Terverifikasi TalentSync',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.findMentors),
                  child: const Text(
                    'Cari Mentor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_portfolios.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: const Text(
                  'Belum ada portofolio proyek internal. UMKM akan meninjau LinkedIn, CV, dan GitHub yang kamu lampirkan di atas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                    height: 1.4,
                  ),
                ),
              )
            else
              ..._portfolios.map((item) {
                final pid = (item['id'] as num).toInt();
                final checked = _selectedPortfolioIds.contains(pid);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    value: checked,
                    onChanged: (_) => setState(() {
                      if (checked) {
                        _selectedPortfolioIds.remove(pid);
                      } else {
                        _selectedPortfolioIds.add(pid);
                      }
                    }),
                    activeColor: AppColors.primaryNavy,
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.borderSlate),
                    ),
                    title: Text(
                      (item['title'] as String?) ?? '',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${item['client_name'] ?? 'UMKM'} · Rating ${item['rating'] ?? 5.0}',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 14),
            _buildFieldLabel('Tautan Karya Tambahan (Figma / Behance / Web)', required: false),
            const SizedBox(height: 6),
            _buildInputBox(
              controller: _externalPortfolioController,
              icon: Icons.link_rounded,
              hint: 'https://figma.com/... atau link karya lainnya (opsional)',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),
            const Text(
              'Komitmen Waktu Pengerjaan',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _timelineOptions.length,
                (i) => ChoiceChip(
                  label: Text('${_timelineOptions[i]} (${_dedicationHours[i]})'),
                  selected: _selectedTimelineIndex == i,
                  selectedColor: AppColors.primaryNavy,
                  labelStyle: TextStyle(
                    color: _selectedTimelineIndex == i
                        ? Colors.white
                        : AppColors.darkSlate,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _selectedTimelineIndex = i),
                ),
              ),
            ),

            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isCommitted,
              onChanged: (v) => setState(() => _isCommitted = v ?? false),
              activeColor: AppColors.primaryNavy,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Saya berkomitmen menyelesaikan seluruh milestone sesuai tenggat dan standar kualitas Smart Escrow.',
                style: TextStyle(fontSize: 12.5, color: AppColors.darkSlate),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: isBlocked
                      ? AppColors.secondarySlate
                      : AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (isBlocked || _isSubmitting)
                    ? null
                    : _submitApplication,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Kirim Lamaran ($rewardTc TC)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool required}) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: required ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            required ? 'Wajib' : 'Opsional',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: required
                  ? const Color(0xFFDC2626)
                  : AppColors.secondarySlate,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondarySlate),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 13, color: AppColors.darkSlate),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
