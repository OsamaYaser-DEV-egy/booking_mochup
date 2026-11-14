import 'map_reader.dart';

/// Wire format of a `hotels` document.
///
/// DTOs mirror storage, not the domain: fields are nullable where documents may
/// omit them, enums are plain id strings, and nothing here derives or validates
/// business meaning. Translation into entities happens in the mappers.
final class HotelDto {
  const HotelDto({
    required this.id,
    required this.name,
    required this.propertyTypeId,
    required this.starRating,
    required this.currency,
    required this.location,
    required this.reviews,
    required this.imageUrls,
    required this.roomOffers,
    required this.amenityIds,
    required this.searchTokens,
    this.summary = '',
    this.description = '',
    this.sustainability,
    this.isPreferredPartner = false,
    this.hasMemberDiscount = false,
    this.checkInFrom,
    this.checkOutUntil,
    this.houseRules = const [],
  });

  factory HotelDto.fromMap(String id, Map<String, Object?> map) {
    final reader = MapReader(map);
    return HotelDto(
      id: id,
      name: reader.string('name'),
      propertyTypeId: reader.string('propertyType'),
      starRating: reader.integerOr('starRating', 0),
      currency: reader.stringOr('currency', 'EGP'),
      summary: reader.stringOr('summary', ''),
      description: reader.stringOr('description', ''),
      location: HotelLocationDto.fromReader(reader.object('location')),
      reviews: ReviewSummaryDto.fromReader(reader.object('reviews')),
      imageUrls: reader.strings('imageUrls'),
      amenityIds: reader.strings('amenities'),
      searchTokens: reader.strings('searchTokens'),
      roomOffers: reader
          .objects('roomOffers')
          .map(RoomOfferDto.fromReader)
          .toList(growable: false),
      sustainability: switch (reader.objectOrNull('sustainability')) {
        final value? => SustainabilityDto.fromReader(value),
        null => null,
      },
      isPreferredPartner: reader.boolean('isPreferredPartner'),
      hasMemberDiscount: reader.boolean('hasMemberDiscount'),
      checkInFrom: reader.optional<String>('checkInFrom'),
      checkOutUntil: reader.optional<String>('checkOutUntil'),
      houseRules: reader.strings('houseRules'),
    );
  }

  final String id;
  final String name;
  final String propertyTypeId;
  final int starRating;
  final String currency;
  final String summary;
  final String description;
  final HotelLocationDto location;
  final ReviewSummaryDto reviews;
  final List<String> imageUrls;
  final List<String> amenityIds;

  /// Lower-cased tokens the destination query is matched against.
  final List<String> searchTokens;

  final List<RoomOfferDto> roomOffers;
  final SustainabilityDto? sustainability;
  final bool isPreferredPartner;
  final bool hasMemberDiscount;
  final String? checkInFrom;
  final String? checkOutUntil;
  final List<String> houseRules;

  Map<String, Object?> toMap() => {
        'name': name,
        'propertyType': propertyTypeId,
        'starRating': starRating,
        'currency': currency,
        'summary': summary,
        'description': description,
        'location': location.toMap(),
        'reviews': reviews.toMap(),
        'imageUrls': imageUrls,
        'amenities': amenityIds,
        'searchTokens': searchTokens,
        'roomOffers': roomOffers.map((offer) => offer.toMap()).toList(),
        if (sustainability != null) 'sustainability': sustainability!.toMap(),
        'isPreferredPartner': isPreferredPartner,
        'hasMemberDiscount': hasMemberDiscount,
        if (checkInFrom != null) 'checkInFrom': checkInFrom,
        if (checkOutUntil != null) 'checkOutUntil': checkOutUntil,
        'houseRules': houseRules,
      };
}

final class HotelLocationDto {
  const HotelLocationDto({
    required this.area,
    required this.city,
    required this.country,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceFromCentreKm,
    this.locationScore,
    this.highlight,
    this.nearbyLandmarks = const [],
  });

  factory HotelLocationDto.fromReader(MapReader reader) => HotelLocationDto(
        area: reader.string('area'),
        city: reader.string('city'),
        country: reader.string('country'),
        address: reader.stringOr('address', ''),
        latitude: reader.number('latitude'),
        longitude: reader.number('longitude'),
        distanceFromCentreKm: reader.numberOr('distanceFromCentreKm', 0),
        locationScore: reader.numberOrNull('locationScore'),
        highlight: reader.optional<String>('highlight'),
        nearbyLandmarks: reader
            .objects('nearbyLandmarks')
            .map(LandmarkDto.fromReader)
            .toList(growable: false),
      );

  final String area;
  final String city;
  final String country;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceFromCentreKm;
  final double? locationScore;
  final String? highlight;
  final List<LandmarkDto> nearbyLandmarks;

