import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/auth/data/auth_api.dart';
import 'package:flutter_frontend/features/auth/screens/student_auth_screen.dart';
import 'package:flutter_frontend/features/profile/data/student_profile_api.dart';
import 'package:flutter_frontend/features/profile/screens/switch_to_mentor_screen.dart';
import 'package:flutter_frontend/features/project/data/project_api.dart';
import 'package:flutter_frontend/features/project/screens/apply_project_screen.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';
import 'package:flutter_frontend/features/wallet/screens/history_screen.dart';
import 'package:flutter_frontend/features/wallet/screens/transfer_screen.dart';
import 'package:flutter_frontend/features/workspace/data/workspace_api.dart';
import 'package:flutter_frontend/features/workspace/screens/workspace_kanban_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({this.loginResult});

  Map<String, dynamic>? loginResult;
  bool loggedOut = false;
  String? lastIdentifier;

  @override
  Future<Map<String, dynamic>> login({
    String? email,
    String? identifier,
    required String password,
  }) async {
    lastIdentifier = identifier ?? email;
    return loginResult ??
        {
          'id': 10,
          'name': 'Arya Mahasiswa',
          'email': 'arya@mhs.unesa.ac.id',
          'role': 'student',
        };
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }
}

class _FakeProjectApi extends ProjectApi {
  _FakeProjectApi({required this.canApply});

  final bool canApply;
  bool applyCalled = false;

  @override
  Future<Map<String, dynamic>> applyContext(int projectId) async {
    return {
      'project': {
        'id': projectId,
        'title': 'Aplikasi Kasir Toko Bu Sri',
        'reward_tc': 150,
        'msme': {'business_name': 'Toko Bu Sri'},
      },
      'eligibility': {
        'can_apply': canApply,
        'reason': canApply
            ? 'Memenuhi syarat melamar.'
            : 'Wajib memiliki Portofolio Terverifikasi atau Badge Rekomendasi Mentor.',
      },
      'portfolios': canApply
          ? [
              {
                'id': 1,
                'title': 'Sistem Kasir Warung Pak Gito',
                'client_name': 'Warung Pak Gito',
              },
            ]
          : [],
    };
  }

  @override
  Future<Map<String, dynamic>> apply(
    int projectId, {
    required String coverLetter,
    List<int> portfolioIds = const [],
    String? portfolioLink,
    String? timelineCommitment,
    String? dedicationHours,
    bool commitmentAccepted = true,
  }) async {
    applyCalled = true;
    return {'id': 99, 'status': 'pending'};
  }
}

class _FakeWorkspaceApi extends WorkspaceApi {
  final List<Map<String, dynamic>> tasks = [
    {
      'id': 1,
      'title': 'Setup skema database kasir',
      'tag': 'Backend',
      'status': 'todo',
      'deadline_label': '12 Nov',
    },
  ];
  bool createCalled = false;
  bool updateCalled = false;

  @override
  Future<Map<String, dynamic>> kanban(int projectId) async {
    final total = tasks.length;
    final done = tasks.where((t) => t['status'] == 'done').length;
    return {
      'project': {
        'id': projectId,
        'title': 'Sistem Kasir POS',
        'reward_tc': 150,
        'msme': {'business_name': 'Toko Bu Sri'},
      },
      'progress_percent': total == 0 ? 0 : ((done / total) * 100).round(),
      'tasks': List<Map<String, dynamic>>.from(tasks),
    };
  }

  @override
  Future<Map<String, dynamic>> createTask(
    int projectId, {
    required String title,
    String tag = 'Fitur',
    String status = 'todo',
    String? deadlineLabel,
  }) async {
    createCalled = true;
    final created = {
      'id': tasks.length + 1,
      'title': title,
      'tag': tag,
      'status': status,
      'deadline_label': deadlineLabel ?? 'Baru',
    };
    tasks.add(created);
    return created;
  }

  @override
  Future<Map<String, dynamic>> updateTask(
    int taskId,
    Map<String, dynamic> body,
  ) async {
    updateCalled = true;
    final idx = tasks.indexWhere((t) => t['id'] == taskId);
    if (idx != -1) {
      tasks[idx] = {...tasks[idx], ...body};
      return tasks[idx];
    }
    return const {};
  }
}

