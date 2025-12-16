import 'package:equatable/equatable.dart';

class Prestamo extends Equatable {
  final String id;
  final String workerId;
  final String farmId;
  final double amount;
  final DateTime date;
  final String description;
  final bool isPaid;

  const Prestamo({
    required this.id,
    required this.workerId,
    required this.farmId,
    required this.amount,
    required this.date,
    required this.description,
    this.isPaid = false,
  });

  @override
  List<Object?> get props => [id, workerId, farmId, amount, date, description, isPaid];
}
