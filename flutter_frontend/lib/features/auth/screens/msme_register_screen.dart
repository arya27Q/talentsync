import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MsmeRegisterScreen extends StatefulWidget {
  const MsmeRegisterScreen({super.key});

  @override
  State<MsmeRegisterScreen> createState() => _MsmeRegisterScreenState();
}

class _MsmeRegisterScreenState extends State<MsmeRegisterScreen> {
  final _businessNameController = TextEditingController(text: 'Kopi Tepi Kali');
  final _ownerNameController = TextEditingController(text: 'Bu Rina');
  final _addressController = TextEditingController(
    text: 'Jl. Ketintang Baru No. 12, Surabaya',
  );
  final _descriptionController = TextEditingController(
    text: 'Kedai kopi rumahan dekat kampus UNESA, buka sejak 2019.',
  );
  final _nibController = TextEditingController();

  String _selectedCategory = 'Kuliner';
  bool _hasUploadedLogo = false;

  final List<String> _categories = [
    'Kuliner',
    'Fesyen',
    'Kerajinan',
    'Ritel',
    'Jasa',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _nibController.dispose();
    super.dispose();
  }

  void _onFinishSetup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil usaha berhasil disimpan! Selamat datang di TalentSync.'),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.msmeDashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Setup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Profil usaha untuk mahasiswa',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondarySlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Form Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Upload Card
                  InkWell(
                    onTap: () {
                      setState(() {
                        _hasUploadedLogo = !_hasUploadedLogo;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _hasUploadedLogo
                                ? 'Logo toko berhasil diunggah'
                                : 'Logo toko direset',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _hasUploadedLogo
                              ? AppColors.primaryNavy
                              : AppColors.borderSlate,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueSurface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _hasUploadedLogo
                                  ? Icons.check_circle_rounded
                                  : Icons.add_photo_alternate_rounded,
                              color: _hasUploadedLogo
                                  ? const Color(0xFF10B981)
                                  : AppColors.primaryNavy,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hasUploadedLogo
                                      ? 'Logo Toko Terunggah (logo_kopi.png)'
                                      : 'Unggah logo toko',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PNG atau JPG persegi, maks. 2 MB',
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
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Nama Usaha
                  const _FieldLabel('Nama usaha'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _businessNameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      Icons.storefront_rounded,
                      'Nama usaha anda',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nama Pemilik
                  const _FieldLabel('Nama pemilik'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ownerNameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      Icons.person_outline_rounded,
                      'Nama lengkap pemilik',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Kategori Usaha
                  const _FieldLabel('Kategori usaha'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((category) {
                      final bool isSelected = _selectedCategory == category;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
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
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryNavy.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.darkSlate,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Alamat Usaha
                  const _FieldLabel('Alamat usaha'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      Icons.location_on_rounded,
                      'Alamat fisik usaha',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Deskripsi Singkat
                  const _FieldLabel('Deskripsi singkat'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkSlate,
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan profil singkat usahamu...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.borderSlate,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primaryNavy,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // NIB (opsional, untuk badge Verified Partner)
                  const _FieldLabel('NIB (opsional, untuk badge Verified Partner)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nibController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(
                      Icons.badge_rounded,
                      '13 digit Nomor Induk Berusaha',
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Bottom Action Button
                  Container(
                    width: double.infinity,
                    height: 52,
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onFinishSetup,
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Finish Setup',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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

  InputDecoration _inputDecoration(IconData icon, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.secondarySlate, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryNavy,
            width: 1.5,
          ),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.darkSlate,
    ),
  );
}
