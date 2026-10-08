import 'package:flutter/material.dart';

/// Tema global aplikasi SIMOHE.
///
/// Warna dasar hijau (pertanian) akan disesuaikan pada fase desain UI.
class AppTheme {
  const AppTheme._();

  static const Color _seedColor = Color(0xFF2E7D32);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
