import 'package:equatable/equatable.dart';

enum TransferReason {
  venta,
  prestamo,
  reproduccion,
  tratamiento,
  otro,
}

extension TransferReasonExtension on TransferReason {
  String get displayName {
    switch (this) {
      case TransferReason.venta:
        return 'Venta';
      case TransferReason.prestamo:
        return 'Préstamo';
      case TransferReason.reproduccion:
        return 'Reproducción';
      case TransferReason.tratamiento:
        return 'Tratamiento';
      case TransferReason.otro:
        return 'Otro';
    }
  }

  String get iconName {
    switch (this) {
      case TransferReason.venta:
        return 'attach_money';
      case TransferReason.prestamo:
        return 'swap_horiz';
      case TransferReason.reproduccion:
        return 'child_care';
      case TransferReason.tratamiento:
        return 'medical_services';
      case TransferReason.otro:
        return 'more_horiz';
    }
  }
}

class TransferEntity extends Equatable {
  final String id;
  final String bovineId;
  final String farmId;
  final String? toFarmId;
  final DateTime transferDate;
  final String fromLocation;
  final String toLocation;
  final TransferReason reason;
  final String? notes;
  final String? transporterName;
  final String? vehicleInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TransferEntity({
    required this.id,
    required this.bovineId,
    required this.farmId,
    this.toFarmId,
    required this.transferDate,
    required this.fromLocation,
    required this.toLocation,
    required this.reason,
    this.notes,
    this.transporterName,
    this.vehicleInfo,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isValid {
    return bovineId.isNotEmpty &&
        farmId.isNotEmpty &&
        fromLocation.trim().isNotEmpty &&
        toLocation.trim().isNotEmpty &&
        transferDate.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [
        id,
        bovineId,
        farmId,
        toFarmId,
        transferDate,
        fromLocation,
        toLocation,
        reason,
        notes,
        transporterName,
        vehicleInfo,
        createdAt,
        updatedAt,
      ];
}

