import 'dart:async';
import '../../../domain/entities/ovinos/oveja.dart';
import '../../../domain/repositories/ovinos/ovejas_repository.dart';
import '../../../core/utils/result.dart';

/// Use case para obtener todas las ovejas como Stream
class GetOvejasStream {
  final OvejasRepository repository;
  final String farmId;

  GetOvejasStream({
    required this.repository,
    required this.farmId,
  });

  /// Devuelve un Stream de todas las ovejas
  Stream<List<Oveja>> call() {
    final controller = StreamController<List<Oveja>>();
    Timer? timer;
    
    Future<void> loadOvejas() async {
      if (controller.isClosed) return;
      
      try {
        final result = await repository.getAllOvejas(farmId);
        if (controller.isClosed) return;
        
        switch (result) {
          case Success<List<Oveja>>(:final data):
            controller.add(data);
          case Error<List<Oveja>>():
            controller.addError('Error al obtener ovejas');
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError('Error al obtener ovejas: $e');
        }
      }
    }

    loadOvejas();

    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      loadOvejas();
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

