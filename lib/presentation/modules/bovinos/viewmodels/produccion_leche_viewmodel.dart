import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/bovinos/produccion_leche.dart';
import '../../../../domain/usecases/bovinos/get_producciones_leche_by_bovino.dart';
import '../../../../domain/usecases/bovinos/get_producciones_leche_by_fecha.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Producción de Leche
class ProduccionLecheViewModel extends BaseViewModel {
  final GetProduccionesLecheByBovino getProduccionesByBovino;
  final GetProduccionesLecheByFecha getProduccionesByFecha;

  ProduccionLecheViewModel({
    required this.getProduccionesByBovino,
    required this.getProduccionesByFecha,
  });

  // Estado
  List<ProduccionLeche> _producciones = [];

  // Getters
  List<ProduccionLeche> get producciones => _producciones;

  /// Carga producciones de leche de un bovino específico
  Future<void> loadProduccionesByBovino(String bovinoId, String farmId) async {
    setLoading(true);
    clearError();

    final result = await getProduccionesByBovino(bovinoId, farmId);
    
    switch (result) {
      case Success<List<ProduccionLeche>>(:final data):
        _producciones = data;
        setLoading(false);
      case Error<List<ProduccionLeche>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Carga producciones de leche por rango de fechas
  Future<void> loadProduccionesByFecha(
    String farmId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    setLoading(true);
    clearError();

    final result = await getProduccionesByFecha(farmId, fechaInicio, fechaFin);
    
    switch (result) {
      case Success<List<ProduccionLeche>>(:final data):
        _producciones = data;
        setLoading(false);
      case Error<List<ProduccionLeche>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Calcula el promedio diario de producción
  double get promedioDiario {
    if (_producciones.isEmpty) return 0.0;
    final total = _producciones.fold<double>(
      0.0,
      (sum, p) => sum + p.litersProduced,
    );
    return total / _producciones.length;
  }

  /// Calcula el total de litros producidos
  double get totalLitros {
    return _producciones.fold<double>(
      0.0,
      (sum, p) => sum + p.litersProduced,
    );
  }

  /// Limpia la lista y el estado
  void clearList() {
    _producciones = [];
    clearState();
  }
}
