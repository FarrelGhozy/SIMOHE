import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'offline_cache.dart';

/// Di-override saat bootstrap dengan instance [SharedPreferences].
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider belum di-override'),
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final offlineCacheProvider = Provider<OfflineCache>(
  (ref) => OfflineCache(ref.watch(sharedPreferencesProvider)),
);
