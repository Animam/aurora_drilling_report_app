import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Projects extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get odooId => integer().unique()();
  TextColumn get name => text()();
  IntColumn get partnerOdooId => integer().nullable()();
  TextColumn get partnerName => text().nullable()();
  RealColumn get dateDJ => real().nullable()();
  RealColumn get dateDN => real().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class Employees extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get odooId => integer().unique()();
  TextColumn get name => text()();
  TextColumn get jobName => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class Equipments extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get odooId => integer().unique()();
  TextColumn get name => text()();
  TextColumn get categoryName => text().nullable()();
  IntColumn get projectOdooId => integer().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class Tasks extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get odooId => integer().unique()();
  TextColumn get numItem => text().nullable()();
  TextColumn get libelle => text()();
  TextColumn get typeTache => text().nullable()();
  TextColumn get categorieActivity => text().nullable()();
  TextColumn get categorie => text().nullable()();
  TextColumn get typeActivite => text().nullable()();
  TextColumn get updatedAt => text().nullable()();
}

class Locations extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get odooId => integer().unique()();
  TextColumn get name => text()();
  TextColumn get updatedAt => text().nullable()();
}

class MaterialReferences extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get odooId => integer().unique()();
  TextColumn get description => text()();
  TextColumn get reference => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get updatedAt => text().nullable()();
}

class Feuilles extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get mobileUuid => text().unique()();
  IntColumn get odooId => integer().nullable()();

  IntColumn get nomProjetOdooId => integer()();
  TextColumn get quart => text()();
  TextColumn get dateForage => text()();

  IntColumn get foreuseOdooId => integer().nullable()();
  IntColumn get locationOdooId => integer().nullable()();

  IntColumn get hourMeter => integer().nullable()();
  TextColumn get fuelMeter => text().nullable()();
  TextColumn get forageSignature => text().nullable()();
  TextColumn get clientSignature => text().nullable()();
  TextColumn get remarks => text().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

class FeuilleLignes extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get mobileUuid => text().unique()();
  IntColumn get odooId => integer().nullable()();

  IntColumn get feuilleLocalId => integer()();

  TextColumn get item => text()();
  IntColumn get tacheOdooId => integer().nullable()();
  TextColumn get holeNo => text().nullable()();
  TextColumn get note => text().nullable()();

  RealColumn get dateD => real().nullable()();
  RealColumn get dateF => real().nullable()();
  RealColumn get rr => real().nullable()();

  IntColumn get distance => integer().nullable()();
  IntColumn get fromDim => integer().nullable()();
  IntColumn get toDim => integer().nullable()();
  IntColumn get totalDim => integer().nullable()();

  IntColumn get sequence => integer().withDefault(const Constant(10))();

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

class FeuilleFuels extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get mobileUuid => text().unique()();
  IntColumn get odooId => integer().nullable()();

  IntColumn get feuilleLocalId => integer()();

  IntColumn get compresseurOdooId => integer().nullable()();
  RealColumn get qytFuel => real().withDefault(const Constant(0.0))();

  RealColumn get dateDEqui => real().nullable()();
  RealColumn get dateFEqui => real().nullable()();
  RealColumn get dateDRavi => real().nullable()();
  RealColumn get dateFRavi => real().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

class FeuilleEmployes extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get mobileUuid => text().unique()();
  IntColumn get odooId => integer().nullable()();

  IntColumn get feuilleLocalId => integer()();
  IntColumn get employeeOdooId => integer()();

  TextColumn get fonction => text().nullable()();
  TextColumn get observation => text().nullable()();
  TextColumn get dateEmp => text().nullable()();

  TextColumn get dateDebut => text().nullable()();
  TextColumn get dateFin => text().nullable()();
  RealColumn get difference => real().nullable()();

  BoolColumn get absent => boolean().withDefault(const Constant(false))();

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

