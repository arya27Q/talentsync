import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, this.workspaceApi});

  final WorkspaceApi? workspaceApi;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late final WorkspaceApi _api = widget.workspaceApi ?? WorkspaceApi.instance;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _threads = const [];

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
          _error = 'Gagal memuat kotak pesan.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      appBar: AppBar(
        backgroundColor: AppColors.canvasWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppColors.darkSlate,
            size: 28,
          ),
        ),
        title: const Text(
          'Kotak Pesan',
          style: TextStyle(
            color: AppColors.darkSlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSlate),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), _load);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari pesan atau nama mitra / mentor...',
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
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _load,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      )
                    : _threads.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada percakapan aktif dengan UMKM atau Mentor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.secondarySlate),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          itemCount: _threads.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _threads[index];
                            final type = item['thread_type'] as String?;
                            final refId =
                                (item['reference_id'] as num?)?.toInt();
                            final unread =
                                (item['unread_count'] as num?)?.toInt() ?? 0;

                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: refId == null
                                  ? null
                                  : () {
                                      if (type == 'mentor') {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.mentorChat,
                                          arguments: MentoringEnrollmentArgs(
                                            enrollmentId: refId,
                                          ),
                                        );
                                      } else {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.workspaceChat,
                                          arguments: ProjectRouteArgs(
                                            projectId: refId,
                                          ),
                                        );
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.borderSlate,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.lightBlueSurface,
                                      child: Icon(
                                        type == 'mentor'
                                            ? Icons.school_rounded
                                            : Icons.storefront_rounded,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (item['partner_name'] as String?) ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5,
                                              color: AppColors.darkSlate,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (item['subtitle'] as String?) ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.primaryNavy,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            (item['last_message'] as String?) ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.secondarySlate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (unread > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryNavy,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
