import 'package:flutter/foundation.dart';
import '../../repositories/farm_repository.dart';

/// Caso de uso para establecer la finca actual del usuario
class SetCurrentFarm {
  final FarmRepository repository;

  SetCurrentFarm(this.repository);

  /// Establece la finca actual del usuario con timeout de 10 segundos
  Future<void> call(String userId, String farmId) async {
    debugPrint('🔵 [SetCurrentFarm UseCase] Iniciando - userId: $userId, farmId: $farmId');
    
    try {
      await repository.setCurrentFarmId(userId, farmId).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ [SetCurrentFarm UseCase] TIMEOUT - Operación tardó más de 10s');
          throw Exception('Timeout: No se pudo establecer la finca actual. Verifica tu conexión.');
        },
      );
      
      debugPrint('✅ [SetCurrentFarm UseCase] Finca actual establecida exitosamente');
    } catch (e, stackTrace) {
      debugPrint('❌ [SetCurrentFarm UseCase] Error: $e');
      debugPrint('❌ [SetCurrentFarm UseCase] StackTrace: $stackTrace');
      rethrow;
    }
  }
}


