import 'package:intl/intl.dart';

/// Formatting helpers shared by the presentation layer.
///
/// All user-facing number and date strings are produced here so that a change
/// in convention happens in one place.
abstract final class Formatters {
  static final NumberFormat _integer = NumberFormat.decimalPattern('en_US');
  static final DateFormat _dayMonth = DateFormat('EEE d MMM');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');

  /// `1234` becomes `1,234`.
  static String count(int value) => _integer.format(value);

  /// Renders a money amount with no decimals, which is how nightly rates are
  /// displayed throughout the product: `EGP 4,250`.
  static String money(double amount, String currencyCode) {
    return '$currencyCode ${_integer.format(amount.round())}';
  }

  /// `Fri 12 Dec`
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// `12 Dec 2026`
  static String dayMonthYear(DateTime date) => _dayMonthYear.format(date);

  /// `Fri 12 Dec — Mon 15 Dec`
  static String dateRange(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) return 'Add dates';
    return '${dayMonth(checkIn)} — ${dayMonth(checkOut)}';
  }

  /// Distance in a unit that reads naturally: metres below 1 km.
  static String distance(double kilometres) {
    if (kilometres < 1) return '${(kilometres * 1000).round()} m from centre';
    return '${kilometres.toStringAsFixed(1)} km from centre';
  }

  /// `1 night` / `3 nights`
  static String nights(int value) => '$value ${plural(value, 'night')}';

  /// `2 adults` / `1 adult`
  static String adults(int value) => '$value ${plural(value, 'adult')}';

  /// `1 room` / `2 rooms`
  static String rooms(int value) => '$value ${plural(value, 'room')}';

  /// `2 children` / `1 child`
  static String children(int value) =>
      value == 1 ? '1 child' : '$value children';

  /// Naive English pluralisation, adequate for the fixed vocabulary used here.
  static String plural(int value, String singular) =>
      value == 1 ? singular : '${singular}s';
}
