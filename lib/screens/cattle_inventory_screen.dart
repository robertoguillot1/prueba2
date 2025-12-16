import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/cattle.dart';
import 'cattle_form_screen.dart';
import 'cattle_profile_screen.dart';

class CattleInventoryScreen extends StatefulWidget {
  final Farm farm;

  const CattleInventoryScreen({super.key, required this.farm});

  @override
  State<CattleInventoryScreen> createState() => _CattleInventoryScreenState();
}

class _CattleInventoryScreenState extends State<CattleInventoryScreen> {
  String _searchQuery = '';
  String? _filterCategory;


  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
        builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        // Debug: Verificar qué está pasando
        print('DEBUG build: Total fincas: ${farmProvider.farms.length}');
        print('DEBUG build: Ganado en finca: ${updatedFarm.cattle.length}');
        if (updatedFarm.cattle.isNotEmpty) {
          print('DEBUG build: Primer animal: ${updatedFarm.cattle[0].id} - ${updatedFarm.cattle[0].name ?? updatedFarm.cattle[0].identification}');
        }

        var cattle = updatedFarm.cattle;
        
        // Filtrar por búsqueda
        if (_searchQuery.isNotEmpty) {
          cattle = cattle.where((c) {
            final id = c.identification?.toLowerCase() ?? '';
            final name = c.name?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return id.contains(query) || name.contains(query);
          }).toList();
        }
        
        // Filtrar por categoría
        if (_filterCategory != null && _filterCategory!.isNotEmpty) {
          cattle = cattle.where((c) => c.categoryString == _filterCategory).toList();
        }
        
        // Debug final antes de renderizar
        print('DEBUG build: Ganado después de filtros: ${cattle.length}');
        print('DEBUG build: ListView.builder se construirá con ${cattle.length} items');

        return Scaffold(
          appBar: AppBar(
            title: const Text('🐄 Inventario de Ganado'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              // Botón para refrescar manualmente
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  final farmProvider = Provider.of<FarmProvider>(context, listen: false);
                  farmProvider.loadFarms().then((_) {
                    if (mounted) {
                      setState(() {
                        // Limpiar todos los filtros al refrescar
                        _searchQuery = '';
                        _filterCategory = null;
                      });
                    }
                  });
                },
                tooltip: 'Refrescar',
              ),
            ],
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
                        labelText: 'Buscar animal',
                        hintText: 'DNI, ID o nombre...',
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
                    // Filtros de categoría
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todos', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Toro', 'Toro'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Vaca', 'Vaca'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Ternero', 'Ternero'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Novillo', 'Novillo'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cattle.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay animales registrados',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Agrega tu primer animal',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cattle.length,
                        itemBuilder: (context, index) {
                          print('DEBUG ListView.builder: Construyendo item $index de ${cattle.length}');
                          final animal = cattle[index];
                          print('DEBUG ListView.builder: Animal ${animal.id} - ${animal.name ?? animal.identification}');
                          return _buildCattleCard(context, animal, updatedFarm);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final farmProvider = Provider.of<FarmProvider>(context, listen: false);
              Farm currentFarm;
              try {
                currentFarm = farmProvider.farms.firstWhere(
                  (f) => f.id == widget.farm.id,
                );
              } catch (e) {
                currentFarm = widget.farm;
              }
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => CattleFormScreen(
                    farm: currentFarm,
                    cattleToEdit: null,
                  ),
                ),
              );
              
              // Forzar actualización después de regresar
              if (mounted && result == true) {
                // Recargar las fincas para asegurar datos actualizados
                await farmProvider.loadFarms();
                // Esperar un momento para que el Provider se actualice
                await Future.delayed(const Duration(milliseconds: 500));
                // Forzar rebuild del widget
                if (mounted) {
                  setState(() {
                    _searchQuery = '';
                    _filterCategory = null;
                  });
                  // Forzar otro rebuild después de un momento
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (mounted) {
                    setState(() {});
                  }
                }
              }
            },
            backgroundColor: updatedFarm.primaryColor,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Animal'),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _filterCategory == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterCategory = selected ? value : null;
        });
      },
    );
  }


  Widget _buildCattleCard(BuildContext context, Cattle cattle, Farm farm) {
    print('DEBUG _buildCattleCard: Construyendo tarjeta para ${cattle.id} - ${cattle.name ?? cattle.identification}');
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CattleProfileScreen(
                farm: farm,
                cattle: cattle,
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
                        backgroundColor: cattle.gender == CattleGender.male
                            ? Colors.blue[100]
                            : Colors.pink[100],
                        child: Text(
                          cattle.name?.substring(0, 1).toUpperCase() ?? 
                          cattle.identification?.substring(0, 1).toUpperCase() ?? 
                          '🐄',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cattle.name ?? cattle.identification ?? 'Sin nombre',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            cattle.categoryString,
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
                      color: _getStageColor(cattle.productionStage).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cattle.productionStageString,
                      style: TextStyle(
                        color: _getStageColor(cattle.productionStage),
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
                    '${cattle.currentWeight.toStringAsFixed(0)} kg',
                    'Peso',
                    farm.primaryColor,
                  ),
                  _buildInfoItem(
                    context,
                    cattle.gender == CattleGender.male ? Icons.male : Icons.female,
                    cattle.genderString,
                    'Género',
                    farm.primaryColor,
                  ),
                  _buildInfoItem(
                    context,
                    Icons.health_and_safety,
                    cattle.healthStatusString,
                    'Estado',
                    farm.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label, Color? color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color ?? Theme.of(context).primaryColor),
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

  Color _getStageColor(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.levante:
        return Colors.green;
      case ProductionStage.desarrollo:
        return Colors.orange;
      case ProductionStage.produccion:
        return Colors.blue;
      case ProductionStage.descarte:
        return Colors.purple;
    }
  }

  Farm get farm => widget.farm;
}
