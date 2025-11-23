import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../entities/bovinos/evento_reproductivo.dart';
import '../../entities/bovinos/bovino.dart';
import '../../repositories/bovinos/eventos_reproductivos_repository.dart';
import '../../repositories/bovinos/bovinos_repository.dart';

/// Caso de uso para registrar un parto y crear la cría automáticamente
class RegistrarPartoConCria {
  final EventosReproductivosRepository eventosRepository;
  final BovinosRepository bovinosRepository;

  RegistrarPartoConCria({
    required this.eventosRepository,
    required this.bovinosRepository,
  });

  /// Registra un parto y opcionalmente crea la cría
  /// 
  /// [eventoParto] - El evento de parto a registrar
  /// [crearCria] - Si es true, crea automáticamente la cría
  /// [datosCria] - Datos de la cría si se va a crear (opcional)
  Future<Result<Map<String, dynamic>>> call({
    required EventoReproductivo eventoParto,
    required bool crearCria,
    Map<String, dynamic>? datosCria,
  }) async {
    // Validar que el evento sea de tipo parto
    if (eventoParto.tipo != TipoEventoReproductivo.parto) {
      return Error(const ValidationFailure('El evento debe ser de tipo parto'));
    }

    // 1. Registrar el evento de parto
    final eventoResult = await eventosRepository.createEvento(eventoParto);
    
    switch (eventoResult) {
      case Error<EventoReproductivo>(:final failure):
        return Error(failure);
      case Success<EventoReproductivo>():
        break;
    }

    final eventoCreado = eventoResult.data!;

    // 2. Si se debe crear la cría, obtener la última inseminación para el padre
    String? idPadre;
    String? nombrePadre;

    if (crearCria) {
      final ultimaInseminacionResult = await eventosRepository.getUltimaInseminacion(
        eventoParto.idAnimal,
        eventoParto.farmId,
      );

      switch (ultimaInseminacionResult) {
        case Success<EventoReproductivo?>(:final data):
          if (data != null) {
            // Obtener el ID del toro de los detalles
            idPadre = data.idToro;
            nombrePadre = data.detalles['nombreToro'] as String?;
          }
        case Error<EventoReproductivo?>():
          // Si no hay inseminación, continuar sin padre
          break;
      }

      // 3. Obtener la madre para pre-rellenar datos
      final madreResult = await bovinosRepository.getBovinoById(
        eventoParto.idAnimal,
        eventoParto.farmId,
      );

      Bovino? madre;
      switch (madreResult) {
        case Success<Bovino>(:final data):
          madre = data;
        case Error<Bovino>():
          return Error(CacheFailure('No se pudo obtener la información de la madre'));
      }

      // 4. Crear la cría con datos pre-rellenados
      final criaId = DateTime.now().millisecondsSinceEpoch.toString();
      final cria = Bovino(
        id: criaId,
        farmId: eventoParto.farmId,
        identification: datosCria?['identification'] as String?,
        name: datosCria?['name'] as String?,
        category: BovinoCategory.ternero,
        gender: datosCria?['gender'] as BovinoGender? ?? BovinoGender.male,
        currentWeight: (datosCria?['currentWeight'] as num?)?.toDouble() ?? 0.0,
        birthDate: eventoParto.fecha,
        productionStage: ProductionStage.levante,
        healthStatus: HealthStatus.sano,
        idPadre: idPadre,
        nombrePadre: nombrePadre,
        idMadre: madre.id,
        nombreMadre: madre.name ?? madre.identification,
        raza: datosCria?['raza'] as String? ?? madre.raza,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final criaResult = await bovinosRepository.createBovino(cria);

      switch (criaResult) {
        case Success<Bovino>(:final data):
          // Actualizar el evento con el ID de la cría creada
          final detallesActualizados = Map<String, dynamic>.from(eventoParto.detalles);
          detallesActualizados['idCriaCreada'] = data.id;
          detallesActualizados['nacioCria'] = true;

          final eventoActualizado = EventoReproductivo(
            id: eventoCreado.id,
            farmId: eventoCreado.farmId,
            idAnimal: eventoCreado.idAnimal,
            tipo: eventoCreado.tipo,
            fecha: eventoCreado.fecha,
            detalles: detallesActualizados,
            notas: eventoCreado.notas,
            createdAt: eventoCreado.createdAt,
            updatedAt: DateTime.now(),
          );

          await eventosRepository.updateEvento(eventoActualizado);

          return Success({
            'evento': eventoActualizado,
            'cria': data,
          });
        case Error<Bovino>(:final failure):
          return Error(failure);
      }
    }

    // Si no se crea cría, solo retornar el evento
    return Success({
      'evento': eventoCreado,
      'cria': null,
    });
  }
}

