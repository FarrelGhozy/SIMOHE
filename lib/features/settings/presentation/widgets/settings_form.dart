import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/models/settings.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../domain/providers.dart';

class SettingsForm extends ConsumerStatefulWidget {
  const SettingsForm({super.key, required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<SettingsForm> {
  late final Map<String, TextEditingController> _controllers;
  late bool _heaterAuto;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _controllers = {
      'history': TextEditingController(text: '${s.historyIntervalMin}'),
      'ingest': TextEditingController(text: '${s.ingestIntervalSec}'),
      'tempMin': TextEditingController(text: '${s.tempMinC}'),
      'tempMax': TextEditingController(text: '${s.tempMaxC}'),
      'hysteresis': TextEditingController(text: '${s.tempHysteresisC}'),
      'nh3': TextEditingController(text: '${s.nh3MaturePpm}'),
      'hold': TextEditingController(text: '${s.matureHoldMin}'),
      'heaterMax': TextEditingController(text: '${s.heaterMaxOnMin}'),
      'valveMax': TextEditingController(text: '${s.valveMaxOpenMin}'),
      'ttl': TextEditingController(text: '${s.commandTtlSec}'),
      'retention': TextEditingController(text: '${s.rawRetentionDays}'),
    };
    _heaterAuto = s.heaterAuto;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int? _parseInt(String key) => int.tryParse(_controllers[key]!.text.trim());

  double? _parseDouble(String key) =>
      double.tryParse(_controllers[key]!.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final patch = SettingsPatch(
      historyIntervalMin: _parseInt('history'),
      ingestIntervalSec: _parseInt('ingest'),
      tempMinC: _parseDouble('tempMin'),
      tempMaxC: _parseDouble('tempMax'),
      tempHysteresisC: _parseDouble('hysteresis'),
      nh3MaturePpm: _parseDouble('nh3'),
      matureHoldMin: _parseInt('hold'),
      heaterAuto: _heaterAuto,
      heaterMaxOnMin: _parseInt('heaterMax'),
      valveMaxOpenMin: _parseInt('valveMax'),
      commandTtlSec: _parseInt('ttl'),
      rawRetentionDays: _parseInt('retention'),
    );

    if (patch.toJson().length < _controllers.length + 1) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Periksa kembali nilai yang diisi.')),
      );
      return;
    }

    try {
      await ref.read(settingsProvider.notifier).save(patch);
      messenger.showSnackBar(
        const SnackBar(content: Text('Pengaturan disimpan.')),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${error.message}')),
      );
    }
  }

  Widget _numberField(String key, String label, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Interval',
          child: Column(
            children: [
              _numberField('history', 'Interval sampling', 'menit'),
              _numberField('ingest', 'Interval ingest', 'detik'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Ambang suhu',
          child: Column(
            children: [
              _numberField('tempMin', 'Suhu minimum', '°C'),
              _numberField('tempMax', 'Suhu maksimum (safety)', '°C'),
              _numberField('hysteresis', 'Hysteresis', '°C'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Kematangan',
          child: Column(
            children: [
              _numberField('nh3', 'Ambang NH3 matang', 'ppm'),
              _numberField('hold', 'Durasi tahan', 'menit'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Heater & katup',
          child: Column(
            children: [
              _numberField('heaterMax', 'Heater maks menyala', 'menit'),
              _numberField('valveMax', 'Katup maks terbuka', 'menit'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Perintah & retensi',
          child: Column(
            children: [
              _numberField('ttl', 'TTL perintah', 'detik'),
              _numberField('retention', 'Retensi telemetri raw', 'hari'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Mode heater',
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Kontrol otomatis berbasis suhu'),
            value: _heaterAuto,
            onChanged: (value) => setState(() => _heaterAuto = value),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Server',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Base URL', style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              SelectableText(AppConfig.apiBaseUrl),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Simpan'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
