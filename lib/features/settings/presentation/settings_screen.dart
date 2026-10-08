import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/settings.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../domain/providers.dart';
import 'widgets/settings_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        actions: [
          IconButton(
            tooltip: 'Info perangkat',
            icon: const Icon(Icons.memory),
            onPressed: () => context.push('/device'),
          ),
        ],
      ),
      body: AsyncValueView<AppSettings>(
        value: settings,
        onRetry: () => ref.read(settingsProvider.notifier).refresh(),
        builder: (data) => SettingsForm(settings: data),
      ),
    );
  }
}
