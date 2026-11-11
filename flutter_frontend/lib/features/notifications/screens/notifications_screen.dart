import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants/app_colors.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/notifications/data/notification_api.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.notificationApi});

  final NotificationApi? notificationApi;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationApi _api =
      widget.notificationApi ?? NotificationApi.instance;

  bool _isLoading = true;
  String? _error;
  String _role = 'student';
  int _unreadCount = 0;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sessionUser = await ApiClient.instance.readSessionUser();
      _role = (sessionUser?['role'] as String?) ?? 'student';

      final res = await _api.list();
      final rows = (res['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      final meta = (res['meta'] as Map<String, dynamic>?) ?? const {};

      if (!mounted) return;
      setState(() {
        _items = rows;
        _unreadCount = (meta['unread_count'] as num?)?.toInt() ?? 0;
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
          _error = 'Gagal memuat daftar notifikasi.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllRead();
      if (!mounted) return;
      setState(() {
        _unreadCount = 0;
        for (final item in _items) {
          item['is_read'] = true;
        }
      });
    } catch (_) {}
  }

  Future<void> _handleTap(int index) async {
    final item = _items[index];
    final id = (item['id'] ?? '').toString();
    if (id.isNotEmpty && item['is_read'] != true) {
      setState(() {
        _items[index]['is_read'] = true;
        if (_unreadCount > 0) _unreadCount--;
      });
      try {
        await _api.markRead(id);
      } catch (_) {}
    }

    if (!mounted) return;
    final route = _resolveRoute(item['target_route'] as String?);
    if (route != null) {
      Navigator.pushNamed(context, route);
    }
  }

  String? _resolveRoute(String? targetRoute) {
    if (targetRoute == null || targetRoute.isEmpty) return null;
    if (_role == 'mentor') {
      if (targetRoute.contains('wallet')) return AppRoutes.mentorCashOut;
      return null;
    }
    if (targetRoute.contains('wallet')) return AppRoutes.wallet;
    if (targetRoute.contains('certificates')) return AppRoutes.certificates;
    if (targetRoute.contains('portfolio')) return AppRoutes.portfolio;
    if (targetRoute.contains('help-support')) return AppRoutes.helpSupport;
    if (targetRoute.contains('projects')) return AppRoutes.myProjects;
    if (targetRoute.contains('mentoring')) return AppRoutes.myMentors;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : _items.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primaryNavy,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, idx) => _buildNotificationCard(idx),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  _role == 'mentor'
                      ? AppRoutes.mentorDashboard
                      : AppRoutes.studentDashboard,
                );
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSlate),
              ),
              child: const Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppColors.darkSlate,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlate,
                  ),
                ),
                Text(
                  '$_unreadCount belum dibaca',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Tandai dibaca',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(int idx) {
    final item = _items[idx];
    final unread = item['is_read'] != true;
    final type = (item['type'] as String?) ?? '';
    final icon = type.contains('wallet') || type.contains('tc')
        ? Icons.toll_rounded
        : type.contains('mentor') || type.contains('endorse')
        ? Icons.verified_rounded
        : Icons.notifications_active_rounded;

    return InkWell(
      onTap: () => _handleTap(idx),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppColors.lightBlueSurface : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unread
                ? AppColors.primaryNavy.withValues(alpha: 0.25)
                : AppColors.borderSlate,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: unread ? Colors.white : AppColors.canvasWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryNavy, size: 20),
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
                          (item['title'] as String?) ?? 'Notifikasi',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNavy,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (item['body'] as String?) ?? '',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.secondarySlate,
                      height: 1.4,
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

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 46,
              color: AppColors.secondarySlate,
            ),
            SizedBox(height: 10),
            Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Pembaruan proyek, mentoring, dan transaksi TimeCoin akan tampil di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondarySlate),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                ),
                onPressed: _load,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
