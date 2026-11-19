import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';

class MsmeApplicantProfileScreen extends StatefulWidget {
  const MsmeApplicantProfileScreen({
    super.key,
    this.applicationId,
    this.applicantData,
    this.applicantName = 'Arya Pratama',
    this.projectName = 'Aplikasi Menu & Pre-order Kopi',
    this.msmeApi,
  });

  final int? applicationId;
  final Map<String, dynamic>? applicantData;
  final String applicantName;
  final String projectName;
  final MsmeApi? msmeApi;

  @override
  State<MsmeApplicantProfileScreen> createState() =>
      _MsmeApplicantProfileScreenState();
}

class _MsmeApplicantProfileScreenState
    extends State<MsmeApplicantProfileScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;
  int _selectedCertTab = 0; // 0: Semua, 1: Mentor TalentSync, 2: Eksternal
  bool _isLoadingDetail = false;
  Map<String, dynamic>? _detail;

  final List<String> _certTabs = ['Semua', 'Mentor TalentSync', 'Eksternal'];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final appId = widget.applicationId ??
        (widget.applicantData?['id'] as int?) ??
        (widget.applicantData?['application_id'] as int?);
    if (appId == null) return;

    setState(() => _isLoadingDetail = true);
    try {
      final data = await _msmeApi.getApplicantDetail(appId);
      if (mounted) {
        setState(() {
          _detail = data;
          _isLoadingDetail = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDetail = false);
      }
    }
  }

  int? get _resolvedApplicationId =>
      widget.applicationId ??
      (widget.applicantData?['id'] as int?) ??
      (widget.applicantData?['application_id'] as int?) ??
      (_detail?['application_id'] as int?) ??
      (_detail?['id'] as int?);

  Future<void> _onAccept() async {
    final appId = _resolvedApplicationId;
    final name = (_detail?['name'] as String?) ??
        (widget.applicantData?['name'] as String?) ??
        widget.applicantName;
    final projectTitle = (_detail?['project_title'] as String?) ??
        (widget.applicantData?['project_title'] as String?) ??
        widget.projectName;
    final rewardTc = (_detail?['project_reward_tc'] as num?)?.toInt() ??
        (widget.applicantData?['project_reward_tc'] as num?)?.toInt() ??
        100;

    final confirmed = await AppStatusDialog.show(
      context,
      type: AppStatusDialogType.info,
      title: 'Terima Pelamar & Kunci Escrow',
      message:
          'Apakah Anda yakin menerima $name untuk mengerjakan proyek "$projectTitle"?\n\nImbalan sebesar $rewardTc TC akan dikunci aman di Smart Escrow dan 3 tugas awal di Workspace Kanban akan disiapkan untuk mahasiswa.',
      primaryButtonText: 'Ya, Terima & Kunci',
      secondaryButtonText: 'Batal',
    );

    if (confirmed != true || !mounted) return;

    if (appId == null) {
      Navigator.pop(context, true);
      return;
    }

    try {
      final response = await _msmeApi.acceptApplicant(appId);
      if (!mounted) return;

      final message = (response['message'] as String?) ??
          'Selamat! Kolaborasi dengan $name telah aktif. Proyek berpindah ke tahap Berjalan.';

      await AppStatusDialog.showSuccess(
        context,
        title: 'Lamaran Berhasil Diterima!',
        message: message,
        buttonText: 'Kembali ke Daftar',
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Menerima Pelamar',
        message: 'Terjadi kendala saat memproses: $e',
      );
    }
  }

  void _onReject() {
    final appId = _resolvedApplicationId;
    final name = (_detail?['name'] as String?) ??
        (widget.applicantData?['name'] as String?) ??
        widget.applicantName;

    final textController = TextEditingController(
      text:
          'Mitra menyarankan untuk mengikuti bimbingan mentor terlebih dahulu agar portofolio dan kesiapan kerja semakin optimal.',
    );

    showDialog<void>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.55),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tolak & Arahkan Mentor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beri arahan bimbingan mentor ramah untuk $name agar dapat meningkatkan keahlian sebelum melamar kembali:',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.secondarySlate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: AppColors.darkSlate),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSlate),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSlate),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryNavy),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondarySlate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (appId == null) {
                Navigator.pop(context, true);
                return;
              }
              final feedback = textController.text.trim();
              try {
                await _msmeApi.rejectToMentor(appId, feedback: feedback);
                if (!mounted) return;
                await AppStatusDialog.showSuccess(
                  context,
                  title: 'Arahan Terkirim!',
                  message:
                      'Saran bimbingan mentor telah dikirimkan secara edukatif ke $name.',
                  buttonText: 'Tutup',
                );
                if (mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (!mounted) return;
                await AppStatusDialog.showError(
                  context,
                  title: 'Gagal Mengirimkan Arahan',
                  message: '$e',
                );
              }
            },
            child: const Text(
              'Kirim Arahan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onChat() {
    final name = (_detail?['name'] as String?) ??
        (widget.applicantData?['name'] as String?) ??
        widget.applicantName;
    final projectId = (_detail?['project_id'] as num?)?.toInt() ??
        (widget.applicantData?['project_id'] as num?)?.toInt();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MsmeChatScreen(
          projectId: projectId,
          studentName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (_detail?['name'] as String?) ??
        (widget.applicantData?['name'] as String?) ??
        widget.applicantName;
    final projectName = (_detail?['project_title'] as String?) ??
        (widget.applicantData?['project_title'] as String?) ??
        widget.projectName;
    final university = (_detail?['university'] as String?) ??
        (widget.applicantData?['university'] as String?) ??
        'Universitas Negeri Surabaya';
    final major = (_detail?['major'] as String?) ??
        (widget.applicantData?['major'] as String?) ??
        'S1 Sistem Informasi';
    final rating =
        ((_detail?['rating'] ?? widget.applicantData?['rating'] ?? 4.9) as num)
            .toStringAsFixed(1);
    final completedCount = _detail?['completed_projects_count'] ??
        widget.applicantData?['completed_projects_count'] ??
        3;
    final hasMentorEndorsement = (_detail?['has_mentor_endorsement'] ??
        widget.applicantData?['has_mentor_endorsement'] ??
        false) as bool;
    final mentorName = (_detail?['mentor_name'] as String?) ??
        (widget.applicantData?['mentor_name'] as String?) ??
        'Dimas Prasetyo (Senior Engineer)';
    final coverLetter = (_detail?['cover_letter'] as String?) ??
        (widget.applicantData?['cover_letter'] as String?) ??
        'Yth. Mitra UMKM, saya siap berkontribusi secara profesional untuk proyek ini.';
    final timeline = (_detail?['timeline_commitment'] as String?) ??
        (widget.applicantData?['timeline_commitment'] as String?) ??
        '1 Bulan';
    final dedication = (_detail?['dedication_hours'] as String?) ??
        (widget.applicantData?['dedication_hours'] as String?) ??
        '10-15 jam/minggu';

    final skills = (_detail?['skills'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        (widget.applicantData?['skills'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        ['Flutter', 'Laravel', 'UI/UX'];

    final rawPortfolios = _detail?['portfolios'];
    final portfolios = (rawPortfolios is List)
        ? rawPortfolios.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    final rawCerts = _detail?['certificates'];
    final certificates = (rawCerts is List)
        ? rawCerts.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    // Inisial
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'M');

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Page Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
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
                              'Profil Pelamar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkSlate,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Melamar: $projectName',
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
                          tooltip: 'Pesan',
                          padding: EdgeInsets.zero,
                          onPressed: _onChat,
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.darkSlate,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_isLoadingDetail)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(
                        color: AppColors.primaryNavy,
                        backgroundColor: Color(0xFFE2E8F0),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Card 1: Applicant Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: hasMentorEndorsement
                                    ? AppColors.primaryNavy
                                    : const Color(0xFF0D9488),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$major · $university',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _buildPillBadge(
                                        icon: Icons.check_circle_rounded,
                                        label: 'KTM terverifikasi',
                                        bgColor: const Color(0xFFF0FDF4),
                                        textColor: const Color(0xFF047857),
                                        borderColor: const Color(0xFFBBF7D0),
                                      ),
                                      if (hasMentorEndorsement)
                                        _buildPillBadge(
                                          icon: Icons.military_tech_rounded,
                                          label: 'Endorse Mentor',
                                          bgColor: const Color(0xFFFFFBEB),
                                          textColor: const Color(0xFFB45309),
                                          borderColor: const Color(0xFFFDE68A),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 4 Metric Boxes
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              _buildProfileMetric(rating, 'Penilaian'),
                              _buildMetricDivider(),
                              _buildProfileMetric(
                                '$completedCount',
                                'Proyek',
                              ),
                              _buildMetricDivider(),
                              _buildProfileMetric('96', 'Jam'),
                              _buildMetricDivider(),
                              _buildProfileMetric(
                                '${certificates.isNotEmpty ? certificates.length : 4}',
                                'Sertifikat',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section 2: Rekomendasi mentor
                  if (hasMentorEndorsement) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Rekomendasi mentor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.03),
                            blurRadius: 10,
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
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.military_tech_rounded,
                                  color: Color(0xFFD97706),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mentorName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Mentor Ekosistem TalentSync',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: const Text(
                                  '95% cocok',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              '"$name telah menyelesaikan bimbingan arsitektur desain dan implementasi nyata untuk mitra UMKM. Kemampuan komunikasi dan kedisiplinan kerja sangat direkomendasikan."',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.adjust_rounded,
                                color: AppColors.primaryNavy,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Khusus untuk proyek $projectName',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Section 3: Hasil proyek nyata / Portofolio
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Hasil proyek nyata',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${portfolios.isNotEmpty ? portfolios.length : 3} terverifikasi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Carousel of Real Projects
                  SizedBox(
                    height: 260,
                    child: portfolios.isNotEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: portfolios.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final p = portfolios[index];
                              final pTitle = (p['title'] as String?) ??
                                  'Portofolio Digital';
                              final pClient = (p['organization_or_partner'] as String?) ??
                                  'Mitra TalentSync';
                              final isVerified =
                                  (p['is_verified'] as bool?) ?? true;
                              final quote = (p['short_summary'] as String?) ??
                                  (p['description'] as String?) ??
                                  '"Proyek selesai tepat waktu dengan hasil memuaskan."';
                              final pTech = (p['tools_or_tech'] as String?) ??
                                  'Figma · Flutter';
                              final pRating =
                                  ((p['rating'] as num?) ?? 5.0).toStringAsFixed(1);
                              final pImage = (p['image_url'] as String?) ??
                                  'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=300&q=80';

                              return _buildRealProjectCard(
                                title: pTitle,
                                client: pClient,
                                verifiedBadge: isVerified
                                    ? 'Diverifikasi UMKM'
                                    : 'Portofolio',
                                isMentorVerified: hasMentorEndorsement,
                                quote: quote,
                                tech: pTech,
                                rating: pRating,
                                imageUrl: pImage,
                              );
                            },
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildRealProjectCard(
                                title: 'Modul offline-sync aplikasi kasir',
                                client: 'Koperasi Pasar Genteng',
                                verifiedBadge: 'Diverifikasi Mentor',
                                isMentorVerified: true,
                                quote:
                                    '"Dipakai 40 pedagang setiap hari tanpa kendala."',
                                tech: 'Flutter · SQLite',
                                rating: '5.0',
                                imageUrl:
                                    'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=300&q=80',
                              ),
                              const SizedBox(width: 14),
                              _buildRealProjectCard(
                                title: 'Sistem reservasi meja',
                                client: 'Warung Pak Gito',
                                verifiedBadge: 'Diverifikasi UMKM',
                                isMentorVerified: false,
                                quote:
                                    '"Pesanan ganda hilang, karyawan mudah memakainya."',
                                tech: 'Laravel · MySQL',
                                rating: '5.0',
                                imageUrl:
                                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80',
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Section 4: Sertifikat
                  const Text(
                    'Sertifikat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_certTabs.length, (index) {
                        final bool isSelected = _selectedCertTab == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCertTab = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : AppColors.borderSlate,
                                ),
                              ),
                              child: Text(
                                _certTabs[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkSlate,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Certificate Tiles List
                  if (certificates.isNotEmpty)
                    ...certificates.map((cert) {
                      final cTitle = (cert['title'] as String?) ??
                          'Sertifikat Kelulusan Proyek';
                      final cIssuer = (cert['issuer'] as String?) ??
                          'TalentSync Academy';
                      final cTag = (cert['category'] as String?) ??
                          'Terverifikasi';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildCertificateTile(
                          title: cTitle,
                          issuer: cIssuer,
                          tag: cTag,
                          isMentor: hasMentorEndorsement,
                        ),
                      );
                    })
                  else ...[
                    _buildCertificateTile(
                      title: 'Arsitektur Aplikasi Mobile Modern',
                      issuer: 'Mentor Dimas Prasetyo · TalentSync',
                      tag: 'Mentor Verified',
                      isMentor: true,
                    ),
                    const SizedBox(height: 10),
                    _buildCertificateTile(
                      title: 'Desain Sistem & UI/UX Standar Industri',
                      issuer: 'Google UX Certificate',
                      tag: 'Eksternal',
                      isMentor: false,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Section 5: Keahlian & Bukti
                  const Text(
                    'Keahlian & bukti',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < skills.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _buildSkillRow(
                            skills[i],
                            i == 0 && hasMentorEndorsement
                                ? 'Endorse mentor · 3 proyek'
                                : 'Terverifikasi portofolio',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 6: Pesan lamaran & Komitmen
                  const Text(
                    'Pesan lamaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coverLetter,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.secondarySlate,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Komitmen: $timeline · $dedication',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondarySlate,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Fixed Action Bar: Tolak & Accept & Collaborate
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderSlate.withValues(alpha: 0.8),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onReject,
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Text(
                                'Tolak & Arahkan',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNavy.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onAccept,
                            borderRadius: BorderRadius.circular(14),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Terima & Kunci Escrow',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.handshake_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProfileMetric(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      );

  Widget _buildMetricDivider() =>
      Container(width: 1, height: 24, color: const Color(0xFFE2E8F0));

  Widget _buildRealProjectCard({
    required String title,
    required String client,
    required String verifiedBadge,
    required bool isMentorVerified,
    required String quote,
    required String tech,
    required String rating,
    required String imageUrl,
  }) => Container(
        width: 270,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: const Color(0xFFE2E8F0),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isMentorVerified
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMentorVerified
                              ? Icons.military_tech_rounded
                              : Icons.verified_rounded,
                          color: isMentorVerified
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          verifiedBadge,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isMentorVerified
                                ? const Color(0xFFB45309)
                                : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        tech,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondarySlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildCertificateTile({
    required String title,
    required String issuer,
    required String tag,
    required bool isMentor,
  }) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSlate),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isMentor
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isMentor
                    ? Icons.military_tech_rounded
                    : Icons.workspace_premium_rounded,
                color: isMentor
                    ? const Color(0xFFF59E0B)
                    : AppColors.primaryNavy,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    issuer,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSkillRow(String skill, String proof) => Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: AppColors.primaryNavy,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              skill,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              proof,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondarySlate,
              ),
            ),
          ),
        ],
      );
}
