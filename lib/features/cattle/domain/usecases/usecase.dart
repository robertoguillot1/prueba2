/// Interfaz base para todos los casos de uso
/// Type: Tipo de dato que retorna el caso de uso
/// Params: Tipo de parámetros que recibe el caso de uso
abstract class UseCase<Type, Params> {
  /// Ejecuta el caso de uso con los parámetros dados
  Future<Type> call(Params params);
}

/// Clase base para casos de uso que no requieren parámetros
abstract class UseCaseNoParams<Type> {
  /// Ejecuta el caso de uso sin parámetros
  Future<Type> call();
}


