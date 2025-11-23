import 'dart:async';
import '../../../domain/entities/avicultura/gallina.dart';
import '../../../domain/repositories/avicultura/gallinas_repository.dart';
import '../../../core/utils/result.dart';

/// Use case para obtener todas las gallinas como Stream
class GetGallinasStream {
  final GallinasRepository repository;
  final String farmId;

  GetGallinasStream({
    required this.repository,
    required this.farmId,
  });

  /// Devuelve un Stream de todas las gallinas
  Stream<List<Gallina>> call() {
    final controller = StreamController<List<Gallina>>();
    Timer? timer;
    
    Future<void> loadGallinas() async {
      if (controller.isClosed) return;
      
      try {
        final result = await repository.getAllGallinas(farmId);
        if (controller.isClosed) return;
        
        switch (result) {
          case Success<List<Gallina>>(:final data):
            controller.add(data);
          case Error<List<Gallina>>():
            controller.addError('Error al obtener gallinas');
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError('Error al obtener gallinas: $e');
        }
      }
    }

    loadGallinas();

    timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (controller.isClosed) {
        t.cancel();
        return;
      }
      loadGallinas();
    });

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }
}

