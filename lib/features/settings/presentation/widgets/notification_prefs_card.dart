import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/notification_prefs.dart';
import '../../../../shared/widgets/section_card.dart';

/// Preferensi notifikasi sistem (lokal per perangkat).
class NotificationPrefsCard extends ConsumerStatefulWidget {
  const NotificationPrefsCard({super.key});

  @override
  ConsumerState<NotificationPrefsCard> createState() =>
      _NotificationPrefsCardState();
}

class _NotificationPrefsCardState
    extends ConsumerState<NotificationPrefsCard> {
  late bool _enabled;
  late bool _warnAndAboveOnly;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(notificationPrefsProvider);
    _enabled = prefs.enabled;
    _warnAndAboveOnly = prefs.warnAndAboveOnly;
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(notificationPrefsProvider.notifier).save(
          NotificationPrefs(
            enabled: _enabled,
            warnAndAboveOnly: _warnAndAboveOnly,
          ),
        );
    messenger.showSnackBar(
      const SnackBar(content: Text('Preferensi notifikasi disimpan (lokal).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Notifikasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notifikasi sistem'),
            subtitle: const Text('Tampilkan notifikasi saat aplikasi berjalan.'),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hanya peringatan & bahaya'),
            subtitle: const Text('Lewati notifikasi info (heater/katup).'),
            value: _warnAndAboveOnly,
            onChanged: _enabled
                ? (value) => setState(() => _warnAndAboveOnly = value)
                : null,
          ),
          Text(
            'Notifikasi hanya muncul saat aplikasi aktif. Untuk notifikasi '
            'saat aplikasi tertutup diperlukan FCM (belum tersedia).',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Simpan preferensi notifikasi'),
          ),
        ],
      ),
    );
  }
}
