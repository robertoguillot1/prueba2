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
}

class CattleTransfer {
  final String id;
  final String cattleId;
  final String farmId;
  final String? toFarmId;
  final DateTime transferDate;
  final String fromLocation;
  final String toLocation;
  final String? reason;
  final String? notes;

  CattleTransfer({
    required this.id,
    required this.cattleId,
    required this.farmId,
    this.toFarmId,
    required this.transferDate,
    required this.fromLocation,
    required this.toLocation,
    this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cattleId': cattleId,
      'farmId': farmId,
      'toFarmId': toFarmId,
      'transferDate': transferDate.toIso8601String(),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'reason': reason,
      'notes': notes,
    };
  }

  factory CattleTransfer.fromJson(Map<String, dynamic> json) {
    return CattleTransfer(
      id: json['id'] as String,
      cattleId: json['cattleId'] as String,
      farmId: json['farmId'] as String,
      toFarmId: json['toFarmId'] as String?,
      transferDate: DateTime.parse(json['transferDate'] as String),
      fromLocation: json['fromLocation'] as String,
      toLocation: json['toLocation'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );
  }

  String get reasonString => reason ?? 'N/A';
  
  // Getter para compatibilidad
  String get fromFarmId => farmId;
}




