import 'package:equatable/equatable.dart';

class Pago extends Equatable {
  final String id;
  final String workerId;
  final String farmId;
  final double amount;
  final DateTime date;
  final String concept; // e.g., "Salario", "Bono", "Liquidación"
  final String? notes;

  const Pago({
    required this.id,
    required this.workerId,
    required this.farmId,
    required this.amount,
    required this.date,
    required this.concept,
    this.notes,
  });

  @override
  List<Object?> get props => [id, workerId, farmId, amount, date, concept, notes];
}
