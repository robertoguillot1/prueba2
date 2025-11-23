import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ovejas_viewmodel.dart';
import '../widgets/oveja_form.dart';
import '../../../../domain/entities/ovinos/oveja.dart';

/// Pantalla para editar una Oveja existente
class OvejaEditScreen extends StatefulWidget {
  final Oveja oveja;
  final String farmId;

  const OvejaEditScreen({
    super.key,
    required this.oveja,
    required this.farmId,
  });

  @override
  State<OvejaEditScreen> createState() => _OvejaEditScreenState();
}

class _OvejaEditScreenState extends State<OvejaEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleSave(Oveja oveja) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<OvejasViewModel>();
    final success = await viewModel.updateOvejaEntity(oveja, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oveja actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al actualizar oveja'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Oveja'),
      ),
      body: OvejaForm(
        initialOveja: widget.oveja,
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

