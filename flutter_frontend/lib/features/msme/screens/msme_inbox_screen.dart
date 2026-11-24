import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/auth/widgets/user_avatar_modal.dart';
import 'package:flutter_frontend/features/msme/screens/msme_chat_screen.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';

class MsmeInboxScreen extends StatefulWidget {
  const MsmeInboxScreen({super.key, this.workspaceApi});

  final WorkspaceApi? workspaceApi;

  @override
  State<MsmeInboxScreen> createState() => _MsmeInboxScreenState();
}

class _MsmeInboxScreenState extends State<MsmeInboxScreen> {
  late final WorkspaceApi _api = widget.workspaceApi ?? WorkspaceApi.instance;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = true;
  String? _error;
  int _selectedFilter = 0; // 0: Semua, 1: Belum Dibaca, 2: Pelamar, 3: Diterima, 4: Arsip
  List<Map<String, dynamic>> _threads = const [];

  final List<String> _filters = const [
    'Semua',
    'Belum Dibaca',
    'Pelamar',
    'Diterima',
    'Ditolak (Arsip)',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rows = await _api.inbox(query: _searchController.text);
      if (!mounted) return;
      setState(() {
        _threads = rows;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat kotak pesan mitra.';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredThreads {
    return switch (_selectedFilter) {
      1 => _threads
          .where((t) => ((t['unread_count'] as num?)?.toInt() ?? 0) > 0)
          .toList(),
      2 => _threads
          .where((t) => (t['application_status'] as String?) == 'pending')
          .toList(),
      3 => _threads
          .where((t) => (t['application_status'] as String?) == 'accepted')
          .toList(),
      4 => _threads
          .where((t) => (t['application_status'] as String?) == 'rejected')
          .toList(),
      _ => _threads,
    };
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }

  (Color bg, Color fg) _badgeColors(String label) {
    return switch (label) {
      'Diterima' => (const Color(0xFFECFDF5), const Color(0xFF047857)),
      'Pelamar' => (const Color(0xFFFFFBEB), const Color(0xFFB45309)),
      'Ditolak (Arsip)' || 'Ditolak' => (
        const Color(0xFFFEF2F2),
        const Color(0xFFB91C1C),
      ),
      _ => (const Color(0xFFEFF6FF), AppColors.primaryNavy),
    };
  }

  Future<void> _openThread(Map<String, dynamic> item) async {
    final projectId =
        (item['project_id'] as num?)?.toInt() ??
        (item['reference_id'] as num?)?.toInt();
    final studentId = (item['student_id'] as num?)?.toInt();
    final studentName = (item['partner_name'] as String?) ?? 'Mahasiswa';
    if (projectId == null) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => MsmeChatScreen(
          projectId: projectId,
          studentId: studentId,
          studentName: studentName,
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleThreads = _filteredThreads;

    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSlate),
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
                          'Kotak Pesan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkSlate,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Obrolan dengan mahasiswa & pelamar proyek',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondarySlate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSlate),
                    ),
                    child: IconButton(
                      tooltip: 'Muat ulang pesan',
                      padding: EdgeInsets.zero,
                      onPressed: _load,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primaryNavy,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), _load);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari nama mahasiswa atau proyek...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.secondarySlate,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),

            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = index),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryNavy
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryNavy
                                : AppColors.borderSlate,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkSlate,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Conversation List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.secondarySlate,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryNavy,
                              ),
                              onPressed: _load,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : visibleThreads.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 64,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: AppColors.secondarySlate,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum Ada Pesan Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkSlate,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Obrolan akan otomatis muncul di sini saat ada mahasiswa yang melamar tugas atau proyek milik tokomu.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.secondarySlate,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: visibleThreads.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _buildThreadTile(visibleThreads[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadTile(Map<String, dynamic> item) {
    final partnerName = (item['partner_name'] as String?) ?? 'Mahasiswa';
    final subtitle = (item['subtitle'] as String?) ?? 'Proyek UMKM';
    final badgeLabel = (item['badge_label'] as String?) ?? 'Tanya Proyek';
    final lastMessage =
        (item['last_message'] as String?) ?? 'Mulai obrolan dengan mahasiswa';
    final lastTime = _formatTime(item['last_message_at'] as String?);
    final unread = (item['unread_count'] as num?)?.toInt() ?? 0;
    final avatarUrl = item['avatar_url'] as String?;
    final (badgeBg, badgeFg) = _badgeColors(badgeLabel);

    final parts = partnerName.trim().split(RegExp(r'\s+'));
    final initials = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'M');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openThread(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unread > 0
                ? AppColors.primaryNavy.withValues(alpha: 0.35)
                : AppColors.borderSlate,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatarHelper.buildAvatarWidget(
              avatarUrl: avatarUrl,
              initial: initials,
              size: 46,
              borderRadius: 14,
              fallbackBgColor: AppColors.lightBlueSurface,
              fallbackTextColor: AppColors.primaryNavy,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partnerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lastTime,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              unread > 0 ? FontWeight.bold : FontWeight.w500,
                          color: unread > 0
                              ? AppColors.primaryNavy
                              : AppColors.secondarySlate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: badgeFg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                unread > 0 ? FontWeight.w600 : FontWeight.normal,
                            color: unread > 0
                                ? AppColors.darkSlate
                                : AppColors.secondarySlate,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
