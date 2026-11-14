import 'package:flutter/material.dart';

import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/amenity.dart';
import '../../../domain/entities/hotel.dart';
import '../../../domain/entities/hotel_location.dart';
import 'details_section.dart';

/// The long-form blurb plus the headline facilities.
class OverviewSection extends StatelessWidget {
  const OverviewSection({required this.hotel, super.key});

  final Hotel hotel;

  /// The facilities worth promoting above the full list.
  static const List<Amenity> _headline = [
    Amenity.swimmingPool,
    Amenity.freeWifi,
    Amenity.breakfast,
    Amenity.airportShuttle,
    Amenity.spa,
    Amenity.fitnessCentre,
    Amenity.restaurant,
    Amenity.bar,
    Amenity.beachfront,
    Amenity.parking,
    Amenity.airConditioning,
    Amenity.familyRooms,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final popular = _headline
        .where(hotel.hasAmenity)
        .take(8)
        .toList(growable: false);

    return DetailsSection(
      title: 'About this property',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hotel.description, style: textTheme.bodyLarge),
          if (popular.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Most popular facilities', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final amenity in popular)
                  _AmenityPill(amenity: amenity),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Every facility the property lists, in a multi-column checklist.
class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({required this.amenities, super.key});

  final List<Amenity> amenities;

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    final columns = switch (context.formFactor) {
      FormFactor.compact => 1,
      FormFactor.medium => 2,
      FormFactor.expanded => 3,
    };

    return DetailsSection(
      title: 'Facilities',
      subtitle: '${amenities.length} facilities at this property',
      // Rows of Expanded cells rather than a GridView: each row is as tall as
      // its content, so a long facility name wraps instead of being clipped
      // by a fixed aspect ratio.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var start = 0; start < amenities.length; start += columns)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var column = 0; column < columns; column++)
                    Expanded(
                      child: start + column < amenities.length
                          ? _FacilityRow(
                              amenity: amenities[start + column],
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Nearby landmarks grouped by what kind of place they are.
class SurroundingsSection extends StatelessWidget {
  const SurroundingsSection({required this.location, super.key});

  final HotelLocation location;

  @override
  Widget build(BuildContext context) {
    final landmarks = location.nearbyLandmarks;
    if (landmarks.isEmpty) return const SizedBox.shrink();

    final grouped = <LandmarkCategory, List<Landmark>>{};
    for (final landmark in landmarks) {
      grouped.putIfAbsent(landmark.category, () => []).add(landmark);
    }

    return DetailsSection(
      title: 'Hotel surroundings',
      subtitle: location.locationScore == null
          ? null
          : 'Guests rate this location '
              '${location.locationScore!.toStringAsFixed(1)} out of 10',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in grouped.entries) ...[
            Text(
              _titleFor(entry.key),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final landmark in entry.value)
              DetailsFactRow(
                icon: _iconFor(entry.key),
                label: landmark.name,
                value: landmark.distanceKm < 1
                    ? '${(landmark.distanceKm * 1000).round()} m'
                    : '${landmark.distanceKm.toStringAsFixed(1)} km',
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  String _titleFor(LandmarkCategory category) => switch (category) {
        LandmarkCategory.attraction => 'What is nearby',
        LandmarkCategory.restaurant => 'Restaurants and cafés',
        LandmarkCategory.transport => 'Public transport',
        LandmarkCategory.airport => 'Closest airports',
        LandmarkCategory.beach => 'Beaches in the neighbourhood',
      };

  IconData _iconFor(LandmarkCategory category) => switch (category) {
        LandmarkCategory.attraction => Icons.photo_camera_outlined,
        LandmarkCategory.restaurant => Icons.restaurant_rounded,
        LandmarkCategory.transport => Icons.directions_subway_rounded,
        LandmarkCategory.airport => Icons.flight_takeoff_rounded,
        LandmarkCategory.beach => Icons.beach_access_rounded,
      };
}

/// Check-in and check-out times, and the property's own rules.
class HouseRulesSection extends StatelessWidget {
  const HouseRulesSection({required this.hotel, super.key});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final rules = hotel.houseRules;
    final hasTimes = hotel.checkInFrom != null || hotel.checkOutUntil != null;
    if (rules.isEmpty && !hasTimes) return const SizedBox.shrink();

    return DetailsSection(
      title: 'House rules',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hotel.checkInFrom case final time?)
            DetailsFactRow(
              icon: Icons.login_rounded,
              label: 'Check-in',
              value: 'From $time',
            ),
          if (hotel.checkOutUntil case final time?)
            DetailsFactRow(
              icon: Icons.logout_rounded,
              label: 'Check-out',
              value: 'Until $time',
            ),
          if (rules.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final rule in rules)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        rule,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _FacilityRow extends StatelessWidget {
  const _FacilityRow({required this.amenity});

  final Amenity amenity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              amenity.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityPill extends StatelessWidget {
  const _AmenityPill({required this.amenity});

  final Amenity amenity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(amenity), size: 16, color: AppColors.navy),
          const SizedBox(width: AppSpacing.sm),
          Text(amenity.label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  IconData _iconFor(Amenity amenity) => switch (amenity) {
        Amenity.freeWifi => Icons.wifi_rounded,
        Amenity.parking => Icons.local_parking_rounded,
        Amenity.swimmingPool => Icons.pool_rounded,
        Amenity.airportShuttle => Icons.airport_shuttle_rounded,
        Amenity.familyRooms => Icons.family_restroom_rounded,
        Amenity.nonSmokingRooms => Icons.smoke_free_rounded,
        Amenity.restaurant => Icons.restaurant_rounded,
        Amenity.roomService => Icons.room_service_rounded,
        Amenity.frontDesk24h => Icons.support_agent_rounded,
        Amenity.fitnessCentre => Icons.fitness_center_rounded,
        Amenity.spa => Icons.spa_rounded,
        Amenity.bar => Icons.local_bar_rounded,
        Amenity.airConditioning => Icons.ac_unit_rounded,
        Amenity.breakfast => Icons.free_breakfast_rounded,
        Amenity.beachfront => Icons.beach_access_rounded,
        Amenity.terrace => Icons.deck_rounded,
        Amenity.petsAllowed => Icons.pets_rounded,
        Amenity.facilitiesForDisabled => Icons.accessible_rounded,
        Amenity.laundry => Icons.local_laundry_service_rounded,
        Amenity.teaCoffeeMaker => Icons.coffee_rounded,
      };
}
