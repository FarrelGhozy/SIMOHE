import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Warna status global: normal, peringatan, bahaya, offline.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.normal,
    required this.warning,
    required this.danger,
    required this.offline,
  });

  final Color normal;
  final Color warning;
  final Color danger;
  final Color offline;

  static AppStatusColors of(BuildContext context) =>
      Theme.of(context).extension<AppStatusColors>()!;

  @override
  AppStatusColors copyWith({
    Color? normal,
    Color? warning,
    Color? danger,
    Color? offline,
  }) {
    return AppStatusColors(
      normal: normal ?? this.normal,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      offline: offline ?? this.offline,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      normal: Color.lerp(normal, other.normal, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static const Color _seedColor = BrandColors.primary;

  static const AppStatusColors _statusLight = AppStatusColors(
    normal: BrandColors.accent,
    warning: Color(0xFFEF6C00),
    danger: Color(0xFFC62828),
    offline: Color(0xFF757575),
  );

  static const AppStatusColors _statusDark = AppStatusColors(
    normal: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    danger: Color(0xFFEF9A9A),
    offline: Color(0xFF9E9E9E),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
        extensions: const <ThemeExtension<dynamic>>[_statusLight],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        extensions: const <ThemeExtension<dynamic>>[_statusDark],
      );
}
