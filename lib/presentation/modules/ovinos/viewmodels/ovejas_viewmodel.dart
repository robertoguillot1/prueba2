import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/ovinos/oveja.dart';
import '../../../../domain/usecases/ovinos/get_all_ovejas.dart';
import '../../../../domain/usecases/ovinos/get_oveja_by_id.dart';
import '../../../../domain/usecases/ovinos/create_oveja.dart';
import '../../../../domain/usecases/ovinos/update_oveja.dart';
import '../../../../domain/usecases/ovinos/delete_oveja.dart';
import '../../../../domain/usecases/ovinos/search_ovejas.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Ovejas
/// 
/// Maneja el estado y la lógica de negocio para las operaciones CRUD de ovejas.
/// Incluye carga, creación, actualización, eliminación y búsqueda.
class OvejasViewModel extends BaseViewModel {
  final GetAllOvejas getAllOvejas;
  final GetOvejaById getOvejaById;
  final CreateOveja createOveja;
  final UpdateOveja updateOveja;
  final DeleteOveja deleteOveja;
  final SearchOvejas searchOvejas;

  OvejasViewModel({
    required this.getAllOvejas,
    required this.getOvejaById,
    required this.createOveja,
    required this.updateOveja,
    required this.deleteOveja,
    required this.searchOvejas,
  });

  // Estado
  List<Oveja> _ovejas = [];
  Oveja? _selectedOveja;
  String _searchQuery = '';

  // Getters
  List<Oveja> get ovejas => _ovejas;
  Oveja? get selectedOveja => _selectedOveja;
  String get searchQuery => _searchQuery;

  /// Carga todas las ovejas de una finca
  /// 
  /// [farmId] - ID de la finca
  Future<void> loadOvejas(String farmId) async {
    setLoading(true);
    clearError();

    final result = await getAllOvejas(farmId);
    
    switch (result) {
      case Success<List<Oveja>>(:final data):
        _ovejas = data;
        setLoading(false);
      case Error<List<Oveja>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Obtiene una oveja por su ID
  /// 
  /// [id] - ID de la oveja
  /// [farmId] - ID de la finca
  Future<void> loadOvejaById(String id, String farmId) async {
    setLoading(true);
    clearError();

    final result = await getOvejaById(id, farmId);
    
    switch (result) {
      case Success<Oveja>(:final data):
        _selectedOveja = data;
        setLoading(false);
      case Error<Oveja>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Crea una nueva oveja
  /// 
  /// [oveja] - Entidad de oveja a crear
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> createOvejaEntity(Oveja oveja, String farmId) async {
    setLoading(true);
    clearError();

    final result = await createOveja(oveja);
    
    return switch (result) {
      Success<Oveja>(:final data) => () {
        _ovejas.add(data);
        setLoading(false);
        return true;
      }(),
      Error<Oveja>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza una oveja existente
  /// 
  /// [oveja] - Entidad de oveja con los datos actualizados
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> updateOvejaEntity(Oveja oveja, String farmId) async {
    setLoading(true);
    clearError();

    final result = await updateOveja(oveja);
    
    return switch (result) {
      Success<Oveja>(:final data) => () {
        final index = _ovejas.indexWhere((o) => o.id == data.id);
        if (index != -1) {
          _ovejas[index] = data;
        }
        if (_selectedOveja?.id == data.id) {
          _selectedOveja = data;
        }
        setLoading(false);
        return true;
      }(),
      Error<Oveja>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina una oveja
  /// 
  /// [id] - ID de la oveja a eliminar
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  Future<bool> deleteOvejaEntity(String id, String farmId) async {
    setLoading(true);
    clearError();

    final result = await deleteOveja(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _ovejas.removeWhere((o) => o.id == id);
        if (_selectedOveja?.id == id) {
          _selectedOveja = null;
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

  /// Busca ovejas por nombre o identificación
  /// 
  /// [farmId] - ID de la finca
  /// [query] - Término de búsqueda
  Future<void> search(String farmId, String query) async {
    _searchQuery = query;
    setLoading(true);
    clearError();

    final result = await searchOvejas(farmId, query);
    
    switch (result) {
      case Success<List<Oveja>>(:final data):
        _ovejas = data;
        setLoading(false);
      case Error<List<Oveja>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Selecciona una oveja
  /// 
  /// [oveja] - Oveja a seleccionar, o `null` para deseleccionar
  void selectOveja(Oveja? oveja) {
    _selectedOveja = oveja;
    notifyListeners();
  }

  /// Limpia la lista y el estado de búsqueda
  void clearList() {
    _ovejas = [];
    _searchQuery = '';
    _selectedOveja = null;
    clearState();
  }
}
