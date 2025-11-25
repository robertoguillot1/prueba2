import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../domain/usecases/bovinos/get_all_bovinos.dart';
import '../../../../domain/usecases/bovinos/create_bovino.dart';
import '../../../../domain/usecases/bovinos/update_bovino.dart';
import '../../../../domain/usecases/bovinos/delete_bovino.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Bovinos
/// 
/// Maneja el estado y la lógica de negocio para las operaciones CRUD de bovinos.
/// Incluye carga, creación, actualización y eliminación.
class BovinosViewModel extends BaseViewModel {
  final GetAllBovinos getAllBovinos;
  final CreateBovino createBovino;
  final UpdateBovino updateBovino;
  final DeleteBovino deleteBovino;

  BovinosViewModel({
    required this.getAllBovinos,
    required this.createBovino,
    required this.updateBovino,
    required this.deleteBovino,
  });

  // Estado
  List<Bovino> _bovinos = [];
  Bovino? _selectedBovino;

  // Getters
  List<Bovino> get bovinos => _bovinos;
  Bovino? get selectedBovino => _selectedBovino;

  /// Carga todos los bovinos de una finca
  /// 
  /// [farmId] - ID de la finca
  Future<void> loadBovinos(String farmId) async {
    setLoading(true);
    clearError();

    final result = await getAllBovinos(farmId);
    
    switch (result) {
      case Success<List<Bovino>>(:final data):
        _bovinos = data;
        setLoading(false);
      case Error<List<Bovino>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Crea un nuevo bovino
  /// 
  /// [bovino] - Entidad de bovino a crear
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> createBovinoEntity(Bovino bovino, String farmId) async {
    setLoading(true);
    clearError();

    final result = await createBovino(bovino);
    
    return switch (result) {
      Success<Bovino>(:final data) => () {
        _bovinos.add(data);
        setLoading(false);
        return true;
      }(),
      Error<Bovino>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza un bovino existente
  /// 
  /// [bovino] - Entidad de bovino con los datos actualizados
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> updateBovinoEntity(Bovino bovino, String farmId) async {
    setLoading(true);
    clearError();

    final result = await updateBovino(bovino);
    
    return switch (result) {
      Success<Bovino>(:final data) => () {
        final index = _bovinos.indexWhere((b) => b.id == data.id);
        if (index != -1) {
          _bovinos[index] = data;
        }
        if (_selectedBovino?.id == data.id) {
          _selectedBovino = data;
        }
        setLoading(false);
        return true;
      }(),
      Error<Bovino>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina un bovino
  /// 
  /// [id] - ID del bovino a eliminar
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> deleteBovinoEntity(String id, String farmId) async {
    setLoading(true);
    clearError();

    final result = await deleteBovino(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _bovinos.removeWhere((b) => b.id == id);
        if (_selectedBovino?.id == id) {
          _selectedBovino = null;
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

  /// Selecciona un bovino
  /// 
  /// [bovino] - Bovino a seleccionar, o `null` para deseleccionar
  void selectBovino(Bovino? bovino) {
    _selectedBovino = bovino;
    notifyListeners();
  }

  /// Limpia la lista y el estado
  void clearList() {
    _bovinos = [];
    _selectedBovino = null;
    clearState();
  }
}
