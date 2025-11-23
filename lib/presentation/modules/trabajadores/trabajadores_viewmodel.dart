import 'package:flutter/foundation.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/trabajadores/trabajador.dart';
import '../../../domain/usecases/trabajadores/get_all_trabajadores.dart';
import '../../../domain/usecases/trabajadores/create_trabajador.dart';
import '../../../domain/usecases/trabajadores/update_trabajador.dart';
import '../../../domain/usecases/trabajadores/delete_trabajador.dart';
import '../../../domain/usecases/trabajadores/get_trabajadores_activos.dart';

/// ViewModel para gestión de Trabajadores
class TrabajadoresViewModel extends ChangeNotifier {
  final GetAllTrabajadores getAllTrabajadores;
  final CreateTrabajador createTrabajador;
  final UpdateTrabajador updateTrabajador;
  final DeleteTrabajador deleteTrabajador;
  final GetTrabajadoresActivos getTrabajadoresActivos;

  TrabajadoresViewModel({
    required this.getAllTrabajadores,
    required this.createTrabajador,
    required this.updateTrabajador,
    required this.deleteTrabajador,
    required this.getTrabajadoresActivos,
  });

  // Estado
  List<Trabajador> _trabajadores = [];
  Trabajador? _selectedTrabajador;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showOnlyActivos = false;

  // Getters
  List<Trabajador> get trabajadores => _showOnlyActivos 
      ? _trabajadores.where((t) => t.isActive).toList()
      : _trabajadores;
  Trabajador? get selectedTrabajador => _selectedTrabajador;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get showOnlyActivos => _showOnlyActivos;

  /// Carga todos los trabajadores de una finca
  Future<void> loadTrabajadores(String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getAllTrabajadores(farmId);
    
    switch (result) {
      case Success<List<Trabajador>>(:final data):
        _trabajadores = data;
        _setLoading(false);
      case Error<List<Trabajador>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Carga solo trabajadores activos
  Future<void> loadTrabajadoresActivos(String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getTrabajadoresActivos(farmId);
    
    switch (result) {
      case Success<List<Trabajador>>(:final data):
        _trabajadores = data;
        _setLoading(false);
      case Error<List<Trabajador>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Crea un nuevo trabajador
  Future<bool> createTrabajadorEntity(Trabajador trabajador, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await createTrabajador(trabajador);
    
    return switch (result) {
      Success<Trabajador>(:final data) => () {
        _trabajadores.add(data);
        _setLoading(false);
        return true;
      }(),
      Error<Trabajador>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza un trabajador existente
  Future<bool> updateTrabajadorEntity(Trabajador trabajador, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await updateTrabajador(trabajador);
    
    return switch (result) {
      Success<Trabajador>(:final data) => () {
        final index = _trabajadores.indexWhere((t) => t.id == data.id);
        if (index != -1) {
          _trabajadores[index] = data;
        }
        if (_selectedTrabajador?.id == data.id) {
          _selectedTrabajador = data;
        }
        _setLoading(false);
        return true;
      }(),
      Error<Trabajador>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina un trabajador
  Future<bool> deleteTrabajadorEntity(String id, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await deleteTrabajador(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _trabajadores.removeWhere((t) => t.id == id);
        if (_selectedTrabajador?.id == id) {
          _selectedTrabajador = null;
        }
        _setLoading(false);
        return true;
      }(),
      Error<void>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Selecciona un trabajador
  void selectTrabajador(Trabajador? trabajador) {
    _selectedTrabajador = trabajador;
    notifyListeners();
  }

  /// Alterna el filtro de trabajadores activos
  void toggleShowOnlyActivos() {
    _showOnlyActivos = !_showOnlyActivos;
    notifyListeners();
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
