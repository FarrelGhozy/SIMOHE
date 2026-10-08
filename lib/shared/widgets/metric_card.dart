import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'brand_icon.dart';
import 'status_badge.dart';

/// Kartu metrik: menampilkan satu nilai sensor/aktuator secara menonjol.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.brandIcon,
    this.tone = StatusTone.normal,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String value;
  final String? unit;
  final IconData? icon;
  final String? brandIcon;
  final StatusTone tone;
  final String? subtitle;
  final Widget? trailing;

  Color _accent(BuildContext context) {
    final status = AppStatusColors.of(context);
    return switch (tone) {
      StatusTone.normal => status.normal,
      StatusTone.warning => status.warning,
      StatusTone.danger => status.danger,
      StatusTone.offline => status.offline,
      StatusTone.info => Theme.of(context).colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accent(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (brandIcon != null) ...[
                  BrandIcon(
                    asset: brandIcon!,
                    size: 32,
                    semanticLabel: title,
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon, size: 18, color: accent),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(unit!, style: theme.textTheme.titleMedium),
                  ],
                ],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