  Map<String, Object?> toMap() => {
        'area': area,
        'city': city,
        'country': country,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'distanceFromCentreKm': distanceFromCentreKm,
        if (locationScore != null) 'locationScore': locationScore,
        if (highlight != null) 'highlight': highlight,
        'nearbyLandmarks':
            nearbyLandmarks.map((landmark) => landmark.toMap()).toList(),
      };
}

final class LandmarkDto {
  const LandmarkDto({
    required this.name,
    required this.distanceKm,
    required this.categoryId,
  });

  factory LandmarkDto.fromReader(MapReader reader) => LandmarkDto(
        name: reader.string('name'),
        distanceKm: reader.numberOr('distanceKm', 0),
        categoryId: reader.stringOr('category', 'attraction'),
      );

  final String name;
  final double distanceKm;
  final String categoryId;

  Map<String, Object?> toMap() => {
        'name': name,
        'distanceKm': distanceKm,
        'category': categoryId,
      };
}

final class ReviewSummaryDto {
  const ReviewSummaryDto({
    required this.score,
    required this.reviewCount,
    this.categoryScores = const {},
    this.highlightQuote,
    this.highlightAuthor,
    this.highlightCountry,
  });

  factory ReviewSummaryDto.fromReader(MapReader reader) => ReviewSummaryDto(
        score: reader.numberOr('score', 0),
        reviewCount: reader.integerOr('reviewCount', 0),
        categoryScores: reader.numberMap('categoryScores'),
        highlightQuote: reader.optional<String>('highlightQuote'),
        highlightAuthor: reader.optional<String>('highlightAuthor'),
        highlightCountry: reader.optional<String>('highlightCountry'),
      );

  final double score;
  final int reviewCount;
  final Map<String, double> categoryScores;
  final String? highlightQuote;
  final String? highlightAuthor;
  final String? highlightCountry;

  Map<String, Object?> toMap() => {
        'score': score,
        'reviewCount': reviewCount,
        'categoryScores': categoryScores,
        if (highlightQuote != null) 'highlightQuote': highlightQuote,
        if (highlightAuthor != null) 'highlightAuthor': highlightAuthor,
        if (highlightCountry != null) 'highlightCountry': highlightCountry,
      };
}

final class RoomOfferDto {
  const RoomOfferDto({
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

  factory RoomOfferDto.fromReader(MapReader reader) => RoomOfferDto(
        id: reader.string('id'),
        name: reader.string('name'),
        pricePerNight: reader.number('pricePerNight'),
        originalPricePerNight: reader.numberOrNull('originalPricePerNight'),
        maxOccupancy: reader.integerOr('maxOccupancy', 2),
        sizeSquareMetres: reader.numberOrNull('sizeSquareMetres'),
        beds: reader
            .objects('beds')
            .map(BedConfigurationDto.fromReader)
            .toList(growable: false),
        breakfastIncluded: reader.boolean('breakfastIncluded'),
        freeCancellation: reader.boolean('freeCancellation'),
        payAtProperty: reader.boolean('payAtProperty'),
        roomsLeft: reader.integerOrNull('roomsLeft'),
        features: reader.strings('features'),
      );

  final String id;
  final String name;
  final double pricePerNight;
  final double? originalPricePerNight;
  final int maxOccupancy;
  final double? sizeSquareMetres;
  final List<BedConfigurationDto> beds;
  final bool breakfastIncluded;
  final bool freeCancellation;
  final bool payAtProperty;
  final int? roomsLeft;
  final List<String> features;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'pricePerNight': pricePerNight,
        if (originalPricePerNight != null)
          'originalPricePerNight': originalPricePerNight,
        'maxOccupancy': maxOccupancy,
        if (sizeSquareMetres != null) 'sizeSquareMetres': sizeSquareMetres,
        'beds': beds.map((bed) => bed.toMap()).toList(),
        'breakfastIncluded': breakfastIncluded,
        'freeCancellation': freeCancellation,
        'payAtProperty': payAtProperty,
        if (roomsLeft != null) 'roomsLeft': roomsLeft,
        'features': features,
      };
}

final class BedConfigurationDto {
  const BedConfigurationDto({required this.typeId, required this.quantity});

  factory BedConfigurationDto.fromReader(MapReader reader) =>
      BedConfigurationDto(
        typeId: reader.string('type'),
        quantity: reader.integerOr('quantity', 1),
      );

  final String typeId;
  final int quantity;

  Map<String, Object?> toMap() => {'type': typeId, 'quantity': quantity};
}

final class SustainabilityDto {
  const SustainabilityDto({required this.level, required this.label});

  factory SustainabilityDto.fromReader(MapReader reader) => SustainabilityDto(
        level: reader.integerOr('level', 1),
        label: reader.stringOr('label', 'Travel Sustainable'),
      );

  final int level;
  final String label;

  Map<String, Object?> toMap() => {'level': level, 'label': label};
}
