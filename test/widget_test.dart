import 'package:flutter_test/flutter_test.dart';
import 'package:strike_log/main.dart';
import 'package:strike_log/screens/login_screen.dart';

void main() {
  testWidgets('App renders login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StrikeLogApp(homeOverride: LoginScreen()));
    expect(find.text('Strike Log'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
