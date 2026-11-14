import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/search_filters.dart';
import '../entities/search_query.dart';
import '../entities/search_result.dart';
import '../entities/sort_option.dart';
import '../repositories/hotel_repository.dart';
import '../services/facet_calculator.dart';
import '../services/hotel_filter.dart';
import '../services/hotel_sorter.dart';

/// Everything needed to run a search.
final class SearchHotelsInput extends Equatable {
  const SearchHotelsInput({
    required this.query,
    this.filters = SearchFilters.none,
    this.sortOption = SortOption.defaultOption,
  });

  final SearchQuery query;
  final SearchFilters filters;
  final SortOption sortOption;

  @override
  List<Object?> get props => [query, filters, sortOption];
}

/// Fetches candidates for a destination, then narrows, orders and counts them.
///
/// The use case owns the orchestration only; each step of the work lives in a
/// dedicated collaborator it receives through the constructor, which is what
/// lets the whole pipeline be tested with simple fakes.
@lazySingleton
class SearchHotels implements UseCase<SearchResult, SearchHotelsInput> {
  const SearchHotels(
    this._repository,
    this._filter,
    this._sorter,
    this._facetCalculator,
  );

  final HotelRepository _repository;
  final HotelFilter _filter;
  final HotelSorter _sorter;
  final FacetCalculator _facetCalculator;

  @override
  Future<Either<Failure, SearchResult>> call(SearchHotelsInput input) async {
    if (!input.query.isValid) {
      return const Left(
        ValidationFailure('Enter a destination to start searching.'),
      );
    }

    final candidates =
        await _repository.findByDestination(input.query.destination);

    return candidates.map((hotels) {
      final matching = _filter.apply(hotels, input.filters);
      final ordered = _sorter.apply(matching, input.sortOption);

      return SearchResult(
        hotels: ordered,
        totalCandidates: hotels.length,
        facets: _facetCalculator.calculate(hotels, input.filters),
      );
    });
  }
}
