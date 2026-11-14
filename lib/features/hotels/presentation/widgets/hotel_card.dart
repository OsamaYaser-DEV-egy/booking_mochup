import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/feature_tag.dart';
import '../../../../shared/widgets/score_badge.dart';
import '../../../../shared/widgets/star_rating.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/room_offer.dart';
import '../../domain/entities/search_query.dart';

/// One property in the result list.
///
/// The card composes three regions — gallery, description and the price
/// column — and swaps between a horizontal and a stacked arrangement at the
/// compact breakpoint. The regions themselves are shared between both
/// arrangements, so the two layouts can never show different information.
class HotelCard extends StatelessWidget {
  const HotelCard({
    required this.hotel,
    required this.nights,
    required this.guests,
    super.key,
    this.onTap,
    this.onShowOnMap,
    this.isSaved = false,
    this.onToggleSaved,
  });

  final Hotel hotel;

  /// Nights in the current search, used to price the stay.
  final int nights;

  final GuestSelection guests;

  final VoidCallback? onTap;
  final VoidCallback? onShowOnMap;
  final bool isSaved;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final isStacked = context.formFactor.isCompact;
    final offer = hotel.bestOfferFor(guests.totalGuests);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: isStacked
              ? _StackedLayout(
                  hotel: hotel,
                  offer: offer,
                  nights: nights,
                  guests: guests,
                  isSaved: isSaved,
                  onToggleSaved: onToggleSaved,
                  onShowOnMap: onShowOnMap,
                  onTap: onTap,
                )
              : _HorizontalLayout(
                  hotel: hotel,
                  offer: offer,
                  nights: nights,
                  guests: guests,
                  isSaved: isSaved,
                  onToggleSaved: onToggleSaved,
                  onShowOnMap: onShowOnMap,
                  onTap: onTap,
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- arrangements

class _HorizontalLayout extends StatelessWidget {
  const _HorizontalLayout({
    required this.hotel,
    required this.offer,
    required this.nights,
    required this.guests,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onShowOnMap,
    required this.onTap,
  });

  final Hotel hotel;
  final RoomOffer offer;
  final int nights;
  final GuestSelection guests;
  final bool isSaved;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onShowOnMap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Gallery(
          hotel: hotel,
          width: 232,
          height: 212,
          isSaved: isSaved,
          onToggleSaved: onToggleSaved,
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _Description(
            hotel: hotel,
            offer: offer,
            onShowOnMap: onShowOnMap,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 196,
          child: _PriceColumn(
            hotel: hotel,
            offer: offer,
            nights: nights,
            guests: guests,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _StackedLayout extends StatelessWidget {
  const _StackedLayout({
    required this.hotel,
    required this.offer,
    required this.nights,
    required this.guests,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onShowOnMap,
    required this.onTap,
  });

  final Hotel hotel;
  final RoomOffer offer;
  final int nights;
  final GuestSelection guests;
  final bool isSaved;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onShowOnMap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Gallery(
          hotel: hotel,
          height: 180,
          isSaved: isSaved,
          onToggleSaved: onToggleSaved,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Heading(hotel: hotel),
            ),
            const SizedBox(width: AppSpacing.sm),
            ScoreBadge(reviews: hotel.reviews, compact: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${hotel.reviews.band.label} · '
          '${Formatters.count(hotel.reviews.reviewCount)} reviews',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LocationLine(hotel: hotel, onShowOnMap: onShowOnMap),
        const SizedBox(height: AppSpacing.md),
        _OfferSummary(hotel: hotel, offer: offer),
        const SizedBox(height: AppSpacing.md),
        _PriceColumn(
          hotel: hotel,
          offer: offer,
          nights: nights,
          guests: guests,
          onTap: onTap,
          alignment: CrossAxisAlignment.start,
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------- regions

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.hotel,
    required this.height,
    required this.isSaved,
    required this.onToggleSaved,
    this.width,
  });

  final Hotel hotel;
  final double? width;
  final double height;
  final bool isSaved;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              url: hotel.thumbnailUrl,
              semanticLabel: hotel.name,
            ),
            if (hotel.isDiscounted)
              Positioned(
                left: AppSpacing.sm,
                top: AppSpacing.sm,
                child: FeatureTag(
                  label: '${hotel.leadOffer.discountPercent}% off',
                  tone: TagTone.promotional,
                  icon: Icons.local_offer_rounded,
                ),
              ),
            Positioned(
              right: AppSpacing.xs,
              top: AppSpacing.xs,
              child: _SaveButton(
                isSaved: isSaved,
                onPressed: onToggleSaved,
                hotelName: hotel.name,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isSaved,
    required this.onPressed,
    required this.hotelName,
  });

  final bool isSaved;
  final VoidCallback? onPressed;
  final String hotelName;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isSaved ? 'Remove from your saved list' : 'Save for later',
      child: IconButton(
        onPressed: onPressed,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: isSaved ? AppColors.danger : AppColors.inkMuted,
          padding: const EdgeInsets.all(AppSpacing.sm),
        ),
        icon: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        ),
        tooltip: null,
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.hotel,
    required this.offer,
    required this.onShowOnMap,
  });

  final Hotel hotel;
  final RoomOffer offer;
  final VoidCallback? onShowOnMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(hotel: hotel),
        const SizedBox(height: AppSpacing.xs),
        _LocationLine(hotel: hotel, onShowOnMap: onShowOnMap),
        if (hotel.summary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            hotel.summary,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _OfferSummary(hotel: hotel, offer: offer),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel.name,
          style: textTheme.titleLarge?.copyWith(color: AppColors.blue),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StarRating(rating: hotel.starRating),
            Text(hotel.propertyType.label, style: textTheme.labelSmall),
            if (hotel.isPreferredPartner)
              const FeatureTag(
                label: 'Preferred',
                tone: TagTone.informative,
                icon: Icons.thumb_up_rounded,
              ),
            if (hotel.isSustainable)
              FeatureTag(
                label: hotel.sustainability!.label,
                tone: TagTone.positive,
                icon: Icons.eco_rounded,
              ),
          ],
        ),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.hotel, required this.onShowOnMap});

  final Hotel hotel;
  final VoidCallback? onShowOnMap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final location = hotel.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              location.shortLabel,
              style: textTheme.labelMedium?.copyWith(color: AppColors.blue),
            ),
            InkWell(
              onTap: onShowOnMap,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: Text(
                'Show on map',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.blue,
                ),
              ),
            ),
            Text(
              Formatters.distance(location.distanceFromCentreKm),
              style: textTheme.labelSmall,
            ),
          ],
        ),
        if (location.hasExcellentLocation && location.highlight != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.place_rounded,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  location.highlight!,
                  style: textTheme.labelMedium
                      ?.copyWith(color: AppColors.success),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OfferSummary extends StatelessWidget {
  const _OfferSummary({required this.hotel, required this.offer});

  final Hotel hotel;
  final RoomOffer offer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer.name,
          style: textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          [
            offer.bedSummary,
            if (offer.sizeSquareMetres != null)
              '${offer.sizeSquareMetres!.round()} m²',
          ].join(' · '),
          style: textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (offer.breakfastIncluded)
              const FeatureTag(
                label: 'Breakfast included',
                tone: TagTone.positive,
                icon: Icons.free_breakfast_rounded,
              ),
            if (offer.freeCancellation)
              const FeatureTag(
                label: 'Free cancellation',
                tone: TagTone.positive,
                icon: Icons.check_circle_rounded,
              ),
            if (offer.payAtProperty)
              const FeatureTag(
                label: 'No prepayment needed',
                tone: TagTone.neutral,
                icon: Icons.schedule_rounded,
              ),
            if (hotel.hasMemberDiscount)
              const FeatureTag(
                label: 'Member price',
                tone: TagTone.promotional,
                icon: Icons.card_membership_rounded,
              ),
          ],
        ),
      ],
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.hotel,
    required this.offer,
    required this.nights,
    required this.guests,
    required this.onTap,
    this.alignment = CrossAxisAlignment.end,
  });

  final Hotel hotel;
  final RoomOffer offer;
  final int nights;
  final GuestSelection guests;
  final VoidCallback? onTap;
  final CrossAxisAlignment alignment;

  bool get _isTrailing => alignment == CrossAxisAlignment.end;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = offer.totalFor(nights);
    final textAlign = _isTrailing ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (_isTrailing) ...[
          ScoreBadge(reviews: hotel.reviews),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          '${Formatters.nights(nights)}, ${Formatters.adults(guests.adults)}',
          style: textTheme.labelSmall,
          textAlign: textAlign,
        ),
        const SizedBox(height: AppSpacing.xxs),
        if (offer.isDiscounted)
          Text(
            Formatters.money(
              offer.originalPricePerNight!.amount * nights,
              offer.pricePerNight.currency,
            ),
            style: textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppColors.inkSubtle,
            ),
            textAlign: textAlign,
          ),
        Text(
          Formatters.money(total.amount, total.currency),
          style: textTheme.headlineSmall,
          textAlign: textAlign,
        ),
        Text(
          '+ taxes and charges',
          style: textTheme.labelSmall,
          textAlign: textAlign,
        ),
        if (offer.isScarce) ...[
          const SizedBox(height: AppSpacing.sm),
          FeatureTag(
            label: 'Only ${offer.roomsLeft} left on our site',
            tone: TagTone.urgent,
            icon: Icons.priority_high_rounded,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: _isTrailing ? double.infinity : null,
          child: FilledButton(
            onPressed: onTap,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('See availability'),
                SizedBox(width: AppSpacing.xs),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
