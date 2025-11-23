import 'dart:async';
import '../../../domain/entities/trabajadores/trabajador.dart';
import '../../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../../core/utils/result.dart';

/// Use case para obtener todos los trabajadores como Stream
class GetTrabajadoresStream {
  final TrabajadoresRepository repository;
  final String farmId;

  GetTrabajadoresStream({
    required this.repository,
    required this.farmId,
  });

  /// Devuelve un Stream de todos los trabajadores
  Stream<List<Trabajador>> call() {
    final controller = StreamController<List<Trabajador>>();
    Timer? timer;
    
    Future<void> loadTrabajadores() async {
      if (controller.isClosed) return;
      
      try {
        final result = await repository.getAllTrabajadores(farmId);
        if (controller.isClosed) return;
        
        switch (result) {
          case Success<List<Trabajador>>(:final data):
            controller.add(data);
          case Error<List<Trabajador>>():
            controller.addError('Error al obtener trabajadores');
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError('Error al obtener trabajadores: $e');
        }
      }
    }

    loadTrabajadores();

    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      loadTrabajadores();
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

