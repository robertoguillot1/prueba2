import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/peso_bovino.dart';
import '../../repositories/bovinos/peso_bovino_repository.dart';

/// Caso de uso para agregar un registro de peso
class AddWeightRecord {
  final PesoBovinoRepository repository;

  AddWeightRecord(this.repository);

  Future<Result<PesoBovino>> call(PesoBovino weightRecord) async {
    // Validar que los datos sean válidos
    if (!weightRecord.isValid) {
      return const Error(ValidationFailure('Los datos de peso no son válidos'));
    }

    // Validar que el peso sea mayor a 0
    if (weightRecord.weight <= 0) {
      return const Error(ValidationFailure('El peso debe ser mayor a 0'));
    }

    return await repository.createRegistro(weightRecord);
  }
}





