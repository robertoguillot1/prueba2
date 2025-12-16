import 'package:sqflite/sqflite.dart';
import '../../../../../../core/utils/result.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../../../data/database/app_database.dart';
import '../../models/bovine_model.dart';
import '../../../domain/entities/bovine_entity.dart';

/// Data source local para Cattle usando SQLite
abstract class CattleLocalDataSource {
  Future<Result<List<BovineModel>>> fetchAll(String farmId);
  Future<Result<BovineModel>> fetchById(String farmId, String id);
  Future<Result<BovineModel>> save(String farmId, BovineModel bovine);
  Future<Result<void>> delete(String farmId, String id);
  Future<Result<List<BovineModel>>> search(String farmId, String query);
}

class CattleLocalDataSourceImpl implements CattleLocalDataSource {
  @override
  Future<Result<List<BovineModel>>> fetchAll(String farmId) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'cattle',
        where: 'farmId = ?',
        whereArgs: [farmId],
      );
      final bovines = maps.map((map) => _mapToBovineModel(map)).toList();
      return Success(bovines);
    } catch (e) {
      return Error(CacheFailure('Error al obtener bovinos: $e'));
    }
  }

  @override
  Future<Result<BovineModel>> fetchById(String farmId, String id) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'cattle',
        where: 'farmId = ? AND id = ?',
        whereArgs: [farmId, id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return Error(NotFoundFailure('Bovino no encontrado'));
      }
      return Success(_mapToBovineModel(maps.first));
    } catch (e) {
      return Error(CacheFailure('Error al obtener bovino: $e'));
    }
  }

  @override
  Future<Result<BovineModel>> save(String farmId, BovineModel bovine) async {
    try {
      final db = await AppDatabase.database;
      final json = _bovineModelToMap(bovine);
      json['synced'] = 0; // Marcar como no sincronizado
      await db.insert(
        'cattle',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(bovine);
    } catch (e) {
      return Error(CacheFailure('Error al guardar bovino: $e'));
    }
  }

  @override
  Future<Result<void>> delete(String farmId, String id) async {
    try {
      final db = await AppDatabase.database;
      await db.delete(
        'cattle',
        where: 'farmId = ? AND id = ?',
        whereArgs: [farmId, id],
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Error al eliminar bovino: $e'));
    }
  }

  @override
  Future<Result<List<BovineModel>>> search(String farmId, String query) async {
    try {
      final db = await AppDatabase.database;
      final maps = await db.query(
        'cattle',
        where: 'farmId = ? AND (name LIKE ? OR identifier LIKE ? OR id LIKE ?)',
        whereArgs: [farmId, '%$query%', '%$query%', '%$query%'],
      );
      final bovines = maps.map((map) => _mapToBovineModel(map)).toList();
      return Success(bovines);
    } catch (e) {
      return Error(CacheFailure('Error al buscar bovinos: $e'));
    }
  }

  /// Convierte un Map de SQLite a BovineModel
  BovineModel _mapToBovineModel(Map<String, dynamic> map) {
    final json = Map<String, dynamic>.from(map);
    json.remove('synced'); // Remover campo interno
    
    // Convertir fechas de String a Timestamp (como espera fromJson)
    if (json['birthDate'] != null) {
      final date = DateTime.parse(json['birthDate'] as String);
      json['birthDate'] = date; // fromJson espera DateTime directamente
    }
    if (json['createdAt'] != null) {
      final date = DateTime.parse(json['createdAt'] as String);
      json['createdAt'] = date;
    }
    if (json['updatedAt'] != null) {
      final date = DateTime.parse(json['updatedAt'] as String);
      json['updatedAt'] = date;
    }
    if (json['lastHeatDate'] != null) {
      final date = DateTime.parse(json['lastHeatDate'] as String);
      json['lastHeatDate'] = date;
    }
    if (json['inseminationDate'] != null) {
      final date = DateTime.parse(json['inseminationDate'] as String);
      json['inseminationDate'] = date;
    }
    if (json['expectedCalvingDate'] != null) {
      final date = DateTime.parse(json['expectedCalvingDate'] as String);
      json['expectedCalvingDate'] = date;
    }
    
    // fromJson de BovineModel espera Timestamps, pero aquí tenemos DateTime
    // Necesitamos crear un modelo directamente desde el map
    return _createBovineModelFromMap(json);
  }

  /// Crea un BovineModel directamente desde un Map (sin usar fromJson que espera Timestamps)
  BovineModel _createBovineModelFromMap(Map<String, dynamic> json) {
    return BovineModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      identifier: json['identifier'] as String,
      name: json['name'] as String?,
      breed: json['breed'] as String,
      gender: _parseGender(json['gender'] as String),
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : DateTime.now(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      purpose: _parsePurpose(json['purpose'] as String),
      status: _parseStatus(json['status'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      motherId: json['motherId'] as String?,
      fatherId: json['fatherId'] as String?,
      previousCalvings: (json['previousCalvings'] as num?)?.toInt() ?? 0,
      healthStatus: json['healthStatus'] != null
          ? _parseHealthStatus(json['healthStatus'] as String)
          : HealthStatus.healthy,
      productionStage: json['productionStage'] != null
          ? _parseProductionStage(json['productionStage'] as String)
          : ProductionStage.raising,
      breedingStatus: json['breedingStatus'] != null
          ? _parseBreedingStatus(json['breedingStatus'] as String)
          : null,
      lastHeatDate: json['lastHeatDate'] != null
          ? DateTime.parse(json['lastHeatDate'] as String)
          : null,
      inseminationDate: json['inseminationDate'] != null
          ? DateTime.parse(json['inseminationDate'] as String)
          : null,
      expectedCalvingDate: json['expectedCalvingDate'] != null
          ? DateTime.parse(json['expectedCalvingDate'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  // Helpers para parsear enums
  BovineGender _parseGender(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'macho':
        return BovineGender.male;
      case 'female':
      case 'hembra':
        return BovineGender.female;
      default:
        return BovineGender.male;
    }
  }

  BovinePurpose _parsePurpose(String value) {
    switch (value.toLowerCase()) {
      case 'meat':
      case 'carne':
        return BovinePurpose.meat;
      case 'milk':
      case 'leche':
        return BovinePurpose.milk;
      case 'dual':
      case 'doble':
        return BovinePurpose.dual;
      default:
        return BovinePurpose.dual;
    }
  }

  BovineStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
      case 'activo':
        return BovineStatus.active;
      case 'sold':
      case 'vendido':
        return BovineStatus.sold;
      case 'dead':
      case 'muerto':
        return BovineStatus.dead;
      default:
        return BovineStatus.active;
    }
  }

  HealthStatus _parseHealthStatus(String value) {
    switch (value.toLowerCase()) {
      case 'healthy':
      case 'sano':
        return HealthStatus.healthy;
      case 'sick':
      case 'enfermo':
        return HealthStatus.sick;
      case 'undertreatment':
      case 'tratamiento':
        return HealthStatus.underTreatment;
      case 'recovering':
      case 'recuperandose':
        return HealthStatus.recovering;
      default:
        return HealthStatus.healthy;
    }
  }

  ProductionStage _parseProductionStage(String value) {
    switch (value.toLowerCase()) {
      case 'raising':
      case 'levante':
        return ProductionStage.raising;
      case 'productive':
      case 'productiva':
        return ProductionStage.productive;
      case 'dry':
      case 'seco':
        return ProductionStage.dry;
      default:
        return ProductionStage.raising;
    }
  }

  BreedingStatus? _parseBreedingStatus(String value) {
    switch (value.toLowerCase()) {
      case 'notspecified':
      case 'no_especificado':
        return BreedingStatus.notSpecified;
      case 'pregnant':
      case 'prenada':
        return BreedingStatus.pregnant;
      case 'inseminated':
      case 'inseminada':
        return BreedingStatus.inseminated;
      case 'empty':
      case 'vacia':
        return BreedingStatus.empty;
      case 'served':
      case 'servida':
        return BreedingStatus.served;
      default:
        return null;
    }
  }

  /// Convierte BovineModel a Map para SQLite
  Map<String, dynamic> _bovineModelToMap(BovineModel bovine) {
    // Crear map manualmente para evitar problemas con Timestamps
    final map = <String, dynamic>{
      'id': bovine.id,
      'farmId': bovine.farmId,
      'identifier': bovine.identifier,
      if (bovine.name != null) 'name': bovine.name,
      'breed': bovine.breed,
      'gender': _genderToString(bovine.gender),
      'birthDate': bovine.birthDate.toIso8601String(),
      'weight': bovine.weight,
      'purpose': _purposeToString(bovine.purpose),
      'status': _statusToString(bovine.status),
      'createdAt': bovine.createdAt.toIso8601String(),
      if (bovine.updatedAt != null) 'updatedAt': bovine.updatedAt!.toIso8601String(),
      if (bovine.motherId != null) 'motherId': bovine.motherId,
      if (bovine.fatherId != null) 'fatherId': bovine.fatherId,
      'previousCalvings': bovine.previousCalvings,
      'healthStatus': _healthStatusToString(bovine.healthStatus),
      'productionStage': _productionStageToString(bovine.productionStage),
      if (bovine.breedingStatus != null) 'breedingStatus': _breedingStatusToString(bovine.breedingStatus!),
      if (bovine.lastHeatDate != null) 'lastHeatDate': bovine.lastHeatDate!.toIso8601String(),
      if (bovine.inseminationDate != null) 'inseminationDate': bovine.inseminationDate!.toIso8601String(),
      if (bovine.expectedCalvingDate != null) 'expectedCalvingDate': bovine.expectedCalvingDate!.toIso8601String(),
      if (bovine.notes != null) 'notes': bovine.notes,
    };
    
    return map;
  }

  // Helpers para convertir enums a String
  String _genderToString(BovineGender gender) {
    switch (gender) {
      case BovineGender.male:
        return 'male';
      case BovineGender.female:
        return 'female';
    }
  }

  String _purposeToString(BovinePurpose purpose) {
    switch (purpose) {
      case BovinePurpose.meat:
        return 'meat';
      case BovinePurpose.milk:
        return 'milk';
      case BovinePurpose.dual:
        return 'dual';
    }
  }

  String _statusToString(BovineStatus status) {
    switch (status) {
      case BovineStatus.active:
        return 'active';
      case BovineStatus.sold:
        return 'sold';
      case BovineStatus.dead:
        return 'dead';
    }
  }

  String _healthStatusToString(HealthStatus healthStatus) {
    switch (healthStatus) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.sick:
        return 'sick';
      case HealthStatus.underTreatment:
        return 'undertreatment';
      case HealthStatus.recovering:
        return 'recovering';
    }
  }

  String _productionStageToString(ProductionStage productionStage) {
    switch (productionStage) {
      case ProductionStage.raising:
        return 'raising';
      case ProductionStage.productive:
        return 'productive';
      case ProductionStage.dry:
        return 'dry';
    }
  }

  String _breedingStatusToString(BreedingStatus breedingStatus) {
    switch (breedingStatus) {
      case BreedingStatus.notSpecified:
        return 'notSpecified';
      case BreedingStatus.pregnant:
        return 'pregnant';
      case BreedingStatus.inseminated:
        return 'inseminated';
      case BreedingStatus.empty:
        return 'empty';
      case BreedingStatus.served:
        return 'served';
    }
  }
}

