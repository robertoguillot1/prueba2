import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/goat_sheep.dart';
import 'goat_sheep_form_screen.dart';
import 'goat_sheep_profile_screen.dart';
import 'goat_sheep_vaccines_screen.dart';

class GoatSheepInventoryScreen extends StatefulWidget {
  final Farm farm;

  const GoatSheepInventoryScreen({super.key, required this.farm});

  @override
  State<GoatSheepInventoryScreen> createState() => _GoatSheepInventoryScreenState();
}

class _GoatSheepInventoryScreenState extends State<GoatSheepInventoryScreen> {
  String _searchQuery = '';
  String? _filterType;
  String? _filterEstado;

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == widget.farm.id,
          orElse: () => widget.farm,
        );

        var animals = updatedFarm.goatSheep;
        
        // Filtrar por búsqueda
        if (_searchQuery.isNotEmpty) {
          animals = animals.where((a) {
            final id = a.identification?.toLowerCase() ?? '';
            final name = a.name?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return id.contains(query) || name.contains(query);
          }).toList();
        }
        
        // Filtrar por tipo
        if (_filterType != null && _filterType!.isNotEmpty) {
          animals = animals.where((a) => a.typeString == _filterType).toList();
        }
        
        // Filtrar por estado reproductivo
        if (_filterEstado != null && _filterEstado!.isNotEmpty) {
          animals = animals.where((a) => a.estadoReproductivoString == _filterEstado).toList();
        }

        // Contar animales cerca del parto
        final nearPartoCount = animals.where((a) => a.isNearParto).length;
        final pastPartoCount = animals.where((a) => a.isPastParto).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('🐑 Control Chivos/Ovejas'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.medical_services),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoatSheepVaccinesScreen(farm: updatedFarm),
                    ),
                  );
                },
                tooltip: 'Control de Vacunas',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  farmProvider.loadFarms().then((_) {
                    if (mounted) {
                      setState(() {
                        _searchQuery = '';
                        _filterType = null;
                        _filterEstado = null;
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
              // Alertas de animales cerca del parto
              if (nearPartoCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$nearPartoCount animal${nearPartoCount > 1 ? 'es' : ''} cerca del parto (≤ 10 días)',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (pastPartoCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$pastPartoCount animal${pastPartoCount > 1 ? 'es' : ''} pasaron la fecha probable de parto',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Barra de búsqueda y filtros
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar animal',
                        hintText: 'ID o nombre...',
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
                    // Filtros
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todos', null, null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Chivo', 'Chivo', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Oveja', 'Oveja', null),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Todos Estados', null, null, isEstado: true),
                          const SizedBox(width: 8),
                          _buildFilterChip('Gestante', null, 'Gestante', isEstado: true),
                          const SizedBox(width: 8),
                          _buildFilterChip('Lactante', null, 'Lactante', isEstado: true),
                          const SizedBox(width: 8),
                          _buildFilterChip('Vacía', null, 'Vacía', isEstado: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: animals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 64, color: Colors.grey[400]),
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
                        itemCount: animals.length,
                        itemBuilder: (context, index) {
                          final animal = animals[index];
                          return _buildGoatSheepCard(context, animal, updatedFarm);
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
                  builder: (context) => GoatSheepFormScreen(
                    farm: currentFarm,
                    animalToEdit: null,
                  ),
                ),
              );
              
              if (mounted && result == true) {
                await farmProvider.loadFarms();
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  setState(() {
                    _searchQuery = '';
                    _filterType = null;
                    _filterEstado = null;
                  });
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

  Widget _buildFilterChip(String label, String? typeValue, String? estadoValue, {bool isEstado = false}) {
    final isSelected = isEstado 
        ? _filterEstado == estadoValue
        : _filterType == typeValue;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isEstado) {
            _filterEstado = selected ? estadoValue : null;
          } else {
            _filterType = selected ? typeValue : null;
          }
        });
      },
    );
  }

  Widget _buildGoatSheepCard(BuildContext context, GoatSheep animal, Farm farm) {
    final isGestante = animal.estadoReproductivo == EstadoReproductivo.gestante;
    final isNearParto = animal.isNearParto;
    final isPastParto = animal.isPastParto;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isNearParto
            ? BorderSide(color: Colors.orange, width: 2)
            : isPastParto
                ? BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoatSheepProfileScreen(
                farm: farm,
                animal: animal,
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
                        backgroundColor: animal.gender == GoatSheepGender.male
                            ? Colors.blue[100]
                            : Colors.pink[100],
                        child: Text(
                          animal.name?.substring(0, 1).toUpperCase() ?? 
                          animal.identification?.substring(0, 1).toUpperCase() ?? 
                          (animal.type == GoatSheepType.oveja ? '🐑' : '🐐'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animal.name ?? animal.identification ?? 'Sin nombre',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            animal.typeString,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isGestante)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isNearParto
                            ? Colors.orange.withValues(alpha: 0.2)
                            : isPastParto
                                ? Colors.red.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNearParto
                                ? Icons.warning
                                : isPastParto
                                    ? Icons.error
                                    : Icons.pregnant_woman,
                            size: 16,
                            color: isNearParto
                                ? Colors.orange[700]
                                : isPastParto
                                    ? Colors.red[700]
                                    : Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            animal.estadoReproductivoString,
                            style: TextStyle(
                              color: isNearParto
                                  ? Colors.orange[700]
                                  : isPastParto
                                      ? Colors.red[700]
                                      : Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                    animal.gender == GoatSheepGender.male ? Icons.male : Icons.female,
                    animal.genderString,
                    'Género',
                    farm.primaryColor,
                  ),
                  if (animal.currentWeight != null)
                    _buildInfoItem(
                      context,
                      Icons.monitor_weight,
                      '${animal.currentWeight!.toStringAsFixed(0)} kg',
                      'Peso',
                      farm.primaryColor,
                    ),
                  if (animal.estadoReproductivo != null)
                    _buildInfoItem(
                      context,
                      Icons.favorite,
                      animal.estadoReproductivoString,
                      'Estado',
                      farm.primaryColor,
                    ),
                  if (animal.fechaProbableParto != null && animal.diasRestantesParto != null)
                    _buildInfoItem(
                      context,
                      Icons.calendar_today,
                      animal.diasRestantesParto! >= 0
                          ? '${animal.diasRestantesParto} días'
                          : 'Pasado',
                      'Parto',
                      animal.diasRestantesParto! >= 0 && animal.diasRestantesParto! <= 10
                          ? Colors.orange
                          : animal.diasRestantesParto! < 0
                              ? Colors.red
                              : farm.primaryColor,
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
}

