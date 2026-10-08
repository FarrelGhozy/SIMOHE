import 'package:flutter_test/flutter_test.dart';

import 'package:simohe/shared/models/command.dart';
import 'package:simohe/shared/models/enums.dart';
import 'package:simohe/shared/models/event_item.dart';
import 'package:simohe/shared/models/live_state.dart';
import 'package:simohe/shared/models/reading.dart';
import 'package:simohe/shared/models/settings.dart';
import 'package:simohe/shared/models/summary.dart';

void main() {
  group('LiveState', () {
    test('parse respons /api/live', () {
      final live = LiveState.fromJson({
        'device': {
          'id': '1',
          'name': 'Reaktor Pupuk 1',
          'location': null,
          'online': true,
          'last_seen_at': '2026-10-08T10:00:05Z',
          'firmware': '0.1.0',
        },
        'state': {
          'temp_c': 31.2,
          'nh3_ppm': 18.42,
          'temp_ok': true,
          'heater_on': true,
          'valve_open': false,
          'mode': 'AUTO',
          'status': 'heating',
          'updated_at': '2026-10-08T10:00:05Z',
        },
        'maturity': {
          'mature': false,
          'progress': 0.35,
          'threshold_ppm': 25.0,
          'hold_minutes': 30,
          'streak_sec': 630,
        },
      });

      expect(live.device.online, isTrue);
      expect(live.device.lastSeenAt, DateTime.utc(2026, 10, 8, 10, 0, 5));
      expect(live.state.mode, HeaterMode.auto);
      expect(live.state.status, DeviceStatus.heating);
      expect(live.state.heaterOn, isTrue);
      expect(live.maturity.progress, 0.35);
    });
  });

  group('ReadingsResponse', () {
    test('memetakan bucket wire "15m"', () {
      final response = ReadingsResponse.fromJson({
        'bucket': '15m',
        'from': '2026-10-08T00:00:00Z',
        'to': '2026-10-08T10:00:00Z',
        'items': [
          {
            'ts': '2026-10-08T09:45:00Z',
            'temp_c': 31.0,
            'nh3_ppm': 17.8,
            'heater_on': true,
            'valve_open': false,
          },
        ],
      });

      expect(response.bucket, ReadingBucket.m15);
      expect(response.items, hasLength(1));
      expect(response.items.first.tempC, 31.0);
    });
  });

  group('SummaryResponse', () {
    test('parse ringkasan min/max/avg', () {
      final summary = SummaryResponse.fromJson({
        'from': '2026-10-08T00:00:00Z',
        'to': '2026-10-08T10:00:00Z',
        'range_count': 40,
        'temp_c': {'min': 29.1, 'max': 35.4, 'avg': 32.2},
        'nh3_ppm': {'min': 5.0, 'max': 26.1, 'avg': 14.3},
      });

      expect(summary.rangeCount, 40);
      expect(summary.tempC.max, 35.4);
      expect(summary.nh3Ppm.avg, 14.3);
    });
  });

  group('EventsResponse', () {
    test('parse event dengan payload dan enum', () {
      final response = EventsResponse.fromJson({
        'items': [
          {
            'id': 7,
            'type': 'mature',
            'severity': 'critical',
            'message': 'Pupuk siap/matang.',
            'payload': {'nh3_ppm': 26.1},
            'is_read': false,
            'created_at': '2026-10-08T10:00:00Z',
          },
        ],
        'unread_count': 1,
      });

      expect(response.items.first.type, EventType.mature);
      expect(response.items.first.severity, EventSeverity.critical);
      expect(response.items.first.isRead, isFalse);
      expect(response.unreadCount, 1);
    });
  });

  group('Command', () {
    test('parse command dengan args kosong', () {
      final command = Command.fromJson({
        'id': 'c1f2',
        'action': 'valve_open',
        'status': 'pending',
        'created_at': '2026-10-08T10:00:00Z',
        'sent_at': null,
        'acked_at': null,
        'expires_at': '2026-10-08T10:01:00Z',
      });

      expect(command.action, CommandAction.valveOpen);
      expect(command.status, CommandStatus.pending);
      expect(command.args, isEmpty);
      expect(command.sentAt, isNull);
    });
  });

  group('SettingsPatch', () {
    test('hanya menyertakan field non-null', () {
      const patch = SettingsPatch(tempMinC: 29.5, matureHoldMin: 45);
      expect(patch.toJson(), {'temp_min_c': 29.5, 'mature_hold_min': 45});
    });

    test('isEmpty bila semua null', () {
      expect(const SettingsPatch().isEmpty, isTrue);
    });
  });
}
