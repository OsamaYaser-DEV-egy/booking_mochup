import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/sort_option.dart';

/// Where a search currently stands.
enum SearchStatus {
  /// Nothing requested yet.
  initial,

  /// First load for this query — the list shows skeletons.
  loading,

  /// Re-running after a filter or sort change — the list stays visible and
  /// dims, which avoids a full-page flash on every checkbox tick.
  refreshing,

  /// Results are current.
  ready,

  /// The last attempt failed.
  failure;

  bool get isBusy => this == loading || this == refreshing;
}

/// The complete state of the search screen.
///
/// One immutable object holds the query, the user's narrowing choices and the
/// outcome together, so the UI renders from a single value and every
/// transition is explicit and comparable.
final class SearchState extends Equatable {
  const SearchState({
    required this.query,
    this.filters = SearchFilters.none,
    this.sortOption = SortOption.defaultOption,
    this.status = SearchStatus.initial,
    this.result = const SearchResult.empty(),
    this.failure,
  });

  /// Opening state for [destination], before anything has been fetched.
  SearchState.initial(String destination)
      : query = SearchQuery(destination: destination),
        filters = SearchFilters.none,
        sortOption = SortOption.defaultOption,
        status = SearchStatus.initial,
        result = const SearchResult.empty(),
        failure = null;

  final SearchQuery query;
  final SearchFilters filters;
  final SortOption sortOption;
  final SearchStatus status;
  final SearchResult result;
  final Failure? failure;

  /// True while the first load for a query is in flight and there is nothing
  /// to show yet.
  bool get showsSkeletons =>
      status == SearchStatus.loading && result.isEmpty;

  /// True when results are on screen but a new request is running.
  bool get showsStaleResults =>
      status == SearchStatus.refreshing && !result.isEmpty;

  bool get hasError => status == SearchStatus.failure && failure != null;

  /// True when the destination has properties but the filters excluded them.
  bool get showsFilteredOutMessage =>
      status == SearchStatus.ready && result.isFilteredOut;

  /// True when the destination itself has nothing.
  bool get showsNoPropertiesMessage =>
      status == SearchStatus.ready &&
      result.isEmpty &&
      result.totalCandidates == 0;

  SearchState copyWith({
    SearchQuery? query,
    SearchFilters? filters,
    SortOption? sortOption,
    SearchStatus? status,
    SearchResult? result,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      sortOption: sortOption ?? this.sortOption,
      status: status ?? this.status,
      result: result ?? this.result,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        query,
        filters,
        sortOption,
        status,
        result,
        failure,
      ];
}
