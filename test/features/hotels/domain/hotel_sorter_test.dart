import 'package:booking_mochup/features/hotels/domain/services/hotel_sorter.dart';
import 'package:booking_mochup/features/hotels/domain/entities/sort_option.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hotel_fixtures.dart';

void main() {
  const sorter = HotelSorter();

  group('HotelSorter', () {
    test('does not mutate the list it is given', () {
      final original = [
        HotelFixtures.hotel(id: 'expensive', pricePerNight: 5000),
        HotelFixtures.hotel(id: 'cheap', pricePerNight: 1000),
      ];
      final snapshot = List.of(original);

      sorter.apply(original, SortOption.priceLowest);

      expect(original, snapshot);
    });

    test('priceLowest orders by the cheapest offer, ascending', () {
      final hotels = [
        HotelFixtures.hotel(id: 'b', pricePerNight: 3000),
        HotelFixtures.hotel(id: 'c', pricePerNight: 5000),
        HotelFixtures.hotel(id: 'a', pricePerNight: 1000),
      ];

      final sorted = sorter.apply(hotels, SortOption.priceLowest);

      expect(sorted.map((hotel) => hotel.id), ['a', 'b', 'c']);
    });

    test('topReviewed orders by score, breaking ties on review volume', () {
      final hotels = [
        HotelFixtures.hotel(id: 'few', reviewScore: 9.0, reviewCount: 10),
        HotelFixtures.hotel(id: 'lower', reviewScore: 8.0, reviewCount: 9000),
        HotelFixtures.hotel(id: 'many', reviewScore: 9.0, reviewCount: 4000),
      ];

      final sorted = sorter.apply(hotels, SortOption.topReviewed);

      expect(sorted.map((hotel) => hotel.id), ['many', 'few', 'lower']);
    });

    test('propertyRatingHigh orders by stars, descending', () {
      final hotels = [
        HotelFixtures.hotel(id: 'three', starRating: 3),
        HotelFixtures.hotel(id: 'five', starRating: 5),
        HotelFixtures.hotel(id: 'four', starRating: 4),
      ];

      final sorted = sorter.apply(hotels, SortOption.propertyRatingHigh);

      expect(sorted.map((hotel) => hotel.id), ['five', 'four', 'three']);
    });

    test('propertyRatingLow is the exact reverse ordering of stars', () {
      final hotels = [
        HotelFixtures.hotel(id: 'three', starRating: 3),
        HotelFixtures.hotel(id: 'five', starRating: 5),
        HotelFixtures.hotel(id: 'four', starRating: 4),
      ];

      final sorted = sorter.apply(hotels, SortOption.propertyRatingLow);

      expect(sorted.map((hotel) => hotel.id), ['three', 'four', 'five']);
    });

    test('distanceFromCentre orders by distance, ascending', () {
      final hotels = [
        HotelFixtures.hotel(id: 'far', distanceFromCentreKm: 9),
        HotelFixtures.hotel(id: 'near', distanceFromCentreKm: 0.4),
        HotelFixtures.hotel(id: 'mid', distanceFromCentreKm: 3),
      ];

      final sorted = sorter.apply(hotels, SortOption.distanceFromCentre);

      expect(sorted.map((hotel) => hotel.id), ['near', 'mid', 'far']);
    });

    group('topPicks', () {
      test('prefers a well-reviewed property with many reviews over one '
          'with a marginally better score and almost none', () {
        final established = HotelFixtures.hotel(
          id: 'established',
          reviewScore: 8.9,
          reviewCount: 3000,
        );
        final newcomer = HotelFixtures.hotel(
          id: 'newcomer',
          reviewScore: 9.1,
          reviewCount: 3,
        );

        final sorted = sorter.apply(
          [newcomer, established],
          SortOption.topPicks,
        );

        expect(sorted.first.id, 'established');
      });

      test('promotes a preferred partner over an equal non-partner', () {
        final partner = HotelFixtures.hotel(
          id: 'partner',
          isPreferredPartner: true,
        );
        final plain = HotelFixtures.hotel(id: 'plain');

        final sorted = sorter.apply([plain, partner], SortOption.topPicks);

        expect(sorted.first.id, 'partner');
      });

      test('does not let review volume alone beat a much better score', () {
        final excellent = HotelFixtures.hotel(
          id: 'excellent',
          reviewScore: 9.5,
          reviewCount: 60,
        );
        final mediocre = HotelFixtures.hotel(
          id: 'mediocre',
          reviewScore: 7.0,
          reviewCount: 50000,
        );

        final sorted = sorter.apply(
          [mediocre, excellent],
          SortOption.topPicks,
        );

        expect(sorted.first.id, 'excellent');
      });
    });
  });
}
