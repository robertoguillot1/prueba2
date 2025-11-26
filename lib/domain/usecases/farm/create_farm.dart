import 'package:flutter/foundation.dart';
import '../../entities/farm/farm.dart';
import '../../repositories/farm_repository.dart';

/// Caso de uso para crear una nueva finca
class CreateFarm {
  final FarmRepository repository;

  CreateFarm(this.repository);

  /// Crea una nueva finca con timeout de 30 segundos
  Future<Farm> call(Farm farm) async {
    debugPrint('🔵 [CreateFarm UseCase] Iniciando creación de finca: ${farm.name}');
    
    try {
      final result = await repository.createFarm(farm).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [CreateFarm UseCase] TIMEOUT - Firebase no respondió en 30s');
          throw Exception('Timeout: La operación tardó demasiado. Verifica tu conexión a internet.');
        },
      );
      
      debugPrint('✅ [CreateFarm UseCase] Finca creada exitosamente - ID: ${result.id}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [CreateFarm UseCase] Error: $e');
      debugPrint('❌ [CreateFarm UseCase] StackTrace: $stackTrace');
      rethrow;
    }
  }
}


