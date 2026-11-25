import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/routes/student_route_args.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_services_screen.dart';
import 'package:flutter_frontend/features/mentoring/data/student_mentoring_api.dart';
import 'package:flutter_frontend/features/mentoring/screens/booking_session_screen.dart';
import 'package:flutter_frontend/features/mentoring/screens/find_mentors_screen.dart';
import 'package:flutter_frontend/features/msme/data/msme_api.dart';
import 'package:flutter_frontend/features/msme/widgets/msme_reject_mentor_dialog.dart';
import 'package:flutter_frontend/features/wallet/data/wallet_api.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMentorApi extends MentorApi {
  Map<String, dynamic>? lastCreatedClass;
  final List<Map<String, dynamic>> storedClasses = [
    {
      'id': 1,
      'topic': 'Arsitektur Flutter & BLoC',
      'description': 'Audit struktur Feature-First dan persiapan proyek UMKM.',
      'scheduled_time': '2026-12-01T19:00:00Z',
      'duration_minutes': 60,
      'duration_days': 7,
      'duration_label': '7 Hari',
      'price_tc': 30,
      'capacity': 1,
      'enrolled_count': 2,
      'status': 'open',
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> classes({int page = 1}) async =>
      List<Map<String, dynamic>>.from(storedClasses);

  @override
  Future<Map<String, dynamic>> profile() async => {
    'cashout_fee_percent': 0,
  };

  @override
  Future<Map<String, dynamic>> createClass(Map<String, dynamic> body) async {
    lastCreatedClass = body;
    final created = {
      'id': 2,
      ...body,
      'enrolled_count': 0,
      'status': 'open',
    };
    storedClasses.insert(0, created);
    return created;
  }
}

class _FakeStudentMentoringApi extends StudentMentoringApi {
  @override
  Future<Map<String, dynamic>> mentors({
    String? search,
    String? category,
    String? sort = 'rating_desc',
    int page = 1,
  }) async => {
    'data': [
      {
        'id': 21,
        'name': 'Dimas Prasetyo',
        'title_headline': 'Senior Flutter Engineer',
        'bio': 'Pendampingan portofolio dan arsitektur Flutter.',
        'hourly_rate_tc': 30,
        'rating': 4.9,
        'reviews_count': 8,
        'tags': ['Top Mentor'],
        'nearest_class': {
          'id': 101,
          'topic': 'Pendampingan Kasir UMKM',
          'duration_days': 14,
          'duration_label': '2 Minggu',
          'price_tc': 45,
        },
      },
    ],
  };

  @override
  Future<Map<String, dynamic>> classDetail(int classId) async => {
    'id': classId,
    'mentor_id': 21,
    'mentor_name': 'Dimas Prasetyo',
    'title_headline': 'Senior Flutter Engineer',
    'topic': 'Pendampingan Kasir UMKM',
    'duration_days': 14,
    'duration_label': '2 Minggu',
    'price_tc': 45,
  };
}

class _FakeWalletApi extends WalletApi {
  @override
  Future<Map<String, dynamic>> summary() async => {'balance_tc': 120};
}

class _FakeMsmeApi extends MsmeApi {
  String? lastCategory;

  @override
  Future<List<Map<String, dynamic>>> getRecommendedMentors({
    String? search,
    String? category,
  }) async {
    lastCategory = category;
    return [
      {
        'id': 21,
        'name': 'Dimas Prasetyo',
        'title_headline': 'Senior Flutter Engineer',
        'hourly_rate_tc': 30,
        'nearest_class': {
          'id': 101,
          'topic': 'Pendampingan Kasir UMKM',
          'duration_days': 14,
          'duration_label': '2 Minggu',
          'price_tc': 45,
        },
      },
    ];
  }
}

void main() {
  testWidgets(
    'MentorServicesScreen rejects 1 day duration and previews custom multi-day duration on 360x640',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeMentorApi = _FakeMentorApi();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MentorServicesScreen(mentorApi: fakeMentorApi),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('7 Hari · 1-on-1'), findsOneWidget);

      await tester.tap(find.byTooltip('Tambah layanan'));
      await tester.pumpAndSettle();

      expect(find.text('Buat Layanan Mentoring'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Bidang & tag keahlian'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final flutterChipSize = tester.getSize(
        find.ancestor(
          of: find.text('Flutter').first,
          matching: find.byType(FilterChip),
        ),
      );
      expect(flutterChipSize.width, lessThan(180));

      // Open crafted category dropdown and select Web Programming
      final categoryDropdown = find.byType(DropdownButtonFormField<String>);
      expect(categoryDropdown, findsOneWidget);
      await tester.ensureVisible(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Web Programming').last);
      await tester.pumpAndSettle();
      expect(find.text('Sub-keahlian · Web Programming'), findsOneWidget);

      final webCustomField = find.widgetWithText(
        TextField,
        'Ketik bahasa/tech web (misal: Go, Django, Express)',
      );
      await tester.ensureVisible(webCustomField);
      await tester.pumpAndSettle();
      await tester.enterText(webCustomField, 'Golang');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tambah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'Golang'), findsWidgets);

      // Switch to AI Engineering via dropdown and select Python
      await tester.ensureVisible(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('AI Engineering').last);
      await tester.pumpAndSettle();
      expect(find.text('Sub-keahlian · AI Engineering'), findsOneWidget);
      await tester.ensureVisible(find.text('Python'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Python'));
      await tester.pumpAndSettle();
      expect(find.text('Keahlian terpilih (4)'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Terbitkan Layanan'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terbitkan Layanan'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Durasi pendampingan'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Durasi pendampingan'), findsOneWidget);
      expect(find.text('Isi angka durasi pendampingan.'), findsOneWidget);

      final durationField = find.widgetWithText(TextFormField, 'Misal: 7');
      await tester.ensureVisible(durationField);
      await tester.enterText(durationField, '1');
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Terbitkan Layanan'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terbitkan Layanan'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Durasi pendampingan'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Minimal 2 hari sesuai target kinerja murid.'),
        findsOneWidget,
      );

      await tester.enterText(durationField, '2');
      await tester.ensureVisible(find.text('Minggu'));
      await tester.tap(find.text('Minggu'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Target durasi: 2 Minggu (setara 14 hari pendampingan sesuai kinerja murid).',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Kelas mentoring'), findsOneWidget);
    },
  );

  testWidgets(
    'Student FindMentorsScreen, BookingSessionScreen, and MSME dialog display custom mentor duration',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final studentMentoringApi = _FakeStudentMentoringApi();
      final walletApi = _FakeWalletApi();

      await tester.pumpWidget(
        MaterialApp(
          home: FindMentorsScreen(
            mentoringApi: studentMentoringApi,
            walletApi: walletApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('45 TC / 2 Minggu'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingSessionScreen(
            args: const BookingSessionArgs(classId: 101),
            mentoringApi: studentMentoringApi,
            walletApi: walletApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Durasi pendampingan: 2 Minggu · Sesuai kinerja'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MsmeRejectMentorDialog(
              studentName: 'Arya Pratama',
              msmeApi: _FakeMsmeApi(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Senior Flutter Engineer · Durasi 2 Minggu'),
        findsOneWidget,
      );
      expect(find.text('45 TC'), findsOneWidget);
    },
  );
}
