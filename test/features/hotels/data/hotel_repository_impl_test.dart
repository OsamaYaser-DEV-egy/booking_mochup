import 'package:booking_mochup/core/error/exceptions.dart';
import 'package:booking_mochup/core/error/failures.dart';
import 'package:booking_mochup/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:booking_mochup/features/hotels/data/datasources/hotel_seed_catalog.dart';
import 'package:booking_mochup/features/hotels/data/dtos/hotel_dto.dart';
import 'package:booking_mochup/features/hotels/data/mappers/hotel_mapper.dart';
import 'package:booking_mochup/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements HotelRemoteDataSource {}

void main() {
  late _MockDataSource dataSource;
  late HotelRepositoryImpl repository;

  final seedHotel = HotelSeedCatalog.hotels.first;

  setUp(() {
    dataSource = _MockDataSource();
    repository = HotelRepositoryImpl(dataSource, const HotelMapper());
  });

  group('HotelRepositoryImpl', () {
    test('maps data-source results into entities', () async {
      when(() => dataSource.fetchByDestination('Egypt'))
          .thenAnswer((_) async => [seedHotel]);

      final outcome = await repository.findByDestination('Egypt');

      expect(outcome.isRight(), isTrue);
      outcome.fold(
        (_) => fail('expected a successful result'),
        (hotels) {
          expect(hotels, hasLength(1));
          expect(hotels.single.id, seedHotel.id);
          expect(hotels.single.name, seedHotel.name);
        },
      );
    });

    test('an empty destination yields an empty list, not a failure', () async {
      when(() => dataSource.fetchByDestination(any()))
          .thenAnswer((_) async => const []);

      final outcome = await repository.findByDestination('Atlantis');

      expect(outcome.isRight(), isTrue);
      outcome.fold(
        (_) => fail('an unknown destination is not an error'),
        (hotels) => expect(hotels, isEmpty),
      );
    });

    group('error translation', () {
      test('connectivity becomes NetworkFailure', () async {
        when(() => dataSource.fetchByDestination(any()))
            .thenThrow(const ConnectivityException());

        final outcome = await repository.findByDestination('Egypt');

        expect(outcome.isLeft(), isTrue);
        outcome.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('expected a failure'),
        );
      });

      test('a missing document becomes NotFoundFailure', () async {
        when(() => dataSource.fetchById(any()))
            .thenThrow(const DocumentNotFoundException('gone'));

        final outcome = await repository.findById('gone');

        outcome.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (_) => fail('expected a failure'),
        );
      });

      test('a remote error becomes ServerFailure', () async {
        when(() => dataSource.fetchByDestination(any()))
            .thenThrow(const RemoteSourceException('rejected'));

        final outcome = await repository.findByDestination('Egypt');

        outcome.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('expected a failure'),
        );
      });

      test('an unmappable document becomes DataFormatFailure', () async {
        when(() => dataSource.fetchByDestination(any())).thenAnswer(
          (_) async => [
            HotelDto.fromMap('broken', {
              'name': 'Broken Hotel',
              'propertyType': 'spaceship',
              'location': {
                'area': 'A',
                'city': 'B',
                'country': 'C',
                'latitude': 0,
                'longitude': 0,
              },
              'reviews': <String, Object?>{},
            }),
          ],
        );

        final outcome = await repository.findByDestination('Egypt');

        outcome.fold(
          (failure) => expect(failure, isA<DataFormatFailure>()),
          (_) => fail('expected a failure'),
        );
      });

      test('an unexpected error becomes UnexpectedFailure', () async {
        when(() => dataSource.fetchByDestination(any()))
            .thenThrow(StateError('boom'));

        final outcome = await repository.findByDestination('Egypt');

        outcome.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('expected a failure'),
        );
      });
    });
  });
}
