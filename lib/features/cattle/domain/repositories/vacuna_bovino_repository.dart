import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/vacuna_bovino_entity.dart';

/// Repositorio abstracto para gestión de vacunas de bovinos
abstract class VacunaBovinoRepository {
  /// Obtiene todas las vacunas de un bovino específico
  Future<Result<List<VacunaBovinoEntity>>> getVacunasByBovino(
    String bovinoId,
    String farmId,
  );

  /// Obtiene una vacuna por su ID
  Future<Result<VacunaBovinoEntity>> getVacunaById(
    String id,
    String bovinoId,
    String farmId,
  );

  /// Crea una nueva vacuna
  Future<Result<VacunaBovinoEntity>> addVacuna(VacunaBovinoEntity vacuna);

  /// Actualiza una vacuna existente
  Future<Result<VacunaBovinoEntity>> updateVacuna(VacunaBovinoEntity vacuna);

  /// Elimina una vacuna
  Future<Result<void>> deleteVacuna(
    String id,
    String bovinoId,
    String farmId,
  );

  /// Obtiene las vacunas que requieren refuerzo próximo
  Future<Result<List<VacunaBovinoEntity>>> getVacunasConRefuerzoPendiente(
    String farmId,
  );
}


