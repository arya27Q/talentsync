import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';

class PickedCvFile {
  const PickedCvFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class MentorRegisterScreen extends StatefulWidget {
  const MentorRegisterScreen({
    super.key,
    this.onPickCv,
    this.authApi,
  });

  final Future<PickedCvFile?> Function()? onPickCv;
  final AuthApi? authApi;

  @override
  State<MentorRegisterScreen> createState() => _MentorRegisterScreenState();
}

class _MentorRegisterScreenState extends State<MentorRegisterScreen> {
  static const int _maxCvBytes = 5 * 1024 * 1024;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _campusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _portfolioUrlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AuthApi _authApi = widget.authApi ?? AuthApi();

  int _selectedStatusIndex = 0; // 0: Mahasiswa Tingkat Akhir, 1: Fresh Graduate, 2: Praktisi Muda, 3: Alumni
  final List<String> _statusOptions = [
    'Mahasiswa Tingkat Akhir',
    'Fresh Graduate',
    'Praktisi Muda',
    'Alumni Kampus',
  ];

  final Set<String> _selectedSkills = {};
  final List<String> _availableSkills = [
    'Flutter & Dart',
    'Laravel & PHP',
    'UI/UX Design & Figma',
    'RESTful API',
    'PostgreSQL / Database',
    'React & Frontend',
    'Quality Assurance',
    'Product Management',
  ];

  int _selectedRateIndex = 1; // 0: 25 TC, 1: 35 TC, 2: 50 TC, 3: Kustom
  final List<Map<String, String>> _rateOptions = [
    {'tc': '25 TC', 'idr': 'Rp25.000 / sesi'},
    {'tc': '35 TC', 'idr': 'Rp35.000 (Rekomendasi)'},
    {'tc': '50 TC', 'idr': 'Rp50.000 / sesi'},
  ];

  bool _obscurePassword = true;
  bool _agreedToEthics = false;
  bool _isUploadingFile = false;
  bool _isSubmitting = false;
  String? _cvFileName;
  Uint8List? _cvBytes;
  String? _cvErrorText;

  @override
  void dispose() {
    _nameController.dispose();
    _campusController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _portfolioUrlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<PickedCvFile?> _defaultPickCv() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih CV (Format PDF)',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return PickedCvFile(name: picked.name, bytes: bytes);
  }

  bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    final limit = bytes.length < 1024 ? bytes.length - 3 : 1021;
    for (var i = 0; i <= limit; i++) {
      if (bytes[i] == 0x25 &&
          bytes[i + 1] == 0x50 &&
          bytes[i + 2] == 0x44 &&
          bytes[i + 3] == 0x46) {
        return true;
      }
    }
    return false;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb < 10 ? kb.toStringAsFixed(1) : kb.round()} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickCvPdf() async {
    if (_isUploadingFile || _isSubmitting) return;
    setState(() {
      _isUploadingFile = true;
      _cvErrorText = null;
    });
    try {
      final picked = await (widget.onPickCv ?? _defaultPickCv)();
      if (!mounted || picked == null) return;

      final fileName = picked.name.trim();
      final bytes = picked.bytes;

      if (!fileName.toLowerCase().endsWith('.pdf')) {
        setState(() {
          _cvErrorText = 'Format berkas harus .pdf. Pilih ulang CV berformat PDF.';
        });
        return;
      }
      if (bytes.isEmpty) {
        setState(() {
          _cvErrorText = 'Berkas PDF kosong dan tidak dapat diunggah.';
        });
        return;
      }
      if (!_looksLikePdf(bytes)) {
        setState(() {
          _cvErrorText = 'Isi berkas tidak valid sebagai dokumen PDF.';
        });
        return;
      }
      if (bytes.length > _maxCvBytes) {
        setState(() {
          _cvErrorText =
              'Ukuran CV (${_formatFileSize(bytes.length)}) melebihi batas maksimal 5 MB.';
        });
        return;
      }

      setState(() {
        _cvFileName = fileName;
        _cvBytes = bytes;
        _cvErrorText = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cvErrorText = 'Gagal membaca berkas CV. Coba pilih file PDF lain.';
      });
    } finally {
      if (mounted) {
        setState(() => _isUploadingFile = false);
      }
    }
  }

