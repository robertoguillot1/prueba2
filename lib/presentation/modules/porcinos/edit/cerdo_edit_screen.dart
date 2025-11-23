import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cerdos_viewmodel.dart';
import '../widgets/cerdo_form.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';

/// Pantalla para editar un Cerdo existente
class CerdoEditScreen extends StatefulWidget {
  final Cerdo cerdo;
  final String farmId;

  const CerdoEditScreen({
    super.key,
    required this.cerdo,
    required this.farmId,
  });

  @override
  State<CerdoEditScreen> createState() => _CerdoEditScreenState();
}

class _CerdoEditScreenState extends State<CerdoEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleSave(Cerdo cerdo) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<CerdosViewModel>();
    final success = await viewModel.updateCerdoEntity(cerdo, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cerdo actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al actualizar cerdo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cerdo'),
      ),
      body: CerdoForm(
        initialCerdo: widget.cerdo,
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

