import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';

class MsmeReviewSubmissionScreen extends StatefulWidget {
  const MsmeReviewSubmissionScreen({super.key});

  @override
  State<MsmeReviewSubmissionScreen> createState() =>
      _MsmeReviewSubmissionScreenState();
}

class _MsmeReviewSubmissionScreenState
    extends State<MsmeReviewSubmissionScreen> {
  bool _checkBrief = true;
  bool _checkQuality = true;
  bool _checkOnTime = false;

  double _slidePosition = 0.0;
  bool _isApproved = false;

  void _onSlideComplete() {
    setState(() {
      _isApproved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tahap 2 disetujui! 45 TC telah ditransfer ke Salsa Putri.',
        ),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.maybePop(context);
    });
  }

  void _onRequestRevision() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minta Revisi'),
        content: const Text(
          'Tuliskan catatan revisi yang perlu diperbaiki oleh Salsa Putri untuk tahap 2 ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permintaan revisi berhasil dikirim ke murid.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Kirim Revisi'),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const MsmeChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvasWhite,
    body: SafeArea(
      child: Stack(
        children: [
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
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Submission',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkSlate,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Desain Menu Board & Feed Instagram',
                            style: TextStyle(
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
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        tooltip: 'Chat',
                        padding: EdgeInsets.zero,
                        onPressed: _openChat,
                        icon: const Icon(
                          Icons.chat_bubble_rounded,
                          color: AppColors.darkSlate,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Student Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC2410C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'SP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              'Salsa Putri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkSlate,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Desain Komunikasi Visual · UNESA',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Tahap 2/3',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Step Tabs / Milestone Tracker
                Row(
                  children: [
                    _buildStepTab(
                      label: 'Riset & moodboard',
                      isDone: true,
                      isActive: false,
                    ),
                    const SizedBox(width: 8),
                    _buildStepTab(
                      label: 'Menu board final',
                      isDone: false,
                      isActive: true,
                    ),
                    const SizedBox(width: 8),
                    _buildStepTab(
                      label: 'Template feed Instagram',
                      isDone: false,
                      isActive: false,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Submission Card with Preview
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Escrow Lock
                            Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Menu board final',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkSlate,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Diajukan 3 jam lalu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondarySlate,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_rounded,
                                      color: Color(0xFFB45309),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '45 TC di escrow',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // File 1: PDF
                            _buildAttachmentTile(
                              icon: Icons.picture_as_pdf_rounded,
                              title: 'menu-board-final.pdf',
                              meta: '8,2 MB',
                            ),
                            const SizedBox(height: 10),

                            // File 2: ZIP
                            _buildAttachmentTile(
                              icon: Icons.folder_zip_rounded,
                              title: 'aset-menu-board.zip',
                              meta: 'AI, PNG, SVG · 24 MB',
                            ),
                            const SizedBox(height: 10),

                            // File 3: Figma Link
                            _buildAttachmentTile(
                              icon: Icons.link_rounded,
                              title: 'figma.com/file/menu-board-kopi',
                              meta: 'Tautan desain',
                            ),

                            const SizedBox(height: 16),

                            // Catatan Salsa Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Catatan Salsa: ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkSlate,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Menu board ukuran A1 dan versi digital 1080x1350 sudah siap. Warna mengikuti panduan brand dari tahap 1.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF475569),
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Checklist Persetujuan Card
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Checklist persetujuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Item 1
                      _buildChecklistTile(
                        label: 'Sesuai brief dan deliverable',
                        value: _checkBrief,
                        onChanged: (val) =>
                            setState(() => _checkBrief = val ?? false),
                      ),
                      const SizedBox(height: 10),

                      // Item 2
                      _buildChecklistTile(
                        label: 'Kualitas file siap dipakai',
                        value: _checkQuality,
                        onChanged: (val) =>
                            setState(() => _checkQuality = val ?? false),
                      ),
                      const SizedBox(height: 10),

                      // Item 3
                      _buildChecklistTile(
                        label: 'Dikirim tepat waktu',
                        value: _checkOnTime,
                        onChanged: (val) =>
                            setState(() => _checkOnTime = val ?? false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Button: Minta Revisi
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSlate),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onRequestRevision,
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.darkSlate,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Minta Revisi',
                              style: TextStyle(
                                color: AppColors.darkSlate,
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

          // Bottom Slide to Approve Button Bar
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
              child: _buildSwipeButton(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStepTab({
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    Color lineColor;
    if (isDone) {
      lineColor = const Color(0xFF10B981);
    } else if (isActive) {
      lineColor = AppColors.primaryNavy;
    } else {
      lineColor = const Color(0xFFE2E8F0);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.darkSlate : AppColors.secondarySlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile({
    required IconData icon,
    required String title,
    required String meta,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, color: AppColors.primaryNavy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                meta,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondarySlate,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.download_rounded,
          color: AppColors.secondarySlate,
          size: 20,
        ),
      ],
    ),
  );

  Widget _buildChecklistTile({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primaryNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlate,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSwipeButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSlide = constraints.maxWidth - 56;

        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryNavy.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center Label
              const Text(
                'Geser untuk Setujui & Bayar 45 TC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),

              // Draggable Slider Knob
              Positioned(
                left: _slidePosition.clamp(0.0, maxSlide),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isApproved) return;
                    setState(() {
                      _slidePosition = (_slidePosition + details.delta.dx)
                          .clamp(0.0, maxSlide);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isApproved) return;
                    if (_slidePosition >= maxSlide * 0.8) {
                      _onSlideComplete();
                    } else {
                      setState(() {
                        _slidePosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: AppColors.primaryNavy,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
