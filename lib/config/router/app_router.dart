import 'package:flutter/material.dart';

// Importar pantallas de menú
import '../../presentation/modules/bovinos/screens/bovino_menu_screen.dart';
import '../../presentation/modules/avicultura/screens/avicultura_menu_screen.dart';
import '../../presentation/modules/ovinos/screens/caprinos_menu_screen.dart';
// TODO: Importar cuando se creen estas pantallas de menú
// import '../../presentation/modules/porcinos/screens/porcicultura_menu_screen.dart';
// import '../../presentation/modules/trabajadores/screens/trabajadores_menu_screen.dart';

// Importar pantallas de lista
import '../../presentation/modules/bovinos/list/bovinos_list_screen.dart';
import '../../presentation/modules/trabajadores/list/trabajadores_list_screen.dart';
import '../../presentation/modules/porcinos/list/cerdos_list_screen.dart';
import '../../presentation/modules/ovinos/list/ovejas_list_screen.dart';
import '../../presentation/modules/avicultura/list/gallinas_list_screen.dart';

// Importar pantallas del módulo Cattle (Clean Architecture)
import '../../features/cattle/presentation/screens/cattle_list_screen.dart';

// Importar pantallas de Fincas
import '../../presentation/modules/farms/screens/farms_list_screen.dart';
import '../../presentation/modules/farms/screens/farm_form_screen.dart';
import '../../domain/entities/farm/farm.dart';

// Importar Dashboard
import '../../presentation/modules/dashboard/screens/dashboard_screen.dart';

// Importar Login
import '../../presentation/screens/auth/login_screen.dart';

/// Router centralizado para la aplicación
/// 
/// Maneja todas las rutas nombradas de la aplicación.
/// Las rutas principales apuntan a los menús intermedios,
/// y las sub-rutas apuntan a las pantallas de lista específicas.
class AppRouter {
  /// Obtiene el farmId de los argumentos
  static String? _getFarmId(BuildContext context, Object? arguments) {
    // Intentar obtener farmId de los argumentos
    if (arguments is Map<String, dynamic> && arguments['farmId'] != null) {
      return arguments['farmId'] as String;
    }
    
    // Si no está en los argumentos, retornar null
    // TODO: Implementar lógica alternativa para obtener farmId si es necesario
    return null;
  }

  /// Genera las rutas de la aplicación
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    // Función helper para crear rutas con farmId
    Route<dynamic> buildRoute(Widget Function(String farmId) builder) {
      return MaterialPageRoute(
        builder: (context) {
          final farmId = _getFarmId(context, arguments);
          if (farmId == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('No se pudo obtener el ID de la finca'),
              ),
            );
          }
          return builder(farmId);
        },
        settings: settings,
      );
    }

    switch (routeName) {
      // ========== RUTA RAÍZ (LOGIN) ==========
      
      case '/':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      // ========== RUTAS PRINCIPALES (MENÚS) ==========
      
      case '/bovinos':
        return buildRoute((farmId) => BovinoMenuScreen(farmId: farmId));

      case '/avicultura':
        return buildRoute((farmId) => AviculturaMenuScreen(farmId: farmId));

      case '/porcinos':
        // TODO: Reemplazar cuando se cree PorciculturaMenuScreen
        // return buildRoute((farmId) => PorciculturaMenuScreen(farmId: farmId));
        // Por ahora, redirigir a la lista directamente
        return buildRoute((farmId) => CerdosListScreen(farmId: farmId));

      case '/ovinos':
        // TODO: Reemplazar cuando se cree CaprinosMenuScreen
        // return buildRoute((farmId) => CaprinosMenuScreen(farmId: farmId));
        // Por ahora, redirigir a la lista directamente
        return buildRoute((farmId) => OvejasListScreen(farmId: farmId));

      case '/trabajadores':
        // TODO: Reemplazar cuando se cree TrabajadoresMenuScreen
        // return buildRoute((farmId) => TrabajadoresMenuScreen(farmId: farmId));
        // Por ahora, redirigir a la lista directamente
        return buildRoute((farmId) => TrabajadoresListScreen(farmId: farmId));

      // ========== RUTAS DE LISTAS ==========

      case '/bovinos/list':
        return buildRoute((farmId) => BovinosListScreen(farmId: farmId));

      // Nueva ruta para el módulo Cattle con Clean Architecture
      case '/cattle/list':
        return buildRoute((farmId) => CattleListScreen(farmId: farmId));

      case '/trabajadores/list':
        return buildRoute((farmId) => TrabajadoresListScreen(farmId: farmId));

      case '/porcinos/list':
        return buildRoute((farmId) => CerdosListScreen(farmId: farmId));

      case '/ovinos/list':
        return buildRoute((farmId) => OvejasListScreen(farmId: farmId));

      // ========== RUTAS DE AVICULTURA ==========
      // Por ahora, ambas rutas apuntan a la lista genérica de gallinas
      // hasta que se separe la lógica de engorde y ponedoras

      case '/avicultura/engorde/list':
        return buildRoute((farmId) => GallinasListScreen(farmId: farmId));

      case '/avicultura/ponedoras/list':
        return buildRoute((farmId) => GallinasListScreen(farmId: farmId));

      // Ruta genérica de avicultura (por compatibilidad)
      case '/avicultura/list':
        return buildRoute((farmId) => GallinasListScreen(farmId: farmId));

      // ========== RUTA DE DASHBOARD ==========
      
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) {
            // Extraer el farmId de los argumentos
            if (arguments is Map<String, dynamic> && arguments['farmId'] != null) {
              final farmId = arguments['farmId'] as String;
              return DashboardScreen(farmId: farmId);
            }
            // Si no se proporciona el farmId, mostrar error
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('No se proporcionó el ID de la finca'),
              ),
            );
          },
          settings: settings,
        );

      // ========== RUTAS DE FINCAS ==========
      
      case '/farms':
        return MaterialPageRoute(
          builder: (_) => const FarmsListScreen(),
          settings: settings,
        );

      case '/farms/create':
        return MaterialPageRoute(
          builder: (_) => const FarmFormScreen(),
          settings: settings,
        );

      case '/farms/edit':
        return MaterialPageRoute(
          builder: (_) {
            // Extraer el objeto Farm de los argumentos
            if (arguments is Map<String, dynamic> && arguments['farm'] != null) {
              final farm = arguments['farm'] as Farm;
              return FarmFormScreen(farm: farm);
            }
            // Si no se proporciona la finca, mostrar error
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('No se proporcionó la finca para editar'),
              ),
            );
          },
          settings: settings,
        );

      default:
        return null;
    }
  }
}

