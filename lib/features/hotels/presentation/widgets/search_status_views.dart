import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shared frame for the non-result states, so an error and an empty list are
/// laid out identically and only differ in what they say.
class SearchStatusView extends StatelessWidget {
  const SearchStatusView({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.action,
    this.tone = AppColors.inkSubtle,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.giant,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: tone),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
              textAlign: TextAlign.center,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Shown when a search fails.
class SearchErrorView extends StatelessWidget {
  const SearchErrorView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SearchStatusView(
      icon: _iconFor(failure),
      tone: AppColors.danger,
      title: _titleFor(failure),
      message: failure.message,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Try again'),
      ),
    );
  }

  IconData _iconFor(Failure failure) => switch (failure) {
        NetworkFailure() => Icons.wifi_off_rounded,
        NotFoundFailure() => Icons.search_off_rounded,
        _ => Icons.error_outline_rounded,
      };

  String _titleFor(Failure failure) => switch (failure) {
        NetworkFailure() => 'You appear to be offline',
        ValidationFailure() => 'Check your search',
        NotFoundFailure() => 'Nothing matched',
        _ => 'We could not load these results',
      };
}

/// Shown when the destination has properties but the filters excluded them.
class NoMatchesView extends StatelessWidget {
  const NoMatchesView({
    required this.totalCandidates,
    required this.onClearFilters,
    super.key,
  });

  final int totalCandidates;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return SearchStatusView(
      icon: Icons.filter_alt_off_rounded,
      title: 'No properties match your filters',
      message: 'There '
          '${totalCandidates == 1 ? 'is 1 property' : 'are $totalCandidates '
              'properties'} '
          'in this destination. Removing a filter or two should bring them '
          'back.',
      action: OutlinedButton.icon(
        onPressed: onClearFilters,
        icon: const Icon(Icons.clear_rounded, size: 18),
        label: const Text('Clear all filters'),
      ),
    );
  }
}

/// Shown when the destination itself has nothing.
class NoPropertiesView extends StatelessWidget {
  const NoPropertiesView({required this.destination, super.key});

  final String destination;

  @override
  Widget build(BuildContext context) {
    return SearchStatusView(
      icon: Icons.travel_explore_rounded,
      title: 'We have nothing in $destination yet',
      message: 'Try a nearby city, or a broader area such as a country or '
          'region.',
    );
  }
}