  void _removeCvPdf() {
    if (_isSubmitting || _isUploadingFile) return;
    setState(() {
      _cvFileName = null;
      _cvBytes = null;
      _cvErrorText = null;
    });
  }

  Future<void> _submitRegistration() async {
    if (_isSubmitting || _isUploadingFile) return;
    if (!_agreedToEthics) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap centang persetujuan kode etik bimbingan terlebih dahulu.',
          ),
          backgroundColor: AppColors.darkSlate,
        ),
      );
      return;
    }
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final portfolioText = _normalizeWebUrl(_portfolioUrlController.text);
    final missingFields = <String>[];
    if (name.isEmpty) missingFields.add('nama');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      missingFields.add('email valid');
    }
    if (password.length < 8) missingFields.add('kata sandi minimal 8 karakter');
    if (_selectedSkills.isEmpty) missingFields.add('minimal satu keahlian');
    if (portfolioText == null) {
      missingFields.add('tautan portofolio yang valid');
    }
    if (_cvFileName == null || _cvBytes == null) {
      missingFields.add('upload CV (format PDF)');
      setState(() {
        _cvErrorText = 'CV dalam format PDF wajib diunggah.';
      });
    }
    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Periksa: ${missingFields.join(', ')}.')),
      );
      return;
    }

    final validPortfolioUrl = portfolioText!;
    final validCvFileName = _cvFileName!;
    final validCvBytes = _cvBytes!;
    _portfolioUrlController.text = validPortfolioUrl;

    setState(() {
      _isSubmitting = true;
      _cvErrorText = null;
    });
    try {
      final headline = 'Mentor ${_selectedSkills.first}';
      final bioParts = <String>['Keahlian: ${_selectedSkills.join(', ')}'];
      if (_campusController.text.trim().isNotEmpty) {
        bioParts.add('Institusi: ${_campusController.text.trim()}');
      }
      bioParts.add('Status: ${_statusOptions[_selectedStatusIndex]}.');
      await _authApi.registerMentor(
        name: name,
        email: email,
        password: password,
        titleHeadline: headline,
        bio: bioParts.join('. '),
        hourlyRateTc: int.parse(
          _rateOptions[_selectedRateIndex]['tc']!.split(' ').first,
        ),
        cvFileName: validCvFileName,
        cvBytes: validCvBytes,
        portfolioUrl: validPortfolioUrl,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pendaftaran terkirim'),
          content: const Text(
            'Pendaftaran berhasil. Anda bisa masuk sekarang dan langsung menggunakan fitur mentor.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mentorAuth,
                  (route) => false,
                );
              },
              child: const Text('Kembali ke masuk'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        final cvErrors = error.errors?['cv_file'];
        if (cvErrors is List && cvErrors.isNotEmpty) {
          setState(() => _cvErrorText = '${cvErrors.first}');
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pendaftaran gagal diproses. Periksa koneksi dan ulangi.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _normalizeWebUrl(String value) {
    var candidate = value.trim();
    if (candidate.isEmpty) return null;
    if (!candidate.contains('://')) candidate = 'https://$candidate';
    final uri = Uri.tryParse(candidate);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !{'http', 'https'}.contains(uri.scheme.toLowerCase())) {
      return null;
    }
    return uri.toString();
  }

  Widget _buildFieldSection({
    required String label,
    required Widget child,
    String? caption,
  }) {
    return Column(
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
        if (caption != null) ...[
          const SizedBox(height: 3),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondarySlate,
            ),
          ),
        ],
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, color: AppColors.darkSlate),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.secondarySlate, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
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
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSlate),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkSlate.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.keyboard_arrow_left_rounded,
                          size: 24,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendaftaran Peer Mentor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        Text(
                          'Berbagi keahlian & bimbing sesama mahasiswa',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Card: Peer Mentor Concept
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(
                              alpha: 0.22,
                            ),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.people_alt_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jadilah Peer Mentor',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Bukan mentor formal berbiaya tinggi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF93C5FD),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Wadahi mahasiswa tingkat akhir, alumni muda, dan praktisi pemula untuk membimbing mahasiswa lain dalam menyelesaikan proyek UMKM serta memberikan Badge Rekomendasi Kerja (Endorse).',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE2E8F0),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.toll_rounded,
                                      color: AppColors.accentAmberGold,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Dapatkan TimeCoin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF38BDF8),
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Beri Endorse Resmi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Section Header 1
                    const Text(
                      'DATA IDENTITAS & LATAR BELAKANG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondarySlate,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 1. Nama Lengkap
                    _buildFieldSection(
                      label: 'Nama Lengkap',
                      caption: 'Cantumkan nama sesuai identitas resmi',
                      child: _buildInputBox(
                        controller: _nameController,
                        hint: 'Contoh: Dimas Prasetyo',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    // 2. Status Saat Ini (Chips)
                    _buildFieldSection(
                      label: 'Status / Latar Belakang Saat Ini',
                      caption:
                          'Pilih status yang paling menggambarkan posisimu',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_statusOptions.length, (idx) {
                          final bool isSelected = _selectedStatusIndex == idx;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStatusIndex = idx;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                _statusOptions[idx],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkSlate,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // 3. Asal Kampus / Institusi
                    _buildFieldSection(
                      label: 'Asal Kampus / Komunitas',
                      caption: 'Nama universitas atau instansi tempat kamu belajar/berkarya',
                      child: _buildInputBox(
                        controller: _campusController,
                        hint: 'Contoh: Universitas Negeri Surabaya',
                        icon: Icons.school_rounded,
                      ),
                    ),

                    // 4. Email Aktif
                    _buildFieldSection(
                      label: 'Alamat Email',
                      caption: 'Digunakan untuk notifikasi jadwal bimbingan',
                      child: _buildInputBox(
                        controller: _emailController,
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.mail_outline_rounded,
                      ),
                    ),

                    // 5. Nomor WhatsApp
                    _buildFieldSection(
                      label: 'Nomor WhatsApp Aktif',
                      caption: 'Untuk koordinasi cepat ruang sesi virtual',
                      child: _buildInputBox(
                        controller: _phoneController,
                        hint: '0812-3456-7890',
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_rounded,
                      ),
                    ),

                    // Section Header 2
                    const Text(
                      'KEAHLIAN & BUKTI KOMPETENSI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondarySlate,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 6. Keahlian yang Ingin Diajarkan (Multi-select)
                    _buildFieldSection(
                      label: 'Bidang Keahlian Bimbingan (Pilih yang dikuasai)',
                      caption: 'Mahasiswa akan memilihmu berdasarkan topik ini',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableSkills.map((skill) {
                          final bool isSelected = _selectedSkills.contains(
                            skill,
                          );
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  if (_selectedSkills.length > 1) {
                                    _selectedSkills.remove(skill);
                                  }
                                } else {
                                  _selectedSkills.add(skill);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEFF6FF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: AppColors.primaryNavy,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primaryNavy
                                          : AppColors.darkSlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // 7. Tautan Portofolio / GitHub
                    _buildFieldSection(
                      label: 'Tautan Portofolio / GitHub / LinkedIn',
                      caption: 'Sebagai bukti hasil karya proyek nyata',
                      child: _buildInputBox(
                        controller: _portfolioUrlController,
                        hint: 'https://github.com/username',
                        icon: Icons.link_rounded,
                      ),
                    ),

                    // 8. Upload CV (Format PDF)
                    _buildFieldSection(
                      label: 'Upload CV (Format PDF)',
                      caption:
                          'Lampirkan CV terbaru dalam format .pdf (maks. 5 MB) untuk kelengkapan profil mentor.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            button: true,
                            label: _cvFileName != null
                                ? 'CV terpilih $_cvFileName. Ketuk untuk mengganti file PDF.'
                                : 'Unggah CV dalam format PDF maksimal 5 MB',
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _isSubmitting ? null : _pickCvPdf,
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(
                                    minHeight: 72,
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                    14,
                                    14,
                                    _cvFileName != null ? 6 : 14,
                                    14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _cvErrorText != null
                                          ? const Color(0xFFB91C1C)
                                          : _cvFileName != null
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF64748B),
                                      width: _cvErrorText != null ? 1.5 : 1.2,
                                    ),
                                  ),
                                  child: _isUploadingFile
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primaryNavy,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Flexible(
                                              child: Text(
                                                'Memproses berkas CV PDF...',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF475569),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : _cvFileName != null && _cvBytes != null
                                      ? Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCFCE7),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.picture_as_pdf_rounded,
                                                color: Color(0xFF15803D),
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _cvFileName!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.darkSlate,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${_formatFileSize(_cvBytes!.length)} · PDF siap diunggah',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF15803D),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              constraints: const BoxConstraints(
                                                minWidth: 44,
                                                minHeight: 44,
                                              ),
                                              tooltip: 'Hapus CV',
                                              onPressed: _isSubmitting
                                                  ? null
                                                  : _removeCvPdf,
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                color: Color(0xFF475569),
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.upload_file_rounded,
                                                color: AppColors.primaryNavy,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Pilih File CV (.pdf)',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.primaryNavy,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Unggah CV berformat PDF · Maks. 5 MB',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      color: Color(0xFF475569),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Color(0xFF475569),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                          if (_cvErrorText != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFB91C1C),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _cvErrorText!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Section Header 3
                    const Text(
                      'TARIF BIMBINGAN & KEAMANAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondarySlate,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 9. Tarif TimeCoin per Sesi
                    _buildFieldSection(
                      label: 'Tarif Bimbingan per Sesi 60 Menit',
                      caption: '1 TC setara Rp1.000. Dana diteruskan via smart escrow setelah sesi tervalidasi.',
                      child: Row(
                        children: List.generate(_rateOptions.length, (idx) {
                          final bool isSelected = _selectedRateIndex == idx;
                          final item = _rateOptions[idx];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRateIndex = idx;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: idx < _rateOptions.length - 1 ? 8 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      item['tc']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.darkSlate,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        item['idr']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? const Color(0xFF93C5FD)
                                              : AppColors.secondarySlate,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // 10. Kata Sandi Baru
                    _buildFieldSection(
                      label: 'Kata Sandi Akun Mentor',
                      caption:
                          'Minimal 8 karakter untuk keamanan dasbor bimbingan',
                      child: _buildInputBox(
                        controller: _passwordController,
                        hint: 'Minimal 8 karakter',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.secondarySlate,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // 11. Checkbox Komitmen Kode Etik
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToEthics = !_agreedToEthics;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _agreedToEthics
                                    ? AppColors.primaryNavy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreedToEthics
                                      ? AppColors.primaryNavy
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToEthics
                                  ? const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Saya berkomitmen memberikan bimbingan yang solutif, santun, dan objektif serta tidak melakukan praktik joki tugas.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkSlate,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit CTA Button
                    GestureDetector(
                      onTap: _isSubmitting ? null : _submitRegistration,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(16),
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
                        child: _isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Mengirim pendaftaran...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Kirim Pendaftaran Peer Mentor',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Footer Link to Mentor Login
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.mentorAuth,
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Sudah terdaftar sebagai mentor? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondarySlate,
                            ),
                            children: [
                              TextSpan(
                                text: 'Masuk di sini',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
