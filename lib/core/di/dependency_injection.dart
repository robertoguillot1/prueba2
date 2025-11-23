import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core Services
import '../services/photo_service.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../network/connectivity_service.dart';

// Network
import '../../data/datasources/remote/api_client.dart';

// Bovinos - Datasources
import '../../data/datasources/bovinos/bovinos_datasource.dart';
import '../../data/datasources/bovinos/eventos_reproductivos_datasource.dart';
import '../../data/datasources/remote/bovinos/bovinos_remote_datasource.dart';

// Bovinos - Repositories
import '../../domain/repositories/bovinos/bovinos_repository.dart';
import '../../data/repositories_impl/bovinos/bovinos_repository_impl.dart';
import '../../domain/repositories/bovinos/eventos_reproductivos_repository.dart';
import '../../data/repositories_impl/bovinos/eventos_reproductivos_repository_impl.dart';

// Bovinos - UseCases
import '../../domain/usecases/bovinos/get_all_bovinos.dart';
import '../../domain/usecases/bovinos/create_bovino.dart';
import '../../domain/usecases/bovinos/update_bovino.dart';
import '../../domain/usecases/bovinos/delete_bovino.dart';
import '../../domain/usecases/bovinos/get_bovinos_stream.dart';
import '../../domain/usecases/bovinos/get_eventos_reproductivos_by_bovino.dart';
import '../../domain/usecases/bovinos/create_evento_reproductivo.dart';
import '../../domain/usecases/bovinos/registrar_parto_con_cria.dart';

// Porcinos - Datasources
import '../../data/datasources/porcinos/cerdos_datasource.dart';
import '../../data/datasources/remote/porcinos/porcinos_remote_datasource.dart';

// Porcinos - Repositories
import '../../domain/repositories/porcinos/cerdos_repository.dart';
import '../../data/repositories_impl/porcinos/cerdos_repository_impl.dart';

// Porcinos - UseCases
import '../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../domain/usecases/porcinos/create_cerdo.dart';
import '../../domain/usecases/porcinos/update_cerdo.dart';
import '../../domain/usecases/porcinos/delete_cerdo.dart';
import '../../domain/usecases/porcinos/get_cerdos_stream.dart';

// Ovinos - Datasources
import '../../data/datasources/ovinos/ovejas_datasource.dart';
import '../../data/datasources/remote/ovinos/ovejas_remote_datasource.dart';

// Ovinos - Repositories
import '../../domain/repositories/ovinos/ovejas_repository.dart';
import '../../data/repositories_impl/ovinos/ovejas_repository_impl.dart';

// Ovinos - UseCases
import '../../domain/usecases/ovinos/get_all_ovejas.dart';
import '../../domain/usecases/ovinos/get_oveja_by_id.dart';
import '../../domain/usecases/ovinos/create_oveja.dart';
import '../../domain/usecases/ovinos/update_oveja.dart';
import '../../domain/usecases/ovinos/delete_oveja.dart';
import '../../domain/usecases/ovinos/search_ovejas.dart';
import '../../domain/usecases/ovinos/get_ovejas_stream.dart';

// Avicultura - Datasources
import '../../data/datasources/avicultura/gallinas_datasource.dart';
import '../../data/datasources/remote/avicultura/avicultura_remote_datasource.dart';

// Avicultura - Repositories
import '../../domain/repositories/avicultura/gallinas_repository.dart';
import '../../data/repositories_impl/avicultura/gallinas_repository_impl.dart';

// Avicultura - UseCases
import '../../domain/usecases/avicultura/get_all_gallinas.dart';
import '../../domain/usecases/avicultura/create_gallina.dart';
import '../../domain/usecases/avicultura/get_gallinas_stream.dart';

// Trabajadores - Datasources
import '../../data/datasources/trabajadores/trabajadores_datasource.dart';
import '../../data/datasources/remote/trabajadores/trabajadores_remote_datasource.dart';

