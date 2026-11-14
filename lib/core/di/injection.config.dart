// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/hotels/data/datasources/firestore_hotel_data_source.dart'
    as _i924;
import '../../features/hotels/data/datasources/hotel_catalogue_seeder.dart'
    as _i306;
import '../../features/hotels/data/datasources/hotel_remote_data_source.dart'
    as _i271;
import '../../features/hotels/data/datasources/in_memory_hotel_data_source.dart'
    as _i550;
import '../../features/hotels/data/mappers/hotel_mapper.dart' as _i741;
import '../../features/hotels/data/repositories/hotel_repository_impl.dart'
    as _i703;
import '../../features/hotels/domain/repositories/hotel_repository.dart'
    as _i159;
import '../../features/hotels/domain/services/facet_calculator.dart' as _i260;
import '../../features/hotels/domain/services/hotel_filter.dart' as _i479;
import '../../features/hotels/domain/services/hotel_sorter.dart' as _i871;
import '../../features/hotels/domain/usecases/get_hotel_details.dart' as _i692;
import '../../features/hotels/domain/usecases/search_hotels.dart' as _i687;
import '../../features/hotels/presentation/cubit/search_cubit.dart' as _i103;
import 'injection.dart' as _i464;

const String _local = 'local';
const String _remote = 'remote';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i741.HotelMapper>(() => const _i741.HotelMapper());
    gh.lazySingleton<_i479.HotelFilter>(() => const _i479.HotelFilter());
    gh.lazySingleton<_i871.HotelSorter>(() => const _i871.HotelSorter());
    gh.lazySingleton<_i271.HotelRemoteDataSource>(
      () => _i550.InMemoryHotelDataSource(),
      registerFor: {_local},
    );
    gh.lazySingleton<_i260.FacetCalculator>(
      () => _i260.FacetCalculator(gh<_i479.HotelFilter>()),
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firestore,
      registerFor: {_remote},
    );
    gh.lazySingleton<_i271.HotelRemoteDataSource>(
      () => _i924.FirestoreHotelDataSource(gh<_i974.FirebaseFirestore>()),
      registerFor: {_remote},
    );
    gh.lazySingleton<_i306.HotelCatalogueSeeder>(
      () => _i306.HotelCatalogueSeeder(gh<_i974.FirebaseFirestore>()),
      registerFor: {_remote},
    );
    gh.lazySingleton<_i159.HotelRepository>(
      () => _i703.HotelRepositoryImpl(
        gh<_i271.HotelRemoteDataSource>(),
        gh<_i741.HotelMapper>(),
      ),
    );
    gh.lazySingleton<_i692.GetHotelDetails>(
      () => _i692.GetHotelDetails(gh<_i159.HotelRepository>()),
    );
    gh.lazySingleton<_i687.SearchHotels>(
      () => _i687.SearchHotels(
        gh<_i159.HotelRepository>(),
        gh<_i479.HotelFilter>(),
        gh<_i871.HotelSorter>(),
        gh<_i260.FacetCalculator>(),
      ),
    );
    gh.factory<_i103.SearchCubit>(
      () => _i103.SearchCubit(gh<_i687.SearchHotels>()),
    );
    return this;
  }
}

class _$FirebaseModule extends _i464.FirebaseModule {}
