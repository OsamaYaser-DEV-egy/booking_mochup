import 'package:injectable/injectable.dart';

import '../entities/amenity.dart';
import '../entities/hotel.dart';
import '../entities/property_type.dart';
import '../entities/search_filters.dart';
import '../entities/search_result.dart';
import 'hotel_filter.dart';

/// Derives the counts and bounds the filter rail displays.
///
/// Counts are computed per group against the *other* active filters, which is
/// what makes a rail feel correct: ticking "Hotels" should not zero out the
/// star-rating counts, but it should refine the facility counts.
@lazySingleton
class FacetCalculator {
  const FacetCalculator(this._filter);

  final HotelFilter _filter;

  FilterFacets calculate(List<Hotel> candidates, SearchFilters active) {
    if (candidates.isEmpty) return const FilterFacets.empty();

    return FilterFacets(
      priceBounds: _priceBounds(candidates),
      propertyTypeCounts: _propertyTypeCounts(candidates, active),
      starRatingCounts: _starRatingCounts(candidates, active),
      amenityCounts: _amenityCounts(candidates, active),
      popularFilterCounts: _popularFilterCounts(candidates, active),
      reviewScoreCounts: _reviewScoreCounts(candidates, active),
      maxDistanceFromCentreKm: _maxDistance(candidates),
    );
  }

  PriceRange _priceBounds(List<Hotel> candidates) {
    final prices = candidates
        .map((hotel) => hotel.leadPricePerNight.amount)
        .toList(growable: false);
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);

    // Round outwards to a tidy step so the slider ends on sensible numbers.
    return PriceRange(
      min: (min / 50).floor() * 50,
      max: (max / 50).ceil() * 50,
    );
  }

  double _maxDistance(List<Hotel> candidates) => candidates
      .map((hotel) => hotel.location.distanceFromCentreKm)
      .reduce((a, b) => a > b ? a : b);

  Map<PropertyType, int> _propertyTypeCounts(
    List<Hotel> candidates,
    SearchFilters active,
  ) {
    final context = active.copyWith(propertyTypes: const {});
    final counts = <PropertyType, int>{};
    for (final hotel in _surviving(candidates, context)) {
      counts.update(hotel.propertyType, (n) => n + 1, ifAbsent: () => 1);
    }
    return Map.unmodifiable(counts);
  }

  Map<int, int> _starRatingCounts(
    List<Hotel> candidates,
    SearchFilters active,
  ) {
    final context = active.copyWith(starRatings: const {});
    final counts = <int, int>{};
    for (final hotel in _surviving(candidates, context)) {
      if (!hotel.isRated) continue;
      counts.update(hotel.starRating, (n) => n + 1, ifAbsent: () => 1);
    }
    return Map.unmodifiable(counts);
  }

  Map<Amenity, int> _amenityCounts(
    List<Hotel> candidates,
    SearchFilters active,
  ) {
    final context = active.copyWith(amenities: const {});
    final counts = <Amenity, int>{};
    for (final hotel in _surviving(candidates, context)) {
      for (final amenity in hotel.amenities) {
        counts.update(amenity, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    return Map.unmodifiable(counts);
  }

  Map<PopularFilter, int> _popularFilterCounts(
    List<Hotel> candidates,
    SearchFilters active,
  ) {
    final context = active.copyWith(popularFilters: const {});
    final pool = _surviving(candidates, context);
    final counts = <PopularFilter, int>{};
    for (final filter in PopularFilter.values) {
      final probe = context.copyWith(popularFilters: {filter});
      final matching = pool.where((hotel) => _filter.matches(hotel, probe));
      final count = matching.length;
      if (count > 0) counts[filter] = count;
    }
    return Map.unmodifiable(counts);
  }

  Map<int, int> _reviewScoreCounts(
    List<Hotel> candidates,
    SearchFilters active,
  ) {
    final context = active.copyWith(clearMinReviewScore: true);
    final pool = _surviving(candidates, context);
    final counts = <int, int>{};
    for (final threshold in const [6, 7, 8, 9]) {
      final count =
          pool.where((hotel) => hotel.reviews.score >= threshold).length;
      if (count > 0) counts[threshold] = count;
    }
    return Map.unmodifiable(counts);
  }

  List<Hotel> _surviving(List<Hotel> candidates, SearchFilters context) =>
      _filter.apply(candidates, context);
}
