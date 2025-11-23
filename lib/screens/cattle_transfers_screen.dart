import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import 'cattle_transfer_form_screen.dart';
import 'trip_details_screen.dart';

class CattleTransfersScreen extends StatelessWidget {
  final Farm farm;

  const CattleTransfersScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        // Combinar trips y transfers para mostrar todo
        final trips = updatedFarm.cattleTrips.toList()
          ..sort((a, b) => b.tripDate.compareTo(a.tripDate));
        
        final transfers = updatedFarm.cattleTransfers.toList()
          ..sort((a, b) => b.transferDate.compareTo(a.transferDate));

        // Filtrar transfers que ya están en trips
        final uniqueTransfers = transfers.where((transfer) {
          return !trips.any((trip) => trip.cattleIds.contains(transfer.cattleId) && 
                                      trip.farmId == transfer.fromFarmId &&
                                      trip.toFarmId == transfer.toFarmId &&
                                      trip.tripDate.difference(transfer.transferDate).inDays.abs() < 1);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('🚚 Viajes y Transferencias'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: (trips.isEmpty && uniqueTransfers.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay viajes registrados',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra el movimiento de animales entre fincas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Sección de Viajes (Trips)
                    if (trips.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.airport_shuttle, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Viajes Recientes (${trips.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...trips.map((trip) {
                        final destFarm = farmProvider.farms.firstWhere(
                          (f) => f.id == trip.toFarmId,
                          orElse: () => farm,
                        );

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetailsScreen(
                                    farm: updatedFarm,
                                    trip: trip,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue.withOpacity(0.1),
                                        child: const Icon(
                                          Icons.airport_shuttle,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              trip.isLote ? 'Viaje de Lote' : 'Viaje Individual',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${trip.cattleIds.length} ${trip.isLote ? "animales" : "animal"}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${updatedFarm.name} → ${destFarm.name}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(DateFormat('dd/MM/yyyy').format(trip.tripDate)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.label, size: 16, color: Colors.purple),
                                      const SizedBox(width: 4),
                                      Text(trip.reasonString),
                                    ],
                                  ),
                                  if (trip.transporterName != null || trip.vehicleInfo != null) ...[
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    if (trip.transporterName != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 16, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Text('Transportista: ${trip.transporterName}'),
                                        ],
                                      ),
                                    if (trip.transporterName != null && trip.vehicleInfo != null)
                                      const SizedBox(height: 4),
                                    if (trip.vehicleInfo != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.directions_car, size: 16, color: Colors.indigo),
                                          const SizedBox(width: 4),
                                          Text('Vehículo: ${trip.vehicleInfo}'),
                                        ],
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],

                    // Sección de Transferencias individuales antiguas
                    if (uniqueTransfers.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.swap_horiz, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text(
                            'Transferencias Antiguas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...uniqueTransfers.take(5).map((transfer) {
                        final animal = updatedFarm.cattle
                            .where((c) => c.id == transfer.cattleId)
                            .firstOrNull;
                        
                        if (animal == null) return const SizedBox.shrink();
                        
                        final destFarm = farmProvider.farms.firstWhere(
                          (f) => f.id == transfer.toFarmId,
                          orElse: () => updatedFarm,
                        );

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: farm.primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    transfer.reason == 'venta' ? Icons.sell :
                                    transfer.reason == 'reproduccion' ? Icons.child_care :
                                    Icons.swap_horiz,
                                    color: farm.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        animal.name ?? animal.identification ?? 'Sin ID',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${transfer.reasonString} → ${destFarm.name}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(transfer.transferDate),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
          floatingActionButton: updatedFarm.cattle.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattleTransferFormScreen(farm: updatedFarm),
                      ),
                    );
                  },
                  backgroundColor: farm.primaryColor,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Viaje'),
                ),
        );
      },
    );
  }
}