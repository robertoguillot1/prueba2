import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';
import '../models/feeding_alert.dart';

class FeedingAlertsScreen extends StatelessWidget {
  final Farm farm;

  const FeedingAlertsScreen({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, _child) {
        final updatedFarm = farmProvider.farms.firstWhere(
          (f) => f.id == farm.id,
          orElse: () => farm,
        );

        final alerts = updatedFarm.feedingAlerts.reversed.toList();
        final unreadAlerts = alerts.where((a) => !a.isRead).toList();
        final criticalAlerts = alerts.where((a) => a.level == AlertLevel.critical).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('🔔 Alertas de Alimentación'),
            centerTitle: true,
            backgroundColor: updatedFarm.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (unreadAlerts.isNotEmpty)
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${unreadAlerts.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    // Opción: marcar todas como leídas
                  },
                ),
            ],
          ),
          body: alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay alertas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Todo está bajo control',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: farmProvider.loadFarms,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Resumen
                      if (criticalAlerts.isNotEmpty || unreadAlerts.isNotEmpty)
                        Card(
                          color: criticalAlerts.isNotEmpty ? Colors.red[50] : Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      criticalAlerts.isNotEmpty ? Icons.error : Icons.info,
                                      color: criticalAlerts.isNotEmpty ? Colors.red : Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      criticalAlerts.isNotEmpty
                                          ? 'Alerta Crítica'
                                          : 'Resumen',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hay ${criticalAlerts.length} alerta(s) crítica(s) y ${unreadAlerts.length} alerta(s) sin leer',
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Lista de alertas
                      ...alerts.map((alert) => _buildAlertCard(context, alert, farmProvider)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAlertCard(BuildContext context, FeedingAlert alert, FarmProvider farmProvider) {
    return Card(
      elevation: alert.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.levelColor.withOpacity(alert.isRead ? 0.2 : 0.5),
          width: alert.isRead ? 1 : 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (!alert.isRead) {
            await farmProvider.markAlertAsRead(alert.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.levelColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      alert.levelIcon,
                      color: alert.levelColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.levelString,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: alert.levelColor,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(alert.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!alert.isRead)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


