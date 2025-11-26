import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/farm/farm.dart';
import '../../../../presentation/cubits/auth/auth_cubit.dart';
import '../../../../presentation/cubits/auth/auth_state.dart';
import '../cubits/farms_cubit.dart';
import '../cubits/farms_state.dart';
import 'farm_form_screen.dart';
import '../../../../core/di/dependency_injection.dart' as di;

/// Pantalla para listar las fincas del usuario
class FarmsListScreen extends StatelessWidget {
  const FarmsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis Fincas')),
            body: const Center(
              child: Text('Debes iniciar sesión para ver tus fincas'),
            ),
          );
        }

        final userId = authState.user.id;

        return BlocProvider(
          create: (_) => di.DependencyInjection.createFarmsCubit(userId),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Mis Fincas'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: di.DependencyInjection.createFarmFormCubit(userId),
                          child: const FarmFormScreen(),
                        ),
                      ),
                    );
                    // Si se creó una finca exitosamente, el stream se actualizará automáticamente
                    // No necesitamos recargar manualmente
                  },
                  tooltip: 'Crear nueva finca',
                ),
              ],
            ),
            body: BlocBuilder<FarmsCubit, FarmsState>(
              builder: (context, state) {
                if (state is FarmsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FarmsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<FarmsCubit>().reloadFarms();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is FarmsLoaded) {
                  if (state.farms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.agriculture,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes fincas',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primera finca para comenzar',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: di.DependencyInjection.createFarmFormCubit(userId),
                                    child: const FarmFormScreen(),
                                  ),
                                ),
                              );
                              // El stream se actualizará automáticamente
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Finca'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<FarmsCubit>().reloadFarms();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.farms.length,
                      itemBuilder: (context, index) {
                        final farm = state.farms[index];
                        return _buildFarmCard(context, farm, userId);
                      },
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFarmCard(BuildContext context, Farm farm, String userId) {
    final primaryColor = Color(farm.primaryColor);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          // Establecer como finca actual y navegar al dashboard
          try {
            await context.read<FarmsCubit>().setCurrentFarm(farm.id);
            
            if (!context.mounted) return;
            
            // Navegar al dashboard con el farmId
            Navigator.of(context).pushReplacementNamed(
              '/dashboard',
              arguments: {'farmId': farm.id},
            );
          } catch (e) {
            if (!context.mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Error al seleccionar la finca'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de finca con color
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.agriculture,
                  color: primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Información de la finca
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (farm.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            farm.location!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Botón de opciones
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: di.DependencyInjection.createFarmFormCubit(userId),
                          child: FarmFormScreen(farm: farm),
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, farm);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Farm farm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Finca'),
        content: Text('¿Estás seguro de que deseas eliminar "${farm.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<FarmsCubit>().deleteFarm(farm.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Finca "${farm.name}" eliminada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

