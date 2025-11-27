import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/produccion_leche.dart';
import '../../repositories/bovinos/produccion_leche_repository.dart';

/// Caso de uso para agregar un registro de producción de leche
class AddMilkProduction {
  final ProduccionLecheRepository repository;

  AddMilkProduction(this.repository);

  Future<Result<ProduccionLeche>> call(ProduccionLeche production) async {
    // Validar que los datos sean válidos
    if (!production.isValid) {
      return const Error(ValidationFailure('Los datos de producción no son válidos'));
    }

    // Validar que los litros sean mayores a 0
    if (production.litersProduced <= 0) {
      return const Error(ValidationFailure('Los litros producidos deben ser mayores a 0'));
    }

    return await repository.createProduccion(production);
  }
}




