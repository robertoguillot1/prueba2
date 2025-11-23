import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/trabajadores_viewmodel.dart';
import '../widgets/trabajador_form.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';

/// Pantalla para editar un Trabajador existente
class TrabajadorEditScreen extends StatefulWidget {
  final Trabajador trabajador;
  final String farmId;

  const TrabajadorEditScreen({
    super.key,
    required this.trabajador,
    required this.farmId,
  });

  @override
  State<TrabajadorEditScreen> createState() => _TrabajadorEditScreenState();
}

class _TrabajadorEditScreenState extends State<TrabajadorEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleSave(Trabajador trabajador) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<TrabajadoresViewModel>();
    final success = await viewModel.updateTrabajadorEntity(trabajador, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajador actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al actualizar trabajador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Trabajador'),
      ),
      body: TrabajadorForm(
        initialTrabajador: widget.trabajador,
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

