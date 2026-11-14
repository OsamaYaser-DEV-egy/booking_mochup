import 'package:flutter/material.dart';

import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/feature_tag.dart';
import '../../../../../shared/widgets/star_rating.dart';
import '../../../domain/entities/hotel.dart';

/// Name, rating, address and the top-level actions for a property.
///
/// The actions are styled but inert: this screen is presentation only, so
/// they carry no behaviour. They are given empty handlers rather than null so
/// they render in their normal state instead of looking disabled.
class HotelIdentityHeader extends StatelessWidget {
  const HotelIdentityHeader({required this.hotel, super.key});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;
    final textTheme = Theme.of(context).textTheme;

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StarRating(rating: hotel.starRating, size: 16),
            Text(hotel.propertyType.label, style: textTheme.labelSmall),
            if (hotel.isPreferredPartner)
              const FeatureTag(
                label: 'Preferred partner',
                tone: TagTone.informative,
                icon: Icons.thumb_up_rounded,
              ),
            if (hotel.isSustainable)
              FeatureTag(
                label: hotel.sustainability!.label,
                tone: TagTone.positive,
                icon: Icons.eco_rounded,
              ),
            if (hotel.hasMemberDiscount)
              const FeatureTag(
                label: 'Member price available',
                tone: TagTone.promotional,
                icon: Icons.card_membership_rounded,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          hotel.name,
          style: isCompact ? textTheme.headlineMedium : textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(
              Icons.place_outlined,
              size: 16,
              color: AppColors.inkMuted,
            ),
            Text(hotel.location.address, style: textTheme.bodyMedium),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
              child: const Text('Show on map'),
            ),
          ],
        ),
        if (hotel.location.hasExcellentLocation &&
            hotel.location.highlight != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FeatureTag(
            label: hotel.location.highlight!,
            tone: TagTone.positive,
            icon: Icons.location_on_rounded,
          ),
        ],
      ],
    );

    final actions = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border_rounded, size: 18),
          label: const Text('Save'),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: const Text('Share'),
        ),
        FilledButton(
          onPressed: () {},
          child: const Text('Reserve'),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          identity,
          const SizedBox(height: AppSpacing.lg),
          actions,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: identity),
        const SizedBox(width: AppSpacing.xl),
        actions,
      ],
    );
  }
}
