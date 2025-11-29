import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/dependency_injection.dart' as di;
import '../../../../../features/cattle/domain/entities/bovine_entity.dart';
import '../../../../../features/cattle/domain/entities/transfer_entity.dart';
import '../cubits/transfer_cubit.dart';
import '../cubits/transfer_state.dart';
import '../forms/transfer_form_screen.dart';

/// Tab de Transporte/Transferencias para el detalle del bovino
class TransferTab extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const TransferTab({
    super.key,
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.DependencyInjection.createTransferCubit()
        ..loadTransfers(bovineId: bovine.id, farmId: farmId),
      child: _TransferTabContent(
        bovine: bovine,
        farmId: farmId,
      ),
    );
  }
}

class _TransferTabContent extends StatelessWidget {
  final BovineEntity bovine;
  final String farmId;

  const _TransferTabContent({
    required this.bovine,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransferCubit, TransferState>(
      listener: (context, state) {
        if (state is TransferOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Recargar la lista después de una operación exitosa
          context.read<TransferCubit>().refresh(
                bovineId: bovine.id,
                farmId: farmId,
              );
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
    );
  }

  Widget _buildLoadedState(BuildContext context, TransferLoaded state) {
    if (state.transfers.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TransferCubit>().refresh(
            bovineId: bovine.id,
            farmId: farmId,
          ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Título
              Text(
                'Historial de Transferencias',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Lista de transferencias
              ...state.transfers.map((transfer) => _buildTransferTile(context, transfer)),

              const SizedBox(height: 80), // Espacio para el FAB
            ],
          ),

          // Botón flotante para agregar transferencia
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToTransferForm(context),
              icon: const Icon(Icons.local_shipping),
              label: const Text('Registrar'),
              backgroundColor: Colors.blue,
            ),
          ),
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
                    Text(
                      transfer.reason.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
              'Comienza a registrar transferencias\npara llevar un control de los movimientos del animal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToTransferForm(context),
              icon: const Icon(Icons.local_shipping),
              label: const Text('Registrar Transferencia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
              onPressed: () => context.read<TransferCubit>().refresh(
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

  Future<void> _navigateToTransferForm(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransferFormScreen(
          bovine: bovine,
          farmId: farmId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TransferCubit>().refresh(
            bovineId: bovine.id,
            farmId: farmId,
          );
    }
  }

  Future<void> _navigateToEditTransfer(BuildContext context, TransferEntity transfer) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransferFormScreen(
          bovine: bovine,
          farmId: farmId,
          transfer: transfer, // Modo edición
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<TransferCubit>().refresh(
            bovineId: bovine.id,
            farmId: farmId,
          );
    }
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
      context.read<TransferCubit>().deleteTransfer(
            id: transfer.id,
            bovineId: bovine.id,
            farmId: farmId,
          );
    }
  }
}

