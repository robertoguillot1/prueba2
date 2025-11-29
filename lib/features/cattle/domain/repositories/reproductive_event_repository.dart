import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reproductive_event_entity.dart';

/// Contrato abstracto del repositorio para Eventos Reproductivos
abstract class ReproductiveEventRepository {
  /// Obtiene todos los eventos reproductivos de un bovino
  /// Retorna Either<Failure, List<ReproductiveEventEntity>>
  Future<Either<Failure, List<ReproductiveEventEntity>>> getEventsByBovine(
    String bovineId,
    String farmId,
  );

  /// Obtiene un evento reproductivo por su ID
  /// Retorna Either<Failure, ReproductiveEventEntity>
  Future<Either<Failure, ReproductiveEventEntity>> getEventById(
    String id,
    String bovineId,
    String farmId,
  );

  /// Agrega un nuevo evento reproductivo
  /// Retorna Either<Failure, ReproductiveEventEntity> con el evento creado
  Future<Either<Failure, ReproductiveEventEntity>> addEvent(
    ReproductiveEventEntity event,
  );

  /// Actualiza un evento reproductivo existente
  /// Retorna Either<Failure, ReproductiveEventEntity> con el evento actualizado
  Future<Either<Failure, ReproductiveEventEntity>> updateEvent(
    ReproductiveEventEntity event,
  );

  /// Elimina un evento reproductivo por su ID
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> deleteEvent(
    String id,
    String bovineId,
    String farmId,
  );
}

