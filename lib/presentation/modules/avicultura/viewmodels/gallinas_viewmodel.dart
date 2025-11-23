import 'package:flutter/foundation.dart';
import '../../../../core/utils/result.dart' show Result, Success, Error;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/avicultura/gallina.dart';
import '../../../../domain/usecases/avicultura/get_all_gallinas.dart';
import '../../../../domain/usecases/avicultura/create_gallina.dart';
import '../../base/base_viewmodel.dart';

/// ViewModel para gestión de Gallinas
/// 
/// Maneja el estado y la lógica de negocio para las operaciones CRUD de gallinas.
/// Incluye carga y creación.
/// 
/// Nota: Actualmente solo tiene métodos de creación. Se puede extender con
/// update y delete cuando estén disponibles en los use cases.
class GallinasViewModel extends BaseViewModel {
  final GetAllGallinas getAllGallinas;
  final CreateGallina createGallina;

  GallinasViewModel({
    required this.getAllGallinas,
    required this.createGallina,
  });

  // Estado
  List<Gallina> _gallinas = [];
  Gallina? _selectedGallina;

  // Getters
  List<Gallina> get gallinas => _gallinas;
  Gallina? get selectedGallina => _selectedGallina;

  /// Carga todas las gallinas de una finca
  /// 
  /// [farmId] - ID de la finca
  Future<void> loadGallinas(String farmId) async {
    setLoading(true);
    clearError();

    final result = await getAllGallinas(farmId);
    
    switch (result) {
      case Success<List<Gallina>>(:final data):
        _gallinas = data;
        setLoading(false);
      case Error<List<Gallina>>(:final failure):
        setError(getErrorMessage(failure));
        setLoading(false);
    }
  }

  /// Crea una nueva gallina
  /// 
  /// [gallina] - Entidad de gallina a crear
  /// [farmId] - ID de la finca
  /// 
  /// Retorna `true` si la operación fue exitosa, `false` en caso contrario
  /// 
  /// Nota: Este método también se usa para actualizar temporalmente hasta
  /// que se implemente updateGallinaEntity
  Future<bool> createGallinaEntity(Gallina gallina, String farmId) async {
    setLoading(true);
    clearError();

    final result = await createGallina(gallina);
    
    return switch (result) {
      Success<Gallina>(:final data) => () {
        // Si ya existe, actualizar; si no, agregar
        final index = _gallinas.indexWhere((g) => g.id == data.id);
        if (index != -1) {
          _gallinas[index] = data;
        } else {
          _gallinas.add(data);
        }
        setLoading(false);
        return true;
      }(),
      Error<Gallina>(:final failure) => () {
        setError(getErrorMessage(failure));
        setLoading(false);
        return false;
      }(),
    };
  }

  /// Selecciona una gallina
  /// 
  /// [gallina] - Gallina a seleccionar, o `null` para deseleccionar
  void selectGallina(Gallina? gallina) {
    _selectedGallina = gallina;
    notifyListeners();
  }

  /// Limpia la lista y el estado
  void clearList() {
    _gallinas = [];
    _selectedGallina = null;
    clearState();
  }
}
