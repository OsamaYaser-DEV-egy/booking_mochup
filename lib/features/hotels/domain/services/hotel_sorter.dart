import 'package:injectable/injectable.dart';

import '../entities/hotel.dart';
import '../entities/sort_option.dart';

/// Orders search results.
///
/// Each ordering is a plain [Comparator], so adding one means adding a case to
/// the lookup rather than touching any existing comparison logic.
@lazySingleton
class HotelSorter {
  const HotelSorter();

  /// Returns a new ordered list; the input is never mutated.
  List<Hotel> apply(List<Hotel> hotels, SortOption option) {
    final sorted = List<Hotel>.of(hotels)..sort(_comparatorFor(option));
    return List.unmodifiable(sorted);
  }

  Comparator<Hotel> _comparatorFor(SortOption option) {
    return switch (option) {
      SortOption.topPicks => _byRelevance,
      SortOption.priceLowest => _byPriceAscending,
      SortOption.bestReviewedAndLowestPrice => _byReviewThenPrice,
      SortOption.propertyRatingHigh => _byStarsDescending,
      SortOption.propertyRatingLow => _byStarsAscending,
      SortOption.distanceFromCentre => _byDistanceAscending,
      SortOption.topReviewed => _byReviewDescending,
    };
  }

  /// The default ordering: a blend of guest score, review volume and partner
  /// status, so a well-reviewed property with many reviews outranks a
  /// thinly-reviewed one with a marginally higher score.
  static int _byRelevance(Hotel a, Hotel b) =>
      _relevance(b).compareTo(_relevance(a));

  static double _relevance(Hotel hotel) {
    final scoreWeight = hotel.reviews.score * 10;
    final volumeWeight = _volumeBonus(hotel.reviews.reviewCount);
    final partnerWeight = hotel.isPreferredPartner ? 6 : 0;
    final starWeight = hotel.starRating * 1.5;
    return scoreWeight + volumeWeight + partnerWeight + starWeight;
  }

  /// Diminishing bonus so review volume matters but never dominates.
  static double _volumeBonus(int reviewCount) {
    if (reviewCount >= 2000) return 10;
    if (reviewCount >= 1000) return 8;
    if (reviewCount >= 500) return 6;
    if (reviewCount >= 200) return 4;
    if (reviewCount >= 50) return 2;
    return 0;
  }

  static int _byPriceAscending(Hotel a, Hotel b) =>
      a.leadPricePerNight.amount.compareTo(b.leadPricePerNight.amount);

  static int _byReviewDescending(Hotel a, Hotel b) {
    final byScore = b.reviews.score.compareTo(a.reviews.score);
    if (byScore != 0) return byScore;
    return b.reviews.reviewCount.compareTo(a.reviews.reviewCount);
  }

  static int _byReviewThenPrice(Hotel a, Hotel b) {
    final byScore = _byReviewDescending(a, b);
    if (byScore != 0) return byScore;
    return _byPriceAscending(a, b);
  }

  static int _byStarsDescending(Hotel a, Hotel b) {
    final byStars = b.starRating.compareTo(a.starRating);
    if (byStars != 0) return byStars;
    return _byReviewDescending(a, b);
  }

  static int _byStarsAscending(Hotel a, Hotel b) {
    final byStars = a.starRating.compareTo(b.starRating);
    if (byStars != 0) return byStars;
    return _byReviewDescending(a, b);
  }

  static int _byDistanceAscending(Hotel a, Hotel b) => a
      .location.distanceFromCentreKm
      .compareTo(b.location.distanceFromCentreKm);
}
