import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transfer_entity.dart';

class TransferModel extends TransferEntity {
  const TransferModel({
    required String id,
    required String bovineId,
    required String farmId,
    String? toFarmId,
    required DateTime transferDate,
    required String fromLocation,
    required String toLocation,
    required TransferReason reason,
    String? notes,
    String? transporterName,
    String? vehicleInfo,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          bovineId: bovineId,
          farmId: farmId,
          toFarmId: toFarmId,
          transferDate: transferDate,
          fromLocation: fromLocation,
          toLocation: toLocation,
          reason: reason,
          notes: notes,
          transporterName: transporterName,
          vehicleInfo: vehicleInfo,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as String? ?? '',
      bovineId: json['bovineId'] as String,
      farmId: json['farmId'] as String,
      toFarmId: json['toFarmId'] as String?,
      transferDate: (json['transferDate'] as Timestamp).toDate(),
      fromLocation: json['fromLocation'] as String,
      toLocation: json['toLocation'] as String,
      reason: _parseReason(json['reason'] as String? ?? 'otro'),
      notes: json['notes'] as String?,
      transporterName: json['transporterName'] as String?,
      vehicleInfo: json['vehicleInfo'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bovineId': bovineId,
      'farmId': farmId,
      'toFarmId': toFarmId,
      'transferDate': Timestamp.fromDate(transferDate),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'reason': _reasonToString(reason),
      'notes': notes,
      'transporterName': transporterName,
      'vehicleInfo': vehicleInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory TransferModel.fromEntity(TransferEntity entity) {
    return TransferModel(
      id: entity.id,
      bovineId: entity.bovineId,
      farmId: entity.farmId,
      toFarmId: entity.toFarmId,
      transferDate: entity.transferDate,
      fromLocation: entity.fromLocation,
      toLocation: entity.toLocation,
      reason: entity.reason,
      notes: entity.notes,
      transporterName: entity.transporterName,
      vehicleInfo: entity.vehicleInfo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TransferModel copyWith({
    String? id,
    String? bovineId,
    String? farmId,
    String? toFarmId,
    DateTime? transferDate,
    String? fromLocation,
    String? toLocation,
    TransferReason? reason,
    String? notes,
    String? transporterName,
    String? vehicleInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransferModel(
      id: id ?? this.id,
      bovineId: bovineId ?? this.bovineId,
      farmId: farmId ?? this.farmId,
      toFarmId: toFarmId ?? this.toFarmId,
      transferDate: transferDate ?? this.transferDate,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      transporterName: transporterName ?? this.transporterName,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static TransferReason _parseReason(String reason) {
    switch (reason) {
      case 'venta':
        return TransferReason.venta;
      case 'prestamo':
        return TransferReason.prestamo;
      case 'reproduccion':
        return TransferReason.reproduccion;
      case 'tratamiento':
        return TransferReason.tratamiento;
      default:
        return TransferReason.otro;
    }
  }

  static String _reasonToString(TransferReason reason) {
    switch (reason) {
      case TransferReason.venta:
        return 'venta';
      case TransferReason.prestamo:
        return 'prestamo';
      case TransferReason.reproduccion:
        return 'reproduccion';
      case TransferReason.tratamiento:
        return 'tratamiento';
      case TransferReason.otro:
        return 'otro';
    }
  }
}

