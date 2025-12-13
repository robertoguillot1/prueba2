import 'package:flutter/material.dart';
import '../../../../features/cattle/domain/entities/bovine_entity.dart';

/// Filtro de género para el selector
enum SexFilter {
  male,   // Solo machos
  female, // Solo hembras
  any,    // Cualquiera
}

/// Widget selector inteligente de bovinos con modal y búsqueda
/// Versión para el nuevo sistema (BovineEntity)
class BovineSelectorField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final BovineEntity? selectedBovine;
  final List<BovineEntity> availableBovines;
  final SexFilter sexFilter;
  final String? excludeBovineId; // ID del bovino a excluir (para evitar ciclos)
  final Function(BovineEntity?) onSelect;
  final Color? primaryColor;

  const BovineSelectorField({
    super.key,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.selectedBovine,
    required this.availableBovines,
    this.sexFilter = SexFilter.any,
    this.excludeBovineId,
    required this.onSelect,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.primaryColor;

    return InkWell(
      onTap: () => _showSelectorModal(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? 'Toca para seleccionar',
          prefixIcon: Icon(prefixIcon, color: color),
          suffixIcon: selectedBovine != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => onSelect(null),
                  tooltip: 'Limpiar selección',
                )
              : const Icon(Icons.arrow_drop_down),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: selectedBovine != null
              ? Colors.green.shade50
              : Colors.white,
        ),
        child: selectedBovine != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedBovine!.name ?? 
                    selectedBovine!.identifier ?? 
                    'Sin ID',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (selectedBovine!.identifier.isNotEmpty)
                    Text(
                      'ID: ${selectedBovine!.identifier}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (selectedBovine!.breed.isNotEmpty)
                    Text(
                      'Raza: ${selectedBovine!.breed}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              )
            : Text(
                hint ?? 'Toca para seleccionar',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
      ),
    );
  }

  void _showSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BovineSelectorModal(
        title: label,
        availableBovines: availableBovines,
        selectedBovineId: selectedBovine?.id,
        sexFilter: sexFilter,
        excludeBovineId: excludeBovineId,
        primaryColor: primaryColor,
        onSelect: (bovine) {
          onSelect(bovine);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _BovineSelectorModal extends StatefulWidget {
  final String title;
  final List<BovineEntity> availableBovines;
  final String? selectedBovineId;
  final SexFilter sexFilter;
  final String? excludeBovineId;
  final Color? primaryColor;
  final Function(BovineEntity?) onSelect;

  const _BovineSelectorModal({
    required this.title,
    required this.availableBovines,
    this.selectedBovineId,
    required this.sexFilter,
    this.excludeBovineId,
    this.primaryColor,
    required this.onSelect,
  });

  @override
  State<_BovineSelectorModal> createState() => _BovineSelectorModalState();
}

class _BovineSelectorModalState extends State<_BovineSelectorModal> {
  late TextEditingController _searchController;
  List<BovineEntity> _filteredBovines = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterBovines();
    _searchController.addListener(_filterBovines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBovines() {
    setState(() {
      final searchTerm = _searchController.text.toLowerCase();
      
      _filteredBovines = widget.availableBovines.where((bovine) {
        // Filtrar por género si se requiere
        if (widget.sexFilter == SexFilter.male && 
            bovine.gender != BovineGender.male) {
          return false;
        }
        if (widget.sexFilter == SexFilter.female && 
            bovine.gender != BovineGender.female) {
          return false;
        }
        
        // Excluir el bovino actual si se especifica
        if (widget.excludeBovineId != null && 
            bovine.id == widget.excludeBovineId) {
          return false;
        }
        
        // Filtrar por búsqueda
        if (searchTerm.isNotEmpty) {
          final name = (bovine.name ?? '').toLowerCase();
          final identifier = bovine.identifier.toLowerCase();
          final breed = bovine.breed.toLowerCase();
          if (!name.contains(searchTerm) && 
              !identifier.contains(searchTerm) &&
              !breed.contains(searchTerm)) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Ordenar por nombre o identificador
      _filteredBovines.sort((a, b) {
        final aName = a.name ?? a.identifier;
        final bName = b.name ?? b.identifier;
        return aName.compareTo(bName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.primaryColor ?? theme.primaryColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Título y botón cerrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, ID o raza...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 16),
          // Lista de bovinos
          Expanded(
            child: _filteredBovines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron bovinos',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.sexFilter == SexFilter.male
                              ? 'No hay machos disponibles'
                              : widget.sexFilter == SexFilter.female
                                  ? 'No hay hembras disponibles'
                                  : 'Intenta con otro término de búsqueda',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBovines.length + 1, // +1 para "Sin seleccionar"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Opción para no seleccionar
                        return ListTile(
                          leading: const Icon(Icons.cancel_outlined, color: Colors.grey),
                          title: const Text(
                            'Sin seleccionar',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: const Text('Dejar como desconocido'),
                          onTap: () => widget.onSelect(null),
                          selected: widget.selectedBovineId == null,
                          selectedTileColor: color.withOpacity(0.1),
                        );
                      }
                      
                      final bovine = _filteredBovines[index - 1];
                      final isSelected = widget.selectedBovineId == bovine.id;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? color.withOpacity(0.2)
                              : Colors.grey.shade200,
                          child: Icon(
                            bovine.gender == BovineGender.male
                                ? Icons.male
                                : Icons.female,
                            color: isSelected
                                ? color
                                : Colors.grey.shade600,
                          ),
                        ),
                        title: Text(
                          bovine.name ?? 'Sin nombre',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bovine.identifier.isNotEmpty)
                              Text(
                                'ID: ${bovine.identifier}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (bovine.breed.isNotEmpty)
                              Text(
                                'Raza: ${bovine.breed}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: color,
                              )
                            : null,
                        onTap: () => widget.onSelect(bovine),
                        selected: isSelected,
                        selectedTileColor: color.withOpacity(0.1),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



