import 'package:booking_mochup/features/hotels/domain/entities/amenity.dart';
import 'package:booking_mochup/features/hotels/domain/entities/hotel.dart';
import 'package:booking_mochup/features/hotels/domain/entities/hotel_location.dart';
import 'package:booking_mochup/features/hotels/domain/entities/money.dart';
import 'package:booking_mochup/features/hotels/domain/entities/property_type.dart';
import 'package:booking_mochup/features/hotels/domain/entities/review_summary.dart';
import 'package:booking_mochup/features/hotels/domain/entities/room_offer.dart';

/// Builders for domain objects used across the domain tests.
///
/// Every parameter has a sensible default so a test states only the field it
/// actually cares about, which keeps the intent of each case visible.
abstract final class HotelFixtures {
  static Hotel hotel({
    String id = 'test-hotel',
    String name = 'Test Hotel',
    PropertyType propertyType = PropertyType.hotel,
    int starRating = 4,
    double reviewScore = 8.5,
    int reviewCount = 500,
    double pricePerNight = 2000,
    double? originalPricePerNight,
    double distanceFromCentreKm = 2,
    List<Amenity> amenities = const [Amenity.freeWifi],
    bool breakfastIncluded = false,
    bool freeCancellation = false,
    bool payAtProperty = false,
    int? roomsLeft,
    bool isPreferredPartner = false,
    bool isSustainable = false,
    List<RoomOffer>? roomOffers,
    List<BedConfiguration> beds = const [
      BedConfiguration(type: BedType.king, quantity: 1),
    ],
    int maxOccupancy = 2,
  }) {
    return Hotel(
      id: id,
      name: name,
      propertyType: propertyType,
      starRating: starRating,
      location: location(distanceFromCentreKm: distanceFromCentreKm),
      reviews: reviews(score: reviewScore, reviewCount: reviewCount),
      imageUrls: const ['https://example.test/image.jpg'],
      amenities: amenities,
      isPreferredPartner: isPreferredPartner,
      sustainability: isSustainable
          ? const SustainabilityCertification(level: 2, label: 'Level 2')
          : null,
      roomOffers: roomOffers ??
          [
            offer(
              pricePerNight: pricePerNight,
              originalPricePerNight: originalPricePerNight,
              breakfastIncluded: breakfastIncluded,
              freeCancellation: freeCancellation,
              payAtProperty: payAtProperty,
              roomsLeft: roomsLeft,
              beds: beds,
              maxOccupancy: maxOccupancy,
            ),
          ],
    );
  }

  static RoomOffer offer({
    String id = 'test-offer',
    String name = 'Test Room',
    double pricePerNight = 2000,
    double? originalPricePerNight,
    int maxOccupancy = 2,
    List<BedConfiguration> beds = const [
      BedConfiguration(type: BedType.king, quantity: 1),
    ],
    bool breakfastIncluded = false,
    bool freeCancellation = false,
    bool payAtProperty = false,
    int? roomsLeft,
  }) {
    return RoomOffer(
      id: id,
      name: name,
      pricePerNight: Money.egp(pricePerNight),
      originalPricePerNight: originalPricePerNight == null
          ? null
          : Money.egp(originalPricePerNight),
      maxOccupancy: maxOccupancy,
      beds: beds,
      breakfastIncluded: breakfastIncluded,
      freeCancellation: freeCancellation,
      payAtProperty: payAtProperty,
      roomsLeft: roomsLeft,
    );
  }

  static HotelLocation location({double distanceFromCentreKm = 2}) {
    return HotelLocation(
      area: 'Test Area',
      city: 'Test City',
      country: 'Testland',
      address: '1 Test Street',
      coordinates: const GeoPoint(latitude: 30, longitude: 31),
      distanceFromCentreKm: distanceFromCentreKm,
      locationScore: 9,
    );
  }

  static ReviewSummary reviews({double score = 8.5, int reviewCount = 500}) {
    return ReviewSummary(score: score, reviewCount: reviewCount);
  }
}
