import 'dart:async';
import '../../../domain/entities/porcinos/cerdo.dart';
import '../../../domain/repositories/porcinos/cerdos_repository.dart';
import '../../../core/utils/result.dart';

/// Use case para obtener todos los cerdos como Stream
class GetCerdosStream {
  final CerdosRepository repository;
  final String farmId;

  GetCerdosStream({
    required this.repository,
    required this.farmId,
  });

  /// Devuelve un Stream de todos los cerdos
  Stream<List<Cerdo>> call() {
    final controller = StreamController<List<Cerdo>>();
    Timer? timer;
    
    Future<void> loadCerdos() async {
      if (controller.isClosed) return;
      
      try {
        final result = await repository.getAllCerdos(farmId);
        if (controller.isClosed) return;
        
        switch (result) {
          case Success<List<Cerdo>>(:final data):
            controller.add(data);
          case Error<List<Cerdo>>():
            controller.addError('Error al obtener cerdos');
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError('Error al obtener cerdos: $e');
        }
      }
    }

    loadCerdos();

    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      loadCerdos();
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

