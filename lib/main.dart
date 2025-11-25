import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Providers existentes (mantener compatibilidad)
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';

// Nuevos providers y tema
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart' as di;

// Auth - Cubit y Estados
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/cubits/auth/auth_state.dart';

// Screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/modules/dashboard/screens/dashboard_screen.dart';

// Router
import 'config/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
    // Continuar aunque Firebase falle para mostrar la UI
  }
  
  // Inicializar Dependency Injection
  try {
    await di.DependencyInjection.init();
  } catch (e) {
    debugPrint('Error inicializando Dependency Injection: $e');
  }
  
  // Inicializar ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  
  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const MyApp({
    super.key,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers existentes
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        // Nuevo ThemeProvider
        ChangeNotifierProvider.value(value: themeProvider),
        // AuthService como Provider (si se necesita acceso desde widgets)
        Provider.value(value: di.DependencyInjection.authService),
      ],
      child: MultiBlocProvider(
        providers: [
          // AuthCubit - verifica el estado de autenticación al iniciar
          BlocProvider<AuthCubit>(
            create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
          ),
        ],
        child: const AppWithAuthSync(),
      ),
    );
  }
}

class AppWithAuthSync extends StatefulWidget {
  const AppWithAuthSync({super.key});

  @override
  State<AppWithAuthSync> createState() => _AppWithAuthSyncState();
}

class _AppWithAuthSyncState extends State<AppWithAuthSync> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Sincronizar userId inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserId();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Actualizar tema cuando cambia el modo del sistema
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.updateSystemTheme();
    }
  }

  void _syncUserId() {
    if (!mounted) return;
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      farmProvider.setUserId(userId);
    } catch (e) {
      debugPrint('Error sincronizando userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, FarmProvider, ThemeProvider>(
      builder: (context, authProvider, farmProvider, themeProvider, child) {
        // Sincronizar userId cuando cambie el usuario
        final currentUserId = authProvider.user?.uid;
        if (farmProvider.userId != currentUserId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                farmProvider.setUserId(currentUserId);
              } catch (e) {
                debugPrint('Error actualizando userId: $e');
              }
            }
          });
        }

        // Obtener color primario de la finca actual o usar verde por defecto
        final primaryColor = farmProvider.currentFarm?.primaryColor ?? 
            const Color(0xFF4CAF50);
        
        // Obtener tema según el modo seleccionado
        final theme = AppTheme.getTheme(
          isDarkMode: themeProvider.isDarkMode,
          primaryColor: primaryColor,
        );

        return MaterialApp(
          title: 'Gestión de Fincas',
          theme: theme,
          darkTheme: AppTheme.darkTheme(primaryColor),
          themeMode: themeProvider.isSystemMode 
              ? ThemeMode.system 
              : (themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light),
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              // Si está autenticado, mostrar Dashboard
              if (authState is Authenticated) {
                return DashboardScreen(farmId: 'default');
              }
              
              // Si no está autenticado o hay error, mostrar Login
              if (authState is Unauthenticated || authState is AuthError) {
                return const LoginScreen();
              }
              
              // Para cualquier otro estado (AuthLoading, AuthInitial), mostrar loading
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
