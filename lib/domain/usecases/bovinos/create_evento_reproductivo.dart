import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/evento_reproductivo.dart';
import '../../repositories/bovinos/eventos_reproductivos_repository.dart';

/// Caso de uso para crear un evento reproductivo
class CreateEventoReproductivo {
  final EventosReproductivosRepository repository;

  CreateEventoReproductivo(this.repository);

  Future<Result<EventoReproductivo>> call(EventoReproductivo evento) async {
    if (!evento.isValid) {
      return Error(const ValidationFailure('El evento no es válido'));
    }

    return await repository.createEvento(evento);
  }
}

