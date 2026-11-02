import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  final TextEditingController _deliverableNotesController = TextEditingController(
    text: 'Implementasi fitur stok barang dan integrasi pencatatan harga modal serta transaksi kasir offline selesai.',
  );
  final TextEditingController _repoLinkController = TextEditingController(
    text: 'https://github.com/aryapratama/kasir-toko-busri',
  );

  bool _isSubmitted = false;

  @override
  void dispose() {
    _deliverableNotesController.dispose();
    _repoLinkController.dispose();
    super.dispose();
  }

  void _showSubmissionSuccessModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightGreenSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successGreen,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hasil Pengerjaan Berhasil Diajukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mitra Toko Bu Sri akan memeriksa deliverable Tahap 2 dalam 1x24 jam. Escrow senilai 50 TC akan otomatis cair setelah disetujui.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondarySlate,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkSlate,
                        side: const BorderSide(color: AppColors.borderSlate),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, AppRoutes.workspaceKanban);
                      },
                      child: const Text(
                        'Ke Workspace',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, AppRoutes.projectCompleted);
                      },
                      child: const Text(
                        'Lihat Status Akhir',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required Widget iconWidget,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondarySlate,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
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
    );
  }

  Widget _buildMilestoneStepCard({
    required int stepNumber,
    required String title,
    required String reward,
    required String statusText,
    required Color statusBg,
    required Color statusTextCol,
    required bool isCompleted,
    required bool isActive,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryNavy : AppColors.borderSlate,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSlate.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.lightGreenSurface
                      : isActive
                          ? AppColors.lightBlueSurface
                          : AppColors.canvasWhite,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.successGreen,
                        )
                      : Text(
                          '$stepNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? AppColors.primaryNavy
                                : AppColors.secondarySlate,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSlate,
                      ),
                    ),
                    Text(
                      'Imbalan: $reward',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextCol,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderSlate, height: 1),
          const SizedBox(height: 12),
          content,
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
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header
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
                      const Text(
                        'Status Proyek & Milestones',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.workspaceKanban),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Icon(
                            Icons.view_kanban_outlined,
                            color: AppColors.darkSlate,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTopBadge(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Lamaran diterima & kontrak aktif',
                        bgColor: const Color(0xFFDCFCE7),
                        textColor: const Color(0xFF15803D),
                        iconColor: const Color(0xFF15803D),
                      ),
                      _buildTopBadge(
                        icon: Icons.lock_outline_rounded,
                        label: 'Smart Escrow aktif',
                        bgColor: const Color(0xFFEEF2FF),
                        textColor: const Color(0xFF3730A3),
                        iconColor: const Color(0xFF3730A3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Project Title Block
                  const Text(
                    'Toko Bu Sri · Klaster Ritel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Aplikasi Kasir Sederhana Toko Kelontong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlate,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metrics Row (Nilai Kontrak & Sisa Waktu)
                  Row(
                    children: [
                      _buildMetricCard(
                        iconWidget: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.toll_rounded,
                            color: AppColors.accentAmberGold,
                            size: 20,
                          ),
                        ),
                        label: 'Nilai kontrak',
                        value: '120 TC',
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        iconWidget: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlueSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.primaryNavy,
                            size: 20,
                          ),
                        ),
                        label: 'Sisa waktu',
                        value: '11 hari',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kemajuan Pengerjaan Card
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KEMAJUAN PENGERJAAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Tahap 1 dari 3 selesai',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            Text(
                              _isSubmitted ? '66%' : '33%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _isSubmitted ? 0.66 : 0.33,
                            backgroundColor: AppColors.borderSlate,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreenSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFDCFCE7)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 14,
                                          color: AppColors.successGreen,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Dicairkan',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.successGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isSubmitted ? '80 TC' : '30 TC',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    const Text(
                                      'Langsung ke dompet',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderSlate),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: 14,
                                          color: AppColors.secondarySlate,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Terkunci di escrow',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.secondarySlate,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isSubmitted ? '40 TC' : '90 TC',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    const Text(
                                      'Aman di sistem',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Title: Tahapan & Deliverable
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Tahapan & deliverable',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'POV Mahasiswa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Atur pembagian kerja mandiri atau gunakan template UMKM',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Milestone 1 (Selesai)
                  _buildMilestoneStepCard(
                    stepNumber: 1,
                    title: 'Desain alur kasir & prototipe',
                    reward: '30 TC',
                    statusText: 'Selesai',
                    statusBg: AppColors.lightGreenSurface,
                    statusTextCol: AppColors.successGreen,
                    isCompleted: true,
                    isActive: false,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.canvasWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.link_rounded, size: 18, color: AppColors.primaryNavy),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'figma.com/design/kasir-tokobusri-v1',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.check_circle_rounded, size: 16, color: AppColors.successGreen),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Disetujui Bu Sri pada 28 Jun · 30 TC telah masuk ke saldo dompet.',
                          style: TextStyle(fontSize: 11, color: AppColors.secondarySlate),
                        ),
                      ],
                    ),
                  ),

                  // Milestone 2 (Sedang Berjalan / Diajukan)
                  _buildMilestoneStepCard(
                    stepNumber: 2,
                    title: 'Fitur stok & transaksi',
                    reward: '50 TC',
                    statusText: _isSubmitted ? 'Menunggu Validasi' : 'Sedang Berjalan',
                    statusBg: _isSubmitted ? const Color(0xFFFEF3C7) : AppColors.lightBlueSurface,
                    statusTextCol: _isSubmitted ? const Color(0xFFB45309) : AppColors.primaryNavy,
                    isCompleted: _isSubmitted,
                    isActive: !_isSubmitted,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tautan Repository / Berkas Master:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.canvasWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: TextField(
                            controller: _repoLinkController,
                            style: const TextStyle(fontSize: 12, color: AppColors.darkSlate),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(Icons.code_rounded, size: 18, color: AppColors.secondarySlate),
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Catatan Pengajuan:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.canvasWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSlate),
                          ),
                          child: TextField(
                            controller: _deliverableNotesController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12, color: AppColors.darkSlate),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Milestone 3 (Menunggu)
                  _buildMilestoneStepCard(
                    stepNumber: 3,
                    title: 'Uji coba & serah terima',
                    reward: '40 TC',
                    statusText: 'Terkunci',
                    statusBg: AppColors.canvasWhite,
                    statusTextCol: AppColors.secondarySlate,
                    isCompleted: false,
                    isActive: false,
                    content: const Text(
                      'Tahap final pengujian menyeluruh di perangkat fisik toko kelontong Bu Sri dan serah terima buku panduan manual kasir.',
                      style: TextStyle(fontSize: 11, color: AppColors.secondarySlate, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 84,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSubmitted = true;
                });
                _showSubmissionSuccessModal();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Simpan & Ajukan Hasil Pengerjaan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Floating Bar
          _buildBottomNavFloating(context),
        ],
      ),
    );
  }
}
