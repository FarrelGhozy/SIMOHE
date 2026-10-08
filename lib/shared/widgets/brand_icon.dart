import 'package:flutter/material.dart';

/// Menampilkan aset brand (logo/ikon fitur) dengan fallback ke ikon Material.
class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.fallbackIcon,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final IconData? fallbackIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        if (fallbackIcon == null) return SizedBox(width: size, height: size);
        return Icon(fallbackIcon, size: size);
      },
    );
  }
}
