import 'package:flutter/material.dart';

/// Segmented control konsisten SIMOHE tanpa ikon ceklis.
///
/// `SegmentedButton` Material 3 secara default menampilkan ikon `check`
/// pada segmen terpilih (`showSelectedIcon: true`) yang menggeser layout
/// dan tidak diinginkan di aplikasi ini. Widget ini mengunci default
/// `showSelectedIcon: false` sehingga status terpilih hanya ditandai
/// lewat warna background/foreground dari tema.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.expanded = false,
    this.style,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Bila true, segmen membentang memenuhi lebar parent
  /// (via `expandedInsets: EdgeInsets.zero`).
  /// Bungkus dengan `SizedBox(width: double.infinity)` di parent
  /// ber-alignment `start` agar benar-benar penuh.
  final bool expanded;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      showSelectedIcon: false,
      expandedInsets: expanded ? EdgeInsets.zero : null,
      style: style,
    );
  }
}
