import 'package:equatable/equatable.dart';

/// Estados del Dashboard
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final int totalBovinos;
  final int totalCerdos;
  final int totalOvejas;
  final int totalGallinas;
  final int totalTrabajadores;
  final List<String> alertas;

  const DashboardLoaded({
    required this.totalBovinos,
    required this.totalCerdos,
    required this.totalOvejas,
    required this.totalGallinas,
    required this.totalTrabajadores,
    required this.alertas,
  });

  @override
  List<Object?> get props => [
        totalBovinos,
        totalCerdos,
        totalOvejas,
        totalGallinas,
        totalTrabajadores,
        alertas,
      ];
}

