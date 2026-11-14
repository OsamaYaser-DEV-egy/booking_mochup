import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/hotel.dart';

/// The domain's view of hotel storage.
///
/// Declared here and implemented in the data layer so the domain depends on
/// nothing concrete. The contract is deliberately narrow: it retrieves
/// candidates and single properties, and knows nothing about filtering,
/// sorting or presentation.
abstract interface class HotelRepository {
  /// All properties matching a destination, unfiltered and unsorted.
  ///
  /// An unknown destination yields an empty list, not a failure.
  Future<Either<Failure, List<Hotel>>> findByDestination(String destination);

  /// A single property by its identifier.
  ///
  /// Yields [NotFoundFailure] when no such property exists.
  Future<Either<Failure, Hotel>> findById(String id);
}
