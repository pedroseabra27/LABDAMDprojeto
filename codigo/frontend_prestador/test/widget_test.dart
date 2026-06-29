import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_prestador/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const PrestadorApp());
  });
}
