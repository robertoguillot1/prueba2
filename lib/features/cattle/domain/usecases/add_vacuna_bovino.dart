import '../../../../core/utils/result.dart';
import '../entities/vacuna_bovino_entity.dart';
import '../repositories/vacuna_bovino_repository.dart';

/// Parámetros para el caso de uso AddVacunaBovino
class AddVacunaBovinoParams {
  final VacunaBovinoEntity vacuna;

  AddVacunaBovinoParams({required this.vacuna});
}

/// UseCase para agregar una vacuna a un bovino
class AddVacunaBovino {
  final VacunaBovinoRepository repository;

  AddVacunaBovino(this.repository);

  Future<Result<VacunaBovinoEntity>> call(AddVacunaBovinoParams params) async {
    return await repository.addVacuna(params.vacuna);
  }
}

