import 'package:flutter/material.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';

/// Pantalla para seleccionar múltiples bovinos para transferencia de lote
class BatchTransferSelectorScreen extends StatefulWidget {
  final List<BovineEntity> bovines;
  final String farmId;

  const BatchTransferSelectorScreen({
    super.key,
    required this.bovines,
    required this.farmId,
  });

  @override
  State<BatchTransferSelectorScreen> createState() => _BatchTransferSelectorScreenState();
}

class _BatchTransferSelectorScreenState extends State<BatchTransferSelectorScreen> {
  final Set<String> _selectedBovineIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Bovinos (${_selectedBovineIds.length})',
        ),
        actions: [
          if (_selectedBovineIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedBovineIds.clear();
                });
              },
              child: const Text('Limpiar'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de información
          if (_selectedBovineIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedBovineIds.length} bovino${_selectedBovineIds.length > 1 ? 's' : ''} seleccionado${_selectedBovineIds.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Lista de bovinos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.bovines.length,
              itemBuilder: (context, index) {
                final bovine = widget.bovines[index];
                final isSelected = _selectedBovineIds.contains(bovine.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? Colors.blue.shade50 : null,
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedBovineIds.add(bovine.id);
                        } else {
                          _selectedBovineIds.remove(bovine.id);
                        }
                      });
                    },
                    title: Text(
                      bovine.identifier,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue.shade700 : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bovine.name?.isNotEmpty == true)
                          Text('Nombre: ${bovine.name}'),
                        Text('Raza: ${bovine.breed}'),
                        Text('Edad: ${bovine.ageDisplay}'),
                        Row(
                          children: [
                            Icon(
                              bovine.gender == BovineGender.female
                                  ? Icons.female
                                  : Icons.male,
                              size: 16,
                              color: bovine.gender == BovineGender.female
                                  ? Colors.pink
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bovine.gender == BovineGender.female
                                  ? 'Hembra'
                                  : 'Macho',
                            ),
                          ],
                        ),
                      ],
                    ),
                    secondary: Icon(
                      bovine.gender == BovineGender.female
                          ? Icons.female
                          : Icons.male,
                      color: bovine.gender == BovineGender.female
                          ? Colors.pink
                          : Colors.blue,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),

          // Botón de continuar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedBovineIds.isEmpty
                      ? null
                      : () {
                          print('✅ [BatchTransferSelectorScreen] Continuar con ${_selectedBovineIds.length} bovinos');
                          
                          // Verificar que hay seleccionados
                          if (_selectedBovineIds.isEmpty) {
                            print('❌ [BatchTransferSelectorScreen] No hay bovinos seleccionados');
                            return;
                          }
                          
                          // Obtener los bovinos seleccionados
                          final selectedBovines = widget.bovines
                              .where((b) => _selectedBovineIds.contains(b.id))
                              .toList();
                          
                          print('📋 [BatchTransferSelectorScreen] Bovinos seleccionados: ${selectedBovines.map((b) => b.identifier).join(", ")}');
                          
                          // Retornar los bovinos seleccionados al llamador
                          if (context.mounted) {
                            Navigator.pop(context, selectedBovines);
                          } else {
                            print('❌ [BatchTransferSelectorScreen] Contexto no montado');
                          }
                        },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _selectedBovineIds.isEmpty
                        ? 'Selecciona al menos un bovino'
                        : 'Continuar con ${_selectedBovineIds.length} bovino${_selectedBovineIds.length > 1 ? 's' : ''}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

