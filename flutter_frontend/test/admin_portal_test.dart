import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/admin/data/admin_api.dart';
import 'package:flutter_frontend/features/admin/screens/admin_login_screen.dart';
import 'package:flutter_frontend/features/admin/screens/admin_main_layout.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminApi extends AdminApi {
  bool loggedIn = false;
  int? resolvedCashOutId;
  int? resolvedDisputeId;

  @override
  Future<Map<String, dynamic>?> currentAdminSession() async => null;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    loggedIn = true;
    return {'id': 1, 'name': 'Admin TalentSync', 'email': email, 'role': 'admin'};
  }

  @override
  Future<Map<String, dynamic>> dashboard() async => {
    'users': {'total': 12, 'students': 6, 'msmes': 4, 'mentors': 2},
    'projects': {'total': 5, 'open': 2, 'in_progress': 2, 'completed': 1},
    'economy': {'total_circulating_tc': 2500, 'total_locked_escrow_tc': 350},
    'queues': {
      'pending_cash_outs': 1,
      'pending_mentor_premium': 1,
      'open_disputes': 1,
    },
    'recent_transactions': [
      {
        'label': 'Escrow Proyek',
        'owner_name': 'Toko Bu Sri',
        'owner_email': 'umkm.busri@talentsync.id',
        'direction': 'debit',
        'amount': 100,
        'status': 'completed',
      },
    ],
  };

  @override
  Future<List<Map<String, dynamic>>> pendingCashOuts() async => [
    {
      'id': 9,
      'amount_tc': 100,
      'bank_name': 'BCA',
      'account_number': '1234567890',
      'account_holder_name': 'Dimas Prasetyo',
      'disbursed_amount_idr': 100000,
      'user': {'name': 'Dimas Prasetyo', 'email': 'dimas@talentsync.id'},
    },
  ];

  @override
  Future<void> resolveCashOut(int id, String status) async {
    resolvedCashOutId = id;
  }

  @override
  Future<List<Map<String, dynamic>>> pendingMentorPremium() async => [
    {
      'id': 4,
      'price_idr': 99000,
      'payment_status': 'pending',
      'mentor': {'name': 'Nadia Kusuma', 'email': 'nadia@talentsync.id'},
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> disputes({String status = 'all'}) async => [
    {
      'id': 7,
      'reporter_name': 'Arya Pratama',
      'reporter_email': 'arya@mhs.unesa.ac.id',
      'reference_type_label': 'Proyek UMKM',
      'category': 'Keterlambatan Validasi',
      'description': 'Mitra belum memvalidasi hasil pekerjaan selama 4 hari.',
      'status': 'open',
    },
  ];

  @override
  Future<Map<String, dynamic>> resolveDispute(
    int disputeId, {
    required String status,
    required String resolutionNotes,
  }) async {
    resolvedDisputeId = disputeId;
    return {'id': disputeId, 'status': status};
  }

  @override
  Future<List<Map<String, dynamic>>> users({
    String role = 'all',
    String search = '',
  }) async => [
    {
      'id': 11,
      'name': 'Arya Pratama',
      'email': 'arya@mhs.unesa.ac.id',
      'role': 'student',
      'subtitle': 'UNESA · 24051214017',
      'verification_status': 'pending',
      'balance_tc': 150,
      'locked_balance_tc': 30,
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> projects({
    String status = 'all',
    String search = '',
  }) async => [
    {
      'id': 20,
      'title': 'Aplikasi Kasir Toko Bu Sri',
      'category': 'App Development',
      'msme_name': 'Toko Bu Sri',
      'reward_tc': 150,
      'status': 'open',
      'applications_count': 3,
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> transactions({String type = 'all'}) async =>
      const [];

  @override
  Future<Map<String, dynamic>> securityAnomalies() async => {
    'summary': {
      'total_alerts': 1,
      'high_severity_count': 1,
      'suspended_users_count': 0,
      'open_disputes_count': 1,
    },
    'alerts': [
      {
        'severity': 'high',
        'code': 'high_value_cash_out',
        'title': 'Pencairan Nominal Tinggi (400 TC)',
        'description': 'Dimas mengajukan pencairan 400 TC.',
      },
    ],
  };

  @override
  Future<List<Map<String, dynamic>>> auditLogs({String action = 'all'}) async =>
      [
        {
          'id': 1,
          'admin_name': 'Admin TalentSync',
          'action': 'cash_out_approved',
          'target_label': 'Cash-Out #9 (100 TC)',
          'details': 'Disetujui admin.',
          'ip_address': '127.0.0.1',
          'created_at': '2026-11-25T12:00:00Z',
        },
      ];

  @override
  Future<AdminPageResult> usersPage({
    String role = 'all',
    String search = '',
    int page = 1,
  }) async => AdminPageResult(
    items: await users(role: role, search: search),
    currentPage: page,
    lastPage: 1,
    total: 1,
  );

  @override
  Future<AdminPageResult> projectsPage({
    String status = 'all',
    String search = '',
    int page = 1,
  }) async => AdminPageResult(
    items: await projects(status: status, search: search),
    currentPage: page,
    lastPage: 1,
    total: 1,
  );

  @override
  Future<AdminPageResult> transactionsPage({
    String type = 'all',
    int page = 1,
  }) async => const AdminPageResult(
    items: [],
    currentPage: 1,
    lastPage: 1,
    total: 0,
  );

  @override
  Future<AdminPageResult> auditLogsPage({
    String action = 'all',
    int page = 1,
  }) async => AdminPageResult(
    items: await auditLogs(action: action),
    currentPage: page,
    lastPage: 1,
    total: 1,
  );

  @override
  Future<AdminPageResult> mentoringClassesPage({
    String status = 'all',
    String search = '',
    int page = 1,
  }) async => const AdminPageResult(
    items: [],
    currentPage: 1,
    lastPage: 1,
    total: 0,
  );

  @override
  Future<List<Map<String, dynamic>>> rewards() async => const [];

  @override
  Future<List<Map<String, dynamic>>> activeSessions() async => [
    {
      'id': 1,
      'device_name': 'Chrome Desktop',
      'is_current': true,
      'created_at': '2026-11-25T12:00:00Z',
      'last_used_at': '2026-11-25T12:05:00Z',
    },
  ];
}

void main() {
  testWidgets(
    'AdminLoginScreen validates credentials and navigates to AdminMainLayout on desktop',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeApi = _FakeAdminApi();
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.adminLogin: (_) => AdminLoginScreen(adminApi: fakeApi),
            AppRoutes.adminDashboard: (_) => AdminMainLayout(adminApi: fakeApi),
          },
          initialRoute: AppRoutes.adminLogin,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk ke Portal Admin'));
      await tester.pumpAndSettle();
      expect(find.text('Masukkan email administrator yang valid.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'admin@talentsync.id'),
        'admin@talentsync.id',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Masukkan kata sandi'),
        'password123',
      );
      await tester.tap(find.text('Masuk ke Portal Admin'));
      await tester.pumpAndSettle();

      expect(fakeApi.loggedIn, isTrue);
      expect(find.text('TalentSync'), findsOneWidget);
      expect(find.text('2500 TC'), findsOneWidget);

      // Switch to Persetujuan and approve cash-out
      await tester.tap(find.text('Persetujuan'));
      await tester.pumpAndSettle();
      expect(find.text('Antrean Pencairan Dana Cash-Out (1)'), findsOneWidget);
      await tester.tap(find.text('Setujui Transfer'));
      await tester.pumpAndSettle();
      expect(fakeApi.resolvedCashOutId, 9);

      // Switch to Sengketa
      await tester.tap(find.text('Sengketa'));
      await tester.pumpAndSettle();
      expect(find.text('Putuskan Sengketa'), findsOneWidget);

      // Switch to Pengguna 3 POV
      await tester.tap(find.text('Pengguna 3 POV'));
      await tester.pumpAndSettle();
      expect(find.text('Arya Pratama (student)'), findsOneWidget);
      expect(find.text('Bekukan'), findsOneWidget);

      // Switch to Keamanan & Audit
      await tester.tap(find.text('Keamanan & Audit'));
      await tester.pumpAndSettle();
      expect(find.text('Pemantauan Anomali Ekonomi TimeCoin'), findsOneWidget);
      expect(find.text('Pencairan Nominal Tinggi (400 TC)'), findsOneWidget);
    },
  );

  testWidgets('AdminMainLayout renders cleanly on tablet 800x600 without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: AdminMainLayout(adminApi: _FakeAdminApi())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Antrean Tindakan Admin'), findsOneWidget);
  });
}
