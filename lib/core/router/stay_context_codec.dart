import '../../features/hotels/domain/entities/search_query.dart';

/// Moves the dates and party size of a search through a URL.
///
/// Carrying the stay in query parameters rather than in router `extra` means a
/// details link can be copied, bookmarked or reloaded and still price the same
/// stay — which is the whole point of having real URLs on the web.
abstract final class StayContextCodec {
  static const String checkInKey = 'checkin';
  static const String checkOutKey = 'checkout';
  static const String adultsKey = 'adults';
  static const String childrenKey = 'children';
  static const String roomsKey = 'rooms';
  static const String petsKey = 'pets';

  /// Parameters describing [dates] and [guests]. Absent values are omitted
  /// rather than written as empty strings, so a flexible search produces a
  /// short, clean URL.
  static Map<String, String> encode({
    required StayDates dates,
    required GuestSelection guests,
  }) {
    return {
      if (dates.checkIn case final date?) checkInKey: _encodeDate(date),
      if (dates.checkOut case final date?) checkOutKey: _encodeDate(date),
      adultsKey: '${guests.adults}',
      childrenKey: '${guests.children}',
      roomsKey: '${guests.rooms}',
      if (guests.travellingWithPets) petsKey: 'true',
    };
  }

  /// Reads dates back, falling back to a flexible stay when either bound is
  /// missing or unparseable.
  static StayDates decodeDates(Map<String, String> parameters) {
    final checkIn = _decodeDate(parameters[checkInKey]);
    final checkOut = _decodeDate(parameters[checkOutKey]);
    if (checkIn == null || checkOut == null) return const StayDates.flexible();
    if (!checkOut.isAfter(checkIn)) return const StayDates.flexible();
    return StayDates(checkIn: checkIn, checkOut: checkOut);
  }

  /// Reads the party back, falling back to the default occupancy.
  static GuestSelection decodeGuests(Map<String, String> parameters) {
    const fallback = GuestSelection();
    return GuestSelection(
      adults: _decodeInt(parameters[adultsKey], fallback.adults, minimum: 1),
      children: _decodeInt(parameters[childrenKey], fallback.children),
      rooms: _decodeInt(parameters[roomsKey], fallback.rooms, minimum: 1),
      travellingWithPets: parameters[petsKey] == 'true',
    );
  }

  /// `2026-12-24`
  static String _encodeDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? _decodeDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static int _decodeInt(String? raw, int fallback, {int minimum = 0}) {
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed < minimum) return fallback;
    return parsed;
  }
}
