import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_location.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/property_type.dart';
import '../../domain/entities/review_summary.dart';
import '../../domain/entities/room_offer.dart';
import '../dtos/hotel_dto.dart';

/// Translates storage DTOs into domain entities.
///
/// This is the only place that knows how stored ids map onto domain enums, so
/// a vocabulary change in Firestore is absorbed here rather than rippling
/// through the domain. Unknown ids for optional vocabulary (amenities, bed
/// types, landmark categories) are skipped rather than fatal, which keeps the
/// app resilient to a newer backend; unknown ids for required vocabulary
/// (property type) are rejected.
@lazySingleton
class HotelMapper {
  const HotelMapper();

  Hotel toEntity(HotelDto dto) {
    final propertyType = PropertyType.fromId(dto.propertyTypeId);
    if (propertyType == null) {
      throw MappingException(
        'Unknown property type "${dto.propertyTypeId}" on hotel ${dto.id}.',
      );
    }

    if (dto.roomOffers.isEmpty) {
      throw MappingException('Hotel ${dto.id} has no room offers.');
    }

    return Hotel(
      id: dto.id,
      name: dto.name,
      propertyType: propertyType,
      starRating: dto.starRating.clamp(0, 5),
      summary: dto.summary,
      description: dto.description,
      location: _location(dto.location),
      reviews: _reviews(dto.reviews),
      imageUrls: List.unmodifiable(dto.imageUrls),
      amenities: List.unmodifiable(
        dto.amenityIds.map(Amenity.fromId).whereType<Amenity>(),
      ),
      roomOffers: List.unmodifiable(
        dto.roomOffers.map((offer) => _offer(offer, dto.currency)),
      ),
      sustainability: switch (dto.sustainability) {
        final value? => SustainabilityCertification(
            level: value.level,
            label: value.label,
          ),
        null => null,
      },
      isPreferredPartner: dto.isPreferredPartner,
      hasMemberDiscount: dto.hasMemberDiscount,
      checkInFrom: dto.checkInFrom,
      checkOutUntil: dto.checkOutUntil,
      houseRules: List.unmodifiable(dto.houseRules),
    );
  }

  List<Hotel> toEntities(Iterable<HotelDto> dtos) =>
      dtos.map(toEntity).toList(growable: false);

  HotelLocation _location(HotelLocationDto dto) => HotelLocation(
        area: dto.area,
        city: dto.city,
        country: dto.country,
        address: dto.address,
        coordinates: GeoPoint(
          latitude: dto.latitude,
          longitude: dto.longitude,
        ),
        distanceFromCentreKm: dto.distanceFromCentreKm,
        locationScore: dto.locationScore,
        highlight: dto.highlight,
        nearbyLandmarks: List.unmodifiable(
          dto.nearbyLandmarks.map(
            (landmark) => Landmark(
              name: landmark.name,
              distanceKm: landmark.distanceKm,
              category: _landmarkCategory(landmark.categoryId),
            ),
          ),
        ),
      );

  ReviewSummary _reviews(ReviewSummaryDto dto) => ReviewSummary(
        score: dto.score,
        reviewCount: dto.reviewCount,
        categoryScores: Map.unmodifiable({
          for (final entry in dto.categoryScores.entries)
            ?_reviewCategory(entry.key): entry.value,
        }),
        highlightQuote: dto.highlightQuote,
        highlightAuthor: dto.highlightAuthor,
        highlightCountry: dto.highlightCountry,
      );

  RoomOffer _offer(RoomOfferDto dto, String currency) => RoomOffer(
        id: dto.id,
        name: dto.name,
        pricePerNight: Money(amount: dto.pricePerNight, currency: currency),
        originalPricePerNight: switch (dto.originalPricePerNight) {
          final amount? => Money(amount: amount, currency: currency),
          null => null,
        },
        maxOccupancy: dto.maxOccupancy,
        sizeSquareMetres: dto.sizeSquareMetres,
        beds: List.unmodifiable(
          dto.beds
              .map(
                (bed) => switch (BedType.fromId(bed.typeId)) {
                  final type? => BedConfiguration(
                      type: type,
                      quantity: bed.quantity,
                    ),
                  null => null,
                },
              )
              .whereType<BedConfiguration>(),
        ),
        breakfastIncluded: dto.breakfastIncluded,
        freeCancellation: dto.freeCancellation,
        payAtProperty: dto.payAtProperty,
        roomsLeft: dto.roomsLeft,
        features: List.unmodifiable(dto.features),
      );

  ReviewCategory? _reviewCategory(String id) {
    for (final category in ReviewCategory.values) {
      if (category.name == id) return category;
    }
    return null;
  }

  LandmarkCategory _landmarkCategory(String id) {
    for (final category in LandmarkCategory.values) {
      if (category.name == id) return category;
    }
    return LandmarkCategory.attraction;
  }
}
