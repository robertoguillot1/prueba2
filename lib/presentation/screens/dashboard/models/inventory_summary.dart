/// Modelo para el resumen de inventario
class InventorySummary {
  final int totalBovinos;
  final int vacasEnOrdeno;
  final int totalCerdos;
  final int totalAves;
  final int totalOvinos;
  final int trabajadoresActivos;

  const InventorySummary({
    required this.totalBovinos,
    required this.vacasEnOrdeno,
    required this.totalCerdos,
    required this.totalAves,
    required this.totalOvinos,
    required this.trabajadoresActivos,
  });
}

