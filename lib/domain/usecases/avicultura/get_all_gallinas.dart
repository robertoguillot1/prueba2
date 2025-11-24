import '../../../core/utils/result.dart';
import '../../entities/avicultura/gallina.dart';
import '../../repositories/avicultura/gallinas_repository.dart';

/// Use case para obtener todas las gallinas de una finca
class GetAllGallinas {
  final GallinasRepository repository;

  GetAllGallinas(this.repository);

  Future<Result<List<Gallina>>> call(String farmId) async {
    return await repository.getAllGallinas(farmId);
  }
}



