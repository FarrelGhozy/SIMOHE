import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simohe/core/theme/app_theme.dart';
import 'package:simohe/shared/widgets/app_segmented.dart';

void main() {
  testWidgets('AppSegmented tidak menampilkan ikon ceklis', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppSegmented<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('AUTO')),
              ButtonSegment(value: 1, label: Text('ON')),
              ButtonSegment(value: 2, label: Text('OFF')),
            ],
            selected: const {0},
            onSelectionChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('AUTO'), findsOneWidget);
    expect(find.text('ON'), findsOneWidget);
    expect(find.text('OFF'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('AppSegmented expanded tetap tanpa ceklis', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: double.infinity,
            child: AppSegmented<int>(
              expanded: true,
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('AUTO'),
                  icon: Icon(Icons.autorenew),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('ON'),
                  icon: Icon(Icons.power_settings_new),
                ),
              ],
              selected: const {1},
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.autorenew), findsOneWidget);
    expect(find.byIcon(Icons.power_settings_new), findsOneWidget);
  });
}
