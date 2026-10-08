import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

/// Root widget aplikasi SIMOHE.
///
/// Ini masih berupa fondasi. Routing (go_router) dan state management
/// (Riverpod) akan dipasang pada fase berikutnya sesuai `TODO.md`.
class SimoheApp extends StatelessWidget {
  const SimoheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMOHE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _BootstrapPage(),
    );
  }
}

class _BootstrapPage extends StatelessWidget {
  const _BootstrapPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'SIMOHE',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Fondasi proyek — lihat docs/ dan TODO.md'),
          ],
        ),
      ),
    );
  }
}
