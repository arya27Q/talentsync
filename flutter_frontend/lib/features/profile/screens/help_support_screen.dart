import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Dompet & TC',
      'desc': 'Escrow & cash-out',
    },
    {
      'icon': Icons.assignment_rounded,
      'title': 'Proyek UMKM',
      'desc': 'Deliverable & revisi',
    },
    {
      'icon': Icons.school_rounded,
      'title': 'Mentoring',
      'desc': 'Sesi & endorsement',
    },
    {
      'icon': Icons.verified_user_rounded,
      'title': 'Verifikasi KTM',
      'desc': 'Status akun kampus',
    },
  ];

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Berapa lama proses pencairan TimeCoin ke rekening bank?',
      'answer':
          'Pencairan TimeCoin diproses instan hingga maksimal 1x24 jam kerja. Mahasiswa menikmati potongan admin 0% sehingga seluruh nilai 1 TC setara Rp1.000 masuk utuh ke rekening bank Anda.',
    },
    {
      'question': 'Bagaimana jika mitra UMKM belum memvalidasi hasil kerja?',
      'answer':
          'Sistem Smart Escrow TalentSync dilengkapi fitur auto-release. Apabila mitra tidak memberikan catatan revisi atau validasi dalam 3x24 jam kerja, dana TC otomatis diteruskan ke saldo Anda.',
    },
    {
      'question': 'Apa syarat mendapatkan Badge Rekomendasi Kerja dari mentor?',
      'answer':
          'Mahasiswa perlu menyelesaikan minimal satu paket mentoring dengan evaluasi nilai akhir di atas 80/100 serta membuktikan artefak hasil kerja nyata yang siap dipresentasikan ke mitra UMKM.',
    },
    {
      'question': 'Apakah saya bisa menjadwalkan ulang sesi mentoring?',
      'answer':
          'Bisa. Anda dapat mengajukan perubahan jadwal melalui fitur chat langsung dengan mentor minimal 2 jam sebelum waktu sesi dimulai.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildQuickCategoryCard(int index, Map<String, dynamic> item) {
    final bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.borderSlate,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item['icon'] as IconData,
              color: isSelected ? AppColors.primaryNavy : AppColors.secondarySlate,
              size: 24,
            ),
            const Spacer(),
            Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryNavy : AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item['desc'] as String,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppColors.primaryNavy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppColors.darkSlate,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Bantuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'Panduan fitur, kendala transaksi, dan kontak CS',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkSlate.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari topik bantuan atau kendala...',
                        hintStyle: TextStyle(
                          color: AppColors.secondarySlate,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.secondarySlate,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kategori Cepat
                  const Text(
                    'Kategori Pertanyaan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      _categories.length,
                      (index) => _buildQuickCategoryCard(index, _categories[index]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FAQ Section
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pertanyaan Umum (FAQ)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._faqItems.map(
                    (faq) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSlate),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          iconColor: AppColors.primaryNavy,
                          collapsedIconColor: AppColors.secondarySlate,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          childrenPadding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          children: [
                            Text(
                              faq['answer']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySlate,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hubungi Tim Dukungan
                  const Text(
                    'Hubungi Kami',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactOption(
                    icon: Icons.chat_rounded,
                    title: 'Live Chat Dukungan TalentSync',
                    subtitle: 'Respon cepat dalam waktu kurang dari 5 menit',
                    iconColor: AppColors.primaryNavy,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menghubungkan ke layanan live chat dukungan...'),
                          backgroundColor: AppColors.primaryNavy,
                        ),
                      );
                    },
                  ),
                  _buildContactOption(
                    icon: Icons.forum_rounded,
                    title: 'WhatsApp Layanan Pengguna',
                    subtitle: 'Bantuan instan via hotline resmi WhatsApp',
                    iconColor: const Color(0xFF16A34A),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membuka kontak WhatsApp resmi TalentSync.'),
                        ),
                      );
                    },
                  ),
                  _buildContactOption(
                    icon: Icons.mail_rounded,
                    title: 'Email Tim Resolusi',
                    subtitle: 'bantuan@talentsync.id · Penanganan 1x24 jam',
                    iconColor: const Color(0xFF2563EB),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membuka aplikasi email ke bantuan@talentsync.id.'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
