import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/core/routes/app_routes.dart';
import 'package:flutter_frontend/features/auth/screens/mentor_auth_screen.dart';
import 'package:flutter_frontend/features/auth/screens/msme_auth_screen.dart';
import 'package:flutter_frontend/features/auth/screens/student_auth_screen.dart';

void main() {
  testWidgets(
    'MentorAuthScreen back button falls back to role selection when root route',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.roleSelection: (_) =>
                const Scaffold(body: Center(child: Text('Role Selection'))),
            AppRoutes.mentorAuth: (_) => const MentorAuthScreen(),
          },
          initialRoute: AppRoutes.mentorAuth,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Role Selection'), findsOneWidget);
    },
  );

  testWidgets(
    'MentorAuthScreen back button pops cleanly when previous route exists',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.roleSelection: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.mentorAuth),
                  child: const Text('Buka Portal Mentor'),
                ),
              ),
            ),
            AppRoutes.mentorAuth: (_) => const MentorAuthScreen(),
          },
          initialRoute: AppRoutes.roleSelection,
        ),
      );

      await tester.tap(find.text('Buka Portal Mentor'));
      await tester.pumpAndSettle();
      expect(find.text('Portal Mentor'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Buka Portal Mentor'), findsOneWidget);
    },
  );

  testWidgets(
    'MentorAuthScreen handles system back via PopScope when root route',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.roleSelection: (_) =>
                const Scaffold(body: Center(child: Text('Role Selection'))),
            AppRoutes.mentorAuth: (_) => const MentorAuthScreen(),
          },
          initialRoute: AppRoutes.mentorAuth,
        ),
      );
      await tester.pumpAndSettle();

      final navigatorContext = tester.element(find.byType(MentorAuthScreen));
      await Navigator.of(navigatorContext).maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Role Selection'), findsOneWidget);
    },
  );

  testWidgets(
    'MsmeAuthScreen back button falls back to role selection when root route',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.roleSelection: (_) =>
                const Scaffold(body: Center(child: Text('Role Selection'))),
            AppRoutes.msmeAuth: (_) => const MsmeAuthScreen(),
          },
          initialRoute: AppRoutes.msmeAuth,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Role Selection'), findsOneWidget);
    },
  );

  testWidgets(
    'StudentAuthScreen back button falls back to role selection when root route',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.roleSelection: (_) =>
                const Scaffold(body: Center(child: Text('Role Selection'))),
            AppRoutes.studentAuth: (_) => const StudentAuthScreen(),
          },
          initialRoute: AppRoutes.studentAuth,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_arrow_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Role Selection'), findsOneWidget);
    },
  );
}

