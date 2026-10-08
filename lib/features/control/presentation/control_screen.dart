import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/command_history.dart';
import 'widgets/heater_control.dart';
import 'widgets/valve_control.dart';

class ControlScreen extends ConsumerWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontrol')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ValveControl(),
          SizedBox(height: 12),
          HeaterControl(),
          SizedBox(height: 12),
          CommandHistory(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
