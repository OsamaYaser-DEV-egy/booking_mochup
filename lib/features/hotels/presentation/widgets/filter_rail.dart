import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/property_type.dart';
import '../../domain/entities/review_summary.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../cubit/search_cubit.dart';
import 'filter_group.dart';
import 'map_teaser.dart';
import 'price_range_filter.dart';

/// Every narrowing control for the current result set.
///
/// The rail is a pure function of `filters` and `facets` and reports changes
/// through [SearchCubit]; it holds no state of its own, which is why the same
/// widget serves both the desktop rail and the mobile bottom sheet.
class FilterRail extends StatelessWidget {
  const FilterRail({
    required this.filters,
    required this.facets,
    required this.cubit,
    required this.currency,
    super.key,
    this.showMapTeaser = true,
  });

  final SearchFilters filters;
  final FilterFacets facets;
  final SearchCubit cubit;
  final String currency;
  final bool showMapTeaser;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMapTeaser) ...[
          const MapTeaser(),
          const SizedBox(height: AppSpacing.lg),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter by',
                        style: textTheme.titleLarge,
                      ),
                    ),
                    if (filters.isNotEmpty)
                      TextButton(
                        onPressed: cubit.clearFilters,
                        child: const Text('Clear all'),
                      ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.lg),
              _budgetGroup(),
              const Divider(height: 1),
              _popularGroup(),
              const Divider(height: 1),
              _reviewScoreGroup(),
              const Divider(height: 1),
              _propertyTypeGroup(),
              const Divider(height: 1),
              _starRatingGroup(),
              const Divider(height: 1),
              _facilitiesGroup(),
              const Divider(height: 1),
              _distanceGroup(),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------- groups

  Widget _budgetGroup() {
    return FilterGroup(
      title: 'Your budget (per night)',
      trailing: filters.priceRange == null
          ? null
          : _ResetLink(onPressed: cubit.clearPriceRange),
      children: [
        PriceRangeFilter(
          bounds: facets.priceBounds,
          selected: filters.priceRange,
          currency: currency,
          onChanged: cubit.changePriceRange,
        ),
      ],
    );
  }

  Widget _popularGroup() {
    final available = PopularFilter.values
        .where((filter) => facets.popularFilterCounts.containsKey(filter))
        .toList(growable: false);

    if (available.isEmpty) return const SizedBox.shrink();

    return FilterGroup(
      title: 'Popular filters',
      children: [
        for (final filter in available)
          FilterCheckTile(
            label: filter.label,
            count: facets.popularFilterCounts[filter],
            isSelected: filters.popularFilters.contains(filter),
            onChanged: (_) => cubit.togglePopularFilter(filter),
          ),
      ],
    );
  }

  Widget _reviewScoreGroup() {
    if (facets.reviewScoreCounts.isEmpty) return const SizedBox.shrink();

    final thresholds = facets.reviewScoreCounts.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return FilterGroup(
      title: 'Review score',
      trailing: filters.minReviewScore == null
          ? null
          : _ResetLink(onPressed: () => cubit.changeMinReviewScore(null)),
      children: [
        for (final threshold in thresholds)
          FilterCheckTile(
            label: '${ScoreBand.fromScore(threshold.toDouble()).label}: '
                '$threshold+',
            count: facets.reviewScoreCounts[threshold],
            isSelected: filters.minReviewScore == threshold.toDouble(),
            onChanged: (isSelected) => cubit.changeMinReviewScore(
              isSelected ? threshold.toDouble() : null,
            ),
          ),
      ],
    );
  }

  Widget _propertyTypeGroup() {
    if (facets.propertyTypeCounts.isEmpty) return const SizedBox.shrink();

    final types = PropertyType.values
        .where((type) => facets.propertyTypeCounts.containsKey(type))
        .toList(growable: false);

    return FilterGroup(
      title: 'Property type',
      children: [
        for (final type in types)
          FilterCheckTile(
            label: type.pluralLabel,
            count: facets.propertyTypeCounts[type],
            isSelected: filters.propertyTypes.contains(type),
            onChanged: (_) => cubit.togglePropertyType(type),
          ),
      ],
    );
  }

  Widget _starRatingGroup() {
    if (facets.starRatingCounts.isEmpty) return const SizedBox.shrink();

    final ratings = facets.starRatingCounts.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return FilterGroup(
      title: 'Property rating',
      children: [
        for (final stars in ratings)
          FilterCheckTile(
            label: '$stars ${stars == 1 ? 'star' : 'stars'}',
            count: facets.starRatingCounts[stars],
            isSelected: filters.starRatings.contains(stars),
            onChanged: (_) => cubit.toggleStarRating(stars),
            leading: Icon(
              Icons.star_rounded,
              size: 15,
              color: AppColors.star,
            ),
          ),
      ],
    );
  }

  Widget _facilitiesGroup() {
    if (facets.amenityCounts.isEmpty) return const SizedBox.shrink();

    final amenities = Amenity.values
        .where((amenity) => facets.amenityCounts.containsKey(amenity))
        .toList(growable: false);

    return FilterGroup(
      title: 'Facilities',
      children: [
        for (final amenity in amenities)
          FilterCheckTile(
            label: amenity.label,
            count: facets.amenityCounts[amenity],
            isSelected: filters.amenities.contains(amenity),
            onChanged: (_) => cubit.toggleAmenity(amenity),
          ),
      ],
    );
  }

  Widget _distanceGroup() {
    final options = const [1.0, 3.0, 5.0, 10.0]
        .where((km) => km < facets.maxDistanceFromCentreKm)
        .toList(growable: false);

    if (options.isEmpty) return const SizedBox.shrink();

    return FilterGroup(
      title: 'Distance from centre',
      trailing: filters.maxDistanceFromCentreKm == null
          ? null
          : _ResetLink(onPressed: () => cubit.changeMaxDistance(null)),
      children: [
        for (final km in options)
          FilterCheckTile(
            label: 'Less than ${km.round()} km',
            isSelected: filters.maxDistanceFromCentreKm == km,
            onChanged: (isSelected) =>
                cubit.changeMaxDistance(isSelected ? km : null),
          ),
      ],
    );
  }
}

class _ResetLink extends StatelessWidget {
  const _ResetLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        textStyle: Theme.of(context).textTheme.labelMedium,
      ),
      child: const Text('Reset'),
    );
  }
}
