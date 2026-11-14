import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/search_query.dart';
import '../widgets/app_brand_header.dart';
import '../widgets/details/availability_table.dart';
import '../widgets/details/booking_panel.dart';
import '../widgets/details/hotel_gallery.dart';
import '../widgets/details/hotel_identity_header.dart';
import '../widgets/details/guest_reviews_section.dart';
import '../widgets/details/property_info_sections.dart';
import '../widgets/details/unavailable_property_view.dart';

/// The property page.
///
/// This screen is presentation only. It takes a [Hotel] that the results list
/// already loaded and renders it — there is no cubit, no fetch and no booking
/// logic behind it. That is a deliberate scope choice, and it is why the page
/// is a plain [StatelessWidget] rather than the cubit-backed screen the search
/// results use.
///
/// The consequence is that the page cannot restore itself from a cold URL: a
/// shared or refreshed link arrives with no hotel, and [UnavailablePropertyView]
/// sends the visitor back to the results instead.
class HotelDetailsPage extends StatelessWidget {
  const HotelDetailsPage({
    required this.hotel,
    required this.dates,
    required this.guests,
    super.key,
  });

  static const String routeName = 'hotel-details';

  /// Null when the route was opened directly rather than from the results.
  final Hotel? hotel;

  final StayDates dates;
  final GuestSelection guests;

  @override
  Widget build(BuildContext context) {
    final property = hotel;

    return Scaffold(
      body: Column(
        children: [
          const AppBrandHeader(showVerticals: false),
          Expanded(
            child: property == null
                ? const UnavailablePropertyView()
                : _DetailsBody(
                    hotel: property,
                    dates: dates,
                    guests: guests,
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.hotel,
    required this.dates,
    required this.guests,
  });

  final Hotel hotel;
  final StayDates dates;
  final GuestSelection guests;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;
    final nights = dates.nights();

    final narrative = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OverviewSection(hotel: hotel),
        const SizedBox(height: AppSpacing.lg),
        FacilitiesSection(amenities: hotel.amenities),
        const SizedBox(height: AppSpacing.lg),
        GuestReviewsSection(reviews: hotel.reviews),
        const SizedBox(height: AppSpacing.lg),
        SurroundingsSection(location: hotel.location),
        const SizedBox(height: AppSpacing.lg),
        HouseRulesSection(hotel: hotel),
      ],
    );

    final bookingPanel = BookingPanel(
      hotel: hotel,
      dates: dates,
      guests: guests,
    );

    final availability = AvailabilityTable(
      hotel: hotel,
      nights: nights,
      guests: guests.totalGuests,
    );

    return SingleChildScrollView(
      child: Padding(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _BackToResults(),
                const SizedBox(height: AppSpacing.md),
                HotelIdentityHeader(hotel: hotel),
                const SizedBox(height: AppSpacing.lg),
                HotelGallery(
                  imageUrls: hotel.imageUrls,
                  hotelName: hotel.name,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isCompact) ...[
                  bookingPanel,
                  const SizedBox(height: AppSpacing.lg),
                  narrative,
                  const SizedBox(height: AppSpacing.lg),
                  availability,
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: narrative),
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(width: 320, child: bookingPanel),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  availability,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackToResults extends StatelessWidget {
  const _BackToResults();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        // A link opened cold has no history to pop, so fall back to the
        // results route rather than leaving the visitor on a dead end.
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Back to search results'),
      ),
    );
  }
}
