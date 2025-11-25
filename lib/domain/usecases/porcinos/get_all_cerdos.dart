import '../../../core/utils/result.dart';
import '../../entities/porcinos/cerdo.dart';
import '../../repositories/porcinos/cerdos_repository.dart';

/// Use case para obtener todos los cerdos de una finca
class GetAllCerdos {
  final CerdosRepository repository;

  GetAllCerdos(this.repository);

  Future<Result<List<Cerdo>>> call(String farmId) async {
    return await repository.getAllCerdos(farmId);
  }
}

