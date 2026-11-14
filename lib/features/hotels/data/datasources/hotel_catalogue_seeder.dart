import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'firestore_hotel_data_source.dart';
import 'hotel_seed_catalog.dart';

/// Writes [HotelSeedCatalog] into Firestore.
///
/// Running this from the app avoids needing a service-account key: the writes
/// go through the same client SDK and the same security rules as any other
/// request. It is idempotent — documents are keyed by slug and written with
/// `set`, so re-running updates in place rather than duplicating.
@Environment('remote')
@lazySingleton
class HotelCatalogueSeeder {
  const HotelCatalogueSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  /// Writes every seed document and returns how many were written.
  Future<int> seed() async {
    final collection =
        _firestore.collection(FirestoreHotelDataSource.collectionPath);
    final batch = _firestore.batch();

    final hotels = HotelSeedCatalog.hotels;
    for (final hotel in hotels) {
      batch.set(collection.doc(hotel.id), hotel.toMap());
    }

    await batch.commit();
    return hotels.length;
  }

  /// True when the collection already holds documents, so a caller can decide
  /// whether seeding is needed.
  Future<bool> isSeeded() async {
    final snapshot = await _firestore
        .collection(FirestoreHotelDataSource.collectionPath)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Seeds only when the collection is empty. Returns the number written.
  Future<int> seedIfEmpty() async {
    if (await isSeeded()) return 0;
    return seed();
  }
}
