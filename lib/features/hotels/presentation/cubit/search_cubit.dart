import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/amenity.dart';
import '../../domain/entities/property_type.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/sort_option.dart';
import '../../domain/usecases/search_hotels.dart';
import 'search_state.dart';

/// Drives the search-results screen.
///
/// The cubit holds no business rules: it records what the user chose, asks
/// [SearchHotels] for the outcome and publishes the result. Everything about
/// *how* results are narrowed, ordered or counted lives in the domain, which
/// is why this class stays short no matter how many filters are added.
@injectable
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchHotels)
      : super(SearchState.initial(AppConfig.defaultDestination));

  final SearchHotels _searchHotels;

  /// Loads the destination the screen opened with.
  Future<void> start() => _run(isFirstLoad: true);

  /// Runs a new search for [query], resetting filters because facet bounds
  /// from the previous destination no longer apply.
  Future<void> search(SearchQuery query) {
    emit(
      state.copyWith(
        query: query,
        filters: SearchFilters.none,
        clearFailure: true,
      ),
    );
    return _run(isFirstLoad: true);
  }

  /// Retries the current query after a failure.
  Future<void> retry() => _run(isFirstLoad: state.result.isEmpty);

  // ------------------------------------------------------------------ sorting

  Future<void> changeSort(SortOption option) {
    if (option == state.sortOption) return Future.value();
    emit(state.copyWith(sortOption: option));
    return _run();
  }

  // ------------------------------------------------------------------ filters

  Future<void> togglePropertyType(PropertyType type) =>
      _applyFilters(state.filters.togglePropertyType(type));

  Future<void> toggleStarRating(int stars) =>
      _applyFilters(state.filters.toggleStarRating(stars));

  Future<void> toggleAmenity(Amenity amenity) =>
      _applyFilters(state.filters.toggleAmenity(amenity));

  Future<void> togglePopularFilter(PopularFilter filter) =>
      _applyFilters(state.filters.togglePopularFilter(filter));

  Future<void> changePriceRange(PriceRange range) =>
      _applyFilters(state.filters.copyWith(priceRange: range));

  Future<void> clearPriceRange() =>
      _applyFilters(state.filters.copyWith(clearPriceRange: true));

  Future<void> changeMinReviewScore(double? score) => _applyFilters(
        score == null
            ? state.filters.copyWith(clearMinReviewScore: true)
            : state.filters.copyWith(minReviewScore: score),
      );

  Future<void> changeMaxDistance(double? kilometres) => _applyFilters(
        kilometres == null
            ? state.filters.copyWith(clearMaxDistance: true)
            : state.filters.copyWith(maxDistanceFromCentreKm: kilometres),
      );

  Future<void> clearFilters() {
    if (state.filters.isEmpty) return Future.value();
    return _applyFilters(SearchFilters.none);
  }

  Future<void> _applyFilters(SearchFilters filters) {
    if (filters == state.filters) return Future.value();
    emit(state.copyWith(filters: filters));
    return _run();
  }

  // ---------------------------------------------------------------- execution

  /// Issues the search for the current state.
  ///
  /// [isFirstLoad] distinguishes a cold load, which shows skeletons, from a
  /// filter change, which keeps the existing list on screen while it refreshes.
  Future<void> _run({bool isFirstLoad = false}) async {
    emit(
      state.copyWith(
        status: isFirstLoad ? SearchStatus.loading : SearchStatus.refreshing,
        result: isFirstLoad ? const SearchResult.empty() : null,
        clearFailure: true,
      ),
    );

    final outcome = await _searchHotels(
      SearchHotelsInput(
        query: state.query,
        filters: state.filters,
        sortOption: state.sortOption,
      ),
    );

    if (isClosed) return;

    emit(
      outcome.fold(
        (failure) => state.copyWith(
          status: SearchStatus.failure,
          failure: failure,
        ),
        (result) => state.copyWith(
          status: SearchStatus.ready,
          result: result,
          clearFailure: true,
        ),
      ),
    );
  }
}
