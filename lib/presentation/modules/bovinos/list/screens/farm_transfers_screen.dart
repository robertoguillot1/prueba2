import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../core/di/dependency_injection.dart' show sl;
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../cubits/farm_transfers_cubit.dart';
import '../../details/cubits/transfer_state.dart';
import '../../details/forms/transfer_form_screen.dart';
import '../../screens/bovino_detail_screen.dart';
import 'batch_transfer_selector_screen.dart';
import 'batch_transfer_form_screen.dart';

/// Pantalla para ver todas las transferencias de una finca
class FarmTransfersScreen extends StatelessWidget {
  final String farmId;

  const FarmTransfersScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createFarmTransfersCubit()
        ..loadTransfers(farmId: farmId),
      child: _FarmTransfersScreenContent(farmId: farmId),
    );
  }
}

class _FarmTransfersScreenContent extends StatelessWidget {
  final String farmId;

  const _FarmTransfersScreenContent({required this.farmId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporte y Transferencias'),
        centerTitle: true,
      ),
      body: BlocConsumer<FarmTransfersCubit, TransferState>(
        listener: (context, state) {
          if (state is TransferOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar la lista después de una operación exitosa
            context.read<FarmTransfersCubit>().refresh(farmId: farmId);
          } else if (state is TransferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TransferLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransferError) {
            return _buildErrorState(context, state.message);
          }

          if (state is TransferLoaded) {
            return _buildLoadedState(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransferOptions(context),
        icon: const Icon(Icons.local_shipping),
        label: const Text('Nueva Transferencia'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, TransferLoaded state) {
    if (state.transfers.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FarmTransfersCubit>().refresh(farmId: farmId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título
          Text(
            'Historial de Transferencias (${state.transfers.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Lista de transferencias
          ...state.transfers.map((transfer) => _buildTransferTile(context, transfer)),
        ],
      ),
    );
  }

  Widget _buildTransferTile(BuildContext context, TransferEntity transfer) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final color = _getColorForReason(transfer.reason);
    final icon = _getIconForReason(transfer.reason);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _showTransferDetails(context, transfer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transfer.reason.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToBovine(context, transfer.bovineId),
                          child: const Text('Ver Bovino'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(transfer.transferDate),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${transfer.fromLocation} → ${transfer.toLocation}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (transfer.transporterName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            transfer.transporterName!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditTransfer(context, transfer);
                  } else if (value == 'delete') {
                    _confirmDeleteTransfer(context, transfer);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin registros de transferencias',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza a registrar transferencias\npara llevar un control de los movimientos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
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
              onPressed: () => context.read<FarmTransfersCubit>().refresh(farmId: farmId),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDetails(BuildContext context, TransferEntity transfer) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transfer.reason.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Fecha', dateFormat.format(transfer.transferDate)),
              _buildDetailRow('Origen', transfer.fromLocation),
              _buildDetailRow('Destino', transfer.toLocation),
              if (transfer.toFarmId != null)
                _buildDetailRow('ID Finca Destino', transfer.toFarmId!),
              if (transfer.transporterName != null)
                _buildDetailRow('Transportista', transfer.transporterName!),
              if (transfer.vehicleInfo != null)
                _buildDetailRow('Vehículo', transfer.vehicleInfo!),
              if (transfer.notes != null && transfer.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Notas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(transfer.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEditTransfer(context, transfer);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteTransfer(context, transfer);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToBovine(context, transfer.bovineId);
            },
            child: const Text('Ver Bovino'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getIconForReason(TransferReason reason) {
    switch (reason.iconName) {
      case 'attach_money':
        return Icons.attach_money;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'child_care':
        return Icons.child_care;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.more_horiz;
    }
  }

  Color _getColorForReason(TransferReason reason) {
    switch (reason) {
      case TransferReason.venta:
        return Colors.green;
      case TransferReason.prestamo:
        return Colors.blue;
      case TransferReason.reproduccion:
        return Colors.pink;
      case TransferReason.tratamiento:
        return Colors.orange;
      case TransferReason.otro:
        return Colors.grey;
    }
  }

  Future<void> _navigateToBovine(BuildContext context, String bovineId) async {
    // Obtener lista de bovinos y buscar el específico
    final getCattleList = sl<GetCattleList>();
    final result = await getCattleList(GetCattleListParams(farmId: farmId));

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (bovines) {
        try {
          final bovine = bovines.firstWhere((b) => b.id == bovineId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BovinoDetailScreen(
                bovine: bovine,
                farmId: farmId,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bovino no encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showTransferOptions(BuildContext context) {
    print('📋 [FarmTransfersScreen] Mostrando opciones de transferencia');
    // CRÍTICO: Guardar el contexto de la pantalla principal ANTES del bottom sheet
    final parentContext = context;
    
    showModalBottomSheet(
      context: context,
      builder: (bsContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Transferencia Individual'),
              subtitle: const Text('Registrar transferencia de un bovino'),
              onTap: () {
                print('✅ [FarmTransfersScreen] Opción Individual seleccionada');
                Navigator.pop(bsContext); // Cerrar con el context del bottom sheet
                // Usar el contexto de la pantalla principal
                Future.microtask(() {
                  if (parentContext.mounted) {
                    print('🚀 [FarmTransfersScreen] Navegando a selector individual...');
                    _showBovineSelector(parentContext);
                  } else {
                    print('❌ [FarmTransfersScreen] Contexto no montado después de cerrar bottom sheet');
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Transferencia de Lote'),
              subtitle: const Text('Registrar transferencia de múltiples bovinos'),
              onTap: () {
                print('✅ [FarmTransfersScreen] Opción Lote seleccionada');
                Navigator.pop(bsContext); // Cerrar con el context del bottom sheet
                // Usar el contexto de la pantalla principal
                Future.microtask(() {
                  if (parentContext.mounted) {
                    print('🚀 [FarmTransfersScreen] Navegando a selector de lote...');
                    _showBatchTransferSelector(parentContext);
                  } else {
                    print('❌ [FarmTransfersScreen] Contexto no montado después de cerrar bottom sheet');
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBovineSelector(BuildContext context) async {
    try {
      // Verificar que el contexto esté montado
      if (!context.mounted) {
        print('❌ [FarmTransfersScreen] Contexto no montado al iniciar selección');
        return;
      }

      // Obtener lista de bovinos
      final getCattleList = sl<GetCattleList>();
      final result = await getCattleList(GetCattleListParams(farmId: farmId));

      await result.fold(
        (failure) async {
          print('❌ [FarmTransfersScreen] Error al obtener bovinos: ${failure.message}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (bovines) async {
          print('✅ [FarmTransfersScreen] Bovinos obtenidos: ${bovines.length}');

          if (!context.mounted) {
            print('❌ [FarmTransfersScreen] Contexto no montado después de obtener bovinos');
            return;
          }

          if (bovines.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No hay bovinos registrados'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          // Mostrar diálogo de selección
          print('📋 [FarmTransfersScreen] Mostrando diálogo de selección...');
          final selectedBovine = await showDialog<BovineEntity>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Seleccionar Bovino'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: bovines.length,
                    itemBuilder: (context, index) {
                      final bovine = bovines[index];
                      return ListTile(
                        leading: Icon(
                          bovine.gender == BovineGender.female 
                              ? Icons.female 
                              : Icons.male,
                          color: bovine.gender == BovineGender.female 
                              ? Colors.pink 
                              : Colors.blue,
                        ),
                        title: Text(
                          bovine.identifier,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          bovine.name?.isNotEmpty == true 
                              ? '${bovine.name} • ${bovine.breed}' 
                              : bovine.breed,
                        ),
                        onTap: () {
                          print('✅ [FarmTransfersScreen] Bovino seleccionado: ${bovine.identifier}');
                          Navigator.pop(dialogContext, bovine);
                        },
                      );
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('❌ [FarmTransfersScreen] Selección cancelada');
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          );

          print('🔍 [FarmTransfersScreen] Resultado del diálogo: ${selectedBovine?.identifier ?? "null"}');

          // Si se seleccionó un bovino, navegar al formulario
          if (selectedBovine != null) {
            if (!context.mounted) {
              print('❌ [FarmTransfersScreen] Contexto no montado antes de navegar');
              return;
            }

            print('🚀 [FarmTransfersScreen] Navegando al formulario para: ${selectedBovine.identifier}');
            
            final editResult = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => TransferFormScreen(
                  bovine: selectedBovine,
                  farmId: farmId,
                ),
              ),
            );

            print('📝 [FarmTransfersScreen] Resultado del formulario: $editResult');

            // Recargar la lista si se guardó exitosamente
            if (editResult == true && context.mounted) {
              print('🔄 [FarmTransfersScreen] Recargando lista de transferencias...');
              context.read<FarmTransfersCubit>().refresh(farmId: farmId);
            }
          } else {
            print('⚠️ [FarmTransfersScreen] No se seleccionó ningún bovino');
          }
        },
      );
    } catch (e, stackTrace) {
      print('❌ [FarmTransfersScreen] Error inesperado: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditTransfer(BuildContext context, TransferEntity transfer) async {
    // Obtener el bovino para poder editarlo
    final getCattleList = sl<GetCattleList>();
    final result = await getCattleList(GetCattleListParams(farmId: farmId));

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (bovines) async {
        try {
          final bovine = bovines.firstWhere((b) => b.id == transfer.bovineId);
          final editResult = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => TransferFormScreen(
                bovine: bovine,
                farmId: farmId,
                transfer: transfer, // Modo edición
              ),
            ),
          );

          if (editResult == true && context.mounted) {
            context.read<FarmTransfersCubit>().refresh(farmId: farmId);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bovino no encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _confirmDeleteTransfer(BuildContext context, TransferEntity transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de eliminar esta transferencia del ${DateFormat('dd/MM/yyyy').format(transfer.transferDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<FarmTransfersCubit>().deleteTransfer(
            id: transfer.id,
            bovineId: transfer.bovineId,
            farmId: farmId,
          );
    }
  }

  Future<void> _showBatchTransferSelector(BuildContext context) async {
    try {
      // Verificar que el contexto esté montado
      if (!context.mounted) {
        print('❌ [FarmTransfersScreen] Contexto no montado al iniciar selección de lote');
        return;
      }

      // Obtener lista de bovinos
      final getCattleList = sl<GetCattleList>();
      final result = await getCattleList(GetCattleListParams(farmId: farmId));

      await result.fold(
        (failure) async {
          print('❌ [FarmTransfersScreen] Error al obtener bovinos para lote: ${failure.message}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (bovines) async {
          print('✅ [FarmTransfersScreen] Bovinos obtenidos para lote: ${bovines.length}');

          if (!context.mounted) {
            print('❌ [FarmTransfersScreen] Contexto no montado después de obtener bovinos');
            return;
          }

          if (bovines.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No hay bovinos registrados'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          // Navegar a la pantalla de selección múltiple
          print('📋 [FarmTransfersScreen] Navegando a selector de lote...');
          final selectedBovines = await Navigator.push<List<BovineEntity>>(
            context,
            MaterialPageRoute(
              builder: (_) => BatchTransferSelectorScreen(
                bovines: bovines,
                farmId: farmId,
              ),
            ),
          );

          print('🔍 [FarmTransfersScreen] Resultado del selector: ${selectedBovines?.length ?? 0} bovinos');

          // Si se seleccionaron bovinos, navegar al formulario de lote
          if (selectedBovines != null && selectedBovines.isNotEmpty) {
            if (!context.mounted) {
              print('❌ [FarmTransfersScreen] Contexto no montado antes de navegar al formulario de lote');
              return;
            }

            print('🚀 [FarmTransfersScreen] Navegando al formulario de lote para ${selectedBovines.length} bovinos');

            final editResult = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => BatchTransferFormScreen(
                  bovines: selectedBovines,
                  farmId: farmId,
                ),
              ),
            );

            print('📝 [FarmTransfersScreen] Resultado del formulario de lote: $editResult');

            // Recargar la lista si se guardó exitosamente
            if (editResult == true && context.mounted) {
              print('🔄 [FarmTransfersScreen] Recargando lista de transferencias...');
              context.read<FarmTransfersCubit>().refresh(farmId: farmId);
            }
          } else {
            print('⚠️ [FarmTransfersScreen] No se seleccionaron bovinos para el lote');
          }
        },
      );
    } catch (e, stackTrace) {
      print('❌ [FarmTransfersScreen] Error inesperado en selección de lote: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

