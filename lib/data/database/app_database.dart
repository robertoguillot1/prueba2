import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Base de datos local para modo offline
class AppDatabase {
  static const String _databaseName = 'ganaderia.db';
  static const int _databaseVersion = 4; // Incremented version (added Pagos/Prestamos)
  
  static Database? _database;
  static bool _isWebMode = kIsWeb;

  /// Inicializa la base de datos
  static Future<void> initialize() async {
    if (_isWebMode) return;
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Getter para obtener la instancia de la base de datos
  static Future<Database> get database async {
    if (_isWebMode) {
      throw UnsupportedError('SQLite no está disponible en modo web');
    }
    if (_database == null) {
      await initialize();
    }
    return _database!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Tabla de Ovinos
    await db.execute('''
      CREATE TABLE ovinos (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        name TEXT,
        identification TEXT NOT NULL,
        breed TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        weight REAL NOT NULL,
        purpose TEXT NOT NULL,
        status TEXT NOT NULL,
        photoUrl TEXT,
        createdAt TEXT NOT NULL,
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

    // Tabla de Cola de Sincronización
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

    // NEW TABLES (Version 2) - Feeding
    await _createFeedingTables(db);

    // NEW TABLES (Version 3) - Cattle
    await _createCattleTable(db);

    // NEW TABLES (Version 4) - Trabajadores Extras
    await _createTrabajadoresExtrasTables(db);

    // Índices
    await db.execute('CREATE INDEX idx_ovinos_farmId ON ovinos(farmId)');
    await db.execute('CREATE INDEX idx_trabajadores_farmId ON trabajadores(farmId)');
    await db.execute('CREATE INDEX idx_sync_queue_farmId ON sync_queue(farmId)');
    await db.execute('CREATE INDEX idx_feeding_schedules_bovineId ON feeding_schedules(bovineId)');
    await db.execute('CREATE INDEX idx_nutritional_alerts_bovineId ON nutritional_alerts(bovineId)');
    await db.execute('CREATE INDEX idx_cattle_farmId ON cattle(farmId)');
    await db.execute('CREATE INDEX idx_pagos_workerId ON pagos(workerId)');
    await db.execute('CREATE INDEX idx_prestamos_workerId ON prestamos(workerId)');
  }

  static Future<void> _createFeedingTables(Database db) async {
    // Tabla de Horarios de Alimentación
    await db.execute('''
      CREATE TABLE feeding_schedules (
        id TEXT PRIMARY KEY,
        bovineId TEXT NOT NULL,
        farmId TEXT NOT NULL,
        feedType TEXT NOT NULL,
        amountKg REAL NOT NULL,
        frequency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Tabla de Alertas Nutricionales
    await db.execute('''
      CREATE TABLE nutritional_alerts (
        id TEXT PRIMARY KEY,
        bovineId TEXT NOT NULL,
        alertType TEXT NOT NULL,
        severity TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        isResolved INTEGER DEFAULT 0,
        resolvedDate TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createCattleTable(Database db) async {
    // Tabla de Cattle (Bovinos)
    await db.execute('''
      CREATE TABLE cattle (
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        identifier TEXT NOT NULL,
        name TEXT,
        breed TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        weight REAL NOT NULL,
        purpose TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        motherId TEXT,
        fatherId TEXT,
        previousCalvings INTEGER DEFAULT 0,
        healthStatus TEXT NOT NULL,
        productionStage TEXT NOT NULL,
        breedingStatus TEXT,
        lastHeatDate TEXT,
        inseminationDate TEXT,
        expectedCalvingDate TEXT,
        notes TEXT,
        photoUrl TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _createTrabajadoresExtrasTables(Database db) async {
    // Tabla de Pagos
    await db.execute('''
      CREATE TABLE pagos (
        id TEXT PRIMARY KEY,
        workerId TEXT NOT NULL,
        farmId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        concept TEXT NOT NULL,
        notes TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Préstamos
    await db.execute('''
      CREATE TABLE prestamos (
        id TEXT PRIMARY KEY,
        workerId TEXT NOT NULL,
        farmId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        isPaid INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createFeedingTables(db);
      await db.execute('CREATE INDEX idx_feeding_schedules_bovineId ON feeding_schedules(bovineId)');
      await db.execute('CREATE INDEX idx_nutritional_alerts_bovineId ON nutritional_alerts(bovineId)');
    }
    if (oldVersion < 3) {
      await _createCattleTable(db);
      await db.execute('CREATE INDEX idx_cattle_farmId ON cattle(farmId)');
    }
    if (oldVersion < 4) {
      await _createTrabajadoresExtrasTables(db);
      await db.execute('CREATE INDEX idx_pagos_workerId ON pagos(workerId)');
      await db.execute('CREATE INDEX idx_prestamos_workerId ON prestamos(workerId)');
    }
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
