import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gallinas_viewmodel.dart';
import '../widgets/gallina_form.dart';
import '../../../../domain/entities/avicultura/gallina.dart';

/// Pantalla para crear una nueva Gallina
class GallinaCreateScreen extends StatefulWidget {
  final String farmId;

  const GallinaCreateScreen({
    super.key,
    required this.farmId,
  });

  @override
  State<GallinaCreateScreen> createState() => _GallinaCreateScreenState();
}

class _GallinaCreateScreenState extends State<GallinaCreateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleSave(Gallina gallina) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<GallinasViewModel>();
    final success = await viewModel.createGallinaEntity(gallina, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallina creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al crear gallina'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Gallina'),
      ),
      body: GallinaForm(
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

