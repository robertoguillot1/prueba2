import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/trabajadores_viewmodel.dart';
import '../edit/trabajador_edit_screen.dart';
import '../../../../domain/entities/trabajadores/trabajador.dart';
import '../../../../presentation/widgets/info_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../screens/pagos_list_screen.dart';
import '../screens/prestamos_list_screen.dart';

/// Pantalla de detalles de un Trabajador
class TrabajadorDetailsScreen extends StatelessWidget {
  final Trabajador trabajador;
  final String farmId;

  const TrabajadorDetailsScreen({
    super.key,
    required this.trabajador,
    required this.farmId,
  });

  Future<bool> _confirmDelete(BuildContext context, TrabajadoresViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de eliminar a ${trabajador.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _handleDelete(BuildContext context, TrabajadoresViewModel viewModel) async {
    final confirmed = await _confirmDelete(context, viewModel);
    if (!confirmed) return;

    final success = await viewModel.deleteTrabajadorEntity(trabajador.id, farmId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trabajador eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al eliminar trabajador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<TrabajadoresViewModel>(),
          child: TrabajadorEditScreen(trabajador: trabajador, farmId: farmId),
        ),
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  Widget _buildFinanceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(trabajador.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(
              context,
              context.read<TrabajadoresViewModel>(),
            ),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: trabajador.isActive ? Colors.green : Colors.grey,
                    child: Icon(
                      trabajador.isActive ? Icons.person : Icons.person_off,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    trabajador.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      StatusChip(
                        label: trabajador.position,
                        color: Colors.blue,
                      ),
                      StatusChip(
                        label: trabajador.workerType == WorkerType.fijo ? 'Fijo' : 'Por Labor',
                        color: Colors.purple,
                      ),
                      StatusChip(
                        label: trabajador.isActive ? 'Activo' : 'Inactivo',
                        color: trabajador.isActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Información personal
            Text(
              'Información Personal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              label: 'Identificación',
              value: trabajador.identification,
              icon: Icons.badge,
            ),
            // Información laboral
            const SizedBox(height: 24),
            Text(
              'Información Laboral',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            InfoCard(
              label: 'Cargo',
              value: trabajador.position,
              icon: Icons.work,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Tipo de Trabajador',
              value: trabajador.workerType == WorkerType.fijo ? 'Fijo' : 'Por Labor',
              icon: Icons.category,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Salario',
              value: currencyFormat.format(trabajador.salary),
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 8),
            InfoCard(
              label: 'Fecha de Contratación',
              value: dateFormat.format(trabajador.startDate),
              icon: Icons.calendar_today,
            ),
            if (trabajador.workerType == WorkerType.porLabor &&
                trabajador.laborDescription != null) ...[
              const SizedBox(height: 8),
              InfoCard(
                label: 'Descripción de Labor',
                value: trabajador.laborDescription!,
                icon: Icons.description,
              ),
            ],
            const SizedBox(height: 32),
            
            // Gestión Financiera
             Text(
              'Gestión Financiera',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceCard(
                    context,
                    title: 'Pagos',
                    icon: Icons.payments,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PagosListScreen(
                            farmId: farmId,
                            workerId: trabajador.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFinanceCard(
                    context,
                    title: 'Préstamos',
                    icon: Icons.account_balance_wallet,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrestamosListScreen(
                            farmId: farmId,
                            workerId: trabajador.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: Icons.edit,
                    onPressed: () => _navigateToEdit(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: 'Eliminar',
                    icon: Icons.delete,
                    onPressed: () => _handleDelete(
                      context,
                      context.read<TrabajadoresViewModel>(),
                    ),
                    backgroundColor: Colors.red,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

