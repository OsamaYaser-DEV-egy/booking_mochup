import 'package:flutter/material.dart';

import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/widgets/score_badge.dart';
import '../../../domain/entities/review_summary.dart';
import 'details_section.dart';

/// Overall guest score plus the per-category breakdown.
class GuestReviewsSection extends StatelessWidget {
  const GuestReviewsSection({required this.reviews, super.key});

  final ReviewSummary reviews;

  @override
  Widget build(BuildContext context) {
    final columns = context.formFactor.isCompact ? 1 : 2;
    final categories = reviews.categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DetailsSection(
      title: 'Guest reviews',
      subtitle: reviews.hasReviews
          ? '${Formatters.count(reviews.reviewCount)} verified reviews'
          : 'No reviews yet',
      trailing: ScoreBadge(reviews: reviews, showCount: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Laid out as rows of Expanded cells rather than a GridView, so each
          // row takes the height its content needs. A fixed childAspectRatio
          // overflows as soon as a label wraps or the text scale changes.
          for (var start = 0; start < categories.length; start += columns)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var column = 0; column < columns; column++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: column < columns - 1 ? AppSpacing.xxl : 0,
                        ),
                        child: start + column < categories.length
                            ? _CategoryBar(
                                category: categories[start + column].key,
                                score: categories[start + column].value,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
            ),
          if (reviews.hasHighlight) ...[
            const SizedBox(height: AppSpacing.xl),
            _HighlightQuote(reviews: reviews),
          ],
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.category, required this.score});

  final ReviewCategory category;
  final double score;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '${category.label}: ${score.toStringAsFixed(1)} out of 10',
      excludeSemantics: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(category.label, style: textTheme.bodyMedium),
              ),
              Text(score.toStringAsFixed(1), style: textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: (score / 10).clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(_colourFor(score)),
            ),
          ),
        ],
      ),
    );
  }

  /// Bars are tinted by band so a weak category is visible at a glance rather
  /// than only readable from its number.
  Color _colourFor(double score) {
    if (score >= 9) return AppColors.success;
    if (score >= 8) return AppColors.blue;
    if (score >= 7) return AppColors.amber;
    return AppColors.danger;
  }
}

class _HighlightQuote extends StatelessWidget {
  const _HighlightQuote({required this.reviews});

  final ReviewSummary reviews;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.inkSubtle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(reviews.highlightQuote!, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.navy,
                child: Text(
                  (reviews.highlightAuthor ?? '?').characters.first,
                  style: textTheme.labelMedium?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                [reviews.highlightAuthor, reviews.highlightCountry]
                    .whereType<String>()
                    .join(' · '),
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
