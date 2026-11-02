import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildProjectCard({
    required String title,
    required String client,
    required String role,
    required String deadline,
    required double progress,
    required bool isCompleted,
    required VoidCallback onWorkspace,
    required VoidCallback onMilestones,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.lightGreenSurface : AppColors.lightBlueSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isCompleted ? 'Selesai & Terverifikasi' : 'Sedang Berjalan',
                  style: TextStyle(
                    color: isCompleted ? AppColors.successGreen : AppColors.primaryNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: AppColors.secondarySlate,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deadline,
                    style: const TextStyle(
                      color: AppColors.secondarySlate,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$client · $role',
            style: const TextStyle(
              color: AppColors.secondarySlate,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          if (!isCompleted) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progres Pengerjaan',
                  style: TextStyle(
                    color: AppColors.secondarySlate,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.borderSlate,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkSlate,
                      side: const BorderSide(color: AppColors.borderSlate),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onMilestones,
                    child: const Text(
                      'Milestones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onWorkspace,
                    child: const Text(
                      'Workspace',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: onMilestones,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Lihat Hasil & Testimoni',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.workspaceChat),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppColors.darkSlate,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSlate),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.darkSlate,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.secondarySlate,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sedang Aktif (1)'),
                  Tab(text: 'Selesai (3)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Projects
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: [
                    _buildProjectCard(
                      title: 'Aplikasi Kasir Sederhana Toko Kelontong',
                      client: 'Toko Bu Sri',
                      role: 'Mobile Specialist',
                      deadline: '12 Jul 2026',
                      progress: 0.57,
                      isCompleted: false,
                      onWorkspace: () => Navigator.pushNamed(context, AppRoutes.workspaceKanban),
                      onMilestones: () => Navigator.pushNamed(context, AppRoutes.submission),
                    ),
                  ],
                ),

                // Completed Projects
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: [
                    _buildProjectCard(
                      title: 'Aplikasi Kasir Sederhana Toko Kelontong',
                      client: 'Toko Bu Sri',
                      role: 'Mobile Specialist',
                      deadline: '28 Jun 2026',
                      progress: 1.0,
                      isCompleted: true,
                      onWorkspace: () {},
                      onMilestones: () => Navigator.pushNamed(context, AppRoutes.projectCompleted),
                    ),
                    _buildProjectCard(
                      title: 'Katalog Produk Digital Keripik Tempe',
                      client: 'UMKM Berkah Jaya',
                      role: 'Flutter Developer',
                      deadline: '14 Mei 2026',
                      progress: 1.0,
                      isCompleted: true,
                      onWorkspace: () {},
                      onMilestones: () => Navigator.pushNamed(context, AppRoutes.projectCompleted),
                    ),
                    _buildProjectCard(
                      title: 'Sistem Pembukuan Kas Sederhana',
                      client: 'Warung Madura Barokah',
                      role: 'Mobile Developer',
                      deadline: '20 Apr 2026',
                      progress: 1.0,
                      isCompleted: true,
                      onWorkspace: () {},
                      onMilestones: () => Navigator.pushNamed(context, AppRoutes.projectCompleted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
