import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/dependency_injection.dart';
import '../../../../../features/cattle/domain/entities/feeding_schedule.dart';
import '../../../../widgets/custom_card.dart';
import '../../../../widgets/animated_button.dart';
import '../cubits/feeding_cubit.dart';
import 'package:uuid/uuid.dart';

class FeedingTab extends StatelessWidget {
  final String bovineId;
  final String farmId;

  const FeedingTab({super.key, required this.bovineId, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.createFeedingCubit()..loadFeedingData(bovineId),
      child: BlocBuilder<FeedingCubit, FeedingState>(
        builder: (context, state) {
          if (state is FeedingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is FeedingError) {
            return Center(child: Text(state.message));
          }

          if (state is FeedingLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNutritionalSummary(context, state.nutritionalStats),
                  const SizedBox(height: 16),
                  _buildAddScheduleButton(context),
                  const SizedBox(height: 16),
                  _buildActiveSchedulesList(context, state.schedules),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNutritionalSummary(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      elevation: 4,
      gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen Nutricional (Estimado)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Energía', '${stats['energy_mcal']} Mcal', Icons.flash_on, Colors.orange),
              _buildStatItem('Proteína', '${stats['protein_g']} g', Icons.fitness_center, Colors.blue),
              _buildStatItem('Fibra', '${stats['fiber_g']} g', Icons.grass, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildAddScheduleButton(BuildContext context) {
    return AnimatedButton(
      label: 'Agregar Dieta / Suplemento',
      icon: Icons.add_circle_outline,
      color: Colors.green,
      onPressed: () => _showAddDialog(context),
    );
  }

  Widget _buildActiveSchedulesList(BuildContext context, List<FeedingSchedule> schedules) {
    if (schedules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay programas de alimentación activos.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Programa Actual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...schedules.map((schedule) => _buildScheduleItem(context, schedule)),
      ],
    );
  }

  Widget _buildScheduleItem(BuildContext context, FeedingSchedule schedule) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.restaurant, color: Colors.green.shade800),
        ),
        title: Text(schedule.feedType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${schedule.amountKg} kg - ${schedule.frequency}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final feedTypeController = TextEditingController();
    final amountController = TextEditingController();
    String frequency = 'Diario'; // Default

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nueva Alimentación'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: feedTypeController,
                decoration: const InputDecoration(labelText: 'Tipo de Alimento (e.g. Concentrado)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad (Kg)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                items: ['Diario', 'AM', 'PM', 'Semanal']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => frequency = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.tryParse(amountController.text) ?? 0;
                final newSchedule = FeedingSchedule(
                  id: const Uuid().v4(), // We need uuid package or generate random string
                  bovineId: bovineId,
                  farmId: farmId,
                  feedType: feedTypeController.text,
                  amountKg: amount,
                  frequency: frequency,
                  startDate: DateTime.now(),
                );
                
                // Use the context from the button press which is separate, but we need the cubit context
                // Since showDialog context is different, we can't access provided Bloc easily unless passed.
                // We'll call the method on the parent context BEFORE popping or pass the cubit.
                // Actually, BlocProvider is above. So we can access it using the parent 'context' 
                // but we need to capture it outside showDialog closure or use .read/add.
                
                context.read<FeedingCubit>().addSchedule(newSchedule);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
