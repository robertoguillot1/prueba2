import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          
          // Exportar datos
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.green),
              title: const Text('Exportar Datos'),
              subtitle: const Text('Crear una copia de seguridad de toda la información'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _exportData(context),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Importar datos
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.file_download, color: Colors.blue),
              title: const Text('Importar Datos'),
              subtitle: const Text('Restaurar datos desde un archivo de copia de seguridad'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _importData(context),
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // Información del usuario
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user != null) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade400,
                              child: Text(
                                authProvider.user!.displayName != null &&
                                        authProvider.user!.displayName!.isNotEmpty
                                    ? authProvider.user!.displayName![0].toUpperCase()
                                    : authProvider.user!.email![0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authProvider.user!.displayName ??
                                        'Usuario',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authProvider.user!.email ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Cerrar sesión
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Card(
                elevation: 2,
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.orange.shade700),
                  title: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  subtitle: const Text('Salir de tu cuenta'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _logout(context, authProvider),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // Información sobre copias de seguridad
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Información sobre Copias de Seguridad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(Icons.check_circle, 'Exportar crea un archivo JSON con todos tus datos'),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.check_circle, 'Puedes compartir el archivo por WhatsApp, correo, etc.'),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.check_circle, 'Importar reemplaza todos los datos actuales'),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.warning, 'Asegúrate de hacer una copia de seguridad antes de importar'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Limpiar todos los datos
          Card(
            elevation: 2,
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
              title: Text(
                'Limpiar Todos los Datos',
                style: TextStyle(color: Colors.red.shade700),
              ),
              subtitle: const Text('Eliminar permanentemente toda la información'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _clearAllData(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    
    if (farmProvider.farms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos para exportar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando copia de seguridad...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Exportar datos
      final filePath = await farmProvider.exportAllData();
      
      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al exportar datos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Copia de seguridad - Ganadería',
        text: 'Comparto mi copia de seguridad de la aplicación Ganadería',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo exportado y listo para compartir'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    // Confirmar importación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Datos'),
        content: const Text(
          'Esto reemplazará todos los datos actuales. ¿Estás seguro?',
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
            ),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Seleccionar archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importando datos...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Importar datos
      final success = await farmProvider.importAllData(filePath);

      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar diálogo de carga

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos importados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Cerrar la pantalla de configuración
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al importar datos. Verifica el archivo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
      // El cambio de estado automáticamente redirigirá al login
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Todos los Datos'),
        content: const Text(
          'Esta acción es irreversible. Se eliminarán todos los datos incluyendo:\n\n'
          '• Todas las fincas\n'
          '• Todos los trabajadores\n'
          '• Todos los registros de ganado\n'
          '• Todos los registros de porcicultura\n'
          '• Todos los pagos y préstamos\n\n'
          '¿Estás completamente seguro?',
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
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await farmProvider.clearAllData();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los datos han sido eliminados'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}

