import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/vacuna_bovino_entity.dart';
import '../cubits/health_cubit.dart';
import '../cubits/health_state.dart';
import '../forms/vaccine_form_screen.dart';

/// Tab de Sanidad (Vacunas y Tratamientos) para el detalle del bovino
class HealthTab extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const HealthTab({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createHealthCubit()
        ..loadVacunas(bovineId: bovine.id, farmId: farmId),
      child: _HealthTabContent(
        bovine: bovine,
        farmId: farmId,
      ),
    );
  }
}

class _HealthTabContent extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const _HealthTabContent({
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HealthCubit, HealthState>(
      listener: (context, state) {
        if (state is HealthOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is HealthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is HealthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HealthError) {
          return _buildErrorState(context, state.message);
        }

        if (state is HealthLoaded) {
          return _buildLoadedState(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadedState(BuildContext context, HealthLoaded state) {
    if (state.vacunas.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<HealthCubit>().refresh(
            bovineId: bovine.id,
            farmId: farmId,
          ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Alertas de refuerzos pendientes o atrasados
              if (state.vacunasConRefuerzoAtrasado.isNotEmpty) ...[
                _buildAlertCard(
                  context,
                  'Refuerzos Atrasados',
                  '${state.vacunasConRefuerzoAtrasado.length} vacuna(s) con refuerzo atrasado',
                  Colors.red,
                  Icons.warning,
                ),
                const SizedBox(height: 12),
              ],
              if (state.vacunasConRefuerzoPendiente.isNotEmpty) ...[
                _buildAlertCard(
                  context,
                  'Refuerzos Próximos',
                  '${state.vacunasConRefuerzoPendiente.length} vacuna(s) requieren refuerzo pronto',
                  Colors.orange,
                  Icons.notifications_active,
                ),
                const SizedBox(height: 16),
              ],

              // Título
              Text(
                'Historial de Sanidad',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Lista de vacunas
              ...state.vacunas.map((vacuna) => _buildVaccineTile(context, vacuna)),

              const SizedBox(height: 80), // Espacio para el FAB
            ],
          ),

          // Botón flotante para agregar vacuna
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToVaccineForm(context),
              icon: const Icon(Icons.vaccines),
              label: const Text('Registrar'),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineTile(BuildContext context, VacunaBovinoEntity vacuna) {
    final bool hasRefuerzo = vacuna.proximaDosis != null;
    final bool refuerzoAtrasado = vacuna.refuerzoAtrasado;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.vaccines,
            color: Colors.green.shade700,
            size: 24,
          ),
        ),
        title: Text(
          vacuna.nombreVacuna,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(vacuna.fechaAplicacion),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            if (vacuna.lote != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.qr_code, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Lote: ${vacuna.lote}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
            if (hasRefuerzo) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: refuerzoAtrasado ? Colors.red.shade100 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: refuerzoAtrasado ? Colors.red : Colors.blue.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      refuerzoAtrasado ? Icons.warning : Icons.event,
                      size: 14,
                      color: refuerzoAtrasado ? Colors.red : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Refuerzo: ${DateFormat('dd/MM/yyyy').format(vacuna.proximaDosis!)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: refuerzoAtrasado ? Colors.red.shade900 : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: vacuna.notas != null && vacuna.notas!.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.notes, color: Colors.grey.shade600),
                onPressed: () => _showNotesDialog(context, vacuna),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vaccines_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin registros de sanidad',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza a registrar vacunas y tratamientos\npara llevar un control de la salud del animal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToVaccineForm(context),
              icon: const Icon(Icons.vaccines),
              label: const Text('Registrar Vacuna'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HealthCubit>().refresh(
                    bovineId: bovine.id,
                    farmId: farmId,
                  ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, VacunaBovinoEntity vacuna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notas'),
        content: Text(vacuna.notas ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToVaccineForm(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VaccineFormScreen(
          bovine: bovine,
          farmId: farmId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<HealthCubit>().refresh(
            bovineId: bovine.id,
            farmId: farmId,
          );
    }
  }
}




