import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/widgets/app_status_dialog.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/widgets/msme_finance_modals.dart';

class MsmeBarterScreen extends StatefulWidget {
  const MsmeBarterScreen({
    super.key,
    this.msmeApi,
    this.onBalanceChanged,
  });

  final MsmeApi? msmeApi;
  final VoidCallback? onBalanceChanged;

  @override
  State<MsmeBarterScreen> createState() => _MsmeBarterScreenState();
}

class _MsmeBarterScreenState extends State<MsmeBarterScreen> {
  late final MsmeApi _msmeApi = widget.msmeApi ?? MsmeApi.instance;

  static const _voucherTypes = [
    (key: 'free_product', label: 'Gratis produk'),
    (key: 'discount', label: 'Diskon'),
    (key: 'bundle', label: 'Paket hemat'),
  ];
  static const _validityOptions = [30, 60, 90];

  int _selectedVoucherType = 0;
  final _voucherNameController = TextEditingController();
  int _voucherQuantity = 5;
  final _voucherPriceController = TextEditingController(text: '15000');
  int _selectedValidity = 1; // 60 hari
  bool _isGuaranteed = true;

  Uint8List? _designBytes;
  String? _designFileName;

  bool _isLoading = true;
  bool _isSubmitting = false;
  int _balanceTc = 0;
  bool _isPremium = false;
  List<Map<String, dynamic>> _barters = const [];

  int get _valueIdr =>
      int.tryParse(
        _voucherPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      ) ??
      0;

  int get _tcPerVoucher => _valueIdr >= 1000 ? (_valueIdr / 1000).round() : 0;

  int get _estimatedTc => _voucherQuantity * _tcPerVoucher;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = await ApiClient.instance.readSessionUser();
    if (mounted && session != null && _isLoading) {
      setState(() {
        _balanceTc = (session['balance_tc'] as num?)?.toInt() ?? _balanceTc;
        _isPremium = (session['is_premium'] as bool?) ?? _isPremium;
      });
    }

    try {
      final data = await _msmeApi.getBarters();
      if (!mounted) return;
      final rows = data['barters'];
      setState(() {
        _balanceTc = (data['balance_tc'] as num?)?.toInt() ?? 0;
        _isPremium = (data['is_premium'] as bool?) ?? false;
        _barters = rows is List
            ? rows.whereType<Map<String, dynamic>>().toList(growable: false)
            : const [];
        _isLoading = false;
      });
      await ApiClient.instance.updateSessionUser({
        'balance_tc': _balanceTc,
        'is_premium': _isPremium,
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _voucherNameController.dispose();
    _voucherPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickDesignFile() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Pilih Desain Voucher (PNG/JPG)',
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg'],
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) return;
      if (bytes.lengthInBytes > 3 * 1024 * 1024) {
        if (!mounted) return;
        await AppStatusDialog.showError(
          context,
          title: 'File Terlalu Besar',
          message: 'Ukuran desain voucher maksimal 3 MB (PNG atau JPG).',
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _designBytes = bytes;
        _designFileName = picked.name;
      });
    } catch (_) {
      if (!mounted) return;
      await AppStatusDialog.showError(
        context,
        title: 'Gagal Memilih Gambar',
        message: 'Tidak dapat membuka pemilih gambar di perangkat ini.',
      );
    }
  }

  Future<void> _openTopUp() async {
    final ok = await MsmeTopUpSheet.show(
      context,
      isPremium: _isPremium,
      msmeApi: _msmeApi,
    );
    if (ok && mounted) {
      await _loadData();
      widget.onBalanceChanged?.call();
    }
  }

