import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class KanbanTask {
  final String id;
  final String title;
  final String tag;
  final String deadline;
  final Color tagColor;
  final Color tagBgColor;
  String status; // 'todo', 'in_progress', 'done'

  KanbanTask({
    required this.id,
    required this.title,
    required this.tag,
    required this.deadline,
    required this.tagColor,
    required this.tagBgColor,
    required this.status,
  });
}

class WorkspaceKanbanScreen extends StatefulWidget {
  const WorkspaceKanbanScreen({super.key});

  @override
  State<WorkspaceKanbanScreen> createState() => _WorkspaceKanbanScreenState();
}

class _WorkspaceKanbanScreenState extends State<WorkspaceKanbanScreen> {
  final List<KanbanTask> _tasks = [
    KanbanTask(
      id: '1',
      title: 'Halaman rekap laba mingguan',
      tag: 'UI',
      deadline: '8 Jul',
      tagColor: const Color(0xFF2563EB),
      tagBgColor: const Color(0xFFEFF6FF),
      status: 'todo',
    ),
    KanbanTask(
      id: '2',
      title: 'Ekspor laporan ke PDF',
      tag: 'Fitur',
      deadline: '10 Jul',
      tagColor: const Color(0xFF4F46E5),
      tagBgColor: const Color(0xFFEEF2FF),
      status: 'todo',
    ),
    KanbanTask(
      id: '3',
      title: 'Uji coba di HP pemilik toko',
      tag: 'QA',
      deadline: '11 Jul',
      tagColor: const Color(0xFFD97706),
      tagBgColor: const Color(0xFFFEF3C7),
      status: 'todo',
    ),
    KanbanTask(
      id: '4',
      title: 'Form input stok & harga modal',
      tag: 'Fitur',
      deadline: '5 Jul',
      tagColor: const Color(0xFF4F46E5),
      tagBgColor: const Color(0xFFEEF2FF),
      status: 'in_progress',
    ),
    KanbanTask(
      id: '5',
      title: 'Skema database offline SQLite',
      tag: 'Backend',
      deadline: '4 Jul',
      tagColor: const Color(0xFF7C3AED),
      tagBgColor: const Color(0xFFF5F3FF),
      status: 'in_progress',
    ),
    KanbanTask(
      id: '6',
      title: 'Wireframe alur kasir & checkout',
      tag: 'Desain',
      deadline: '28 Jun',
      tagColor: AppColors.successGreen,
      tagBgColor: AppColors.lightGreenSurface,
      status: 'done',
    ),
    KanbanTask(
      id: '7',
      title: 'Inisialisasi repo Flutter & State Management',
      tag: 'Setup',
      deadline: '25 Jun',
      tagColor: AppColors.successGreen,
      tagBgColor: AppColors.lightGreenSurface,
      status: 'done',
    ),
  ];

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    String selectedTag = 'UI';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Tambah Tugas Baru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Judul Tugas',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondarySlate),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Misal: Optimasi cetak nota struk',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondarySlate),
                      filled: true,
                      fillColor: AppColors.canvasWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSlate),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSlate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kategori Label',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondarySlate),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['UI', 'Fitur', 'QA', 'Backend'].map((tag) {
                      final bool isSelected = selectedTag == tag;
                      return ChoiceChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: AppColors.primaryNavy,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.darkSlate,
                        ),
                        onSelected: (val) {
                          setDialogState(() {
                            selectedTag = tag;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: AppColors.secondarySlate)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      setState(() {
                        _tasks.add(
                          KanbanTask(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            tag: selectedTag,
                            deadline: '12 Jul',
                            tagColor: const Color(0xFF2563EB),
                            tagBgColor: const Color(0xFFEFF6FF),
                            status: 'todo',
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTaskItem(KanbanTask task) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: task.tagBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.tag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: task.tagColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                task.status == 'done' ? Icons.check_circle_rounded : Icons.access_time_rounded,
                size: 13,
                color: task.status == 'done' ? AppColors.successGreen : AppColors.secondarySlate,
              ),
              const SizedBox(width: 4),
              Text(
                task.deadline,
                style: TextStyle(
                  fontSize: 11,
                  color: task.status == 'done' ? AppColors.successGreen : AppColors.secondarySlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required Color indicatorColor,
    required int count,
    required List<KanbanTask> columnTasks,
    bool showAddButton = false,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.canvasWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Column Task Cards
          ...columnTasks.map((t) => _buildTaskItem(t)),

          // Add Task Button in To Do column
          if (showAddButton)
            GestureDetector(
              onTap: _showAddTaskDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderSlate,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.secondarySlate,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tambah tugas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavFloating(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkSlate.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.explore_outlined, color: AppColors.secondarySlate, size: 24),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.assignment_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'My Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.wallet),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.secondarySlate, size: 24),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.portfolio),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.person_outline_rounded, color: AppColors.secondarySlate, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoTasks = _tasks.where((t) => t.status == 'todo').toList();
    final inProgressTasks = _tasks.where((t) => t.status == 'in_progress').toList();
    final doneTasks = _tasks.where((t) => t.status == 'done').toList();

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Column(
                        children: const [
                          Text(
                            'Project Workspace',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkSlate,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Aplikasi kasir · Toko Bu Sri',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Overview Progress Card
                  Container(
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
                    child: Row(
                      children: [
                        // Circular Progress Indicator
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Stack(
                            alignment: Alignment.center,
                            children: const [
                              CircularProgressIndicator(
                                value: 0.57,
                                strokeWidth: 5,
                                backgroundColor: AppColors.borderSlate,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
                              ),
                              Text(
                                '57%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Middle Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '4 dari 7 tugas selesai',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: AppColors.secondarySlate,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tenggat 12 Jul · sisa 9 hari',
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
                        // Right TimeCoin Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.toll_rounded,
                                color: AppColors.accentAmberGold,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '120 TC',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Horizontal Kanban Columns
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKanbanColumn(
                          title: 'To Do',
                          indicatorColor: const Color(0xFF64748B),
                          count: todoTasks.length,
                          columnTasks: todoTasks,
                          showAddButton: true,
                        ),
                        _buildKanbanColumn(
                          title: 'In Progress',
                          indicatorColor: AppColors.primaryNavy,
                          count: inProgressTasks.length,
                          columnTasks: inProgressTasks,
                        ),
                        _buildKanbanColumn(
                          title: 'Done',
                          indicatorColor: AppColors.successGreen,
                          count: doneTasks.length,
                          columnTasks: doneTasks,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Bottom Navigation
          _buildBottomNavFloating(context),
        ],
      ),
    );
  }
}
