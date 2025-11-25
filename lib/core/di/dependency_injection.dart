import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/ovinos/ovejas_datasource.dart';
import '../../data/datasources/bovinos/bovinos_datasource.dart';
import '../../data/datasources/porcinos/cerdos_datasource.dart';
import '../../data/datasources/trabajadores/trabajadores_datasource.dart';
import '../../data/datasources/avicultura/gallinas_datasource.dart';
import '../../data/repositories_impl/ovinos/ovejas_repository_impl.dart';
import '../../data/repositories_impl/bovinos/bovinos_repository_impl.dart';
import '../../data/repositories_impl/porcinos/cerdos_repository_impl.dart';
import '../../data/repositories_impl/trabajadores/trabajadores_repository_impl.dart';
import '../../data/repositories_impl/avicultura/gallinas_repository_impl.dart';
import '../../domain/repositories/ovinos/ovejas_repository.dart';
import '../../domain/repositories/bovinos/bovinos_repository.dart';
import '../../domain/repositories/porcinos/cerdos_repository.dart';
import '../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../domain/repositories/avicultura/gallinas_repository.dart';
import '../../domain/usecases/ovinos/get_all_ovejas.dart';
import '../../domain/usecases/ovinos/get_oveja_by_id.dart';
import '../../domain/usecases/ovinos/create_oveja.dart';
import '../../domain/usecases/ovinos/update_oveja.dart';
import '../../domain/usecases/ovinos/delete_oveja.dart';
import '../../domain/usecases/ovinos/search_ovejas.dart';
import '../../domain/usecases/bovinos/get_all_bovinos.dart';
import '../../domain/usecases/bovinos/create_bovino.dart';
import '../../domain/usecases/bovinos/update_bovino.dart';
import '../../domain/usecases/bovinos/delete_bovino.dart';
import '../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../domain/usecases/porcinos/create_cerdo.dart';
import '../../domain/usecases/porcinos/update_cerdo.dart';
import '../../domain/usecases/porcinos/delete_cerdo.dart';
import '../../domain/usecases/trabajadores/get_all_trabajadores.dart';
import '../../domain/usecases/trabajadores/create_trabajador.dart';
import '../../domain/usecases/trabajadores/update_trabajador.dart';
import '../../domain/usecases/trabajadores/delete_trabajador.dart';
import '../../domain/usecases/trabajadores/get_trabajadores_activos.dart';
import '../../domain/usecases/avicultura/get_all_gallinas.dart';
import '../../domain/usecases/avicultura/create_gallina.dart';
import '../../presentation/modules/ovinos/viewmodels/ovejas_viewmodel.dart';
import '../../presentation/modules/bovinos/viewmodels/bovinos_viewmodel.dart';
import '../../presentation/modules/porcinos/viewmodels/cerdos_viewmodel.dart';
import '../../presentation/modules/trabajadores/viewmodels/trabajadores_viewmodel.dart';
import '../../presentation/modules/avicultura/viewmodels/gallinas_viewmodel.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/remote/ovinos/ovinos_remote_datasource.dart';
import '../../data/datasources/remote/bovinos/bovinos_remote_datasource.dart';
import '../../data/datasources/remote/porcinos/porcinos_remote_datasource.dart';
import '../../data/datasources/remote/avicultura/avicultura_remote_datasource.dart';
import '../../data/datasources/remote/trabajadores/trabajadores_remote_datasource.dart';
import '../../data/datasources/local/ovinos/ovinos_local_datasource.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/sync/sync_manager.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/photo_service.dart';
import '../../core/services/report_service.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in.dart';
import '../../domain/usecases/auth/sign_up.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/bovinos/get_bovinos_stream.dart';
import '../../domain/usecases/porcinos/get_cerdos_stream.dart';
import '../../domain/usecases/ovinos/get_ovejas_stream.dart';
import '../../domain/usecases/avicultura/get_gallinas_stream.dart';
import '../../domain/usecases/trabajadores/get_trabajadores_stream.dart';
import '../../domain/repositories/farm_repository.dart';
import '../../domain/usecases/farm/get_farms_stream.dart';
import '../../domain/usecases/farm/create_farm.dart';
import '../../domain/usecases/farm/update_farm.dart';
import '../../domain/usecases/farm/delete_farm.dart';
import '../../domain/usecases/farm/set_current_farm.dart';
import '../../data/datasources/remote/farm/farm_remote_datasource.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../presentation/cubits/auth/auth_cubit.dart';
import '../../presentation/modules/dashboard/cubits/dashboard_cubit.dart';
import '../../presentation/modules/farms/cubits/farms_cubit.dart';
import '../../presentation/modules/farms/cubits/farm_form_cubit.dart';
// Cattle Module (Clean Architecture)
import '../../features/cattle/data/datasources/cattle_remote_datasource.dart';
import '../../features/cattle/data/repositories/cattle_repository_impl.dart';
import '../../features/cattle/domain/repositories/cattle_repository.dart';
import '../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../../features/cattle/domain/usecases/get_bovine.dart';
import '../../features/cattle/domain/usecases/add_bovine.dart';
import '../../features/cattle/domain/usecases/update_bovine.dart';
import '../../features/cattle/domain/usecases/delete_bovine.dart';
import '../../features/cattle/presentation/cubit/cattle_cubit.dart';

