import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bovine_entity.dart';
import '../repositories/cattle_repository.dart';
import 'usecase.dart';

/// Parámetros para obtener un bovino por ID
class GetBovineParams {
  final String id;

  const GetBovineParams({required this.id});
}

/// Caso de uso para obtener un bovino por su ID
class GetBovine implements UseCase<Either<Failure, BovineEntity>, GetBovineParams> {
  final CattleRepository repository;

  GetBovine(this.repository);

  @override
  Future<Either<Failure, BovineEntity>> call(GetBovineParams params) async {
    return await repository.getBovine(params.id);
  }
}


