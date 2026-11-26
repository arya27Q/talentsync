import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/core/network/api_exception.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';

class AdminPageResult {
  const AdminPageResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int lastPage;
  final int total;
}

class AdminApi {
  AdminApi({ApiClient? client, AuthApi? authApi})
    : _client = client ?? ApiClient.instance,
      _authApi = authApi ?? AuthApi(client: client ?? ApiClient.instance);

  static final AdminApi instance = AdminApi();

  final ApiClient _client;
  final AuthApi _authApi;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final user = await _authApi.login(email: email.trim(), password: password);
    final role = (user['role'] as String?)?.toLowerCase();
    final roles = ((user['roles'] as List?) ?? const [])
        .map((e) => '$e'.toLowerCase())
        .toSet();
    if (role != 'admin' && !roles.contains('admin')) {
      await _authApi.logout();
      throw const ApiException(
        'Akun ini tidak memiliki hak akses Administrator TalentSync.',
      );
    }
    return user;
  }

  Future<void> logout() => _authApi.logout();

  Future<Map<String, dynamic>?> currentAdminSession() async {
    final user = await _client.readSessionUser();
    if (user == null) return null;
    final role = (user['role'] as String?)?.toLowerCase();
    if (role != 'admin') return null;
    return user;
  }

  Future<Map<String, dynamic>> dashboard() async {
    final res = await _client.get('/admin/dashboard');
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<List<Map<String, dynamic>>> users({
    String role = 'all',
    String search = '',
  }) async {
    final res = await _client.get(
      '/admin/users',
      query: {
        if (role != 'all') 'role': role,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _asMapList(res['data']);
  }

  Future<Map<String, dynamic>> updateUserVerification(
    int userId, {
    required String status,
    required String targetRole,
  }) async {
    final res = await _client.patch(
      '/admin/users/$userId/verification',
      body: {'status': status, 'target_role': targetRole},
    );
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<List<Map<String, dynamic>>> pendingCashOuts() async {
    final res = await _client.get('/admin/cash-outs/pending');
    return _extractPaginatedOrList(res['data']);
  }

  Future<void> resolveCashOut(int id, String status) async {
    await _client.patch('/wallet/cash-outs/$id', body: {'status': status});
  }

  Future<List<Map<String, dynamic>>> pendingMentorPremium() async {
    final res = await _client.get('/admin/mentor-premium-subscriptions/pending');
    return _extractPaginatedOrList(res['data']);
  }

  Future<void> resolveMentorPremium(int id, String paymentStatus) async {
    await _client.patch(
      '/admin/mentor-premium-subscriptions/$id',
      body: {'payment_status': paymentStatus},
    );
  }

  Future<List<Map<String, dynamic>>> disputes({String status = 'all'}) async {
    final res = await _client.get(
      '/admin/disputes',
      query: {if (status != 'all') 'status': status},
    );
    return _asMapList(res['data']);
  }

  Future<Map<String, dynamic>> resolveDispute(
    int disputeId, {
    required String status,
    required String resolutionNotes,
  }) async {
    final res = await _client.patch(
      '/admin/disputes/$disputeId',
      body: {'status': status, 'resolution_notes': resolutionNotes.trim()},
    );
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<List<Map<String, dynamic>>> projects({
    String status = 'all',
    String search = '',
  }) async {
    final res = await _client.get(
      '/admin/projects',
      query: {
        if (status != 'all') 'status': status,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _asMapList(res['data']);
  }

  Future<void> updateProjectStatus(
    int projectId, {
    required String status,
    String? reason,
  }) async {
    await _client.patch(
      '/admin/projects/$projectId/status',
      body: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> transactions({String type = 'all'}) async {
    final res = await _client.get(
      '/admin/transactions',
      query: {if (type != 'all') 'type': type},
    );
    return _asMapList(res['data']);
  }

  Future<Map<String, dynamic>> updateUserSuspension(
    int userId, {
    required bool isSuspended,
    String reason = '',
    String? adminPassword,
  }) async {
    final res = await _client.patch(
      '/admin/users/$userId/suspension',
      body: {
        'is_suspended': isSuspended,
        if (reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (adminPassword != null && adminPassword.isNotEmpty)
          'admin_password': adminPassword,
      },
    );
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<int> forceLogoutUser(int userId) async {
    final res = await _client.post('/admin/users/$userId/force-logout');
    final data = (res['data'] as Map<String, dynamic>?) ?? const {};
    return (data['revoked_tokens'] as num?)?.toInt() ?? 0;
  }

  Future<List<Map<String, dynamic>>> auditLogs({String action = 'all'}) async {
    final res = await _client.get(
      '/admin/audit-logs',
      query: {if (action != 'all') 'action': action},
    );
    return _asMapList(res['data']);
  }

  Future<Map<String, dynamic>> securityAnomalies() async {
    final res = await _client.get('/admin/security/anomalies');
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<void> confirmAdminPassword(String password) async {
    await _client.post(
      '/admin/security/confirm-password',
      body: {'password': password},
    );
  }

  Future<int> broadcastAnnouncement({
    required String targetRole,
    required String title,
    required String body,
  }) async {
    final res = await _client.post(
      '/admin/announcements/broadcast',
      body: {
        'target_role': targetRole,
        'title': title.trim(),
        'body': body.trim(),
      },
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? const {};
    return (data['recipients_count'] as num?)?.toInt() ?? 0;
  }

  Future<List<Map<String, dynamic>>> activeSessions() async {
    final res = await _client.get('/auth/sessions');
    return _asMapList(res['data']);
  }

  Future<String> revokeOtherSessions() async {
    await _client.delete('/auth/sessions/others');
    return 'Sesi perangkat lain berhasil dicabut.';
  }

  Future<AdminPageResult> usersPage({
    String role = 'all',
    String search = '',
    int page = 1,
  }) async {
    final res = await _client.get(
      '/admin/users',
      query: {
        if (role != 'all') 'role': role,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        'page': '$page',
      },
    );
    return _asPageResult(res);
  }

  Future<AdminPageResult> projectsPage({
    String status = 'all',
    String search = '',
    int page = 1,
  }) async {
    final res = await _client.get(
      '/admin/projects',
      query: {
        if (status != 'all') 'status': status,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        'page': '$page',
      },
    );
    return _asPageResult(res);
  }

  Future<AdminPageResult> transactionsPage({
    String type = 'all',
    int page = 1,
  }) async {
    final res = await _client.get(
      '/admin/transactions',
      query: {
        if (type != 'all') 'type': type,
        'page': '$page',
      },
    );
    return _asPageResult(res);
  }

  Future<AdminPageResult> auditLogsPage({
    String action = 'all',
    int page = 1,
  }) async {
    final res = await _client.get(
      '/admin/audit-logs',
      query: {
        if (action != 'all') 'action': action,
        'page': '$page',
      },
    );
    return _asPageResult(res);
  }

  Future<Map<String, dynamic>> adjustUserWallet(
    int userId, {
    required String direction,
    required int amountTc,
    required String reason,
    required String adminPassword,
  }) async {
    final res = await _client.post(
      '/admin/users/$userId/wallet-adjustment',
      body: {
        'direction': direction,
        'amount_tc': amountTc,
        'reason': reason.trim(),
        'admin_password': adminPassword,
      },
    );
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  Future<AdminPageResult> mentoringClassesPage({
    String status = 'all',
    String search = '',
    int page = 1,
  }) async {
    final res = await _client.get(
      '/admin/mentoring-classes',
      query: {
        if (status != 'all') 'status': status,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        'page': '$page',
      },
    );
    return _asPageResult(res);
  }

  Future<void> updateMentoringClassStatus(
    int classId, {
    required String status,
    String? reason,
  }) async {
    await _client.patch(
      '/admin/mentoring-classes/$classId/status',
      body: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> rewards() async {
    final res = await _client.get('/admin/rewards');
    return _asMapList(res['data']);
  }

  Future<void> createReward({
    required String title,
    required String provider,
    required String description,
    required int tcPrice,
    required int stock,
  }) async {
    await _client.post(
      '/admin/rewards',
      body: {
        'title': title.trim(),
        'provider': provider.trim(),
        'description': description.trim(),
        'tc_price': tcPrice,
        'stock': stock,
        'is_active': true,
      },
    );
  }

  Future<void> updateReward(
    int rewardId, {
    int? tcPrice,
    int? stock,
    bool? isActive,
  }) async {
    await _client.patch(
      '/admin/rewards/$rewardId',
      body: {
        'tc_price': ?tcPrice,
        'stock': ?stock,
        'is_active': ?isActive,
      },
    );
  }

  Future<Map<String, dynamic>> exportCsv(String resource) async {
    final res = await _client.get('/admin/export/$resource');
    return (res['data'] as Map<String, dynamic>?) ?? const {};
  }

  AdminPageResult _asPageResult(Map<String, dynamic> res) {
    final items = _asMapList(res['data']);
    final meta = (res['meta'] as Map<String, dynamic>?) ?? const {};
    return AdminPageResult(
      items: items,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
    );
  }

  List<Map<String, dynamic>> _extractPaginatedOrList(Object? raw) {
    if (raw is Map<String, dynamic> && raw['data'] is List) {
      return _asMapList(raw['data']);
    }
    return _asMapList(raw);
  }

  List<Map<String, dynamic>> _asMapList(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
