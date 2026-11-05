import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.secondarySlate,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color iconColor = AppColors.primaryNavy,
    Color titleColor = AppColors.darkSlate,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
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
                trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text(
              'Keluar dari Akun?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun mahasiswa? Anda harus masuk kembali dengan NIM dan kata sandi.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.secondarySlate,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.secondarySlate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.roleSelection,
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
            // Top App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.darkSlate,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan & Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        'Kelola profil, peran, dan navigasi modul',
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

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                children: [
                  // Student Profile Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkSlate.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
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
                                color: const Color(0xFFE0E7FF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryNavy.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'AP',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
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
                                    'Arya Pratama Yudhistira',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkSlate,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'S1 Sistem Informasi · UNESA',
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

                        // Badges Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: AppColors.accentAmberGold,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Top Talent · 4.9',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFF16A34A),
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'KTM Terverifikasi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Public Portfolio Button
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.portfolio),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryNavy.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Buka Portofolio Publik',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section 1: Peran & Mode Akun
                  _buildSectionHeader('PERAN & MODE AKUN'),
                  _buildMenuItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch to Mentor (Peer Mentor)',
                    subtitle: 'Buka kelas bimbingan & peroleh TimeCoin',
                    iconColor: const Color(0xFF2563EB),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tersedia',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.switchToMentor),
                  ),

                  // Section 2: Mentoring & Bimbingan
                  _buildSectionHeader('MENTORING & BIMBINGAN'),
                  _buildMenuItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Mentor Saya',
                    subtitle: 'Sesi aktif, materi, dan tugas bimbingan',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.myMentors),
                  ),
                  _buildMenuItem(
                    icon: Icons.menu_book_rounded,
                    title: 'Ruang Belajar Mentor',
                    subtitle: 'Materi, tugas, proyek, dan riwayat hasil',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.ruangBelajar),
                  ),
                  _buildMenuItem(
                    icon: Icons.history_edu_rounded,
                    title: 'Log Bimbingan',
                    subtitle: 'Riwayat sesi 1-on-1, catatan mentor, & TC',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.logBimbingan),
                  ),
                  _buildMenuItem(
                    icon: Icons.insights_rounded,
                    title: 'Hasil & Action Plan Bimbingan',
                    subtitle: 'Skor evaluasi 88/100 & rekomendasi kerja',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.mentoringResult),
                  ),
                  _buildMenuItem(
                    icon: Icons.person_search_rounded,
                    title: 'Cari & Booking Mentor',
                    subtitle: 'Eksplorasi mentor terverifikasi industri',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.findMentors),
                  ),

                  // Section 3: Proyek & Portofolio
                  _buildSectionHeader('PROYEK & PORTOFOLIO'),
                  _buildMenuItem(
                    icon: Icons.assignment_rounded,
                    title: 'Proyek Saya',
                    subtitle: 'Kasir Toko Bu Sri · Tahap 2 Aktif',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.myProjects),
                  ),
                  _buildMenuItem(
                    icon: Icons.checklist_rounded,
                    title: 'Status Proyek & Milestone',
                    subtitle: 'Kelola serah terima deliverable & escrow',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.submission),
                  ),
                  _buildMenuItem(
                    icon: Icons.task_alt_rounded,
                    title: 'Hasil Proyek Selesai',
                    subtitle: 'Ulasan bintang 5.0 dari Pak Gito & 40 TC',
                    iconColor: const Color(0xFF10B981),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.projectCompleted,
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Sertifikat & Rekomendasi',
                    subtitle: 'Badge rekomendasi kerja & bukti kelulusan',
                    iconColor: AppColors.accentAmberGold,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.certificates),
                  ),
                  _buildMenuItem(
                    icon: Icons.folder_special_rounded,
                    title: 'Studi Kasus Proyek',
                    subtitle: 'Dokumentasi visual UI/UX & problem solving',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.caseStudy),
                  ),

                  // Section 4: Finansial & TimeCoin
                  _buildSectionHeader('FINANSIAL & TIMECOIN'),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Dompet TimeCoin',
                    subtitle: 'Saldo 240 TC · Escrow aman',
                    iconColor: AppColors.accentAmberGold,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
                  ),
                  _buildMenuItem(
                    icon: Icons.military_tech_rounded,
                    title: 'Reward Hub & Misi',
                    subtitle: 'Klaim bonus reputasi & achievement',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.rewardHub),
                  ),

                  // Section 5: Pengaturan & Bantuan
                  _buildSectionHeader('PENGATURAN & BANTUAN'),
                  _buildMenuItem(
                    icon: Icons.person_rounded,
                    title: 'Edit Profil Mahasiswa',
                    subtitle: 'Biodata, semester, & keahlian teknis',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_rounded,
                    title: 'Privasi & Keamanan',
                    subtitle: 'PIN dompet, kata sandi, & data pribadi',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.privacySecurity),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_rounded,
                    title: 'Pusat Bantuan & Resolusi',
                    subtitle: 'FAQ, panduan escrow, & layanan CS',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.helpSupport),
                  ),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Ganti Peran / Keluar Akun',
                    subtitle: 'Kembali ke layar pemilihan peran awal',
                    iconColor: const Color(0xFFEF4444),
                    titleColor: const Color(0xFFDC2626),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
