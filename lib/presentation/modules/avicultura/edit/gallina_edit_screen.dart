import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gallinas_viewmodel.dart';
import '../widgets/gallina_form.dart';
import '../../../../domain/entities/avicultura/gallina.dart';

/// Pantalla para editar una Gallina existente
class GallinaEditScreen extends StatefulWidget {
  final Gallina gallina;
  final String farmId;

  const GallinaEditScreen({
    super.key,
    required this.gallina,
    required this.farmId,
  });

  @override
  State<GallinaEditScreen> createState() => _GallinaEditScreenState();
}

class _GallinaEditScreenState extends State<GallinaEditScreen> {
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
    // TODO: Implementar updateGallinaEntity cuando esté disponible en ViewModel
    // Por ahora usamos createGallinaEntity
    final success = await viewModel.createGallinaEntity(gallina, widget.farmId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallina actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al actualizar gallina'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gallina'),
      ),
      body: GallinaForm(
        initialGallina: widget.gallina,
        farmId: widget.farmId,
        formKey: _formKey,
        onSave: _handleSave,
      ),
    );
  }
}

