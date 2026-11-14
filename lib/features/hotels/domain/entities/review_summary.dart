import 'package:equatable/equatable.dart';

/// The sub-scores a property is rated on.
enum ReviewCategory {
  staff('Staff'),
  facilities('Facilities'),
  cleanliness('Cleanliness'),
  comfort('Comfort'),
  valueForMoney('Value for money'),
  location('Location'),
  freeWifi('Free WiFi');

  const ReviewCategory(this.label);

  final String label;
}

/// The qualitative band a numeric score falls into.
enum ScoreBand {
  exceptional('Exceptional'),
  wonderful('Wonderful'),
  excellent('Excellent'),
  veryGood('Very good'),
  good('Good'),
  pleasant('Pleasant'),
  review('Review');

  const ScoreBand(this.label);

  final String label;

  /// Maps a 0–10 score onto its band. Thresholds live here so the whole
  /// product agrees on what "Very good" means.
  static ScoreBand fromScore(double score) {
    if (score >= 9.5) return ScoreBand.exceptional;
    if (score >= 9.0) return ScoreBand.wonderful;
    if (score >= 8.5) return ScoreBand.excellent;
    if (score >= 8.0) return ScoreBand.veryGood;
    if (score >= 7.0) return ScoreBand.good;
    if (score >= 6.0) return ScoreBand.pleasant;
    return ScoreBand.review;
  }
}

/// Aggregated guest-review information for a property.
final class ReviewSummary extends Equatable {
  const ReviewSummary({
    required this.score,
    required this.reviewCount,
    this.categoryScores = const {},
    this.highlightQuote,
    this.highlightAuthor,
    this.highlightCountry,
  });

  /// Overall score on a 0–10 scale.
  final double score;
  final int reviewCount;
  final Map<ReviewCategory, double> categoryScores;

  /// A short pull-quote shown on the property card.
  final String? highlightQuote;
  final String? highlightAuthor;
  final String? highlightCountry;

  ScoreBand get band => ScoreBand.fromScore(score);

  /// Score rendered the way the badge shows it: always one decimal.
  String get formattedScore => score.toStringAsFixed(1);

  bool get hasReviews => reviewCount > 0;

  bool get hasHighlight => highlightQuote != null && highlightQuote!.isNotEmpty;

  @override
  List<Object?> get props => [
        score,
        reviewCount,
        categoryScores,
        highlightQuote,
        highlightAuthor,
        highlightCountry,
      ];
}