class _FakeProfileApi extends StudentProfileApi {
  _FakeProfileApi({required this.eligible});

  final bool eligible;
  bool switched = false;

  @override
  Future<Map<String, dynamic>> mentorEligibility() async {
    return {
      'is_eligible': eligible,
      'already_mentor': false,
      'completed_projects_count': eligible ? 5 : 2,
      'min_projects_required': 5,
      'rating_average': eligible ? 4.9 : 4.5,
      'checks': [
        {
          'key': 'completed_projects',
          'label': 'Selesaikan minimal 5 proyek UMKM nyata',
          'detail': eligible ? '5/5 selesai' : '2/5 selesai',
          'passed': eligible,
        },
      ],
      'available_proofs': [
        {'id': 1, 'title': 'Sistem Kasir', 'subtitle': 'UMKM', 'selected': true},
      ],
      'skills': ['Flutter', 'Laravel'],
    };
  }

  @override
  Future<Map<String, dynamic>> switchToMentor({
    required List<int> selectedProofIds,
    required List<String> teachingSkills,
    String? titleHeadline,
    String? bio,
    int hourlyRateTc = 30,
    String? externalCertFileName,
    Uint8List? externalCertBytes,
  }) async {
    switched = true;
    return {'active_role': 'mentor'};
  }
}

class _FakeWalletApi extends WalletApi {
  String? lastDirection;
  String? lastRecipient;
  int? lastTransferAmount;

