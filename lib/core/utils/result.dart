import '../errors/failures.dart';

/// Resultado de una operación que puede ser éxito o fallo
sealed class Result<T> {
  const Result();
}

/// Resultado exitoso
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Resultado con error
final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Extensión para facilitar el uso de Result
extension ResultExtension<T> on Result<T> {
  /// Verifica si es exitoso
  bool get isSuccess => this is Success<T>;
  
  /// Verifica si es error
  bool get isError => this is Error<T>;
  
  /// Obtiene el dato si es exitoso, null si es error
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Error<T>() => null,
  };
  
  /// Obtiene el fallo si es error, null si es exitoso
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final failure) => failure,
  };
  
  /// Ejecuta una función si es exitoso
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(:final data) => Success(mapper(data)),
      Error<T>(:final failure) => Error(failure),
    };
  }
  
  /// Ejecuta una función si es error
  Result<T> mapError(Failure Function(Failure failure) mapper) {
    return switch (this) {
      Success<T>() => this,
      Error<T>(:final failure) => Error(mapper(failure)),
    };
  }
}


