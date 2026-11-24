import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/profile/data/student_profile_api.dart';

class SwitchToMentorScreen extends StatefulWidget {
  const SwitchToMentorScreen({
    super.key,
    this.profileApi,
    this.authApi,
  });

  final StudentProfileApi? profileApi;
  final AuthApi? authApi;

  @override
  State<SwitchToMentorScreen> createState() => _SwitchToMentorScreenState();
}

class _SwitchToMentorScreenState extends State<SwitchToMentorScreen> {
  late final StudentProfileApi _profileApi =
      widget.profileApi ?? StudentProfileApi.instance;
  late final AuthApi _authApi = widget.authApi ?? AuthApi();

  final TextEditingController _headlineCtrl = TextEditingController();
  final TextEditingController _customSkillCtrl = TextEditingController();
  final TextEditingController _certTitleCtrl = TextEditingController();
  final TextEditingController _certIssuerCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  bool _isEligible = false;
  bool _alreadyMentor = false;
  bool _ktmVerified = false;
  bool _hasOpenDispute = false;
  int _completedProjects = 0;
  int _minRequired = 20;
  double _ratingAverage = 0.0;
  double _minRatingRequired = 4.8;
  int _partnerEndorsements = 0;
  int _minPartnerEndorsements = 3;
  int _externalCertsCount = 0;
  int _minExternalCerts = 1;
  int _hourlyRateTc = 35;

  List<Map<String, dynamic>> _proofs = const [];
  List<Map<String, dynamic>> _existingCerts = const [];

  final Set<int> _selectedProofIds = {};
  final Set<String> _selectedSkills = {'Flutter', 'UI Design'};
  List<String> _availableSkills = const ['Flutter', 'UI Design', 'Laravel'];

