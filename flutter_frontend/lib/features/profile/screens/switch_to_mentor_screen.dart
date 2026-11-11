import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
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

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  bool _isEligible = false;
  bool _alreadyMentor = false;
  int _completedProjects = 0;
  int _minRequired = 5;
  int _hourlyRateTc = 35;

  List<Map<String, dynamic>> _checks = const [];
  List<Map<String, dynamic>> _proofs = const [];
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
    super.dispose();
  }

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
        _completedProjects =
            (data['completed_projects_count'] as num?)?.toInt() ?? 0;
        _minRequired = (data['min_projects_required'] as num?)?.toInt() ?? 5;
        _checks = (data['checks'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        _proofs = proofs;
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
          _error = 'Gagal memeriksa kelayakan Peer Mentor.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickCertificate() async {
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: 'Pilih Sertifikat Tambahan',
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _certFileName = file.name;
        _certBytes = bytes;
      });
    } catch (_) {
      _showSnack('Gagal memilih file sertifikat.', isError: true);
    }
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
    if (!_isEligible || _isSubmitting) return;
    if (_selectedSkills.isEmpty) {
      _showSnack('Pilih minimal 1 keahlian mengajar.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final res = await _profileApi.switchToMentor(
        selectedProofIds: _selectedProofIds.toList(),
        teachingSkills: _selectedSkills.toList(),
        titleHeadline: _headlineCtrl.text.trim().isEmpty
            ? 'Peer Mentor Mahasiswa'
            : _headlineCtrl.text.trim(),
        hourlyRateTc: _hourlyRateTc,
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
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Color(0xFF16A34A),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mode Mentor Aktif!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selamat! Profil Peer Mentor Anda aktif dan siap membuka sesi bimbingan mahasiswa.',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB91C1C)
            : AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
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
                            _buildEligibilityBanner(),
                            const SizedBox(height: 16),
                            _buildChecklistCard(),
                            const SizedBox(height: 16),
                            if (_proofs.isNotEmpty) ...[
                              _buildProofsCard(),
                              const SizedBox(height: 16),
                            ],
                            _buildTeachingSetupCard(),
                            const SizedBox(height: 20),
                            if (_isEligible)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryNavy,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _isSubmitting
                                      ? null
                                      : _activateMentorMode,
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
                              )
                            else
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
                                    ),
                                  ),
                                ),
                              ),
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
            child: Text(
              'Switch as a Peer Mentor',
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
            'Akun mahasiswa Anda sudah memiliki akses ganda untuk beralih ke Dasbor Mentor kapan saja.',
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

  Widget _buildEligibilityBanner() {
    final ratio = _minRequired > 0
        ? (_completedProjects / _minRequired).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isEligible
            ? AppColors.primaryNavy
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isEligible ? Icons.verified_rounded : Icons.lock_clock_rounded,
                color: AppColors.accentAmberGold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEligible
                      ? 'Memenuhi Syarat Peer Mentor!'
                      : 'Lengkapi Syarat Minimal 5 Proyek',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Progres Proyek UMKM Selesai: $_completedProjects/$_minRequired',
            style: const TextStyle(fontSize: 13, color: Color(0xFFDBEAFE)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: AppColors.accentAmberGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
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
            'Checklist Verifikasi Ekosistem',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          ..._checks.map((c) {
            final passed = c['passed'] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    passed
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: passed
                        ? AppColors.successGreen
                        : AppColors.accentAmberGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (c['label'] as String?) ?? '',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        Text(
                          (c['detail'] as String?) ?? '',
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
            );
          }),
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
            'Portofolio Proyek Terverifikasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                (p['subtitle'] as String?) ?? '',
                style: const TextStyle(fontSize: 12),
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
            'Profil Pengajar Peer Mentor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _headlineCtrl,
            decoration: InputDecoration(
              labelText: 'Headline Mentor (opsional)',
              hintText: 'Contoh: Peer Mentor Flutter & Sistem Kasir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          const Text(
            'Keahlian yang Diajarkan',
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
                    hintText: 'Tambah bidang ajar...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _pickCertificate,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: Text(
                _certFileName ?? 'Unggah Sertifikat Tambahan (Opsional)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
