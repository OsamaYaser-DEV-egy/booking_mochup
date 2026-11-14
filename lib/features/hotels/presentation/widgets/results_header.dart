import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/search_query.dart';

/// The line above the result list: destination, match count and stay summary.
class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    required this.query,
    required this.matchCount,
    super.key,
  });

  final SearchQuery query;
  final int matchCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${query.destination}: ${Formatters.count(matchCount)} '
          '${matchCount == 1 ? 'property' : 'properties'} found',
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.event_rounded,
              size: 14,
              color: AppColors.inkMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                [
                  Formatters.dateRange(
                    query.dates.checkIn,
                    query.dates.checkOut,
                  ),
                  query.guests.summary,
                ].join('  ·  '),
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
