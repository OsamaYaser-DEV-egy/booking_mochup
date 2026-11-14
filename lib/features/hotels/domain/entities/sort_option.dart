/// The orderings offered above the result list.
enum SortOption {
  topPicks('Our top picks'),
  priceLowest('Price (lowest first)'),
  bestReviewedAndLowestPrice('Best reviewed and lowest price'),
  propertyRatingHigh('Property rating (high to low)'),
  propertyRatingLow('Property rating (low to high)'),
  distanceFromCentre('Distance from centre'),
  topReviewed('Top reviewed');

  const SortOption(this.label);

  final String label;

  static const SortOption defaultOption = SortOption.topPicks;
}
