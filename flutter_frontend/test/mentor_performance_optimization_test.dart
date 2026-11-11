import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/core/network/api_client.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_bookings_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_dashboard_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_main_layout.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_profile_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_services_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_students_screen.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_wallet_screen.dart';

class _CountingFakeMentorApi extends MentorApi {
  int dashboardCalls = 0;
  int profileCalls = 0;
  int walletCalls = 0;
  int enrollmentsCalls = 0;

  @override
  Future<Map<String, dynamic>> dashboard() async {
    dashboardCalls++;
    return {
      'completed_sessions': 8,
      'active_students': 3,
      'rating': 4.9,
      'upcoming_bookings': const <Map<String, dynamic>>[],
    };
  }

  @override
  Future<Map<String, dynamic>> profile() async {
    profileCalls++;
    return {'name': 'Mentor Uji'};
  }

  @override
  Future<Map<String, dynamic>> walletSummary() async {
    walletCalls++;
    return {'balance_tc': 350, 'total_earned_tc': 1200};
  }

  @override
  Future<List<Map<String, dynamic>>> enrollments({int page = 1}) async {
    enrollmentsCalls++;
    return const <Map<String, dynamic>>[];
  }
}

void main() {
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  late Map<String, String> backingStore;
  late Map<String, int> readCountByKey;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    backingStore = {
      'access_token': 'token-uji',
      'session_user': jsonEncode({'id': 1, 'name': 'Mentor Uji'}),
    };
    readCountByKey = {};

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          final args = Map<Object?, Object?>.from(
            call.arguments as Map? ?? const {},
          );
          final key = args['key']?.toString();
          switch (call.method) {
            case 'read':
              if (key != null) {
                readCountByKey[key] = (readCountByKey[key] ?? 0) + 1;
                return backingStore[key];
              }
              return null;
            case 'write':
              final value = args['value']?.toString();
              if (key != null && value != null) {
                backingStore[key] = value;
              }
              return null;
            case 'delete':
              if (key != null) backingStore.remove(key);
              return null;
            default:
              return null;
          }
        });

    await ApiClient.instance.clearSession();
    backingStore['access_token'] = 'token-uji';
    backingStore['session_user'] = jsonEncode({
      'id': 1,
      'name': 'Mentor Uji',
    });
    readCountByKey.clear();
  });

  tearDown(() async {
    await ApiClient.instance.clearSession();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  test('ApiClient caches session user across concurrent and repeated reads', () async {
    final concurrent = await Future.wait([
      ApiClient.instance.readSessionUser(),
      ApiClient.instance.readSessionUser(),
      ApiClient.instance.readSessionUser(),
    ]);

    expect(readCountByKey['session_user'], 1);
    expect(concurrent[0]?['name'], 'Mentor Uji');

    // Returned copy should not mutate internal cache.
    concurrent[0]?['name'] = 'Mutated Locally';
    final cachedAgain = await ApiClient.instance.readSessionUser();
    expect(cachedAgain?['name'], 'Mentor Uji');
    expect(readCountByKey['session_user'], 1);

    await ApiClient.instance.updateSessionUser({'name': 'Mentor Baru'});
    final updated = await ApiClient.instance.readSessionUser();
    expect(updated?['name'], 'Mentor Baru');
    expect(readCountByKey['session_user'], 1);
  });

  testWidgets(
    'MentorDashboardScreen caches Future on rebuild, drops unused profile call, and syncs availableTc',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeApi = _CountingFakeMentorApi();
      final availableTc = ValueNotifier<int>(0);
      addTearDown(availableTc.dispose);

      late VoidCallback triggerRebuild;
      int rebuildCounter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              triggerRebuild = () => setState(() => rebuildCounter++);
              return Scaffold(
                body: Column(
                  children: [
                    Text('rebuild-$rebuildCounter'),
                    Expanded(
                      child: MentorDashboardScreen(
                        availableTc: availableTc,
                        mentorApi: fakeApi,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(fakeApi.profileCalls, 0);
      expect(fakeApi.dashboardCalls, 1);
      expect(fakeApi.walletCalls, 1);
      expect(fakeApi.enrollmentsCalls, 1);
      expect(availableTc.value, 350);

      triggerRebuild();
      await tester.pump();
      triggerRebuild();
      await tester.pump();

      expect(fakeApi.profileCalls, 0);
      expect(fakeApi.dashboardCalls, 1);
      expect(fakeApi.walletCalls, 1);
      expect(fakeApi.enrollmentsCalls, 1);
    },
  );

  testWidgets('MentorMainLayout builds tabs lazily on first visit', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MentorMainLayout()));
    await tester.pump();

    expect(find.byType(MentorDashboardScreen), findsOneWidget);
    expect(find.byType(MentorBookingsScreen), findsNothing);
    expect(find.byType(MentorStudentsScreen), findsNothing);
    expect(find.byType(MentorWalletScreen), findsNothing);
    expect(find.byType(MentorProfileScreen), findsNothing);
    expect(find.byType(MentorServicesScreen), findsNothing);

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pump();

    expect(
      find.byType(MentorDashboardScreen, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(MentorBookingsScreen), findsOneWidget);
    expect(find.byType(MentorStudentsScreen), findsNothing);
    expect(find.byType(MentorWalletScreen), findsNothing);
    expect(find.byType(MentorProfileScreen), findsNothing);
  });
}
