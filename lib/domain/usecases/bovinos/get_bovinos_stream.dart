import 'dart:async';
import '../../../domain/entities/bovinos/bovino.dart';
import '../../../domain/repositories/bovinos/bovinos_repository.dart';
import '../../../core/utils/result.dart';

/// Use case para obtener todos los bovinos como Stream
class GetBovinosStream {
  final BovinosRepository repository;
  final String farmId;

  GetBovinosStream({
    required this.repository,
    required this.farmId,
  });

  /// Devuelve un Stream de todos los bovinos
  Stream<List<Bovino>> call() {
    // Si el repositorio tiene un método Stream, usarlo directamente
    // Si no, convertir el Future en un Stream con polling
    final controller = StreamController<List<Bovino>>();
    Timer? timer;
    
    // Función para cargar bovinos
    Future<void> loadBovinos() async {
      if (controller.isClosed) return;
      
      try {
        final result = await repository.getAllBovinos(farmId);
        if (controller.isClosed) return;
        
        switch (result) {
          case Success<List<Bovino>>(:final data):
            controller.add(data);
          case Error<List<Bovino>>():
            controller.addError('Error al obtener bovinos');
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError('Error al obtener bovinos: $e');
        }
      }
    }

    // Cargar inicialmente
    loadBovinos();

    // Polling cada 2 segundos para simular un Stream en tiempo real
    // En producción, esto debería ser reemplazado por un Stream real del repositorio
    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      loadBovinos();
    });

    // Cancelar el timer cuando el stream se cierre
    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

