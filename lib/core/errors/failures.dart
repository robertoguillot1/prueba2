/// Clase base para todos los errores de la aplicación
abstract class Failure {
  final String message;
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Error de caché/local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Error de autorización (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

/// Error de recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

