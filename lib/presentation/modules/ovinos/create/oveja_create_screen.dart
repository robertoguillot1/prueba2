import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ovejas_viewmodel.dart';
import '../widgets/oveja_form.dart';
import '../../../../domain/entities/ovinos/oveja.dart';

/// Pantalla para crear una nueva Oveja
class OvejaCreateScreen extends StatefulWidget {
  final String farmId;

  const OvejaCreateScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<OvejaCreateScreen> createState() => _OvejaCreateScreenState();
}

class _OvejaCreateScreenState extends State<OvejaCreateScreen> {
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
    final success = await viewModel.createOvejaEntity(oveja, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oveja creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al crear oveja'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Oveja'),
      ),
      body: OvejaForm(
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