/// Instancia global de GetIt para inyección de dependencias
final GetIt sl = GetIt.instance;

/// Clase para inyección de dependencias (Dependency Injection)
class DependencyInjection {
  static SharedPreferences? _sharedPreferences;
  
  // API Client
  static ApiClient? _apiClient;
  
  // Remote Data Sources
  static OvinosRemoteDataSource? _ovinosRemoteDataSource;
  static BovinosRemoteDataSource? _bovinosRemoteDataSource;
  static PorcinosRemoteDataSource? _porcinosRemoteDataSource;
  static AviculturaRemoteDataSource? _aviculturaRemoteDataSource;
  static TrabajadoresRemoteDataSource? _trabajadoresRemoteDataSource;
  
  // Local Data Sources
  static OvinosLocalDataSource? _ovinosLocalDataSource;
  
  // Services
  static ConnectivityService? _connectivityService;
  static SyncManager? _syncManager;
  static AuthService? _authService;
  static PhotoService? _photoService;
  static ReportService? _reportService;
  
  // Data Sources
  static OvejasDataSource? _ovejasDataSource;
  static BovinosDataSource? _bovinosDataSource;
  static CerdosDataSource? _cerdosDataSource;
  static TrabajadoresDataSource? _trabajadoresDataSource;
  static GallinasDataSource? _gallinasDataSource;
  
  // Repositories
  static OvejasRepository? _ovejasRepository;
  static BovinosRepository? _bovinosRepository;
  static CerdosRepository? _cerdosRepository;
  static TrabajadoresRepository? _trabajadoresRepository;
  static GallinasRepository? _gallinasRepository;
  
  /// Inicializa todas las dependencias
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    
    // Inicializar base de datos
    await AppDatabase.initialize();
    try {
      await AppDatabase.database;
    } catch (e) {
      debugPrint('Error inicializando base de datos: $e');
      // Continuar sin base de datos si falla (modo web sin soporte)
    }
    
    // Inicializar API Client
    _apiClient = ApiClient();
    
    // Inicializar Connectivity Service
    _connectivityService = ConnectivityService();
    
    // Inicializar Remote Data Sources
    _ovinosRemoteDataSource = OvinosRemoteDataSourceImpl(_apiClient!);
    _bovinosRemoteDataSource = BovinosRemoteDataSourceImpl(_apiClient!);
    _porcinosRemoteDataSource = PorcinosRemoteDataSourceImpl(_apiClient!);
    _aviculturaRemoteDataSource = AviculturaRemoteDataSourceImpl(_apiClient!);
    _trabajadoresRemoteDataSource = TrabajadoresRemoteDataSourceImpl(_apiClient!);
    
    // Inicializar Local Data Sources
    _ovinosLocalDataSource = OvinosLocalDataSourceImpl();
    
    // Inicializar Sync Manager
    _syncManager = SyncManager(
      connectivityService: _connectivityService!,
      apiClient: _apiClient!,
    );
    
    // Inicializar Services
    _authService = AuthService(
      apiClient: _apiClient!,
      prefs: _sharedPreferences!,
    );
    _photoService = PhotoService();
    _reportService = ReportService();
    
