import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/search_filters.dart';

/// Nightly-budget slider.
///
/// Dragging is local state and only reports upwards once the gesture ends, so
/// a drag across the track triggers one search rather than one per frame.
class PriceRangeFilter extends StatefulWidget {
  const PriceRangeFilter({
    required this.bounds,
    required this.selected,
    required this.currency,
    required this.onChanged,
    super.key,
  });

  /// The full span available for this destination.
  final PriceRange bounds;

  /// The user's current window, or null when unconstrained.
  final PriceRange? selected;

  final String currency;
  final ValueChanged<PriceRange> onChanged;

  @override
  State<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends State<PriceRangeFilter> {
  RangeValues? _dragging;

  RangeValues get _values {
    if (_dragging != null) return _dragging!;
    final selected = widget.selected;
    return RangeValues(
      selected?.min ?? widget.bounds.min,
      selected?.max ?? widget.bounds.max,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bounds = widget.bounds;

    // A single-price destination has nothing to slide between.
    if (bounds.max <= bounds.min) return const SizedBox.shrink();

    final values = _values;
    final divisions = ((bounds.max - bounds.min) / 50).round().clamp(1, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${Formatters.money(values.start, widget.currency)} — '
          '${Formatters.money(values.end, widget.currency)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        RangeSlider(
          values: values,
          min: bounds.min,
          max: bounds.max,
          divisions: divisions,
          labels: RangeLabels(
            Formatters.money(values.start, widget.currency),
            Formatters.money(values.end, widget.currency),
          ),
          onChanged: (next) => setState(() => _dragging = next),
          onChangeEnd: (next) {
            setState(() => _dragging = null);
            widget.onChanged(PriceRange(min: next.start, max: next.end));
          },
        ),
      ],
    );
  }
}
