import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/hotel.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/active_filter_chips.dart';
import '../widgets/app_brand_header.dart';
import '../widgets/filter_rail.dart';
import '../widgets/hotel_card.dart';
import '../widgets/hotel_card_skeleton.dart';
import '../widgets/results_header.dart';
import '../widgets/search_panel.dart';
import '../widgets/search_status_views.dart';
import '../widgets/sort_bar.dart';

/// The application's main screen: search, narrow, order, choose.
///
/// This widget's only job is to supply the cubit; everything visual lives in
/// [_SearchResultsView] and the widgets it composes, so the screen can be
/// pumped in a test with a stub cubit.
class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key});

  static const String routePath = '/';
  static const String routeName = 'search';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (_) => getIt<SearchCubit>()..start(),
      child: const _SearchResultsView(),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  const _SearchResultsView();

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  /// Saved properties, held locally because a wishlist needs an account and
  /// that is outside this screen's scope.
  final Set<String> _savedHotelIds = <String>{};

  void _toggleSaved(Hotel hotel) {
    setState(() {
      if (!_savedHotelIds.remove(hotel.id)) _savedHotelIds.add(hotel.id);
    });
  }

  void _announce(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFilterSheet(SearchCubit cubit, SearchState state) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.canvas,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => BlocProvider.value(
          value: cubit,
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (_, current) => SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: FilterRail(
                filters: current.filters,
                facets: current.result.facets,
                cubit: cubit,
                currency: AppConfig.defaultCurrency,
                showMapTeaser: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      body: Column(
        children: [
          const AppBrandHeader(),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => SingleChildScrollView(
                child: Column(
                  children: [
                    _SearchPanelStrip(
                      child: SearchPanel(
                        query: state.query,
                        onSubmit: cubit.search,
                      ),
                    ),
                    _ContentArea(
                      state: state,
                      cubit: cubit,
                      savedHotelIds: _savedHotelIds,
                      onToggleSaved: _toggleSaved,
                      onShowOnMap: (hotel) => _announce(
                        '${hotel.name} — ${hotel.location.address}',
                      ),
                      onOpenHotel: (hotel) => _announce(
                        'The property page for ${hotel.name} is next on the '
                        'roadmap.',
                      ),
                      onOpenFilters: () => _openFilterSheet(cubit, state),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The navy strip the search panel overlaps, which visually ties the panel to
/// the header rather than letting it float on the canvas.
class _SearchPanelStrip extends StatelessWidget {
  const _SearchPanelStrip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navy, AppColors.navy, AppColors.canvas],
          stops: [0, 0.6, 0.6],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.lg : AppSpacing.xxl,
        0,
        isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

/// The centred content column: filter rail plus results.
class _ContentArea extends StatelessWidget {
  const _ContentArea({
    required this.state,
    required this.cubit,
    required this.savedHotelIds,
    required this.onToggleSaved,
    required this.onShowOnMap,
    required this.onOpenHotel,
    required this.onOpenFilters,
  });

  final SearchState state;
  final SearchCubit cubit;
  final Set<String> savedHotelIds;
  final ValueChanged<Hotel> onToggleSaved;
  final ValueChanged<Hotel> onShowOnMap;
  final ValueChanged<Hotel> onOpenHotel;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final formFactor = context.formFactor;
    final isCompact = formFactor.isCompact;

    final results = _ResultsColumn(
      state: state,
      cubit: cubit,
      savedHotelIds: savedHotelIds,
      onToggleSaved: onToggleSaved,
      onShowOnMap: onShowOnMap,
      onOpenHotel: onOpenHotel,
      onOpenFilters: onOpenFilters,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.lg,
        isCompact ? AppSpacing.lg : AppSpacing.xxl,
        AppSpacing.giant,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: formFactor.usesFilterSheet
              ? results
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: AppLayout.filterRailWidth,
                      child: FilterRail(
                        filters: state.filters,
                        facets: state.result.facets,
                        cubit: cubit,
                        currency: AppConfig.defaultCurrency,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    Expanded(child: results),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ResultsColumn extends StatelessWidget {
  const _ResultsColumn({
    required this.state,
    required this.cubit,
    required this.savedHotelIds,
    required this.onToggleSaved,
    required this.onShowOnMap,
    required this.onOpenHotel,
    required this.onOpenFilters,
  });

  final SearchState state;
  final SearchCubit cubit;
  final Set<String> savedHotelIds;
  final ValueChanged<Hotel> onToggleSaved;
  final ValueChanged<Hotel> onShowOnMap;
  final ValueChanged<Hotel> onOpenHotel;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final usesSheet = context.formFactor.usesFilterSheet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultsHeader(query: state.query, matchCount: state.result.matchCount),
        const SizedBox(height: AppSpacing.lg),
        if (usesSheet)
          Row(
            children: [
              Expanded(
                child: SortBar(
                  selected: state.sortOption,
                  onChanged: cubit.changeSort,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilterSheetButton(
                  activeCount: state.filters.activeCount,
                  onPressed: onOpenFilters,
                ),
              ),
            ],
          )
        else
          SortBar(selected: state.sortOption, onChanged: cubit.changeSort),
        if (state.filters.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ActiveFilterChips(
            filters: state.filters,
            cubit: cubit,
            currency: AppConfig.defaultCurrency,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _ResultsBody(
          state: state,
          cubit: cubit,
          savedHotelIds: savedHotelIds,
          onToggleSaved: onToggleSaved,
          onShowOnMap: onShowOnMap,
          onOpenHotel: onOpenHotel,
        ),
      ],
    );
  }
}

/// Chooses between skeletons, the list and the three non-result states.
class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.state,
    required this.cubit,
    required this.savedHotelIds,
    required this.onToggleSaved,
    required this.onShowOnMap,
    required this.onOpenHotel,
  });

  final SearchState state;
  final SearchCubit cubit;
  final Set<String> savedHotelIds;
  final ValueChanged<Hotel> onToggleSaved;
  final ValueChanged<Hotel> onShowOnMap;
  final ValueChanged<Hotel> onOpenHotel;

  @override
  Widget build(BuildContext context) {
    if (state.showsSkeletons) {
      return const Column(
        children: [
          HotelCardSkeleton(),
          SizedBox(height: AppSpacing.lg),
          HotelCardSkeleton(),
          SizedBox(height: AppSpacing.lg),
          HotelCardSkeleton(),
        ],
      );
    }

    if (state.hasError) {
      return SearchErrorView(failure: state.failure!, onRetry: cubit.retry);
    }

    if (state.showsFilteredOutMessage) {
      return NoMatchesView(
        totalCandidates: state.result.totalCandidates,
        onClearFilters: cubit.clearFilters,
      );
    }

    if (state.showsNoPropertiesMessage) {
      return NoPropertiesView(destination: state.query.destination);
    }

    // The catalogue is small enough to build eagerly. A paginated catalogue
    // would move this column into a sliver list fed by the cubit.
    final list = Column(
      children: [
        for (final hotel in state.result.hotels) ...[
          HotelCard(
            hotel: hotel,
            nights: state.query.nights,
            guests: state.query.guests,
            isSaved: savedHotelIds.contains(hotel.id),
            onToggleSaved: () => onToggleSaved(hotel),
            onShowOnMap: () => onShowOnMap(hotel),
            onTap: () => onOpenHotel(hotel),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );

    // While a filter change is in flight the existing list stays in place and
    // dims, so the page does not flash empty on every checkbox tick.
    return AnimatedOpacity(
      opacity: state.showsStaleResults ? 0.55 : 1,
      duration: const Duration(milliseconds: 150),
      child: list,
    );
  }
}
