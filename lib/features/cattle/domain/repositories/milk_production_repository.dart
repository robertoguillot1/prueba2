import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/milk_production_entity.dart';

/// Contrato abstracto del repositorio para Producción de Leche
abstract class MilkProductionRepository {
  /// Obtiene todos los registros de producción de leche de un bovino
  /// Retorna Either<Failure, List<MilkProductionEntity>>
  Future<Either<Failure, List<MilkProductionEntity>>> getProductionsByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene la producción de leche por rango de fechas
  /// Retorna Either<Failure, List<MilkProductionEntity>>
  Future<Either<Failure, List<MilkProductionEntity>>> getProductionsByDateRange(
    String farmId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Obtiene un registro de producción por su ID
  /// Retorna Either<Failure, MilkProductionEntity>
  Future<Either<Failure, MilkProductionEntity>> getProductionById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega un nuevo registro de producción de leche
  /// Retorna Either<Failure, MilkProductionEntity> con el registro creado
  Future<Either<Failure, MilkProductionEntity>> addProduction(
    MilkProductionEntity production,
  );

  /// Actualiza un registro de producción existente
  /// Retorna Either<Failure, MilkProductionEntity> con el registro actualizado
  Future<Either<Failure, MilkProductionEntity>> updateProduction(
    MilkProductionEntity production,
  );

  /// Elimina un registro de producción por su ID
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> deleteProduction(
    String id,
    String bovineId,
    String farmId,
  );
}

