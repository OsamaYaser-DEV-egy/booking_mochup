import 'package:equatable/equatable.dart';

/// Geographic coordinates.
final class GeoPoint extends Equatable {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Where a property is, and how good that location is judged to be.
final class HotelLocation extends Equatable {
  const HotelLocation({
    required this.area,
    required this.city,
    required this.country,
    required this.address,
    required this.coordinates,
    required this.distanceFromCentreKm,
    this.locationScore,
    this.highlight,
    this.nearbyLandmarks = const [],
  });

  /// Neighbourhood or district, e.g. `Al Haram`.
  final String area;
  final String city;
  final String country;
  final String address;
  final GeoPoint coordinates;

  /// Straight-line distance from the city centre, in kilometres.
  final double distanceFromCentreKm;

  /// Dedicated location sub-score on a 0–10 scale, when enough guests rated it.
  final double? locationScore;

  /// Short editorial note, e.g. `Great location — right by the Pyramids`.
  final String? highlight;

  final List<Landmark> nearbyLandmarks;

  /// `Al Haram, Giza` — the one-line label shown on cards.
  String get shortLabel => '$area, $city';

  bool get hasExcellentLocation =>
      locationScore != null && locationScore! >= 8.5;

  @override
  List<Object?> get props => [
        area,
        city,
        country,
        address,
        coordinates,
        distanceFromCentreKm,
        locationScore,
        highlight,
        nearbyLandmarks,
      ];
}

/// A point of interest near a property.
final class Landmark extends Equatable {
  const Landmark({
    required this.name,
    required this.distanceKm,
    this.category = LandmarkCategory.attraction,
  });

  final String name;
  final double distanceKm;
  final LandmarkCategory category;

  @override
  List<Object?> get props => [name, distanceKm, category];
}

enum LandmarkCategory { attraction, restaurant, transport, airport, beach }
