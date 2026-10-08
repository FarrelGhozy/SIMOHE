import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/command.dart';
import '../../../shared/models/enums.dart';
import '../data/control_repository.dart';

final controlRepositoryProvider = Provider<ControlRepository>(
  (ref) => ControlRepository(ref.watch(apiClientProvider)),
);

class CommandsNotifier extends AsyncNotifier<List<Command>> {
  @override
  Future<List<Command>> build() =>
      ref.read(controlRepositoryProvider).getCommands();

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
