import 'package:flutter/material.dart';

/// Palet brand SIMOHE. Lihat `docs/15-BRANDING.md`.
class BrandColors {
  const BrandColors._();

  static const Color primary = Color(0xFF084E34);
  static const Color primaryDark = Color(0xFF063A26);
  static const Color accent = Color(0xFF3B9640);
  static const Color sage = Color(0xFF97B4A9);
  static const Color sageDark = Color(0xFF2D6953);

  static const Color surface = Color(0xFFFDFDFD);
  static const Color surfaceVariant = Color(0xFFEBEEF0);
  static const Color border = Color(0xFFD1D7DC);
  static const Color ink = Color(0xFF23292B);
}

/// Nama aset brand agar tidak tersebar sebagai string literal.
class BrandAssets {
  const BrandAssets._();

  static const String emblem = 'assets/branding/emblem.png';
  static const String logoMonochrome = 'assets/branding/logo_monochrome.png';
}
