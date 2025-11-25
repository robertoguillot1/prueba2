import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bovine_entity.dart';

/// Contrato abstracto del repositorio para Bovinos
abstract class CattleRepository {
  /// Obtiene la lista de bovinos de una finca (consulta única)
  /// Retorna Either<Failure, List<BovineEntity>>
  Future<Either<Failure, List<BovineEntity>>> getCattleList(String farmId);

  /// Obtiene un stream de bovinos para actualizaciones en tiempo real
  /// Retorna Stream<List<BovineEntity>>
  Stream<List<BovineEntity>> getCattleListStream(String farmId);

  /// Obtiene un bovino por su ID
  /// Retorna Either<Failure, BovineEntity>
  Future<Either<Failure, BovineEntity>> getBovine(String id);

  /// Agrega un nuevo bovino
  /// Retorna Either<Failure, BovineEntity> con el bovino creado
  Future<Either<Failure, BovineEntity>> addBovine(BovineEntity bovine);

  /// Actualiza un bovino existente
  /// Retorna Either<Failure, BovineEntity> con el bovino actualizado
  Future<Either<Failure, BovineEntity>> updateBovine(BovineEntity bovine);

  /// Elimina un bovino por su ID
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> deleteBovine(String id);
}

