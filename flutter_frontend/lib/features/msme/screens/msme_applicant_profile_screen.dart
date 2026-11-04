import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class MsmeApplicantProfileScreen extends StatefulWidget {
  const MsmeApplicantProfileScreen({
    super.key,
    this.applicantName = 'Arya Pratama',
    this.projectName = 'Aplikasi Menu & Pre-order Kopi',
  });

  final String applicantName;
  final String projectName;

  @override
  State<MsmeApplicantProfileScreen> createState() =>
      _MsmeApplicantProfileScreenState();
}

class _MsmeApplicantProfileScreenState
    extends State<MsmeApplicantProfileScreen> {
  int _selectedCertTab = 0; // 0: Semua, 1: Mentor TalentSync, 2: Eksternal

  final List<String> _certTabs = ['Semua', 'Mentor TalentSync', 'Eksternal'];

  void _onAccept() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selamat! Kolaborasi dengan ${widget.applicantName} dimulai. Dana escrow diamankan.',
        ),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _onReject() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lamaran ${widget.applicantName} telah ditolak.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _onChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka percakapan dengan ${widget.applicantName}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      child: Stack(
        children: [
          // Scrollable Page Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profil Pelamar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkSlate,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Melamar: ${widget.projectName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.secondarySlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        tooltip: 'Chat',
                        padding: EdgeInsets.zero,
                        onPressed: _onChat,
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppColors.darkSlate,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card 1: Applicant Profile Card
                Container(
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
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Text(
                                'AP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.applicantName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Sistem Informasi · UNESA',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildPillBadge(
                                      icon: Icons.check_circle_rounded,
                                      label: 'KTM terverifikasi',
                                      bgColor: const Color(0xFFF0FDF4),
                                      textColor: const Color(0xFF047857),
                                      borderColor: const Color(0xFFBBF7D0),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildPillBadge(
                                      icon: Icons.military_tech_rounded,
                                      label: 'Endorse Mentor',
                                      bgColor: const Color(0xFFFFFBEB),
                                      textColor: const Color(0xFFB45309),
                                      borderColor: const Color(0xFFFDE68A),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 4 Metric Boxes
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            _buildProfileMetric('4.9', 'Rating'),
                            _buildMetricDivider(),
                            _buildProfileMetric('4', 'Proyek'),
                            _buildMetricDivider(),
                            _buildProfileMetric('96', 'Jam'),
                            _buildMetricDivider(),
                            _buildProfileMetric('4', 'Sertifikat'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 2: Rekomendasi mentor
                const Text(
                  'Rekomendasi mentor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dimas Prasetyo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Senior Flutter Engineer · 2 hari lalu',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: const Text(
                              '95% cocok',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          '"Arya sudah 3 sesi bersama saya membahas arsitektur Flutter dan mengerjakan modul offline-sync yang kini dipakai koperasi. Cocok untuk aplikasi pre-order yang butuh stabil di jam ramai."',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(
                            Icons.adjust_rounded,
                            color: AppColors.primaryNavy,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Khusus untuk proyek Aplikasi Menu & Pre-order Kopi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 3: Hasil proyek nyata
                Row(
                  children: [
                    const Text(
                      'Hasil proyek nyata',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkSlate,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '3 terverifikasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Horizontal Carousel of Real Projects
                SizedBox(
                  height: 240,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildRealProjectCard(
                        title: 'Modul offline-sync aplikasi koperasi',
                        client: 'Koperasi Pasar Genteng',
                        verifiedBadge: 'Diverifikasi Mentor',
                        isMentorVerified: true,
                        quote: '"Dipakai 40 pedagang setiap hari tanpa kendala."',
                        tech: 'Flutter · SQLite',
                        rating: '5.0',
                        imageUrl:
                            'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=300&q=80',
                      ),
                      const SizedBox(width: 14),
                      _buildRealProjectCard(
                        title: 'Sistem reservasi meja',
                        client: 'Warung Pak Gito',
                        verifiedBadge: 'Diverifikasi UMKM',
                        isMentorVerified: false,
                        quote: '"Pesanan ganda hilang, karyawan mudah memakainya."',
                        tech: 'Laravel · MySQL',
                        rating: '5.0',
                        imageUrl:
                            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=300&q=80',
                      ),
                      const SizedBox(width: 14),
                      _buildRealProjectCard(
                        title: 'Katalog digital produk',
                        client: 'Kerajinan Anyam Ayu',
                        verifiedBadge: 'Diverifikasi UMKM',
                        isMentorVerified: false,
                        quote: '"Penjualan via WhatsApp naik sejak katalog dipakai."',
                        tech: 'Flutter · Firebase',
                        rating: '4.8',
                        imageUrl:
                            'https://images.unsplash.com/photo-1526738549149-8e07eca6c147?auto=format&fit=crop&w=300&q=80',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section 4: Sertifikat
                const Text(
                  'Sertifikat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Tabs
                Row(
                  children: List.generate(_certTabs.length, (index) {
                    final bool isSelected = _selectedCertTab == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCertTab = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryNavy : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : AppColors.borderSlate,
                            ),
                          ),
                          child: Text(
                            _certTabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.darkSlate,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 14),

                // Certificate List
                if (_selectedCertTab == 0 || _selectedCertTab == 1) ...[
                  _buildCertificateTile(
                    title: 'Rekomendasi Kerja: Flutter Developer',
                    issuer: 'Dimas Prasetyo · Mentor · Jul 2025',
                    tag: 'Mentor',
                    isMentor: true,
                  ),
                  const SizedBox(height: 10),
                  _buildCertificateTile(
                    title: 'Lulus Bimbingan: Arsitektur Flutter & BLoC',
                    issuer: 'Dimas Prasetyo · Mentor · Jul 2025',
                    tag: 'Mentor',
                    isMentor: true,
                  ),
                  const SizedBox(height: 10),
                ],
                if (_selectedCertTab == 0 || _selectedCertTab == 2) ...[
                  _buildCertificateTile(
                    title: 'Menjadi Flutter Developer Expert',
                    issuer: 'Dicoding Indonesia · Mar 2025',
                    tag: 'Eksternal',
                    isMentor: false,
                  ),
                  const SizedBox(height: 10),
                  _buildCertificateTile(
                    title: 'Junior Mobile Programmer',
                    issuer: 'BNSP · Jan 2025',
                    tag: 'Eksternal',
                    isMentor: false,
                  ),
                ],

                const SizedBox(height: 24),

                // Section 5: Keahlian terverifikasi
                const Text(
                  'Keahlian terverifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSkillRow('Flutter', 'Endorse mentor · 2 proyek'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildSkillRow('Laravel', '2 proyek UMKM'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildSkillRow('MySQL', '1 proyek UMKM'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildSkillRow('Dart', 'GitHub 7 repo'),
                      const SizedBox(height: 14),
                      // GitHub Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.code_rounded,
                              color: AppColors.primaryNavy,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'github.com/aryapratama',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '12 repo · 284 commit · Dart 52% · PHP 31%',
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

                const SizedBox(height: 24),

                // Section 6: Pesan lamaran
                const Text(
                  'Pesan lamaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkSlate,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yth. Kopi Tepi Kali, saya sudah membangun aplikasi kasir dan sistem reservasi untuk UMKM kuliner. Saya siap mulai minggu ini dengan target prototipe di hari ke-5.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: AppColors.secondarySlate,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Komitmen: 1 Bulan · 10–15 jam/minggu',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Fixed Action Bar: Tolak & Accept & Collaborate
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderSlate.withValues(alpha: 0.8),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _onReject,
                          borderRadius: BorderRadius.circular(14),
                          child: const Center(
                            child: Text(
                              'Tolak',
                              style: TextStyle(
                                color: AppColors.darkSlate,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
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
                          onTap: _onAccept,
                          borderRadius: BorderRadius.circular(14),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Accept & Collaborate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.handshake_rounded,
                                  color: Colors.white,
                                  size: 18,
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
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildPillBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textColor, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );

  Widget _buildProfileMetric(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.darkSlate,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.secondarySlate,
          ),
        ),
      ],
    ),
  );

  Widget _buildMetricDivider() => Container(
    width: 1,
    height: 24,
    color: const Color(0xFFE2E8F0),
  );

  Widget _buildRealProjectCard({
    required String title,
    required String client,
    required String verifiedBadge,
    required bool isMentorVerified,
    required String quote,
    required String tech,
    required String rating,
    required String imageUrl,
  }) => Container(
    width: 270,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
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
        // Thumbnail Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(
            imageUrl,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMentorVerified
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMentorVerified
                          ? Icons.military_tech_rounded
                          : Icons.verified_rounded,
                      color: isMentorVerified
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      verifiedBadge,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isMentorVerified
                          ? const Color(0xFFB45309)
                          : const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                client,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondarySlate,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                quote,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    tech,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondarySlate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildCertificateTile({
    required String title,
    required String issuer,
    required String tag,
    required bool isMentor,
  }) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderSlate),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isMentor
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isMentor
                ? Icons.military_tech_rounded
                : Icons.workspace_premium_outlined,
            color: isMentor ? const Color(0xFFF59E0B) : AppColors.primaryNavy,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                issuer,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSkillRow(String skill, String proof) => Row(
    children: [
      const Icon(
        Icons.verified_rounded,
        color: AppColors.primaryNavy,
        size: 18,
      ),
      const SizedBox(width: 10),
      Text(
        skill,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: AppColors.darkSlate,
        ),
      ),
      const Spacer(),
      Text(
        proof,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.secondarySlate,
        ),
      ),
    ],
  );
}

