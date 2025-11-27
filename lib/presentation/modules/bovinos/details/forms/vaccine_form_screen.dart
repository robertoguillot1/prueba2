import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../cubits/health_cubit.dart';
import '../cubits/health_state.dart';

/// Pantalla de formulario para registrar una vacuna o tratamiento
class VaccineFormScreen extends StatefulWidget {
  final BovineEntity bovine;
  final String farmId;

  const VaccineFormScreen({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _loteController = TextEditingController();
  final _notasController = TextEditingController();

  DateTime _fechaAplicacion = DateTime.now();
  DateTime? _proximaDosis;
  bool _tieneProximaDosis = false;

  // Vacunas comunes predefinidas
  final List<String> _vacunasComunes = [
    'Fiebre Aftosa',
    'Brucelosis',
    'Rabia',
    'Carbón Sintomático',
    'IBR (Rinotraqueítis Infecciosa Bovina)',
    'DVB (Diarrea Viral Bovina)',
    'Leptospirosis',
    'Vitaminas (ADE)',
    'Desparasitante Interno',
    'Desparasitante Externo',
    'Antibiótico',
    'Antiinflamatorio',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _loteController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createHealthCubit(),
      child: BlocConsumer<HealthCubit, HealthState>(
        listener: (context, state) {
          if (state is HealthOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Retornar true para indicar éxito
          } else if (state is HealthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is HealthLoading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Registrar Vacuna'),
              actions: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _submit(context),
                    tooltip: 'Guardar',
                  ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Información del bovino
                  _buildBovinoInfo(),
                  const SizedBox(height: 24),

                  // Nombre de vacuna/tratamiento
                  _buildSectionTitle('Información de la Vacuna', Icons.vaccines),
                  const SizedBox(height: 12),
                  _buildVaccineNameField(),
                  const SizedBox(height: 16),

                  // Lote
                  _buildLoteField(),
                  const SizedBox(height: 24),

                  // Fechas
                  _buildSectionTitle('Fechas', Icons.calendar_today),
                  const SizedBox(height: 12),
                  _buildFechaAplicacionField(),
                  const SizedBox(height: 16),
                  _buildProximaDosisSection(),
                  const SizedBox(height: 24),

                  // Notas
                  _buildSectionTitle('Observaciones', Icons.notes),
                  const SizedBox(height: 12),
                  _buildNotasField(),
                  const SizedBox(height: 32),

                  // Botón de guardar
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Registrar Vacuna',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBovinoInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pets, color: Colors.blue.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bovine.identifier,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.bovine.name != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.bovine.name!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildVaccineNameField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Vacuna / Tratamiento *',
        hintText: 'Seleccione o escriba',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.vaccines),
      ),
      items: _vacunasComunes.map((vacuna) {
        return DropdownMenuItem(
          value: vacuna,
          child: Text(vacuna),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          if (value == 'Otro') {
            _nombreController.clear();
          } else {
            _nombreController.text = value;
          }
        }
      },
      validator: (value) {
        if (_nombreController.text.trim().isEmpty) {
          return 'Por favor seleccione o escriba el nombre';
        }
        return null;
      },
    );
  }

  Widget _buildLoteField() {
    return TextFormField(
      controller: _loteController,
      decoration: const InputDecoration(
        labelText: 'Número de Lote (Opcional)',
        hintText: 'Ej: L123456',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.qr_code),
      ),
    );
  }

  Widget _buildFechaAplicacionField() {
    return InkWell(
      onTap: () => _selectFechaAplicacion(),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de Aplicación *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_fechaAplicacion),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildProximaDosisSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Programar refuerzo'),
          value: _tieneProximaDosis,
          onChanged: (value) {
            setState(() {
              _tieneProximaDosis = value ?? false;
              if (!_tieneProximaDosis) {
                _proximaDosis = null;
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (_tieneProximaDosis) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectProximaDosis(),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de Próxima Dosis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event),
              ),
              child: Text(
                _proximaDosis != null
                    ? DateFormat('dd/MM/yyyy').format(_proximaDosis!)
                    : 'Seleccionar fecha',
                style: TextStyle(
                  fontSize: 16,
                  color: _proximaDosis != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotasField() {
    return TextFormField(
      controller: _notasController,
      decoration: const InputDecoration(
        labelText: 'Observaciones (Opcional)',
        hintText: 'Notas adicionales sobre la aplicación',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notes),
      ),
      maxLines: 3,
    );
  }

  Future<void> _selectFechaAplicacion() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaAplicacion,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaAplicacion = picked;
      });
    }
  }

  Future<void> _selectProximaDosis() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _proximaDosis ?? _fechaAplicacion.add(const Duration(days: 30)),
      firstDate: _fechaAplicacion,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _proximaDosis = picked;
      });
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<HealthCubit>().addNewVacuna(
            bovinoId: widget.bovine.id,
            farmId: widget.farmId,
            fechaAplicacion: _fechaAplicacion,
            nombreVacuna: _nombreController.text.trim(),
            lote: _loteController.text.trim().isEmpty
                ? null
                : _loteController.text.trim(),
            proximaDosis: _proximaDosis,
            notas: _notasController.text.trim().isEmpty
                ? null
                : _notasController.text.trim(),
          );
    }
  }
}



