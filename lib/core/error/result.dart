import 'failures.dart';

/// The outcome of an operation that can fail in an expected way.
///
/// Used instead of exceptions across layer boundaries so that failure handling
/// is visible in the type and cannot be forgotten.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// The value, or `null` if the operation failed.
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failed<T>() => null,
  };

  /// The failure, or `null` if the operation succeeded.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(:final failure) => failure,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failed<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
