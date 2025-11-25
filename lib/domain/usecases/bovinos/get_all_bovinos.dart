import '../../../core/utils/result.dart';
import '../../entities/bovinos/bovino.dart';
import '../../repositories/bovinos/bovinos_repository.dart';

/// Use case para obtener todos los bovinos de una finca
class GetAllBovinos {
  final BovinosRepository repository;

  GetAllBovinos(this.repository);

  Future<Result<List<Bovino>>> call(String farmId) async {
    return await repository.getAllBovinos(farmId);
  }
}

