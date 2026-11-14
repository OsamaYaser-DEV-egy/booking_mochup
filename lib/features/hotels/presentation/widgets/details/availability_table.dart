import 'package:flutter/material.dart';

import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/widgets/feature_tag.dart';
import '../../../domain/entities/hotel.dart';
import '../../../domain/entities/room_offer.dart';
import 'details_section.dart';

/// The rooms on offer, as a read-only table.
///
/// Presentation only: it lists what each room is, who it sleeps, what it costs
/// for the stay and what the rate includes. There is no quantity picker and no
/// running total, because this screen carries no booking logic.
///
/// Wide viewports get a real table with a shared header; narrow ones get one
/// card per room. Both render the same [_OfferCells], so a column cannot
/// appear in one arrangement and go missing in the other.
class AvailabilityTable extends StatelessWidget {
  const AvailabilityTable({
    required this.hotel,
    required this.nights,
    required this.guests,
    super.key,
  });

  final Hotel hotel;
  final int nights;
  final int guests;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;

    return DetailsSection(
      title: 'Availability',
      subtitle: '${Formatters.nights(nights)} · '
          '${Formatters.adults(guests)} · prices shown for the whole stay',
      padded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isCompact) const _TableHeader(),
          for (final offer in hotel.roomOffers)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? AppSpacing.lg : 0,
                vertical: isCompact ? AppSpacing.sm : 0,
              ),
              child: _OfferRow(
                offer: offer,
                nights: nights,
                isCompact: isCompact,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Align(
              alignment: isCompact ? Alignment.center : Alignment.centerRight,
              // Inert by design: this screen is a visual mock.
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Reserve'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white);

    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('Room type', style: style)),
          Expanded(flex: 2, child: Text('Sleeps', style: style)),
          Expanded(flex: 3, child: Text('Price for the stay', style: style)),
          Expanded(flex: 3, child: Text('Your options', style: style)),
        ],
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({
    required this.offer,
    required this.nights,
    required this.isCompact,
  });

  final RoomOffer offer;
  final int nights;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final cells = _OfferCells(offer: offer, nights: nights);

    if (isCompact) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cells.roomType(context),
            const SizedBox(height: AppSpacing.md),
            cells.sleeps(context),
            const SizedBox(height: AppSpacing.md),
            cells.options(context),
            const SizedBox(height: AppSpacing.lg),
            cells.price(context),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: cells.roomType(context)),
          Expanded(flex: 2, child: cells.sleeps(context)),
          Expanded(flex: 3, child: cells.price(context)),
          Expanded(flex: 3, child: cells.options(context)),
        ],
      ),
    );
  }
}

/// The four pieces of information an offer row shows, in one place so both
/// arrangements stay in agreement.
class _OfferCells {
  const _OfferCells({required this.offer, required this.nights});

  final RoomOffer offer;
  final int nights;

  Widget roomType(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer.name,
          style: textTheme.titleMedium?.copyWith(color: AppColors.blue),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(offer.bedSummary, style: textTheme.bodySmall),
        if (offer.sizeSquareMetres != null)
          Text(
            '${offer.sizeSquareMetres!.round()} m²',
            style: textTheme.bodySmall,
          ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final feature in offer.features)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(feature, style: textTheme.labelSmall),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget sleeps(BuildContext context) {
    return Semantics(
      label: 'Sleeps ${offer.maxOccupancy}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < offer.maxOccupancy.clamp(0, 6); i++)
            const Icon(Icons.person_rounded, size: 17, color: AppColors.ink),
        ],
      ),
    );
  }

  Widget price(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = offer.totalFor(nights);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          style: textTheme.headlineSmall,
        ),
        Text('+ taxes and charges', style: textTheme.labelSmall),
      ],
    );
  }

  Widget options(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offer.breakfastIncluded)
          const _OptionLine(
            label: 'Breakfast included',
            icon: Icons.free_breakfast_rounded,
          ),
        if (offer.freeCancellation)
          const _OptionLine(
            label: 'Free cancellation',
            icon: Icons.check_circle_rounded,
          ),
        if (offer.payAtProperty)
          const _OptionLine(
            label: 'No prepayment needed',
            icon: Icons.schedule_rounded,
          ),
        if (offer.isScarce) ...[
          const SizedBox(height: AppSpacing.xs),
          FeatureTag(
            label: 'Only ${offer.roomsLeft} left',
            tone: TagTone.urgent,
            icon: Icons.priority_high_rounded,
          ),
        ],
      ],
    );
  }
}

class _OptionLine extends StatelessWidget {
  const _OptionLine({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
