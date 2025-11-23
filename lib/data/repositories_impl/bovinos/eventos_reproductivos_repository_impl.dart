import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../domain/repositories/bovinos/eventos_reproductivos_repository.dart';
import '../../datasources/bovinos/eventos_reproductivos_datasource.dart';
import '../../models/bovinos/evento_reproductivo_model.dart';

/// Implementación del repositorio de Eventos Reproductivos
class EventosReproductivosRepositoryImpl implements EventosReproductivosRepository {
  final EventosReproductivosDataSource dataSource;

  EventosReproductivosRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<EventoReproductivo>>> getEventosByAnimal(
    String animalId,
    String farmId,
  ) async {
    try {
      final models = await dataSource.getEventosByAnimal(animalId, farmId);
      return Success(models.cast<EventoReproductivo>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al obtener eventos: $e'));
    }
  }

  @override
  Future<Result<List<EventoReproductivo>>> getAllEventos(String farmId) async {
    try {
      final models = await dataSource.getAllEventos(farmId);
      return Success(models.cast<EventoReproductivo>().toList());
    } catch (e) {
      return Error(CacheFailure('Error al obtener eventos: $e'));
    }
  }

  @override
  Future<Result<EventoReproductivo>> getEventoById(String id, String farmId) async {
    try {
      final model = await dataSource.getEventoById(id, farmId);
      return Success(model as EventoReproductivo);
    } catch (e) {
      if (e is CacheFailure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al obtener evento: $e'));
    }
  }

  @override
  Future<Result<EventoReproductivo>> createEvento(EventoReproductivo evento) async {
    try {
      final model = EventoReproductivoModel.fromEntity(evento);
      final created = await dataSource.createEvento(model);
      return Success(created as EventoReproductivo);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al crear evento: $e'));
    }
  }

  @override
  Future<Result<EventoReproductivo>> updateEvento(EventoReproductivo evento) async {
    try {
      final model = EventoReproductivoModel.fromEntity(evento);
      final updated = await dataSource.updateEvento(model);
      return Success(updated as EventoReproductivo);
    } catch (e) {
      if (e is Failure) {
        return Error(e);
      }
      return Error(CacheFailure('Error al actualizar evento: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEvento(String id, String farmId) async {
    try {
      await dataSource.deleteEvento(id, farmId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar evento: $e'));
    }
  }

  @override
  Future<Result<EventoReproductivo?>> getUltimaInseminacion(
    String animalId,
    String farmId,
  ) async {
    try {
      final eventos = await dataSource.getEventosByAnimal(animalId, farmId);
      final inseminaciones = eventos
          .where((e) => e.tipo == TipoEventoReproductivo.montaInseminacion)
          .toList();
      
      if (inseminaciones.isEmpty) {
        return const Success(null);
      }
      
      // Ordenar por fecha descendente y tomar el más reciente
      inseminaciones.sort((a, b) => b.fecha.compareTo(a.fecha));
      return Success(inseminaciones.first as EventoReproductivo);
    } catch (e) {
      return Error(CacheFailure('Error al obtener última inseminación: $e'));
    }
  }
}

