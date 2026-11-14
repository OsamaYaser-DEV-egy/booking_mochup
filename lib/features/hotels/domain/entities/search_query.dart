import 'package:equatable/equatable.dart';

/// How many people, in how many rooms, a search is for.
final class GuestSelection extends Equatable {
  const GuestSelection({
    this.adults = 2,
    this.children = 0,
    this.rooms = 1,
    this.travellingWithPets = false,
  });

  final int adults;
  final int children;
  final int rooms;
  final bool travellingWithPets;

  int get totalGuests => adults + children;

  /// `2 adults · 0 children · 1 room`
  String get summary {
    final parts = <String>[
      '$adults ${adults == 1 ? 'adult' : 'adults'}',
      '$children ${children == 1 ? 'child' : 'children'}',
      '$rooms ${rooms == 1 ? 'room' : 'rooms'}',
    ];
    return parts.join(' · ');
  }

  GuestSelection copyWith({
    int? adults,
    int? children,
    int? rooms,
    bool? travellingWithPets,
  }) {
    return GuestSelection(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
      travellingWithPets: travellingWithPets ?? this.travellingWithPets,
    );
  }

  @override
  List<Object?> get props => [adults, children, rooms, travellingWithPets];
}

/// The dates of a stay. Either both bounds are present, or the search is
/// treated as flexible and a nominal stay length is assumed for pricing.
final class StayDates extends Equatable {
  const StayDates({this.checkIn, this.checkOut});

  const StayDates.flexible() : checkIn = null, checkOut = null;

  final DateTime? checkIn;
  final DateTime? checkOut;

  bool get isDefined => checkIn != null && checkOut != null;

  /// Nights in the stay. Falls back to [fallbackNights] when the search has no
  /// dates yet, so prices can still be shown for a representative stay.
  int nights({int fallbackNights = 1}) {
    if (!isDefined) return fallbackNights;
    final difference = checkOut!.difference(checkIn!).inDays;
    return difference > 0 ? difference : fallbackNights;
  }

  @override
  List<Object?> get props => [checkIn, checkOut];
}

/// Everything the user asked for: where, when and for whom.
///
/// This is deliberately separate from [SearchFilters]: a query identifies the
/// set of candidate properties, while filters narrow that set. Keeping them
/// apart means changing a filter never needs to re-ask the data source.
final class SearchQuery extends Equatable {
  const SearchQuery({
    required this.destination,
    this.dates = const StayDates.flexible(),
    this.guests = const GuestSelection(),
  });

  /// Free-text destination as typed by the user, e.g. `Egypt` or `Cairo`.
  final String destination;
  final StayDates dates;
  final GuestSelection guests;

  int get nights => dates.nights();

  bool get isValid => destination.trim().isNotEmpty;

  SearchQuery copyWith({
    String? destination,
    StayDates? dates,
    GuestSelection? guests,
  }) {
    return SearchQuery(
      destination: destination ?? this.destination,
      dates: dates ?? this.dates,
      guests: guests ?? this.guests,
    );
  }

  @override
  List<Object?> get props => [destination, dates, guests];
}
