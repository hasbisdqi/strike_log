import 'package:flutter_test/flutter_test.dart';
import 'package:strike_log/main.dart';

void main() {
  testWidgets('StrikeLog smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StrikeLogApp(isLoggedIn: false));
    expect(find.text('STRIKE LOG'), findsOneWidget);
  });
}
