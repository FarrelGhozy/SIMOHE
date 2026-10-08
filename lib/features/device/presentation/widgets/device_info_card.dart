import 'package:flutter/material.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/device_detail.dart';
import '../../../../shared/widgets/brand_icon.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';

class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({super.key, required this.device});

  final DeviceDetail device;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: device.name,
      leading: const BrandIcon(asset: BrandAssets.iconKoneksi, size: 32),
      trailing: StatusBadge(
        label: device.isOnline ? 'Online' : 'Offline',
        tone: device.isOnline ? StatusTone.normal : StatusTone.offline,
        icon: device.isOnline ? Icons.wifi : Icons.wifi_off,
      ),
      child: Column(
        children: [
          _InfoRow(label: 'ID', value: device.id),
          _InfoRow(label: 'Lokasi', value: device.location ?? '-'),
          _InfoRow(label: 'Firmware', value: device.firmware ?? '-'),
          _InfoRow(
            label: 'Terakhir terlihat',
            value: device.lastSeenAt == null
                ? '-'
                : '${Formatters.relative(device.lastSeenAt)} '
                    '(${Formatters.dateTime(device.lastSeenAt)})',
          ),
          _InfoRow(
            label: 'Terdaftar',
            value: Formatters.dateTime(device.createdAt),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
