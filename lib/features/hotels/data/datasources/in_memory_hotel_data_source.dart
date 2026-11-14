import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../dtos/hotel_dto.dart';
import 'firestore_hotel_data_source.dart';
import 'hotel_remote_data_source.dart';
import 'hotel_seed_catalog.dart';

/// Serves [HotelSeedCatalog] without touching the network.
///
/// Registered under the `local` environment so the app can be run and the UI
/// reviewed before Firestore is provisioned, and so widget tests need no
/// Firebase initialisation. It matches destinations with exactly the same
/// token rule as the Firestore source, so behaviour does not change between
/// the two.
@Environment('local')
@LazySingleton(as: HotelRemoteDataSource)
class InMemoryHotelDataSource implements HotelRemoteDataSource {
  /// Serves the bundled seed catalogue. This is the constructor the service
  /// locator uses, so it takes no arguments.
  InMemoryHotelDataSource() : _catalogue = HotelSeedCatalog.hotels;

  /// Serves an arbitrary catalogue. Tests use this to drive the source with a
  /// small, purpose-built fixture.
  @visibleForTesting
  const InMemoryHotelDataSource.withCatalogue(this._catalogue);

  static const String environmentName = 'local';

  final List<HotelDto> _catalogue;

  /// Simulated round-trip latency, so loading states are visible in the UI.
  static const Duration _latency = Duration(milliseconds: 350);

  @override
  Future<List<HotelDto>> fetchByDestination(String destination) async {
    await Future<void>.delayed(_latency);

    final token = FirestoreHotelDataSource.normaliseToken(destination);
    if (token.isEmpty) return const [];

    return _catalogue
        .where((hotel) => hotel.searchTokens.contains(token))
        .toList(growable: false);
  }

  @override
  Future<HotelDto> fetchById(String id) async {
    await Future<void>.delayed(_latency);

    for (final hotel in _catalogue) {
      if (hotel.id == id) return hotel;
    }
    throw DocumentNotFoundException('No hotel with id "$id".');
  }
}
