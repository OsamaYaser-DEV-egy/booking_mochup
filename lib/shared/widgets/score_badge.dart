import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../features/hotels/domain/entities/review_summary.dart';

/// The guest-score block: band label, review count and the numeric badge.
///
/// Rendered as one widget so the badge, its label and its count can never
/// disagree about the score they describe.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    required this.reviews,
    super.key,
    this.compact = false,
    this.showCount = true,
  });

  final ReviewSummary reviews;

  /// Drops the text column and shows the numeric badge alone, for tight
  /// layouts such as a card image overlay.
  final bool compact;

  final bool showCount;

  @override
  Widget build(BuildContext context) {
    if (compact) return _Badge(reviews: reviews);

    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reviews.band.label,
                style: textTheme.titleSmall,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
              if (showCount && reviews.hasReviews)
                Text(
                  '${Formatters.count(reviews.reviewCount)} reviews',
                  style: textTheme.labelSmall,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _Badge(reviews: reviews),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.reviews});

  final ReviewSummary reviews;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Guest score ${reviews.formattedScore} out of 10, '
          '${reviews.band.label}',
      child: Container(
        width: 38,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.md),
            topRight: Radius.circular(AppRadius.md),
            bottomRight: Radius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          reviews.formattedScore,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
