import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_segmented.dart';
import '../../domain/providers.dart';

class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HistoryRange selected;
  final ValueChanged<HistoryRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AppSegmented<HistoryRange>(
            segments: [
              for (final range in HistoryRange.values)
                ButtonSegment(value: range, label: Text(range.label)),
            ],
            selected: {selected},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ),
      ),
    );
  }
}
