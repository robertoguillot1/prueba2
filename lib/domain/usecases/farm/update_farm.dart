import '../../entities/farm/farm.dart';
import '../../repositories/farm_repository.dart';

/// Caso de uso para actualizar una finca existente
class UpdateFarm {
  final FarmRepository repository;

  UpdateFarm(this.repository);

  /// Actualiza una finca existente
  Future<Farm> call(Farm farm) async {
    return await repository.updateFarm(farm);
  }
}






