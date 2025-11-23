import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Base de datos local para modo offline
class AppDatabase {
  static const String _databaseName = 'ganaderia.db';
  static const int _databaseVersion = 1;

  static Database? _database;
  static bool _initialized = false;
  static bool _isWebMode = false;

  /// Inicializa el factory de la base de datos (necesario para web)
  static Future<void> initialize() async {
    if (_initialized) return;
    
    if (kIsWeb) {
      // Para web, sqflite no está soportado directamente
      // Deshabilitar la base de datos y usar solo modo online
      debugPrint('Base de datos no disponible en web. Usando modo online solamente.');
      _isWebMode = true;
      _initialized = true;
      return;
    }
    
    _initialized = true;
  }

  /// Obtiene la instancia de la base de datos
  static Future<Database> get database async {
    if (!_initialized) {
      await initialize();
    }
    
    // Si estamos en web, lanzar un error explicativo
    if (_isWebMode) {
      throw UnsupportedError(
        'Base de datos local no disponible en web. '
        'Por favor, use el modo online o ejecute la aplicación en móvil/desktop.'
      );
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos y crea las tablas
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas en la base de datos
  static Future<void> _onCreate(Database db, int version) async {
    // Tabla de Ovinos
    await db.execute('''
      CREATE TABLE ovinos (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        identification TEXT,
        name TEXT,
        birthDate TEXT NOT NULL,
        currentWeight REAL,
        gender TEXT NOT NULL,
        estadoReproductivo TEXT,
        fechaMonta TEXT,
        fechaProbableParto TEXT,
        partosPrevios INTEGER,
        notes TEXT,
        photoUrl TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Bovinos
    await db.execute('''
      CREATE TABLE bovinos (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        identification TEXT,
        name TEXT,
        category TEXT NOT NULL,
        gender TEXT NOT NULL,
        currentWeight REAL NOT NULL,
        birthDate TEXT NOT NULL,
        productionStage TEXT NOT NULL,
        healthStatus TEXT NOT NULL,
        breedingStatus TEXT,
        lastHeatDate TEXT,
        inseminationDate TEXT,
        expectedCalvingDate TEXT,
        previousCalvings INTEGER,
        notes TEXT,
        photoUrl TEXT,
        idPadre TEXT,
        nombrePadre TEXT,
        idMadre TEXT,
        nombreMadre TEXT,
        raza TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Porcinos
    await db.execute('''
      CREATE TABLE porcinos (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        identification TEXT,
        gender TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        currentWeight REAL NOT NULL,
        feedingStage TEXT NOT NULL,
        notes TEXT,
        photoUrl TEXT,
        updatedAt TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Avicultura
    await db.execute('''
      CREATE TABLE avicultura (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        identification TEXT,
        name TEXT,
        fechaNacimiento TEXT NOT NULL,
        raza TEXT,
        gender TEXT NOT NULL,
        estado TEXT NOT NULL,
        fechaIngresoLote TEXT,
        loteId TEXT,
        notes TEXT,
        photoUrl TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Trabajadores
    await db.execute('''
      CREATE TABLE trabajadores (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        fullName TEXT NOT NULL,
        identification TEXT NOT NULL,
        position TEXT NOT NULL,
        salary REAL NOT NULL,
        startDate TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        workerType TEXT NOT NULL,
        laborDescription TEXT,
        photoUrl TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de cola de sincronización
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        operation TEXT NOT NULL,
        entityId TEXT NOT NULL,
        farmId TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // Índices para mejorar el rendimiento
    await db.execute('CREATE INDEX idx_ovinos_farmId ON ovinos(farmId)');
    await db.execute('CREATE INDEX idx_bovinos_farmId ON bovinos(farmId)');
    await db.execute('CREATE INDEX idx_porcinos_farmId ON porcinos(farmId)');
    await db.execute('CREATE INDEX idx_avicultura_farmId ON avicultura(farmId)');
    await db.execute('CREATE INDEX idx_trabajadores_farmId ON trabajadores(farmId)');
    await db.execute('CREATE INDEX idx_sync_queue_farmId ON sync_queue(farmId)');
  }

  /// Actualiza la base de datos cuando cambia la versión
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar migraciones aquí si es necesario
  }

  /// Cierra la base de datos
  static Future<void> close() async {
    if (_isWebMode) return;
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
