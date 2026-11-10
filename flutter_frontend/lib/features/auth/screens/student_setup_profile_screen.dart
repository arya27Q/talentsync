import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class StudentSetupProfileScreen extends StatefulWidget {
  const StudentSetupProfileScreen({super.key});

  @override
  State<StudentSetupProfileScreen> createState() =>
      _StudentSetupProfileScreenState();
}

class _StudentSetupProfileScreenState extends State<StudentSetupProfileScreen> {
  final TextEditingController _nimController = TextEditingController();
  String _selectedUniversity = 'Universitas Negeri Surabaya';
  bool _agreedToPrivacy = false;
  bool _isUploading = false;
  String? _uploadedFileName;

  final List<String> _universities = [
    'Universitas Negeri Surabaya',
    'Institut Teknologi Sepuluh Nopember',
    'Universitas Airlangga',
    'Universitas Brawijaya',
    'Universitas Gadjah Mada',
    'Universitas Indonesia',
  ];

  @override
  void dispose() {
    _nimController.dispose();
    super.dispose();
  }

  void _showUniversityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Perguruan Tinggi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 16),
                ..._universities.map(
                  (univ) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      univ,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedUniversity == univ
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedUniversity == univ
                            ? AppColors.primaryNavy
                            : AppColors.darkSlate,
                      ),
                    ),
                    trailing: _selectedUniversity == univ
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryNavy,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedUniversity = univ;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulateUploadKtm() {
    setState(() {
      _isUploading = true;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadedFileName = 'KTM_24051214017.jpg';
        });
      }
    });
  }

  void _onSubmit() {
    if (!_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap setujui Perjanjian Privasi Data terlebih dahulu.',
          ),
          backgroundColor: AppColors.darkSlate,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.studentSetupProfileStep2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Back & Header Title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSlate.withValues(
                                    alpha: 0.06,
                                  ),
                                  blurRadius: 10,
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
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Verification',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Langkah 1 dari 2',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

                    const SizedBox(height: 18),

                    // Progress Bar (2 segments)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.borderSlate,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Field 1: Perguruan tinggi
                    const Text(
                      'Perguruan tinggi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showUniversityPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_rounded,
                              color: AppColors.secondarySlate,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedUniversity,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.secondarySlate,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Field 2: NIM
                    const Text(
                      'NIM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: TextField(
                        controller: _nimController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkSlate,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 22050974012',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.tag_rounded,
                            color: AppColors.secondarySlate,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Field 3: Foto Kartu Tanda Mahasiswa (Upload Card)
                    const Text(
                      'Foto Kartu Tanda Mahasiswa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _simulateUploadKtm,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueSurface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: _isUploading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primaryNavy,
                                        ),
                                      )
                                    : Icon(
                                        _uploadedFileName != null
                                            ? Icons.check_circle_outline_rounded
                                            : Icons
                                                  .add_photo_alternate_outlined,
                                        color: AppColors.primaryNavy,
                                        size: 26,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _uploadedFileName ?? 'Ketuk untuk unggah KTM',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'JPG atau PNG, maks. 5 MB. Pastikan nama dan NIM terbaca.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySlate,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Field 4: Data Privacy Agreement Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreedToPrivacy = !_agreedToPrivacy;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _agreedToPrivacy
                                    ? AppColors.primaryNavy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreedToPrivacy
                                      ? AppColors.primaryNavy
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToPrivacy
                                  ? const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saya menyetujui Perjanjian Privasi Data',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Data Privacy Agreement compliant with ISO/IEC 27001 standards. KTM hanya dipakai untuk verifikasi dan tidak ditampilkan publik.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondarySlate,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: Submit Verifikasi
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 28,
                top: 12,
              ),
              child: GestureDetector(
                onTap: _onSubmit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
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
                      'Submit Verifikasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
}
