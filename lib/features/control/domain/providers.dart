import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/command.dart';
import '../../../shared/models/enums.dart';
import '../data/control_repository.dart';

final controlRepositoryProvider = Provider<ControlRepository>(
  (ref) => ControlRepository(ref.watch(apiClientProvider)),
);

class CommandsNotifier extends AsyncNotifier<List<Command>> {
  Timer? _timer;

  @override
  Future<List<Command>> build() async {
    _timer = Timer.periodic(
      const Duration(seconds: AppConfig.commandPollIntervalSeconds),
      (_) => _poll(),
    );
    ref.onDispose(() => _timer?.cancel());
    return ref.read(controlRepositoryProvider).getCommands();
  }

  Future<void> _poll() async {
    try {
      state = AsyncData(await ref.read(controlRepositoryProvider).getCommands());
    } on Object {
      // Pertahankan daftar terakhir saat polling gagal.
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(controlRepositoryProvider).getCommands(),
    );
  }

  Future<CreateCommandResult> send(
    CommandAction action, {
    int? durationMin,
  }) async {
    final result = await ref
        .read(controlRepositoryProvider)
        .sendCommand(action, durationMin: durationMin);
    await refresh();
    return result;
  }

  Future<void> cancel(String id) async {
    await ref.read(controlRepositoryProvider).cancelCommand(id);
    await refresh();
  }
}

final commandsProvider =
    AsyncNotifierProvider<CommandsNotifier, List<Command>>(
  CommandsNotifier.new,
);