class FeuilleMateriels extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get mobileUuid => text().unique()();
  IntColumn get odooId => integer().nullable()();

  IntColumn get feuilleLocalId => integer()();

  TextColumn get description => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  RealColumn get quantity => real().nullable()();
  TextColumn get observation => text().nullable()();
  TextColumn get status => text().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dir.path, 'forages_mobile.sqlite'));
//     return NativeDatabase(file);
//   });
// }
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = Directory(
      r'C:\Users\Parfait-SEDOGO\DevOps\forages_mobile_data',
    );
    await dbFolder.create(recursive: true);

    final file = File(p.join(dbFolder.path, 'forages_mobile.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    Projects,
    Employees,
    Equipments,
    Tasks,
    Locations,
    MaterialReferences,
    Feuilles,
    FeuilleLignes,
    FeuilleFuels,
    FeuilleEmployes,
    FeuilleMateriels,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async => m.createAll(),
  );

  Future<void> saveProjects(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      batch.insertAll(
        projects,
        items.map((item) {
          return ProjectsCompanion.insert(
            odooId: (item['odoo_id'] as num).toInt(),
            name: item['name']?.toString() ?? '',
            partnerOdooId: Value((item['partner_odoo_id'] as num?)?.toInt()),
            partnerName: Value(item['partner_name']?.toString()),
            dateDJ: Value((item['date_d_j'] as num?)?.toDouble()),
            dateDN: Value((item['date_d_n'] as num?)?.toDouble()),
            active: Value(item['active'] == true),
            updatedAt: Value(item['updated_at']?.toString()),
          );
        }).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> saveEmployees(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      batch.insertAll(
        employees,
        items.map((item) {
          return EmployeesCompanion.insert(
            odooId: (item['odoo_id'] as num).toInt(),
            name: item['name']?.toString() ?? '',
            jobName: Value(item['job_name']?.toString()),
            active: Value(item['active'] == true),
            updatedAt: Value(item['updated_at']?.toString()),
          );
        }).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> saveEquipments(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      batch.insertAll(
        equipments,
        items.map((item) {
          return EquipmentsCompanion.insert(
            odooId: (item['odoo_id'] as num).toInt(),
            name: item['name']?.toString() ?? '',
            categoryName: Value(item['category_name']?.toString()),
            projectOdooId: Value((item['project_odoo_id'] as num?)?.toInt()),
            active: Value(item['active'] == true),
            updatedAt: Value(item['updated_at']?.toString()),
          );
        }).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> saveTasks(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      batch.insertAll(
        tasks,
        items.map((item) {
          return TasksCompanion.insert(
            odooId: (item['odoo_id'] as num).toInt(),
            numItem: Value(item['num_item']?.toString()),
            libelle: item['libelle']?.toString() ?? '',
            typeTache: Value(item['type_tache']?.toString()),
            categorieActivity: Value(item['categorie_activity']?.toString()),
            categorie: Value(item['categorie']?.toString()),
            typeActivite: Value(item['type_activite']?.toString()),
            updatedAt: Value(item['updated_at']?.toString()),
          );
        }).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> saveLocations(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      batch.insertAll(
        locations,
        items.map((item) {
          return LocationsCompanion.insert(
            odooId: (item['odoo_id'] as num).toInt(),
            name: item['name']?.toString() ?? '',
            updatedAt: Value(item['updated_at']?.toString()),
          );
        }).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> saveMaterialReferences(List<Map<String, dynamic>> items) async {
    await batch((batch) {
      batch.insertAll(
        materialReferences,
        items.map((item) {
          return MaterialReferencesCompanion.insert(
            odooId: (item['odoo_id'] as num).toInt(),
            description: item['description']?.toString() ?? '',
            reference: Value(item['reference']?.toString()),
            active: Value(item['active'] != false),
            updatedAt: Value(item['updated_at']?.toString()),
          );
        }).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<int> saveLocalFeuille({
    required String mobileUuid,
    required int nomProjetOdooId,
    required String quart,
    required String dateForage,
    int? foreuseOdooId,
    int? locationOdooId,
    int? hourMeter,
    String? fuelMeter,
    String? forageSignature,
    String? clientSignature,
    String? remarks,
  }) {
    final now = DateTime.now().toIso8601String();

    return into(feuilles).insert(
      FeuillesCompanion.insert(
        mobileUuid: mobileUuid,
        nomProjetOdooId: nomProjetOdooId,
        quart: quart,
        dateForage: dateForage,
        foreuseOdooId: Value(foreuseOdooId),
        locationOdooId: Value(locationOdooId),
        hourMeter: Value(hourMeter),
        fuelMeter: Value(fuelMeter),
        forageSignature: Value(forageSignature),
        clientSignature: Value(clientSignature),
        remarks: Value(remarks),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> saveLocalFeuilleLigne({
    required int feuilleLocalId,
    required String mobileUuid,
    required String item,
    int? tacheOdooId,
    String? holeNo,
    String? note,
    double? dateD,
    double? dateF,
    double? rr,
    int? distance,
    int? fromDim,
    int? toDim,
    int? totalDim,
    int? sequence,
  }) {
    final now = DateTime.now().toIso8601String();

    return into(feuilleLignes).insert(
      FeuilleLignesCompanion.insert(
        feuilleLocalId: feuilleLocalId,
        mobileUuid: mobileUuid,
        item: item,
        tacheOdooId: Value(tacheOdooId),
        holeNo: Value(holeNo),
        note: Value(note),
        dateD: Value(dateD),
        dateF: Value(dateF),
        rr: Value(rr),
        distance: Value(distance),
        fromDim: Value(fromDim),
        toDim: Value(toDim),
        totalDim: Value(totalDim),
        sequence: Value(sequence ?? 10),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> saveLocalFeuilleFuel({
    required int feuilleLocalId,
    required String mobileUuid,
    int? compresseurOdooId,
    required double qytFuel,
    double? dateDEqui,
    double? dateFEqui,
    double? dateDRavi,
    double? dateFRavi,
  }) {
    final now = DateTime.now().toIso8601String();

    return into(feuilleFuels).insert(
      FeuilleFuelsCompanion.insert(
        feuilleLocalId: feuilleLocalId,
        mobileUuid: mobileUuid,
        compresseurOdooId: Value(compresseurOdooId),
        qytFuel: Value(qytFuel),
        dateDEqui: Value(dateDEqui),
        dateFEqui: Value(dateFEqui),
        dateDRavi: Value(dateDRavi),
        dateFRavi: Value(dateFRavi),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> saveLocalFeuilleEmploye({
    required int feuilleLocalId,
    required String mobileUuid,
    required int employeeOdooId,
    String? fonction,
    String? observation,
    String? dateEmp,
    String? dateDebut,
    String? dateFin,
    double? difference,
    bool absent = false,
  }) {
    final now = DateTime.now().toIso8601String();

    return into(feuilleEmployes).insert(
      FeuilleEmployesCompanion.insert(
        feuilleLocalId: feuilleLocalId,
        mobileUuid: mobileUuid,
        employeeOdooId: employeeOdooId,
        fonction: Value(fonction),
        observation: Value(observation),
        dateEmp: Value(dateEmp),
        dateDebut: Value(dateDebut),
        dateFin: Value(dateFin),
        difference: Value(difference),
        absent: Value(absent),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> saveLocalFeuilleMateriel({
    required int feuilleLocalId,
    required String mobileUuid,
    String? description,
    String? serialNumber,
    double? quantity,
    String? observation,
    String? status,
  }) {
    final now = DateTime.now().toIso8601String();

    return into(feuilleMateriels).insert(
      FeuilleMaterielsCompanion.insert(
        feuilleLocalId: feuilleLocalId,
        mobileUuid: mobileUuid,
        description: Value(description),
        serialNumber: Value(serialNumber),
        quantity: Value(quantity),
        observation: Value(observation),
        status: Value(status),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<FeuilleEmploye>> getEmployesByFeuille(int feuilleLocalId) {
    return (select(feuilleEmployes)
          ..where(
            (tbl) =>
                tbl.feuilleLocalId.equals(feuilleLocalId) &
                tbl.isVisible.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<List<FeuilleMateriel>> getMaterielsByFeuille(int feuilleLocalId) {
    return (select(feuilleMateriels)
          ..where(
            (tbl) =>
                tbl.feuilleLocalId.equals(feuilleLocalId) &
                tbl.isVisible.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<List<FeuilleFuel>> getFuelsByFeuille(int feuilleLocalId) {
    return (select(feuilleFuels)
          ..where(
            (tbl) =>
                tbl.feuilleLocalId.equals(feuilleLocalId) &
                tbl.isVisible.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<double> getTotalFuelByFeuille(int feuilleLocalId) async {
    final rows =
        await (select(feuilleFuels)..where(
              (tbl) =>
                  tbl.feuilleLocalId.equals(feuilleLocalId) &
                  tbl.isVisible.equals(true),
            ))
            .get();

    return rows.fold<double>(0.0, (sum, row) => sum + row.qytFuel);
  }

  Future<List<FeuilleLigne>> getLignesByFeuille(int feuilleLocalId) {
    return (select(feuilleLignes)
          ..where(
            (tbl) =>
                tbl.feuilleLocalId.equals(feuilleLocalId) &
                tbl.isVisible.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sequence)]))
        .get();
  }

  Future<List<Feuille>> getVisibleFeuilles() {
    return (select(feuilles)
          ..where((tbl) => tbl.isVisible.equals(true))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<Feuille?> getFeuilleByLocalId(int feuilleLocalId) {
    return (select(feuilles)..where((tbl) => tbl.localId.equals(feuilleLocalId)))
        .getSingleOrNull();
  }

  Future<List<Feuille>> getPendingFeuilles() {
    return (select(feuilles)
          ..where((tbl) => tbl.isVisible.equals(true) & tbl.syncStatus.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<void> markFeuilleSynced({
    required int feuilleLocalId,
    required int feuilleOdooId,
  }) async {
    final now = DateTime.now().toIso8601String();

    await transaction(() async {
      await (update(feuilles)..where((tbl) => tbl.localId.equals(feuilleLocalId))).write(
        FeuillesCompanion(
          odooId: Value(feuilleOdooId),
          syncStatus: const Value('synced'),
          updatedAt: Value(now),
        ),
      );

      await (update(feuilleLignes)
            ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
          .write(
        FeuilleLignesCompanion(
          syncStatus: const Value('synced'),
          updatedAt: Value(now),
        ),
      );

      await (update(feuilleFuels)
            ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
          .write(
        FeuilleFuelsCompanion(
          syncStatus: const Value('synced'),
          updatedAt: Value(now),
        ),
      );

      await (update(feuilleEmployes)
            ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
          .write(
        FeuilleEmployesCompanion(
          syncStatus: const Value('synced'),
          updatedAt: Value(now),
        ),
      );

      await (update(feuilleMateriels)
            ..where((tbl) => tbl.feuilleLocalId.equals(feuilleLocalId)))
          .write(
        FeuilleMaterielsCompanion(
          syncStatus: const Value('synced'),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<List<Project>> getAllProjects() => select(projects).get();
  Future<List<Employee>> getAllEmployees() => select(employees).get();
  Future<List<Equipment>> getAllEquipments() => select(equipments).get();
  Future<List<Task>> getAllTasks() => select(tasks).get();
  Future<List<Location>> getAllLocations() => select(locations).get();
  Future<List<MaterialReference>> getAllMaterialReferences() => select(materialReferences).get();
}

