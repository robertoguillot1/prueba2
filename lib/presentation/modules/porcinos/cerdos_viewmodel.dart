import 'package:flutter/foundation.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/porcinos/cerdo.dart';
import '../../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../../domain/usecases/porcinos/create_cerdo.dart';
import '../../../domain/usecases/porcinos/update_cerdo.dart';
import '../../../domain/usecases/porcinos/delete_cerdo.dart';

/// ViewModel para gestión de Cerdos
class CerdosViewModel extends ChangeNotifier {
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
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Cerdo> get cerdos => _cerdos;
  Cerdo? get selectedCerdo => _selectedCerdo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carga todos los cerdos de una finca
  Future<void> loadCerdos(String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getAllCerdos(farmId);
    
    switch (result) {
      case Success<List<Cerdo>>(:final data):
        _cerdos = data;
        _setLoading(false);
      case Error<List<Cerdo>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Crea un nuevo cerdo
  Future<bool> createCerdoEntity(Cerdo cerdo, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await createCerdo(cerdo);
    
    return switch (result) {
      Success<Cerdo>(:final data) => () {
        _cerdos.add(data);
        _setLoading(false);
        return true;
      }(),
      Error<Cerdo>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza un cerdo existente
  Future<bool> updateCerdoEntity(Cerdo cerdo, String farmId) async {
    _setLoading(true);
    _clearError();

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
        _setLoading(false);
        return true;
      }(),
      Error<Cerdo>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina un cerdo
  Future<bool> deleteCerdoEntity(String id, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await deleteCerdo(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _cerdos.removeWhere((c) => c.id == id);
        if (_selectedCerdo?.id == id) {
          _selectedCerdo = null;
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

  /// Selecciona un cerdo
  void selectCerdo(Cerdo? cerdo) {
    _selectedCerdo = cerdo;
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
