import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simohe/core/network/providers.dart';
import 'package:simohe/core/theme/app_theme.dart';
import 'package:simohe/core/utils/formatters.dart';
import 'package:simohe/features/notifications/domain/providers.dart';
import 'package:simohe/features/notifications/presentation/notifications_screen.dart';
import 'package:simohe/shared/models/enums.dart';
import 'package:simohe/shared/models/event_item.dart';

final _matureEvent = EventItem(
  id: 42,
  type: EventType.mature,
  severity: EventSeverity.info,
  message: 'Pupuk siap/matang. Buka katup dari aplikasi.',
  payload: const {'nh3_ppm': 26.1, 'threshold_ppm': 25.0},
  isRead: false,
  createdAt: DateTime.utc(2026, 10, 8, 10),
);

class _StubEventsNotifier extends EventsNotifier {
  _StubEventsNotifier(this.response);

  final EventsResponse response;

  @override
  Future<EventsResponse> build() async => response;

  @override
  Future<void> markRead(int id) async {}

  @override
  Future<void> markAllRead() async {}
}

void main() {
  testWidgets('tap notifikasi membuka detail + info ditandai dibaca',
      (tester) async {
    await Formatters.initialize();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          eventsProvider.overrideWith(
            () => _StubEventsNotifier(
              EventsResponse(items: [_matureEvent], unreadCount: 1),
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_matureEvent.message), findsOneWidget);

    await tester.tap(find.text(_matureEvent.message));
    await tester.pumpAndSettle();

    expect(find.text('Ditandai dibaca'), findsOneWidget);
    expect(find.text('Buka Kontrol katup'), findsOneWidget);
    expect(find.text('nh3 ppm: 26.1'), findsOneWidget);
  });

  testWidgets('tap notifikasi memberi Batal pada tandai semua', (tester) async {
    await Formatters.initialize();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          eventsProvider.overrideWith(
            () => _StubEventsNotifier(
              EventsResponse(items: [_matureEvent], unreadCount: 1),
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.done_all));
    await tester.pumpAndSettle();

    expect(find.text('Tandai semua dibaca?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Tandai semua dibaca?'), findsNothing);
  });
}
