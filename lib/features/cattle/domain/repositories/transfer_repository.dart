import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_entity.dart';

abstract class TransferRepository {
  /// Obtiene todas las transferencias de un bovino
  Future<Either<Failure, List<TransferEntity>>> getTransfersByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene todas las transferencias de una finca
  Future<Either<Failure, List<TransferEntity>>> getTransfersByFarm(String farmId);

  /// Obtiene una transferencia por su ID
  Future<Either<Failure, TransferEntity>> getTransferById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega una nueva transferencia
  Future<Either<Failure, TransferEntity>> addTransfer(TransferEntity transfer);

  /// Actualiza una transferencia existente
  Future<Either<Failure, TransferEntity>> updateTransfer(TransferEntity transfer);

  /// Elimina una transferencia por su ID
  Future<Either<Failure, void>> deleteTransfer(
    String id,
    String bovineId,
    String farmId,
  );
}

