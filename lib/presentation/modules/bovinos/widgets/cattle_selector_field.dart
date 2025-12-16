import 'package:flutter/material.dart';
import '../../../../domain/entities/bovinos/bovino.dart';

/// Filtro de género para el selector
enum SexFilter {
  male,   // Solo machos
  female, // Solo hembras
  any,    // Cualquiera
}

/// Widget selector inteligente de bovinos con modal y búsqueda
class CattleSelectorField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final Bovino? selectedBovino;
  final List<Bovino> availableBovinos;
  final SexFilter sexFilter;
  final String? excludeBovinoId; // ID del bovino a excluir (para evitar ciclos)
  final Function(Bovino?) onSelect;
  final Color? primaryColor;

  const CattleSelectorField({
    super.key,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.selectedBovino,
    required this.availableBovinos,
    this.sexFilter = SexFilter.any,
    this.excludeBovinoId,
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
          suffixIcon: selectedBovino != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => onSelect(null),
                  tooltip: 'Limpiar selección',
                )
              : const Icon(Icons.arrow_drop_down),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: selectedBovino != null
              ? Colors.green.shade50
              : Colors.white,
        ),
        child: selectedBovino != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedBovino!.name ?? 
                    selectedBovino!.identification ?? 
                    'Sin ID',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (selectedBovino!.identification != null)
                    Text(
                      'ID: ${selectedBovino!.identification}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (selectedBovino!.raza != null && selectedBovino!.raza!.isNotEmpty)
                    Text(
                      'Raza: ${selectedBovino!.raza}',
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
      builder: (context) => _CattleSelectorModal(
        title: label,
        availableBovinos: availableBovinos,
        selectedBovinoId: selectedBovino?.id,
        sexFilter: sexFilter,
        excludeBovinoId: excludeBovinoId,
        primaryColor: primaryColor,
        onSelect: (bovino) {
          onSelect(bovino);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CattleSelectorModal extends StatefulWidget {
  final String title;
  final List<Bovino> availableBovinos;
  final String? selectedBovinoId;
  final SexFilter sexFilter;
  final String? excludeBovinoId;
  final Color? primaryColor;
  final Function(Bovino?) onSelect;

  const _CattleSelectorModal({
    required this.title,
    required this.availableBovinos,
    this.selectedBovinoId,
    required this.sexFilter,
    this.excludeBovinoId,
    this.primaryColor,
    required this.onSelect,
  });

  @override
  State<_CattleSelectorModal> createState() => _CattleSelectorModalState();
}

class _CattleSelectorModalState extends State<_CattleSelectorModal> {
  late TextEditingController _searchController;
  List<Bovino> _filteredBovinos = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterBovinos();
    _searchController.addListener(_filterBovinos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBovinos() {
    setState(() {
      final searchTerm = _searchController.text.toLowerCase();
      
      _filteredBovinos = widget.availableBovinos.where((bovino) {
        // Filtrar por género si se requiere
        if (widget.sexFilter == SexFilter.male && 
            bovino.gender != BovinoGender.male) {
          return false;
        }
        if (widget.sexFilter == SexFilter.female && 
            bovino.gender != BovinoGender.female) {
          return false;
        }
        
        // Excluir el bovino actual si se especifica
        if (widget.excludeBovinoId != null && 
            bovino.id == widget.excludeBovinoId) {
          return false;
        }
        
        // Filtrar por búsqueda
        if (searchTerm.isNotEmpty) {
          final name = (bovino.name ?? '').toLowerCase();
          final identification = (bovino.identification ?? '').toLowerCase();
          final raza = (bovino.raza ?? '').toLowerCase();
          if (!name.contains(searchTerm) && 
              !identification.contains(searchTerm) &&
              !raza.contains(searchTerm)) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Ordenar por nombre o identificación
      _filteredBovinos.sort((a, b) {
        final aName = a.name ?? a.identification ?? '';
        final bName = b.name ?? b.identification ?? '';
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
            child: _filteredBovinos.isEmpty
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
                    itemCount: _filteredBovinos.length + 1, // +1 para "Sin seleccionar"
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
                          selected: widget.selectedBovinoId == null,
                          selectedTileColor: color.withValues(alpha: 0.1),
                        );
                      }
                      
                      final bovino = _filteredBovinos[index - 1];
                      final isSelected = widget.selectedBovinoId == bovino.id;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? color.withValues(alpha: 0.2)
                              : Colors.grey.shade200,
                          child: Icon(
                            bovino.gender == BovinoGender.male
                                ? Icons.male
                                : Icons.female,
                            color: isSelected
                                ? color
                                : Colors.grey.shade600,
                          ),
                        ),
                        title: Text(
                          bovino.name ?? 'Sin nombre',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bovino.identification != null)
                              Text(
                                'ID: ${bovino.identification}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (bovino.raza != null && bovino.raza!.isNotEmpty)
                              Text(
                                'Raza: ${bovino.raza}',
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
                        onTap: () => widget.onSelect(bovino),
                        selected: isSelected,
                        selectedTileColor: color.withValues(alpha: 0.1),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

