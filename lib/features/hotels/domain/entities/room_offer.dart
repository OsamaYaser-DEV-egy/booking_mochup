import 'package:equatable/equatable.dart';

import 'money.dart';

enum BedType {
  single('single', 'Single bed'),
  twin('twin', 'Twin bed'),
  double_('double', 'Double bed'),
  queen('queen', 'Queen bed'),
  king('king', 'King bed'),
  sofaBed('sofa_bed', 'Sofa bed'),
  bunk('bunk', 'Bunk bed');

  const BedType(this.id, this.label);

  /// Stable key stored in Firestore, independent of the Dart member name.
  final String id;

  final String label;

  static BedType? fromId(String id) {
    for (final type in BedType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// How many beds of a given type a room has.
final class BedConfiguration extends Equatable {
  const BedConfiguration({required this.type, required this.quantity});

  final BedType type;
  final int quantity;

  /// `2 twin beds` / `1 king bed`
  String get label => quantity == 1
      ? '1 ${type.label.toLowerCase()}'
      : '$quantity ${type.label.toLowerCase()}s';

  @override
  List<Object?> get props => [type, quantity];
}

/// What a guest actually books: a room, at a price, under a set of conditions.
///
/// Price is expressed per night; the total for a stay is derived by the
/// presentation layer from the number of nights in the search query, so a
/// single offer can serve any date range.
final class RoomOffer extends Equatable {
  const RoomOffer({
    required this.id,
    required this.name,
    required this.pricePerNight,
    required this.maxOccupancy,
    required this.beds,
    this.originalPricePerNight,
    this.sizeSquareMetres,
    this.breakfastIncluded = false,
    this.freeCancellation = false,
    this.payAtProperty = false,
    this.roomsLeft,
    this.features = const [],
  });

  final String id;
  final String name;
  final Money pricePerNight;

  /// The pre-discount rate, when this offer is discounted.
  final Money? originalPricePerNight;

  final int maxOccupancy;
  final List<BedConfiguration> beds;
  final double? sizeSquareMetres;
  final bool breakfastIncluded;
  final bool freeCancellation;
  final bool payAtProperty;

  /// Remaining inventory, used to drive the scarcity notice.
  final int? roomsLeft;

  /// Short in-room perks, e.g. `Private bathroom`, `Pyramids view`.
  final List<String> features;

  bool get isDiscounted =>
      originalPricePerNight != null &&
      originalPricePerNight!.amount > pricePerNight.amount;

  /// Whole-percent saving against the original rate, or null when not on offer.
  int? get discountPercent {
    if (!isDiscounted) return null;
    final original = originalPricePerNight!.amount;
    return (((original - pricePerNight.amount) / original) * 100).round();
  }

  bool get isScarce => roomsLeft != null && roomsLeft! > 0 && roomsLeft! <= 5;

  /// Total for [nights] nights of this offer.
  Money totalFor(int nights) => pricePerNight * nights;

  /// `1 king bed` or `1 king bed, 1 sofa bed`
  String get bedSummary => beds.map((bed) => bed.label).join(', ');

  bool accommodates(int guests) => maxOccupancy >= guests;

  @override
  List<Object?> get props => [
        id,
        name,
        pricePerNight,
        originalPricePerNight,
        maxOccupancy,
        beds,
        sizeSquareMetres,
        breakfastIncluded,
        freeCancellation,
        payAtProperty,
        roomsLeft,
        features,
      ];
}
