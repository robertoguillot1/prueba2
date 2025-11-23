import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../domain/usecases/trabajadores/get_all_trabajadores.dart';
import '../../../../domain/usecases/trabajadores/create_trabajador.dart';
import '../../../../domain/usecases/trabajadores/update_trabajador.dart';
import '../../../../domain/usecases/trabajadores/delete_trabajador.dart';
import '../../../../domain/usecases/trabajadores/get_trabajadores_activos.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Trabajadores
/// 
/// Maneja el estado y la lógica de negocio para las operaciones CRUD de trabajadores.
/// Incluye carga, creación, actualización, eliminación y filtrado por estado activo.
class TrabajadoresViewModel extends BaseViewModel {
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
  bool _showOnlyActivos = false;

  // Getters
  List<Trabajador> get trabajadores => _showOnlyActivos 
      ? _trabajadores.where((t) => t.isActive).toList()
      : _trabajadores;
  Trabajador? get selectedTrabajador => _selectedTrabajador;
  bool get showOnlyActivos => _showOnlyActivos;

  /// Carga todos los trabajadores de una finca
  /// 
  /// [farmId] - ID de la finca
  Future<void> loadTrabajadores(String farmId) async {
    setLoading(true);
    clearError();

    final result = await getAllTrabajadores(farmId);
    
    switch (result) {
      case Success<List<Trabajador>>(:final data):
        _trabajadores = data;
        setLoading(false);
      case Error<List<Trabajador>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Carga solo trabajadores activos
  /// 
  /// [farmId] - ID de la finca
  Future<void> loadTrabajadoresActivos(String farmId) async {
    setLoading(true);
    clearError();

    final result = await getTrabajadoresActivos(farmId);
    
    switch (result) {
      case Success<List<Trabajador>>(:final data):
        _trabajadores = data;
        setLoading(false);
      case Error<List<Trabajador>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Crea un nuevo trabajador
  /// 
  /// [trabajador] - Entidad de trabajador a crear
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> createTrabajadorEntity(Trabajador trabajador, String farmId) async {
    setLoading(true);
    clearError();

    final result = await createTrabajador(trabajador);
    
    return switch (result) {
      Success<Trabajador>(:final data) => () {
        _trabajadores.add(data);
        setLoading(false);
        return true;
      }(),
      Error<Trabajador>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza un trabajador existente
  /// 
  /// [trabajador] - Entidad de trabajador con los datos actualizados
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> updateTrabajadorEntity(Trabajador trabajador, String farmId) async {
    setLoading(true);
    clearError();

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
        setLoading(false);
        return true;
      }(),
      Error<Trabajador>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina un trabajador
  /// 
  /// [id] - ID del trabajador a eliminar
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> deleteTrabajadorEntity(String id, String farmId) async {
    setLoading(true);
    clearError();

    final result = await deleteTrabajador(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _trabajadores.removeWhere((t) => t.id == id);
        if (_selectedTrabajador?.id == id) {
          _selectedTrabajador = null;
        }
        setLoading(false);
        return true;
      }(),
      Error<void>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Selecciona un trabajador
  /// 
  /// [trabajador] - Trabajador a seleccionar, o `null` para deseleccionar
  void selectTrabajador(Trabajador? trabajador) {
    _selectedTrabajador = trabajador;
    notifyListeners();
  }

  /// Alterna el filtro de trabajadores activos
  /// 
  /// Cambia entre mostrar todos los trabajadores o solo los activos
  void toggleShowOnlyActivos() {
    _showOnlyActivos = !_showOnlyActivos;
    notifyListeners();
  }

  /// Limpia la lista y el estado
  void clearList() {
    _trabajadores = [];
    _selectedTrabajador = null;
    _showOnlyActivos = false;
    clearState();
  }
}
