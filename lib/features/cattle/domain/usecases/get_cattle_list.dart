import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bovine_entity.dart';
import '../repositories/cattle_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener la lista de bovinos
class GetCattleListParams {
  final String farmId;

  const GetCattleListParams({required this.farmId});
}

/// Caso de uso para obtener la lista de bovinos de una finca
class GetCattleList implements UseCase<Either<Failure, List<BovineEntity>>, GetCattleListParams> {
  final CattleRepository repository;

  GetCattleList(this.repository);

  @override
  Future<Either<Failure, List<BovineEntity>>> call(GetCattleListParams params) async {
    return await repository.getCattleList(params.farmId);
  }
}







