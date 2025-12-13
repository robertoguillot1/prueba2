import 'package:equatable/equatable.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';

/// Estados del Cubit de Lista de Bovinos
abstract class BovineListState extends Equatable {
  const BovineListState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class BovineListInitial extends BovineListState {
  const BovineListInitial();
}

/// Estado de carga
class BovineListLoading extends BovineListState {
  const BovineListLoading();
}

/// Estado de datos cargados
class BovineListLoaded extends BovineListState {
  final List<BovineEntity> bovines;
  final String? searchQuery;

  const BovineListLoaded({
    required this.bovines,
    this.searchQuery,
  });

  /// Filtra la lista según la consulta de búsqueda
  List<BovineEntity> get filteredBovines {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return bovines;
    }

    final query = searchQuery!.toLowerCase();
    return bovines.where((bovine) {
      return bovine.identifier.toLowerCase().contains(query) ||
          (bovine.name?.toLowerCase().contains(query) ?? false) ||
          bovine.breed.toLowerCase().contains(query);
    }).toList();
  }

  @override
  List<Object?> get props => [bovines, searchQuery];

  BovineListLoaded copyWith({
    List<BovineEntity>? bovines,
    String? searchQuery,
  }) {
    return BovineListLoaded(
      bovines: bovines ?? this.bovines,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Estado de error
class BovineListError extends BovineListState {
  final String message;

  const BovineListError(this.message);

  @override
  List<Object?> get props => [message];
}





