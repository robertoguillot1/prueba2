import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/trabajadores_viewmodel.dart';
import '../widgets/trabajador_form.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';

/// Pantalla para crear un nuevo Trabajador
class TrabajadorCreateScreen extends StatefulWidget {
  final String farmId;

  const TrabajadorCreateScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<TrabajadorCreateScreen> createState() => _TrabajadorCreateScreenState();
}

class _TrabajadorCreateScreenState extends State<TrabajadorCreateScreen> {
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
    final success = await viewModel.createTrabajadorEntity(trabajador, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajador creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al crear trabajador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Trabajador'),
      ),
      body: TrabajadorForm(
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

