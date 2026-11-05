import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/main.dart';

void main() {
  testWidgets('App smoke test - boots correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('TalentSync'), findsOneWidget);
  });
}
