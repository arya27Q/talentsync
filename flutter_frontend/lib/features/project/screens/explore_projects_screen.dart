import 'package:flutter/material.dart';
import 'package:skillswap_frontend/core/constants/app_colors.dart';
import 'package:skillswap_frontend/core/routes/app_routes.dart';

class ExploreProjectsScreen extends StatefulWidget {
  const ExploreProjectsScreen({super.key});

  @override
  State<ExploreProjectsScreen> createState() => _ExploreProjectsScreenState();
}

class _ExploreProjectsScreenState extends State<ExploreProjectsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'TimeCoin',
    'Cash Task',
    'Barter',
    'Web Dev',
    'Design',
    'Marketing',
    'Writing'
  ];

  Widget _buildFilterPill(String text) {
    final isActive = _selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryTan : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!isActive)
              BoxShadow(
                color: AppColors.darkBrown.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            if (isActive)
              BoxShadow(
                color: AppColors.primaryTan.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListTaskCard({
    required IconData icon,
    required String category,
    required String reward,
    required String title,
    required String client,
    required String due,
    required Color iconBgColor,
    required Color iconColor,
    required bool isPremium,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.projectDetail),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPremium ? const Color(0xFFB88656) : AppColors.warmOffWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reward,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.white : AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkBrown)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(due, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryTan.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Apply', style: TextStyle(color: AppColors.primaryTan, fontWeight: FontWeight.bold, fontSize: 13)),
              )
            ],
          ),
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.warmOffWhite,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Project',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Find your next project',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.darkBrown),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
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
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for projects, skills...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryTan),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: _filters.map((filter) => _buildFilterPill(filter)).toList(),
              ),
            ),
            const SizedBox(height: 20),
            
            // List Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                child: Column(
                  children: [
                    _buildListTaskCard(
                      icon: Icons.code_rounded,
                      category: 'Web Dev',
                      reward: '15 TC',
                      title: 'Build Landing Page for Cafe',
                      client: 'Kopitiam Sari',
                      due: 'Due in 3 days',
                      iconBgColor: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1976D2),
                      isPremium: true,
                    ),
                    _buildListTaskCard(
                      icon: Icons.brush_rounded,
                      category: 'Design',
                      reward: 'Barter',
                      title: 'Logo Redesign & Branding',
                      client: 'Batik Nusantara',
                      due: 'Due in 5 days',
                      iconBgColor: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF7B1FA2),
                      isPremium: false,
                    ),
                    _buildListTaskCard(
                      icon: Icons.storefront_rounded,
                      category: 'Marketing',
                      reward: '50 TC',
                      title: 'Social Media Strategy & Content',
                      client: 'Warung Bu Ani',
                      due: 'Due in 1 week',
                      iconBgColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF388E3C),
                      isPremium: true,
                    ),
                    _buildListTaskCard(
                      icon: Icons.edit_document,
                      category: 'Writing',
                      reward: '5 TC',
                      title: 'Copywriting for Catalog',
                      client: 'Toko Sepatu Juara',
                      due: 'Due in 2 days',
                      iconBgColor: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFF57C00),
                      isPremium: true,
                    ),
                    _buildListTaskCard(
                      icon: Icons.data_usage_rounded,
                      category: 'Data Entry',
                      reward: '30 TC',
                      title: 'Input Data Inventory',
                      client: 'Toko Makmur',
                      due: 'Due tomorrow',
                      iconBgColor: const Color(0xFFE0F7FA),
                      iconColor: const Color(0xFF0097A7),
                      isPremium: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
