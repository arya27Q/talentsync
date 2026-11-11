import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/mentor/data/mentor_api.dart';
import 'package:flutter_frontend/features/mentor/screens/mentor_profile_screen.dart';

final Uint8List _validPng1x1 = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeMentorApi extends MentorApi {
  Map<String, dynamic>? lastUpdateBody;
  String? lastAvatarFileName;
  Uint8List? lastAvatarBytes;
  bool deleteAccountCalled = false;

  @override
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body, {
    String? avatarFileName,
    Uint8List? avatarBytes,
  }) async {
    lastUpdateBody = body;
    lastAvatarFileName = avatarFileName;
    lastAvatarBytes = avatarBytes;
    return {
      'name': body['name'],
      'title_headline': body['title_headline'],
      'bio': body['bio'],
      'avatar_url': null,
    };
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
  }
}

void main() {
  testWidgets(
    'MentorProfileScreen supports editing name & photo and deleting mentor account on 360x640',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeApi = _FakeMentorApi();
      final balance = ValueNotifier<int>(420);
      PickedAvatarFile? nextAvatar;

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.roleSelection: (_) =>
                const Scaffold(body: Center(child: Text('Role Selection'))),
          },
          home: Scaffold(
            body: MentorProfileScreen(
              availableTc: balance,
              mentorApi: fakeApi,
              skipInitialLoad: true,
              initialName: 'Andika Octavianto',
              initialHeadline: 'Mentor Flutter & Dart',
              initialBio: 'Bio awal',
              onPickAvatar: () async => nextAvatar,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Shows initials fallback 'AO' and initial name
      expect(find.text('AO'), findsOneWidget);
      expect(find.text('Andika Octavianto'), findsOneWidget);

      // 2. Opens Edit Profil bottom sheet
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profil Mentor'), findsOneWidget);

      // 3. Rejects invalid non-image extension
      nextAvatar = PickedAvatarFile(
        name: 'dokumen.pdf',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      );
      await tester.tap(find.text('Pilih Foto'));
      await tester.pumpAndSettle();
      expect(
        find.text('Format foto harus JPG, PNG, atau WEBP.'),
        findsOneWidget,
      );

      // 4. Rejects oversized photo > 2 MB
      nextAvatar = PickedAvatarFile(
        name: 'besar.png',
        bytes: Uint8List(2 * 1024 * 1024 + 100),
      );
      await tester.tap(find.text('Pilih Foto'));
      await tester.pumpAndSettle();
      expect(find.text('Ukuran foto profil maksimal 2 MB.'), findsOneWidget);

      // 5. Accepts valid PNG image, edits name & headline, and saves
      nextAvatar = PickedAvatarFile(name: 'avatar.png', bytes: _validPng1x1);
      await tester.tap(find.text('Pilih Foto'));
      await tester.pumpAndSettle();
      expect(find.text('Ganti Foto'), findsOneWidget);
      expect(find.text('Hapus Foto'), findsOneWidget);

      final nameField = find.widgetWithText(TextField, 'Andika Octavianto');
      await tester.enterText(nameField, 'Andika Pratama');
      final headlineField = find.widgetWithText(
        TextField,
        'Mentor Flutter & Dart',
      );
      await tester.enterText(headlineField, 'Senior Flutter Architect');

      final saveButton = find.text('Simpan Perubahan');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(fakeApi.lastUpdateBody?['name'], 'Andika Pratama');
      expect(
        fakeApi.lastUpdateBody?['title_headline'],
        'Senior Flutter Architect',
      );
      expect(fakeApi.lastAvatarFileName, 'avatar.png');
      expect(fakeApi.lastAvatarBytes, isNotNull);
      expect(find.text('Andika Pratama'), findsOneWidget);
      expect(find.text('Senior Flutter Architect'), findsOneWidget);

      // 6. Scroll to bottom and delete mentor account
      final deleteButton = find.text('Hapus Akun Mentor');
      await tester.scrollUntilVisible(deleteButton, 300);
      await tester.pumpAndSettle();
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Hapus Akun Mentor Permanen?'), findsOneWidget);
      await tester.tap(find.text('Ya, Hapus Akun'));
      await tester.pumpAndSettle();

      expect(fakeApi.deleteAccountCalled, isTrue);
      expect(find.text('Role Selection'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
