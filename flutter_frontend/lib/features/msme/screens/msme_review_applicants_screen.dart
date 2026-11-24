import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/screens/msme_applicant_profile_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';
import 'package:flutter_frontend/features/msme/widgets/msme_reject_mentor_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class MsmeReviewApplicantsScreen extends StatefulWidget {
  const MsmeReviewApplicantsScreen({
    super.key,
    this.projectId,
    this.projectTitle,
    this.msmeApi,
  });

  final int? projectId;
  final String? projectTitle;
  final MsmeApi? msmeApi;

  @override
  State<MsmeReviewApplicantsScreen> createState() =>
      _MsmeReviewApplicantsScreenState();
}

class _MsmeReviewApplicantsScreenState
    extends State<MsmeReviewApplicantsScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;
  int _selectedFilterIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _applicants = [];

  final List<String> _filters = [
    'Semua',
    'Diterima',
    'Ditolak',
    'Menunggu',
    'Rekomendasi Mentor',
    'Penilaian 4.8+',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() => _isLoading = true);
    try {
      final filterKey = switch (_selectedFilterIndex) {
        1 => 'accepted',
        2 => 'rejected',
        3 => 'pending',
        4 => 'recommended',
        5 => 'top_rated',
        _ => 'all',
      };
      final data = await _msmeApi.getApplicants(
        projectId: widget.projectId,
        filter: filterKey,
      );
      if (mounted) {
        setState(() {
          _applicants = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openExternalUrl(String rawUrl, String label) async {
    final resolved = ApiClient.resolveMediaUrl(rawUrl) ?? rawUrl.trim();
    final uri = Uri.tryParse(resolved);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka tautan $label.')),
      );
    }
  }

  Future<void> _onRejectAndRecommendMentor(
    Map<String, dynamic> applicant,
  ) async {
    final name = (applicant['name'] as String?) ?? 'Mahasiswa Pelamar';
    final applicationId = (applicant['id'] as num?)?.toInt();
    if (applicationId == null) return;

    final result = await MsmeRejectMentorDialog.show(
      context,
      studentName: name,
      msmeApi: _msmeApi,
    );
    if (result == null || !mounted) return;

    try {
      await _msmeApi.rejectToMentor(
        applicationId,
        feedback: result.feedback,
        recommendedMentorId: result.recommendedMentorId,
        allowCatalogChoice: result.allowCatalogChoice,
      );
      if (!mounted) return;
      final mentorInfo = result.recommendedMentorName != null
          ? ' bersama Mentor ${result.recommendedMentorName}'
          : '';
      await AppStatusDialog.showSuccess(
        context,
        title: 'Arahan Terkirim!',
        message:
            'Saran bimbingan mentor$mentorInfo telah dikirimkan secara edukatif ke $name.',
        buttonText: 'Tutup',
      );
      _loadApplicants();
    } catch (e) {
      if (!mounted) return;
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Mengirimkan Arahan',
        message: '$e',
      );
    }
  }

  Future<void> _onAccept(Map<String, dynamic> applicant) async {
    final name = (applicant['name'] as String?) ?? 'Mahasiswa Pelamar';
    final projectTitle =
        (applicant['project_title'] as String?) ?? 'Proyek Tugas';
    final rewardTc = applicant['project_reward_tc'] ?? 0;
    final applicationId = applicant['id'] as int?;
    if (applicationId == null) return;

    final confirmed = await AppStatusDialog.show(
      context,
      type: AppStatusDialogType.info,
      title: 'Terima & Kunci Escrow',
      message:
          'Apakah Anda yakin menerima $name untuk proyek "$projectTitle"?\n\nDana sebesar $rewardTc TC akan dikunci aman di Smart Escrow dan 3 tugas awal di Workspace Kanban akan otomatis dibuat untuk mahasiswa.',
      primaryButtonText: 'Ya, Terima & Kunci',
      secondaryButtonText: 'Batal',
    );

    if (confirmed != true || !mounted) return;

    try {
      final response = await _msmeApi.acceptApplicant(applicationId);
      if (!mounted) return;

      final message =
          (response['message'] as String?) ??
          'Pelamar $name berhasil diterima. Proyek telah berpindah ke tahap Berjalan.';

      await AppStatusDialog.showSuccess(
        context,
        title: 'Lamaran Berhasil Diterima!',
        message: message,
        buttonText: 'Lihat Daftar',
      );

      _loadApplicants();
    } catch (e) {
      if (!mounted) return;
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Menerima Pelamar',
        message: 'Terjadi kendala saat memproses: $e',
      );
    }
  }

  Future<void> _onViewProfile(Map<String, dynamic> applicant) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MsmeApplicantProfileScreen(
          applicationId: applicant['id'] as int?,
          applicantData: applicant,
          applicantName: (applicant['name'] as String?) ?? 'Arya Pratama',
          projectName:
              (applicant['project_title'] as String?) ??
              widget.projectTitle ??
              'Tugas Proyek',
        ),
      ),
    );
    if (result == true) {
      _loadApplicants();
    }
  }

  void _onChat(Map<String, dynamic> applicant) {
    final name = (applicant['name'] as String?) ?? 'Pelamar';
    final projectId =
        (applicant['project_id'] as num?)?.toInt() ?? widget.projectId;
    final studentId = (applicant['student_id'] as num?)?.toInt();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MsmeChatScreen(
          projectId: projectId,
          studentId: studentId,
          studentName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.projectTitle ?? 'Semua Tugas Proyek';

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A)
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Kembali',
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tinjau Pelamar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondarySlate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A)
                              .withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Lihat Detail Tugas',
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.projectDetail,
                          arguments: ProjectRouteArgs(
                            projectId: widget.projectId,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryNavy,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final bool isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                        _loadApplicants();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryNavy
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryNavy
                                : AppColors.borderSlate,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryNavy.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkSlate,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadApplicants,
                color: AppColors.primaryNavy,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryNavy,
                        ),
                      )
                    : _applicants.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                        itemCount: _applicants.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final applicant = _applicants[index];
                          return _buildApplicantCard(applicant);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: AppColors.secondarySlate,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belum Ada Pelamar',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Belum ada mahasiswa yang melamar tugas ini. Tunggu beberapa saat atau periksa kembali detail tugas yang telah dipublikasikan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.projectDetail,
                arguments: ProjectRouteArgs(projectId: widget.projectId),
              );
            },
            icon: const Icon(
              Icons.visibility_rounded,
              size: 16,
              color: AppColors.primaryNavy,
            ),
            label: const Text(
              'Lihat Detail Tugas Ini',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryNavy, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    final name = (applicant['name'] as String?) ?? 'Pelamar';
    final major = (applicant['major'] as String?) ?? 'S1 Sistem Informasi';
    final university =
        (applicant['university'] as String?) ?? 'Universitas Negeri Surabaya';
    final rawRating = (applicant['rating'] as num?)?.toDouble() ?? 0.0;
    final rating = rawRating > 0 ? rawRating.toStringAsFixed(1) : 'Baru';
    final completedCount =
        (applicant['completed_projects_count'] as num?)?.toInt() ?? 0;
    final hasMentorEndorsement =
        (applicant['has_mentor_endorsement'] as bool?) ?? false;
    final mentorName =
        (applicant['mentor_name'] as String?) ?? 'Mentor TalentSync';
    final coverLetter =
        (applicant['cover_letter'] as String?) ??
        'Siap berkontribusi maksimal untuk kebutuhan digitalisasi toko.';
    final timelineCommitment =
        (applicant['timeline_commitment'] as String?) ?? '14 Hari Pengerjaan';
    final dedicationHours =
        (applicant['dedication_hours'] as String?) ?? '10-15 jam/minggu';
    final skills =
        (applicant['skills'] as List?)
            ?.map((e) => e.toString())
            .take(4)
            .toList() ??
        const <String>[];
    final linkedinUrl = (applicant['linkedin_url'] as String?)?.trim();
    final cvUrl = (applicant['cv_url'] as String?)?.trim();
    final cvFileName = (applicant['cv_file_name'] as String?)?.trim();
    final githubUrl = (applicant['github_url'] as String?)?.trim();
    final hasCredentials =
        (linkedinUrl != null && linkedinUrl.isNotEmpty) ||
        (cvUrl != null && cvUrl.isNotEmpty) ||
        (githubUrl != null && githubUrl.isNotEmpty);
    final status = ((applicant['status'] as String?) ?? 'pending').toLowerCase();
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';
    final isRejected = status == 'rejected';
    final rejectionFeedback = (applicant['rejection_feedback'] as String?)?.trim();
    final recommendedMentor =
        applicant['recommended_mentor'] as Map<String, dynamic>?;
    final recommendedMentorName =
        (recommendedMentor?['name'] as String?)?.trim();

    // Inisial avatar
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'M');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mentor recommendation top strip
          if (hasMentorEndorsement)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: Color(0xFFFDE68A))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Direkomendasikan oleh $mentorName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '95% cocok',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Candidate row: Avatar, Info, Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: hasMentorEndorsement
                            ? AppColors.primaryNavy
                            : const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$major · $completedCount proyek selesai',
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
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Badges row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isAccepted || isRejected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isAccepted
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAccepted
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAccepted
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: isAccepted
                                  ? const Color(0xFF047857)
                                  : const Color(0xFFB91C1C),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAccepted ? 'Diterima' : 'Ditolak',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isAccepted
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Verified Campus · $university',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasMentorEndorsement)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.military_tech_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Endorse Mentor',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Skills chips
                if (skills.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Kredensial pelamar (LinkedIn, CV, GitHub)
                if (hasCredentials) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (cvUrl != null && cvUrl.isNotEmpty)
                        _buildCredentialChip(
                          icon: Icons.description_rounded,
                          label: cvFileName != null && cvFileName.isNotEmpty
                              ? 'CV · $cvFileName'
                              : 'Lihat CV',
                          color: AppColors.primaryNavy,
                          bgColor: const Color(0xFFEFF6FF),
                          onTap: () => _openExternalUrl(cvUrl, 'CV'),
                        ),
                      if (linkedinUrl != null && linkedinUrl.isNotEmpty)
                        _buildCredentialChip(
                          icon: Icons.work_outline_rounded,
                          label: 'LinkedIn',
                          color: const Color(0xFF0A66C2),
                          bgColor: const Color(0xFFF0F9FF),
                          onTap: () =>
                              _openExternalUrl(linkedinUrl, 'LinkedIn'),
                        ),
                      if (githubUrl != null && githubUrl.isNotEmpty)
                        _buildCredentialChip(
                          icon: Icons.code_rounded,
                          label: 'GitHub',
                          color: AppColors.darkSlate,
                          bgColor: const Color(0xFFF1F5F9),
                          onTap: () => _openExternalUrl(githubUrl, 'GitHub'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Cover letter
                Text(
                  coverLetter,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 10),

                // Commitment info
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: AppColors.secondarySlate,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Komitmen: $timelineCommitment · $dedicationHours',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondarySlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status banner for already-reviewed applicants (accepted / rejected)
                if (isRejected) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 15,
                              color: Color(0xFFB91C1C),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                recommendedMentorName != null &&
                                        recommendedMentorName.isNotEmpty
                                    ? 'Ditolak · Diarahkan ke Mentor $recommendedMentorName'
                                    : 'Ditolak · Diarahkan ke Katalog Mentor',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (rejectionFeedback != null &&
                            rejectionFeedback.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            rejectionFeedback,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF7F1D1D),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (isAccepted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Color(0xFF047857),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pelamar diterima · Smart Escrow & Workspace Kanban aktif',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action buttons row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: isRejected
                            ? 'Lihat arsip obrolan'
                            : 'Kirim pesan ke pelamar',
                        onPressed: () => _onChat(applicant),
                        icon: const Icon(
                          Icons.chat_bubble_rounded,
                          color: AppColors.darkSlate,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onViewProfile(applicant),
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Text(
                                'Lihat Profil',
                                style: TextStyle(
                                  color: AppColors.darkSlate,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryNavy.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onAccept(applicant),
                              borderRadius: BorderRadius.circular(14),
                              child: const Center(
                                child: Text(
                                  'Terima',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isAccepted
                                ? AppColors.primaryNavy
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onChat(applicant),
                              borderRadius: BorderRadius.circular(14),
                              child: Center(
                                child: Text(
                                  isAccepted
                                      ? 'Buka Obrolan'
                                      : 'Lihat Arsip Chat',
                                  style: TextStyle(
                                    color: isAccepted
                                        ? Colors.white
                                        : AppColors.darkSlate,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Tombol edukatif: Tolak & Arahkan Bimbingan Mentor (hanya tampil saat pending)
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: const BorderSide(color: Color(0xFFFDE68A)),
                          backgroundColor: const Color(0xFFFFFBEB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.school_rounded,
                          color: Color(0xFFD97706),
                          size: 16,
                        ),
                        label: const Text(
                          'Tolak & Arahkan Bimbingan Mentor',
                          style: TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () =>
                            _onRejectAndRecommendMentor(applicant),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}
