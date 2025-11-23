import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cerdos_viewmodel.dart';
import '../widgets/cerdo_form.dart';
import '../../../../domain/entities/porcinos/cerdo.dart';

/// Pantalla para crear un nuevo Cerdo
class CerdoCreateScreen extends StatefulWidget {
  final String farmId;

  const CerdoCreateScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<CerdoCreateScreen> createState() => _CerdoCreateScreenState();
}

class _CerdoCreateScreenState extends State<CerdoCreateScreen> {
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
    final success = await viewModel.createCerdoEntity(cerdo, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cerdo creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al crear cerdo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cerdo'),
      ),
      body: CerdoForm(
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

