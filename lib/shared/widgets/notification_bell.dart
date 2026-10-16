import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/providers.dart';

/// Ikon lonceng notifikasi untuk AppBar semua tab utama.
///
/// Menampilkan badge jumlah belum dibaca. Ketuk → halaman daftar
/// notifikasi (`/notifications` di luar shell, ada tombol kembali).
/// Ketuk item di daftar → bottom sheet detail (perilaku existing).
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return IconButton(
      tooltip: 'Notifikasi',
      onPressed: () => context.push('/notifications'),
      icon: unread > 0
          ? Badge(label: Text('$unread'), child: const Icon(Icons.notifications_outlined))
          : const Icon(Icons.notifications_outlined),
    );
  }
}
