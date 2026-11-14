import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Contract every use case implements.
///
/// Keeping a single call signature means the presentation layer depends on one
/// stable abstraction (dependency inversion) and new behaviour is added by
/// writing a new use case rather than widening an existing one.
abstract interface class UseCase<Output, Input> {
  Future<Either<Failure, Output>> call(Input input);
}

/// Contract for use cases that expose a continuous stream of values.
abstract interface class StreamUseCase<Output, Input> {
  Stream<Either<Failure, Output>> call(Input input);
}

/// Input marker for use cases that take no arguments.
final class NoInput extends Equatable {
  const NoInput();

  @override
  List<Object?> get props => const [];
}
