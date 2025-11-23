abstract class PoultryBatch {
  final String id;
  final String farmId;
  final String nombreLote;
  final DateTime fechaIngreso;
  final DateTime createdAt;
  final DateTime updatedAt;

  PoultryBatch({
    required this.id,
    required this.farmId,
    required this.nombreLote,
    required this.fechaIngreso,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson();
}

