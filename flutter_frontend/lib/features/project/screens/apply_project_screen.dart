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
  final TextEditingController _externalPortfolioController =
      TextEditingController();

  final Set<int> _selectedPortfolioIds = <int>{};
  int _selectedTimelineIndex = 0;
  bool _isCommitted = true;

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
    _externalPortfolioController.dispose();
    super.dispose();
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

  Future<void> _submitApplication() async {
    if (_isSubmitting || _project == null) return;
    if (_eligibility['can_apply'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (_eligibility['reason'] as String?) ??
                'Wajib memiliki Portofolio Terverifikasi atau Badge Mentor.',
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

    setState(() => _isSubmitting = true);
    final projectId = (_project!['id'] as num).toInt();
    final msme = (_project!['msme'] as Map<String, dynamic>?) ?? const {};
    final umkmName = (msme['business_name'] as String?) ?? 'Mitra UMKM';

    try {
      await _api.apply(
        projectId,
        coverLetter: _coverLetterController.text,
        portfolioIds: _selectedPortfolioIds.toList(),
        portfolioLink: _externalPortfolioController.text,
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
    final canApply = _eligibility['can_apply'] != false;

    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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

            if (!canApply) ...[
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
                          'Diperlukan Portofolio Terverifikasi atau Badge Mentor.',
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: TextField(
                controller: _coverLetterController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  hintText:
                      'Ceritakan pengalaman relevan, rencana pengerjaan, dan ketersediaan waktumu...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lampirkan Portofolio Terverifikasi',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
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
                  'Belum ada portofolio terverifikasi. Badge Rekomendasi Mentor akan dilampirkan otomatis jika tersedia.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
              )
            else
              ..._portfolios.map((item) {
                final pid = (item['id'] as num).toInt();
                final checked = _selectedPortfolioIds.contains(pid);
                return CheckboxListTile(
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
                );
              }),

            const SizedBox(height: 16),
            const Text(
              'Tautan Portofolio Tambahan (Opsional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: TextField(
                controller: _externalPortfolioController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'https://github.com/username atau Figma link',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
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
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      canApply ? AppColors.primaryNavy : AppColors.secondarySlate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (!canApply || _isSubmitting)
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
}
