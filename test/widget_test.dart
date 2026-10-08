import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simohe/app.dart';
import 'package:simohe/core/network/providers.dart';
import 'package:simohe/features/notifications/domain/providers.dart';
import 'package:simohe/shared/models/event_item.dart';

class _StubEventsNotifier extends EventsNotifier {
  @override
  Future<EventsResponse> build() async => const EventsResponse();
}

void main() {
  testWidgets('Shell menampilkan navigasi utama', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          eventsProvider.overrideWith(_StubEventsNotifier.new),
        ],
        child: const SimoheApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Riwayat'), findsOneWidget);
  });
}
