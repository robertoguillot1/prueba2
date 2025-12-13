import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';
import 'usecase.dart';

class GetTransfersByBovineParams {
  final String bovineId;
  final String farmId;

  const GetTransfersByBovineParams({
    required this.bovineId,
    required this.farmId,
  });
}

class GetTransfersByBovine
    implements UseCase<Either<Failure, List<TransferEntity>>, GetTransfersByBovineParams> {
  final TransferRepository repository;

  GetTransfersByBovine(this.repository);

  @override
  Future<Either<Failure, List<TransferEntity>>> call(GetTransfersByBovineParams params) async {
    return await repository.getTransfersByBovine(params.bovineId, params.farmId);
  }
}