// Trabajadores - Repositories
import '../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../data/repositories_impl/trabajadores/trabajadores_repository_impl.dart';

// Trabajadores - UseCases
import '../../domain/usecases/trabajadores/get_all_trabajadores.dart';
import '../../domain/usecases/trabajadores/create_trabajador.dart';
import '../../domain/usecases/trabajadores/update_trabajador.dart';
import '../../domain/usecases/trabajadores/delete_trabajador.dart';
import '../../domain/usecases/trabajadores/get_trabajadores_activos.dart';
import '../../domain/usecases/trabajadores/get_trabajadores_stream.dart';

// ViewModels
import '../../presentation/modules/bovinos/viewmodels/bovinos_viewmodel.dart';
import '../../presentation/modules/porcinos/viewmodels/cerdos_viewmodel.dart';
import '../../presentation/modules/ovinos/viewmodels/ovejas_viewmodel.dart';
import '../../presentation/modules/avicultura/viewmodels/gallinas_viewmodel.dart';
import '../../presentation/modules/trabajadores/viewmodels/trabajadores_viewmodel.dart';

// Cubits
import '../../presentation/modules/dashboard/cubits/dashboard_cubit.dart';
import '../../presentation/modules/bovinos/details/cubits/bovino_partos_cubit.dart';
import '../../presentation/modules/bovinos/details/cubits/bovino_descendencia_cubit.dart';

final sl = GetIt.instance;

/// Clase para la inyección de dependencias usando GetIt
class DependencyInjection {
  /// Inicializa todas las dependencias
  static Future<void> init() async {
    // ========== 1. CORE & SERVICIOS EXTERNOS (Singletons) ==========
    
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(sharedPreferences);

    // Connectivity (connectivity_plus)
    sl.registerSingleton<Connectivity>(Connectivity());

    // ImagePicker
    sl.registerSingleton<ImagePicker>(ImagePicker());

    // Firebase Firestore
    sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

    // ConnectivityService
    sl.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(),
    );

    // PhotoService
    sl.registerLazySingleton<PhotoService>(
      () => PhotoService(),
    );

    // ReportService
    sl.registerLazySingleton<ReportService>(
      () => ReportService(),
    );

