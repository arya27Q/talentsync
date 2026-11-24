import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/features/auth/widgets/msme_logo_modal.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';

class MsmeEditProfileScreen extends StatefulWidget {
  const MsmeEditProfileScreen({super.key, this.msmeApi});

  final MsmeApi? msmeApi;

  @override
  State<MsmeEditProfileScreen> createState() => _MsmeEditProfileScreenState();
}

class _MsmeEditProfileScreenState extends State<MsmeEditProfileScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;

  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _nibCtrl = TextEditingController();
  final _customCategoryCtrl = TextEditingController();

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

  String _selectedCategory = 'Kuliner';
  String? _currentLogoUrl;
  String? _selectedPresetAvatarId;
  Uint8List? _pickedLogoBytes;
  String? _pickedLogoFileName;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _descriptionCtrl.dispose();
    _nibCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    // 1. Baca session user agar langsung terisi tanpa delay
    final sessionUser = await ApiClient.instance.readSessionUser();
    if (sessionUser != null && mounted) {
      _applyUserData(sessionUser);
    }

    // 2. Ambil profil terbaru dari backend MySQL
    try {
      final profile = await _msmeApi.getProfile();
      if (mounted) {
        _applyUserData(profile);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyUserData(Map<String, dynamic> data) {
    setState(() {
      final bName = (data['business_name'] as String?)?.trim();
      if (bName != null && bName.isNotEmpty) {
        _businessNameCtrl.text = bName;
      }

      final oName = (data['name'] as String?)?.trim();
      if (oName != null && oName.isNotEmpty) {
        _ownerNameCtrl.text = oName;
      }

      final addr = (data['address'] as String?)?.trim();
      if (addr != null && addr.isNotEmpty) {
        _addressCtrl.text = addr;
      }

      final city = (data['city'] as String?)?.trim();
      if (city != null && city.isNotEmpty) {
        _cityCtrl.text = city;
      } else if (_cityCtrl.text.isEmpty) {
        _cityCtrl.text = 'Surabaya';
      }

      final desc = (data['description'] as String?)?.trim();
      if (desc != null && desc.isNotEmpty) {
        _descriptionCtrl.text = desc;
      }

      final nib = (data['nib'] as String?)?.trim();
      if (nib != null && nib.isNotEmpty) {
        _nibCtrl.text = nib;
      }

      final sector = (data['business_sector'] as String?)?.trim();
      if (sector != null && sector.isNotEmpty) {
        if (_categories.contains(sector)) {
          _selectedCategory = sector;
        } else {
          _selectedCategory = 'Lainnya';
          _customCategoryCtrl.text = sector;
        }
      }

      final logo = (data['logo_url'] as String?) ?? (data['avatar_url'] as String?);
      if (logo != null && logo.isNotEmpty) {
        _currentLogoUrl = logo;
        if (logo.startsWith('avatar:')) {
          _selectedPresetAvatarId = logo;
        }
      }
    });
  }

  Future<void> _pickCustomPhoto() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Pilih Foto Logo Usaha',
        type: FileType.image,
      );

      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      if (bytes.lengthInBytes > 3 * 1024 * 1024) {
        if (!mounted) return;
        AppStatusDialog.showError(
          context,
          title: 'Ukuran Foto Terlalu Besar',
          message:
              'Ukuran foto maksimal adalah 3 MB. Harap perkecil atau pilih foto yang lebih ringkas.',
        );
        return;
      }

      if (mounted) {
        setState(() {
          _pickedLogoBytes = bytes;
          _pickedLogoFileName = picked.name;
          _selectedPresetAvatarId = null;
          _currentLogoUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppStatusDialog.showError(
        context,
        title: 'Gagal Memilih Gambar',
        message: 'Tidak dapat membuka galeri berkas. Silakan coba lagi.',
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    final bName = _businessNameCtrl.text.trim();
    final oName = _ownerNameCtrl.text.trim();
    final addr = _addressCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final desc = _descriptionCtrl.text.trim();
    final nib = _nibCtrl.text.trim();

    if (bName.isEmpty) {
      AppStatusDialog.showWarning(
        context,
        title: 'Nama Usaha Wajib Diisi',
        message: 'Harap masukkan nama usaha atau toko Anda.',
        buttonText: 'Mengerti',
      );
      return;
    }

    final sector = _selectedCategory == 'Lainnya'
        ? _customCategoryCtrl.text.trim()
        : _selectedCategory;

    setState(() {
      _isSaving = true;
    });

    try {
      final updateBody = <String, dynamic>{
        'business_name': bName,
        if (oName.isNotEmpty) 'name': oName,
        'business_sector': sector.isNotEmpty ? sector : 'Kuliner',
        'address': addr.isNotEmpty ? addr : 'Surabaya',
        'city': city.isNotEmpty ? city : 'Surabaya',
        'description': desc,
        'nib': nib,
        if (_selectedPresetAvatarId != null) 'logo_url': _selectedPresetAvatarId,
      };

      final updated = await _msmeApi.updateProfile(
        updateBody,
        logoFileName: _pickedLogoFileName,
        logoBytes: _pickedLogoBytes,
      );

      final newLogoUrl = (updated['logo_url'] as String?) ??
          _selectedPresetAvatarId ??
          _currentLogoUrl;

      // Perbarui session user lokal agar persist across tabs & restart
      await ApiClient.instance.updateSessionUser({
        'business_name': updated['business_name'] ?? bName,
        if (oName.isNotEmpty) 'name': updated['name'] ?? oName,
        'business_sector': updated['business_sector'] ?? sector,
        'address': updated['address'] ?? addr,
        'city': updated['city'] ?? city,
        'description': updated['description'] ?? desc,
        'nib': updated['nib'] ?? nib,
        'logo_url': ?newLogoUrl,
        'avatar_url': ?newLogoUrl,
      });

      if (!mounted) return;

      AppStatusDialog.showSuccess(
        context,
        title: 'Perubahan Disimpan',
        message: 'Informasi usaha dan avatar toko berhasil diperbarui secara permanen.',
        buttonText: 'Selesai',
        onConfirm: () {
          Navigator.pop(context, true);
        },
      );
    } catch (err) {
      if (!mounted) return;
      AppStatusDialog.showError(
        context,
        title: 'Gagal Menyimpan',
        message: 'Terjadi kendala saat memperbarui profil: $err',
        buttonText: 'Coba Lagi',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeLogoDisplay = _selectedPresetAvatarId ?? _currentLogoUrl;
    final hasLogo = _pickedLogoBytes != null ||
        (_selectedPresetAvatarId != null && _selectedPresetAvatarId!.isNotEmpty) ||
        (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(),

            // Form Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Section: Avatar & Logo Toko
                          _buildAvatarSection(activeLogoDisplay, hasLogo),
                          const SizedBox(height: 24),

                          // 2. Section: Informasi Usaha
                          _buildFormSection(),
                          const SizedBox(height: 24),

                          // 3. Section: Dokumen & Legalitas
                          _buildLegalSection(),
                          const SizedBox(height: 24),

                          // 4. Section: Hapus Akun Mitra UMKM
                          _buildDangerZoneSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),

            // Fixed Bottom CTA Button
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.borderSlate, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Kembali',
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkSlate,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Perbarui identitas & informasi toko usahamu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondarySlate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildAvatarSection(String? activeLogoDisplay, bool hasLogo) {
    String avatarStatusText;
    if (_pickedLogoFileName != null) {
      avatarStatusText = 'Foto Galeri: $_pickedLogoFileName';
    } else if (_selectedPresetAvatarId != null) {
      final preset = MsmeLogoHelper.getPreset(_selectedPresetAvatarId);
      avatarStatusText = 'Avatar: ${preset?.title ?? 'Tematik'}';
    } else if (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty) {
      avatarStatusText = 'Logo Toko Aktif';
    } else {
      avatarStatusText = 'Belum Memilih Logo';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Preview Logo
              MsmeLogoHelper.buildLogoWidget(
                logoUrl: activeLogoDisplay,
                logoBytes: _pickedLogoBytes,
                size: 64,
                borderRadius: 18,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avatarStatusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Tampil di dashboard & profil tokomu',
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
          const Divider(height: 1, color: AppColors.borderSlate),
          const SizedBox(height: 14),

          // Pilihan Avatar Tematik Langsung
          const Text(
            'PILIH AVATAR TEMATIK TOKO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.secondarySlate,
            ),
          ),
          const SizedBox(height: 10),

          // Grid 8 Preset Avatar
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MsmeLogoHelper.presets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.84,
            ),
            itemBuilder: (context, index) {
              final preset = MsmeLogoHelper.presets[index];
              final isSelected = _selectedPresetAvatarId == preset.id &&
                  _pickedLogoBytes == null;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPresetAvatarId = preset.id;
                    _pickedLogoBytes = null;
                    _pickedLogoFileName = null;
                    _currentLogoUrl = preset.id;
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: preset.bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryNavy
                          : preset.primaryColor.withValues(alpha: 0.25),
                      width: isSelected ? 2.2 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryNavy.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              preset.icon,
                              size: 28,
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : preset.primaryColor,
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                preset.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryNavy
                                      : AppColors.darkSlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Tombol Unggah Foto dari Galeri
          InkWell(
            onTap: _pickCustomPhoto,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _pickedLogoBytes != null
                      ? AppColors.primaryNavy
                      : AppColors.borderSlate,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 18,
                    color: _pickedLogoBytes != null
                        ? AppColors.primaryNavy
                        : AppColors.secondarySlate,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _pickedLogoBytes != null
                        ? 'Ganti Foto Logo Toko'
                        : 'Unggah Logo Sendiri (PNG / JPG)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: _pickedLogoBytes != null
                          ? AppColors.primaryNavy
                          : AppColors.darkSlate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMASI DETAIL USAHA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 16),

            // Nama Usaha
            _buildFieldLabel('Nama Usaha / Toko', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _businessNameCtrl,
              decoration: _inputDecoration(
                Icons.storefront_rounded,
                'Contoh: Kopi Tepi Kali',
              ),
            ),
            const SizedBox(height: 16),

            // Nama Pemilik Usaha
            _buildFieldLabel('Nama Pemilik Usaha'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _ownerNameCtrl,
              decoration: _inputDecoration(
                Icons.person_outline_rounded,
                'Contoh: Ibu Rina',
              ),
            ),
            const SizedBox(height: 16),

            // Kategori Usaha
            _buildFieldLabel('Bidang / Kategori Usaha'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primaryNavy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel
                            ? AppColors.primaryNavy
                            : AppColors.borderSlate,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.white : AppColors.darkSlate,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedCategory == 'Lainnya') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _customCategoryCtrl,
                decoration: _inputDecoration(
                  Icons.edit_note_rounded,
                  'Tuliskan bidang usaha Anda',
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Alamat Usaha
            _buildFieldLabel('Alamat Fisik Usaha'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressCtrl,
              decoration: _inputDecoration(
                Icons.location_on_outlined,
                'Contoh: Jl. Ketintang Baru No. 12',
              ),
            ),
            const SizedBox(height: 16),

            // Kota / Wilayah
            _buildFieldLabel('Kota / Wilayah Usaha'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _cityCtrl,
              decoration: _inputDecoration(
                Icons.location_city_rounded,
                'Contoh: Surabaya',
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi Singkat Usaha
            _buildFieldLabel('Deskripsi Singkat Usaha'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Ceritakan profil usaha, produk unggulan, atau latar belakang usahamu...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(14),
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
              ),
            ),
          ],
        ),
      );

  Widget _buildLegalSection() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'LEGALITAS & VERIFIKASI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'Opsional',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildFieldLabel('Nomor Induk Berusaha (NIB)'),
            const SizedBox(height: 4),
            const Text(
              'Masukkan 13 digit NIB untuk mendapatkan status lencana Verified Partner.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondarySlate,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nibCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                Icons.verified_user_rounded,
                '13 digit nomor NIB',
              ),
            ),
          ],
        ),
      );

  Future<void> _confirmDeleteAccount() async {
    if (_isDeletingAccount) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Akun Mitra Permanen?',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Seluruh data profil usaha, logo, dan akses akun Mitra UMKM Anda akan dihapus permanen. Pastikan tidak ada proyek berjalan atau saldo escrow yang masih tertahan.',
          style: TextStyle(
            color: AppColors.secondarySlate,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.secondarySlate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Hapus Akun',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _msmeApi.deleteAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.roleSelection,
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      await AppStatusDialog.showError(
        context,
        title: 'Tidak Dapat Menghapus Akun',
        message: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Menghapus Akun',
        message: 'Terjadi kendala saat menghapus akun Mitra UMKM.',
      );
    }
  }

  Widget _buildDangerZoneSection() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB91C1C),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Hapus Akun Permanen',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tindakan ini menghapus profil usaha dan menonaktifkan akses login secara permanen.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7F1D1D),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving || _isDeletingAccount
                    ? null
                    : _confirmDeleteAccount,
                icon: _isDeletingAccount
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFB91C1C),
                        ),
                      )
                    : const Icon(Icons.delete_forever_rounded, size: 18),
                label: Text(
                  _isDeletingAccount
                      ? 'Menghapus akun...'
                      : 'Hapus Akun Mitra UMKM',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderSlate),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan Usaha',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );

  Widget _buildFieldLabel(String label, {bool isRequired = false}) => Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      );

  InputDecoration _inputDecoration(IconData icon, String hint) =>
      InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.secondarySlate, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
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
