import 'package:equatable/equatable.dart';

import 'amenity.dart';
import 'property_type.dart';

/// An inclusive nightly-price window.
final class PriceRange extends Equatable {
  const PriceRange({required this.min, required this.max});

  final double min;
  final double max;

  bool contains(double amount) => amount >= min && amount <= max;

  /// Widens or narrows the range while keeping `min <= max`.
  PriceRange copyWith({double? min, double? max}) {
    final nextMin = min ?? this.min;
    final nextMax = max ?? this.max;
    return PriceRange(
      min: nextMin <= nextMax ? nextMin : nextMax,
      max: nextMax >= nextMin ? nextMax : nextMin,
    );
  }

  @override
  List<Object?> get props => [min, max];
}

/// The shortcut filters shown at the top of the rail.
enum PopularFilter {
  breakfastIncluded('breakfast_included', 'Breakfast included'),
  freeCancellation('free_cancellation', 'Free cancellation'),
  payAtProperty('pay_at_the_property', 'Pay at the property'),
  swimmingPool('swimming_pool', 'Swimming pool'),
  doubleBed('double_bed', 'Double bed'),
  fiveStars('five_stars', '5 stars'),
  veryGoodAndUp('very_good_8_plus', 'Very good: 8+'),
  sustainable('sustainable', 'Sustainable property');

  const PopularFilter(this.id, this.label);

  final String id;
  final String label;
}

/// The user's narrowing choices.
///
/// Immutable: every change produces a new instance, which keeps cubit state
/// transitions explicit and makes the filter set trivially comparable.
final class SearchFilters extends Equatable {
  const SearchFilters({
    this.priceRange,
    this.propertyTypes = const {},
    this.starRatings = const {},
    this.amenities = const {},
    this.popularFilters = const {},
    this.minReviewScore,
    this.maxDistanceFromCentreKm,
  });

  static const SearchFilters none = SearchFilters();

  /// Null means "no price constraint", which is distinct from the full range.
  final PriceRange? priceRange;

  final Set<PropertyType> propertyTypes;
  final Set<int> starRatings;
  final Set<Amenity> amenities;
  final Set<PopularFilter> popularFilters;

  /// Minimum acceptable overall review score on a 0–10 scale.
  final double? minReviewScore;

  final double? maxDistanceFromCentreKm;

  bool get isEmpty =>
      priceRange == null &&
      propertyTypes.isEmpty &&
      starRatings.isEmpty &&
      amenities.isEmpty &&
      popularFilters.isEmpty &&
      minReviewScore == null &&
      maxDistanceFromCentreKm == null;

  bool get isNotEmpty => !isEmpty;

  /// Number of distinct choices the user has made, shown on the filter button.
  int get activeCount {
    var total = 0;
    if (priceRange != null) total++;
    if (minReviewScore != null) total++;
    if (maxDistanceFromCentreKm != null) total++;
    total += propertyTypes.length;
    total += starRatings.length;
    total += amenities.length;
    total += popularFilters.length;
    return total;
  }

  SearchFilters copyWith({
    PriceRange? priceRange,
    bool clearPriceRange = false,
    Set<PropertyType>? propertyTypes,
    Set<int>? starRatings,
    Set<Amenity>? amenities,
    Set<PopularFilter>? popularFilters,
    double? minReviewScore,
    bool clearMinReviewScore = false,
    double? maxDistanceFromCentreKm,
    bool clearMaxDistance = false,
  }) {
    return SearchFilters(
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      propertyTypes: propertyTypes ?? this.propertyTypes,
      starRatings: starRatings ?? this.starRatings,
      amenities: amenities ?? this.amenities,
      popularFilters: popularFilters ?? this.popularFilters,
      minReviewScore:
          clearMinReviewScore ? null : (minReviewScore ?? this.minReviewScore),
      maxDistanceFromCentreKm: clearMaxDistance
          ? null
          : (maxDistanceFromCentreKm ?? this.maxDistanceFromCentreKm),
    );
  }

  /// Adds [type] when absent, removes it when present.
  SearchFilters togglePropertyType(PropertyType type) =>
      copyWith(propertyTypes: _toggled(propertyTypes, type));

  SearchFilters toggleStarRating(int stars) =>
      copyWith(starRatings: _toggled(starRatings, stars));

  SearchFilters toggleAmenity(Amenity amenity) =>
      copyWith(amenities: _toggled(amenities, amenity));

  SearchFilters togglePopularFilter(PopularFilter filter) =>
      copyWith(popularFilters: _toggled(popularFilters, filter));

  static Set<T> _toggled<T>(Set<T> source, T value) {
    final next = Set<T>.of(source);
    if (!next.remove(value)) next.add(value);
    return next;
  }

  @override
  List<Object?> get props => [
        priceRange,
        propertyTypes,
        starRatings,
        amenities,
        popularFilters,
        minReviewScore,
        maxDistanceFromCentreKm,
      ];
}
