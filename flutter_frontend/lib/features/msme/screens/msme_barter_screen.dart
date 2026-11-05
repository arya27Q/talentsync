import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';

class MsmeBarterScreen extends StatefulWidget {
  const MsmeBarterScreen({super.key});

  @override
  State<MsmeBarterScreen> createState() => _MsmeBarterScreenState();
}

class _MsmeBarterScreenState extends State<MsmeBarterScreen> {
  int _selectedVoucherType = 0; // 0: Gratis produk, 1: Diskon, 2: Paket hemat
  final _voucherNameController = TextEditingController(
    text: 'Gratis 1 Es Kopi Susu',
  );
  int _voucherQuantity = 5;
  final _voucherPriceController = TextEditingController(text: '15000');
  int _selectedValidity = 1; // 0: 30 hari, 1: 60 hari, 2: 90 hari
  bool _isGuaranteed = true;

  final List<String> _voucherTypes = ['Gratis produk', 'Diskon', 'Paket hemat'];

  final List<String> _validities = ['30 hari', '60 hari', '90 hari'];

  int get _estimatedTc {
    final price = int.tryParse(_voucherPriceController.text.trim()) ?? 15000;
    // 1 TC = 1000 Rp, so 15,000 Rp = 15 TC per voucher
    final tcPerVoucher = (price / 1000).round();
    return _voucherQuantity * tcPerVoucher;
  }

  @override
  void dispose() {
    _voucherNameController.dispose();
    _voucherPriceController.dispose();
    super.dispose();
  }

  void _onExchange() {
    if (!_isGuaranteed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Centang pernyataan jaminan penukaran voucher sebelum melanjutkan.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voucher "${_voucherNameController.text}" berhasil dibarter menjadi $_estimatedTc TimeCoin!',
        ),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Isi Saldo Barter',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkSlate,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Saldo 520 TC',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondarySlate,
                  fontWeight: FontWeight.w500,
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
                      text: 'Tukar voucher fisik jadi TimeCoin. ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                        height: 1.45,
                      ),
                      children: [
                        TextSpan(
                          text: 'Voucher tampil di Katalog Hadiah mahasiswa, dan saldo bisa kamu pakai untuk membayar proyek.',
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

          // Showcase Carousel: Contoh Produk & Voucher Mitra yang Laris di Katalog Hadiah
          const InteractiveImageCarousel(
            margin: EdgeInsets.zero,
            height: 175,
            items: [
              CarouselSlideItem(
                imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
                tag: 'Voucher Kuliner',
                tagColor: AppColors.primaryNavy,
                title: 'Voucher Es Kopi Susu & Pastry',
                subtitle: 'Paling diminati mahasiswa saat jam istirahat atau nugas kelompok di kafe.',
                buttonText: 'Contoh',
              ),
              CarouselSlideItem(
                imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                tag: 'Paket Produk',
                tagColor: Color(0xFFB45309),
                title: 'Paket Sambal Rumahan & Frozen Food',
                subtitle: 'Dikonversi 35 TC per botol, cepat di-redeem oleh talenta proyek.',
                buttonText: 'Contoh',
              ),
              CarouselSlideItem(
                imageUrl: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80',
                tag: 'Kerajinan Tangan',
                tagColor: Color(0xFF10B981),
                title: 'Merchandise & Souvenir UMKM Kreatif',
                subtitle: 'Cocok sebagai apresiasi pencapaian tugas mahasiswa berprestasi.',
                buttonText: 'Contoh',
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
                // Jenis Voucher
                const _FieldLabel('Jenis voucher'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_voucherTypes.length, (index) {
                    final bool isSelected = _selectedVoucherType == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVoucherType = index;
                        });
                      },
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
                          _voucherTypes[index],
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

                // Nama Voucher
                const _FieldLabel('Nama voucher'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _voucherNameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration('Contoh: Gratis 1 Es Kopi Susu'),
                ),

                const SizedBox(height: 18),

                // Jumlah & Nilai row
                Row(
                  children: [
                    // Jumlah Counter
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Jumlah voucher'),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSlate),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (_voucherQuantity > 1) {
                                      setState(() {
                                        _voucherQuantity--;
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.remove_rounded,
                                    color: AppColors.darkSlate,
                                    size: 18,
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
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _voucherQuantity++;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_rounded,
                                    color: AppColors.darkSlate,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nilai per voucher
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

                // Masa Berlaku
                const _FieldLabel('Masa berlaku'),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(_validities.length, (index) {
                    final bool isSelected = _selectedValidity == index;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < _validities.length - 1 ? 8.0 : 0.0,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedValidity = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                                _validities[index],
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.primaryNavy,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unggah desain voucher',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Opsional · kami bantu buatkan jika kosong',
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
                    const Text(
                      'Estimasi TimeCoin diterima',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    const Spacer(),
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
                  '$_voucherQuantity voucher × ${(_estimatedTc / _voucherQuantity).round()} TC · berlaku ${_validities[_selectedValidity]}',
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
                  width: 22,
                  height: 22,
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

          const SizedBox(height: 24),

          // Section: Riwayat barter
          const Text(
            'Riwayat barter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Item 1: Gratis 1 Es Kopi Susu
          _buildHistoryItem(
            title: 'Gratis 1 Es Kopi Susu',
            tcAmount: '+300 TC',
            progressText: '12/20 ditukar · 28 Jun',
            progressRatio: 12 / 20,
          ),
          const SizedBox(height: 10),

          // Item 2: Diskon 20% semua menu
          _buildHistoryItem(
            title: 'Diskon 20% semua menu',
            tcAmount: '+90 TC',
            progressText: '30/30 ditukar · 2 Jun',
            progressRatio: 1.0,
          ),

          const SizedBox(height: 24),

          // Exchange Action Button
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
                onTap: _onExchange,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Exchange for $_estimatedTc TimeCoin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
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
        ],
      ),
    ),
  );

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
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const Spacer(),
            Text(
              tcAmount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
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
