import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/review_summary.dart';
import '../../domain/entities/search_filters.dart';
import '../cubit/search_cubit.dart';

/// One removable chip per active filter.
///
/// Giving every choice a visible, dismissable token means the user can always
/// see why a list is short and undo one decision without opening the rail.
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    required this.filters,
    required this.cubit,
    required this.currency,
    super.key,
  });

  final SearchFilters filters;
  final SearchCubit cubit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[
      if (filters.priceRange case final range?)
        _Chip(
          label: '${Formatters.money(range.min, currency)} — '
              '${Formatters.money(range.max, currency)}',
          onRemove: cubit.clearPriceRange,
        ),
      if (filters.minReviewScore case final score?)
        _Chip(
          label: '${ScoreBand.fromScore(score).label}: '
              '${score.toStringAsFixed(0)}+',
          onRemove: () => cubit.changeMinReviewScore(null),
        ),
      if (filters.maxDistanceFromCentreKm case final km?)
        _Chip(
          label: 'Under ${km.round()} km from centre',
          onRemove: () => cubit.changeMaxDistance(null),
        ),
      for (final filter in filters.popularFilters)
        _Chip(
          label: filter.label,
          onRemove: () => cubit.togglePopularFilter(filter),
        ),
      for (final type in filters.propertyTypes)
        _Chip(
          label: type.pluralLabel,
          onRemove: () => cubit.togglePropertyType(type),
        ),
      for (final stars in filters.starRatings)
        _Chip(
          label: '$stars ${stars == 1 ? 'star' : 'stars'}',
          onRemove: () => cubit.toggleStarRating(stars),
        ),
      for (final amenity in filters.amenities)
        _Chip(
          label: amenity.label,
          onRemove: () => cubit.toggleAmenity(amenity),
        ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        TextButton(
          onPressed: cubit.clearFilters,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),
          child: const Text('Clear all'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close_rounded, size: 15),
      deleteButtonTooltipMessage: 'Remove this filter',
      backgroundColor: AppColors.blueSoft,
      side: const BorderSide(color: AppColors.blueBorder),
      labelStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: AppColors.blueHover),
      visualDensity: VisualDensity.compact,
    );
  }
}
