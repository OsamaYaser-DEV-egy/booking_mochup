import 'package:equatable/equatable.dart';

/// Base type for every expected, recoverable error that can cross a layer
/// boundary. Domain and presentation code depends on this abstraction only,
/// never on `FirebaseException` or any other infrastructure type.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  /// Human-readable, already-localised-enough message safe to surface in UI.
  final String message;

  /// The originating error, kept for logging. Never shown to the user.
  final Object? cause;

  @override
  List<Object?> get props => [message, runtimeType];
}

/// The backend was reachable but rejected or failed the request.
final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'We could not reach our servers. Please try again.',
    Object? cause,
  ]) : super(cause: cause);
}

/// The device has no usable connection.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'You appear to be offline. Check your connection.',
    Object? cause,
  ]) : super(cause: cause);
}

/// The caller asked for a resource that does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'We could not find what you were looking for.',
    Object? cause,
  ]) : super(cause: cause);
}

/// A stored document could not be mapped into a domain entity.
final class DataFormatFailure extends Failure {
  const DataFormatFailure([
    super.message = 'Some information could not be read. Please try again.',
    Object? cause,
  ]) : super(cause: cause);
}

/// The caller supplied input the domain rejects.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

/// Anything that escaped the specific cases above.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong on our side.',
    Object? cause,
  ]) : super(cause: cause);
}
