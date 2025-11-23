import '../../../core/utils/result.dart';
import '../../entities/bovinos/evento_reproductivo.dart';

/// Repositorio abstracto para Eventos Reproductivos
abstract class EventosReproductivosRepository {
  /// Obtiene todos los eventos reproductivos de un animal
  Future<Result<List<EventoReproductivo>>> getEventosByAnimal(
    String animalId,
    String farmId,
  );

  /// Obtiene todos los eventos reproductivos de una finca
  Future<Result<List<EventoReproductivo>>> getAllEventos(String farmId);

  /// Obtiene un evento por su ID
  Future<Result<EventoReproductivo>> getEventoById(
    String id,
    String farmId,
  );

  /// Crea un nuevo evento reproductivo
  Future<Result<EventoReproductivo>> createEvento(EventoReproductivo evento);

  /// Actualiza un evento existente
  Future<Result<EventoReproductivo>> updateEvento(EventoReproductivo evento);

  /// Elimina un evento
  Future<Result<void>> deleteEvento(String id, String farmId);

  /// Obtiene el último evento de inseminación de un animal
  Future<Result<EventoReproductivo?>> getUltimaInseminacion(
    String animalId,
    String farmId,
  );
}

