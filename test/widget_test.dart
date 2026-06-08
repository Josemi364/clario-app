import 'package:flutter_test/flutter_test.dart';
import 'package:clario_app/main.dart';

void main() {
  testWidgets('Clario app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClarioApp());
    expect(find.text('Clario'), findsOneWidget);
  });
}