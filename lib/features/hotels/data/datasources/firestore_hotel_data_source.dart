import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../dtos/hotel_dto.dart';
import 'hotel_remote_data_source.dart';

/// Reads the `hotels` collection from Cloud Firestore.
///
/// This class is the only one in the codebase that imports `cloud_firestore`
/// for reads, which is what keeps the rest of the app testable without a
/// Firebase emulator and replaceable if storage ever changes.
@Environment('remote')
@LazySingleton(as: HotelRemoteDataSource)
class FirestoreHotelDataSource implements HotelRemoteDataSource {
  const FirestoreHotelDataSource(this._firestore);

  static const String collectionPath = 'hotels';

  /// Field holding the lower-cased tokens a destination query matches against.
  static const String searchTokensField = 'searchTokens';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  @override
  Future<List<HotelDto>> fetchByDestination(String destination) async {
    final token = normaliseToken(destination);
    if (token.isEmpty) return const [];

    try {
      final snapshot = await _collection
          .where(searchTokensField, arrayContains: token)
          .get();

      return snapshot.docs
          .map((doc) => HotelDto.fromMap(doc.id, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(_translate(error), stackTrace);
    }
  }

  @override
  Future<HotelDto> fetchById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        throw DocumentNotFoundException('No hotel with id "$id".');
      }
      return HotelDto.fromMap(doc.id, data);
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(_translate(error), stackTrace);
    }
  }

  /// Lower-cases and trims a destination so `  Egypt ` and `egypt` match the
  /// same stored token. Kept public so the seeder builds tokens identically.
  static String normaliseToken(String value) => value.trim().toLowerCase();

  AppException _translate(FirebaseException error) {
    return switch (error.code) {
      'unavailable' || 'network-request-failed' => ConnectivityException(
          'Could not reach the hotel catalogue.',
          error,
        ),
      'not-found' => DocumentNotFoundException(
          error.message ?? 'The requested document does not exist.',
          cause: error,
        ),
      _ => RemoteSourceException(
          error.message ?? 'Firestore rejected the request (${error.code}).',
          cause: error,
        ),
    };
  }
}
