import 'dart:async';
import '../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../domain/repositories/bovinos/eventos_reproductivos_repository.dart';
import '../../../core/utils/result.dart';

/// Use case para obtener eventos reproductivos de un bovino como Stream
class GetEventosReproductivosByBovino {
  final EventosReproductivosRepository repository;
  final String farmId;

  GetEventosReproductivosByBovino({
    required this.repository,
    required this.farmId,
  });

  /// Devuelve un Stream de eventos reproductivos para un bovino específico
  Stream<List<EventoReproductivo>> call(String bovinoId) {
    // Si el repositorio tiene un método Stream, usarlo directamente
    // Si no, convertir el Future en un Stream con polling
    final controller = StreamController<List<EventoReproductivo>>();
    Timer? timer;
    
    // Función para cargar eventos
    Future<void> loadEventos() async {
      if (controller.isClosed) return;
      
      try {
        final result = await repository.getEventosByAnimal(bovinoId, farmId);
        if (controller.isClosed) return;
        
        switch (result) {
          case Success<List<EventoReproductivo>>(:final data):
            controller.add(data);
          case Error<List<EventoReproductivo>>():
            controller.addError('Error al obtener eventos');
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError('Error al obtener eventos: $e');
        }
      }
    }

    // Cargar inicialmente
    loadEventos();

    // Polling cada 2 segundos para simular un Stream en tiempo real
    // En producción, esto debería ser reemplazado por un Stream real del repositorio
    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      loadEventos();
    });

    // Cancelar el timer cuando el stream se cierre
    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

