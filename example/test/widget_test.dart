import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('App launches and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const TablerIconsApp());
    expect(find.text('Tabler Icons'), findsOneWidget);
  });
}