    // ApiClient
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(),
    );

    // AuthService
    sl.registerLazySingleton<AuthService>(
      () => AuthService(
        apiClient: sl(),
        prefs: sl(),
      ),
    );

    // ========== 2. DATASOURCES (LazySingleton) ==========

    // Bovinos - Local DataSource
    sl.registerLazySingleton<BovinosDataSource>(
      () => BovinosDataSourceImpl(sl()),
    );

    // Bovinos - Remote DataSource
    sl.registerLazySingleton<BovinosRemoteDataSource>(
      () => BovinosRemoteDataSourceImpl(sl()),
    );

    // Bovinos - Eventos Reproductivos DataSource
    sl.registerLazySingleton<EventosReproductivosDataSource>(
      () => EventosReproductivosDataSourceImpl(sl()),
    );

    // Porcinos - Local DataSource
    sl.registerLazySingleton<CerdosDataSource>(
      () => CerdosDataSourceImpl(sl()),
    );

    // Porcinos - Remote DataSource
    sl.registerLazySingleton<PorcinosRemoteDataSource>(
      () => PorcinosRemoteDataSourceImpl(sl()),
    );

    // Ovinos - Local DataSource
    sl.registerLazySingleton<OvejasDataSource>(
      () => OvejasDataSourceImpl(sl()),
    );

    // Ovinos - Remote DataSource
    sl.registerLazySingleton<OvejasRemoteDataSource>(
      () => OvejasRemoteDataSource(sl()),
    );

    // Avicultura - Local DataSource
    sl.registerLazySingleton<GallinasDataSource>(
      () => GallinasDataSourceImpl(sl()),
    );

    // Avicultura - Remote DataSource
    sl.registerLazySingleton<AviculturaRemoteDataSource>(
      () => AviculturaRemoteDataSourceImpl(sl()),
    );

    // Trabajadores - Local DataSource
    sl.registerLazySingleton<TrabajadoresDataSource>(
      () => TrabajadoresDataSourceImpl(sl()),
    );

    // Trabajadores - Remote DataSource
    sl.registerLazySingleton<TrabajadoresRemoteDataSource>(
      () => TrabajadoresRemoteDataSourceImpl(sl()),
    );

    // ========== 3. REPOSITORIES (LazySingleton) ==========

    // Bovinos Repository
    sl.registerLazySingleton<BovinosRepository>(
      () => BovinosRepositoryImpl(sl<BovinosDataSource>()),
    );

    // Bovinos - Eventos Reproductivos Repository
    sl.registerLazySingleton<EventosReproductivosRepository>(
      () => EventosReproductivosRepositoryImpl(sl()),
    );

    // Porcinos Repository
    sl.registerLazySingleton<CerdosRepository>(
      () => CerdosRepositoryImpl(sl<CerdosDataSource>()),
    );

    // Ovinos Repository
    sl.registerLazySingleton<OvejasRepository>(
      () => OvejasRepositoryImpl(sl<OvejasDataSource>()),
    );

    // Avicultura Repository
    sl.registerLazySingleton<GallinasRepository>(
      () => GallinasRepositoryImpl(sl<GallinasDataSource>()),
    );

    // Trabajadores Repository
    sl.registerLazySingleton<TrabajadoresRepository>(
      () => TrabajadoresRepositoryImpl(sl<TrabajadoresDataSource>()),
    );

    // ========== 4. USE CASES (LazySingleton) ==========

    // Bovinos UseCases
    sl.registerLazySingleton(() => GetAllBovinos(sl()));
    sl.registerLazySingleton(() => CreateBovino(sl()));
    sl.registerLazySingleton(() => UpdateBovino(sl()));
    sl.registerLazySingleton(() => DeleteBovino(sl()));
    // GetEventosReproductivosByBovino se crea en factory methods porque requiere farmId
    sl.registerLazySingleton(() => CreateEventoReproductivo(sl()));
    sl.registerLazySingleton(() => RegistrarPartoConCria(
      eventosRepository: sl(),
      bovinosRepository: sl(),
    ));

    // Porcinos UseCases
    sl.registerLazySingleton(() => GetAllCerdos(sl()));
    sl.registerLazySingleton(() => CreateCerdo(sl()));
    sl.registerLazySingleton(() => UpdateCerdo(sl()));
    sl.registerLazySingleton(() => DeleteCerdo(sl()));

    // Ovinos UseCases
    sl.registerLazySingleton(() => GetAllOvejas(sl()));
    sl.registerLazySingleton(() => GetOvejaById(sl()));
    sl.registerLazySingleton(() => CreateOveja(sl()));
    sl.registerLazySingleton(() => UpdateOveja(sl()));
    sl.registerLazySingleton(() => DeleteOveja(sl()));
    sl.registerLazySingleton(() => SearchOvejas(sl()));

    // Avicultura UseCases
    sl.registerLazySingleton(() => GetAllGallinas(sl()));
    sl.registerLazySingleton(() => CreateGallina(sl()));

    // Trabajadores UseCases
    sl.registerLazySingleton(() => GetAllTrabajadores(sl()));
    sl.registerLazySingleton(() => CreateTrabajador(sl()));
    sl.registerLazySingleton(() => UpdateTrabajador(sl()));
    sl.registerLazySingleton(() => DeleteTrabajador(sl()));
    sl.registerLazySingleton(() => GetTrabajadoresActivos(sl()));

    // ========== 5. VIEWMODELS (Factory) ==========

    // Bovinos ViewModel
    sl.registerFactory(() => BovinosViewModel(
      getAllBovinos: sl(),
      createBovino: sl(),
      updateBovino: sl(),
      deleteBovino: sl(),
    ));

    // Porcinos ViewModel
    sl.registerFactory(() => CerdosViewModel(
      getAllCerdos: sl(),
      createCerdo: sl(),
      updateCerdo: sl(),
      deleteCerdo: sl(),
    ));

    // Ovinos ViewModel
    sl.registerFactory(() => OvejasViewModel(
      getAllOvejas: sl(),
      getOvejaById: sl(),
      createOveja: sl(),
      updateOveja: sl(),
      deleteOveja: sl(),
      searchOvejas: sl(),
    ));

    // Avicultura ViewModel
    sl.registerFactory(() => GallinasViewModel(
      getAllGallinas: sl(),
      createGallina: sl(),
    ));

    // Trabajadores ViewModel
    sl.registerFactory(() => TrabajadoresViewModel(
      getAllTrabajadores: sl(),
      createTrabajador: sl(),
      updateTrabajador: sl(),
      deleteTrabajador: sl(),
      getTrabajadoresActivos: sl(),
    ));
  }

  // ========== 6. MÉTODOS FACTORY ESPECIALES (Static Methods) ==========

  /// Crea un DashboardCubit con el farmId especificado
  static DashboardCubit createDashboardCubit(String farmId) {
    return DashboardCubit(
      getBovinosStream: GetBovinosStream(
        repository: sl<BovinosRepository>(),
        farmId: farmId,
      ),
      getCerdosStream: GetCerdosStream(
        repository: sl<CerdosRepository>(),
        farmId: farmId,
      ),
      getOvejasStream: GetOvejasStream(
        repository: sl<OvejasRepository>(),
        farmId: farmId,
      ),
      getGallinasStream: GetGallinasStream(
        repository: sl<GallinasRepository>(),
        farmId: farmId,
      ),
      getTrabajadoresStream: GetTrabajadoresStream(
        repository: sl<TrabajadoresRepository>(),
        farmId: farmId,
      ),
    );
  }

  /// Crea un BovinoPartosCubit para un bovino específico
  static BovinoPartosCubit createBovinoPartosCubit(
    String bovinoId,
    String farmId,
  ) {
    final cubit = BovinoPartosCubit(
      getEventos: GetEventosReproductivosByBovino(
        repository: sl<EventosReproductivosRepository>(),
        farmId: farmId,
      ),
    );
    cubit.cargarPartos(bovinoId);
    return cubit;
  }

  /// Crea un BovinoDescendenciaCubit para un bovino específico
  static BovinoDescendenciaCubit createBovinoDescendenciaCubit(
    String bovinoId,
    String farmId,
  ) {
    final cubit = BovinoDescendenciaCubit(
      getBovinos: GetBovinosStream(
        repository: sl<BovinosRepository>(),
        farmId: farmId,
      ),
    );
    cubit.cargarDescendencia(bovinoId);
    return cubit;
  }

  // ========== GETTERS PARA ACCESO DIRECTO ==========

  /// Obtiene el AuthService
  static AuthService get authService => sl<AuthService>();

  /// Obtiene el PhotoService
  static PhotoService get photoService => sl<PhotoService>();

  /// Obtiene el ConnectivityService
  static ConnectivityService get connectivityService =>
      sl<ConnectivityService>();

  /// Obtiene el BovinosRepository
  static BovinosRepository get bovinosRepository => sl<BovinosRepository>();

  /// Factory methods para ViewModels (compatibilidad con código existente)
  static BovinosViewModel createBovinosViewModel() => sl<BovinosViewModel>();
  static CerdosViewModel createCerdosViewModel() => sl<CerdosViewModel>();
  static OvejasViewModel createOvejasViewModel() => sl<OvejasViewModel>();
  static GallinasViewModel createGallinasViewModel() => sl<GallinasViewModel>();
  static TrabajadoresViewModel createTrabajadoresViewModel() =>
      sl<TrabajadoresViewModel>();
}
