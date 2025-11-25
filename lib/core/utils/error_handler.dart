import '../errors/failures.dart';

/// Utilidad para manejo centralizado de errores
class ErrorHandler {
  /// Convierte un Failure a un mensaje de error amigable para el usuario
  static String getErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    }
    
    if (failure is CacheFailure) {
      return 'Error de almacenamiento: ${failure.message}';
    }
    
    if (failure is NetworkFailure) {
      return 'Error de conexión: ${failure.message}';
    }
    
    if (failure is ServerFailure) {
      return 'Error del servidor: ${failure.message}';
    }
    
    return failure.message;
  }

  /// Obtiene un mensaje genérico según el tipo de error
  static String getGenericErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return 'Por favor verifica los datos ingresados';
    }
    
    if (failure is CacheFailure) {
      return 'No se pudo guardar la información. Intenta nuevamente.';
    }
    
    if (failure is NetworkFailure) {
      return 'No hay conexión a internet. Verifica tu conexión.';
    }
    
    if (failure is ServerFailure) {
      return 'El servidor no está disponible. Intenta más tarde.';
    }
    
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }
}

