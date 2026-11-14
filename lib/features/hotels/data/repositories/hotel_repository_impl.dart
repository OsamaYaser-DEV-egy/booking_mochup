import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../datasources/hotel_remote_data_source.dart';
import '../mappers/hotel_mapper.dart';

/// Fulfils the domain's [HotelRepository] contract.
///
/// Its whole job is translation: it delegates retrieval to a data source,
/// delegates shape conversion to a mapper, and converts the exceptions those
/// two throw into [Failure] values. No business rule lives here.
@LazySingleton(as: HotelRepository)
class HotelRepositoryImpl implements HotelRepository {
  const HotelRepositoryImpl(this._dataSource, this._mapper);

  final HotelRemoteDataSource _dataSource;
  final HotelMapper _mapper;

  @override
  Future<Either<Failure, List<Hotel>>> findByDestination(
    String destination,
  ) async {
    return _guard(() async {
      final dtos = await _dataSource.fetchByDestination(destination);
      return _mapper.toEntities(dtos);
    });
  }

  @override
  Future<Either<Failure, Hotel>> findById(String id) async {
    return _guard(() async {
      final dto = await _dataSource.fetchById(id);
      return _mapper.toEntity(dto);
    });
  }

  /// Runs [action], mapping every known error type onto a [Failure].
  ///
  /// Centralising this keeps each repository method to a single expression and
  /// guarantees no infrastructure exception escapes the data layer.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ConnectivityException catch (error) {
      return Left(NetworkFailure(error.message, error.cause ?? error));
    } on DocumentNotFoundException catch (error) {
      return Left(NotFoundFailure(error.message, error.cause ?? error));
    } on MappingException catch (error) {
      return Left(DataFormatFailure(error.message, error.cause ?? error));
    } on RemoteSourceException catch (error) {
      return Left(ServerFailure(error.message, error.cause ?? error));
    } catch (error) {
      return Left(UnexpectedFailure(
        'Something went wrong on our side.',
        error,
      ));
    }
  }
}
