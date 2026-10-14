import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/command.dart';
import '../../../shared/models/enums.dart';
import '../data/control_repository.dart';

final controlRepositoryProvider = Provider<ControlRepository>(
  (ref) => ControlRepository(ref.watch(supabaseClientProvider)),
);

class CommandsNotifier extends AsyncNotifier<List<Command>> {
  Timer? _timer;
  RealtimeChannel? _channel;

  @override
  Future<List<Command>> build() async {
    _timer = Timer.periodic(
      const Duration(seconds: AppConfig.commandPollIntervalSeconds),
      (_) => _poll(),
    );
    ref.onDispose(() => _timer?.cancel());
    _subscribeRealtime();
    return ref.read(controlRepositoryProvider).getCommands();
  }

  /// Realtime sebagai pelengkap polling; diabaikan bila Supabase belum
  /// siap (mis. unit test) — polling tetap jalan sebagai fallback.
  void _subscribeRealtime() {
    try {
      final client = ref.read(supabaseClientProvider);
      _channel = client.channel('commands-feed')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'commands',
          callback: (_) => _poll(),
        )
        ..subscribe();
      ref.onDispose(() {
        final channel = _channel;
        if (channel != null) unawaited(client.removeChannel(channel));
      });
    } on Object {
      _channel = null;
    }
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
