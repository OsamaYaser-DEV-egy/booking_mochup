import 'package:equatable/equatable.dart';

/// The kind of place a property is. Drives both the card subtitle and the
/// "Property type" filter group.
enum PropertyType {
  hotel('hotel', 'Hotel', 'Hotels'),
  apartment('apartment', 'Apartment', 'Apartments'),
  resort('resort', 'Resort', 'Resorts'),
  villa('villa', 'Villa', 'Villas'),
  guestHouse('guest_house', 'Guest house', 'Guest houses'),
  hostel('hostel', 'Hostel', 'Hostels'),
  bedAndBreakfast('bed_and_breakfast', 'Bed and breakfast', 'Bed and breakfasts'),
  holidayHome('holiday_home', 'Holiday home', 'Holiday homes');

  const PropertyType(this.id, this.label, this.pluralLabel);

  final String id;

  /// Singular label, used on a property card.
  final String label;

  /// Plural label, used as a filter row.
  final String pluralLabel;

  static PropertyType? fromId(String id) {
    for (final type in PropertyType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// A sustainability certification level, shown as a small leaf badge.
final class SustainabilityCertification extends Equatable {
  const SustainabilityCertification({required this.level, required this.label});

  /// 1, 2 or 3 — higher is better.
  final int level;
  final String label;

  @override
  List<Object?> get props => [level, label];
}