  @override
  Future<Map<String, dynamic>> summary() async {
    return {
      'balance_tc': 150,
      'locked_balance_tc': 30,
      'estimated_idr': 150000,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> recipients({String? query}) async {
    return [
      {
        'id': 21,
        'name': 'Budi Santoso',
        'email': 'budi@mhs.unesa.ac.id',
        'student_id_number': '24051214099',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> transactions({
    int page = 1,
    String? type,
    String? direction,
  }) async {
    lastDirection = direction;
    final rows = [
      {
        'id': 1,
        'title': 'Imbalan Proyek UMKM',
        'direction': 'credit',
        'amount': 80,
        'created_at': '2026-11-11T09:00:00Z',
      },
      {
        'id': 2,
        'title': 'Booking Sesi Mentoring',
        'direction': 'debit',
        'amount': 30,
        'created_at': '2026-11-11T08:00:00Z',
      },
    ];
    final filtered = direction == null
        ? rows
        : rows.where((r) => r['direction'] == direction).toList();
    return {
      'data': filtered,
      'meta': {'current_page': 1, 'last_page': 1},
    };
  }

  @override
  Future<Map<String, dynamic>> transfer({
    required String recipientIdentifier,
    required int amountTc,
  }) async {
    lastRecipient = recipientIdentifier;
    lastTransferAmount = amountTc;
    return {'recipient_name': 'Budi Santoso', 'amount_tc': amountTc};
  }
}

void main() {
  testWidgets('StudentAuthScreen validates empty input and rejects non-student', (
    tester,
  ) async {
    final nonStudentApi = _FakeAuthApi(
      loginResult: {'id': 2, 'name': 'Dimas', 'role': 'mentor'},
    );

    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: StudentAuthScreen(authApi: nonStudentApi),
        routes: {
          AppRoutes.studentDashboard: (_) => const Scaffold(
            body: Center(child: Text('DASHBOARD_MAHASISWA')),
          ),
        },
      ),
    );
    await tester.pumpAndSettle();

    final signInBtn = find.text('Masuk Sekarang');
    await tester.ensureVisible(signInBtn);
    await tester.tap(signInBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.text('Masukkan NIM atau email dan kata sandi akun.'),
      findsOneWidget,
    );
    ScaffoldMessenger.of(tester.element(signInBtn)).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '24051214017');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.ensureVisible(signInBtn);
    await tester.tap(signInBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(nonStudentApi.lastIdentifier, '24051214017');
    expect(nonStudentApi.loggedOut, isTrue);
    expect(
      find.text('Akun ini bukan akun mahasiswa. Gunakan portal masuk sesuai peran.'),
      findsOneWidget,
    );

    final studentApi = _FakeAuthApi();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: StudentAuthScreen(authApi: studentApi),
        routes: {
          AppRoutes.studentDashboard: (_) => const Scaffold(
            body: Center(child: Text('DASHBOARD_MAHASISWA')),
          ),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '24051214017');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.ensureVisible(find.text('Masuk Sekarang'));
    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD_MAHASISWA'), findsOneWidget);
  });

  testWidgets('ApplyProjectScreen enforces eligibility guard & mentor CTA', (
    tester,
  ) async {
    final blockedApi = _FakeProjectApi(canApply: false);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: ApplyProjectScreen(projectId: 1, projectApi: blockedApi),
        routes: {
          AppRoutes.findMentors: (_) =>
              const Scaffold(body: Center(child: Text('FIND_MENTORS_PAGE'))),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cari Mentor Sekarang'), findsOneWidget);
    await tester.tap(find.text('Cari Mentor Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('FIND_MENTORS_PAGE'), findsOneWidget);
    expect(blockedApi.applyCalled, isFalse);

    final eligibleApi = _FakeProjectApi(canApply: true);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: ApplyProjectScreen(projectId: 1, projectApi: eligibleApi),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Saya siap mengerjakan integrasi aplikasi kasir untuk Toko Bu Sri secara tuntas.',
    );
    await tester.pump();
    final submitBtn = find.text('Kirim Lamaran (150 TC)');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(eligibleApi.applyCalled, isTrue);
    expect(find.text('Lamaran Terkirim!'), findsOneWidget);
  });

  testWidgets('WorkspaceKanbanScreen creates and moves task status', (
    tester,
  ) async {
    final workspaceApi = _FakeWorkspaceApi();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: WorkspaceKanbanScreen(
          projectId: 1,
          workspaceApi: workspaceApi,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Setup skema database kasir'), findsOneWidget);

    await tester.tap(find.text('Tambah tugas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Integrasi printer');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(workspaceApi.createCalled, isTrue);
    expect(find.text('Integrasi printer'), findsOneWidget);

    await tester.ensureVisible(find.text('Setup skema database kasir'));
    await tester.tap(find.text('Setup skema database kasir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done (Selesai)'));
    await tester.pumpAndSettle();

    expect(workspaceApi.updateCalled, isTrue);
  });

  testWidgets('SwitchToMentorScreen blocks ineligible student and activates eligible', (
    tester,
  ) async {
    final blockedProfileApi = _FakeProfileApi(eligible: false);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: SwitchToMentorScreen(profileApi: blockedProfileApi),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lengkapi Syarat Minimal 5 Proyek'), findsOneWidget);
    expect(find.text('Aktifkan Mode Peer Mentor'), findsNothing);

    final eligibleProfileApi = _FakeProfileApi(eligible: true);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: SwitchToMentorScreen(profileApi: eligibleProfileApi),
        routes: {
          AppRoutes.mentorDashboard: (_) =>
              const Scaffold(body: Center(child: Text('MENTOR_DASHBOARD'))),
        },
      ),
    );
    await tester.pumpAndSettle();

    final activateBtn = find.text('Aktifkan Mode Peer Mentor');
    await tester.scrollUntilVisible(
      activateBtn,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(activateBtn);
    await tester.pumpAndSettle();

    expect(eligibleProfileApi.switched, isTrue);
    expect(find.text('Mode Mentor Aktif!'), findsOneWidget);
  });

  testWidgets('Wallet HistoryScreen and TransferScreen wire WalletApi actions', (
    tester,
  ) async {
    final walletApi = _FakeWalletApi();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: HistoryScreen(walletApi: walletApi),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Imbalan Proyek UMKM'), findsOneWidget);
    expect(find.text('+80 TC'), findsOneWidget);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(walletApi.lastDirection, 'credit');
    expect(find.text('Imbalan Proyek UMKM'), findsOneWidget);
    expect(find.text('Booking Sesi Mentoring'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: TransferScreen(walletApi: walletApi),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saldo Tersedia: 150 TC'), findsOneWidget);
    await tester.tap(find.text('25 TC'));
    await tester.tap(find.text('Budi Santoso'));
    await tester.pump();
    final sendBtn = find.text('Kirim TimeCoin Sekarang');
    await tester.ensureVisible(sendBtn);
    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    expect(walletApi.lastTransferAmount, 25);
    expect(walletApi.lastRecipient, 'budi@mhs.unesa.ac.id');
  });
}
