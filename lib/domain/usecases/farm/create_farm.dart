import '../../entities/farm/farm.dart';
import '../../repositories/farm_repository.dart';

/// Caso de uso para crear una nueva finca
class CreateFarm {
  final FarmRepository repository;

  CreateFarm(this.repository);

  /// Crea una nueva finca
  Future<Farm> call(Farm farm) async {
    return await repository.createFarm(farm);
  }
}

