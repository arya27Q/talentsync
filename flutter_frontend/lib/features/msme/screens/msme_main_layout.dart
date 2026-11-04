import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/msme/screens/msme_create_task_wizard_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_dashboard_screen.dart';
import 'package:flutter_frontend/features/msme/screens/msme_postings_screen.dart';
import 'package:flutter_frontend/features/msme/widgets/msme_bottom_nav.dart';

class MsmeMainLayout extends StatefulWidget {
  const MsmeMainLayout({super.key});

  @override
  State<MsmeMainLayout> createState() => _MsmeMainLayoutState();
}

class _MsmeMainLayoutState extends State<MsmeMainLayout> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCreateTaskWizard() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MsmeCreateTaskWizardScreen(
          onCompleted: () {
            Navigator.pop(context);
            _selectTab(1); // Go to Postingan tab
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MsmeDashboardScreen(
        onCreateProject: _openCreateTaskWizard,
        onOpenPostings: () => _selectTab(1),
        onOpenBarter: () => _selectTab(2),
        onOpenProfile: () => _selectTab(3),
      ),
      MsmePostingsScreen(
        onCreatePosting: _openCreateTaskWizard,
      ),
      _buildBarterScreen(),
      _buildProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: MsmeBottomNav(
        selectedIndex: _currentIndex,
        onSelected: _selectTab,
      ),
    );
  }

  Widget _buildBarterScreen() => SafeArea(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barter Voucher',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Tukar produk usaha untuk menambah saldo TimeCoin',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primaryNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hemat Kas Usaha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Jadikan voucher menu kedaumu sebagai imbalan TimeCoin untuk mahasiswa.',
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

          const SizedBox(height: 20),

          // Voucher Card
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Setara 50 TC',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Voucher Minum Kopi Rp50.000',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dapat ditukarkan langsung di kedai Kopi Tepi Kali Surabaya.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.secondarySlate,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Sisa kuota: 8 / 10 voucher',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Kelola'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildProfileScreen() => SafeArea(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Usaha',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkSlate,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Informasi kedai dan kredensial kemitraan',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondarySlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Profile Header Card
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
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(18),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=150&q=80',
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
                          Row(
                            children: [
                              Text(
                                'Kopi Tepi Kali',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                color: AppColors.primaryNavy,
                                size: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Pemilik: Bu Rina · Kuliner',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderSlate),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.secondarySlate,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jl. Ketintang Baru No. 12, Surabaya',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu Options
          _buildMenuTile(
            icon: Icons.edit_note_rounded,
            title: 'Edit Profil Usaha',
            subtitle: 'Ubah logo, alamat, dan deskripsi toko',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.msmeRegister);
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.workspace_premium_rounded,
            title: 'Paket Langganan Mitra',
            subtitle: 'Verified Partner · Slot aktif 2/2',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan & Dukungan',
            subtitle: 'FAQ dan customer care TalentSync',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          // Logout Button
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.roleSelection,
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Keluar Akun Mitra',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
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

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderSlate),
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.lightBlueSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryNavy, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.darkSlate,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppColors.secondarySlate),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondarySlate,
      ),
      onTap: onTap,
    ),
  );
}

