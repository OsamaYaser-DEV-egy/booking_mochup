import 'package:booking_mochup/features/hotels/domain/entities/amenity.dart';
import 'package:booking_mochup/features/hotels/domain/entities/property_type.dart';
import 'package:booking_mochup/features/hotels/domain/entities/room_offer.dart';
import 'package:booking_mochup/features/hotels/domain/entities/search_filters.dart';
import 'package:booking_mochup/features/hotels/domain/services/hotel_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hotel_fixtures.dart';

void main() {
  const filter = HotelFilter();

  group('HotelFilter', () {
    test('returns every candidate when no filter is active', () {
      final candidates = [
        HotelFixtures.hotel(id: 'a'),
        HotelFixtures.hotel(id: 'b'),
      ];

      expect(filter.apply(candidates, SearchFilters.none), candidates);
    });

    test('preserves the order of the candidates it keeps', () {
      final candidates = [
        HotelFixtures.hotel(id: 'a', starRating: 5),
        HotelFixtures.hotel(id: 'b', starRating: 3),
        HotelFixtures.hotel(id: 'c', starRating: 5),
      ];

      final kept = filter.apply(
        candidates,
        const SearchFilters(starRatings: {5}),
      );

      expect(kept.map((hotel) => hotel.id), ['a', 'c']);
    });

    group('price', () {
      test('keeps a hotel whose lead price is inside the range', () {
        final hotel = HotelFixtures.hotel(pricePerNight: 1500);

        final kept = filter.apply(
          [hotel],
          const SearchFilters(priceRange: PriceRange(min: 1000, max: 2000)),
        );

        expect(kept, hasLength(1));
      });

      test('excludes a hotel priced above the range', () {
        final hotel = HotelFixtures.hotel(pricePerNight: 2500);

        final kept = filter.apply(
          [hotel],
          const SearchFilters(priceRange: PriceRange(min: 1000, max: 2000)),
        );

        expect(kept, isEmpty);
      });

      test('compares against the cheapest offer, not the first one', () {
        final hotel = HotelFixtures.hotel(
          roomOffers: [
            HotelFixtures.offer(id: 'pricey', pricePerNight: 5000),
            HotelFixtures.offer(id: 'cheap', pricePerNight: 1200),
          ],
        );

        final kept = filter.apply(
          [hotel],
          const SearchFilters(priceRange: PriceRange(min: 1000, max: 2000)),
        );

        expect(kept, hasLength(1));
      });
    });

    group('amenities', () {
      test('requires every selected amenity to be present', () {
        final hotel = HotelFixtures.hotel(
          amenities: const [Amenity.freeWifi, Amenity.spa],
        );

        expect(
          filter.apply(
            [hotel],
            const SearchFilters(amenities: {Amenity.freeWifi, Amenity.spa}),
          ),
          hasLength(1),
        );
        expect(
          filter.apply(
            [hotel],
            const SearchFilters(
              amenities: {Amenity.freeWifi, Amenity.beachfront},
            ),
          ),
          isEmpty,
        );
      });
    });

    group('popular filters', () {
      test('breakfast matches a hotel with any breakfast offer', () {
        final hotel = HotelFixtures.hotel(
          roomOffers: [
            HotelFixtures.offer(id: 'plain'),
            HotelFixtures.offer(id: 'with-breakfast', breakfastIncluded: true),
          ],
        );

        final kept = filter.apply(
          [hotel],
          const SearchFilters(
            popularFilters: {PopularFilter.breakfastIncluded},
          ),
        );

        expect(kept, hasLength(1));
      });

      test('double bed matches double, queen and king configurations', () {
        for (final type in [BedType.double_, BedType.queen, BedType.king]) {
          final hotel = HotelFixtures.hotel(
            beds: [BedConfiguration(type: type, quantity: 1)],
          );

          expect(
            filter.apply(
              [hotel],
              const SearchFilters(popularFilters: {PopularFilter.doubleBed}),
            ),
            hasLength(1),
            reason: '$type should satisfy the double-bed filter',
          );
        }
      });

      test('double bed does not match a twin-only configuration', () {
        final hotel = HotelFixtures.hotel(
          beds: const [BedConfiguration(type: BedType.twin, quantity: 2)],
        );

        expect(
          filter.apply(
            [hotel],
            const SearchFilters(popularFilters: {PopularFilter.doubleBed}),
          ),
          isEmpty,
        );
      });

      test('very good and up uses a score of 8 as the threshold', () {
        final atThreshold = HotelFixtures.hotel(id: 'at', reviewScore: 8);
        final below = HotelFixtures.hotel(id: 'below', reviewScore: 7.9);

        final kept = filter.apply(
          [atThreshold, below],
          const SearchFilters(popularFilters: {PopularFilter.veryGoodAndUp}),
        );

        expect(kept.map((hotel) => hotel.id), ['at']);
      });
    });

    test('combines filters across groups with AND', () {
      final matching = HotelFixtures.hotel(
        id: 'matching',
        propertyType: PropertyType.resort,
        starRating: 5,
        reviewScore: 9,
      );
      final wrongType = HotelFixtures.hotel(
        id: 'wrong-type',
        propertyType: PropertyType.hostel,
        starRating: 5,
        reviewScore: 9,
      );

      final kept = filter.apply(
        [matching, wrongType],
        const SearchFilters(
          propertyTypes: {PropertyType.resort},
          starRatings: {5},
          minReviewScore: 8.5,
        ),
      );

      expect(kept.map((hotel) => hotel.id), ['matching']);
    });

    test('distance filter is inclusive of the boundary', () {
      final hotel = HotelFixtures.hotel(distanceFromCentreKm: 5);

      expect(
        filter.apply(
          [hotel],
          const SearchFilters(maxDistanceFromCentreKm: 5),
        ),
        hasLength(1),
      );
    });
  });
}
