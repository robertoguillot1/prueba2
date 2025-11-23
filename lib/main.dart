import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// TODO: Descomentar cuando DependencyInjection esté implementado
// import 'core/di/dependency_injection.dart' as di;
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
  
  // TODO: Inicializar inyección de dependencias cuando esté implementado
  // try {
  //   await di.DependencyInjection.init();
  // } catch (e) {
  //   debugPrint('Error inicializando DependencyInjection: $e');
  // }
  
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
      // TODO: Descomentar cuando DependencyInjection.createDashboardCubit esté implementado
      // home: BlocProvider(
      //   create: (_) => di.DependencyInjection.createDashboardCubit('default'),
      //   child: const DashboardScreen(farmId: 'default'),
      // ),
      home: const Scaffold(
        appBar: AppBar(title: Text('Configuración Requerida')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'DependencyInjection no está implementado.\n\n'
              'Por favor, implementa lib/core/di/dependency_injection.dart con:\n'
              '- Método estático init()\n'
              '- Método estático createDashboardCubit(String farmId)\n'
              '- Otros métodos factory necesarios',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
