import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/brand_icon.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../dashboard/domain/providers.dart';
import '../../../settings/domain/providers.dart';
import '../../domain/providers.dart';

class ValveControl extends ConsumerWidget {
  const ValveControl({super.key});

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    CommandAction action,
    int maxOpen,
    bool open,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(open ? 'Tutup katup?' : 'Buka katup?'),
        content: Text(
          open
              ? 'Katup akan ditutup dan aliran dihentikan.'
              : 'Katup akan dibuka. Safety akan menutup otomatis setelah '
                  '$maxOpen menit. Pastikan penampung sudah siap.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref.read(commandsProvider.notifier).send(action);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Perintah "${result.action.label}" dikirim (${result.status.label}).',
          ),
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal: ${error.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveProvider).asData?.value;
    final maxOpen =
        ref.watch(settingsProvider).asData?.value.valveMaxOpenMin ?? 10;
    final open = live?.state.valveOpen ?? false;
    final ready = live != null;

    return SectionCard(
      title: 'Katup solenoid',
      leading: const BrandIcon(asset: BrandAssets.iconKatup, size: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: open ? 'Terbuka' : 'Tertutup',
                tone: open ? StatusTone.info : StatusTone.offline,
                icon: open ? Icons.water_drop : Icons.invert_colors_off,
              ),
              const Spacer(),
              Text(
                'Safety auto-close: $maxOpen menit',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: ready
                ? () => _run(
                      context,
                      ref,
                      open ? CommandAction.valveClose : CommandAction.valveOpen,
                      maxOpen,
                      open,
                    )
                : null,
            icon: Icon(open ? Icons.invert_colors_off : Icons.water_drop),
            label: Text(open ? 'Tutup katup' : 'Buka katup'),
          ),
        ],
      ),
    );
  }
}
