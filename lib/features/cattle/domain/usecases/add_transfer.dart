import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';
import 'usecase.dart';

class AddTransferParams {
  final TransferEntity transfer;

  const AddTransferParams({required this.transfer});
}

class AddTransfer implements UseCase<Either<Failure, TransferEntity>, AddTransferParams> {
  final TransferRepository repository;

  AddTransfer(this.repository);

  @override
  Future<Either<Failure, TransferEntity>> call(AddTransferParams params) async {
    if (!params.transfer.isValid) {
      return Left(ValidationFailure('Los datos de la transferencia no son válidos'));
    }
    return await repository.addTransfer(params.transfer);
  }
}

