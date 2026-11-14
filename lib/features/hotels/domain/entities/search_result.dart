import 'package:equatable/equatable.dart';

import 'amenity.dart';
import 'hotel.dart';
import 'property_type.dart';
import 'search_filters.dart';

/// Counts and bounds derived from the unfiltered candidate set.
///
/// The rail needs these to render "Hotels (3)" and to bound the price slider.
/// They are computed from candidates *before* filtering so the numbers do not
/// collapse to zero as the user ticks boxes.
final class FilterFacets extends Equatable {
  const FilterFacets({
    required this.priceBounds,
    required this.propertyTypeCounts,
    required this.starRatingCounts,
    required this.amenityCounts,
    required this.popularFilterCounts,
    required this.reviewScoreCounts,
    required this.maxDistanceFromCentreKm,
  });

  const FilterFacets.empty()
      : priceBounds = const PriceRange(min: 0, max: 0),
        propertyTypeCounts = const {},
        starRatingCounts = const {},
        amenityCounts = const {},
        popularFilterCounts = const {},
        reviewScoreCounts = const {},
        maxDistanceFromCentreKm = 0;

  /// Lowest and highest nightly lead price among candidates.
  final PriceRange priceBounds;

  final Map<PropertyType, int> propertyTypeCounts;
  final Map<int, int> starRatingCounts;
  final Map<Amenity, int> amenityCounts;
  final Map<PopularFilter, int> popularFilterCounts;

  /// Keyed by score threshold (6, 7, 8, 9) — how many properties score at
  /// least that much.
  final Map<int, int> reviewScoreCounts;

  final double maxDistanceFromCentreKm;

  bool get hasPriceSpread => priceBounds.max > priceBounds.min;

  @override
  List<Object?> get props => [
        priceBounds,
        propertyTypeCounts,
        starRatingCounts,
        amenityCounts,
        popularFilterCounts,
        reviewScoreCounts,
        maxDistanceFromCentreKm,
      ];
}

/// The outcome of a search: the matching properties plus the facets needed to
/// render the filter rail.
final class SearchResult extends Equatable {
  const SearchResult({
    required this.hotels,
    required this.totalCandidates,
    required this.facets,
  });

  const SearchResult.empty()
      : hotels = const [],
        totalCandidates = 0,
        facets = const FilterFacets.empty();

  /// Properties that passed the filters, in the requested order.
  final List<Hotel> hotels;

  /// How many properties the destination has before filtering.
  final int totalCandidates;

  final FilterFacets facets;

  int get matchCount => hotels.length;

  bool get isEmpty => hotels.isEmpty;

  /// True when the destination has properties but the filters excluded them
  /// all — the case that warrants a "relax your filters" message rather than
  /// a "nothing here" one.
  bool get isFilteredOut => hotels.isEmpty && totalCandidates > 0;

  @override
  List<Object?> get props => [hotels, totalCandidates, facets];
}
