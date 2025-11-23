import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../widgets/bovino_form.dart';
import '../../../../domain/entities/bovinos/bovino.dart';

/// Pantalla para editar un Bovino existente
class BovinoEditScreen extends StatefulWidget {
  final Bovino bovino;
  final String farmId;

  const BovinoEditScreen({
    super.key,
    required this.bovino,
    required this.farmId,
  });

  @override
  State<BovinoEditScreen> createState() => _BovinoEditScreenState();
}

class _BovinoEditScreenState extends State<BovinoEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleSave(Bovino bovino) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<BovinosViewModel>();
    final success = await viewModel.updateBovinoEntity(bovino, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bovino actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al actualizar bovino'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Bovino'),
      ),
      body: BovinoForm(
        initialBovino: widget.bovino,
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

