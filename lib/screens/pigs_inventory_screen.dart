import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/pig.dart';
import 'pig_form_screen.dart';
import 'pig_profile_screen.dart';

class PigsInventoryScreen extends StatefulWidget {
  final Farm farm;

  const PigsInventoryScreen({super.key, required this.farm});

  @override
  State<PigsInventoryScreen> createState() => _PigsInventoryScreenState();
}

class _PigsInventoryScreenState extends State<PigsInventoryScreen> {
  String _searchQuery = '';
  String? _filterStage;

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        var pigs = updatedFarm.pigs;
        
        // Filtrar por búsqueda
        if (_searchQuery.isNotEmpty) {
          pigs = pigs.where((pig) {
            final id = pig.identification?.toLowerCase() ?? '';
            final gender = pig.genderString.toLowerCase();
            final stage = pig.feedingStageString.toLowerCase();
            final query = _searchQuery.toLowerCase();
            
            return id.contains(query) ||
                   gender.contains(query) ||
                   stage.contains(query);
          }).toList();
        }
        
        // Filtrar por etapa
        if (_filterStage != null && _filterStage!.isNotEmpty) {
          pigs = pigs.where((pig) => pig.feedingStageString == _filterStage).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('🐷 Inventario de Cerdos'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // Barra de búsqueda y filtros
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar cerdo',
                        hintText: 'Nombre, ID, género, etapa...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todas', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Inicio', 'Inicio'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Levante', 'Levante'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Engorde', 'Engorde'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: pigs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay cerdos registrados',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pigs.length,
                        itemBuilder: (context, index) {
                          final pig = pigs[index];
                          return _buildPigCard(context, pig, updatedFarm);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PigFormScreen(
                    farm: updatedFarm,
                    pigToEdit: null,
                  ),
                ),
              );
            },
            backgroundColor: updatedFarm.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Cerdo'),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _filterStage == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStage = selected ? value : null;
        });
      },
    );
  }

  Widget _buildPigCard(BuildContext context, Pig pig, Farm farm) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PigProfileScreen(
                farm: farm,
                pig: pig,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: pig.gender == PigGender.male
                            ? Colors.blue[100]
                            : Colors.pink[100],
                        child: Text(
                          pig.identification?.substring(0, 1).toUpperCase() ?? '🐷',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pig.identification ?? 'Sin ID',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            pig.genderString,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStageColor(pig.feedingStage).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pig.feedingStageString,
                      style: TextStyle(
                        color: _getStageColor(pig.feedingStage),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    context,
                    Icons.monitor_weight,
                    '${pig.currentWeight.toStringAsFixed(1)} kg',
                    'Peso actual',
                  ),
                  _buildInfoItem(
                    context,
                    Icons.restaurant,
                    '${pig.estimatedDailyConsumption.toStringAsFixed(2)} kg/día',
                    'Consumo diario',
                  ),
                  _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    '${pig.ageInDays} días',
                    'Edad',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: farm.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Color _getStageColor(FeedingStage stage) {
    switch (stage) {
      case FeedingStage.inicio:
        return Colors.green;
      case FeedingStage.levante:
        return Colors.orange;
      case FeedingStage.engorde:
        return Colors.red;
    }
  }

  Farm get farm => widget.farm;
}

