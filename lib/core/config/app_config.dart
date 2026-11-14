/// Compile-time configuration, supplied with `--dart-define`.
///
/// Reading flags in one place keeps `String.fromEnvironment` calls out of
/// feature code and makes every switch discoverable.
abstract final class AppConfig {
  /// Serve the bundled catalogue instead of Firestore.
  ///
  /// Enable with `flutter run --dart-define=USE_LOCAL_CATALOGUE=true`. Useful
  /// before Firestore is provisioned, and for working offline.
  static const bool useLocalCatalogue = bool.fromEnvironment(
    'USE_LOCAL_CATALOGUE',
  );

  /// Expose the in-app Firestore seeding action.
  ///
  /// Enable with `flutter run --dart-define=ENABLE_SEEDING=true`. Off by
  /// default so a deployed build cannot overwrite the catalogue.
  static const bool enableSeeding = bool.fromEnvironment('ENABLE_SEEDING');

  /// The destination the search screen opens on.
  static const String defaultDestination = 'Egypt';

  /// Nights assumed for pricing when a search has no dates yet.
  static const int assumedStayNights = 1;

  /// Currency the mocked catalogue is priced in.
  static const String defaultCurrency = 'EGP';
}
