import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simohe/core/theme/app_theme.dart';
import 'package:simohe/shared/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge menampilkan label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: StatusBadge(label: 'Online', tone: StatusTone.normal),
        ),
      ),
    );

    expect(find.text('Online'), findsOneWidget);
  });
}