    // Restaurar sesión si existe
    if (await _authService!.hasSession()) {
      final token = _authService!.getToken();
      if (token != null) {
        _apiClient!.setAuthToken(token);
      }
    }
    
    // Inicializar Data Sources locales (legacy)
    _ovejasDataSource = OvejasDataSourceImpl(_sharedPreferences!);
    _bovinosDataSource = BovinosDataSourceImpl(_sharedPreferences!);
    _cerdosDataSource = CerdosDataSourceImpl(_sharedPreferences!);
    _trabajadoresDataSource = TrabajadoresDataSourceImpl(_sharedPreferences!);
    _gallinasDataSource = GallinasDataSourceImpl(_sharedPreferences!);
    
    // Inicializar Repositories
    _ovejasRepository = OvejasRepositoryImpl(_ovejasDataSource!);
    _bovinosRepository = BovinosRepositoryImpl(_bovinosDataSource!);
    _cerdosRepository = CerdosRepositoryImpl(_cerdosDataSource!);
    _trabajadoresRepository = TrabajadoresRepositoryImpl(_trabajadoresDataSource!);
    _gallinasRepository = GallinasRepositoryImpl(_gallinasDataSource!);
    
    // ========== REGISTRO CON GET_IT ==========
    // CORE - Firebase Auth
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    
    // AUTH - Repositorio
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(firebaseAuth: sl<FirebaseAuth>()),
    );
    
    // AUTH - Casos de Uso
    sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SignIn(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SignUp(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
    
    // AUTH - Cubit (Factory para crear nueva instancia cada vez)
    sl.registerFactory(
      () => AuthCubit(
        getCurrentUser: sl<GetCurrentUser>(),
        signInUseCase: sl<SignIn>(),
        signUpUseCase: sl<SignUp>(),
        signOutUseCase: sl<SignOut>(),
      ),
    );

    // FARMS - Data Source
    sl.registerLazySingleton<FarmRemoteDataSource>(
      () => FarmFirebaseDataSource(),
    );

    // FARMS - Repository
    sl.registerLazySingleton<FarmRepository>(
      () => FarmRepositoryImpl(
        remoteDataSource: sl<FarmRemoteDataSource>(),
      ),
    );

    // FARMS - Use Cases (no se registran como singleton porque necesitan userId)
    // Se crearán directamente en los factory methods

    // CATTLE - Data Source
    sl.registerLazySingleton<CattleRemoteDataSource>(
      () => CattleRemoteDataSourceImpl(),
    );

    // CATTLE - Repository
    sl.registerLazySingleton<CattleRepository>(
      () => CattleRepositoryImpl(
        remoteDataSource: sl<CattleRemoteDataSource>(),
      ),
    );

    // CATTLE - Use Cases
    sl.registerLazySingleton(() => GetCattleList(sl<CattleRepository>()));
    sl.registerLazySingleton(() => GetBovine(sl<CattleRepository>()));
    sl.registerLazySingleton(() => AddBovine(sl<CattleRepository>()));
    sl.registerLazySingleton(() => UpdateBovine(sl<CattleRepository>()));
    sl.registerLazySingleton(() => DeleteBovine(sl<CattleRepository>()));
  }
  
  // Getters para Data Sources
  static OvejasDataSource get ovejasDataSource => _ovejasDataSource!;
  static BovinosDataSource get bovinosDataSource => _bovinosDataSource!;
  static CerdosDataSource get cerdosDataSource => _cerdosDataSource!;
  static TrabajadoresDataSource get trabajadoresDataSource => _trabajadoresDataSource!;
  static GallinasDataSource get gallinasDataSource => _gallinasDataSource!;
  
  // Getters para Repositories
  static OvejasRepository get ovejasRepository => _ovejasRepository!;
  static BovinosRepository get bovinosRepository => _bovinosRepository!;
  static CerdosRepository get cerdosRepository => _cerdosRepository!;
  static TrabajadoresRepository get trabajadoresRepository => _trabajadoresRepository!;
  static GallinasRepository get gallinasRepository => _gallinasRepository!;
  
  // Factory methods para ViewModels
  static OvejasViewModel createOvejasViewModel() {
    return OvejasViewModel(
      getAllOvejas: GetAllOvejas(_ovejasRepository!),
      getOvejaById: GetOvejaById(_ovejasRepository!),
      createOveja: CreateOveja(_ovejasRepository!),
      updateOveja: UpdateOveja(_ovejasRepository!),
      deleteOveja: DeleteOveja(_ovejasRepository!),
      searchOvejas: SearchOvejas(_ovejasRepository!),
    );
  }
  
  static BovinosViewModel createBovinosViewModel() {
    return BovinosViewModel(
      getAllBovinos: GetAllBovinos(_bovinosRepository!),
      createBovino: CreateBovino(_bovinosRepository!),
      updateBovino: UpdateBovino(_bovinosRepository!),
      deleteBovino: DeleteBovino(_bovinosRepository!),
    );
  }
  
  static CerdosViewModel createCerdosViewModel() {
    return CerdosViewModel(
      getAllCerdos: GetAllCerdos(_cerdosRepository!),
      createCerdo: CreateCerdo(_cerdosRepository!),
      updateCerdo: UpdateCerdo(_cerdosRepository!),
      deleteCerdo: DeleteCerdo(_cerdosRepository!),
    );
  }
  
  static TrabajadoresViewModel createTrabajadoresViewModel() {
    return TrabajadoresViewModel(
      getAllTrabajadores: GetAllTrabajadores(_trabajadoresRepository!),
      createTrabajador: CreateTrabajador(_trabajadoresRepository!),
      updateTrabajador: UpdateTrabajador(_trabajadoresRepository!),
      deleteTrabajador: DeleteTrabajador(_trabajadoresRepository!),
      getTrabajadoresActivos: GetTrabajadoresActivos(_trabajadoresRepository!),
    );
  }
  
  static GallinasViewModel createGallinasViewModel() {
    return GallinasViewModel(
      getAllGallinas: GetAllGallinas(_gallinasRepository!),
      createGallina: CreateGallina(_gallinasRepository!),
    );
  }
  
  /// Crea una instancia de FarmsCubit para un usuario
  static FarmsCubit createFarmsCubit(String userId) {
    final farmRepository = sl<FarmRepository>();
    return FarmsCubit(
      getFarmsStream: GetFarmsStream(
        repository: farmRepository,
        userId: userId,
      ),
      deleteFarmUseCase: DeleteFarm(farmRepository),
      setCurrentFarmUseCase: SetCurrentFarm(farmRepository),
      farmRepository: farmRepository,
      userId: userId,
    );
  }

  /// Crea una instancia de FarmFormCubit para un usuario
  static FarmFormCubit createFarmFormCubit(String userId) {
    return FarmFormCubit(
      createFarmUseCase: CreateFarm(sl<FarmRepository>()),
      updateFarmUseCase: UpdateFarm(sl<FarmRepository>()),
      userId: userId,
    );
  }

  /// Crea una instancia de DashboardCubit con todos los streams necesarios
  static DashboardCubit createDashboardCubit(String farmId) {
    return DashboardCubit(
      getBovinosStream: GetBovinosStream(
        repository: _bovinosRepository!,
        farmId: farmId,
      ),
      getCerdosStream: GetCerdosStream(
        repository: _cerdosRepository!,
        farmId: farmId,
      ),
      getOvejasStream: GetOvejasStream(
        repository: _ovejasRepository!,
        farmId: farmId,
      ),
      getGallinasStream: GetGallinasStream(
        repository: _gallinasRepository!,
        farmId: farmId,
      ),
      getTrabajadoresStream: GetTrabajadoresStream(
        repository: _trabajadoresRepository!,
        farmId: farmId,
      ),
    );
  }

  /// Crea una instancia de CattleCubit para una finca específica
  static CattleCubit createCattleCubit() {
    return CattleCubit(
      getCattleListUseCase: sl<GetCattleList>(),
      getBovineUseCase: sl<GetBovine>(),
      addBovineUseCase: sl<AddBovine>(),
      updateBovineUseCase: sl<UpdateBovine>(),
      deleteBovineUseCase: sl<DeleteBovine>(),
      repository: sl<CattleRepository>(),
    );
  }
  
  // Getters para Services
  static AuthService get authService => _authService!;
  static PhotoService get photoService => _photoService!;
  static ReportService get reportService => _reportService!;
  static ConnectivityService get connectivityService => _connectivityService!;
  static SyncManager get syncManager => _syncManager!;
  static ApiClient get apiClient => _apiClient!;
}

