import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/refresh_settings.dart';
import '../../../../shared/widgets/section_card.dart';

/// Pengaturan interval ambil data aplikasi (lokal per perangkat).
///
/// Berbeda dari "Interval" server: ini murni frekuensi polling saat app dibuka.
class AppRefreshCard extends ConsumerStatefulWidget {
  const AppRefreshCard({super.key});

  @override
  ConsumerState<AppRefreshCard> createState() => _AppRefreshCardState();
}

class _AppRefreshCardState extends ConsumerState<AppRefreshCard> {
  late int _liveSec;
  late int _eventsSec;
  late int _commandSec;
  late int _trendSec;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(refreshSettingsProvider);
    _liveSec = settings.liveSec;
    _eventsSec = settings.eventsSec;
    _commandSec = settings.commandSec;
    _trendSec = settings.trendSec;
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(refreshSettingsProvider.notifier).save(
          AppRefreshSettings(
            liveSec: _liveSec,
            eventsSec: _eventsSec,
            commandSec: _commandSec,
            trendSec: _trendSec,
          ),
        );
    messenger.showSnackBar(
      const SnackBar(content: Text('Interval aplikasi disimpan (lokal).')),
    );
  }

  Widget _dropdown(
    String label,
    int value,
    List<int> options,
    String Function(int) labelFor,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(labelFor(option))),
        ],
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Aplikasi — ambil data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frekuensi aplikasi menarik data saat dibuka. Berbeda dari '
            '"Interval" server di bawah (yang mengatur cron/device).',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _dropdown(
            'Data live (suhu/NH3)',
            _liveSec,
            RefreshPresets.live,
            (v) => '$v detik',
            (v) => setState(() => _liveSec = v),
          ),
          _dropdown(
            'Notifikasi',
            _eventsSec,
            RefreshPresets.events,
            (v) => '$v detik',
            (v) => setState(() => _eventsSec = v),
          ),
          _dropdown(
            'Status perintah',
            _commandSec,
            RefreshPresets.command,
            (v) => '$v detik',
            (v) => setState(() => _commandSec = v),
          ),
          _dropdown(
            'Tren dashboard',
            _trendSec,
            RefreshPresets.trend,
            (v) => v < 60 ? '$v detik' : '${v ~/ 60} menit',
            (v) => setState(() => _trendSec = v),
          ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Simpan interval aplikasi'),
          ),
        ],
      ),
    );
  }
}
