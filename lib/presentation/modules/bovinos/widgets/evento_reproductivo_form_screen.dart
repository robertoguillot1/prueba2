import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/entities/bovinos/evento_reproductivo.dart';
import '../../../../domain/entities/bovinos/bovino.dart';
import '../../../../domain/usecases/bovinos/create_evento_reproductivo.dart';
import '../../../../domain/usecases/bovinos/registrar_parto_con_cria.dart';
import '../../../../domain/repositories/bovinos/eventos_reproductivos_repository.dart';
import '../../../../domain/repositories/bovinos/bovinos_repository.dart';
import '../../../../data/repositories_impl/bovinos/eventos_reproductivos_repository_impl.dart';
import '../../../../data/datasources/bovinos/eventos_reproductivos_datasource.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/eventos_reproductivos_viewmodel.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../widgets/cattle_selector_field.dart';
import '../../../../presentation/widgets/custom_date_picker.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/custom_dropdown.dart';
import '../../../../presentation/widgets/form_section.dart';

/// Pantalla para crear/editar un evento reproductivo
class EventoReproductivoFormScreen extends StatefulWidget {
  final Bovino bovino;
  final String farmId;
  final TipoEventoReproductivo? tipoPreSeleccionado;

  const EventoReproductivoFormScreen({
    super.key,
    required this.bovino,
    required this.farmId,
    this.tipoPreSeleccionado,
  });

  @override
  State<EventoReproductivoFormScreen> createState() => _EventoReproductivoFormScreenState();
}

