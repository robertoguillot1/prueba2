import '../../entities/farm/farm.dart';
import '../../repositories/farm_repository.dart';

/// Caso de uso para obtener el stream de fincas de un usuario
class GetFarmsStream {
  final FarmRepository repository;
  final String userId;

  GetFarmsStream({
    required this.repository,
    required this.userId,
  });

  /// Retorna un stream de todas las fincas del usuario
  Stream<List<Farm>> call() {
    return repository.getFarmsStream(userId);
  }
}



