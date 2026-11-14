import 'package:bloc_test/bloc_test.dart';
import 'package:booking_mochup/core/error/failures.dart';
import 'package:booking_mochup/features/hotels/domain/entities/amenity.dart';
import 'package:booking_mochup/features/hotels/domain/entities/search_filters.dart';
import 'package:booking_mochup/features/hotels/domain/entities/search_query.dart';
import 'package:booking_mochup/features/hotels/domain/entities/search_result.dart';
import 'package:booking_mochup/features/hotels/domain/entities/sort_option.dart';
import 'package:booking_mochup/features/hotels/domain/usecases/search_hotels.dart';
import 'package:booking_mochup/features/hotels/presentation/cubit/search_cubit.dart';
import 'package:booking_mochup/features/hotels/presentation/cubit/search_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../domain/hotel_fixtures.dart';

class _MockSearchHotels extends Mock implements SearchHotels {}

void main() {
  // SearchHotelsInput is a final class, so mocktail cannot fake it. A real
  // instance works just as well as a fallback value.
  setUpAll(
    () => registerFallbackValue(
      const SearchHotelsInput(query: SearchQuery(destination: 'fallback')),
    ),
  );

  late _MockSearchHotels searchHotels;

  final result = SearchResult(
    hotels: [HotelFixtures.hotel(id: 'a')],
    totalCandidates: 1,
    facets: const FilterFacets.empty(),
  );

  setUp(() {
    searchHotels = _MockSearchHotels();
    when(() => searchHotels(any())).thenAnswer((_) async => Right(result));
  });

  SearchCubit build() => SearchCubit(searchHotels);

  group('SearchCubit', () {
    blocTest<SearchCubit, SearchState>(
      'start emits loading then ready',
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.ready)
            .having((s) => s.result, 'result', result),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'a failed search ends in failure carrying the reason',
      build: build,
      setUp: () => when(() => searchHotels(any()))
          .thenAnswer((_) async => const Left(NetworkFailure())),
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.failure)
            .having((s) => s.failure, 'failure', const NetworkFailure()),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'a filter change refreshes rather than reloading, so the current '
      'results stay on screen',
      build: build,
      seed: () => SearchState(
        query: const SearchQuery(destination: 'Egypt'),
        status: SearchStatus.ready,
        result: result,
      ),
      act: (cubit) => cubit.toggleAmenity(Amenity.spa),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.filters.amenities, 'amenities', {Amenity.spa}),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.refreshing)
            .having((s) => s.result, 'keeps previous results', result),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.ready),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'a new destination clears filters, because the previous facets no '
      'longer apply',
      build: build,
      seed: () => const SearchState(
        query: SearchQuery(destination: 'Egypt'),
        filters: SearchFilters(starRatings: {5}),
        status: SearchStatus.ready,
      ),
      act: (cubit) => cubit.search(const SearchQuery(destination: 'Luxor')),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query.destination, 'destination', 'Luxor')
            .having((s) => s.filters, 'filters', SearchFilters.none),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.ready),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'selecting the sort option already in use emits nothing',
      build: build,
      seed: () => const SearchState(
        query: SearchQuery(destination: 'Egypt'),
        sortOption: SortOption.priceLowest,
        status: SearchStatus.ready,
      ),
      act: (cubit) => cubit.changeSort(SortOption.priceLowest),
      expect: () => const <SearchState>[],
    );

    blocTest<SearchCubit, SearchState>(
      'clearing filters when none are active emits nothing',
      build: build,
      seed: () => const SearchState(
        query: SearchQuery(destination: 'Egypt'),
        status: SearchStatus.ready,
      ),
      act: (cubit) => cubit.clearFilters(),
      expect: () => const <SearchState>[],
    );

    blocTest<SearchCubit, SearchState>(
      'passes the current query, filters and sort through to the use case',
      build: build,
      seed: () => const SearchState(
        query: SearchQuery(destination: 'Cairo'),
        filters: SearchFilters(starRatings: {5}),
        sortOption: SortOption.priceLowest,
        status: SearchStatus.ready,
      ),
      act: (cubit) => cubit.retry(),
      verify: (_) {
        final captured = verify(() => searchHotels(captureAny()))
            .captured
            .single as SearchHotelsInput;

        expect(captured.query.destination, 'Cairo');
        expect(captured.filters.starRatings, {5});
        expect(captured.sortOption, SortOption.priceLowest);
      },
    );
  });
}
