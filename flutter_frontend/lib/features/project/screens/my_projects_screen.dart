import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'In Progress',
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF388E3C) : const Color(0xFFF57C00),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                deadline,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
          const SizedBox(height: 4),
          Text('$client • $role', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          if (!isCompleted) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primaryTan, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.warmOffWhite,
                color: AppColors.primaryTan,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 20),
          ],
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.workspaceKanban);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryTan),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Open Workspace',
                  style: TextStyle(color: AppColors.primaryTan, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Projects',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.workspaceChat),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkBrown.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.darkBrown, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkBrown.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: AppColors.darkBrown, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.primaryTan,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'In Progress'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // In Progress View
                ListView(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                  children: [
                    _buildProjectCard(
                      title: 'Redesign E-commerce Landing Page',
                      client: 'Batik Nusantara',
                      role: 'UI/UX Design',
                      deadline: 'Due in 3 days',
                      progress: 0.4,
                      isCompleted: false,
                    ),
                    _buildProjectCard(
                      title: 'Build Mobile Menu App',
                      client: 'Cafe Rindu',
                      role: 'Flutter Dev',
                      deadline: 'Due in 1 week',
                      progress: 0.1,
                      isCompleted: false,
                    ),
                  ],
                ),
                // Completed View
                ListView(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                  children: [
                    _buildProjectCard(
                      title: 'Social Media Management',
                      client: 'Toko Sepatu Juara',
                      role: 'Content Creator',
                      deadline: 'Completed on Oct 10',
                      progress: 1.0,
                      isCompleted: true,
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
