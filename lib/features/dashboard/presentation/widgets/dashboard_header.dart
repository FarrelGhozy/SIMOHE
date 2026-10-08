import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/live_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/tone.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.live});

  final LiveState live;

  @override
  Widget build(BuildContext context) {
    final device = live.device;
    final state = live.state;
    return SectionCard(
      title: device.name,
      trailing: IconButton(
        tooltip: 'Info perangkat',
        icon: const Icon(Icons.info_outline),
        onPressed: () => context.push('/device'),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          StatusBadge(
            label: device.online ? 'Online' : 'Offline',
            tone: device.online ? StatusTone.normal : StatusTone.offline,
            icon: device.online ? Icons.wifi : Icons.wifi_off,
          ),
          StatusBadge(
            label: state.status.label,
            tone: toneForDeviceStatus(state.status),
            icon: Icons.eco,
          ),
          if (!state.tempOk)
            const StatusBadge(
              label: 'Sensor suhu error',
              tone: StatusTone.danger,
              icon: Icons.warning_amber,
            ),
          Text('Terakhir: ${Formatters.relative(device.lastSeenAt)}'),
        ],
      ),
    );
  }
}
