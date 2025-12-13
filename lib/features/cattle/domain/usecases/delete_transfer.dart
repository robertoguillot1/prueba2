import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/transfer_repository.dart';
import 'usecase.dart';

class DeleteTransferParams {
  final String id;
  final String bovineId;
  final String farmId;

  const DeleteTransferParams({
    required this.id,
    required this.bovineId,
    required this.farmId,
  });
}

class DeleteTransfer implements UseCase<Either<Failure, void>, DeleteTransferParams> {
  final TransferRepository repository;

  DeleteTransfer(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransferParams params) async {
    return await repository.deleteTransfer(params.id, params.bovineId, params.farmId);
  }
}



