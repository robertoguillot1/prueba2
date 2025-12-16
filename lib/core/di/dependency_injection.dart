import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/ovinos/ovejas_datasource.dart';
// import '../../data/datasources/bovinos/bovinos_datasource.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
import '../../data/datasources/porcinos/cerdos_datasource.dart';
import '../../data/datasources/trabajadores/trabajadores_datasource.dart';
import '../../data/datasources/avicultura/gallinas_datasource.dart';
import '../../data/repositories_impl/ovinos/ovejas_repository_impl.dart';
// import '../../data/repositories_impl/bovinos/bovinos_repository_impl.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
import '../../data/repositories_impl/porcinos/cerdos_repository_impl.dart';
import '../../data/repositories_impl/trabajadores/trabajadores_repository_impl.dart';
import '../../data/repositories_impl/avicultura/gallinas_repository_impl.dart';
import '../../domain/repositories/ovinos/ovejas_repository.dart';
// import '../../domain/repositories/bovinos/bovinos_repository.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
import '../../domain/repositories/porcinos/cerdos_repository.dart';
import '../../domain/repositories/trabajadores/trabajadores_repository.dart';
import '../../domain/repositories/avicultura/gallinas_repository.dart';
import '../../domain/usecases/ovinos/get_all_ovejas.dart';
import '../../domain/usecases/ovinos/get_oveja_by_id.dart';
import '../../domain/usecases/ovinos/create_oveja.dart';
import '../../domain/usecases/ovinos/update_oveja.dart';
import '../../domain/usecases/ovinos/delete_oveja.dart';
import '../../domain/usecases/ovinos/search_ovejas.dart';
// import '../../domain/usecases/bovinos/get_all_bovinos.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
// import '../../domain/usecases/bovinos/create_bovino.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
// import '../../domain/usecases/bovinos/update_bovino.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
// import '../../domain/usecases/bovinos/delete_bovino.dart'; // ELIMINADO: Usar CattleRepository (sistema nuevo)
import '../../domain/usecases/porcinos/get_all_cerdos.dart';
import '../../domain/usecases/porcinos/create_cerdo.dart';
import '../../domain/usecases/porcinos/update_cerdo.dart';
import '../../domain/usecases/porcinos/delete_cerdo.dart';
import '../../domain/usecases/trabajadores/get_all_trabajadores.dart';
import '../../domain/usecases/trabajadores/create_trabajador.dart';
import '../../domain/usecases/trabajadores/update_trabajador.dart';
import '../../domain/usecases/trabajadores/delete_trabajador.dart';
import '../../domain/usecases/trabajadores/get_trabajadores_activos.dart';
import '../../domain/usecases/trabajadores/search_trabajadores.dart';
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
// Trabajadores Remote DataSource (legacy - para trabajadores, no para pagos/préstamos)
// import '../../data/datasources/remote/trabajadores/trabajadores_remote_datasource.dart';
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
import '../../presentation/modules/bovinos/cubits/form/bovino_form_cubit.dart';
import '../../presentation/modules/farms/cubits/farm_form_cubit.dart';
// Cattle Module (Clean Architecture)
import '../../features/cattle/data/datasources/cattle_remote_datasource.dart';
import '../../features/cattle/data/datasources/local/cattle_local_datasource.dart';
import '../../features/cattle/data/repositories/cattle_repository_impl.dart';
import '../../features/cattle/data/repositories/cattle_hybrid_repository_impl.dart';
import '../../features/cattle/domain/repositories/cattle_repository.dart';
import '../../features/cattle/domain/usecases/get_cattle_list.dart';
import '../../features/cattle/domain/usecases/get_bovine.dart';
import '../../features/cattle/domain/usecases/add_bovine.dart';
import '../../features/cattle/domain/usecases/update_bovine.dart';
import '../../features/cattle/domain/usecases/delete_bovine.dart';
import '../../features/cattle/presentation/cubit/cattle_cubit.dart';
// Trabajadores Module (Clean Architecture - Pagos y Préstamos)
import '../../features/trabajadores/data/datasources/trabajadores_remote_datasource.dart';
import '../../features/trabajadores/data/datasources/local/trabajadores_local_datasource.dart';
import '../../features/trabajadores/data/repositories/trabajadores_hybrid_repository_impl.dart';
// Eventos Reproductivos (Sistema Viejo)
import '../../domain/repositories/bovinos/eventos_reproductivos_repository.dart';
import '../../data/repositories_impl/bovinos/eventos_reproductivos_repository_impl.dart';
import '../../data/datasources/bovinos/eventos_reproductivos_datasource.dart';
import '../../domain/usecases/bovinos/get_eventos_reproductivos_by_bovino.dart';
import '../../domain/usecases/bovinos/create_evento_reproductivo.dart';
import '../../presentation/modules/bovinos/details/cubits/reproduction_cubit.dart';
import '../../presentation/modules/bovinos/details/cubits/reproductive_event_form_cubit.dart';
import '../../presentation/modules/bovinos/list/cubits/bovine_list_cubit.dart';
// Producción (Leche y Peso) - Sistema Viejo
import '../../domain/repositories/bovinos/produccion_leche_repository.dart';
import '../../domain/repositories/bovinos/peso_bovino_repository.dart';
import '../../data/repositories_impl/bovinos/produccion_leche_repository_impl.dart';
import '../../data/repositories_impl/bovinos/peso_bovino_repository_impl.dart';
import '../../data/datasources/bovinos/produccion_leche_datasource.dart';
import '../../data/datasources/bovinos/peso_bovino_datasource.dart';
import '../../domain/usecases/bovinos/get_producciones_leche_by_bovino.dart';
import '../../domain/usecases/bovinos/get_pesos_by_bovino.dart';
import '../../domain/usecases/bovinos/add_milk_production.dart' as old;
import '../../domain/usecases/bovinos/add_weight_record.dart' as old;
import '../../presentation/modules/bovinos/details/cubits/production_cubit.dart';
import '../../presentation/modules/bovinos/details/cubits/production_form_cubit.dart';
// Sanidad (Vacunas)
import '../../features/cattle/domain/repositories/vacuna_bovino_repository.dart';
import '../../features/cattle/domain/usecases/get_vacunas_by_bovino.dart';
import '../../features/cattle/domain/usecases/add_vacuna_bovino.dart';
import '../../features/cattle/data/repositories/vacuna_bovino_repository_impl.dart';
import '../../features/cattle/data/datasources/vacuna_bovino_remote_datasource.dart';
import '../../presentation/modules/bovinos/details/cubits/health_cubit.dart';
// Nuevo Sistema - Eventos Reproductivos
import '../../features/cattle/domain/repositories/reproductive_event_repository.dart';
import '../../features/cattle/data/repositories/reproductive_event_repository_impl.dart';
import '../../features/cattle/data/datasources/reproductive_event_remote_datasource.dart';
import '../../features/cattle/domain/usecases/get_reproductive_events_by_bovine.dart';
import '../../features/cattle/domain/usecases/get_reproductive_event_by_id.dart';
import '../../features/cattle/domain/usecases/add_reproductive_event.dart';
import '../../features/cattle/domain/usecases/update_reproductive_event.dart';
import '../../features/cattle/domain/usecases/delete_reproductive_event.dart';
// Nuevo Sistema - Producción de Leche
import '../../features/cattle/domain/repositories/milk_production_repository.dart';
import '../../features/cattle/data/repositories/milk_production_repository_impl.dart';
import '../../features/cattle/data/datasources/milk_production_remote_datasource.dart';
import '../../features/cattle/domain/usecases/get_milk_productions_by_bovine.dart';
import '../../features/cattle/domain/usecases/get_milk_productions_by_date_range.dart';
import '../../features/cattle/domain/usecases/get_milk_production_by_id.dart';
import '../../features/cattle/domain/usecases/add_milk_production.dart';
import '../../features/cattle/domain/usecases/update_milk_production.dart';
import '../../features/cattle/domain/usecases/delete_milk_production.dart';
// Nuevo Sistema - Registros de Peso
import '../../features/cattle/domain/repositories/weight_record_repository.dart';
import '../../features/cattle/data/repositories/weight_record_repository_impl.dart';
import '../../features/cattle/data/datasources/weight_record_remote_datasource.dart';
import '../../features/cattle/domain/usecases/get_weight_records_by_bovine.dart';
import '../../features/cattle/domain/usecases/get_weight_record_by_id.dart';
import '../../features/cattle/domain/usecases/add_weight_record.dart';
import '../../features/cattle/domain/usecases/update_weight_record.dart';
import '../../features/cattle/domain/usecases/delete_weight_record.dart';
// Nuevo Sistema - Transferencias
import '../../features/cattle/domain/repositories/transfer_repository.dart';
import '../../features/cattle/data/repositories/transfer_repository_impl.dart';
import '../../features/cattle/data/datasources/transfer_remote_datasource.dart';
import '../../features/cattle/domain/usecases/get_transfers_by_bovine.dart';
import '../../features/cattle/domain/usecases/get_transfers_by_farm.dart';
import '../../features/cattle/domain/usecases/add_transfer.dart';
import '../../features/cattle/domain/usecases/update_transfer.dart';
import '../../features/cattle/domain/usecases/delete_transfer.dart';
import '../../presentation/modules/bovinos/details/cubits/transfer_cubit.dart';
import '../../presentation/modules/bovinos/list/cubits/farm_transfers_cubit.dart';
import '../../presentation/modules/bovinos/list/cubits/farm_health_cubit.dart';
import '../../presentation/modules/bovinos/list/cubits/farm_production_cubit.dart';
// Feeding Module (Nuevo Sistema)
import '../../features/cattle/domain/repositories/feeding_repository.dart';
import '../../features/cattle/data/repositories/feeding_repository_impl.dart';
import '../../features/cattle/data/datasources/feeding_local_datasource.dart';
import '../../features/cattle/domain/usecases/feeding/get_feeding_schedules.dart';
import '../../features/cattle/domain/usecases/feeding/save_feeding_schedule.dart';
import '../../features/cattle/domain/usecases/feeding/calculate_nutritional_requirements.dart';
// Finance Module (Clean Architecture)
import '../../features/finance/data/datasources/finance_remote_datasource.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/domain/usecases/get_expenses.dart';
import '../../features/finance/domain/usecases/add_expense.dart';
import '../../features/finance/domain/usecases/update_expense.dart';
import '../../features/finance/domain/usecases/delete_expense.dart';
import '../../features/finance/domain/usecases/get_loans.dart';
import '../../features/finance/domain/usecases/add_loan.dart';
import '../../features/finance/domain/usecases/update_loan.dart';
import '../../features/finance/domain/usecases/delete_loan.dart';
import '../../features/finance/domain/usecases/get_payments.dart';
import '../../features/finance/domain/usecases/add_payment.dart';
import '../../features/finance/domain/usecases/update_payment.dart';
import '../../features/finance/domain/usecases/delete_payment.dart';
import '../../presentation/modules/bovinos/details/cubits/feeding_cubit.dart';
// Trabajadores Extras
import '../../features/trabajadores/domain/usecases/get_pagos.dart';
import '../../features/trabajadores/domain/usecases/add_pago.dart';
import '../../features/trabajadores/domain/usecases/update_pago.dart';
import '../../features/trabajadores/domain/usecases/delete_pago.dart';
import '../../features/trabajadores/domain/usecases/get_prestamos.dart';
import '../../features/trabajadores/domain/usecases/add_prestamo.dart';
import '../../features/trabajadores/domain/usecases/update_prestamo.dart';
import '../../features/trabajadores/domain/usecases/delete_prestamo.dart';
import '../../presentation/modules/trabajadores/cubits/pagos_cubit.dart';
import '../../presentation/modules/trabajadores/cubits/prestamos_cubit.dart';

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
  // static BovinosDataSource? _bovinosDataSource; // ELIMINADO: Usar CattleRepository (sistema nuevo)
  static CerdosDataSource? _cerdosDataSource;
  static TrabajadoresDataSource? _trabajadoresDataSource;
  static GallinasDataSource? _gallinasDataSource;
  static EventosReproductivosDataSource? _eventosReproductivosDataSource;
  static ProduccionLecheDataSource? _produccionLecheDataSource;
  static PesoBovinoDataSource? _pesoBovinoDataSource;
  
  // Repositories
  static OvejasRepository? _ovejasRepository;
  // static BovinosRepository? _bovinosRepository; // ELIMINADO: Usar CattleRepository (sistema nuevo)
  static CerdosRepository? _cerdosRepository;
  static TrabajadoresRepository? _trabajadoresRepository;
  static GallinasRepository? _gallinasRepository;
  static EventosReproductivosRepository? _eventosReproductivosRepository;
  static ProduccionLecheRepository? _produccionLecheRepository;
  static PesoBovinoRepository? _pesoBovinoRepository;
  static VacunaBovinoRepository? _vacunaBovinoRepository;
  
  /// Inicializa todas las dependencias
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    
    // Inicializar base de datos
    try {
      await AppDatabase.initialize();
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
    // _trabajadoresRemoteDataSource = TrabajadoresRemoteDataSourceImpl(_apiClient!); // Legacy - no usado para pagos/préstamos
    
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
    // _bovinosDataSource = BovinosDataSourceImpl(_sharedPreferences!); // ELIMINADO: Usar CattleRepository (sistema nuevo)
    _cerdosDataSource = CerdosDataSourceImpl(_sharedPreferences!);
    _trabajadoresDataSource = TrabajadoresDataSourceImpl(_sharedPreferences!);
    _gallinasDataSource = GallinasDataSourceImpl(_sharedPreferences!);
    _eventosReproductivosDataSource = EventosReproductivosDataSourceImpl(_sharedPreferences!);
    _produccionLecheDataSource = ProduccionLecheDataSourceImpl(_sharedPreferences!);
    _pesoBovinoDataSource = PesoBovinoDataSourceImpl(_sharedPreferences!);
    
    // Inicializar Repositories
    _ovejasRepository = OvejasRepositoryImpl(_ovejasDataSource!);
    // _bovinosRepository = BovinosRepositoryImpl(_bovinosDataSource!); // ELIMINADO: Usar CattleRepository (sistema nuevo)
    _cerdosRepository = CerdosRepositoryImpl(_cerdosDataSource!);
    _trabajadoresRepository = TrabajadoresRepositoryImpl(_trabajadoresDataSource!);
    _gallinasRepository = GallinasRepositoryImpl(_gallinasDataSource!);
    _eventosReproductivosRepository = EventosReproductivosRepositoryImpl(_eventosReproductivosDataSource!);
    _produccionLecheRepository = ProduccionLecheRepositoryImpl(_produccionLecheDataSource!);
    _pesoBovinoRepository = PesoBovinoRepositoryImpl(_pesoBovinoDataSource!);
    // Vacunas Bovino (Firestore)
    final vacunaBovinoDataSource = VacunaBovinoRemoteDataSourceImpl();
    _vacunaBovinoRepository = VacunaBovinoRepositoryImpl(vacunaBovinoDataSource);
    
    // Registrar repositorio en GetIt
    sl.registerFactory<VacunaBovinoRepository>(() => _vacunaBovinoRepository!);
    
    // Registrar UseCases de Sanidad
    sl.registerLazySingleton(() => GetVacunasByBovino(sl<VacunaBovinoRepository>()));
    sl.registerLazySingleton(() => AddVacunaBovino(sl<VacunaBovinoRepository>()));
    
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

    // CATTLE - Data Sources
    sl.registerLazySingleton<CattleRemoteDataSource>(
      () => CattleRemoteDataSourceImpl(),
    );
    
    sl.registerLazySingleton<CattleLocalDataSource>(
      () => CattleLocalDataSourceImpl(),
    );

    // CATTLE - Repository (Hybrid: Online/Offline)
    sl.registerLazySingleton<CattleRepository>(
      () => CattleHybridRepositoryImpl(
        connectivityService: _connectivityService!,
        remoteDataSource: sl<CattleRemoteDataSource>(),
        localDataSource: sl<CattleLocalDataSource>(),
        syncManager: _syncManager!,
      ),
    );

    // CATTLE - Use Cases
    sl.registerLazySingleton(() => GetCattleList(sl<CattleRepository>()));
    sl.registerLazySingleton(() => GetBovine(sl<CattleRepository>()));
    sl.registerLazySingleton(() => AddBovine(sl<CattleRepository>()));
    sl.registerLazySingleton(() => UpdateBovine(sl<CattleRepository>()));
    sl.registerLazySingleton(() => DeleteBovine(sl<CattleRepository>()));

    // CATTLE - Cubit de Formulario (Factory para crear nueva instancia cada vez)
    sl.registerFactory(
      () => BovinoFormCubit(
        addBovineUseCase: sl<AddBovine>(),
        updateBovineUseCase: sl<UpdateBovine>(),
        deleteBovineUseCase: sl<DeleteBovine>(),
      ),
    );

    // ========== FINANCE (Nuevo Sistema) ==========
    // Data Source
    sl.registerLazySingleton<FinanceRemoteDataSource>(
      () => FinanceRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepositoryImpl(
        remoteDataSource: sl<FinanceRemoteDataSource>(),
      ),
    );

    // Use Cases - Expenses
    sl.registerLazySingleton(() => GetExpenses(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => AddExpense(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => UpdateExpense(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => DeleteExpense(sl<FinanceRepository>()));

    // Use Cases - Loans
    sl.registerLazySingleton(() => GetLoans(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => AddLoan(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => UpdateLoan(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => DeleteLoan(sl<FinanceRepository>()));

    // Use Cases - Payments
    sl.registerLazySingleton(() => GetPayments(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => AddPayment(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => UpdatePayment(sl<FinanceRepository>()));
    sl.registerLazySingleton(() => DeletePayment(sl<FinanceRepository>()));

    // ========== REPRODUCTIVE EVENTS (Nuevo Sistema) ==========
    // Data Source
    sl.registerLazySingleton<ReproductiveEventRemoteDataSource>(
      () => ReproductiveEventRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<ReproductiveEventRepository>(
      () => ReproductiveEventRepositoryImpl(
        remoteDataSource: sl<ReproductiveEventRemoteDataSource>(),
      ),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetReproductiveEventsByBovine(sl<ReproductiveEventRepository>()));
    sl.registerLazySingleton(() => GetReproductiveEventById(sl<ReproductiveEventRepository>()));
    sl.registerLazySingleton(() => AddReproductiveEvent(sl<ReproductiveEventRepository>()));
    sl.registerLazySingleton(() => UpdateReproductiveEvent(sl<ReproductiveEventRepository>()));
    sl.registerLazySingleton(() => DeleteReproductiveEvent(sl<ReproductiveEventRepository>()));

    // ========== MILK PRODUCTION (Nuevo Sistema) ==========
    // Data Source
    sl.registerLazySingleton<MilkProductionRemoteDataSource>(
      () => MilkProductionRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<MilkProductionRepository>(
      () => MilkProductionRepositoryImpl(
        remoteDataSource: sl<MilkProductionRemoteDataSource>(),
      ),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetMilkProductionsByBovine(sl<MilkProductionRepository>()));
    sl.registerLazySingleton(() => GetMilkProductionsByDateRange(sl<MilkProductionRepository>()));
    sl.registerLazySingleton(() => GetMilkProductionById(sl<MilkProductionRepository>()));
    sl.registerLazySingleton(() => AddMilkProduction(sl<MilkProductionRepository>()));
    sl.registerLazySingleton(() => UpdateMilkProduction(sl<MilkProductionRepository>()));
    sl.registerLazySingleton(() => DeleteMilkProduction(sl<MilkProductionRepository>()));

    // ========== WEIGHT RECORDS (Nuevo Sistema) ==========
    // Data Source
    sl.registerLazySingleton<WeightRecordRemoteDataSource>(
      () => WeightRecordRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<WeightRecordRepository>(
      () => WeightRecordRepositoryImpl(
        remoteDataSource: sl<WeightRecordRemoteDataSource>(),
      ),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetWeightRecordsByBovine(sl<WeightRecordRepository>()));
    sl.registerLazySingleton(() => GetWeightRecordById(sl<WeightRecordRepository>()));
    sl.registerLazySingleton(() => AddWeightRecord(sl<WeightRecordRepository>()));
    sl.registerLazySingleton(() => UpdateWeightRecord(sl<WeightRecordRepository>()));
    sl.registerLazySingleton(() => DeleteWeightRecord(sl<WeightRecordRepository>()));

    // ========== TRANSFERS (Nuevo Sistema) ==========
    // Data Source
    sl.registerLazySingleton<TransferRemoteDataSource>(
      () => TransferRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<TransferRepository>(
      () => TransferRepositoryImpl(
        remoteDataSource: sl<TransferRemoteDataSource>(),
      ),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetTransfersByBovine(sl<TransferRepository>()));
    sl.registerLazySingleton(() => GetTransfersByFarm(sl<TransferRepository>()));
    sl.registerLazySingleton(() => AddTransfer(sl<TransferRepository>()));
    sl.registerLazySingleton(() => UpdateTransfer(sl<TransferRepository>()));
    // ========== TRANSFERS (Nuevo Sistema) ==========
    // ... (existing transfer code)
    sl.registerLazySingleton(() => DeleteTransfer(sl<TransferRepository>()));

    // ========== FEEDING (Nuevo Sistema) ==========
    // Data Source
    sl.registerLazySingleton<FeedingLocalDataSource>(
      () => FeedingLocalDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<FeedingRepository>(
      () => FeedingRepositoryImpl(sl<FeedingLocalDataSource>()),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetFeedingSchedules(sl<FeedingRepository>()));
    sl.registerLazySingleton(() => SaveFeedingSchedule(sl<FeedingRepository>()));
    sl.registerLazySingleton(() => CalculateNutritionalRequirements(sl<FeedingRepository>()));

    // ========== TRABAJADORES EXTRAS (PAGOS Y PRÉSTAMOS) ==========
    // Data Sources
    sl.registerLazySingleton<TrabajadoresRemoteDataSource>(
      () => TrabajadoresRemoteDataSourceImpl(),
    );
    sl.registerLazySingleton<TrabajadoresLocalDataSource>(
      () => TrabajadoresLocalDataSourceImpl(),
    );

    // Repository (Hybrid - reemplaza el anterior para pagos y préstamos)
    // Nota: El TrabajadoresRepository existente se mantiene para trabajadores
    // pero se actualiza para usar el híbrido para pagos y préstamos
    sl.registerLazySingleton<TrabajadoresRepository>(
      () => TrabajadoresHybridRepositoryImpl(
        connectivityService: _connectivityService!,
        remoteDataSource: sl<TrabajadoresRemoteDataSource>(),
        localDataSource: sl<TrabajadoresLocalDataSource>(),
        syncManager: _syncManager!,
        legacyDataSource: _trabajadoresDataSource!,
      ),
    );

    // Use Cases Pagos
    sl.registerLazySingleton(() => GetPagos(sl<TrabajadoresRepository>()));
    sl.registerLazySingleton(() => AddPago(sl<TrabajadoresRepository>()));
    sl.registerLazySingleton(() => UpdatePago(sl<TrabajadoresRepository>()));
    sl.registerLazySingleton(() => DeletePago(sl<TrabajadoresRepository>()));
    
    // Use Cases Prestamos
    sl.registerLazySingleton(() => GetPrestamos(sl<TrabajadoresRepository>()));
    sl.registerLazySingleton(() => AddPrestamo(sl<TrabajadoresRepository>()));
    sl.registerLazySingleton(() => UpdatePrestamo(sl<TrabajadoresRepository>()));
    sl.registerLazySingleton(() => DeletePrestamo(sl<TrabajadoresRepository>()));
  }
  
  // ... (existing factories)

  /// Crea una instancia de PagosCubit
  static PagosCubit createPagosCubit() {
    return PagosCubit(
      getPagos: sl<GetPagos>(),
      addPago: sl<AddPago>(),
      updatePago: sl<UpdatePago>(),
      deletePago: sl<DeletePago>(),
    );
  }

  /// Crea una instancia de PrestamosCubit
  static PrestamosCubit createPrestamosCubit() {
    return PrestamosCubit(
      getPrestamos: sl<GetPrestamos>(),
      addPrestamo: sl<AddPrestamo>(),
      updatePrestamo: sl<UpdatePrestamo>(),
      deletePrestamo: sl<DeletePrestamo>(),
    );
  }

  // Getters para Services
  static AuthService get authService => _authService!;
  static PhotoService get photoService => _photoService!;
  static ReportService get reportService => _reportService!;
  static ConnectivityService get connectivityService => _connectivityService!;
  static SyncManager get syncManager => _syncManager!;
  static ApiClient get apiClient => _apiClient!;
  // static BovinosRepository get bovinosRepository => _bovinosRepository!; // ELIMINADO: Usar sl<CattleRepository>() en su lugar

  // Factory methods for Cubits/ViewModels (Restored)
  
  static FarmsCubit createFarmsCubit(String userId) {
    final curFarmRepo = sl<FarmRepository>();
    return FarmsCubit(
      getFarmsStream: GetFarmsStream(repository: curFarmRepo, userId: userId),
      deleteFarmUseCase: DeleteFarm(curFarmRepo),
      setCurrentFarmUseCase: SetCurrentFarm(curFarmRepo),
      farmRepository: curFarmRepo,
      userId: userId,
    );
  }

  static FarmFormCubit createFarmFormCubit(String userId) {
    final curFarmRepo = sl<FarmRepository>();
    return FarmFormCubit(
      createFarmUseCase: CreateFarm(curFarmRepo),
      updateFarmUseCase: UpdateFarm(curFarmRepo),
      userId: userId,
    );
  }

  static DashboardCubit createDashboardCubit(String farmId) {
    return DashboardCubit(
      farmId: farmId,
      // getBovinosStream: null, // ELIMINADO: Sistema legacy de bovinos eliminado. Usar cattleRepository en su lugar
      getCerdosStream: GetCerdosStream(repository: _cerdosRepository!, farmId: farmId),
      getOvejasStream: GetOvejasStream(repository: _ovejasRepository!, farmId: farmId),
      getGallinasStream: GetGallinasStream(repository: _gallinasRepository!, farmId: farmId),
      getTrabajadoresStream: GetTrabajadoresStream(repository: _trabajadoresRepository!, farmId: farmId),
      cattleRepository: sl<CattleRepository>(), // Usar este para bovinos (sistema nuevo)
    );
  }

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

  static BovinoFormCubit createBovineFormCubit() => sl<BovinoFormCubit>();
  
    // Legacy ViewModels
  static OvejasViewModel createOvejasViewModel() => OvejasViewModel(
    getAllOvejas: GetAllOvejas(_ovejasRepository!),
    getOvejaById: GetOvejaById(_ovejasRepository!),
    createOveja: CreateOveja(_ovejasRepository!),
    updateOveja: UpdateOveja(_ovejasRepository!),
    deleteOveja: DeleteOveja(_ovejasRepository!),
    searchOvejas: SearchOvejas(_ovejasRepository!),
  );

  static CerdosViewModel createCerdosViewModel() => CerdosViewModel(
    getAllCerdos: GetAllCerdos(_cerdosRepository!),
    createCerdo: CreateCerdo(_cerdosRepository!),
    updateCerdo: UpdateCerdo(_cerdosRepository!),
    deleteCerdo: DeleteCerdo(_cerdosRepository!),
  );

  static GallinasViewModel createGallinasViewModel() => GallinasViewModel(
    getAllGallinas: GetAllGallinas(_gallinasRepository!),
    createGallina: CreateGallina(_gallinasRepository!),
    // Assuming other use cases are similar
  );

  static TrabajadoresViewModel createTrabajadoresViewModel() => TrabajadoresViewModel(
    getAllTrabajadores: GetAllTrabajadores(_trabajadoresRepository!),
    createTrabajador: CreateTrabajador(_trabajadoresRepository!),
    updateTrabajador: UpdateTrabajador(_trabajadoresRepository!),
    deleteTrabajador: DeleteTrabajador(_trabajadoresRepository!),
    getTrabajadoresActivos: GetTrabajadoresActivos(_trabajadoresRepository!),
    searchTrabajadores: SearchTrabajadores(_trabajadoresRepository!),
  );

  static FarmHealthCubit createFarmHealthCubit() {
    return FarmHealthCubit(
      getVacunasByBovino: GetVacunasByBovino(_vacunaBovinoRepository!),
      getCattleList: sl<GetCattleList>(),
    );
  }

  static ProductionFormCubit createProductionFormCubit() {
    return ProductionFormCubit(
      addMilkProduction: sl<AddMilkProduction>(), 
      addWeightRecord: sl<AddWeightRecord>(),
    );
  }

  static ReproductiveEventFormCubit createReproductiveEventFormCubit() {
    return ReproductiveEventFormCubit(
      addEvent: sl<AddReproductiveEvent>(),
    );
  }

  static HealthCubit createHealthCubit() {
    return HealthCubit(
      getVacunas: sl<GetVacunasByBovino>(),
      addVacuna: sl<AddVacunaBovino>(),
    );
  }

  static ProductionCubit createProductionCubit() {
    return ProductionCubit(
      getProduccionesLeche: sl<GetMilkProductionsByBovine>(),
      getPesos: sl<GetWeightRecordsByBovine>(),
    ); 
  }

  static ReproductionCubit createReproductionCubit() {
    return ReproductionCubit(
      getEvents: sl<GetReproductiveEventsByBovine>(),
    );
  }

  static BovineListCubit createBovineListCubit() {
    return BovineListCubit(
      getCattleList: sl<GetCattleList>(),
    );
  }

  static TransferCubit createTransferCubit() {
    return TransferCubit(
      getTransfers: sl<GetTransfersByBovine>(),
      addTransfer: sl<AddTransfer>(),
      updateTransfer: sl<UpdateTransfer>(),
      deleteTransfer: sl<DeleteTransfer>(),
    );
  }

  static FarmProductionCubit createFarmProductionCubit() {
     return FarmProductionCubit(
        getMilkProductions: sl<GetMilkProductionsByBovine>(),
        getWeightRecords: sl<GetWeightRecordsByBovine>(),
        getCattleList: sl<GetCattleList>(),
     );
  }

  static FarmTransfersCubit createFarmTransfersCubit() {
    return FarmTransfersCubit(
      getTransfers: sl<GetTransfersByFarm>(),
      deleteTransfer: sl<DeleteTransfer>(),
    );
  }

  static FeedingCubit createFeedingCubit() {
    return FeedingCubit(
      getSchedules: sl<GetFeedingSchedules>(),
      saveSchedule: sl<SaveFeedingSchedule>(),
      calculateRequirements: sl<CalculateNutritionalRequirements>(),
    );
  }

}

