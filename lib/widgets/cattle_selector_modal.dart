import 'package:flutter/material.dart';
import '../models/cattle.dart';
import '../models/farm.dart';

class CattleSelectorModal extends StatelessWidget {
  final Farm farm;
  final List<Cattle> availableCattle;
  final String title;
  final String? selectedCattleId;
  final Function(Cattle?) onSelect;
  final CattleGender? requiredGender; // Filtro por género
  final Cattle? excludeCattle; // Animal a excluir (para evitar ciclos)

  const CattleSelectorModal({
    super.key,
    required this.farm,
    required this.availableCattle,
    required this.title,
    this.selectedCattleId,
    required this.onSelect,
    this.requiredGender,
    this.excludeCattle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: _CattleSelectorList(
        farm: farm,
        availableCattle: availableCattle,
        selectedCattleId: selectedCattleId,
        onSelect: (cattle) {
          onSelect(cattle);
          Navigator.pop(context);
        },
        requiredGender: requiredGender,
        excludeCattle: excludeCattle,
        title: title,
      ),
    );
  }
}

class _CattleSelectorList extends StatefulWidget {
  final Farm farm;
  final List<Cattle> availableCattle;
  final String? selectedCattleId;
  final Function(Cattle?) onSelect;
  final CattleGender? requiredGender;
  final Cattle? excludeCattle;
  final String title;

  const _CattleSelectorList({
    required this.farm,
    required this.availableCattle,
    this.selectedCattleId,
    required this.onSelect,
    this.requiredGender,
    this.excludeCattle,
    required this.title,
  });

  @override
  State<_CattleSelectorList> createState() => _CattleSelectorListState();
}

class _CattleSelectorListState extends State<_CattleSelectorList> {
  late TextEditingController _searchController;
  List<Cattle> _filteredCattle = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filterCattle();
    _searchController.addListener(_filterCattle);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCattle() {
    setState(() {
      final searchTerm = _searchController.text.toLowerCase();
      
      _filteredCattle = widget.availableCattle.where((cattle) {
        // Filtrar por género si se requiere
        if (widget.requiredGender != null && cattle.gender != widget.requiredGender) {
          return false;
        }
        
        // Excluir el animal actual si se especifica
        if (widget.excludeCattle != null && cattle.id == widget.excludeCattle!.id) {
          return false;
        }
        
        // Filtrar por búsqueda
        if (searchTerm.isNotEmpty) {
          final name = (cattle.name ?? '').toLowerCase();
          final identification = (cattle.identification ?? '').toLowerCase();
          if (!name.contains(searchTerm) && !identification.contains(searchTerm)) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Ordenar por nombre o identificación
      _filteredCattle.sort((a, b) {
        final aName = a.name ?? a.identification ?? '';
        final bName = b.name ?? b.identification ?? '';
        return aName.compareTo(bName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            hintText: 'Buscar por nombre o chapeta...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 16),
        // Lista de animales
        Expanded(
          child: _filteredCattle.isEmpty
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
                        'No se encontraron animales',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.requiredGender == CattleGender.male
                            ? 'No hay machos disponibles'
                            : widget.requiredGender == CattleGender.female
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
                  itemCount: _filteredCattle.length + 1, // +1 para la opción "Sin seleccionar"
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
                        selected: widget.selectedCattleId == null,
                        selectedTileColor: Colors.blue.shade50,
                      );
                    }
                    
                    final cattle = _filteredCattle[index - 1];
                    final isSelected = widget.selectedCattleId == cattle.id;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? widget.farm.primaryColor.withValues(alpha: 0.2)
                            : Colors.grey.shade200,
                        child: Icon(
                          cattle.gender == CattleGender.male
                              ? Icons.male
                              : Icons.female,
                          color: isSelected
                              ? widget.farm.primaryColor
                              : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(
                        cattle.name ?? 'Sin nombre',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cattle.identification != null)
                            Text(
                              'Chapeta: ${cattle.identification}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (cattle.raza != null && cattle.raza!.isNotEmpty)
                            Text(
                              'Raza: ${cattle.raza}',
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
                              color: widget.farm.primaryColor,
                            )
                          : null,
                      onTap: () => widget.onSelect(cattle),
                      selected: isSelected,
                      selectedTileColor: widget.farm.primaryColor.withValues(alpha: 0.1),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
