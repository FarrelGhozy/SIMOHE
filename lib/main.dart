import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/providers.dart';
import 'core/router/app_router.dart';
import 'core/utils/formatters.dart';
import 'features/notifications/data/local_notification_service.dart';
import 'features/notifications/domain/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Formatters.initialize();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
  final preferences = await SharedPreferences.getInstance();

  final localNotifications = LocalNotificationService();
  localNotifications.onSelect = (eventId) =>
      appRouter.go('/notifications?id=$eventId');
  await localNotifications.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        localNotificationServiceProvider.overrideWithValue(localNotifications),
      ],
      child: const SimoheApp(),
    ),
  );
}
