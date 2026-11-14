import '../dtos/hotel_dto.dart';

/// Reads hotel documents from storage.
///
/// Implementations throw [AppException] subtypes on failure; translating those
/// into domain failures is the repository's job, not the caller's.
abstract interface class HotelRemoteDataSource {
  /// Documents whose search tokens contain the normalised [destination].
  Future<List<HotelDto>> fetchByDestination(String destination);

  /// A single document, or a thrown [DocumentNotFoundException].
  Future<HotelDto> fetchById(String id);
}
