import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/result.dart';
import '../../../../features/trabajadores/domain/entities/pago.dart';
import '../../../../features/trabajadores/domain/usecases/get_pagos.dart';
import '../../../../features/trabajadores/domain/usecases/add_pago.dart';
import '../../../../features/trabajadores/domain/usecases/update_pago.dart';
import '../../../../features/trabajadores/domain/usecases/delete_pago.dart';

abstract class PagosState extends Equatable {
  const PagosState();
  @override
  List<Object?> get props => [];
}

class PagosInitial extends PagosState {}
class PagosLoading extends PagosState {}
class PagosLoaded extends PagosState {
  final List<Pago> pagos;
  const PagosLoaded(this.pagos);
  @override
  List<Object?> get props => [pagos];
}
class PagosError extends PagosState {
  final String message;
  const PagosError(this.message);
  @override
  List<Object?> get props => [message];
}

class PagosCubit extends Cubit<PagosState> {
  final GetPagos getPagos;
  final AddPago addPago;
  final UpdatePago updatePago;
  final DeletePago deletePago;

  PagosCubit({
    required this.getPagos,
    required this.addPago,
    required this.updatePago,
    required this.deletePago,
  }) : super(PagosInitial());

  Future<void> loadPagos(String workerId) async {
    emit(PagosLoading());
    final result = await getPagos(workerId);
    if (result is Success<List<Pago>>) {
      emit(PagosLoaded(result.data));
    } else if (result is Error<List<Pago>>) {
      emit(PagosError(result.failure.message));
    }
  }

  Future<void> registrarPago(Pago pago) async {
    // Optimistic or refresh. Let's refresh.
    emit(PagosLoading());
    final result = await addPago(pago);
    if (result is Success<Pago>) {
      loadPagos(pago.workerId);
    } else if (result is Error<Pago>) {
      emit(PagosError(result.failure.message));
    }
  }

  Future<void> actualizarPago(Pago pago) async {
    emit(PagosLoading());
    final result = await updatePago(pago);
    if (result is Success<Pago>) {
      loadPagos(pago.workerId);
    } else if (result is Error<Pago>) {
      emit(PagosError(result.failure.message));
    }
  }

  Future<void> eliminarPago(String workerId, String pagoId) async {
    emit(PagosLoading());
    final result = await deletePago(workerId, pagoId);
    if (result is Success<void>) {
      loadPagos(workerId);
    } else if (result is Error<void>) {
      emit(PagosError(result.failure.message));
    }
  }
}
