import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle_trip.dart';

class TripDetailsScreen extends StatelessWidget {
  final Farm farm;
  final CattleTrip trip;

  const TripDetailsScreen({
    super.key,
    required this.farm,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final destFarm = farmProvider.farms.firstWhere(
          (f) => f.id == trip.toFarmId,
          orElse: () => Farm(
            id: trip.toFarmId ?? '',
            name: 'Finca desconocida',
            createdAt: DateTime.now(),
            primaryColor: Colors.grey,
          ),
        );

        // Buscar animales en la finca destino (donde están ahora)
        // También buscar en la finca origen por si acaso aún están allí
        final tripAnimals = [
          ...destFarm.cattle.where((c) => trip.cattleIds.contains(c.id)),
          ...updatedFarm.cattle.where((c) => trip.cattleIds.contains(c.id) && 
                                           !destFarm.cattle.any((d) => d.id == c.id)),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalles del Viaje'),
            centerTitle: true,
            backgroundColor: farm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información básica
                Container(
                  decoration: BoxDecoration(
                    color: farm.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.airport_shuttle,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        trip.isLote ? 'Viaje de Lote' : 'Transferencia Individual',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(trip.tripDate),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información general
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información General',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              _buildInfoRow('Origen', updatedFarm.name),
                              const SizedBox(height: 8),
                              _buildInfoRow('Destino', destFarm.name),
                              const SizedBox(height: 8),
                              _buildInfoRow('Motivo', trip.reasonString),
                              const SizedBox(height: 8),
                              _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy').format(trip.tripDate)),
                              const SizedBox(height: 8),
                              _buildInfoRow('Cantidad', '${trip.cattleIds.length} ${trip.isLote ? "animales" : "animal"}'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Información de transporte
                      if (trip.transporterName != null || trip.vehicleInfo != null)
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.local_shipping),
                                    SizedBox(width: 8),
                                    Text(
                                      'Información de Transporte',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                if (trip.transporterName != null) ...[
                                  _buildInfoRow('Transportista', trip.transporterName!),
                                  const SizedBox(height: 8),
                                ],
                                if (trip.vehicleInfo != null)
                                  _buildInfoRow('Vehículo', trip.vehicleInfo!),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Animales del viaje
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.pets),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Animales del Viaje (${tripAnimals.length})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              if (tripAnimals.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No se encontraron animales en el inventario',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                ...tripAnimals.map((animal) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: farm.primaryColor.withValues(alpha: 0.1),
                                        child: Icon(
                                          Icons.agriculture,
                                          color: farm.primaryColor,
                                        ),
                                      ),
                                      title: Text(animal.name ?? animal.identification ?? 'Sin ID'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${animal.categoryString} - ${animal.genderString}'),
                                          Text('${animal.currentWeight.toStringAsFixed(1)} kg'),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notas
                      if (trip.notes != null && trip.notes!.isNotEmpty)
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(trip.notes!),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Text(value),
      ],
    );
  }
}