  String? _certFileName;
  Uint8List? _certBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _headlineCtrl.dispose();
    _customSkillCtrl.dispose();
    _certTitleCtrl.dispose();
    _certIssuerCtrl.dispose();
    super.dispose();
  }

  bool get _pillar1Passed =>
      _completedProjects >= _minRequired &&
      _ratingAverage >= _minRatingRequired &&
      !_hasOpenDispute;

  bool get _pillar2Passed => _partnerEndorsements >= _minPartnerEndorsements;

  bool get _pillar3Passed =>
      _externalCertsCount >= _minExternalCerts ||
      (_certBytes != null && _certFileName != null);

  bool get _effectiveIsEligible =>
      _alreadyMentor ||
      (_isEligible ||
          (_ktmVerified &&
              _pillar1Passed &&
              _pillar2Passed &&
              _pillar3Passed));

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _profileApi.mentorEligibility();
      if (!mounted) return;
      final proofs = (data['available_proofs'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final certificates = (data['certificates'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final skills = (data['skills'] as List? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      _selectedProofIds
        ..clear()
        ..addAll(
          proofs
              .where((p) => p['selected'] != false)
              .map((p) => (p['id'] as num?)?.toInt())
              .whereType<int>(),
        );

      if (skills.isNotEmpty) {
        _availableSkills = skills;
        _selectedSkills
          ..clear()
          ..addAll(skills.take(3));
      }

      setState(() {
        _isEligible = data['is_eligible'] == true;
        _alreadyMentor = data['already_mentor'] == true;
        _ktmVerified = data['ktm_verified'] == true;
        _hasOpenDispute = data['has_open_dispute'] == true;
        _completedProjects =
            (data['completed_projects_count'] as num?)?.toInt() ?? 0;
        _minRequired =
            (data['min_projects_required'] as num?)?.toInt() ?? 20;
        _ratingAverage =
            (data['rating_average'] as num?)?.toDouble() ?? 0.0;
        _minRatingRequired =
            (data['min_rating_required'] as num?)?.toDouble() ?? 4.8;
        _partnerEndorsements =
            (data['partner_endorsements_count'] as num?)?.toInt() ?? 0;
        _minPartnerEndorsements =
            (data['min_partner_endorsements'] as num?)?.toInt() ?? 3;
        _externalCertsCount =
            (data['external_certs_count'] as num?)?.toInt() ?? 0;
        _minExternalCerts =
            (data['min_external_certs'] as num?)?.toInt() ?? 1;

        _proofs = proofs;
        _existingCerts = certificates;
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
          _error = 'Gagal memeriksa kelayakan kualifikasi 3 pilar Peer Mentor.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickCertificate() async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Pilih Berkas Sertifikasi Industri atau Rekomendasi',
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _certFileName = file.name;
        _certBytes = bytes;
        if (_certTitleCtrl.text.trim().isEmpty) {
          _certTitleCtrl.text = file.name.split('.').first;
        }
      });
    } catch (_) {
      _showSnack('Gagal memilih berkas sertifikat.', isError: true);
    }
  }

  void _removeCertificate() {
    setState(() {
      _certFileName = null;
      _certBytes = null;
    });
  }

  void _addCustomSkill() {
    final skill = _customSkillCtrl.text.trim();
    if (skill.isEmpty) return;
    setState(() {
      if (!_availableSkills.contains(skill)) {
        _availableSkills = [..._availableSkills, skill];
      }
      _selectedSkills.add(skill);
    });
    _customSkillCtrl.clear();
  }

  Future<void> _switchExistingMentorRole() async {
    setState(() => _isSubmitting = true);
    try {
      await _authApi.switchRole('mentor');
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mentorDashboard,
        (_) => false,
      );
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal beralih ke dasbor mentor.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _activateMentorMode() async {
    if (!_effectiveIsEligible || _isSubmitting) return;
    if (_selectedSkills.isEmpty) {
      _showSnack('Pilih minimal 1 keahlian bimbingan.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await _profileApi.switchToMentor(
        selectedProofIds: _selectedProofIds.toList(),
        teachingSkills: _selectedSkills.toList(),
        titleHeadline: _headlineCtrl.text.trim().isEmpty
            ? 'Peer Mentor Talenta Digital'
            : _headlineCtrl.text.trim(),
        hourlyRateTc: _hourlyRateTc,
        externalCertTitle: _certTitleCtrl.text.trim().isEmpty
            ? null
            : _certTitleCtrl.text.trim(),
        externalCertIssuer: _certIssuerCtrl.text.trim().isEmpty
            ? null
            : _certIssuerCtrl.text.trim(),
        externalCertFileName: _certFileName,
        externalCertBytes: _certBytes,
      );
      final user = res['user'];
      if (user is Map<String, dynamic>) {
        await ApiClient.instance.updateSessionUser(user);
      }
      if (!mounted) return;
      _showActivatedDialog();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal mengaktifkan mode Peer Mentor.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showActivatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Color(0xFF16A34A),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mode Peer Mentor Aktif!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kualifikasi 3 Pilar Anda terverifikasi! Anda kini resmi berhak membimbing mahasiswa junior dan menerbitkan Rekomendasi Kerja.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.mentorDashboard,
                    (_) => false,
                  );
                },
                child: const Text(
                  'Masuk Dasbor Mentor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      AppStatusDialog.showError(
        context,
        title: 'Tidak Dapat Melanjutkan',
        message: message,
      );
      return;
    }
    AppStatusDialog.showSuccess(
      context,
      title: 'Berhasil',
      message: message,
    );
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
                              if (_alreadyMentor) ...[
                                _buildAlreadyMentorCard(),
                              ] else ...[
                                _buildTrifectaPillarsBanner(),
                                const SizedBox(height: 16),
                                _buildChecklistByPillarCard(),
                                const SizedBox(height: 16),
                                _buildPillar3UploadCard(),
                                const SizedBox(height: 16),
                                if (_proofs.isNotEmpty) ...[
                                  _buildProofsCard(),
                                  const SizedBox(height: 16),
                                ],
                                _buildTeachingSetupCard(),
                                const SizedBox(height: 20),
                                _buildBottomActionButton(),
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Switch as a Peer Mentor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  'Standar Kualifikasi 3 Pilar Ekosistem',
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

  Widget _buildAlreadyMentorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 46,
            color: AppColors.successGreen,
          ),
          const SizedBox(height: 12),
          const Text(
            'Akses Peer Mentor Sudah Aktif',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Akun Anda telah memiliki akses ganda. Anda dapat beralih antara Portal Mahasiswa dan Portal Mentor kapan saja.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isSubmitting ? null : _switchExistingMentorRole,
              child: const Text(
                'Buka Dasbor Peer Mentor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrifectaPillarsBanner() {
    final p1 = _pillar1Passed;
    final p2 = _pillar2Passed;
    final p3 = _pillar3Passed;
    final int fulfilledCount = (p1 ? 1 : 0) + (p2 ? 1 : 0) + (p3 ? 1 : 0);
    final bool allDone = _effectiveIsEligible;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentAmberGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accentAmberGold.withValues(alpha: 0.6),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 14,
                      color: AppColors.accentAmberGold,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'STANDAR 3 PILAR PEER MENTOR',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentAmberGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: allDone
                      ? const Color(0xFF16A34A).withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  allDone ? 'Lengkap 3/3' : '$fulfilledCount/3 Pilar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: allDone ? const Color(0xFF4ADE80) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            allDone
                ? 'Kualifikasi 3 Pilar Lengkap!'
                : 'Penuhi Kualifikasi 3 Pilar Peer Mentor',
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Untuk menjaga kredibilitas ekosistem, calon mentor wajib memiliki jam terbang nyata, pengakuan mitra, dan validasi kompetensi.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPillarMiniStatus(
                  number: '1',
                  label: 'Jam Terbang',
                  meta: '$_completedProjects/$_minRequired Prj',
                  passed: p1,
                  icon: Icons.work_history_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarMiniStatus(
                  number: '2',
                  label: 'Pengakuan',
                  meta: '$_partnerEndorsements/$_minPartnerEndorsements Mitra',
                  passed: p2,
                  icon: Icons.handshake_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarMiniStatus(
                  number: '3',
                  label: 'Sertifikasi',
                  meta: p3 ? 'Terlampir' : 'Unggah',
                  passed: p3,
                  icon: Icons.card_membership_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarMiniStatus({
    required String number,
    required String label,
    required String meta,
    required bool passed,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: passed
            ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed
              ? const Color(0xFF3B82F6).withValues(alpha: 0.6)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: passed ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8),
              ),
              const Spacer(),
              Icon(
                passed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 13,
                color: passed ? const Color(0xFF4ADE80) : const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pilar $number: $label',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: passed ? const Color(0xFF93C5FD) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistByPillarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Verifikasi Persyaratan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Evaluasi otomatis sistem terhadap portofolio & riwayat proyek Anda.',
            style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 14),
          _buildPillarSectionHeader(
            pillarTag: 'PRASYARAT',
            title: 'Identitas Akademik Mahasiswa Aktif',
            icon: Icons.school_rounded,
          ),
          _buildCheckItem(
            label: 'KTM & Status Mahasiswa Terverifikasi',
            detail: _ktmVerified
                ? 'Terverifikasi sebagai mahasiswa aktif.'
                : 'Unggah KTM di profil mahasiswa untuk verifikasi.',
            passed: _ktmVerified,
          ),
          const Divider(height: 20, color: AppColors.borderSlate),
          _buildPillarSectionHeader(
            pillarTag: 'PILAR 1',
            title: 'Jam Terbang Nyata (Track Record)',
            icon: Icons.work_history_rounded,
          ),
          _buildCheckItem(
            label: 'Minimal $_minRequired Proyek UMKM Selesai',
            detail: '$_completedProjects/$_minRequired proyek selesai terverifikasi.',
            passed: _completedProjects >= _minRequired,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 4, bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _minRequired > 0
                    ? (_completedProjects / _minRequired).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2E8F0),
                color: _completedProjects >= _minRequired
                    ? AppColors.successGreen
                    : AppColors.primaryNavy,
              ),
            ),
          ),
          _buildCheckItem(
            label: 'Rating Rata-rata Proyek Minimal $_minRatingRequired',
            detail: _ratingAverage > 0
                ? 'Rating saat ini ${_ratingAverage.toStringAsFixed(2)} dari proyek selesai.'
                : 'Belum memiliki rating proyek.',
            passed: _ratingAverage >= _minRatingRequired,
          ),
          _buildCheckItem(
            label: 'Bebas Sengketa Escrow Aktif (Zero Dispute)',
            detail: _hasOpenDispute
                ? 'Selesaikan laporan kendala escrow aktif terlebih dahulu.'
                : 'Tidak ada komplain atau sengketa pembayaran aktif.',
            passed: !_hasOpenDispute,
          ),
          const Divider(height: 20, color: AppColors.borderSlate),
          _buildPillarSectionHeader(
            pillarTag: 'PILAR 2',
            title: 'Pengakuan Mitra Luar (External Endorsements)',
            icon: Icons.handshake_rounded,
          ),
          _buildCheckItem(
            label: 'Minimal $_minPartnerEndorsements Surat Kepuasan / Ulasan Mitra UMKM',
            detail: '$_partnerEndorsements/$_minPartnerEndorsements mitra UMKM memberikan ulasan positif bintang tinggi.',
            passed: _pillar2Passed,
          ),
          const Divider(height: 20, color: AppColors.borderSlate),
          _buildPillarSectionHeader(
            pillarTag: 'PILAR 3',
            title: 'Validasi Industri / Rekomendasi Eksternal',
            icon: Icons.card_membership_rounded,
          ),
          _buildCheckItem(
            label: 'Sertifikasi Industri (BNSP/Google) atau Rekomendasi Dosen',
            detail: _pillar3Passed
                ? (_certFileName != null
                    ? 'Berkas terlampir: $_certFileName'
                    : 'Tersedia $_externalCertsCount sertifikasi terverifikasi di akun.')
                : 'Unggah berkas sertifikasi atau surat rekomendasi di bawah.',
            passed: _pillar3Passed,
          ),
        ],
      ),
    );
  }

  Widget _buildPillarSectionHeader({
    required String pillarTag,
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryNavy),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pillarTag,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required String label,
    required String detail,
    required bool passed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            passed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: passed
                ? AppColors.successGreen
                : const Color(0xFF94A3B8),
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11.5,
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

  Widget _buildPillar3UploadCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilar 3: Dokumen Sertifikasi / Rekomendasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    Text(
                      'BNSP, Google, Dicoding, AWS, atau Surat Dosen',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_existingCerts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sertifikasi Terdata di Akun Anda:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._existingCerts.take(2).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.successGreen,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${c['title'] ?? 'Sertifikat'} (${c['issuer_name'] ?? 'Lembaga'})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.darkSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _certTitleCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Sertifikasi / Rekomendasi',
              hintText: 'Contoh: Sertifikasi Pengembang Aplikasi Mobile BNSP',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _certIssuerCtrl,
            decoration: InputDecoration(
              labelText: 'Lembaga Penerbit / Nama Dosen Pembimbing',
              hintText: 'Contoh: BNSP / Google Career / Dr. Dosen Pembimbing',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_certFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _certFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: const Color(0xFF15803D),
                    onPressed: _removeCertificate,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _pickCertificate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryNavy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.upload_file_rounded,
                size: 18,
                color: AppColors.primaryNavy,
              ),
              label: Text(
                _certFileName == null
                    ? 'Pilih Berkas Sertifikat (PDF / Gambar)'
                    : 'Ganti Berkas Sertifikat',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofsCard() {
    return Material(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSlate),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portofolio Proyek Terverifikasi Mitra',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih karya nyata yang akan disorot di profil bimbingan Anda.',
              style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 8),
            ..._proofs.map((p) {
              final id = (p['id'] as num?)?.toInt();
              final selected = id != null && _selectedProofIds.contains(id);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primaryNavy,
                title: Text(
                  (p['title'] as String?) ?? 'Portofolio',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  (p['subtitle'] as String?) ?? '',
                  style: const TextStyle(fontSize: 11.5),
                ),
                value: selected,
                onChanged: id == null
                    ? null
                    : (v) {
                        setState(() {
                          if (v == true) {
                            _selectedProofIds.add(id);
                          } else {
                            _selectedProofIds.remove(id);
                          }
                        });
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachingSetupCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil & Preferensi Bimbingan Peer Mentor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _headlineCtrl,
            decoration: InputDecoration(
              labelText: 'Headline Mentor (opsional)',
              hintText: 'Contoh: Peer Mentor Flutter & Sistem Kasir UMKM',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tarif Bimbingan per Sesi 60 Menit',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [25, 35, 50].map((rate) {
              final active = _hourlyRateTc == rate;
              return ChoiceChip(
                label: Text('$rate TC'),
                selected: active,
                selectedColor: AppColors.primaryNavy,
                labelStyle: TextStyle(
                  color: active ? Colors.white : AppColors.darkSlate,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _hourlyRateTc = rate),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            'Keahlian yang Siap Dibimbingkan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _availableSkills.map((skill) {
              final selected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: selected,
                selectedColor: AppColors.lightBlueSurface,
                checkmarkColor: AppColors.primaryNavy,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customSkillCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tambah topik ajar lain...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _addCustomSkill,
                  child: const Text('Tambah'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    if (_effectiveIsEligible) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
          ),
          onPressed: _isSubmitting ? null : _activateMentorMode,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : const Text(
                  'Aktifkan Mode Peer Mentor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.exploreProjects,
            ),
            child: const Text(
              'Cari & Selesaikan Proyek UMKM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selesaikan 20 proyek UMKM dan kumpulkan ulasan mitra untuk memenuhi Standar 3 Pilar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.secondarySlate,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
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
