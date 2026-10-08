import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/providers.dart';

class _Destination {
  const _Destination(this.icon, this.label);

  final IconData icon;
  final String label;
}

const List<_Destination> _destinations = [
  _Destination(Icons.dashboard_outlined, 'Dashboard'),
  _Destination(Icons.show_chart, 'Riwayat'),
  _Destination(Icons.tune, 'Kontrol'),
  _Destination(Icons.notifications_outlined, 'Notifikasi'),
  _Destination(Icons.settings_outlined, 'Pengaturan'),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    final wide = MediaQuery.sizeOf(context).width >= 700;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (var i = 0; i < _destinations.length; i++)
                  NavigationRailDestination(
                    icon: _railIcon(i, unread),
                    label: Text(_destinations[i].label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: [
          for (var i = 0; i < _destinations.length; i++)
            NavigationDestination(
              icon: _barIcon(i, unread),
              selectedIcon: _barIcon(i, unread),
              label: _destinations[i].label,
            ),
        ],
      ),
    );
  }

  Widget _barIcon(int index, int unread) {
    final icon = Icon(_destinations[index].icon);
    if (index != 3 || unread <= 0) return icon;
    return Badge(label: Text('$unread'), child: icon);
  }

  Widget _railIcon(int index, int unread) {
    final icon = Icon(_destinations[index].icon);
    if (index != 3 || unread <= 0) return icon;
    return Badge(label: Text('$unread'), child: icon);
  }
}
