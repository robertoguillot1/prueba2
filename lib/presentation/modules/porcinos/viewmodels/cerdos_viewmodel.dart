import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';
import '../../../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../../../domain/usecases/porcinos/create_cerdo.dart';
import '../../../../domain/usecases/porcinos/update_cerdo.dart';
import '../../../../domain/usecases/porcinos/delete_cerdo.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Cerdos
/// 
/// Maneja el estado y la lógica de negocio para las operaciones CRUD de cerdos.
/// Incluye carga, creación, actualización y eliminación.
class CerdosViewModel extends BaseViewModel {
  final GetAllCerdos getAllCerdos;
  final CreateCerdo createCerdo;
  final UpdateCerdo updateCerdo;
  final DeleteCerdo deleteCerdo;

  CerdosViewModel({
    required this.getAllCerdos,
    required this.createCerdo,
    required this.updateCerdo,
    required this.deleteCerdo,
  });

  // Estado
  List<Cerdo> _cerdos = [];
  Cerdo? _selectedCerdo;

  // Getters
  List<Cerdo> get cerdos => _cerdos;
  Cerdo? get selectedCerdo => _selectedCerdo;

  /// Carga todos los cerdos de una finca
  /// 
  /// [farmId] - ID de la finca
  Future<void> loadCerdos(String farmId) async {
    setLoading(true);
    clearError();

    final result = await getAllCerdos(farmId);
    
    switch (result) {
      case Success<List<Cerdo>>(:final data):
        _cerdos = data;
        setLoading(false);
      case Error<List<Cerdo>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Crea un nuevo cerdo
  /// 
  /// [cerdo] - Entidad de cerdo a crear
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> createCerdoEntity(Cerdo cerdo, String farmId) async {
    setLoading(true);
    clearError();

    final result = await createCerdo(cerdo);
    
    return switch (result) {
      Success<Cerdo>(:final data) => () {
        _cerdos.add(data);
        setLoading(false);
        return true;
      }(),
      Error<Cerdo>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza un cerdo existente
  /// 
  /// [cerdo] - Entidad de cerdo con los datos actualizados
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> updateCerdoEntity(Cerdo cerdo, String farmId) async {
    setLoading(true);
    clearError();

    final result = await updateCerdo(cerdo);
    
    return switch (result) {
      Success<Cerdo>(:final data) => () {
        final index = _cerdos.indexWhere((c) => c.id == data.id);
        if (index != -1) {
          _cerdos[index] = data;
        }
        if (_selectedCerdo?.id == data.id) {
          _selectedCerdo = data;
        }
        setLoading(false);
        return true;
      }(),
      Error<Cerdo>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina un cerdo
  /// 
  /// [id] - ID del cerdo a eliminar
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> deleteCerdoEntity(String id, String farmId) async {
    setLoading(true);
    clearError();

    final result = await deleteCerdo(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _cerdos.removeWhere((c) => c.id == id);
        if (_selectedCerdo?.id == id) {
          _selectedCerdo = null;
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

  /// Selecciona un cerdo
  /// 
  /// [cerdo] - Cerdo a seleccionar, o `null` para deseleccionar
  void selectCerdo(Cerdo? cerdo) {
    _selectedCerdo = cerdo;
    notifyListeners();
  }

  /// Limpia la lista y el estado
  void clearList() {
    _cerdos = [];
    _selectedCerdo = null;
    clearState();
  }
}
