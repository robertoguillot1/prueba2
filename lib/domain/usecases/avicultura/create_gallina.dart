import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/avicultura/gallina.dart';
import '../../repositories/avicultura/gallinas_repository.dart';

/// Use case para crear una nueva gallina
class CreateGallina {
  final GallinasRepository repository;

  CreateGallina(this.repository);

  Future<Result<Gallina>> call(Gallina gallina) async {
    if (!gallina.isValid) {
      return const Error(ValidationFailure('Datos de gallina inválidos'));
    }
    return await repository.createGallina(gallina);
  }
}

