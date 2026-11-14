import 'package:injectable/injectable.dart';

import '../entities/amenity.dart';
import '../entities/hotel.dart';
import '../entities/room_offer.dart';
import '../entities/search_filters.dart';

/// One narrowing rule.
///
/// Each concrete rule decides whether a single property survives, which keeps
/// every rule independently testable and lets a new filter be added by writing
/// a new class rather than editing a growing conditional.
abstract interface class HotelCriterion {
  /// True when [hotel] satisfies this rule.
  bool isSatisfiedBy(Hotel hotel);
}

class _PriceCriterion implements HotelCriterion {
  const _PriceCriterion(this.range);

  final PriceRange range;

  @override
  bool isSatisfiedBy(Hotel hotel) =>
      range.contains(hotel.leadPricePerNight.amount);
}

class _PropertyTypeCriterion implements HotelCriterion {
  const _PropertyTypeCriterion(this.filters);

  final SearchFilters filters;

  @override
  bool isSatisfiedBy(Hotel hotel) =>
      filters.propertyTypes.contains(hotel.propertyType);
}

class _StarRatingCriterion implements HotelCriterion {
  const _StarRatingCriterion(this.filters);

  final SearchFilters filters;

  @override
  bool isSatisfiedBy(Hotel hotel) =>
      filters.starRatings.contains(hotel.starRating);
}

class _AmenityCriterion implements HotelCriterion {
  const _AmenityCriterion(this.filters);

  final SearchFilters filters;

  /// All selected amenities must be present, which is what users expect when
  /// they tick several facilities.
  @override
  bool isSatisfiedBy(Hotel hotel) =>
      filters.amenities.every(hotel.hasAmenity);
}

class _ReviewScoreCriterion implements HotelCriterion {
  const _ReviewScoreCriterion(this.minimum);

  final double minimum;

  @override
  bool isSatisfiedBy(Hotel hotel) => hotel.reviews.score >= minimum;
}

class _DistanceCriterion implements HotelCriterion {
  const _DistanceCriterion(this.maxKm);

  final double maxKm;

  @override
  bool isSatisfiedBy(Hotel hotel) =>
      hotel.location.distanceFromCentreKm <= maxKm;
}

class _PopularFilterCriterion implements HotelCriterion {
  const _PopularFilterCriterion(this.filters);

  final Set<PopularFilter> filters;

  @override
  bool isSatisfiedBy(Hotel hotel) =>
      filters.every((filter) => _matches(filter, hotel));

  bool _matches(PopularFilter filter, Hotel hotel) {
    return switch (filter) {
      PopularFilter.breakfastIncluded => hotel.offersBreakfast,
      PopularFilter.freeCancellation => hotel.offersFreeCancellation,
      PopularFilter.payAtProperty => hotel.offersPayAtProperty,
      PopularFilter.swimmingPool => hotel.hasAmenity(Amenity.swimmingPool),
      PopularFilter.doubleBed => hotel.roomOffers.any(
          (offer) => offer.beds.any(
            (bed) => const {
              BedType.double_,
              BedType.queen,
              BedType.king,
            }.contains(bed.type),
          ),
        ),
      PopularFilter.fiveStars => hotel.starRating == 5,
      PopularFilter.veryGoodAndUp => hotel.reviews.score >= 8,
      PopularFilter.sustainable => hotel.isSustainable,
    };
  }
}

/// Applies a [SearchFilters] set to a list of candidates.
///
/// Stateless and dependency-free, so it is exercised directly by unit tests.
@lazySingleton
class HotelFilter {
  const HotelFilter();

  /// Returns the candidates that satisfy every active rule, preserving order.
  List<Hotel> apply(List<Hotel> candidates, SearchFilters filters) {
    if (filters.isEmpty) return List.unmodifiable(candidates);

    final criteria = _criteriaFor(filters);
    return List.unmodifiable(
      candidates.where(
        (hotel) => criteria.every((rule) => rule.isSatisfiedBy(hotel)),
      ),
    );
  }

  /// True when [hotel] would survive [filters]. Used by the facet calculator
  /// to count "how many results would this one extra tick leave me".
  bool matches(Hotel hotel, SearchFilters filters) =>
      _criteriaFor(filters).every((rule) => rule.isSatisfiedBy(hotel));

  List<HotelCriterion> _criteriaFor(SearchFilters filters) {
    return [
      if (filters.priceRange != null) _PriceCriterion(filters.priceRange!),
      if (filters.propertyTypes.isNotEmpty) _PropertyTypeCriterion(filters),
      if (filters.starRatings.isNotEmpty) _StarRatingCriterion(filters),
      if (filters.amenities.isNotEmpty) _AmenityCriterion(filters),
      if (filters.minReviewScore != null)
        _ReviewScoreCriterion(filters.minReviewScore!),
      if (filters.maxDistanceFromCentreKm != null)
        _DistanceCriterion(filters.maxDistanceFromCentreKm!),
      if (filters.popularFilters.isNotEmpty)
        _PopularFilterCriterion(filters.popularFilters),
    ];
  }
}
