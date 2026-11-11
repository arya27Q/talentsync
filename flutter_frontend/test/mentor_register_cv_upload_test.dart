import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/features/auth/screens/mentor_register_screen.dart';

Uint8List _samplePdfBytes([int length = 2048]) {
  final bytes = Uint8List(length);
  const header = '%PDF-1.4\n';
  for (var i = 0; i < header.length && i < length; i++) {
    bytes[i] = header.codeUnitAt(i);
  }
  return bytes;
}

void main() {
  testWidgets(
    'MentorRegisterScreen shows PDF CV upload and handles empty, valid, invalid, and clear states on 360x640',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      PickedCvFile? nextPick;

      await tester.pumpWidget(
        MaterialApp(
          home: MentorRegisterScreen(
            onPickCv: () async => nextPick,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upload CV (Format PDF)'), findsOneWidget);
      expect(find.text('Pilih File CV (.pdf)'), findsOneWidget);
      expect(
        find.text('Tautan dokumen verifikasi (PDF atau gambar)'),
        findsNothing,
      );
      expect(find.text('Masukkan URL dokumen verifikasi'), findsNothing);

      final uploadButton = find.text('Pilih File CV (.pdf)');
      await tester.ensureVisible(uploadButton);
      await tester.pumpAndSettle();

      // 1. Rejects non-PDF extension
      nextPick = PickedCvFile(
        name: 'foto-ktm.png',
        bytes: Uint8List.fromList(<int>[137, 80, 78, 71]),
      );
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();
      expect(
        find.text('Format berkas harus .pdf. Pilih ulang CV berformat PDF.'),
        findsOneWidget,
      );

      // 2. Rejects renamed file lacking PDF header
      nextPick = PickedCvFile(
        name: 'bukan-pdf.pdf',
        bytes: Uint8List.fromList('bukan pdf'.codeUnits),
      );
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();
      expect(
        find.text('Isi berkas tidak valid sebagai dokumen PDF.'),
        findsOneWidget,
      );

      // 3. Rejects PDF larger than 5 MB
      nextPick = PickedCvFile(
        name: 'cv-terlalu-besar.pdf',
        bytes: _samplePdfBytes(5 * 1024 * 1024 + 1024),
      );
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('melebihi batas maksimal 5 MB.'),
        findsOneWidget,
      );

      // 4. Accepts valid PDF and shows real filename + computed file size
      nextPick = PickedCvFile(
        name: 'CV_Dimas_Prasetyo.pdf',
        bytes: _samplePdfBytes(2048),
      );
      await tester.tap(uploadButton);
      await tester.pumpAndSettle();
      expect(find.text('CV_Dimas_Prasetyo.pdf'), findsOneWidget);
      expect(find.text('2.0 KB · PDF siap diunggah'), findsOneWidget);
      expect(find.byTooltip('Hapus CV'), findsOneWidget);

      // 5. Clears uploaded PDF back to empty state
      await tester.tap(find.byTooltip('Hapus CV'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih File CV (.pdf)'), findsOneWidget);
      expect(find.text('CV_Dimas_Prasetyo.pdf'), findsNothing);

      // 6. Submitting without CV triggers inline CV validation error
      final checkbox = find.textContaining('praktik joki tugas.');
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      final submitBtn = find.text('Kirim Pendaftaran Peer Mentor');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('CV dalam format PDF wajib diunggah.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
