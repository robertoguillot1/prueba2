import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_transfers_by_farm.dart';
import '../../../../../features/cattle/domain/usecases/delete_transfer.dart';
import '../../details/cubits/transfer_state.dart';

class FarmTransfersCubit extends Cubit<TransferState> {
  final GetTransfersByFarm _getTransfers;
  final DeleteTransfer _deleteTransfer;

  FarmTransfersCubit({
    required GetTransfersByFarm getTransfers,
    required DeleteTransfer deleteTransfer,
  })  : _getTransfers = getTransfers,
        _deleteTransfer = deleteTransfer,
        super(TransferInitial());

  Future<void> loadTransfers({required String farmId}) async {
    emit(TransferLoading());
    final result = await _getTransfers(GetTransfersByFarmParams(farmId: farmId));
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) {
        final sortedTransfers = List<TransferEntity>.from(transfers);
        sortedTransfers.sort((a, b) => b.transferDate.compareTo(a.transferDate));
        emit(TransferLoaded(sortedTransfers));
      },
    );
  }

  Future<void> deleteTransfer({
    required String id,
    required String bovineId,
    required String farmId,
  }) async {
    final result = await _deleteTransfer(
      DeleteTransferParams(id: id, bovineId: bovineId, farmId: farmId),
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (_) => emit(const TransferOperationSuccess('Transferencia eliminada exitosamente')),
    );
  }

  Future<void> refresh({required String farmId}) async {
    await loadTransfers(farmId: farmId);
  }
}

