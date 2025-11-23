import 'package:flutter/foundation.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/avicultura/gallina.dart';
import '../../../domain/usecases/avicultura/get_all_gallinas.dart';
import '../../../domain/usecases/avicultura/create_gallina.dart';

/// ViewModel para gestión de Gallinas
class GallinasViewModel extends ChangeNotifier {
  final GetAllGallinas getAllGallinas;
  final CreateGallina createGallina;

  GallinasViewModel({
    required this.getAllGallinas,
    required this.createGallina,
  });

  // Estado
  List<Gallina> _gallinas = [];
  Gallina? _selectedGallina;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Gallina> get gallinas => _gallinas;
  Gallina? get selectedGallina => _selectedGallina;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carga todas las gallinas de una finca
  Future<void> loadGallinas(String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await getAllGallinas(farmId);
    
    switch (result) {
      case Success<List<Gallina>>(:final data):
        _gallinas = data;
        _setLoading(false);
      case Error<List<Gallina>>(:final failure):
        _setError(_getErrorMessage(failure));
        _setLoading(false);
    }
  }

  /// Crea una nueva gallina
  Future<bool> createGallinaEntity(Gallina gallina, String farmId) async {
    _setLoading(true);
    _clearError();

    final result = await createGallina(gallina);
    
    return switch (result) {
      Success<Gallina>(:final data) => () {
        _gallinas.add(data);
        _setLoading(false);
        return true;
      }(),
      Error<Gallina>(:final failure) => () {
        _setError(_getErrorMessage(failure));
        _setLoading(false);
        return false;
      }(),
    };
  }

  /// Selecciona una gallina
  void selectGallina(Gallina? gallina) {
    _selectedGallina = gallina;
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
