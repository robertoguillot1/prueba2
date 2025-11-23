import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../list/trabajadores_list_screen.dart';
import '../create/trabajador_create_screen.dart';
import '../../../../core/di/dependency_injection.dart';
import '../viewmodels/trabajadores_viewmodel.dart';

/// Pantalla de menú de Trabajadores que centraliza todas las funcionalidades
class TrabajadoresMenuScreen extends StatelessWidget {
  final String farmId;

  const TrabajadoresMenuScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Trabajadores'),
        centerTitle: true,
      ),
      body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Título descriptivo
              Text(
                'Selecciona una opción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 24),

              // Opción 1: Directorio de Personal
              _buildMenuCard(
                context,
                icon: Icons.people,
                title: 'Directorio de Personal',
                subtitle: 'Ver y gestionar la lista completa de trabajadores',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrabajadoresListScreen(farmId: farmId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Opción 2: Registro de Pagos/Nómina
              _buildMenuCard(
                context,
                icon: Icons.payments,
                title: 'Registro de Pagos/Nómina',
                subtitle: 'Gestionar pagos, salarios y nómina de trabajadores',
                color: Colors.green,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => PaymentsListScreen(farm: farm),
                  //   ),
                  // );
                  debugPrint('Funcionalidad pendiente: Registro de Pagos/Nómina');
                },
              ),
              const SizedBox(height: 16),

              // Opción 3: Control de Préstamos
              _buildMenuCard(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Control de Préstamos',
                subtitle: 'Gestionar préstamos otorgados a trabajadores',
                color: Colors.orange,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => LoansListScreen(farm: farm),
                  //   ),
                  // );
                  debugPrint('Funcionalidad pendiente: Control de Préstamos');
                },
              ),
              const SizedBox(height: 16),

              // Opción 4: Registrar Nuevo Trabajador
              _buildMenuCard(
                context,
                icon: Icons.person_add,
                title: 'Registrar Nuevo Trabajador',
                subtitle: 'Agregar un nuevo trabajador al sistema',
                color: Colors.purple,
                onTap: () {
                  final viewModel = DependencyInjection.createTrabajadoresViewModel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: TrabajadorCreateScreen(farmId: farmId),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

