import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bovinos_viewmodel.dart';
import '../widgets/bovino_form.dart';
import '../../../../domain/entities/bovinos/bovino.dart';

/// Pantalla para crear un nuevo Bovino
class BovinoCreateScreen extends StatefulWidget {
  final String farmId;

  const BovinoCreateScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<BovinoCreateScreen> createState() => _BovinoCreateScreenState();
}

class _BovinoCreateScreenState extends State<BovinoCreateScreen> {
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
    final success = await viewModel.createBovinoEntity(bovino, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bovino creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al crear bovino'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Bovino'),
      ),
      body: BovinoForm(
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

