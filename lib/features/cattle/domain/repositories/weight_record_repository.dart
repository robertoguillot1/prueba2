import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weight_record_entity.dart';

/// Contrato abstracto del repositorio para Registros de Peso
abstract class WeightRecordRepository {
  /// Obtiene todos los registros de peso de un bovino
  /// Retorna Either<Failure, List<WeightRecordEntity>>
  Future<Either<Failure, List<WeightRecordEntity>>> getRecordsByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene un registro de peso por su ID
  /// Retorna Either<Failure, WeightRecordEntity>
  Future<Either<Failure, WeightRecordEntity>> getRecordById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega un nuevo registro de peso
  /// Retorna Either<Failure, WeightRecordEntity> con el registro creado
  Future<Either<Failure, WeightRecordEntity>> addRecord(
    WeightRecordEntity record,
  );

  /// Actualiza un registro de peso existente
  /// Retorna Either<Failure, WeightRecordEntity> con el registro actualizado
  Future<Either<Failure, WeightRecordEntity>> updateRecord(
    WeightRecordEntity record,
  );

  /// Elimina un registro de peso por su ID
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> deleteRecord(
    String id,
    String bovineId,
    String farmId,
  );
}



