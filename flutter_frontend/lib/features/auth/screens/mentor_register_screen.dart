import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MentorRegisterScreen extends StatefulWidget {
  const MentorRegisterScreen({super.key});

  @override
  State<MentorRegisterScreen> createState() => _MentorRegisterScreenState();
}

class _MentorRegisterScreenState extends State<MentorRegisterScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Dimas Prasetyo',
  );
  final TextEditingController _campusController = TextEditingController(
    text: 'Universitas Negeri Surabaya',
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _portfolioUrlController = TextEditingController(
    text: 'https://github.com/dimasprasetyo',
  );
  final TextEditingController _passwordController = TextEditingController();

  int _selectedStatusIndex = 0; // 0: Mahasiswa Tingkat Akhir, 1: Fresh Graduate, 2: Praktisi Muda, 3: Alumni
  final List<String> _statusOptions = [
    'Mahasiswa Tingkat Akhir',
    'Fresh Graduate',
    'Praktisi Muda',
    'Alumni Kampus',
  ];

  final Set<String> _selectedSkills = {
    'Flutter & Dart',
    'Laravel & PHP',
    'UI/UX Design & Figma',
  };
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
  bool _agreedToEthics = true;
  bool _isUploadingFile = false;
  String? _uploadedFileName;

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

  void _simulateFileUpload() {
    setState(() {
      _isUploadingFile = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isUploadingFile = false;
          _uploadedFileName = 'portofolio_dan_sertifikat_dimas.pdf';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berkas portofolio berhasil dilampirkan.'),
            backgroundColor: AppColors.darkSlate,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _submitRegistration() {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pendaftaran Terkirim!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Profil Peer Mentor kamu berhasil diajukan. Kamu dapat langsung membuka dasbor mentor dan mengatur jadwal ketersediaan bimbingan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondarySlate,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mentorDashboard,
                  (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Buka Dasbor Mentor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

                    // 8. Unggah Berkas Portofolio / KTM / Sertifikat
                    _buildFieldSection(
                      label: 'Unggah Bukti Portofolio / Sertifikat (PDF)',
                      caption: 'Lampirkan ringkasan proyek yang pernah kamu selesaikan',
                      child: GestureDetector(
                        onTap: _simulateFileUpload,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _uploadedFileName != null
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFCBD5E1),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _isUploadingFile
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    Text(
                                      'Mengunggah berkas portofolio...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                )
                              : _uploadedFileName != null
                              ? Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.task_alt_rounded,
                                        color: Color(0xFF16A34A),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _uploadedFileName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkSlate,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            '2.4 MB · Terlampir',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF16A34A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.refresh_rounded,
                                      color: AppColors.secondarySlate,
                                      size: 18,
                                    ),
                                  ],
                                )
                              : const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_file_rounded,
                                        color: AppColors.primaryNavy,
                                        size: 22,
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Pilih berkas PDF atau gambar (Maks 10MB)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryNavy,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
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
                      onTap: _submitRegistration,
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
                        child: const Padding(
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
