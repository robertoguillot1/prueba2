import 'package:flutter/material.dart';

// Auth screens
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/sign_up_screen.dart';

// Farms screens
import '../../presentation/modules/farms/screens/farms_list_screen.dart';
import '../../presentation/modules/farms/screens/farm_form_screen.dart';

// Dashboard
import '../../presentation/modules/dashboard/screens/dashboard_screen.dart';

// Bovinos screens
import '../../presentation/modules/bovinos/screens/bovino_menu_screen.dart';
import '../../presentation/modules/bovinos/list/bovinos_list_screen.dart';
import '../../presentation/modules/bovinos/screens/bovino_form_screen.dart';

// Cattle (Clean Architecture)
import '../../features/cattle/presentation/screens/cattle_list_screen.dart';

// Other modules
import '../../presentation/modules/avicultura/screens/avicultura_menu_screen.dart';
import '../../presentation/modules/ovinos/screens/caprinos_menu_screen.dart';
import '../../presentation/modules/porcinos/list/cerdos_list_screen.dart';
import '../../presentation/modules/ovinos/list/ovejas_list_screen.dart';
import '../../presentation/modules/avicultura/list/gallinas_list_screen.dart';
import '../../presentation/modules/trabajadores/list/trabajadores_list_screen.dart';

// Entities
import '../../domain/entities/farm/farm.dart';
import '../../features/cattle/domain/entities/bovine_entity.dart';

/// Router centralizado para la aplicación con logging mejorado
class AppRouter {
  // Constantes de rutas
  static const String login = '/';
  static const String signUp = '/signup';
  static const String farms = '/farms';
  static const String farmCreate = '/farms/create';
  static const String farmEdit = '/farms/edit';
  static const String dashboard = '/dashboard';
  
  /// Obtiene el mapa de rutas básicas (sin argumentos)
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      signUp: (context) => const SignUpScreen(),
      farms: (context) => const FarmsListScreen(),
      farmCreate: (context) => const FarmFormScreen(),
      // Dashboard requiere farmId, manejado por onGenerateRoute
      // farmEdit requiere Farm object, manejado por onGenerateRoute
    };
  }
  
  /// Genera las rutas de la aplicación con logging mejorado (para rutas con argumentos)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    print('🔵 [AppRouter] Navegando a: ${settings.name}');
    print('🔵 [AppRouter] Argumentos: ${settings.arguments}');
    
    final routeName = settings.name;
    final arguments = settings.arguments;

    // Helper para extraer farmId
    String? _getFarmId() {
      if (arguments is Map<String, dynamic> && arguments['farmId'] != null) {
        return arguments['farmId'] as String;
      }
      return null;
    }

    // Helper para rutas con farmId requerido
    MaterialPageRoute _buildFarmRoute(Widget Function(String) builder) {
      return MaterialPageRoute(
        builder: (_) {
          final farmId = _getFarmId();
          if (farmId == null) {
            print('❌ [AppRouter] Error: farmId no proporcionado para $routeName');
            return _errorScreen('No se proporcionó el ID de la finca');
          }
          print('✅ [AppRouter] Navegando a $routeName con farmId: $farmId');
          return builder(farmId);
        },
        settings: settings,
      );
    }

    switch (routeName) {
      // ========== AUTH ==========
      case '/':
      case '/login':
        print('✅ [AppRouter] Navegando a Login');
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case '/signup':
        print('✅ [AppRouter] Navegando a SignUp');
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      // ========== FARMS ==========
      case '/farms':
        print('✅ [AppRouter] Navegando a FarmsList');
        return MaterialPageRoute(
          builder: (_) => const FarmsListScreen(),
          settings: settings,
        );

      case '/farms/create':
        print('✅ [AppRouter] Navegando a FarmForm (create)');
        return MaterialPageRoute(
          builder: (_) => const FarmFormScreen(),
          settings: settings,
        );

      case '/farms/edit':
        final farm = (arguments is Map<String, dynamic>) ? arguments['farm'] as Farm? : null;
        if (farm == null) {
          print('❌ [AppRouter] Error: farm no proporcionado para edición');
          return MaterialPageRoute(
            builder: (_) => _errorScreen('No se proporcionó la finca para editar'),
            settings: settings,
          );
        }
        print('✅ [AppRouter] Navegando a FarmForm (edit) - farmId: ${farm.id}');
        return MaterialPageRoute(
          builder: (_) => FarmFormScreen(farm: farm),
          settings: settings,
        );

      // ========== DASHBOARD ==========
      case '/dashboard':
        final farmId = _getFarmId();
        if (farmId == null) {
          print('❌ [AppRouter] Error: farmId no proporcionado para Dashboard');
          return MaterialPageRoute(
            builder: (_) => _errorScreen('No se proporcionó el ID de la finca para el Dashboard'),
            settings: settings,
          );
        }
        print('✅ [AppRouter] Navegando a Dashboard con farmId: $farmId');
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(farmId: farmId),
          settings: settings,
        );

      // ========== BOVINOS ==========
      case '/bovinos':
        return _buildFarmRoute((farmId) => BovinoMenuScreen(farmId: farmId));

      case '/bovinos/list':
        return _buildFarmRoute((farmId) => BovinosListScreen(farmId: farmId));

      case '/cattle/list':
        return _buildFarmRoute((farmId) => CattleListScreen(farmId: farmId));

      case '/bovinos/form':
        final farmId = _getFarmId();
        if (farmId == null) {
          print('❌ [AppRouter] Error: farmId no proporcionado para BovinoForm');
          return MaterialPageRoute(
            builder: (_) => _errorScreen('No se proporcionó el ID de la finca'),
            settings: settings,
          );
        }
        final argsMap = arguments as Map<String, dynamic>?;
        final bovine = argsMap?['bovine'] as BovineEntity?;
        final initialMotherId = argsMap?['initialMotherId'] as String?;
        final initialBirthDate = argsMap?['initialBirthDate'] as DateTime?;
        
        print('✅ [AppRouter] Navegando a BovinoForm - farmId: $farmId, isEdit: ${bovine != null}');
        return MaterialPageRoute(
          builder: (_) => BovinoFormScreen(
            farmId: farmId,
            bovine: bovine,
            initialMotherId: initialMotherId,
            initialBirthDate: initialBirthDate,
          ),
          settings: settings,
        );

      // ========== OTROS MÓDULOS ==========
      case '/avicultura':
        return _buildFarmRoute((farmId) => AviculturaMenuScreen(farmId: farmId));

      case '/avicultura/list':
      case '/avicultura/engorde/list':
      case '/avicultura/ponedoras/list':
        return _buildFarmRoute((farmId) => GallinasListScreen(farmId: farmId));

      case '/porcinos':
      case '/porcinos/list':
        return _buildFarmRoute((farmId) => CerdosListScreen(farmId: farmId));

      case '/ovinos':
      case '/ovinos/list':
        return _buildFarmRoute((farmId) => OvejasListScreen(farmId: farmId));

      case '/trabajadores':
      case '/trabajadores/list':
        return _buildFarmRoute((farmId) => TrabajadoresListScreen(farmId: farmId));

      default:
        print('❌ [AppRouter] Ruta no encontrada: $routeName');
        return null;
    }
  }

  /// Pantalla de error genérica
  static Widget _errorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error de Navegación'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Esta función no funcionará aquí, pero es para ilustrar
                  print('Usuario intentó volver');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

