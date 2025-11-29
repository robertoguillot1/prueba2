import 'package:equatable/equatable.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {}

class TransferLoading extends TransferState {}

class TransferLoaded extends TransferState {
  final List<TransferEntity> transfers;

  const TransferLoaded(this.transfers);

  @override
  List<Object?> get props => [transfers];
}

class TransferError extends TransferState {
  final String message;

  const TransferError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransferOperationSuccess extends TransferState {
  final String message;

  const TransferOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

