import 'package:equatable/equatable.dart';

import 'amenity.dart';
import 'hotel_location.dart';
import 'money.dart';
import 'property_type.dart';
import 'review_summary.dart';
import 'room_offer.dart';

/// A bookable property.
///
/// This is the aggregate root of the feature: it owns its offers, its review
/// summary and its location, and it answers questions about itself rather than
/// exposing raw data for callers to interpret. Filtering and sorting therefore
/// read intent-revealing members such as [leadPricePerNight] instead of
/// digging through [roomOffers].
final class Hotel extends Equatable {
  const Hotel({
    required this.id,
    required this.name,
    required this.propertyType,
    required this.starRating,
    required this.location,
    required this.reviews,
    required this.imageUrls,
    required this.roomOffers,
    this.summary = '',
    this.description = '',
    this.amenities = const [],
    this.sustainability,
    this.isPreferredPartner = false,
    this.hasMemberDiscount = false,
    this.checkInFrom,
    this.checkOutUntil,
    this.houseRules = const [],
  });

  final String id;
  final String name;
  final PropertyType propertyType;

  /// 0 when the property is unrated, otherwise 1–5.
  final int starRating;

  final HotelLocation location;
  final ReviewSummary reviews;

  /// Gallery images, first entry used as the card thumbnail.
  final List<String> imageUrls;

  /// Every offer available for this property. Never empty for a listed hotel.
  final List<RoomOffer> roomOffers;

  /// One-line editorial blurb used on the card.
  final String summary;

  /// Long-form description used on the details screen.
  final String description;

  final List<Amenity> amenities;
  final SustainabilityCertification? sustainability;

  /// Marks a property that consistently scores well, shown as a badge.
  final bool isPreferredPartner;

  /// Marks a loyalty-programme discount, shown as a badge.
  final bool hasMemberDiscount;

  final String? checkInFrom;
  final String? checkOutUntil;
  final List<String> houseRules;

  // ------------------------------------------------------------- derived data

  /// The cheapest offer, which is the one surfaced on the card.
  RoomOffer get leadOffer =>
      roomOffers.reduce((a, b) => a.pricePerNight < b.pricePerNight ? a : b);

  Money get leadPricePerNight => leadOffer.pricePerNight;

  /// Total for a stay of [nights] nights at the lead rate.
  Money totalFor(int nights) => leadOffer.totalFor(nights);

  bool get hasThumbnail => imageUrls.isNotEmpty;

  String? get thumbnailUrl => hasThumbnail ? imageUrls.first : null;

  bool get isRated => starRating > 0;

  bool get offersBreakfast =>
      roomOffers.any((offer) => offer.breakfastIncluded);

  bool get offersFreeCancellation =>
      roomOffers.any((offer) => offer.freeCancellation);

  bool get offersPayAtProperty =>
      roomOffers.any((offer) => offer.payAtProperty);

  bool get isDiscounted => leadOffer.isDiscounted;

  /// Smallest remaining inventory across offers, used for the scarcity notice.
  int? get fewestRoomsLeft {
    final counts = roomOffers
        .map((offer) => offer.roomsLeft)
        .whereType<int>()
        .toList(growable: false);
    if (counts.isEmpty) return null;
    return counts.reduce((a, b) => a < b ? a : b);
  }

  bool get isScarce => roomOffers.any((offer) => offer.isScarce);

  bool get isSustainable => sustainability != null;

  bool hasAmenity(Amenity amenity) => amenities.contains(amenity);

  /// True when at least one offer can host [guests] people.
  bool accommodates(int guests) =>
      roomOffers.any((offer) => offer.accommodates(guests));

  /// Cheapest offer that can host [guests], falling back to the lead offer so
  /// the card always has something to show.
  RoomOffer bestOfferFor(int guests) {
    final suitable = roomOffers
        .where((offer) => offer.accommodates(guests))
        .toList(growable: false);
    if (suitable.isEmpty) return leadOffer;
    return suitable
        .reduce((a, b) => a.pricePerNight < b.pricePerNight ? a : b);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        propertyType,
        starRating,
        location,
        reviews,
        imageUrls,
        roomOffers,
        summary,
        description,
        amenities,
        sustainability,
        isPreferredPartner,
        hasMemberDiscount,
        checkInFrom,
        checkOutUntil,
        houseRules,
      ];
}
