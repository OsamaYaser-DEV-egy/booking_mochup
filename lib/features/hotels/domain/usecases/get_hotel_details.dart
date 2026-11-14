import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

/// Retrieves one property in full.
@lazySingleton
class GetHotelDetails implements UseCase<Hotel, String> {
  const GetHotelDetails(this._repository);

  final HotelRepository _repository;

  @override
  Future<Either<Failure, Hotel>> call(String hotelId) {
    if (hotelId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('A property identifier is required.')),
      );
    }
    return _repository.findById(hotelId);
  }
}
