import '../../../core/utils/result.dart';
import '../../entities/ovinos/enfermedad_oveja.dart';

/// Repositorio abstracto para Enfermedades de Oveja
abstract class EnfermedadesOvejaRepository {
  /// Obtiene todas las enfermedades de una finca
  Future<Result<List<EnfermedadOveja>>> getAllEnfermedades(String farmId);
  
  /// Obtiene una enfermedad por su ID
  Future<Result<EnfermedadOveja>> getEnfermedadById(String id, String farmId);
  
  /// Crea una nueva enfermedad
  Future<Result<EnfermedadOveja>> createEnfermedad(EnfermedadOveja enfermedad);
  
  /// Actualiza una enfermedad existente
  Future<Result<EnfermedadOveja>> updateEnfermedad(EnfermedadOveja enfermedad);
  
  /// Elimina una enfermedad
  Future<Result<void>> deleteEnfermedad(String id, String farmId);
  
  /// Obtiene enfermedades de una oveja específica
  Future<Result<List<EnfermedadOveja>>> getEnfermedadesByOveja(String ovejaId, String farmId);
  
  /// Obtiene enfermedades activas (no curadas)
  Future<Result<List<EnfermedadOveja>>> getEnfermedadesActivas(String farmId);
}

