import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/dependency_injection.dart' as di;
import 'config/router/app_router.dart';
import 'presentation/modules/dashboard/screens/dashboard_screen.dart';
import 'presentation/modules/dashboard/cubits/dashboard_cubit.dart';

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
  
  // Inicializar inyección de dependencias
  try {
    await di.DependencyInjection.init();
  } catch (e) {
    debugPrint('Error inicializando DependencyInjection: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Fincas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Usar AppRouter para navegación
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Pantalla temporal: Dashboard con farmId por defecto
      // TODO: Reemplazar con lógica de login/autenticación
      home: BlocProvider(
        create: (_) => di.DependencyInjection.createDashboardCubit('default'),
        child: DashboardScreen(farmId: 'default'),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
