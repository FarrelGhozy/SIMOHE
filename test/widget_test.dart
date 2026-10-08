import 'package:flutter_test/flutter_test.dart';

import 'package:simohe/app.dart';

void main() {
  testWidgets('Bootstrap SIMOHE tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const SimoheApp());

    expect(find.text('SIMOHE'), findsOneWidget);
  });
}
