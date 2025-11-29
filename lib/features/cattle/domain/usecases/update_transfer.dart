import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';
import 'usecase.dart';

class UpdateTransferParams {
  final TransferEntity transfer;

  const UpdateTransferParams({required this.transfer});
}

class UpdateTransfer implements UseCase<Either<Failure, TransferEntity>, UpdateTransferParams> {
  final TransferRepository repository;

  UpdateTransfer(this.repository);

  @override
  Future<Either<Failure, TransferEntity>> call(UpdateTransferParams params) async {
    if (!params.transfer.isValid) {
      return Left(ValidationFailure('Los datos de la transferencia no son válidos'));
    }
    return await repository.updateTransfer(params.transfer);
  }
}

