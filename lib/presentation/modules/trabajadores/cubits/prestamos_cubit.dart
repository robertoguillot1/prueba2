import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/result.dart';
import '../../../../features/trabajadores/domain/entities/prestamo.dart';
import '../../../../features/trabajadores/domain/usecases/get_prestamos.dart';
import '../../../../features/trabajadores/domain/usecases/add_prestamo.dart';
import '../../../../features/trabajadores/domain/usecases/update_prestamo.dart';
import '../../../../features/trabajadores/domain/usecases/delete_prestamo.dart';

abstract class PrestamosState extends Equatable {
  const PrestamosState();
  @override
  List<Object?> get props => [];
}

class PrestamosInitial extends PrestamosState {}
class PrestamosLoading extends PrestamosState {}
class PrestamosLoaded extends PrestamosState {
  final List<Prestamo> prestamos;
  final double totalDebt; // Helper for UI
  const PrestamosLoaded(this.prestamos, this.totalDebt);
  @override
  List<Object?> get props => [prestamos, totalDebt];
}
class PrestamosError extends PrestamosState {
  final String message;
  const PrestamosError(this.message);
  @override
  List<Object?> get props => [message];
}

class PrestamosCubit extends Cubit<PrestamosState> {
  final GetPrestamos getPrestamos;
  final AddPrestamo addPrestamo;
  final UpdatePrestamo updatePrestamo;
  final DeletePrestamo deletePrestamo;

  PrestamosCubit({
    required this.getPrestamos,
    required this.addPrestamo,
    required this.updatePrestamo,
    required this.deletePrestamo,
  }) : super(PrestamosInitial());

  Future<void> loadPrestamos(String workerId) async {
    emit(PrestamosLoading());
    final result = await getPrestamos(workerId);
    if (result is Success<List<Prestamo>>) {
      final prestamos = result.data;
      final debt = prestamos.where((element) => !element.isPaid).fold(0.0, (sum, item) => sum + item.amount);
      emit(PrestamosLoaded(prestamos, debt));
    } else if (result is Error<List<Prestamo>>) {
      emit(PrestamosError(result.failure.message));
    }
  }

  Future<void> registrarPrestamo(Prestamo prestamo) async {
    emit(PrestamosLoading());
    final result = await addPrestamo(prestamo);
    if (result is Success<Prestamo>) {
      loadPrestamos(prestamo.workerId);
    } else if (result is Error<Prestamo>) {
      emit(PrestamosError(result.failure.message));
    }
  }

  Future<void> marcarComoPagado(Prestamo prestamo) async {
    emit(PrestamosLoading());
    // Create copy with isPaid = true. Assuming immutable entity copyWith or manual.
    // Entity doesn't have copyWith in the snippet I wrote. Using constructor.
    final updated = Prestamo(
      id: prestamo.id,
      workerId: prestamo.workerId,
      farmId: prestamo.farmId,
      amount: prestamo.amount,
      date: prestamo.date,
      description: prestamo.description,
      isPaid: true,
    );
    
    final result = await updatePrestamo(updated);
    if (result is Success<Prestamo>) {
      loadPrestamos(prestamo.workerId);
    } else if (result is Error<Prestamo>) {
      emit(PrestamosError(result.failure.message));
    }
  }

  Future<void> eliminarPrestamo(String workerId, String prestamoId) async {
    emit(PrestamosLoading());
    final result = await deletePrestamo(workerId, prestamoId);
    if (result is Success<void>) {
      loadPrestamos(workerId);
    } else if (result is Error<void>) {
      emit(PrestamosError(result.failure.message));
    }
  }
}
