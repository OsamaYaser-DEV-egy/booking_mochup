import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/widgets/score_badge.dart';
import '../../../domain/entities/hotel.dart';
import '../../../domain/entities/search_query.dart';

/// The summary beside the description: guest score, the stay and the lead
/// rate.
///
/// Presentation only. It reads the hotel's cheapest offer to show a "from"
/// price and does no arithmetic beyond multiplying by the number of nights;
/// there is no room selection, no tax and no total behind it.
class BookingPanel extends StatelessWidget {
  const BookingPanel({
    required this.hotel,
    required this.dates,
    required this.guests,
    super.key,
  });

  final Hotel hotel;
  final StayDates dates;
  final GuestSelection guests;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nights = dates.nights();
    final offer = hotel.bestOfferFor(guests.totalGuests);
    final total = offer.totalFor(nights);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScoreBadge(reviews: hotel.reviews),
          if (hotel.reviews.hasHighlight) ...[
            const SizedBox(height: AppSpacing.md),
            _Quote(hotel: hotel),
          ],
          const Divider(height: AppSpacing.xxl),
          Text(
            Formatters.dateRange(dates.checkIn, dates.checkOut),
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(guests.summary, style: textTheme.bodySmall),
          const Divider(height: AppSpacing.xxl),
          Text(
            'From, for ${Formatters.nights(nights)}',
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (offer.isDiscounted)
            Text(
              Formatters.money(
                offer.originalPricePerNight!.amount * nights,
                total.currency,
              ),
              style: textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: AppColors.inkSubtle,
              ),
            ),
          Text(
            Formatters.money(total.amount, total.currency),
            style: textTheme.headlineMedium,
          ),
          Text('+ taxes and charges', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.lg),
          // Inert by design: this screen is a visual mock, so the call to
          // action is styled but carries no booking behaviour.
          FilledButton(
            onPressed: () {},
            child: const Text('Reserve'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You will not be charged yet.',
            style: textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reviews = hotel.reviews;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“${reviews.highlightQuote!}”',
            style: textTheme.bodySmall?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [reviews.highlightAuthor, reviews.highlightCountry]
                .whereType<String>()
                .join(' · '),
            style: textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