class _EventoReproductivoFormScreenState extends State<EventoReproductivoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TipoEventoReproductivo _tipoEvento;
  DateTime _fecha = DateTime.now();
  final _notasController = TextEditingController();
  
  // Campos específicos por tipo
  Bovino? _toroSeleccionado;
  final _codigoPajillaController = TextEditingController();
  String? _resultadoPalpacion;
  bool _nacioCria = true;
  final _pesoCriaController = TextEditingController();
  BovinoGender? _generoCria;

  @override
  void initState() {
    super.initState();
    _tipoEvento = widget.tipoPreSeleccionado ?? TipoEventoReproductivo.celo;
  }

  @override
  void dispose() {
    _notasController.dispose();
    _codigoPajillaController.dispose();
    _pesoCriaController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildDetalles() {
    final detalles = <String, dynamic>{};

    switch (_tipoEvento) {
      case TipoEventoReproductivo.montaInseminacion:
        if (_toroSeleccionado != null) {
          detalles['idToro'] = _toroSeleccionado!.id;
          detalles['nombreToro'] = _toroSeleccionado!.name ?? _toroSeleccionado!.identification;
        }
        if (_codigoPajillaController.text.isNotEmpty) {
          detalles['codigoPajilla'] = _codigoPajillaController.text.trim();
        }
        break;
      case TipoEventoReproductivo.palpacionTacto:
        if (_resultadoPalpacion != null) {
          detalles['resultadoPalpacion'] = _resultadoPalpacion;
        }
        break;
      case TipoEventoReproductivo.parto:
        detalles['nacioCria'] = _nacioCria;
        if (_nacioCria && _pesoCriaController.text.isNotEmpty) {
          detalles['pesoCria'] = double.tryParse(_pesoCriaController.text);
        }
        if (_generoCria != null) {
          detalles['generoCria'] = _generoCria!.name;
        }
        break;
      default:
        break;
    }

    return detalles;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Crear ViewModel temporalmente
    final prefs = await SharedPreferences.getInstance();
    final eventosDataSource = EventosReproductivosDataSourceImpl(prefs);
    final eventosRepository = EventosReproductivosRepositoryImpl(eventosDataSource);
    final bovinosRepository = DependencyInjection.bovinosRepository;
    
    final eventosViewModel = EventosReproductivosViewModel(
      createEvento: CreateEventoReproductivo(eventosRepository),
      registrarPartoConCria: RegistrarPartoConCria(
        eventosRepository: eventosRepository,
        bovinosRepository: bovinosRepository,
      ),
    );
    
    final detalles = _buildDetalles();

    final evento = EventoReproductivo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmId: widget.farmId,
      idAnimal: widget.bovino.id,
      tipo: _tipoEvento,
      fecha: _fecha,
      detalles: detalles,
      notas: _notasController.text.trim().isEmpty 
          ? null 
          : _notasController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Si es parto, preguntar si crear cría
    if (_tipoEvento == TipoEventoReproductivo.parto && _nacioCria) {
      final crearCria = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Crear la cría ahora?'),
          content: const Text(
            '¿Desea crear un nuevo bovino para esta cría? '
            'Se pre-rellenará automáticamente con la información de los padres.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, crear cría'),
            ),
          ],
        ),
      );

      if (crearCria == true) {
        // Abrir formulario simplificado para crear cría
        final datosCria = await _mostrarFormularioCria();
        if (datosCria != null && mounted) {
          final result = await eventosViewModel.registrarParto(
            eventoParto: evento,
            crearCria: true,
            datosCria: datosCria,
          );

          if (mounted) {
            if (result != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parto registrado y cría creada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    eventosViewModel.errorMessage ?? 'Error al registrar parto',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          return;
        }
      }
    }

    // Registrar evento normal
    final success = await eventosViewModel.createEventoReproductivo(evento);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              eventosViewModel.errorMessage ?? 'Error al registrar evento',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _mostrarFormularioCria() async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FormularioCriaDialog(
        fechaNacimiento: _fecha,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bovinosViewModel = context.watch<BovinosViewModel>();
    final toros = bovinosViewModel.bovinos
        .where((b) => b.gender == BovinoGender.male)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Evento Reproductivo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FormSection(
              title: 'Información del Evento',
              children: [
                const SizedBox(height: 8),
                CustomDropdown<TipoEventoReproductivo>(
                  label: 'Tipo de Evento *',
                  value: _tipoEvento,
                  items: TipoEventoReproductivo.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _tipoEvento = value);
                    }
                  },
                  prefixIcon: Icons.event,
                ),
                const SizedBox(height: 16),
                CustomDatePicker(
                  label: 'Fecha del Evento *',
                  selectedDate: _fecha,
                  onDateSelected: (date) {
                    setState(() => _fecha = date);
                  },
                  lastDate: DateTime.now(),
                ),
              ],
            ),
            // Campos específicos según el tipo
            if (_tipoEvento == TipoEventoReproductivo.montaInseminacion) ...[
              FormSection(
                title: 'Información de Monta/Inseminación',
                children: [
                  const SizedBox(height: 8),
                  if (toros.isNotEmpty)
                    CattleSelectorField(
                      label: 'Toro (opcional)',
                      hint: 'Selecciona el toro',
                      prefixIcon: Icons.male,
                      selectedBovino: _toroSeleccionado,
                      availableBovinos: toros,
                      sexFilter: SexFilter.male,
                      onSelect: (bovino) {
                        setState(() => _toroSeleccionado = bovino);
                      },
                    ),
                  if (toros.isNotEmpty) const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Código de Pajilla (opcional)',
                    controller: _codigoPajillaController,
                    hint: 'Ej: PAJ-001',
                    prefixIcon: Icons.tag,
                  ),
                ],
              ),
            ],
            if (_tipoEvento == TipoEventoReproductivo.palpacionTacto) ...[
              FormSection(
                title: 'Resultado de Palpación',
                children: [
                  const SizedBox(height: 8),
                  CustomDropdown<String?>(
                    label: 'Resultado *',
                    value: _resultadoPalpacion,
                    items: const [
                      DropdownMenuItem(value: 'Preñada', child: Text('Preñada')),
                      DropdownMenuItem(value: 'Vacía', child: Text('Vacía')),
                    ],
                    onChanged: (value) {
                      setState(() => _resultadoPalpacion = value);
                    },
                    prefixIcon: Icons.medical_services,
                  ),
                ],
              ),
            ],
            if (_tipoEvento == TipoEventoReproductivo.parto) ...[
              FormSection(
                title: 'Información del Parto',
                children: [
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('¿Nació cría?'),
                    value: _nacioCria,
                    onChanged: (value) {
                      setState(() => _nacioCria = value);
                    },
                  ),
                  if (_nacioCria) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Peso de la cría (kg)',
                      controller: _pesoCriaController,
                      hint: 'Ej: 35.5',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.monitor_weight,
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown<BovinoGender?>(
                      label: 'Género de la cría',
                      value: _generoCria,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No especificado'),
                        ),
                        const DropdownMenuItem(
                          value: BovinoGender.male,
                          child: Text('Macho'),
                        ),
                        const DropdownMenuItem(
                          value: BovinoGender.female,
                          child: Text('Hembra'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _generoCria = value);
                      },
                      prefixIcon: Icons.wc,
                    ),
                  ],
                ],
              ),
            ],
            FormSection(
              title: 'Notas',
              children: [
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Notas Adicionales',
                  controller: _notasController,
                  hint: 'Información adicional sobre el evento...',
                  maxLines: 4,
                  prefixIcon: Icons.note,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Evento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioCriaDialog extends StatefulWidget {
  final DateTime fechaNacimiento;

  const _FormularioCriaDialog({required this.fechaNacimiento});

  @override
  State<_FormularioCriaDialog> createState() => _FormularioCriaDialogState();
}

class _FormularioCriaDialogState extends State<_FormularioCriaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _identificationController = TextEditingController();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _razaController = TextEditingController();
  BovinoGender _gender = BovinoGender.male;

  @override
  void dispose() {
    _identificationController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _razaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Cría'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Identificación',
                  controller: _identificationController,
                  hint: 'Ej: BOV-001',
                  prefixIcon: Icons.tag,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nombre',
                  controller: _nameController,
                  hint: 'Ej: Ternero 1',
                  prefixIcon: Icons.pets,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Peso al Nacer (kg)',
                  controller: _weightController,
                  hint: 'Ej: 35.5',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.monitor_weight,
                ),
                const SizedBox(height: 16),
                CustomDropdown<BovinoGender>(
                  label: 'Género *',
                  value: _gender,
                  items: [
                    const DropdownMenuItem(
                      value: BovinoGender.male,
                      child: Text('Macho'),
                    ),
                    const DropdownMenuItem(
                      value: BovinoGender.female,
                      child: Text('Hembra'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _gender = value);
                    }
                  },
                  prefixIcon: Icons.wc,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Raza',
                  controller: _razaController,
                  hint: 'Ej: Holstein',
                  prefixIcon: Icons.agriculture,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'identification': _identificationController.text.trim().isEmpty
                    ? null
                    : _identificationController.text.trim(),
                'name': _nameController.text.trim().isEmpty
                    ? null
                    : _nameController.text.trim(),
                'currentWeight': _weightController.text.isEmpty
                    ? 0.0
                    : double.tryParse(_weightController.text) ?? 0.0,
                'gender': _gender,
                'raza': _razaController.text.trim().isEmpty
                    ? null
                    : _razaController.text.trim(),
              });
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

