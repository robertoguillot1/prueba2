import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';
import 'usecase.dart';

class GetTransfersByFarmParams {
  final String farmId;

  const GetTransfersByFarmParams({
    required this.farmId,
  });
}

class GetTransfersByFarm
    implements UseCase<Either<Failure, List<TransferEntity>>, GetTransfersByFarmParams> {
  final TransferRepository repository;

  GetTransfersByFarm(this.repository);

  @override
  Future<Either<Failure, List<TransferEntity>>> call(GetTransfersByFarmParams params) async {
    return await repository.getTransfersByFarm(params.farmId);
  }
}



