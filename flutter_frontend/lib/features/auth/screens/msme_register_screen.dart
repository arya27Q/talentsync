import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/auth/widgets/msme_logo_modal.dart';

class MsmeRegisterScreen extends StatefulWidget {
  const MsmeRegisterScreen({super.key, this.authApi});

  final AuthApi? authApi;

  @override
  State<MsmeRegisterScreen> createState() => _MsmeRegisterScreenState();
}

class _MsmeRegisterScreenState extends State<MsmeRegisterScreen> {
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nibController = TextEditingController();
  final _customCategoryController = TextEditingController();

  late final AuthApi _authApi = widget.authApi ?? AuthApi();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String _selectedCategory = 'Kuliner';
  Uint8List? _pickedLogoBytes;
  String? _pickedLogoFileName;
  String? _selectedPresetAvatarId;

  bool get _hasLogo =>
      _pickedLogoBytes != null || _selectedPresetAvatarId != null;

  final List<String> _categories = [
    'Kuliner',
    'Fesyen',
    'Kerajinan',
    'Ritel',
    'Jasa',
    'Agrobisnis',
    'Kreatif & Digital',
    'Lainnya',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _nibController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _openLogoModal() async {
    final result = await MsmeLogoPickerSheet.show(
      context,
      currentPresetId: _selectedPresetAvatarId,
      hasExistingPhoto: _pickedLogoBytes != null,
    );

    if (result != null && mounted) {
      setState(() {
        if (result.isCleared) {
          _pickedLogoBytes = null;
          _pickedLogoFileName = null;
          _selectedPresetAvatarId = null;
        } else if (result.pickedBytes != null) {
          _pickedLogoBytes = result.pickedBytes;
          _pickedLogoFileName = result.fileName;
          _selectedPresetAvatarId = null;
        } else if (result.presetAvatarId != null) {
          _selectedPresetAvatarId = result.presetAvatarId;
          _pickedLogoBytes = null;
          _pickedLogoFileName = null;
        }
      });
    }
  }

  Future<void> _onFinishSetup() async {
    if (_isLoading) return;
    final businessName = _businessNameController.text.trim();
    final ownerName = _ownerNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final address = _addressController.text.trim();

    if (businessName.isEmpty ||
        ownerName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      AppStatusDialog.showError(
        context,
        title: 'Data Belum Lengkap',
        message:
            'Harap lengkapi nama usaha, nama pemilik, email bisnis, dan kata sandi akun.',
        buttonText: 'Lengkapi Data',
      );
      return;
    }

    if (password.length < 8) {
      AppStatusDialog.showError(
        context,
        title: 'Kata Sandi Kurang Aman',
        message:
            'Kata sandi akun minimal harus terdiri dari 8 karakter demi keamanan usaha Anda.',
        buttonText: 'Perbaiki Kata Sandi',
      );
      return;
    }

    final categoryToSave = _selectedCategory == 'Lainnya'
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    if (_selectedCategory == 'Lainnya' && categoryToSave.isEmpty) {
      AppStatusDialog.showError(
        context,
        title: 'Kategori Belum Diisi',
        message:
            'Harap tuliskan nama bidang/kategori usaha Anda pada kolom yang tersedia.',
        buttonText: 'Tulis Kategori',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authApi.registerMsme(
        name: ownerName,
        email: email,
        password: password,
        businessName: businessName,
        businessSector: categoryToSave,
        address: address.isNotEmpty ? address : 'Surabaya',
        description: _descriptionController.text.trim(),
        nib: _nibController.text.trim(),
        logoFileName: _pickedLogoFileName,
        logoBytes: _pickedLogoBytes,
        logoUrl: _selectedPresetAvatarId,
      );
      if (!mounted) return;

      await AppStatusDialog.showSuccess(
        context,
        title: 'Pendaftaran Berhasil!',
        message:
            'Profil usaha "$businessName" telah aktif. Selamat datang di portal kolaborasi TalentSync!',
        buttonText: 'Masuk ke Dashboard',
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.msmeDashboard,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        final isEmailTaken =
            error.message.toLowerCase().contains('terdaftar') ||
            (error.errors != null && error.errors!.containsKey('email'));
        if (isEmailTaken) {
          AppStatusDialog.showError(
            context,
            title: 'Akun Sudah Terdaftar',
            message:
                'Akun sudah pernah terdaftar dengan email ini. Silakan langsung masuk melalui halaman login.',
            buttonText: 'Masuk Sekarang',
            onConfirm: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.msmeAuth,
            ),
          );
        } else {
          AppStatusDialog.showError(
            context,
            title: 'Pendaftaran Gagal',
            message: error.message,
            buttonText: 'Coba Lagi',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        AppStatusDialog.showError(
          context,
          title: 'Kendala Koneksi',
          message:
              'Pendaftaran tidak dapat diproses saat ini. Periksa koneksi internet Anda dan coba lagi.',
          buttonText: 'Coba Lagi',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Profil Usaha',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Profil usaha & kemitraan UMKM',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.secondarySlate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
                  // Logo & Avatar Card
                  InkWell(
                    onTap: _openLogoModal,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _hasLogo
                              ? AppColors.primaryNavy
                              : AppColors.borderSlate,
                          width: _hasLogo ? 1.6 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(
                              alpha: _hasLogo ? 0.06 : 0.03,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Thumbnail Preview or Default Container
                          MsmeLogoHelper.buildLogoWidget(
                            logoUrl: _selectedPresetAvatarId,
                            logoBytes: _pickedLogoBytes,
                            size: 58,
                            borderRadius: 16,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _pickedLogoFileName != null
                                            ? _pickedLogoFileName!
                                            : (_selectedPresetAvatarId != null
                                                ? (MsmeLogoHelper.getPreset(_selectedPresetAvatarId)?.title ??
                                                    'Avatar Tematik Terpasang')
                                                : 'Unggah logo toko'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkSlate,
                                        ),
                                      ),
                                    ),
                                    if (_hasLogo)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFA7F3D0),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 13,
                                              color: Color(0xFF10B981),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Terpasang',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF047857),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _hasLogo
                                      ? 'Ketuk untuk mengganti, sesuaikan crop, atau hapus'
                                      : 'Pilih foto galeri & crop atau gunakan avatar tematik',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _hasLogo
                                ? Icons.tune_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: _hasLogo
                                ? AppColors.primaryNavy
                                : AppColors.secondarySlate,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'PILIH CEPAT AVATAR TEMATIK TOKO:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: MsmeLogoHelper.presets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final preset = MsmeLogoHelper.presets[index];
                        final isSelected =
                            _selectedPresetAvatarId == preset.id &&
                                _pickedLogoBytes == null;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPresetAvatarId = preset.id;
                              _pickedLogoBytes = null;
                              _pickedLogoFileName = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 68,
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: preset.bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : preset.primaryColor
                                        .withValues(alpha: 0.25),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  preset.icon,
                                  size: 24,
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : preset.primaryColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preset.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primaryNavy
                                        : AppColors.darkSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

                  // Email Bisnis
                  const _FieldLabel('Email bisnis akun'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      Icons.mail_outline_rounded,
                      'pemilik@bisnis.com',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Kata Sandi
                  const _FieldLabel('Kata sandi'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      Icons.lock_outline_rounded,
                      'Minimal 8 karakter',
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Tampilkan kata sandi'
                            : 'Sembunyikan kata sandi',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.secondarySlate,
                        ),
                      ),
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

                  if (_selectedCategory == 'Lainnya') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customCategoryController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        Icons.edit_note_rounded,
                        'Tulis bidang usahamu (contoh: Otomotif, Laundry, Percetakan)',
                      ),
                    ),
                  ],

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
                  const _FieldLabel(
                    'NIB (opsional, untuk badge Verified Partner)',
                  ),
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
                      color: _isLoading
                          ? AppColors.primaryNavy.withValues(alpha: 0.85)
                          : AppColors.primaryNavy,
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
                        onTap: _isLoading ? null : _onFinishSetup,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Mendaftarkan Usaha...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Selesaikan Pendaftaran',
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

  InputDecoration _inputDecoration(
    IconData icon,
    String hint,
  ) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.secondarySlate, size: 20),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.borderSlate),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
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
