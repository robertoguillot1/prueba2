import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
    // Continuar aunque Firebase falle para mostrar la UI
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
      ],
      child: const AppWithAuthSync(),
    );
  }
}

class AppWithAuthSync extends StatefulWidget {
  const AppWithAuthSync({super.key});

  @override
  State<AppWithAuthSync> createState() => _AppWithAuthSyncState();
}

class _AppWithAuthSyncState extends State<AppWithAuthSync> {
  @override
  void initState() {
    super.initState();
    // Sincronizar userId inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserId();
    });
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
    return Consumer2<AuthProvider, FarmProvider>(
      builder: (context, authProvider, farmProvider, child) {
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

        return MaterialApp(
          title: 'Gestión de Fincas',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: farmProvider.currentFarm?.primaryColor ?? Colors.green,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: authProvider.isAuthenticated
              ? const MainNavigationScreen()
              : const LoginScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}