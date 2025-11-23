import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';

/// Clase base para ViewModels con manejo común de estado
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  /// Indica si está cargando
  bool get isLoading => _isLoading;

  /// Mensaje de error actual
  String? get errorMessage => _errorMessage;

  /// Indica si hay un error
  bool get hasError => _errorMessage != null;

  /// Establece el estado de carga
  @protected
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Establece un mensaje de error
  @protected
  void setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      notifyListeners();
    }
  }

  /// Limpia el error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Obtiene un mensaje de error amigable desde un Failure
  @protected
  String getErrorMessage(Failure failure) {
    return failure.message;
  }

  /// Limpia el estado (loading y error)
  @protected
  void clearState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

