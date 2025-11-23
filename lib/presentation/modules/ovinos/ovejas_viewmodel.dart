import 'package:flutter/foundation.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/ovinos/oveja.dart';
import '../../../domain/usecases/ovinos/get_all_ovejas.dart';
import '../../../domain/usecases/ovinos/get_oveja_by_id.dart';
import '../../../domain/usecases/ovinos/create_oveja.dart';
import '../../../domain/usecases/ovinos/update_oveja.dart';
import '../../../domain/usecases/ovinos/delete_oveja.dart';
import '../../../domain/usecases/ovinos/search_ovejas.dart';

/// ViewModel para gestión de Ovejas
class OvejasViewModel extends ChangeNotifier {
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
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<Oveja> get ovejas => _ovejas;
  Oveja? get selectedOveja => _selectedOveja;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasError => _errorMessage != null;

  /// Carga todas las ovejas de una finca
  Future<void> loadOvejas(String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getAllOvejas(farmId);
    
    switch (result) {
      case Success<List<Oveja>>(:final data):
        _ovejas = data;
        _setLoading(false);
      case Error<List<Oveja>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Obtiene una oveja por su ID
  Future<void> loadOvejaById(String id, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getOvejaById(id, farmId);
    
    switch (result) {
      case Success<Oveja>(:final data):
        _selectedOveja = data;
        _setLoading(false);
      case Error<Oveja>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Crea una nueva oveja
  Future<bool> createOvejaEntity(Oveja oveja, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await createOveja(oveja);
    
    return switch (result) {
      Success<Oveja>(:final data) => () {
        _ovejas.add(data);
        _setLoading(false);
        return true;
      }(),
      Error<Oveja>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza una oveja existente
  Future<bool> updateOvejaEntity(Oveja oveja, String farmId) async {
    _setLoading(true);
    _clearError();

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
        _setLoading(false);
        return true;
      }(),
      Error<Oveja>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina una oveja
  Future<bool> deleteOvejaEntity(String id, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await deleteOveja(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _ovejas.removeWhere((o) => o.id == id);
        if (_selectedOveja?.id == id) {
          _selectedOveja = null;
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

  /// Busca ovejas
  Future<void> search(String farmId, String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();

    final result = await searchOvejas(farmId, query);
    
    switch (result) {
      case Success<List<Oveja>>(:final data):
        _ovejas = data;
        _setLoading(false);
      case Error<List<Oveja>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Selecciona una oveja
  void selectOveja(Oveja? oveja) {
    _selectedOveja = oveja;
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

