import '../dtos/hotel_dto.dart';
import 'firestore_hotel_data_source.dart';

/// The mocked property catalogue, expressed in the storage format.
///
/// This is the single source of truth for the demo data: the Firestore seeder
/// writes it, and [InMemoryHotelDataSource] serves it when the app runs with
/// the local catalogue enabled. Keeping one definition means the two paths can
/// never drift apart.
abstract final class HotelSeedCatalog {
  /// Document ids are stable, human-readable slugs so deep links and the
  /// seeder stay idempotent across runs.
  static List<HotelDto> get hotels => [
        _horizonPyramids,
        _nileCrown,
        _azureReef,
        _luxorRiverside,
        _alexandriaCorniche,
      ];

  /// Builds the token list a destination query matches against.
  ///
  /// Every property is tagged with its country, city and area so searching
  /// `Egypt`, `Giza` or `Al Haram` all return sensible results.
  static List<String> _tokens(Iterable<String> values) => values
      .map(FirestoreHotelDataSource.normaliseToken)
      .where((token) => token.isNotEmpty)
      .toSet()
      .toList(growable: false);

  // ---------------------------------------------------------------- 1 of 5

  static final HotelDto _horizonPyramids = HotelDto(
    id: 'horizon-pyramids-view-suites',
    name: 'Horizon Pyramids View & Suites',
    propertyTypeId: 'hotel',
    starRating: 4,
    currency: 'EGP',
    summary:
        'Rooftop terrace with an unobstructed view of all three pyramids, '
        'eight minutes on foot from the Giza plateau entrance.',
    description:
        'Horizon Pyramids View & Suites sits on a quiet side street in Al '
        'Haram, close enough to the Giza plateau that the Great Pyramid fills '
        'the view from every upper-floor balcony. Rooms are generously sized '
        'and recently refurbished, with blackout curtains, individually '
        'controlled air conditioning and a small seating area. Breakfast is '
        'served on the rooftop from 06:00, early enough for guests heading to '
        'the plateau at opening time. The team arranges licensed guides, '
        'airport transfers and day trips to Saqqara and Memphis.',
    searchTokens: _tokens([
      'egypt',
      'giza',
      'al haram',
      'cairo',
      'pyramids',
      'greater cairo',
    ]),
    isPreferredPartner: true,
    hasMemberDiscount: true,
    checkInFrom: '14:00',
    checkOutUntil: '12:00',
    houseRules: const [
      'No smoking in rooms; smoking is permitted on the rooftop terrace.',
      'Children of all ages are welcome.',
      'Pets are not allowed.',
      'Cash and all major cards accepted.',
    ],
    imageUrls: const [
      'https://images.unsplash.com/photo-1590133324192-1df305deea6b?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&w=1200&q=80',
    ],
    amenityIds: const [
      'free_wifi',
      'parking',
      'swimming_pool',
      'airport_shuttle',
      'family_rooms',
      'non_smoking_rooms',
      'restaurant',
      'room_service',
      'front_desk_24h',
      'air_conditioning',
      'breakfast',
      'terrace',
      'tea_coffee_maker',
    ],
    location: const HotelLocationDto(
      area: 'Al Haram',
      city: 'Giza',
      country: 'Egypt',
      address: '14 Abu Al Hol Al Seyahi Street, Al Haram, Giza 12561',
      latitude: 29.9765,
      longitude: 31.1313,
      distanceFromCentreKm: 2.4,
      locationScore: 9.3,
      highlight: 'Top location: highly rated by recent guests (9.3)',
      nearbyLandmarks: [
        LandmarkDto(
          name: 'Great Pyramid of Giza',
          distanceKm: 0.9,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Great Sphinx of Giza',
          distanceKm: 1.1,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Grand Egyptian Museum',
          distanceKm: 3.2,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Cairo International Airport',
          distanceKm: 44.0,
          categoryId: 'airport',
        ),
      ],
    ),
    reviews: const ReviewSummaryDto(
      score: 8.7,
      reviewCount: 1428,
      categoryScores: {
        'staff': 9.4,
        'facilities': 8.5,
        'cleanliness': 8.8,
        'comfort': 8.7,
        'valueForMoney': 8.9,
        'location': 9.3,
        'freeWifi': 8.4,
      },
      highlightQuote:
          'Woke up, opened the curtains and the Great Pyramid was just there. '
          'The rooftop breakfast is worth getting up early for.',
      highlightAuthor: 'Mariam',
      highlightCountry: 'Egypt',
    ),
    sustainability: const SustainabilityDto(
      level: 2,
      label: 'Travel Sustainable Level 2',
    ),
    roomOffers: const [
      RoomOfferDto(
        id: 'deluxe-double-pyramid-view',
        name: 'Deluxe Double Room with Pyramid View',
        pricePerNight: 3450,
        originalPricePerNight: 4600,
        maxOccupancy: 2,
        sizeSquareMetres: 28,
        beds: [BedConfigurationDto(typeId: 'king', quantity: 1)],
        breakfastIncluded: true,
        freeCancellation: true,
        roomsLeft: 2,
        features: [
          'Private bathroom',
          'Pyramid view',
          'Balcony',
          'Air conditioning',
          'Flat-screen TV',
        ],
      ),
      RoomOfferDto(
        id: 'family-suite-terrace',
        name: 'Family Suite with Terrace',
        pricePerNight: 5200,
        maxOccupancy: 4,
        sizeSquareMetres: 46,
        beds: [
          BedConfigurationDto(typeId: 'king', quantity: 1),
          BedConfigurationDto(typeId: 'single', quantity: 2),
        ],
        breakfastIncluded: true,
        freeCancellation: true,
        payAtProperty: true,
        roomsLeft: 3,
        features: [
          'Private bathroom',
          'Pyramid view',
          'Private terrace',
          'Seating area',
          'Air conditioning',
        ],
      ),
      RoomOfferDto(
        id: 'standard-twin-city-view',
        name: 'Standard Twin Room with City View',
        pricePerNight: 2650,
        maxOccupancy: 2,
        sizeSquareMetres: 22,
        beds: [BedConfigurationDto(typeId: 'twin', quantity: 2)],
        freeCancellation: true,
        payAtProperty: true,
        roomsLeft: 5,
        features: [
          'Private bathroom',
          'City view',
          'Air conditioning',
          'Flat-screen TV',
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------- 2 of 5

  static final HotelDto _nileCrown = HotelDto(
    id: 'nile-crown-boutique-hotel',
    name: 'Nile Crown Boutique Hotel',
    propertyTypeId: 'hotel',
    starRating: 5,
    currency: 'EGP',
    summary:
        'Restored 1930s townhouse on the Garden City corniche, with a '
        'river-facing pool deck and a rooftop bar.',
    description:
        'Nile Crown occupies a restored 1930s townhouse on the Garden City '
        'corniche, a ten-minute walk from Tahrir Square and the Egyptian '
        'Museum. The thirty-four rooms keep the original terrazzo floors and '
        'tall shuttered windows, paired with new bathrooms and quiet split '
        'air conditioning. The river-facing pool deck is open until 22:00 and '
        'the rooftop bar serves until midnight. The concierge books Nile '
        'dinner cruises and private museum tours.',
    searchTokens: _tokens([
      'egypt',
      'cairo',
      'garden city',
      'downtown cairo',
      'nile',
      'greater cairo',
    ]),
    isPreferredPartner: true,
    checkInFrom: '15:00',
    checkOutUntil: '12:00',
    houseRules: const [
      'This is a non-smoking property throughout.',
      'Children of all ages are welcome.',
      'Pets are not allowed.',
      'A valid passport is required at check-in.',
    ],
    imageUrls: const [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1200&q=80',
    ],
    amenityIds: const [
      'free_wifi',
      'parking',
      'swimming_pool',
      'airport_shuttle',
      'non_smoking_rooms',
      'restaurant',
      'room_service',
      'front_desk_24h',
      'fitness_centre',
      'spa',
      'bar',
      'air_conditioning',
      'breakfast',
      'terrace',
      'laundry',
      'facilities_for_disabled',
      'tea_coffee_maker',
    ],
    location: const HotelLocationDto(
      area: 'Garden City',
      city: 'Cairo',
      country: 'Egypt',
      address: '7 Aisha El Taymoureya Street, Garden City, Cairo 11519',
      latitude: 30.0375,
      longitude: 31.2311,
      distanceFromCentreKm: 0.8,
      locationScore: 9.6,
      highlight: 'Top location: highly rated by recent guests (9.6)',
      nearbyLandmarks: [
        LandmarkDto(
          name: 'Egyptian Museum',
          distanceKm: 1.0,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Tahrir Square',
          distanceKm: 0.9,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Khan el-Khalili',
          distanceKm: 3.4,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Sadat Metro Station',
          distanceKm: 0.7,
          categoryId: 'transport',
        ),
      ],
    ),
    reviews: const ReviewSummaryDto(
      score: 9.2,
      reviewCount: 2310,
      categoryScores: {
        'staff': 9.7,
        'facilities': 9.1,
        'cleanliness': 9.4,
        'comfort': 9.3,
        'valueForMoney': 8.8,
        'location': 9.6,
        'freeWifi': 9.0,
      },
      highlightQuote:
          'The old building has been restored beautifully and the staff '
          'remember your name by the second morning.',
      highlightAuthor: 'Thomas',
      highlightCountry: 'Germany',
    ),
    sustainability: const SustainabilityDto(
      level: 3,
      label: 'Travel Sustainable Level 3',
    ),
    roomOffers: const [
      RoomOfferDto(
        id: 'classic-king-nile-view',
        name: 'Classic King Room with Nile View',
        pricePerNight: 6800,
        originalPricePerNight: 8200,
        maxOccupancy: 2,
        sizeSquareMetres: 34,
        beds: [BedConfigurationDto(typeId: 'king', quantity: 1)],
        breakfastIncluded: true,
        freeCancellation: true,
        roomsLeft: 4,
        features: [
          'Private bathroom',
          'Nile view',
          'French balcony',
          'Minibar',
          'Bathrobe and slippers',
        ],
      ),
      RoomOfferDto(
        id: 'townhouse-junior-suite',
        name: 'Townhouse Junior Suite',
        pricePerNight: 9400,
        maxOccupancy: 3,
        sizeSquareMetres: 52,
        beds: [
          BedConfigurationDto(typeId: 'king', quantity: 1),
          BedConfigurationDto(typeId: 'sofa_bed', quantity: 1),
        ],
        breakfastIncluded: true,
        freeCancellation: true,
        roomsLeft: 2,
        features: [
          'Private bathroom',
          'Nile view',
          'Separate living area',
          'Nespresso machine',
          'Walk-in shower',
        ],
      ),
      RoomOfferDto(
        id: 'courtyard-double',
        name: 'Courtyard Double Room',
        pricePerNight: 5100,
        maxOccupancy: 2,
        sizeSquareMetres: 26,
        beds: [BedConfigurationDto(typeId: 'double', quantity: 1)],
        breakfastIncluded: true,
        payAtProperty: true,
        features: [
          'Private bathroom',
          'Courtyard view',
          'Air conditioning',
          'Soundproofing',
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------- 3 of 5

  static final HotelDto _azureReef = HotelDto(
    id: 'azure-reef-resort-spa',
    name: 'Azure Reef Resort & Spa',
    propertyTypeId: 'resort',
    starRating: 5,
    currency: 'EGP',
    summary:
        'All-inclusive beachfront resort on Hadaba with a house reef, four '
        'pools and a 1,200 m² spa.',
    description:
        'Azure Reef sits on a private stretch of Hadaba coastline with direct '
        'access to a protected house reef — fins and masks are included and '
        'the drop-off is a forty-metre swim from the jetty. The resort has '
        'four pools, one of them heated through winter, five restaurants on '
        'the all-inclusive plan, and a 1,200 m² spa with a hammam. Rooms are '
        'spread across low-rise blocks in landscaped gardens, so none is more '
        'than a four-minute walk from the beach.',
    searchTokens: _tokens([
      'egypt',
      'sharm el sheikh',
      'hadaba',
      'south sinai',
      'red sea',
      'sinai',
    ]),
    isPreferredPartner: true,
    hasMemberDiscount: true,
    checkInFrom: '14:00',
    checkOutUntil: '12:00',
    houseRules: const [
      'All-inclusive wristbands are issued at check-in.',
      'Children of all ages are welcome; under-6s stay free.',
      'Pets are not allowed.',
      'Quiet hours apply in the garden blocks from 23:00.',
    ],
    imageUrls: const [
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1559599189-fe84dea4eb79?auto=format&fit=crop&w=1200&q=80',
    ],
    amenityIds: const [
      'free_wifi',
      'parking',
      'swimming_pool',
      'airport_shuttle',
      'family_rooms',
      'non_smoking_rooms',
      'restaurant',
      'room_service',
      'front_desk_24h',
      'fitness_centre',
      'spa',
      'bar',
      'air_conditioning',
      'breakfast',
      'beachfront',
      'terrace',
      'laundry',
      'facilities_for_disabled',
      'tea_coffee_maker',
    ],
    location: const HotelLocationDto(
      area: 'Hadaba',
      city: 'Sharm El Sheikh',
      country: 'Egypt',
      address: 'Ras Um Sid Cliff, Hadaba, Sharm El Sheikh 46619',
      latitude: 27.8521,
      longitude: 34.3085,
      distanceFromCentreKm: 4.6,
      locationScore: 8.8,
      highlight: 'Beachfront, with a protected house reef',
      nearbyLandmarks: [
        LandmarkDto(
          name: 'Ras Um Sid Reef',
          distanceKm: 0.3,
          categoryId: 'beach',
        ),
        LandmarkDto(
          name: 'Naama Bay',
          distanceKm: 6.1,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Soho Square',
          distanceKm: 8.4,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Sharm El Sheikh International Airport',
          distanceKm: 13.2,
          categoryId: 'airport',
        ),
      ],
    ),
    reviews: const ReviewSummaryDto(
      score: 8.9,
      reviewCount: 3564,
      categoryScores: {
        'staff': 9.1,
        'facilities': 9.2,
        'cleanliness': 9.0,
        'comfort': 9.1,
        'valueForMoney': 8.7,
        'location': 8.8,
        'freeWifi': 8.2,
      },
      highlightQuote:
          'You can snorkel the house reef straight off the jetty. We barely '
          'left the resort all week.',
      highlightAuthor: 'Elena',
      highlightCountry: 'Italy',
    ),
    sustainability: const SustainabilityDto(
      level: 3,
      label: 'Travel Sustainable Level 3',
    ),
    roomOffers: const [
      RoomOfferDto(
        id: 'garden-view-double-ai',
        name: 'Garden View Double Room — All Inclusive',
        pricePerNight: 5250,
        originalPricePerNight: 7000,
        maxOccupancy: 2,
        sizeSquareMetres: 32,
        beds: [BedConfigurationDto(typeId: 'queen', quantity: 1)],
        breakfastIncluded: true,
        freeCancellation: true,
        roomsLeft: 4,
        features: [
          'Private bathroom',
          'Garden view',
          'Balcony',
          'All meals and drinks included',
          'Minibar',
        ],
      ),
      RoomOfferDto(
        id: 'sea-view-family-room-ai',
        name: 'Sea View Family Room — All Inclusive',
        pricePerNight: 8100,
        originalPricePerNight: 9900,
        maxOccupancy: 4,
        sizeSquareMetres: 48,
        beds: [
          BedConfigurationDto(typeId: 'king', quantity: 1),
          BedConfigurationDto(typeId: 'bunk', quantity: 1),
        ],
        breakfastIncluded: true,
        freeCancellation: true,
        roomsLeft: 1,
        features: [
          'Private bathroom',
          'Sea view',
          'Balcony',
          'All meals and drinks included',
          'Kids club access',
        ],
      ),
      RoomOfferDto(
        id: 'beachfront-suite-ai',
        name: 'Beachfront Suite with Plunge Pool — All Inclusive',
        pricePerNight: 13500,
        maxOccupancy: 3,
        sizeSquareMetres: 72,
        beds: [
          BedConfigurationDto(typeId: 'king', quantity: 1),
          BedConfigurationDto(typeId: 'sofa_bed', quantity: 1),
        ],
        breakfastIncluded: true,
        freeCancellation: true,
        roomsLeft: 2,
        features: [
          'Private bathroom',
          'Direct beach access',
          'Private plunge pool',
          'All meals and drinks included',
          'Butler service',
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------- 4 of 5

  static final HotelDto _luxorRiverside = HotelDto(
    id: 'luxor-riverside-apartments',
    name: 'Luxor Riverside Apartments',
    propertyTypeId: 'apartment',
    starRating: 3,
    currency: 'EGP',
    summary:
        'Self-catering apartments on the East Bank corniche, a five-minute '
        'walk from Luxor Temple.',
    description:
        'Luxor Riverside offers twelve self-catering apartments in a quiet '
        'building set back one street from the East Bank corniche. Each has a '
        'separate bedroom, a full kitchen with a hob, fridge and kettle, and a '
        'balcony — the upper four look across the Nile towards the Theban '
        'hills. Luxor Temple is a five-minute walk and the ferry to the West '
        'Bank leaves from the jetty opposite. There is no restaurant on site, '
        'but a grocery and several cafés are on the same street.',
    searchTokens: _tokens([
      'egypt',
      'luxor',
      'east bank',
      'upper egypt',
      'nile',
    ]),
    checkInFrom: '13:00',
    checkOutUntil: '11:00',
    houseRules: const [
      'Self check-in with a key safe; the code is sent on the day of arrival.',
      'Children of all ages are welcome.',
      'Pets are allowed on request, free of charge.',
      'No parties or events.',
    ],
    imageUrls: const [
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600121848594-d8644e57abab?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?auto=format&fit=crop&w=1200&q=80',
    ],
    amenityIds: const [
      'free_wifi',
      'parking',
      'family_rooms',
      'non_smoking_rooms',
      'air_conditioning',
      'terrace',
      'pets_allowed',
      'laundry',
      'tea_coffee_maker',
    ],
    location: const HotelLocationDto(
      area: 'East Bank',
      city: 'Luxor',
      country: 'Egypt',
      address: '22 Khaled Ibn El Walid Street, East Bank, Luxor 85951',
      latitude: 25.6935,
      longitude: 32.6421,
      distanceFromCentreKm: 1.2,
      locationScore: 9.0,
      highlight: 'Five minutes on foot from Luxor Temple',
      nearbyLandmarks: [
        LandmarkDto(
          name: 'Luxor Temple',
          distanceKm: 0.4,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Karnak Temple',
          distanceKm: 2.9,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'West Bank Ferry Jetty',
          distanceKm: 0.3,
          categoryId: 'transport',
        ),
        LandmarkDto(
          name: 'Luxor International Airport',
          distanceKm: 6.8,
          categoryId: 'airport',
        ),
      ],
    ),
    reviews: const ReviewSummaryDto(
      score: 8.3,
      reviewCount: 642,
      categoryScores: {
        'staff': 8.6,
        'facilities': 7.9,
        'cleanliness': 8.4,
        'comfort': 8.2,
        'valueForMoney': 9.1,
        'location': 9.0,
        'freeWifi': 7.8,
      },
      highlightQuote:
          'Having a kitchen made a long stay much easier, and the balcony view '
          'of the Nile at sunset was the best part of the trip.',
      highlightAuthor: 'Sofie',
      highlightCountry: 'Denmark',
    ),
    roomOffers: const [
      RoomOfferDto(
        id: 'one-bedroom-nile-view',
        name: 'One-Bedroom Apartment with Nile View',
        pricePerNight: 2150,
        originalPricePerNight: 2600,
        maxOccupancy: 3,
        sizeSquareMetres: 55,
        beds: [
          BedConfigurationDto(typeId: 'double', quantity: 1),
          BedConfigurationDto(typeId: 'sofa_bed', quantity: 1),
        ],
        freeCancellation: true,
        payAtProperty: true,
        roomsLeft: 3,
        features: [
          'Private bathroom',
          'Nile view',
          'Full kitchen',
          'Washing machine',
          'Balcony',
        ],
      ),
      RoomOfferDto(
        id: 'studio-courtyard',
        name: 'Studio Apartment',
        pricePerNight: 1480,
        maxOccupancy: 2,
        sizeSquareMetres: 34,
        beds: [BedConfigurationDto(typeId: 'double', quantity: 1)],
        freeCancellation: true,
        payAtProperty: true,
        roomsLeft: 5,
        features: [
          'Private bathroom',
          'Kitchenette',
          'Air conditioning',
          'Street view',
        ],
      ),
      RoomOfferDto(
        id: 'two-bedroom-family',
        name: 'Two-Bedroom Family Apartment',
        pricePerNight: 3200,
        maxOccupancy: 5,
        sizeSquareMetres: 78,
        beds: [
          BedConfigurationDto(typeId: 'double', quantity: 1),
          BedConfigurationDto(typeId: 'single', quantity: 3),
        ],
        freeCancellation: true,
        payAtProperty: true,
        roomsLeft: 2,
        features: [
          'Two bathrooms',
          'Full kitchen',
          'Dining area',
          'Balcony',
          'Washing machine',
        ],
      ),
    ],
  );

  // ---------------------------------------------------------------- 5 of 5

  static final HotelDto _alexandriaCorniche = HotelDto(
    id: 'alexandria-corniche-guest-house',
    name: 'Alexandria Corniche Guest House',
    propertyTypeId: 'guest_house',
    starRating: 2,
    currency: 'EGP',
    summary:
        'Family-run guest house one block from the Stanley corniche, with a '
        'shared sea-view breakfast room.',
    description:
        'A nine-room guest house run by the same family since 1998, one block '
        'back from the corniche at Stanley. Rooms are simple and spotless, '
        'with high ceilings, ceiling fans and air conditioning; four have sea '
        'views. Breakfast is served in a shared room overlooking the bay and '
        'included in every rate. Stanley Bridge and the tram stop are both a '
        'few minutes away, and the owners will point you to the fish '
        'restaurants locals actually use.',
    searchTokens: _tokens([
      'egypt',
      'alexandria',
      'stanley',
      'sidi gaber',
      'mediterranean',
      'north coast',
    ]),
    checkInFrom: '14:00',
    checkOutUntil: '11:00',
    houseRules: const [
      'Breakfast is served between 07:30 and 10:30.',
      'Children over 4 are welcome.',
      'Pets are not allowed.',
      'Payment in cash on arrival; cards are not accepted.',
    ],
    imageUrls: const [
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1549877452-9c387954fbc2?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?auto=format&fit=crop&w=1200&q=80',
    ],
    amenityIds: const [
      'free_wifi',
      'family_rooms',
      'non_smoking_rooms',
      'front_desk_24h',
      'air_conditioning',
      'breakfast',
      'terrace',
      'tea_coffee_maker',
    ],
    location: const HotelLocationDto(
      area: 'Stanley',
      city: 'Alexandria',
      country: 'Egypt',
      address: '5 El Nasr Street, Stanley, Alexandria 21523',
      latitude: 31.2423,
      longitude: 29.9638,
      distanceFromCentreKm: 6.3,
      locationScore: 8.4,
      highlight: 'One block from the Stanley corniche',
      nearbyLandmarks: [
        LandmarkDto(
          name: 'Stanley Bridge',
          distanceKm: 0.5,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Bibliotheca Alexandrina',
          distanceKm: 4.9,
          categoryId: 'attraction',
        ),
        LandmarkDto(
          name: 'Sidi Gaber Railway Station',
          distanceKm: 2.1,
          categoryId: 'transport',
        ),
        LandmarkDto(
          name: 'Stanley Beach',
          distanceKm: 0.4,
          categoryId: 'beach',
        ),
      ],
    ),
    reviews: const ReviewSummaryDto(
      score: 7.6,
      reviewCount: 318,
      categoryScores: {
        'staff': 9.3,
        'facilities': 6.8,
        'cleanliness': 8.1,
        'comfort': 7.2,
        'valueForMoney': 8.9,
        'location': 8.4,
        'freeWifi': 7.1,
      },
      highlightQuote:
          'Basic but immaculate, and the family could not have been kinder. '
          'Breakfast on the terrace with the bay in front of you.',
      highlightAuthor: 'Youssef',
      highlightCountry: 'Egypt',
    ),
    roomOffers: const [
      RoomOfferDto(
        id: 'double-sea-view',
        name: 'Double Room with Sea View',
        pricePerNight: 1250,
        originalPricePerNight: 1500,
        maxOccupancy: 2,
        sizeSquareMetres: 20,
        beds: [BedConfigurationDto(typeId: 'double', quantity: 1)],
        breakfastIncluded: true,
        payAtProperty: true,
        roomsLeft: 2,
        features: [
          'Private bathroom',
          'Sea view',
          'Air conditioning',
          'Ceiling fan',
        ],
      ),
      RoomOfferDto(
        id: 'twin-street-view',
        name: 'Twin Room with Street View',
        pricePerNight: 980,
        maxOccupancy: 2,
        sizeSquareMetres: 18,
        beds: [BedConfigurationDto(typeId: 'twin', quantity: 2)],
        breakfastIncluded: true,
        freeCancellation: true,
        payAtProperty: true,
        roomsLeft: 4,
        features: [
          'Private bathroom',
          'Street view',
          'Air conditioning',
          'Desk',
        ],
      ),
      RoomOfferDto(
        id: 'triple-family',
        name: 'Triple Family Room',
        pricePerNight: 1620,
        maxOccupancy: 3,
        sizeSquareMetres: 26,
        beds: [
          BedConfigurationDto(typeId: 'double', quantity: 1),
          BedConfigurationDto(typeId: 'single', quantity: 1),
        ],
        breakfastIncluded: true,
        payAtProperty: true,
        roomsLeft: 1,
        features: [
          'Private bathroom',
          'Sea view',
          'Air conditioning',
          'Seating area',
        ],
      ),
    ],
  );
}
