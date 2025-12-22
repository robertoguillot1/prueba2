import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_transfers_by_bovine.dart';
import '../../../../../features/cattle/domain/usecases/add_transfer.dart';
import '../../../../../features/cattle/domain/usecases/update_transfer.dart';
import '../../../../../features/cattle/domain/usecases/delete_transfer.dart';
import 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  final GetTransfersByBovine _getTransfers;
  final AddTransfer _addTransfer;
  final UpdateTransfer _updateTransfer;
  final DeleteTransfer _deleteTransfer;

  TransferCubit({
    required GetTransfersByBovine getTransfers,
    required AddTransfer addTransfer,
    required UpdateTransfer updateTransfer,
    required DeleteTransfer deleteTransfer,
  })  : _getTransfers = getTransfers,
        _addTransfer = addTransfer,
        _updateTransfer = updateTransfer,
        _deleteTransfer = deleteTransfer,
        super(TransferInitial());

  Future<void> loadTransfers({
    required String bovineId,
    required String farmId,
  }) async {
    emit(TransferLoading());
    final result = await _getTransfers(
      GetTransfersByBovineParams(bovineId: bovineId, farmId: farmId),
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) {
        final sortedTransfers = List<TransferEntity>.from(transfers);
        sortedTransfers.sort((a, b) => b.transferDate.compareTo(a.transferDate));
        emit(TransferLoaded(sortedTransfers));
      },
    );
  }

  Future<void> addTransfer({
    required String farmId,
    required String bovineId,
    required String fromLocation,
    required String toLocation,
    required TransferReason reason,
    required DateTime transferDate,
    String? toFarmId,
    String? notes,
    String? transporterName,
    String? vehicleInfo,
    String? mobilizationGuidePhotoUrl,
  }) async {
    final transfer = TransferEntity(
      id: '', // Firestore generará el ID
      bovineId: bovineId,
      farmId: farmId,
      toFarmId: toFarmId,
      transferDate: transferDate,
      fromLocation: fromLocation,
      toLocation: toLocation,
      reason: reason,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      transporterName: transporterName?.trim().isEmpty == true ? null : transporterName?.trim(),
      vehicleInfo: vehicleInfo?.trim().isEmpty == true ? null : vehicleInfo?.trim(),
      mobilizationGuidePhotoUrl: mobilizationGuidePhotoUrl,
      createdAt: DateTime.now(),
    );

    final result = await _addTransfer(AddTransferParams(transfer: transfer));
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (successTransfer) => emit(const TransferOperationSuccess('Transferencia registrada exitosamente')),
    );
  }

  Future<void> updateTransfer(TransferEntity transfer) async {
    final result = await _updateTransfer(UpdateTransferParams(transfer: transfer));
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (successTransfer) => emit(const TransferOperationSuccess('Transferencia actualizada exitosamente')),
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

  Future<void> refresh({required String bovineId, required String farmId}) async {
    await loadTransfers(bovineId: bovineId, farmId: farmId);
  }

  void reset() {
    emit(TransferInitial());
  }
}

