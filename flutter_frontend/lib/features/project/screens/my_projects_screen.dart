import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class MyProjectsScreen extends StatefulWidget {
  final bool showBottomNav;
  const MyProjectsScreen({super.key, this.showBottomNav = false});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  int _selectedTabIndex = 0; // 0: Aktif (2), 1: Menunggu (1), 2: Selesai (3)

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondarySlate,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.secondarySlate,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveProjectCard({
    required String imageAsset,
    required String imageUrl,
    required String businessName,
    required String locationMode,
    required String title,
    required int totalTc,
    required int currentStage,
    required int totalStages,
    required int progressPercent,
    required String nextStageTitle,
    required int nextStageTc,
    required String daysLeft,
    required bool isUrgentDays,
    required int cairTc,
    required int escrowTc,
    required VoidCallback onChat,
    required VoidCallback onKanban,
    required VoidCallback onMilestone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Image, Status & UMKM, TC Reward
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFF1F5F9),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(
                        Icons.store_rounded,
                        color: AppColors.primaryNavy,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 12,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Aktif',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '· $businessName · $locationMode',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // TC Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.toll_rounded,
                    color: AppColors.accentAmberGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalTc TC',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tahap $currentStage/$totalStages · $progressPercent%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Next Stage Box (Tahap Berikutnya)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNavy,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${currentStage + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TAHAP BERIKUTNYA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextStageTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$nextStageTc TC',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 4. 3 Metric Boxes: Sisa Waktu, Sudah Cair, Di Escrow
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        daysLeft,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isUrgentDays ? const Color(0xFFDC2626) : AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sisa waktu',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$cairTc TC',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sudah cair',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$escrowTc TC',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Di escrow',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 5. Action Buttons: Chat, Kanban, Status & Milestone
          Row(
            children: [
              GestureDetector(
                onTap: onChat,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.darkSlate,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onKanban,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.view_kanban_outlined,
                      color: AppColors.darkSlate,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onMilestone,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Status & Milestone',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 6),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenungguCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 14,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_empty_rounded, size: 12, color: Color(0xFFD97706)),
                    SizedBox(width: 4),
                    Text(
                      'Menunggu Seleksi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Row(
                children: [
                  Icon(Icons.toll_rounded, color: AppColors.accentAmberGold, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '300 TC',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkSlate),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Redesain Kemasan & Katalog Online',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sambal Bu Rudi · Lamaran dikirim kemarin',
            style: TextStyle(fontSize: 12, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondarySlate),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'UMKM sedang meninjau portofolio dan pesan lamaranmu. Hasil seleksi diberitahukan paling lambat 2 hari.',
                    style: TextStyle(fontSize: 11, color: AppColors.secondarySlate, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.projectDetail);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Text(
                  'Lihat Detail Proyek',
                  style: TextStyle(
                    color: AppColors.darkSlate,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelesaiCard({
    required String title,
    required String client,
    required int earnedTc,
    required String rating,
    required String feedback,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.04),
            blurRadius: 14,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text(
                      'Selesai & Valid',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.toll_rounded, color: AppColors.accentAmberGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+$earnedTc TC',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$client · Diselesaikan $date',
            style: const TextStyle(fontSize: 12, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accentAmberGold, size: 18),
                const SizedBox(width: 6),
                Text(
                  rating,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSlate),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.secondarySlate),
                  ),
                ),
              ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top App Bar: Title & Notification Bell
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkSlate.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.darkSlate,
                              size: 22,
                            ),
                            Positioned(
                              top: 10,
                              right: 11,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentAmberGold,
                                  shape: BoxShape.circle,
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

              // 2. 3 Metric Summary Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    _buildMetricCard(
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.primaryNavy,
                      value: '2',
                      label: 'Proyek aktif',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricCard(
                      icon: Icons.lock_outline_rounded,
                      iconColor: AppColors.accentAmberGold,
                      value: '115 TC',
                      label: 'Di escrow',
                    ),
                    const SizedBox(width: 10),
                    _buildMetricCard(
                      icon: Icons.school_outlined,
                      iconColor: const Color(0xFF10B981),
                      value: '6 SKS',
                      label: 'Terkumpul',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Segmented Filter Tabs (Aktif, Menunggu, Selesai)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildFilterTab(0, 'Aktif (2)'),
                      _buildFilterTab(1, 'Menunggu (1)'),
                      _buildFilterTab(2, 'Selesai (3)'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Content List based on selected tab
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    if (_selectedTabIndex == 0) ...[
                      // Card 1: Toko Bu Sri
                      _buildActiveProjectCard(
                        imageAsset: 'assets/images/grocery.png',
                        imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=200',
                        businessName: 'Toko Bu Sri',
                        locationMode: 'Hybrid',
                        title: 'Aplikasi Kasir Sederhana Toko Kelontong',
                        totalTc: 120,
                        currentStage: 1,
                        totalStages: 3,
                        progressPercent: 33,
                        nextStageTitle: 'Fitur stok & transaksi',
                        nextStageTc: 50,
                        daysLeft: '11 hari',
                        isUrgentDays: false,
                        cairTc: 30,
                        escrowTc: 90,
                        onChat: () {
                          Navigator.pushNamed(context, AppRoutes.workspaceChat);
                        },
                        onKanban: () {
                          Navigator.pushNamed(context, AppRoutes.workspaceKanban);
                        },
                        onMilestone: () {
                          Navigator.pushNamed(context, AppRoutes.submission);
                        },
                      ),

                      // Card 2: Keripik Tempe Mak Nah
                      _buildActiveProjectCard(
                        imageAsset: 'assets/images/chips.png',
                        imageUrl: 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=200',
                        businessName: 'Keripik Tempe Mak Nah',
                        locationMode: 'Remote',
                        title: 'Logo dan Kemasan Baru Keripik Tempe',
                        totalTc: 35,
                        currentStage: 1,
                        totalStages: 3,
                        progressPercent: 33,
                        nextStageTitle: 'Panduan brand & aset grafis',
                        nextStageTc: 15,
                        daysLeft: '4 hari',
                        isUrgentDays: true,
                        cairTc: 0,
                        escrowTc: 35,
                        onChat: () {
                          Navigator.pushNamed(context, AppRoutes.workspaceChat);
                        },
                        onKanban: () {
                          Navigator.pushNamed(context, AppRoutes.workspaceKanban);
                        },
                        onMilestone: () {
                          Navigator.pushNamed(context, AppRoutes.submission);
                        },
                      ),
                    ] else if (_selectedTabIndex == 1) ...[
                      _buildMenungguCard(),
                    ] else ...[
                      _buildSelesaiCard(
                        title: 'Redesain Logo & Kemasan Kopi',
                        client: 'Warung Pak Gito',
                        earnedTc: 80,
                        rating: '5.0',
                        feedback: 'Rapi dan komunikatif, hasilnya langsung dipakai.',
                        date: '2 hari lalu',
                      ),
                      _buildSelesaiCard(
                        title: 'Katalog Menu Digital Interaktif',
                        client: 'Depot Makan Barokah',
                        earnedTc: 150,
                        rating: '5.0',
                        feedback: 'Sangat puas, konversi SKS disetujui kampus.',
                        date: '1 minggu lalu',
                      ),
                      _buildSelesaiCard(
                        title: 'Setup Google My Business & SEO Lokal',
                        client: 'Laundry Bersih Jaya',
                        earnedTc: 45,
                        rating: '4.9',
                        feedback: 'Pesanan meningkat setelah optimasi maps.',
                        date: '2 minggu lalu',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
