import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/widgets/interactive_image_carousel.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_applicants_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_review_submission_screen.dart';

class MsmePostingsScreen extends StatefulWidget {
  const MsmePostingsScreen({super.key, required this.onCreatePosting});

  final VoidCallback onCreatePosting;

  @override
  State<MsmePostingsScreen> createState() => _MsmePostingsScreenState();
}

class _MsmePostingsScreenState extends State<MsmePostingsScreen> {
  int _selectedTabIndex = 0; // 0: Rekrut (1), 1: Berjalan (1), 2: Selesai (1)

  final List<String> _tabs = ['Rekrut (1)', 'Berjalan (1)', 'Selesai (1)'];

  void _openReviewApplicants() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => const MsmeReviewApplicantsScreen(),
      ),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Postingan Tugas Saya',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Slot aktif 2/2',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondarySlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
                    tooltip: 'Buat postingan baru',
                    padding: EdgeInsets.zero,
                    onPressed: widget.onCreatePosting,
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AppColors.darkSlate,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3-Pill Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSlate),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final bool isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.secondarySlate,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Scrollable Postings Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              child: Column(
                children: [
                  // Showcase Carousel: Standar & Dokumentasi Kualitas Proyek UMKM
                  const InteractiveImageCarousel(
                    margin: EdgeInsets.only(bottom: 16),
                    height: 170,
                    items: [
                      CarouselSlideItem(
                        imageUrl: 'https://images.unsplash.com/photo-1542744094-3a31f272c490?auto=format&fit=crop&w=800&q=80',
                        tag: 'Tahap 1: Riset',
                        tagColor: AppColors.primaryNavy,
                        title: 'Briefing & Riset Visual Kemasan',
                        subtitle: 'Mahasiswa menyusun moodboard visual sesuai target pasar sebelum eksekusi desain.',
                        buttonText: 'Alur',
                      ),
                      CarouselSlideItem(
                        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                        tag: 'Tahap 2: Hasil Kerja',
                        tagColor: Color(0xFFB45309),
                        title: 'Uji Coba Lapangan & Mockup Cetak',
                        subtitle: 'Penerapan desain pada kemasan botol sambal atau menu board kafe secara nyata.',
                        buttonText: 'Standar',
                      ),
                      CarouselSlideItem(
                        imageUrl: 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?auto=format&fit=crop&w=800&q=80',
                        tag: 'Tahap 3: Escrow',
                        tagColor: Color(0xFF10B981),
                        title: 'Serah Terima & Pencairan TimeCoin',
                        subtitle: 'File siap cetak diserahkan dan dana escrow ditransfer dengan ulasan bintang.',
                        buttonText: 'Ketentuan',
                      ),
                    ],
                  ),
                  if (_selectedTabIndex == 0) ...[
                    // Tab 0: Rekrut (1) -> Aplikasi Menu & Pre-order Kopi
                    _buildRecruitingCard(context),
                  ] else if (_selectedTabIndex == 1) ...[
                    // Tab 1: Berjalan (1) -> Desain Menu Board & Feed Instagram
                    _buildOngoingCard(context),
                  ] else ...[
                    // Tab 2: Selesai (1) -> Foto Produk Menu Musim Hujan
                    _buildCompletedCard(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // Tab 0 Card
  Widget _buildRecruitingCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSlate),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=150&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aplikasi Menu & Pre-order Kopi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Diposting 2 hari lalu · Hybrid',
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

        const SizedBox(height: 14),

        // Tag Chips
        Row(
          children: [
            _buildTagChip(
              'Mobile',
              const Color(0xFFEFF6FF),
              AppColors.primaryNavy,
            ),
            const SizedBox(width: 8),
            _buildTcTagChip('380 TC'),
            const SizedBox(width: 8),
            _buildTagChip(
              '1 Bulan',
              const Color(0xFFF1F5F9),
              const Color(0xFF475569),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Applicant Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                height: 28,
                child: Stack(
                  children: [
                    _buildApplicantDot('RH', const Color(0xFF9A3412), 30),
                    _buildApplicantDot('DL', const Color(0xFF0D9488), 15),
                    _buildApplicantDot('AR', AppColors.primaryNavy, 0),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  text: '3 pelamar · ',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '2 baru',
                      style: TextStyle(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Button: Review Pelamar ➔
        Container(
          width: double.infinity,
          height: 48,
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openReviewApplicants,
              borderRadius: BorderRadius.circular(14),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tinjau Pelamar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // Tab 1 Card: Berjalan (1) - Sesuai gambar 1
  Widget _buildOngoingCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSlate),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=150&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desain Menu Board & Feed Instagram',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Diposting 3 minggu lalu · Remote',
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

        const SizedBox(height: 14),

        // Tag Chips
        Row(
          children: [
            _buildTagChip(
              'UI/UX Design',
              const Color(0xFFEFF6FF),
              AppColors.primaryNavy,
            ),
            const SizedBox(width: 8),
            _buildTcTagChip('120 TC'),
            const SizedBox(width: 8),
            _buildTagChip(
              '3 Minggu',
              const Color(0xFFF1F5F9),
              const Color(0xFF475569),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Student assigned row
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFC2410C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'SP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Salsa Putri · UNESA',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
            ),
            const Text(
              'Tahap 1/3',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.33,
            minHeight: 6,
            backgroundColor: Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
          ),
        ),

        const SizedBox(height: 8),

        // Escrow text
        const Text(
          'Cair 35 TC · terkunci di escrow 85 TC',
          style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
        ),

        const SizedBox(height: 14),

        // Amber notification banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.rate_review_rounded,
                color: Color(0xFFB45309),
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hasil tahap 2 menunggu tinjauanmu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons Row
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Kirim pesan ke mahasiswa',
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MsmeChatScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.darkSlate,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Sinkronisasi status',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tahapan pengerjaan berhasil diperbarui.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.darkSlate,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 44,
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MsmeReviewSubmissionScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: const Center(
                      child: Text(
                        'Tinjau Hasil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // Tab 2 Card: Selesai (1) - Sesuai gambar 2
  Widget _buildCompletedCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.borderSlate),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=150&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto Produk Menu Musim Hujan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Diposting 1 bulan lalu · On-site',
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

        const SizedBox(height: 14),

        // Tag Chips
        Row(
          children: [
            _buildTagChip(
              'Desain',
              const Color(0xFFEFF6FF),
              AppColors.primaryNavy,
            ),
            const SizedBox(width: 8),
            _buildTcTagChip('60 TC'),
            const SizedBox(width: 8),
            _buildTagChip(
              '5 Hari',
              const Color(0xFFF1F5F9),
              const Color(0xFF475569),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Worker & Rating Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Text(
                'Dikerjakan Bima Saputra',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Kirim pesan ke mahasiswa',
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MsmeChatScreen(studentName: 'Bima Saputra'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.darkSlate,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur perpanjang kolaborasi memerlukan penambahan kuota slot.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            color: AppColors.primaryNavy,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Perpanjang Kolaborasi',
                            style: TextStyle(
                              color: AppColors.darkSlate,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFFB45309),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildTagChip(String label, Color bg, Color textColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 11.5,
      ),
    ),
  );

  Widget _buildTcTagChip(String amount) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.toll_rounded, color: Color(0xFFF59E0B), size: 14),
        const SizedBox(width: 5),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFFB45309),
            fontWeight: FontWeight.bold,
            fontSize: 11.5,
          ),
        ),
      ],
    ),
  );

  Widget _buildApplicantDot(String text, Color bg, double left) => Positioned(
    left: left,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
