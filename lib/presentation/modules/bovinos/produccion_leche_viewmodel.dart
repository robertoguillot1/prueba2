import 'package:flutter/foundation.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovinos/produccion_leche.dart';
import '../../../domain/usecases/bovinos/get_producciones_leche_by_bovino.dart';
import '../../../domain/usecases/bovinos/get_producciones_leche_by_fecha.dart';

/// ViewModel para gestión de Producción de Leche
class ProduccionLecheViewModel extends ChangeNotifier {
  final GetProduccionesLecheByBovino getProduccionesByBovino;
  final GetProduccionesLecheByFecha getProduccionesByFecha;

  ProduccionLecheViewModel({
    required this.getProduccionesByBovino,
    required this.getProduccionesByFecha,
  });

  // Estado
  List<ProduccionLeche> _producciones = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProduccionLeche> get producciones => _producciones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carga producciones de leche de un bovino específico
  Future<void> loadProduccionesByBovino(String bovinoId, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getProduccionesByBovino(bovinoId, farmId);
    
    switch (result) {
      case Success<List<ProduccionLeche>>(:final data):
        _producciones = data;
        _setLoading(false);
      case Error<List<ProduccionLeche>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Carga producciones de leche por rango de fechas
  Future<void> loadProduccionesByFecha(
    String farmId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await getProduccionesByFecha(farmId, fechaInicio, fechaFin);
    
    switch (result) {
      case Success<List<ProduccionLeche>>(:final data):
        _producciones = data;
        _setLoading(false);
      case Error<List<ProduccionLeche>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
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

  /// Limpia el error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Métodos privados
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  String _getErrorMessage(Failure failure) {
    return failure.message;
  }
}
