import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../shared/models/enums.dart';
import '../../../shared/models/event_item.dart';

/// Pembungkus `flutter_local_notifications` (Android). Di web/no-op agar
/// aman: badge in-app tetap tersedia.
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'simohe_events';
  static const String _channelName = 'Notifikasi SIMOHE';
  static const String _channelDescription =
      'Peringatan suhu, kematangan, safety, dan status perangkat';

  bool _available = false;

  /// Dipanggil saat pengguna menekan notifikasi; berisi `events.id`.
  void Function(int eventId)? onSelect;

  bool get isAvailable => _available;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final id = int.tryParse(response.payload ?? '');
          if (id != null) onSelect?.call(id);
        },
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _available = true;
    } on Object {
      _available = false;
    }
  }

  Future<void> showEvent(EventItem event) async {
    if (kIsWeb || !_available) return;
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      await _plugin.show(
        id: event.id,
        title: _titleFor(event.type),
        body: event.message,
        notificationDetails: details,
        payload: '${event.id}',
      );
    } on Object {
      // Abaikan kegagalan notifikasi sistem agar alur data tidak terganggu.
    }
  }

  String _titleFor(EventType type) => switch (type) {
        EventType.mature => 'Pupuk siap / matang',
        EventType.tempLow => 'Suhu rendah',
        EventType.tempHigh => 'Suhu tinggi!',
        EventType.heaterOn => 'Heater menyala',
        EventType.heaterOff => 'Heater mati',
        EventType.valveOpen => 'Katup dibuka',
        EventType.valveClose => 'Katup ditutup',
        EventType.deviceOffline => 'Perangkat offline',
        EventType.deviceOnline => 'Perangkat online',
        EventType.safetyCutoff => 'Safety cutoff!',
      };

  /// Notifikasi lokal bebas (bukan dari tabel `events`): dipakai peringatan
  /// matang berbasis stabilitas NH3 yang dihitung di HP.
  Future<void> showMessage({
    required String title,
    required String body,
    int id = 999001,
  }) async {
    if (kIsWeb || !_available) return;
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: 'stable',
      );
    } on Object {
      // Abaikan kegagalan notifikasi sistem agar alur data tidak terganggu.
    }
  }
}
