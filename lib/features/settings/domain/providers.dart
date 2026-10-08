import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/settings.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(apiClientProvider)),
);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() =>
      ref.read(settingsRepositoryProvider).getSettings();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).getSettings(),
    );
  }

  Future<void> save(SettingsPatch patch) async {
    final updated =
        await ref.read(settingsRepositoryProvider).updateSettings(patch);
    state = AsyncData(updated);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
