import '../../../core/utils/result.dart';
import '../../entities/bovinos/vacunas_bovino.dart';

/// Repositorio abstracto para Vacunas de Bovino
abstract class VacunasBovinoRepository {
  /// Obtiene todas las vacunas de una finca
  Future<Result<List<VacunasBovino>>> getAllVacunas(String farmId);
  
  /// Obtiene una vacuna por su ID
  Future<Result<VacunasBovino>> getVacunaById(String id, String farmId);
  
  /// Crea una nueva vacuna
  Future<Result<VacunasBovino>> createVacuna(VacunasBovino vacuna);
  
  /// Actualiza una vacuna existente
  Future<Result<VacunasBovino>> updateVacuna(VacunasBovino vacuna);
  
  /// Elimina una vacuna
  Future<Result<void>> deleteVacuna(String id, String farmId);
  
  /// Obtiene vacunas de un bovino específico
  Future<Result<List<VacunasBovino>>> getVacunasByBovino(String bovinoId, String farmId);
  
  /// Obtiene vacunas que necesitan próxima dosis
  Future<Result<List<VacunasBovino>>> getVacunasPendientes(String farmId);
}


