import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../data/datasources/ovinos/ovejas_datasource.dart';
import '../../data/datasources/bovinos/bovinos_datasource.dart';
import '../../data/datasources/bovinos/eventos_reproductivos_datasource.dart';
import '../../data/datasources/porcinos/cerdos_datasource.dart';
import '../../data/datasources/trabajadores/trabajadores_datasource.dart';
import '../../data/datasources/avicultura/gallinas_datasource.dart';
import '../../data/repositories_impl/ovinos/ovejas_repository_impl.dart';
import '../../data/repositories_impl/bovinos/bovinos_repository_impl.dart';
import '../../data/repositories_impl/bovinos/eventos_reproductivos_repository_impl.dart';
import '../../data/repositories_impl/porcinos/cerdos_repository_impl.dart';
import '../../data/repositories_impl/trabajadores/trabajadores_repository_impl.dart';
import '../../data/repositories_impl/avicultura/gallinas_repository_impl.dart';
import '../../domain/repositories/ovinos/ovejas_repository.dart';
import '../../domain/repositories/bovinos/bovinos_repository.dart';
import '../../domain/repositories/bovinos/eventos_reproductivos_repository.dart';
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
import '../../domain/usecases/bovinos/get_eventos_reproductivos_by_bovino.dart';
import '../../domain/usecases/bovinos/get_bovinos_stream.dart';
import '../../domain/usecases/porcinos/get_cerdos_stream.dart';
import '../../domain/usecases/ovinos/get_ovejas_stream.dart';
import '../../domain/usecases/avicultura/get_gallinas_stream.dart';
import '../../domain/usecases/trabajadores/get_trabajadores_stream.dart';
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
import '../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../presentation/modules/ovinos/viewmodels/ovejas_viewmodel.dart';
import '../../presentation/modules/bovinos/viewmodels/bovinos_viewmodel.dart';
import '../../presentation/modules/bovinos/details/cubits/bovino_partos_cubit.dart';
import '../../presentation/modules/bovinos/details/cubits/bovino_descendencia_cubit.dart';
import '../../presentation/modules/dashboard/cubits/dashboard_cubit.dart';
import '../../presentation/modules/porcinos/viewmodels/cerdos_viewmodel.dart';
import '../../presentation/modules/trabajadores/viewmodels/trabajadores_viewmodel.dart';
import '../../presentation/modules/avicultura/viewmodels/gallinas_viewmodel.dart';
import '../../presentation/screens/dashboard/viewmodels/dashboard_viewmodel.dart';
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
  static EventosReproductivosRepository? _eventosReproductivosRepository;
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
    _eventosReproductivosRepository = EventosReproductivosRepositoryImpl(
      EventosReproductivosDataSourceImpl(_sharedPreferences!),
    );
    _cerdosRepository = CerdosRepositoryImpl(_cerdosDataSource!);
    _trabajadoresRepository = TrabajadoresRepositoryImpl(_trabajadoresDataSource!);
    _gallinasRepository = GallinasRepositoryImpl(_gallinasDataSource!);
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
  static EventosReproductivosRepository get eventosReproductivosRepository => _eventosReproductivosRepository!;
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
  
  static DashboardViewModel createDashboardViewModel() {
    return DashboardViewModel(
      getAllBovinos: GetAllBovinos(_bovinosRepository!),
      getAllCerdos: GetAllCerdos(_cerdosRepository!),
      getAllOvejas: GetAllOvejas(_ovejasRepository!),
      getAllGallinas: GetAllGallinas(_gallinasRepository!),
      getAllTrabajadores: GetAllTrabajadores(_trabajadoresRepository!),
    );
  }
  
  // Getters para Services
  static AuthService get authService => _authService!;
  static PhotoService get photoService => _photoService!;
  static ReportService get reportService => _reportService!;
  static ConnectivityService get connectivityService => _connectivityService!;
  static SyncManager get syncManager => _syncManager!;
  static ApiClient get apiClient => _apiClient!;

  // Factory methods para Cubits
  /// Crea un BovinoPartosCubit para un farmId específico
  static BovinoPartosCubit createBovinoPartosCubit(String farmId) {
    return BovinoPartosCubit(
      getEventos: GetEventosReproductivosByBovino(
        repository: _eventosReproductivosRepository!,
        farmId: farmId,
      ),
    );
  }

  /// Crea un BovinoDescendenciaCubit para un farmId específico
  static BovinoDescendenciaCubit createBovinoDescendenciaCubit(String farmId) {
    return BovinoDescendenciaCubit(
      getBovinos: GetBovinosStream(
        repository: _bovinosRepository!,
        farmId: farmId,
      ),
    );
  }

  /// Crea un DashboardCubit para un farmId específico
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
}

