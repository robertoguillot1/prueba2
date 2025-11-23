import '../../../core/utils/result.dart';
import '../../entities/porcinos/vacuna_cerdo.dart';

/// Repositorio abstracto para Vacunas de Cerdo
abstract class VacunaCerdoRepository {
  /// Obtiene todas las vacunas de una finca
  Future<Result<List<VacunaCerdo>>> getAllVacunas(String farmId);
  
  /// Obtiene una vacuna por su ID
  Future<Result<VacunaCerdo>> getVacunaById(String id, String farmId);
  
  /// Crea una nueva vacuna
  Future<Result<VacunaCerdo>> createVacuna(VacunaCerdo vacuna);
  
  /// Actualiza una vacuna existente
  Future<Result<VacunaCerdo>> updateVacuna(VacunaCerdo vacuna);
  
  /// Elimina una vacuna
  Future<Result<void>> deleteVacuna(String id, String farmId);
  
  /// Obtiene vacunas de un cerdo específico
  Future<Result<List<VacunaCerdo>>> getVacunasByCerdo(String cerdoId, String farmId);
  
  /// Obtiene vacunas que necesitan próxima dosis
  Future<Result<List<VacunaCerdo>>> getVacunasPendientes(String farmId);
}