  Future<void> _onExchange() async {
    if (_isSubmitting) return;

    final title = _voucherNameController.text.trim();
    if (title.length < 3) {
      await AppStatusDialog.showError(
        context,
        title: 'Nama Voucher Wajib Diisi',
        message: 'Tulis nama voucher minimal 3 karakter (misal: Gratis 1 Es Kopi Susu).',
      );
      return;
    }

    if (_valueIdr < 5000) {
      await AppStatusDialog.showError(
        context,
        title: 'Nilai Voucher Terlalu Kecil',
        message: 'Nilai minimal per voucher adalah Rp5.000 (5 TC).',
      );
      return;
    }

    if (!_isGuaranteed) {
      await AppStatusDialog.showError(
        context,
        title: 'Pernyataan Belum Dicentang',
        message:
            'Centang pernyataan jaminan penukaran voucher sebelum melanjutkan.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _msmeApi.createBarter(
        voucherType: _voucherTypes[_selectedVoucherType].key,
        title: title,
        quantity: _voucherQuantity,
        valueIdr: _valueIdr,
        validityDays: _validityOptions[_selectedValidity],
        isGuaranteed: _isGuaranteed,
        designFileName: _designFileName,
        designBytes: _designBytes,
      );
      final data = response['data'] as Map<String, dynamic>? ?? const {};
      final newBalance = (data['balance_tc'] as num?)?.toInt();
      if (newBalance != null) {
        await ApiClient.instance.updateSessionUser({'balance_tc': newBalance});
      }
      if (!mounted) return;
      await AppStatusDialog.showSuccess(
        context,
        title: 'Barter +$_estimatedTc TC Berhasil',
        message:
            'Voucher "$title" ($_voucherQuantity pcs) resmi tayang di Katalog Hadiah mahasiswa dan saldo TimeCoin usaha langsung bertambah.',
      );
      if (!mounted) return;
      setState(() {
        _voucherNameController.clear();
        _designBytes = null;
        _designFileName = null;
        _isSubmitting = false;
      });
      await _loadData();
      widget.onBalanceChanged?.call();
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Barter Voucher Gagal',
        message: err.message,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await AppStatusDialog.showError(
        context,
        title: 'Koneksi Bermasalah',
        message: 'Tidak dapat memproses barter voucher saat ini. Coba lagi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryNavy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Isi Saldo Barter',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Saldo $_balanceTc TC · Setara ${formatRupiah(_balanceTc * 1000)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondarySlate,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _openTopUp,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_card_rounded, size: 17),
                    label: const Text(
                      'Top Up',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info Banner: Tukar voucher fisik jadi TimeCoin
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.primaryNavy,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          text: 'Tukar voucher produk jadi TimeCoin. ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                            height: 1.45,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Voucher langsung tayang di Katalog Hadiah mahasiswa, dan saldo TC bisa dipakai mendanai proyek.',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Showcase Carousel
              const InteractiveImageCarousel(
                margin: EdgeInsets.zero,
                height: 175,
                items: [
                  CarouselSlideItem(
                    imageUrl:
                        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
                    tag: 'Voucher Kuliner',
                    tagColor: AppColors.primaryNavy,
                    title: 'Voucher Es Kopi Susu & Pastry',
                    subtitle:
                        'Paling diminati mahasiswa saat jam istirahat atau nugas kelompok di kafe.',
                    buttonText: 'Inspirasi',
                  ),
                  CarouselSlideItem(
                    imageUrl:
                        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                    tag: 'Paket Produk',
                    tagColor: Color(0xFFB45309),
                    title: 'Paket Sambal Rumahan & Frozen Food',
                    subtitle:
                        'Dikonversi 35 TC per botol, cepat ditukar oleh talenta proyek.',
                    buttonText: 'Inspirasi',
                  ),
                  CarouselSlideItem(
                    imageUrl:
                        'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80',
                    tag: 'Kerajinan Tangan',
                    tagColor: Color(0xFF10B981),
                    title: 'Merchandise & Souvenir UMKM Kreatif',
                    subtitle:
                        'Cocok sebagai apresiasi pencapaian tugas mahasiswa berprestasi.',
                    buttonText: 'Inspirasi',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Form Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                    const _FieldLabel('Jenis voucher'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_voucherTypes.length, (index) {
                        final isSelected = _selectedVoucherType == index;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedVoucherType = index),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
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
                            ),
                            child: Text(
                              _voucherTypes[index].label,
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
                      }),
                    ),

                    const SizedBox(height: 18),

                    const _FieldLabel('Nama voucher'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _voucherNameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        'Contoh: Gratis 1 Es Kopi Susu',
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Jumlah voucher'),
                              const SizedBox(height: 8),
                              Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.borderSlate,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (_voucherQuantity > 1) {
                                          setState(() => _voucherQuantity--);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          color: AppColors.darkSlate,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$_voucherQuantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (_voucherQuantity < 100) {
                                          setState(() => _voucherQuantity++);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: AppColors.darkSlate,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Nilai per voucher (Rp)'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _voucherPriceController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: _inputDecoration('15000'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const _FieldLabel('Masa berlaku'),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(_validityOptions.length, (index) {
                        final isSelected = _selectedValidity == index;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < _validityOptions.length - 1
                                  ? 8.0
                                  : 0.0,
                            ),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedValidity = index),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
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
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_validityOptions[index]} hari',
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
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 18),

                    // Unggah Desain Voucher
                    InkWell(
                      onTap: _pickDesignFile,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _designFileName != null
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _designFileName != null
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _designFileName != null
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _designFileName != null
                                    ? Icons.check_circle_rounded
                                    : Icons.add_photo_alternate_rounded,
                                color: _designFileName != null
                                    ? const Color(0xFF047857)
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
                                    _designFileName ?? 'Unggah desain voucher',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _designFileName != null
                                        ? 'Siap diunggah · Ketuk untuk mengganti'
                                        : 'Opsional (PNG/JPG maks 3 MB)',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.secondarySlate,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_designFileName != null)
                              IconButton(
                                tooltip: 'Hapus gambar',
                                onPressed: () => setState(() {
                                  _designBytes = null;
                                  _designFileName = null;
                                }),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Estimasi TimeCoin Diterima Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Estimasi TimeCoin diterima',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Nilai tukar 100%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.toll_rounded,
                          color: Color(0xFFF59E0B),
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+$_estimatedTc TC',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_voucherQuantity voucher × $_tcPerVoucher TC · berlaku ${_validityOptions[_selectedValidity]} hari',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Guarantee Checkbox Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _isGuaranteed,
                        activeColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                        onChanged: (val) =>
                            setState(() => _isGuaranteed = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Saya menjamin voucher dapat ditukar mahasiswa di toko selama masa berlaku.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkSlate,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Exchange Action Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _isSubmitting
                      ? AppColors.primaryNavy.withValues(alpha: 0.65)
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
                    onTap: _isSubmitting ? null : _onExchange,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Tukar jadi +$_estimatedTc TimeCoin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Section: Riwayat barter
              const Text(
                'Riwayat barter voucher',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                )
              else if (_barters.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.confirmation_number_rounded,
                        color: AppColors.secondarySlate,
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum Ada Riwayat Barter Voucher',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Voucher produk yang kamu barter akan muncul di sini beserta progres penukaran mahasiswa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._barters.map((item) {
                  final title = (item['title'] as String?) ?? 'Voucher UMKM';
                  final totalTc = (item['total_tc'] as num?)?.toInt() ?? 0;
                  final qty = (item['quantity'] as num?)?.toInt() ?? 1;
                  final redeemed =
                      (item['redeemed_count'] as num?)?.toInt() ?? 0;
                  final expiresLabel = _formatExpiryDate(
                    item['expires_at'] as String?,
                  );
                  final ratio = qty > 0 ? (redeemed / qty).clamp(0.0, 1.0) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildHistoryItem(
                      title: title,
                      tcAmount: '+$totalTc TC',
                      progressText:
                          '$redeemed/$qty ditukar · berlaku s.d. $expiresLabel',
                      progressRatio: ratio,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    ),
  );

  String _formatExpiryDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  Widget _buildHistoryItem({
    required String title,
    required String tcAmount,
    required String progressText,
    required double progressRatio,
  }) => Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tcAmount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressRatio,
            minHeight: 5,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          progressText,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.secondarySlate,
          ),
        ),
      ],
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
