import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import 'injection.config.dart';

/// The application's service locator.
final GetIt getIt = GetIt.instance;

/// Registers every dependency.
///
/// Composition happens here and nowhere else: classes declare what they need
/// through constructor parameters and never reach for [getIt] themselves, so
/// each one can be constructed directly in a test.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init(
    environment: AppConfig.useLocalCatalogue
        ? _localEnvironment
        : _remoteEnvironment,
  );
}

/// Bundled catalogue, no Firebase required.
const String _localEnvironment = 'local';

/// Live Firestore.
const String _remoteEnvironment = 'remote';

/// Third-party instances that cannot be annotated in their own packages.
@module
abstract class FirebaseModule {
  /// Only resolved in the remote environment, so a local run never touches
  /// Firebase.
  @Environment('remote')
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
