import 'package:flutter/foundation.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovinos/bovino.dart';
import '../../../domain/usecases/bovinos/get_all_bovinos.dart';
import '../../../domain/usecases/bovinos/create_bovino.dart';
import '../../../domain/usecases/bovinos/update_bovino.dart';
import '../../../domain/usecases/bovinos/delete_bovino.dart';

/// ViewModel para gestión de Bovinos
class BovinosViewModel extends ChangeNotifier {
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
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Bovino> get bovinos => _bovinos;
  Bovino? get selectedBovino => _selectedBovino;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carga todos los bovinos de una finca
  Future<void> loadBovinos(String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getAllBovinos(farmId);
    
    switch (result) {
      case Success<List<Bovino>>(:final data):
        _bovinos = data;
        _setLoading(false);
      case Error<List<Bovino>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Crea un nuevo bovino
  Future<bool> createBovinoEntity(Bovino bovino, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await createBovino(bovino);
    
    return switch (result) {
      Success<Bovino>(:final data) => () {
        _bovinos.add(data);
        _setLoading(false);
        return true;
      }(),
      Error<Bovino>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Actualiza un bovino existente
  Future<bool> updateBovinoEntity(Bovino bovino, String farmId) async {
    _setLoading(true);
    _clearError();

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
        _setLoading(false);
        return true;
      }(),
      Error<Bovino>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Elimina un bovino
  Future<bool> deleteBovinoEntity(String id, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await deleteBovino(id, farmId);
    
    return switch (result) {
      Success<void>() => () {
        _bovinos.removeWhere((b) => b.id == id);
        if (_selectedBovino?.id == id) {
          _selectedBovino = null;
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

  /// Selecciona un bovino
  void selectBovino(Bovino? bovino) {
    _selectedBovino = bovino;
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
