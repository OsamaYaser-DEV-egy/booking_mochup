/// Infrastructure-level errors thrown by data sources.
///
/// Data sources throw these; repositories catch them and translate them into
/// [Failure]s. Nothing above the data layer ever sees an exception type.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// The remote source responded with an error.
final class RemoteSourceException extends AppException {
  const RemoteSourceException(super.message, {super.cause});
}

/// The remote source could not be reached at all.
final class ConnectivityException extends AppException {
  const ConnectivityException([
    super.message = 'No network connection available.',
    Object? cause,
  ]) : super(cause: cause);
}

/// A requested document was absent.
final class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException(super.message, {super.cause});
}

/// A payload did not match the shape the mapper expects.
final class MappingException extends AppException {
  const MappingException(super.message, {super.cause});
}
