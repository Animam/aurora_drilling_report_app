// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerOdooIdMeta = const VerificationMeta(
    'partnerOdooId',
  );
  @override
  late final GeneratedColumn<int> partnerOdooId = GeneratedColumn<int>(
    'partner_odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDJMeta = const VerificationMeta('dateDJ');
  @override
  late final GeneratedColumn<double> dateDJ = GeneratedColumn<double>(
    'date_d_j',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDNMeta = const VerificationMeta('dateDN');
  @override
  late final GeneratedColumn<double> dateDN = GeneratedColumn<double>(
    'date_d_n',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    odooId,
    name,
    partnerOdooId,
    partnerName,
    dateDJ,
    dateDN,
    active,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odooIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('partner_odoo_id')) {
      context.handle(
        _partnerOdooIdMeta,
        partnerOdooId.isAcceptableOrUnknown(
          data['partner_odoo_id']!,
          _partnerOdooIdMeta,
        ),
      );
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('date_d_j')) {
      context.handle(
        _dateDJMeta,
        dateDJ.isAcceptableOrUnknown(data['date_d_j']!, _dateDJMeta),
      );
    }
    if (data.containsKey('date_d_n')) {
      context.handle(
        _dateDNMeta,
        dateDN.isAcceptableOrUnknown(data['date_d_n']!, _dateDNMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      partnerOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partner_odoo_id'],
      ),
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      ),
      dateDJ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_d_j'],
      ),
      dateDN: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_d_n'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int localId;
  final int odooId;
  final String name;
  final int? partnerOdooId;
  final String? partnerName;
  final double? dateDJ;
  final double? dateDN;
  final bool active;
  final String? updatedAt;
  const Project({
    required this.localId,
    required this.odooId,
    required this.name,
    this.partnerOdooId,
    this.partnerName,
    this.dateDJ,
    this.dateDN,
    required this.active,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['odoo_id'] = Variable<int>(odooId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || partnerOdooId != null) {
      map['partner_odoo_id'] = Variable<int>(partnerOdooId);
    }
    if (!nullToAbsent || partnerName != null) {
      map['partner_name'] = Variable<String>(partnerName);
    }
    if (!nullToAbsent || dateDJ != null) {
      map['date_d_j'] = Variable<double>(dateDJ);
    }
    if (!nullToAbsent || dateDN != null) {
      map['date_d_n'] = Variable<double>(dateDN);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      localId: Value(localId),
      odooId: Value(odooId),
      name: Value(name),
      partnerOdooId: partnerOdooId == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerOdooId),
      partnerName: partnerName == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerName),
      dateDJ: dateDJ == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDJ),
      dateDN: dateDN == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDN),
      active: Value(active),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      localId: serializer.fromJson<int>(json['localId']),
      odooId: serializer.fromJson<int>(json['odooId']),
      name: serializer.fromJson<String>(json['name']),
      partnerOdooId: serializer.fromJson<int?>(json['partnerOdooId']),
      partnerName: serializer.fromJson<String?>(json['partnerName']),
      dateDJ: serializer.fromJson<double?>(json['dateDJ']),
      dateDN: serializer.fromJson<double?>(json['dateDN']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'odooId': serializer.toJson<int>(odooId),
      'name': serializer.toJson<String>(name),
      'partnerOdooId': serializer.toJson<int?>(partnerOdooId),
      'partnerName': serializer.toJson<String?>(partnerName),
      'dateDJ': serializer.toJson<double?>(dateDJ),
      'dateDN': serializer.toJson<double?>(dateDN),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Project copyWith({
    int? localId,
    int? odooId,
    String? name,
    Value<int?> partnerOdooId = const Value.absent(),
    Value<String?> partnerName = const Value.absent(),
    Value<double?> dateDJ = const Value.absent(),
    Value<double?> dateDN = const Value.absent(),
    bool? active,
    Value<String?> updatedAt = const Value.absent(),
  }) => Project(
    localId: localId ?? this.localId,
    odooId: odooId ?? this.odooId,
    name: name ?? this.name,
    partnerOdooId: partnerOdooId.present
        ? partnerOdooId.value
        : this.partnerOdooId,
    partnerName: partnerName.present ? partnerName.value : this.partnerName,
    dateDJ: dateDJ.present ? dateDJ.value : this.dateDJ,
    dateDN: dateDN.present ? dateDN.value : this.dateDN,
    active: active ?? this.active,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      localId: data.localId.present ? data.localId.value : this.localId,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      name: data.name.present ? data.name.value : this.name,
      partnerOdooId: data.partnerOdooId.present
          ? data.partnerOdooId.value
          : this.partnerOdooId,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      dateDJ: data.dateDJ.present ? data.dateDJ.value : this.dateDJ,
      dateDN: data.dateDN.present ? data.dateDN.value : this.dateDN,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('partnerOdooId: $partnerOdooId, ')
          ..write('partnerName: $partnerName, ')
          ..write('dateDJ: $dateDJ, ')
          ..write('dateDN: $dateDN, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    odooId,
    name,
    partnerOdooId,
    partnerName,
    dateDJ,
    dateDN,
    active,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.localId == this.localId &&
          other.odooId == this.odooId &&
          other.name == this.name &&
          other.partnerOdooId == this.partnerOdooId &&
          other.partnerName == this.partnerName &&
          other.dateDJ == this.dateDJ &&
          other.dateDN == this.dateDN &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> localId;
  final Value<int> odooId;
  final Value<String> name;
  final Value<int?> partnerOdooId;
  final Value<String?> partnerName;
  final Value<double?> dateDJ;
  final Value<double?> dateDN;
  final Value<bool> active;
  final Value<String?> updatedAt;
  const ProjectsCompanion({
    this.localId = const Value.absent(),
    this.odooId = const Value.absent(),
    this.name = const Value.absent(),
    this.partnerOdooId = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.dateDJ = const Value.absent(),
    this.dateDN = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.localId = const Value.absent(),
    required int odooId,
    required String name,
    this.partnerOdooId = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.dateDJ = const Value.absent(),
    this.dateDN = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : odooId = Value(odooId),
       name = Value(name);
  static Insertable<Project> custom({
    Expression<int>? localId,
    Expression<int>? odooId,
    Expression<String>? name,
    Expression<int>? partnerOdooId,
    Expression<String>? partnerName,
    Expression<double>? dateDJ,
    Expression<double>? dateDN,
    Expression<bool>? active,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (odooId != null) 'odoo_id': odooId,
      if (name != null) 'name': name,
      if (partnerOdooId != null) 'partner_odoo_id': partnerOdooId,
      if (partnerName != null) 'partner_name': partnerName,
      if (dateDJ != null) 'date_d_j': dateDJ,
      if (dateDN != null) 'date_d_n': dateDN,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? localId,
    Value<int>? odooId,
    Value<String>? name,
    Value<int?>? partnerOdooId,
    Value<String?>? partnerName,
    Value<double?>? dateDJ,
    Value<double?>? dateDN,
    Value<bool>? active,
    Value<String?>? updatedAt,
  }) {
    return ProjectsCompanion(
      localId: localId ?? this.localId,
      odooId: odooId ?? this.odooId,
      name: name ?? this.name,
      partnerOdooId: partnerOdooId ?? this.partnerOdooId,
      partnerName: partnerName ?? this.partnerName,
      dateDJ: dateDJ ?? this.dateDJ,
      dateDN: dateDN ?? this.dateDN,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (partnerOdooId.present) {
      map['partner_odoo_id'] = Variable<int>(partnerOdooId.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (dateDJ.present) {
      map['date_d_j'] = Variable<double>(dateDJ.value);
    }
    if (dateDN.present) {
      map['date_d_n'] = Variable<double>(dateDN.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('partnerOdooId: $partnerOdooId, ')
          ..write('partnerName: $partnerName, ')
          ..write('dateDJ: $dateDJ, ')
          ..write('dateDN: $dateDN, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobNameMeta = const VerificationMeta(
    'jobName',
  );
  @override
  late final GeneratedColumn<String> jobName = GeneratedColumn<String>(
    'job_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    odooId,
    name,
    jobName,
    active,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<Employee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odooIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('job_name')) {
      context.handle(
        _jobNameMeta,
        jobName.isAcceptableOrUnknown(data['job_name']!, _jobNameMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      jobName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_name'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class Employee extends DataClass implements Insertable<Employee> {
  final int localId;
  final int odooId;
  final String name;
  final String? jobName;
  final bool active;
  final String? updatedAt;
  const Employee({
    required this.localId,
    required this.odooId,
    required this.name,
    this.jobName,
    required this.active,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['odoo_id'] = Variable<int>(odooId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || jobName != null) {
      map['job_name'] = Variable<String>(jobName);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      localId: Value(localId),
      odooId: Value(odooId),
      name: Value(name),
      jobName: jobName == null && nullToAbsent
          ? const Value.absent()
          : Value(jobName),
      active: Value(active),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Employee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      localId: serializer.fromJson<int>(json['localId']),
      odooId: serializer.fromJson<int>(json['odooId']),
      name: serializer.fromJson<String>(json['name']),
      jobName: serializer.fromJson<String?>(json['jobName']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'odooId': serializer.toJson<int>(odooId),
      'name': serializer.toJson<String>(name),
      'jobName': serializer.toJson<String?>(jobName),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Employee copyWith({
    int? localId,
    int? odooId,
    String? name,
    Value<String?> jobName = const Value.absent(),
    bool? active,
    Value<String?> updatedAt = const Value.absent(),
  }) => Employee(
    localId: localId ?? this.localId,
    odooId: odooId ?? this.odooId,
    name: name ?? this.name,
    jobName: jobName.present ? jobName.value : this.jobName,
    active: active ?? this.active,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      localId: data.localId.present ? data.localId.value : this.localId,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      name: data.name.present ? data.name.value : this.name,
      jobName: data.jobName.present ? data.jobName.value : this.jobName,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('jobName: $jobName, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localId, odooId, name, jobName, active, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.localId == this.localId &&
          other.odooId == this.odooId &&
          other.name == this.name &&
          other.jobName == this.jobName &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<int> localId;
  final Value<int> odooId;
  final Value<String> name;
  final Value<String?> jobName;
  final Value<bool> active;
  final Value<String?> updatedAt;
  const EmployeesCompanion({
    this.localId = const Value.absent(),
    this.odooId = const Value.absent(),
    this.name = const Value.absent(),
    this.jobName = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.localId = const Value.absent(),
    required int odooId,
    required String name,
    this.jobName = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : odooId = Value(odooId),
       name = Value(name);
  static Insertable<Employee> custom({
    Expression<int>? localId,
    Expression<int>? odooId,
    Expression<String>? name,
    Expression<String>? jobName,
    Expression<bool>? active,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (odooId != null) 'odoo_id': odooId,
      if (name != null) 'name': name,
      if (jobName != null) 'job_name': jobName,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EmployeesCompanion copyWith({
    Value<int>? localId,
    Value<int>? odooId,
    Value<String>? name,
    Value<String?>? jobName,
    Value<bool>? active,
    Value<String?>? updatedAt,
  }) {
    return EmployeesCompanion(
      localId: localId ?? this.localId,
      odooId: odooId ?? this.odooId,
      name: name ?? this.name,
      jobName: jobName ?? this.jobName,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (jobName.present) {
      map['job_name'] = Variable<String>(jobName.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('jobName: $jobName, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EquipmentsTable extends Equipments
    with TableInfo<$EquipmentsTable, Equipment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectOdooIdMeta = const VerificationMeta(
    'projectOdooId',
  );
  @override
  late final GeneratedColumn<int> projectOdooId = GeneratedColumn<int>(
    'project_odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    odooId,
    name,
    categoryName,
    projectOdooId,
    active,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Equipment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odooIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('project_odoo_id')) {
      context.handle(
        _projectOdooIdMeta,
        projectOdooId.isAcceptableOrUnknown(
          data['project_odoo_id']!,
          _projectOdooIdMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Equipment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipment(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      projectOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_odoo_id'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $EquipmentsTable createAlias(String alias) {
    return $EquipmentsTable(attachedDatabase, alias);
  }
}

class Equipment extends DataClass implements Insertable<Equipment> {
  final int localId;
  final int odooId;
  final String name;
  final String? categoryName;
  final int? projectOdooId;
  final bool active;
  final String? updatedAt;
  const Equipment({
    required this.localId,
    required this.odooId,
    required this.name,
    this.categoryName,
    this.projectOdooId,
    required this.active,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['odoo_id'] = Variable<int>(odooId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || projectOdooId != null) {
      map['project_odoo_id'] = Variable<int>(projectOdooId);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  EquipmentsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentsCompanion(
      localId: Value(localId),
      odooId: Value(odooId),
      name: Value(name),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      projectOdooId: projectOdooId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectOdooId),
      active: Value(active),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Equipment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Equipment(
      localId: serializer.fromJson<int>(json['localId']),
      odooId: serializer.fromJson<int>(json['odooId']),
      name: serializer.fromJson<String>(json['name']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      projectOdooId: serializer.fromJson<int?>(json['projectOdooId']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'odooId': serializer.toJson<int>(odooId),
      'name': serializer.toJson<String>(name),
      'categoryName': serializer.toJson<String?>(categoryName),
      'projectOdooId': serializer.toJson<int?>(projectOdooId),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Equipment copyWith({
    int? localId,
    int? odooId,
    String? name,
    Value<String?> categoryName = const Value.absent(),
    Value<int?> projectOdooId = const Value.absent(),
    bool? active,
    Value<String?> updatedAt = const Value.absent(),
  }) => Equipment(
    localId: localId ?? this.localId,
    odooId: odooId ?? this.odooId,
    name: name ?? this.name,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    projectOdooId: projectOdooId.present
        ? projectOdooId.value
        : this.projectOdooId,
    active: active ?? this.active,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Equipment copyWithCompanion(EquipmentsCompanion data) {
    return Equipment(
      localId: data.localId.present ? data.localId.value : this.localId,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      name: data.name.present ? data.name.value : this.name,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      projectOdooId: data.projectOdooId.present
          ? data.projectOdooId.value
          : this.projectOdooId,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Equipment(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('categoryName: $categoryName, ')
          ..write('projectOdooId: $projectOdooId, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    odooId,
    name,
    categoryName,
    projectOdooId,
    active,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equipment &&
          other.localId == this.localId &&
          other.odooId == this.odooId &&
          other.name == this.name &&
          other.categoryName == this.categoryName &&
          other.projectOdooId == this.projectOdooId &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt);
}

class EquipmentsCompanion extends UpdateCompanion<Equipment> {
  final Value<int> localId;
  final Value<int> odooId;
  final Value<String> name;
  final Value<String?> categoryName;
  final Value<int?> projectOdooId;
  final Value<bool> active;
  final Value<String?> updatedAt;
  const EquipmentsCompanion({
    this.localId = const Value.absent(),
    this.odooId = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.projectOdooId = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EquipmentsCompanion.insert({
    this.localId = const Value.absent(),
    required int odooId,
    required String name,
    this.categoryName = const Value.absent(),
    this.projectOdooId = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : odooId = Value(odooId),
       name = Value(name);
  static Insertable<Equipment> custom({
    Expression<int>? localId,
    Expression<int>? odooId,
    Expression<String>? name,
    Expression<String>? categoryName,
    Expression<int>? projectOdooId,
    Expression<bool>? active,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (odooId != null) 'odoo_id': odooId,
      if (name != null) 'name': name,
      if (categoryName != null) 'category_name': categoryName,
      if (projectOdooId != null) 'project_odoo_id': projectOdooId,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EquipmentsCompanion copyWith({
    Value<int>? localId,
    Value<int>? odooId,
    Value<String>? name,
    Value<String?>? categoryName,
    Value<int?>? projectOdooId,
    Value<bool>? active,
    Value<String?>? updatedAt,
  }) {
    return EquipmentsCompanion(
      localId: localId ?? this.localId,
      odooId: odooId ?? this.odooId,
      name: name ?? this.name,
      categoryName: categoryName ?? this.categoryName,
      projectOdooId: projectOdooId ?? this.projectOdooId,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (projectOdooId.present) {
      map['project_odoo_id'] = Variable<int>(projectOdooId.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentsCompanion(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('categoryName: $categoryName, ')
          ..write('projectOdooId: $projectOdooId, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _numItemMeta = const VerificationMeta(
    'numItem',
  );
  @override
  late final GeneratedColumn<String> numItem = GeneratedColumn<String>(
    'num_item',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _libelleMeta = const VerificationMeta(
    'libelle',
  );
  @override
  late final GeneratedColumn<String> libelle = GeneratedColumn<String>(
    'libelle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeTacheMeta = const VerificationMeta(
    'typeTache',
  );
  @override
  late final GeneratedColumn<String> typeTache = GeneratedColumn<String>(
    'type_tache',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categorieActivityMeta = const VerificationMeta(
    'categorieActivity',
  );
  @override
  late final GeneratedColumn<String> categorieActivity =
      GeneratedColumn<String>(
        'categorie_activity',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categorieMeta = const VerificationMeta(
    'categorie',
  );
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
    'categorie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeActiviteMeta = const VerificationMeta(
    'typeActivite',
  );
  @override
  late final GeneratedColumn<String> typeActivite = GeneratedColumn<String>(
    'type_activite',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    odooId,
    numItem,
    libelle,
    typeTache,
    categorieActivity,
    categorie,
    typeActivite,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odooIdMeta);
    }
    if (data.containsKey('num_item')) {
      context.handle(
        _numItemMeta,
        numItem.isAcceptableOrUnknown(data['num_item']!, _numItemMeta),
      );
    }
    if (data.containsKey('libelle')) {
      context.handle(
        _libelleMeta,
        libelle.isAcceptableOrUnknown(data['libelle']!, _libelleMeta),
      );
    } else if (isInserting) {
      context.missing(_libelleMeta);
    }
    if (data.containsKey('type_tache')) {
      context.handle(
        _typeTacheMeta,
        typeTache.isAcceptableOrUnknown(data['type_tache']!, _typeTacheMeta),
      );
    }
    if (data.containsKey('categorie_activity')) {
      context.handle(
        _categorieActivityMeta,
        categorieActivity.isAcceptableOrUnknown(
          data['categorie_activity']!,
          _categorieActivityMeta,
        ),
      );
    }
    if (data.containsKey('categorie')) {
      context.handle(
        _categorieMeta,
        categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta),
      );
    }
    if (data.containsKey('type_activite')) {
      context.handle(
        _typeActiviteMeta,
        typeActivite.isAcceptableOrUnknown(
          data['type_activite']!,
          _typeActiviteMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      )!,
      numItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}num_item'],
      ),
      libelle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}libelle'],
      )!,
      typeTache: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_tache'],
      ),
      categorieActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie_activity'],
      ),
      categorie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie'],
      ),
      typeActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_activite'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int localId;
  final int odooId;
  final String? numItem;
  final String libelle;
  final String? typeTache;
  final String? categorieActivity;
  final String? categorie;
  final String? typeActivite;
  final String? updatedAt;
  const Task({
    required this.localId,
    required this.odooId,
    this.numItem,
    required this.libelle,
    this.typeTache,
    this.categorieActivity,
    this.categorie,
    this.typeActivite,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['odoo_id'] = Variable<int>(odooId);
    if (!nullToAbsent || numItem != null) {
      map['num_item'] = Variable<String>(numItem);
    }
    map['libelle'] = Variable<String>(libelle);
    if (!nullToAbsent || typeTache != null) {
      map['type_tache'] = Variable<String>(typeTache);
    }
    if (!nullToAbsent || categorieActivity != null) {
      map['categorie_activity'] = Variable<String>(categorieActivity);
    }
    if (!nullToAbsent || categorie != null) {
      map['categorie'] = Variable<String>(categorie);
    }
    if (!nullToAbsent || typeActivite != null) {
      map['type_activite'] = Variable<String>(typeActivite);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      localId: Value(localId),
      odooId: Value(odooId),
      numItem: numItem == null && nullToAbsent
          ? const Value.absent()
          : Value(numItem),
      libelle: Value(libelle),
      typeTache: typeTache == null && nullToAbsent
          ? const Value.absent()
          : Value(typeTache),
      categorieActivity: categorieActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(categorieActivity),
      categorie: categorie == null && nullToAbsent
          ? const Value.absent()
          : Value(categorie),
      typeActivite: typeActivite == null && nullToAbsent
          ? const Value.absent()
          : Value(typeActivite),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      localId: serializer.fromJson<int>(json['localId']),
      odooId: serializer.fromJson<int>(json['odooId']),
      numItem: serializer.fromJson<String?>(json['numItem']),
      libelle: serializer.fromJson<String>(json['libelle']),
      typeTache: serializer.fromJson<String?>(json['typeTache']),
      categorieActivity: serializer.fromJson<String?>(
        json['categorieActivity'],
      ),
      categorie: serializer.fromJson<String?>(json['categorie']),
      typeActivite: serializer.fromJson<String?>(json['typeActivite']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'odooId': serializer.toJson<int>(odooId),
      'numItem': serializer.toJson<String?>(numItem),
      'libelle': serializer.toJson<String>(libelle),
      'typeTache': serializer.toJson<String?>(typeTache),
      'categorieActivity': serializer.toJson<String?>(categorieActivity),
      'categorie': serializer.toJson<String?>(categorie),
      'typeActivite': serializer.toJson<String?>(typeActivite),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Task copyWith({
    int? localId,
    int? odooId,
    Value<String?> numItem = const Value.absent(),
    String? libelle,
    Value<String?> typeTache = const Value.absent(),
    Value<String?> categorieActivity = const Value.absent(),
    Value<String?> categorie = const Value.absent(),
    Value<String?> typeActivite = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => Task(
    localId: localId ?? this.localId,
    odooId: odooId ?? this.odooId,
    numItem: numItem.present ? numItem.value : this.numItem,
    libelle: libelle ?? this.libelle,
    typeTache: typeTache.present ? typeTache.value : this.typeTache,
    categorieActivity: categorieActivity.present
        ? categorieActivity.value
        : this.categorieActivity,
    categorie: categorie.present ? categorie.value : this.categorie,
    typeActivite: typeActivite.present ? typeActivite.value : this.typeActivite,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      localId: data.localId.present ? data.localId.value : this.localId,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      numItem: data.numItem.present ? data.numItem.value : this.numItem,
      libelle: data.libelle.present ? data.libelle.value : this.libelle,
      typeTache: data.typeTache.present ? data.typeTache.value : this.typeTache,
      categorieActivity: data.categorieActivity.present
          ? data.categorieActivity.value
          : this.categorieActivity,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      typeActivite: data.typeActivite.present
          ? data.typeActivite.value
          : this.typeActivite,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('numItem: $numItem, ')
          ..write('libelle: $libelle, ')
          ..write('typeTache: $typeTache, ')
          ..write('categorieActivity: $categorieActivity, ')
          ..write('categorie: $categorie, ')
          ..write('typeActivite: $typeActivite, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    odooId,
    numItem,
    libelle,
    typeTache,
    categorieActivity,
    categorie,
    typeActivite,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.localId == this.localId &&
          other.odooId == this.odooId &&
          other.numItem == this.numItem &&
          other.libelle == this.libelle &&
          other.typeTache == this.typeTache &&
          other.categorieActivity == this.categorieActivity &&
          other.categorie == this.categorie &&
          other.typeActivite == this.typeActivite &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> localId;
  final Value<int> odooId;
  final Value<String?> numItem;
  final Value<String> libelle;
  final Value<String?> typeTache;
  final Value<String?> categorieActivity;
  final Value<String?> categorie;
  final Value<String?> typeActivite;
  final Value<String?> updatedAt;
  const TasksCompanion({
    this.localId = const Value.absent(),
    this.odooId = const Value.absent(),
    this.numItem = const Value.absent(),
    this.libelle = const Value.absent(),
    this.typeTache = const Value.absent(),
    this.categorieActivity = const Value.absent(),
    this.categorie = const Value.absent(),
    this.typeActivite = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.localId = const Value.absent(),
    required int odooId,
    this.numItem = const Value.absent(),
    required String libelle,
    this.typeTache = const Value.absent(),
    this.categorieActivity = const Value.absent(),
    this.categorie = const Value.absent(),
    this.typeActivite = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : odooId = Value(odooId),
       libelle = Value(libelle);
  static Insertable<Task> custom({
    Expression<int>? localId,
    Expression<int>? odooId,
    Expression<String>? numItem,
    Expression<String>? libelle,
    Expression<String>? typeTache,
    Expression<String>? categorieActivity,
    Expression<String>? categorie,
    Expression<String>? typeActivite,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (odooId != null) 'odoo_id': odooId,
      if (numItem != null) 'num_item': numItem,
      if (libelle != null) 'libelle': libelle,
      if (typeTache != null) 'type_tache': typeTache,
      if (categorieActivity != null) 'categorie_activity': categorieActivity,
      if (categorie != null) 'categorie': categorie,
      if (typeActivite != null) 'type_activite': typeActivite,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? localId,
    Value<int>? odooId,
    Value<String?>? numItem,
    Value<String>? libelle,
    Value<String?>? typeTache,
    Value<String?>? categorieActivity,
    Value<String?>? categorie,
    Value<String?>? typeActivite,
    Value<String?>? updatedAt,
  }) {
    return TasksCompanion(
      localId: localId ?? this.localId,
      odooId: odooId ?? this.odooId,
      numItem: numItem ?? this.numItem,
      libelle: libelle ?? this.libelle,
      typeTache: typeTache ?? this.typeTache,
      categorieActivity: categorieActivity ?? this.categorieActivity,
      categorie: categorie ?? this.categorie,
      typeActivite: typeActivite ?? this.typeActivite,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (numItem.present) {
      map['num_item'] = Variable<String>(numItem.value);
    }
    if (libelle.present) {
      map['libelle'] = Variable<String>(libelle.value);
    }
    if (typeTache.present) {
      map['type_tache'] = Variable<String>(typeTache.value);
    }
    if (categorieActivity.present) {
      map['categorie_activity'] = Variable<String>(categorieActivity.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (typeActivite.present) {
      map['type_activite'] = Variable<String>(typeActivite.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('numItem: $numItem, ')
          ..write('libelle: $libelle, ')
          ..write('typeTache: $typeTache, ')
          ..write('categorieActivity: $categorieActivity, ')
          ..write('categorie: $categorie, ')
          ..write('typeActivite: $typeActivite, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [localId, odooId, name, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Location> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odooIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final int localId;
  final int odooId;
  final String name;
  final String? updatedAt;
  const Location({
    required this.localId,
    required this.odooId,
    required this.name,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['odoo_id'] = Variable<int>(odooId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      localId: Value(localId),
      odooId: Value(odooId),
      name: Value(name),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Location.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      localId: serializer.fromJson<int>(json['localId']),
      odooId: serializer.fromJson<int>(json['odooId']),
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'odooId': serializer.toJson<int>(odooId),
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  Location copyWith({
    int? localId,
    int? odooId,
    String? name,
    Value<String?> updatedAt = const Value.absent(),
  }) => Location(
    localId: localId ?? this.localId,
    odooId: odooId ?? this.odooId,
    name: name ?? this.name,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      localId: data.localId.present ? data.localId.value : this.localId,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, odooId, name, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.localId == this.localId &&
          other.odooId == this.odooId &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<int> localId;
  final Value<int> odooId;
  final Value<String> name;
  final Value<String?> updatedAt;
  const LocationsCompanion({
    this.localId = const Value.absent(),
    this.odooId = const Value.absent(),
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocationsCompanion.insert({
    this.localId = const Value.absent(),
    required int odooId,
    required String name,
    this.updatedAt = const Value.absent(),
  }) : odooId = Value(odooId),
       name = Value(name);
  static Insertable<Location> custom({
    Expression<int>? localId,
    Expression<int>? odooId,
    Expression<String>? name,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (odooId != null) 'odoo_id': odooId,
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocationsCompanion copyWith({
    Value<int>? localId,
    Value<int>? odooId,
    Value<String>? name,
    Value<String?>? updatedAt,
  }) {
    return LocationsCompanion(
      localId: localId ?? this.localId,
      odooId: odooId ?? this.odooId,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MaterialReferencesTable extends MaterialReferences
    with TableInfo<$MaterialReferencesTable, MaterialReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialReferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    odooId,
    description,
    reference,
    active,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    } else if (isInserting) {
      context.missing(_odooIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  MaterialReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialReference(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $MaterialReferencesTable createAlias(String alias) {
    return $MaterialReferencesTable(attachedDatabase, alias);
  }
}

class MaterialReference extends DataClass
    implements Insertable<MaterialReference> {
  final int localId;
  final int odooId;
  final String description;
  final String? reference;
  final bool active;
  final String? updatedAt;
  const MaterialReference({
    required this.localId,
    required this.odooId,
    required this.description,
    this.reference,
    required this.active,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['odoo_id'] = Variable<int>(odooId);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  MaterialReferencesCompanion toCompanion(bool nullToAbsent) {
    return MaterialReferencesCompanion(
      localId: Value(localId),
      odooId: Value(odooId),
      description: Value(description),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      active: Value(active),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory MaterialReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialReference(
      localId: serializer.fromJson<int>(json['localId']),
      odooId: serializer.fromJson<int>(json['odooId']),
      description: serializer.fromJson<String>(json['description']),
      reference: serializer.fromJson<String?>(json['reference']),
      active: serializer.fromJson<bool>(json['active']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'odooId': serializer.toJson<int>(odooId),
      'description': serializer.toJson<String>(description),
      'reference': serializer.toJson<String?>(reference),
      'active': serializer.toJson<bool>(active),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  MaterialReference copyWith({
    int? localId,
    int? odooId,
    String? description,
    Value<String?> reference = const Value.absent(),
    bool? active,
    Value<String?> updatedAt = const Value.absent(),
  }) => MaterialReference(
    localId: localId ?? this.localId,
    odooId: odooId ?? this.odooId,
    description: description ?? this.description,
    reference: reference.present ? reference.value : this.reference,
    active: active ?? this.active,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  MaterialReference copyWithCompanion(MaterialReferencesCompanion data) {
    return MaterialReference(
      localId: data.localId.present ? data.localId.value : this.localId,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      description: data.description.present
          ? data.description.value
          : this.description,
      reference: data.reference.present ? data.reference.value : this.reference,
      active: data.active.present ? data.active.value : this.active,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialReference(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('description: $description, ')
          ..write('reference: $reference, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localId, odooId, description, reference, active, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialReference &&
          other.localId == this.localId &&
          other.odooId == this.odooId &&
          other.description == this.description &&
          other.reference == this.reference &&
          other.active == this.active &&
          other.updatedAt == this.updatedAt);
}

class MaterialReferencesCompanion extends UpdateCompanion<MaterialReference> {
  final Value<int> localId;
  final Value<int> odooId;
  final Value<String> description;
  final Value<String?> reference;
  final Value<bool> active;
  final Value<String?> updatedAt;
  const MaterialReferencesCompanion({
    this.localId = const Value.absent(),
    this.odooId = const Value.absent(),
    this.description = const Value.absent(),
    this.reference = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaterialReferencesCompanion.insert({
    this.localId = const Value.absent(),
    required int odooId,
    required String description,
    this.reference = const Value.absent(),
    this.active = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : odooId = Value(odooId),
       description = Value(description);
  static Insertable<MaterialReference> custom({
    Expression<int>? localId,
    Expression<int>? odooId,
    Expression<String>? description,
    Expression<String>? reference,
    Expression<bool>? active,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (odooId != null) 'odoo_id': odooId,
      if (description != null) 'description': description,
      if (reference != null) 'reference': reference,
      if (active != null) 'active': active,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaterialReferencesCompanion copyWith({
    Value<int>? localId,
    Value<int>? odooId,
    Value<String>? description,
    Value<String?>? reference,
    Value<bool>? active,
    Value<String?>? updatedAt,
  }) {
    return MaterialReferencesCompanion(
      localId: localId ?? this.localId,
      odooId: odooId ?? this.odooId,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialReferencesCompanion(')
          ..write('localId: $localId, ')
          ..write('odooId: $odooId, ')
          ..write('description: $description, ')
          ..write('reference: $reference, ')
          ..write('active: $active, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeuillesTable extends Feuilles with TableInfo<$FeuillesTable, Feuille> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeuillesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mobileUuidMeta = const VerificationMeta(
    'mobileUuid',
  );
  @override
  late final GeneratedColumn<String> mobileUuid = GeneratedColumn<String>(
    'mobile_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomProjetOdooIdMeta = const VerificationMeta(
    'nomProjetOdooId',
  );
  @override
  late final GeneratedColumn<int> nomProjetOdooId = GeneratedColumn<int>(
    'nom_projet_odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quartMeta = const VerificationMeta('quart');
  @override
  late final GeneratedColumn<String> quart = GeneratedColumn<String>(
    'quart',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateForageMeta = const VerificationMeta(
    'dateForage',
  );
  @override
  late final GeneratedColumn<String> dateForage = GeneratedColumn<String>(
    'date_forage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foreuseOdooIdMeta = const VerificationMeta(
    'foreuseOdooId',
  );
  @override
  late final GeneratedColumn<int> foreuseOdooId = GeneratedColumn<int>(
    'foreuse_odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationOdooIdMeta = const VerificationMeta(
    'locationOdooId',
  );
  @override
  late final GeneratedColumn<int> locationOdooId = GeneratedColumn<int>(
    'location_odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourMeterMeta = const VerificationMeta(
    'hourMeter',
  );
  @override
  late final GeneratedColumn<int> hourMeter = GeneratedColumn<int>(
    'hour_meter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelMeterMeta = const VerificationMeta(
    'fuelMeter',
  );
  @override
  late final GeneratedColumn<String> fuelMeter = GeneratedColumn<String>(
    'fuel_meter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forageSignatureMeta = const VerificationMeta(
    'forageSignature',
  );
  @override
  late final GeneratedColumn<String> forageSignature = GeneratedColumn<String>(
    'forage_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientSignatureMeta = const VerificationMeta(
    'clientSignature',
  );
  @override
  late final GeneratedColumn<String> clientSignature = GeneratedColumn<String>(
    'client_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    mobileUuid,
    odooId,
    nomProjetOdooId,
    quart,
    dateForage,
    foreuseOdooId,
    locationOdooId,
    hourMeter,
    fuelMeter,
    forageSignature,
    clientSignature,
    remarks,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feuilles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Feuille> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('mobile_uuid')) {
      context.handle(
        _mobileUuidMeta,
        mobileUuid.isAcceptableOrUnknown(data['mobile_uuid']!, _mobileUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileUuidMeta);
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    }
    if (data.containsKey('nom_projet_odoo_id')) {
      context.handle(
        _nomProjetOdooIdMeta,
        nomProjetOdooId.isAcceptableOrUnknown(
          data['nom_projet_odoo_id']!,
          _nomProjetOdooIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nomProjetOdooIdMeta);
    }
    if (data.containsKey('quart')) {
      context.handle(
        _quartMeta,
        quart.isAcceptableOrUnknown(data['quart']!, _quartMeta),
      );
    } else if (isInserting) {
      context.missing(_quartMeta);
    }
    if (data.containsKey('date_forage')) {
      context.handle(
        _dateForageMeta,
        dateForage.isAcceptableOrUnknown(data['date_forage']!, _dateForageMeta),
      );
    } else if (isInserting) {
      context.missing(_dateForageMeta);
    }
    if (data.containsKey('foreuse_odoo_id')) {
      context.handle(
        _foreuseOdooIdMeta,
        foreuseOdooId.isAcceptableOrUnknown(
          data['foreuse_odoo_id']!,
          _foreuseOdooIdMeta,
        ),
      );
    }
    if (data.containsKey('location_odoo_id')) {
      context.handle(
        _locationOdooIdMeta,
        locationOdooId.isAcceptableOrUnknown(
          data['location_odoo_id']!,
          _locationOdooIdMeta,
        ),
      );
    }
    if (data.containsKey('hour_meter')) {
      context.handle(
        _hourMeterMeta,
        hourMeter.isAcceptableOrUnknown(data['hour_meter']!, _hourMeterMeta),
      );
    }
    if (data.containsKey('fuel_meter')) {
      context.handle(
        _fuelMeterMeta,
        fuelMeter.isAcceptableOrUnknown(data['fuel_meter']!, _fuelMeterMeta),
      );
    }
    if (data.containsKey('forage_signature')) {
      context.handle(
        _forageSignatureMeta,
        forageSignature.isAcceptableOrUnknown(
          data['forage_signature']!,
          _forageSignatureMeta,
        ),
      );
    }
    if (data.containsKey('client_signature')) {
      context.handle(
        _clientSignatureMeta,
        clientSignature.isAcceptableOrUnknown(
          data['client_signature']!,
          _clientSignatureMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Feuille map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Feuille(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      mobileUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_uuid'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      ),
      nomProjetOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nom_projet_odoo_id'],
      )!,
      quart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quart'],
      )!,
      dateForage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_forage'],
      )!,
      foreuseOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}foreuse_odoo_id'],
      ),
      locationOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_odoo_id'],
      ),
      hourMeter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour_meter'],
      ),
      fuelMeter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_meter'],
      ),
      forageSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forage_signature'],
      ),
      clientSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_signature'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeuillesTable createAlias(String alias) {
    return $FeuillesTable(attachedDatabase, alias);
  }
}

class Feuille extends DataClass implements Insertable<Feuille> {
  final int localId;
  final String mobileUuid;
  final int? odooId;
  final int nomProjetOdooId;
  final String quart;
  final String dateForage;
  final int? foreuseOdooId;
  final int? locationOdooId;
  final int? hourMeter;
  final String? fuelMeter;
  final String? forageSignature;
  final String? clientSignature;
  final String? remarks;
  final String syncStatus;
  final bool isVisible;
  final String createdAt;
  final String updatedAt;
  const Feuille({
    required this.localId,
    required this.mobileUuid,
    this.odooId,
    required this.nomProjetOdooId,
    required this.quart,
    required this.dateForage,
    this.foreuseOdooId,
    this.locationOdooId,
    this.hourMeter,
    this.fuelMeter,
    this.forageSignature,
    this.clientSignature,
    this.remarks,
    required this.syncStatus,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['mobile_uuid'] = Variable<String>(mobileUuid);
    if (!nullToAbsent || odooId != null) {
      map['odoo_id'] = Variable<int>(odooId);
    }
    map['nom_projet_odoo_id'] = Variable<int>(nomProjetOdooId);
    map['quart'] = Variable<String>(quart);
    map['date_forage'] = Variable<String>(dateForage);
    if (!nullToAbsent || foreuseOdooId != null) {
      map['foreuse_odoo_id'] = Variable<int>(foreuseOdooId);
    }
    if (!nullToAbsent || locationOdooId != null) {
      map['location_odoo_id'] = Variable<int>(locationOdooId);
    }
    if (!nullToAbsent || hourMeter != null) {
      map['hour_meter'] = Variable<int>(hourMeter);
    }
    if (!nullToAbsent || fuelMeter != null) {
      map['fuel_meter'] = Variable<String>(fuelMeter);
    }
    if (!nullToAbsent || forageSignature != null) {
      map['forage_signature'] = Variable<String>(forageSignature);
    }
    if (!nullToAbsent || clientSignature != null) {
      map['client_signature'] = Variable<String>(clientSignature);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_visible'] = Variable<bool>(isVisible);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FeuillesCompanion toCompanion(bool nullToAbsent) {
    return FeuillesCompanion(
      localId: Value(localId),
      mobileUuid: Value(mobileUuid),
      odooId: odooId == null && nullToAbsent
          ? const Value.absent()
          : Value(odooId),
      nomProjetOdooId: Value(nomProjetOdooId),
      quart: Value(quart),
      dateForage: Value(dateForage),
      foreuseOdooId: foreuseOdooId == null && nullToAbsent
          ? const Value.absent()
          : Value(foreuseOdooId),
      locationOdooId: locationOdooId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationOdooId),
      hourMeter: hourMeter == null && nullToAbsent
          ? const Value.absent()
          : Value(hourMeter),
      fuelMeter: fuelMeter == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelMeter),
      forageSignature: forageSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(forageSignature),
      clientSignature: clientSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(clientSignature),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      syncStatus: Value(syncStatus),
      isVisible: Value(isVisible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Feuille.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Feuille(
      localId: serializer.fromJson<int>(json['localId']),
      mobileUuid: serializer.fromJson<String>(json['mobileUuid']),
      odooId: serializer.fromJson<int?>(json['odooId']),
      nomProjetOdooId: serializer.fromJson<int>(json['nomProjetOdooId']),
      quart: serializer.fromJson<String>(json['quart']),
      dateForage: serializer.fromJson<String>(json['dateForage']),
      foreuseOdooId: serializer.fromJson<int?>(json['foreuseOdooId']),
      locationOdooId: serializer.fromJson<int?>(json['locationOdooId']),
      hourMeter: serializer.fromJson<int?>(json['hourMeter']),
      fuelMeter: serializer.fromJson<String?>(json['fuelMeter']),
      forageSignature: serializer.fromJson<String?>(json['forageSignature']),
      clientSignature: serializer.fromJson<String?>(json['clientSignature']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'mobileUuid': serializer.toJson<String>(mobileUuid),
      'odooId': serializer.toJson<int?>(odooId),
      'nomProjetOdooId': serializer.toJson<int>(nomProjetOdooId),
      'quart': serializer.toJson<String>(quart),
      'dateForage': serializer.toJson<String>(dateForage),
      'foreuseOdooId': serializer.toJson<int?>(foreuseOdooId),
      'locationOdooId': serializer.toJson<int?>(locationOdooId),
      'hourMeter': serializer.toJson<int?>(hourMeter),
      'fuelMeter': serializer.toJson<String?>(fuelMeter),
      'forageSignature': serializer.toJson<String?>(forageSignature),
      'clientSignature': serializer.toJson<String?>(clientSignature),
      'remarks': serializer.toJson<String?>(remarks),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isVisible': serializer.toJson<bool>(isVisible),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Feuille copyWith({
    int? localId,
    String? mobileUuid,
    Value<int?> odooId = const Value.absent(),
    int? nomProjetOdooId,
    String? quart,
    String? dateForage,
    Value<int?> foreuseOdooId = const Value.absent(),
    Value<int?> locationOdooId = const Value.absent(),
    Value<int?> hourMeter = const Value.absent(),
    Value<String?> fuelMeter = const Value.absent(),
    Value<String?> forageSignature = const Value.absent(),
    Value<String?> clientSignature = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    String? syncStatus,
    bool? isVisible,
    String? createdAt,
    String? updatedAt,
  }) => Feuille(
    localId: localId ?? this.localId,
    mobileUuid: mobileUuid ?? this.mobileUuid,
    odooId: odooId.present ? odooId.value : this.odooId,
    nomProjetOdooId: nomProjetOdooId ?? this.nomProjetOdooId,
    quart: quart ?? this.quart,
    dateForage: dateForage ?? this.dateForage,
    foreuseOdooId: foreuseOdooId.present
        ? foreuseOdooId.value
        : this.foreuseOdooId,
    locationOdooId: locationOdooId.present
        ? locationOdooId.value
        : this.locationOdooId,
    hourMeter: hourMeter.present ? hourMeter.value : this.hourMeter,
    fuelMeter: fuelMeter.present ? fuelMeter.value : this.fuelMeter,
    forageSignature: forageSignature.present
        ? forageSignature.value
        : this.forageSignature,
    clientSignature: clientSignature.present
        ? clientSignature.value
        : this.clientSignature,
    remarks: remarks.present ? remarks.value : this.remarks,
    syncStatus: syncStatus ?? this.syncStatus,
    isVisible: isVisible ?? this.isVisible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Feuille copyWithCompanion(FeuillesCompanion data) {
    return Feuille(
      localId: data.localId.present ? data.localId.value : this.localId,
      mobileUuid: data.mobileUuid.present
          ? data.mobileUuid.value
          : this.mobileUuid,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      nomProjetOdooId: data.nomProjetOdooId.present
          ? data.nomProjetOdooId.value
          : this.nomProjetOdooId,
      quart: data.quart.present ? data.quart.value : this.quart,
      dateForage: data.dateForage.present
          ? data.dateForage.value
          : this.dateForage,
      foreuseOdooId: data.foreuseOdooId.present
          ? data.foreuseOdooId.value
          : this.foreuseOdooId,
      locationOdooId: data.locationOdooId.present
          ? data.locationOdooId.value
          : this.locationOdooId,
      hourMeter: data.hourMeter.present ? data.hourMeter.value : this.hourMeter,
      fuelMeter: data.fuelMeter.present ? data.fuelMeter.value : this.fuelMeter,
      forageSignature: data.forageSignature.present
          ? data.forageSignature.value
          : this.forageSignature,
      clientSignature: data.clientSignature.present
          ? data.clientSignature.value
          : this.clientSignature,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Feuille(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('nomProjetOdooId: $nomProjetOdooId, ')
          ..write('quart: $quart, ')
          ..write('dateForage: $dateForage, ')
          ..write('foreuseOdooId: $foreuseOdooId, ')
          ..write('locationOdooId: $locationOdooId, ')
          ..write('hourMeter: $hourMeter, ')
          ..write('fuelMeter: $fuelMeter, ')
          ..write('forageSignature: $forageSignature, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('remarks: $remarks, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    mobileUuid,
    odooId,
    nomProjetOdooId,
    quart,
    dateForage,
    foreuseOdooId,
    locationOdooId,
    hourMeter,
    fuelMeter,
    forageSignature,
    clientSignature,
    remarks,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Feuille &&
          other.localId == this.localId &&
          other.mobileUuid == this.mobileUuid &&
          other.odooId == this.odooId &&
          other.nomProjetOdooId == this.nomProjetOdooId &&
          other.quart == this.quart &&
          other.dateForage == this.dateForage &&
          other.foreuseOdooId == this.foreuseOdooId &&
          other.locationOdooId == this.locationOdooId &&
          other.hourMeter == this.hourMeter &&
          other.fuelMeter == this.fuelMeter &&
          other.forageSignature == this.forageSignature &&
          other.clientSignature == this.clientSignature &&
          other.remarks == this.remarks &&
          other.syncStatus == this.syncStatus &&
          other.isVisible == this.isVisible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeuillesCompanion extends UpdateCompanion<Feuille> {
  final Value<int> localId;
  final Value<String> mobileUuid;
  final Value<int?> odooId;
  final Value<int> nomProjetOdooId;
  final Value<String> quart;
  final Value<String> dateForage;
  final Value<int?> foreuseOdooId;
  final Value<int?> locationOdooId;
  final Value<int?> hourMeter;
  final Value<String?> fuelMeter;
  final Value<String?> forageSignature;
  final Value<String?> clientSignature;
  final Value<String?> remarks;
  final Value<String> syncStatus;
  final Value<bool> isVisible;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FeuillesCompanion({
    this.localId = const Value.absent(),
    this.mobileUuid = const Value.absent(),
    this.odooId = const Value.absent(),
    this.nomProjetOdooId = const Value.absent(),
    this.quart = const Value.absent(),
    this.dateForage = const Value.absent(),
    this.foreuseOdooId = const Value.absent(),
    this.locationOdooId = const Value.absent(),
    this.hourMeter = const Value.absent(),
    this.fuelMeter = const Value.absent(),
    this.forageSignature = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.remarks = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeuillesCompanion.insert({
    this.localId = const Value.absent(),
    required String mobileUuid,
    this.odooId = const Value.absent(),
    required int nomProjetOdooId,
    required String quart,
    required String dateForage,
    this.foreuseOdooId = const Value.absent(),
    this.locationOdooId = const Value.absent(),
    this.hourMeter = const Value.absent(),
    this.fuelMeter = const Value.absent(),
    this.forageSignature = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.remarks = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : mobileUuid = Value(mobileUuid),
       nomProjetOdooId = Value(nomProjetOdooId),
       quart = Value(quart),
       dateForage = Value(dateForage),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Feuille> custom({
    Expression<int>? localId,
    Expression<String>? mobileUuid,
    Expression<int>? odooId,
    Expression<int>? nomProjetOdooId,
    Expression<String>? quart,
    Expression<String>? dateForage,
    Expression<int>? foreuseOdooId,
    Expression<int>? locationOdooId,
    Expression<int>? hourMeter,
    Expression<String>? fuelMeter,
    Expression<String>? forageSignature,
    Expression<String>? clientSignature,
    Expression<String>? remarks,
    Expression<String>? syncStatus,
    Expression<bool>? isVisible,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (mobileUuid != null) 'mobile_uuid': mobileUuid,
      if (odooId != null) 'odoo_id': odooId,
      if (nomProjetOdooId != null) 'nom_projet_odoo_id': nomProjetOdooId,
      if (quart != null) 'quart': quart,
      if (dateForage != null) 'date_forage': dateForage,
      if (foreuseOdooId != null) 'foreuse_odoo_id': foreuseOdooId,
      if (locationOdooId != null) 'location_odoo_id': locationOdooId,
      if (hourMeter != null) 'hour_meter': hourMeter,
      if (fuelMeter != null) 'fuel_meter': fuelMeter,
      if (forageSignature != null) 'forage_signature': forageSignature,
      if (clientSignature != null) 'client_signature': clientSignature,
      if (remarks != null) 'remarks': remarks,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isVisible != null) 'is_visible': isVisible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeuillesCompanion copyWith({
    Value<int>? localId,
    Value<String>? mobileUuid,
    Value<int?>? odooId,
    Value<int>? nomProjetOdooId,
    Value<String>? quart,
    Value<String>? dateForage,
    Value<int?>? foreuseOdooId,
    Value<int?>? locationOdooId,
    Value<int?>? hourMeter,
    Value<String?>? fuelMeter,
    Value<String?>? forageSignature,
    Value<String?>? clientSignature,
    Value<String?>? remarks,
    Value<String>? syncStatus,
    Value<bool>? isVisible,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FeuillesCompanion(
      localId: localId ?? this.localId,
      mobileUuid: mobileUuid ?? this.mobileUuid,
      odooId: odooId ?? this.odooId,
      nomProjetOdooId: nomProjetOdooId ?? this.nomProjetOdooId,
      quart: quart ?? this.quart,
      dateForage: dateForage ?? this.dateForage,
      foreuseOdooId: foreuseOdooId ?? this.foreuseOdooId,
      locationOdooId: locationOdooId ?? this.locationOdooId,
      hourMeter: hourMeter ?? this.hourMeter,
      fuelMeter: fuelMeter ?? this.fuelMeter,
      forageSignature: forageSignature ?? this.forageSignature,
      clientSignature: clientSignature ?? this.clientSignature,
      remarks: remarks ?? this.remarks,
      syncStatus: syncStatus ?? this.syncStatus,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (mobileUuid.present) {
      map['mobile_uuid'] = Variable<String>(mobileUuid.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (nomProjetOdooId.present) {
      map['nom_projet_odoo_id'] = Variable<int>(nomProjetOdooId.value);
    }
    if (quart.present) {
      map['quart'] = Variable<String>(quart.value);
    }
    if (dateForage.present) {
      map['date_forage'] = Variable<String>(dateForage.value);
    }
    if (foreuseOdooId.present) {
      map['foreuse_odoo_id'] = Variable<int>(foreuseOdooId.value);
    }
    if (locationOdooId.present) {
      map['location_odoo_id'] = Variable<int>(locationOdooId.value);
    }
    if (hourMeter.present) {
      map['hour_meter'] = Variable<int>(hourMeter.value);
    }
    if (fuelMeter.present) {
      map['fuel_meter'] = Variable<String>(fuelMeter.value);
    }
    if (forageSignature.present) {
      map['forage_signature'] = Variable<String>(forageSignature.value);
    }
    if (clientSignature.present) {
      map['client_signature'] = Variable<String>(clientSignature.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeuillesCompanion(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('nomProjetOdooId: $nomProjetOdooId, ')
          ..write('quart: $quart, ')
          ..write('dateForage: $dateForage, ')
          ..write('foreuseOdooId: $foreuseOdooId, ')
          ..write('locationOdooId: $locationOdooId, ')
          ..write('hourMeter: $hourMeter, ')
          ..write('fuelMeter: $fuelMeter, ')
          ..write('forageSignature: $forageSignature, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('remarks: $remarks, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeuilleLignesTable extends FeuilleLignes
    with TableInfo<$FeuilleLignesTable, FeuilleLigne> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeuilleLignesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mobileUuidMeta = const VerificationMeta(
    'mobileUuid',
  );
  @override
  late final GeneratedColumn<String> mobileUuid = GeneratedColumn<String>(
    'mobile_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feuilleLocalIdMeta = const VerificationMeta(
    'feuilleLocalId',
  );
  @override
  late final GeneratedColumn<int> feuilleLocalId = GeneratedColumn<int>(
    'feuille_local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tacheOdooIdMeta = const VerificationMeta(
    'tacheOdooId',
  );
  @override
  late final GeneratedColumn<int> tacheOdooId = GeneratedColumn<int>(
    'tache_odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holeNoMeta = const VerificationMeta('holeNo');
  @override
  late final GeneratedColumn<String> holeNo = GeneratedColumn<String>(
    'hole_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDMeta = const VerificationMeta('dateD');
  @override
  late final GeneratedColumn<double> dateD = GeneratedColumn<double>(
    'date_d',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateFMeta = const VerificationMeta('dateF');
  @override
  late final GeneratedColumn<double> dateF = GeneratedColumn<double>(
    'date_f',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rrMeta = const VerificationMeta('rr');
  @override
  late final GeneratedColumn<double> rr = GeneratedColumn<double>(
    'rr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<int> distance = GeneratedColumn<int>(
    'distance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromDimMeta = const VerificationMeta(
    'fromDim',
  );
  @override
  late final GeneratedColumn<int> fromDim = GeneratedColumn<int>(
    'from_dim',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toDimMeta = const VerificationMeta('toDim');
  @override
  late final GeneratedColumn<int> toDim = GeneratedColumn<int>(
    'to_dim',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDimMeta = const VerificationMeta(
    'totalDim',
  );
  @override
  late final GeneratedColumn<int> totalDim = GeneratedColumn<int>(
    'total_dim',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    item,
    tacheOdooId,
    holeNo,
    note,
    dateD,
    dateF,
    rr,
    distance,
    fromDim,
    toDim,
    totalDim,
    sequence,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feuille_lignes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeuilleLigne> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('mobile_uuid')) {
      context.handle(
        _mobileUuidMeta,
        mobileUuid.isAcceptableOrUnknown(data['mobile_uuid']!, _mobileUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileUuidMeta);
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    }
    if (data.containsKey('feuille_local_id')) {
      context.handle(
        _feuilleLocalIdMeta,
        feuilleLocalId.isAcceptableOrUnknown(
          data['feuille_local_id']!,
          _feuilleLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feuilleLocalIdMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('tache_odoo_id')) {
      context.handle(
        _tacheOdooIdMeta,
        tacheOdooId.isAcceptableOrUnknown(
          data['tache_odoo_id']!,
          _tacheOdooIdMeta,
        ),
      );
    }
    if (data.containsKey('hole_no')) {
      context.handle(
        _holeNoMeta,
        holeNo.isAcceptableOrUnknown(data['hole_no']!, _holeNoMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date_d')) {
      context.handle(
        _dateDMeta,
        dateD.isAcceptableOrUnknown(data['date_d']!, _dateDMeta),
      );
    }
    if (data.containsKey('date_f')) {
      context.handle(
        _dateFMeta,
        dateF.isAcceptableOrUnknown(data['date_f']!, _dateFMeta),
      );
    }
    if (data.containsKey('rr')) {
      context.handle(_rrMeta, rr.isAcceptableOrUnknown(data['rr']!, _rrMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    }
    if (data.containsKey('from_dim')) {
      context.handle(
        _fromDimMeta,
        fromDim.isAcceptableOrUnknown(data['from_dim']!, _fromDimMeta),
      );
    }
    if (data.containsKey('to_dim')) {
      context.handle(
        _toDimMeta,
        toDim.isAcceptableOrUnknown(data['to_dim']!, _toDimMeta),
      );
    }
    if (data.containsKey('total_dim')) {
      context.handle(
        _totalDimMeta,
        totalDim.isAcceptableOrUnknown(data['total_dim']!, _totalDimMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  FeuilleLigne map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeuilleLigne(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      mobileUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_uuid'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      ),
      feuilleLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feuille_local_id'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      tacheOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tache_odoo_id'],
      ),
      holeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hole_no'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dateD: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_d'],
      ),
      dateF: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_f'],
      ),
      rr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rr'],
      ),
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance'],
      ),
      fromDim: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_dim'],
      ),
      toDim: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_dim'],
      ),
      totalDim: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_dim'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeuilleLignesTable createAlias(String alias) {
    return $FeuilleLignesTable(attachedDatabase, alias);
  }
}

class FeuilleLigne extends DataClass implements Insertable<FeuilleLigne> {
  final int localId;
  final String mobileUuid;
  final int? odooId;
  final int feuilleLocalId;
  final String item;
  final int? tacheOdooId;
  final String? holeNo;
  final String? note;
  final double? dateD;
  final double? dateF;
  final double? rr;
  final int? distance;
  final int? fromDim;
  final int? toDim;
  final int? totalDim;
  final int sequence;
  final String syncStatus;
  final bool isVisible;
  final String createdAt;
  final String updatedAt;
  const FeuilleLigne({
    required this.localId,
    required this.mobileUuid,
    this.odooId,
    required this.feuilleLocalId,
    required this.item,
    this.tacheOdooId,
    this.holeNo,
    this.note,
    this.dateD,
    this.dateF,
    this.rr,
    this.distance,
    this.fromDim,
    this.toDim,
    this.totalDim,
    required this.sequence,
    required this.syncStatus,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['mobile_uuid'] = Variable<String>(mobileUuid);
    if (!nullToAbsent || odooId != null) {
      map['odoo_id'] = Variable<int>(odooId);
    }
    map['feuille_local_id'] = Variable<int>(feuilleLocalId);
    map['item'] = Variable<String>(item);
    if (!nullToAbsent || tacheOdooId != null) {
      map['tache_odoo_id'] = Variable<int>(tacheOdooId);
    }
    if (!nullToAbsent || holeNo != null) {
      map['hole_no'] = Variable<String>(holeNo);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || dateD != null) {
      map['date_d'] = Variable<double>(dateD);
    }
    if (!nullToAbsent || dateF != null) {
      map['date_f'] = Variable<double>(dateF);
    }
    if (!nullToAbsent || rr != null) {
      map['rr'] = Variable<double>(rr);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<int>(distance);
    }
    if (!nullToAbsent || fromDim != null) {
      map['from_dim'] = Variable<int>(fromDim);
    }
    if (!nullToAbsent || toDim != null) {
      map['to_dim'] = Variable<int>(toDim);
    }
    if (!nullToAbsent || totalDim != null) {
      map['total_dim'] = Variable<int>(totalDim);
    }
    map['sequence'] = Variable<int>(sequence);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_visible'] = Variable<bool>(isVisible);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FeuilleLignesCompanion toCompanion(bool nullToAbsent) {
    return FeuilleLignesCompanion(
      localId: Value(localId),
      mobileUuid: Value(mobileUuid),
      odooId: odooId == null && nullToAbsent
          ? const Value.absent()
          : Value(odooId),
      feuilleLocalId: Value(feuilleLocalId),
      item: Value(item),
      tacheOdooId: tacheOdooId == null && nullToAbsent
          ? const Value.absent()
          : Value(tacheOdooId),
      holeNo: holeNo == null && nullToAbsent
          ? const Value.absent()
          : Value(holeNo),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dateD: dateD == null && nullToAbsent
          ? const Value.absent()
          : Value(dateD),
      dateF: dateF == null && nullToAbsent
          ? const Value.absent()
          : Value(dateF),
      rr: rr == null && nullToAbsent ? const Value.absent() : Value(rr),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      fromDim: fromDim == null && nullToAbsent
          ? const Value.absent()
          : Value(fromDim),
      toDim: toDim == null && nullToAbsent
          ? const Value.absent()
          : Value(toDim),
      totalDim: totalDim == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDim),
      sequence: Value(sequence),
      syncStatus: Value(syncStatus),
      isVisible: Value(isVisible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeuilleLigne.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeuilleLigne(
      localId: serializer.fromJson<int>(json['localId']),
      mobileUuid: serializer.fromJson<String>(json['mobileUuid']),
      odooId: serializer.fromJson<int?>(json['odooId']),
      feuilleLocalId: serializer.fromJson<int>(json['feuilleLocalId']),
      item: serializer.fromJson<String>(json['item']),
      tacheOdooId: serializer.fromJson<int?>(json['tacheOdooId']),
      holeNo: serializer.fromJson<String?>(json['holeNo']),
      note: serializer.fromJson<String?>(json['note']),
      dateD: serializer.fromJson<double?>(json['dateD']),
      dateF: serializer.fromJson<double?>(json['dateF']),
      rr: serializer.fromJson<double?>(json['rr']),
      distance: serializer.fromJson<int?>(json['distance']),
      fromDim: serializer.fromJson<int?>(json['fromDim']),
      toDim: serializer.fromJson<int?>(json['toDim']),
      totalDim: serializer.fromJson<int?>(json['totalDim']),
      sequence: serializer.fromJson<int>(json['sequence']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'mobileUuid': serializer.toJson<String>(mobileUuid),
      'odooId': serializer.toJson<int?>(odooId),
      'feuilleLocalId': serializer.toJson<int>(feuilleLocalId),
      'item': serializer.toJson<String>(item),
      'tacheOdooId': serializer.toJson<int?>(tacheOdooId),
      'holeNo': serializer.toJson<String?>(holeNo),
      'note': serializer.toJson<String?>(note),
      'dateD': serializer.toJson<double?>(dateD),
      'dateF': serializer.toJson<double?>(dateF),
      'rr': serializer.toJson<double?>(rr),
      'distance': serializer.toJson<int?>(distance),
      'fromDim': serializer.toJson<int?>(fromDim),
      'toDim': serializer.toJson<int?>(toDim),
      'totalDim': serializer.toJson<int?>(totalDim),
      'sequence': serializer.toJson<int>(sequence),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isVisible': serializer.toJson<bool>(isVisible),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FeuilleLigne copyWith({
    int? localId,
    String? mobileUuid,
    Value<int?> odooId = const Value.absent(),
    int? feuilleLocalId,
    String? item,
    Value<int?> tacheOdooId = const Value.absent(),
    Value<String?> holeNo = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<double?> dateD = const Value.absent(),
    Value<double?> dateF = const Value.absent(),
    Value<double?> rr = const Value.absent(),
    Value<int?> distance = const Value.absent(),
    Value<int?> fromDim = const Value.absent(),
    Value<int?> toDim = const Value.absent(),
    Value<int?> totalDim = const Value.absent(),
    int? sequence,
    String? syncStatus,
    bool? isVisible,
    String? createdAt,
    String? updatedAt,
  }) => FeuilleLigne(
    localId: localId ?? this.localId,
    mobileUuid: mobileUuid ?? this.mobileUuid,
    odooId: odooId.present ? odooId.value : this.odooId,
    feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
    item: item ?? this.item,
    tacheOdooId: tacheOdooId.present ? tacheOdooId.value : this.tacheOdooId,
    holeNo: holeNo.present ? holeNo.value : this.holeNo,
    note: note.present ? note.value : this.note,
    dateD: dateD.present ? dateD.value : this.dateD,
    dateF: dateF.present ? dateF.value : this.dateF,
    rr: rr.present ? rr.value : this.rr,
    distance: distance.present ? distance.value : this.distance,
    fromDim: fromDim.present ? fromDim.value : this.fromDim,
    toDim: toDim.present ? toDim.value : this.toDim,
    totalDim: totalDim.present ? totalDim.value : this.totalDim,
    sequence: sequence ?? this.sequence,
    syncStatus: syncStatus ?? this.syncStatus,
    isVisible: isVisible ?? this.isVisible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeuilleLigne copyWithCompanion(FeuilleLignesCompanion data) {
    return FeuilleLigne(
      localId: data.localId.present ? data.localId.value : this.localId,
      mobileUuid: data.mobileUuid.present
          ? data.mobileUuid.value
          : this.mobileUuid,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      feuilleLocalId: data.feuilleLocalId.present
          ? data.feuilleLocalId.value
          : this.feuilleLocalId,
      item: data.item.present ? data.item.value : this.item,
      tacheOdooId: data.tacheOdooId.present
          ? data.tacheOdooId.value
          : this.tacheOdooId,
      holeNo: data.holeNo.present ? data.holeNo.value : this.holeNo,
      note: data.note.present ? data.note.value : this.note,
      dateD: data.dateD.present ? data.dateD.value : this.dateD,
      dateF: data.dateF.present ? data.dateF.value : this.dateF,
      rr: data.rr.present ? data.rr.value : this.rr,
      distance: data.distance.present ? data.distance.value : this.distance,
      fromDim: data.fromDim.present ? data.fromDim.value : this.fromDim,
      toDim: data.toDim.present ? data.toDim.value : this.toDim,
      totalDim: data.totalDim.present ? data.totalDim.value : this.totalDim,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleLigne(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('item: $item, ')
          ..write('tacheOdooId: $tacheOdooId, ')
          ..write('holeNo: $holeNo, ')
          ..write('note: $note, ')
          ..write('dateD: $dateD, ')
          ..write('dateF: $dateF, ')
          ..write('rr: $rr, ')
          ..write('distance: $distance, ')
          ..write('fromDim: $fromDim, ')
          ..write('toDim: $toDim, ')
          ..write('totalDim: $totalDim, ')
          ..write('sequence: $sequence, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    item,
    tacheOdooId,
    holeNo,
    note,
    dateD,
    dateF,
    rr,
    distance,
    fromDim,
    toDim,
    totalDim,
    sequence,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeuilleLigne &&
          other.localId == this.localId &&
          other.mobileUuid == this.mobileUuid &&
          other.odooId == this.odooId &&
          other.feuilleLocalId == this.feuilleLocalId &&
          other.item == this.item &&
          other.tacheOdooId == this.tacheOdooId &&
          other.holeNo == this.holeNo &&
          other.note == this.note &&
          other.dateD == this.dateD &&
          other.dateF == this.dateF &&
          other.rr == this.rr &&
          other.distance == this.distance &&
          other.fromDim == this.fromDim &&
          other.toDim == this.toDim &&
          other.totalDim == this.totalDim &&
          other.sequence == this.sequence &&
          other.syncStatus == this.syncStatus &&
          other.isVisible == this.isVisible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeuilleLignesCompanion extends UpdateCompanion<FeuilleLigne> {
  final Value<int> localId;
  final Value<String> mobileUuid;
  final Value<int?> odooId;
  final Value<int> feuilleLocalId;
  final Value<String> item;
  final Value<int?> tacheOdooId;
  final Value<String?> holeNo;
  final Value<String?> note;
  final Value<double?> dateD;
  final Value<double?> dateF;
  final Value<double?> rr;
  final Value<int?> distance;
  final Value<int?> fromDim;
  final Value<int?> toDim;
  final Value<int?> totalDim;
  final Value<int> sequence;
  final Value<String> syncStatus;
  final Value<bool> isVisible;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FeuilleLignesCompanion({
    this.localId = const Value.absent(),
    this.mobileUuid = const Value.absent(),
    this.odooId = const Value.absent(),
    this.feuilleLocalId = const Value.absent(),
    this.item = const Value.absent(),
    this.tacheOdooId = const Value.absent(),
    this.holeNo = const Value.absent(),
    this.note = const Value.absent(),
    this.dateD = const Value.absent(),
    this.dateF = const Value.absent(),
    this.rr = const Value.absent(),
    this.distance = const Value.absent(),
    this.fromDim = const Value.absent(),
    this.toDim = const Value.absent(),
    this.totalDim = const Value.absent(),
    this.sequence = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeuilleLignesCompanion.insert({
    this.localId = const Value.absent(),
    required String mobileUuid,
    this.odooId = const Value.absent(),
    required int feuilleLocalId,
    required String item,
    this.tacheOdooId = const Value.absent(),
    this.holeNo = const Value.absent(),
    this.note = const Value.absent(),
    this.dateD = const Value.absent(),
    this.dateF = const Value.absent(),
    this.rr = const Value.absent(),
    this.distance = const Value.absent(),
    this.fromDim = const Value.absent(),
    this.toDim = const Value.absent(),
    this.totalDim = const Value.absent(),
    this.sequence = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : mobileUuid = Value(mobileUuid),
       feuilleLocalId = Value(feuilleLocalId),
       item = Value(item),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeuilleLigne> custom({
    Expression<int>? localId,
    Expression<String>? mobileUuid,
    Expression<int>? odooId,
    Expression<int>? feuilleLocalId,
    Expression<String>? item,
    Expression<int>? tacheOdooId,
    Expression<String>? holeNo,
    Expression<String>? note,
    Expression<double>? dateD,
    Expression<double>? dateF,
    Expression<double>? rr,
    Expression<int>? distance,
    Expression<int>? fromDim,
    Expression<int>? toDim,
    Expression<int>? totalDim,
    Expression<int>? sequence,
    Expression<String>? syncStatus,
    Expression<bool>? isVisible,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (mobileUuid != null) 'mobile_uuid': mobileUuid,
      if (odooId != null) 'odoo_id': odooId,
      if (feuilleLocalId != null) 'feuille_local_id': feuilleLocalId,
      if (item != null) 'item': item,
      if (tacheOdooId != null) 'tache_odoo_id': tacheOdooId,
      if (holeNo != null) 'hole_no': holeNo,
      if (note != null) 'note': note,
      if (dateD != null) 'date_d': dateD,
      if (dateF != null) 'date_f': dateF,
      if (rr != null) 'rr': rr,
      if (distance != null) 'distance': distance,
      if (fromDim != null) 'from_dim': fromDim,
      if (toDim != null) 'to_dim': toDim,
      if (totalDim != null) 'total_dim': totalDim,
      if (sequence != null) 'sequence': sequence,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isVisible != null) 'is_visible': isVisible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeuilleLignesCompanion copyWith({
    Value<int>? localId,
    Value<String>? mobileUuid,
    Value<int?>? odooId,
    Value<int>? feuilleLocalId,
    Value<String>? item,
    Value<int?>? tacheOdooId,
    Value<String?>? holeNo,
    Value<String?>? note,
    Value<double?>? dateD,
    Value<double?>? dateF,
    Value<double?>? rr,
    Value<int?>? distance,
    Value<int?>? fromDim,
    Value<int?>? toDim,
    Value<int?>? totalDim,
    Value<int>? sequence,
    Value<String>? syncStatus,
    Value<bool>? isVisible,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FeuilleLignesCompanion(
      localId: localId ?? this.localId,
      mobileUuid: mobileUuid ?? this.mobileUuid,
      odooId: odooId ?? this.odooId,
      feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
      item: item ?? this.item,
      tacheOdooId: tacheOdooId ?? this.tacheOdooId,
      holeNo: holeNo ?? this.holeNo,
      note: note ?? this.note,
      dateD: dateD ?? this.dateD,
      dateF: dateF ?? this.dateF,
      rr: rr ?? this.rr,
      distance: distance ?? this.distance,
      fromDim: fromDim ?? this.fromDim,
      toDim: toDim ?? this.toDim,
      totalDim: totalDim ?? this.totalDim,
      sequence: sequence ?? this.sequence,
      syncStatus: syncStatus ?? this.syncStatus,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (mobileUuid.present) {
      map['mobile_uuid'] = Variable<String>(mobileUuid.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (feuilleLocalId.present) {
      map['feuille_local_id'] = Variable<int>(feuilleLocalId.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (tacheOdooId.present) {
      map['tache_odoo_id'] = Variable<int>(tacheOdooId.value);
    }
    if (holeNo.present) {
      map['hole_no'] = Variable<String>(holeNo.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dateD.present) {
      map['date_d'] = Variable<double>(dateD.value);
    }
    if (dateF.present) {
      map['date_f'] = Variable<double>(dateF.value);
    }
    if (rr.present) {
      map['rr'] = Variable<double>(rr.value);
    }
    if (distance.present) {
      map['distance'] = Variable<int>(distance.value);
    }
    if (fromDim.present) {
      map['from_dim'] = Variable<int>(fromDim.value);
    }
    if (toDim.present) {
      map['to_dim'] = Variable<int>(toDim.value);
    }
    if (totalDim.present) {
      map['total_dim'] = Variable<int>(totalDim.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleLignesCompanion(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('item: $item, ')
          ..write('tacheOdooId: $tacheOdooId, ')
          ..write('holeNo: $holeNo, ')
          ..write('note: $note, ')
          ..write('dateD: $dateD, ')
          ..write('dateF: $dateF, ')
          ..write('rr: $rr, ')
          ..write('distance: $distance, ')
          ..write('fromDim: $fromDim, ')
          ..write('toDim: $toDim, ')
          ..write('totalDim: $totalDim, ')
          ..write('sequence: $sequence, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeuilleFuelsTable extends FeuilleFuels
    with TableInfo<$FeuilleFuelsTable, FeuilleFuel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeuilleFuelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mobileUuidMeta = const VerificationMeta(
    'mobileUuid',
  );
  @override
  late final GeneratedColumn<String> mobileUuid = GeneratedColumn<String>(
    'mobile_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feuilleLocalIdMeta = const VerificationMeta(
    'feuilleLocalId',
  );
  @override
  late final GeneratedColumn<int> feuilleLocalId = GeneratedColumn<int>(
    'feuille_local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compresseurOdooIdMeta = const VerificationMeta(
    'compresseurOdooId',
  );
  @override
  late final GeneratedColumn<int> compresseurOdooId = GeneratedColumn<int>(
    'compresseur_odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qytFuelMeta = const VerificationMeta(
    'qytFuel',
  );
  @override
  late final GeneratedColumn<double> qytFuel = GeneratedColumn<double>(
    'qyt_fuel',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dateDEquiMeta = const VerificationMeta(
    'dateDEqui',
  );
  @override
  late final GeneratedColumn<double> dateDEqui = GeneratedColumn<double>(
    'date_d_equi',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateFEquiMeta = const VerificationMeta(
    'dateFEqui',
  );
  @override
  late final GeneratedColumn<double> dateFEqui = GeneratedColumn<double>(
    'date_f_equi',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDRaviMeta = const VerificationMeta(
    'dateDRavi',
  );
  @override
  late final GeneratedColumn<double> dateDRavi = GeneratedColumn<double>(
    'date_d_ravi',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateFRaviMeta = const VerificationMeta(
    'dateFRavi',
  );
  @override
  late final GeneratedColumn<double> dateFRavi = GeneratedColumn<double>(
    'date_f_ravi',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    compresseurOdooId,
    qytFuel,
    dateDEqui,
    dateFEqui,
    dateDRavi,
    dateFRavi,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feuille_fuels';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeuilleFuel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('mobile_uuid')) {
      context.handle(
        _mobileUuidMeta,
        mobileUuid.isAcceptableOrUnknown(data['mobile_uuid']!, _mobileUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileUuidMeta);
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    }
    if (data.containsKey('feuille_local_id')) {
      context.handle(
        _feuilleLocalIdMeta,
        feuilleLocalId.isAcceptableOrUnknown(
          data['feuille_local_id']!,
          _feuilleLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feuilleLocalIdMeta);
    }
    if (data.containsKey('compresseur_odoo_id')) {
      context.handle(
        _compresseurOdooIdMeta,
        compresseurOdooId.isAcceptableOrUnknown(
          data['compresseur_odoo_id']!,
          _compresseurOdooIdMeta,
        ),
      );
    }
    if (data.containsKey('qyt_fuel')) {
      context.handle(
        _qytFuelMeta,
        qytFuel.isAcceptableOrUnknown(data['qyt_fuel']!, _qytFuelMeta),
      );
    }
    if (data.containsKey('date_d_equi')) {
      context.handle(
        _dateDEquiMeta,
        dateDEqui.isAcceptableOrUnknown(data['date_d_equi']!, _dateDEquiMeta),
      );
    }
    if (data.containsKey('date_f_equi')) {
      context.handle(
        _dateFEquiMeta,
        dateFEqui.isAcceptableOrUnknown(data['date_f_equi']!, _dateFEquiMeta),
      );
    }
    if (data.containsKey('date_d_ravi')) {
      context.handle(
        _dateDRaviMeta,
        dateDRavi.isAcceptableOrUnknown(data['date_d_ravi']!, _dateDRaviMeta),
      );
    }
    if (data.containsKey('date_f_ravi')) {
      context.handle(
        _dateFRaviMeta,
        dateFRavi.isAcceptableOrUnknown(data['date_f_ravi']!, _dateFRaviMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  FeuilleFuel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeuilleFuel(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      mobileUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_uuid'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      ),
      feuilleLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feuille_local_id'],
      )!,
      compresseurOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compresseur_odoo_id'],
      ),
      qytFuel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qyt_fuel'],
      )!,
      dateDEqui: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_d_equi'],
      ),
      dateFEqui: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_f_equi'],
      ),
      dateDRavi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_d_ravi'],
      ),
      dateFRavi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}date_f_ravi'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeuilleFuelsTable createAlias(String alias) {
    return $FeuilleFuelsTable(attachedDatabase, alias);
  }
}

class FeuilleFuel extends DataClass implements Insertable<FeuilleFuel> {
  final int localId;
  final String mobileUuid;
  final int? odooId;
  final int feuilleLocalId;
  final int? compresseurOdooId;
  final double qytFuel;
  final double? dateDEqui;
  final double? dateFEqui;
  final double? dateDRavi;
  final double? dateFRavi;
  final String syncStatus;
  final bool isVisible;
  final String createdAt;
  final String updatedAt;
  const FeuilleFuel({
    required this.localId,
    required this.mobileUuid,
    this.odooId,
    required this.feuilleLocalId,
    this.compresseurOdooId,
    required this.qytFuel,
    this.dateDEqui,
    this.dateFEqui,
    this.dateDRavi,
    this.dateFRavi,
    required this.syncStatus,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['mobile_uuid'] = Variable<String>(mobileUuid);
    if (!nullToAbsent || odooId != null) {
      map['odoo_id'] = Variable<int>(odooId);
    }
    map['feuille_local_id'] = Variable<int>(feuilleLocalId);
    if (!nullToAbsent || compresseurOdooId != null) {
      map['compresseur_odoo_id'] = Variable<int>(compresseurOdooId);
    }
    map['qyt_fuel'] = Variable<double>(qytFuel);
    if (!nullToAbsent || dateDEqui != null) {
      map['date_d_equi'] = Variable<double>(dateDEqui);
    }
    if (!nullToAbsent || dateFEqui != null) {
      map['date_f_equi'] = Variable<double>(dateFEqui);
    }
    if (!nullToAbsent || dateDRavi != null) {
      map['date_d_ravi'] = Variable<double>(dateDRavi);
    }
    if (!nullToAbsent || dateFRavi != null) {
      map['date_f_ravi'] = Variable<double>(dateFRavi);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_visible'] = Variable<bool>(isVisible);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FeuilleFuelsCompanion toCompanion(bool nullToAbsent) {
    return FeuilleFuelsCompanion(
      localId: Value(localId),
      mobileUuid: Value(mobileUuid),
      odooId: odooId == null && nullToAbsent
          ? const Value.absent()
          : Value(odooId),
      feuilleLocalId: Value(feuilleLocalId),
      compresseurOdooId: compresseurOdooId == null && nullToAbsent
          ? const Value.absent()
          : Value(compresseurOdooId),
      qytFuel: Value(qytFuel),
      dateDEqui: dateDEqui == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDEqui),
      dateFEqui: dateFEqui == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFEqui),
      dateDRavi: dateDRavi == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDRavi),
      dateFRavi: dateFRavi == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFRavi),
      syncStatus: Value(syncStatus),
      isVisible: Value(isVisible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeuilleFuel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeuilleFuel(
      localId: serializer.fromJson<int>(json['localId']),
      mobileUuid: serializer.fromJson<String>(json['mobileUuid']),
      odooId: serializer.fromJson<int?>(json['odooId']),
      feuilleLocalId: serializer.fromJson<int>(json['feuilleLocalId']),
      compresseurOdooId: serializer.fromJson<int?>(json['compresseurOdooId']),
      qytFuel: serializer.fromJson<double>(json['qytFuel']),
      dateDEqui: serializer.fromJson<double?>(json['dateDEqui']),
      dateFEqui: serializer.fromJson<double?>(json['dateFEqui']),
      dateDRavi: serializer.fromJson<double?>(json['dateDRavi']),
      dateFRavi: serializer.fromJson<double?>(json['dateFRavi']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'mobileUuid': serializer.toJson<String>(mobileUuid),
      'odooId': serializer.toJson<int?>(odooId),
      'feuilleLocalId': serializer.toJson<int>(feuilleLocalId),
      'compresseurOdooId': serializer.toJson<int?>(compresseurOdooId),
      'qytFuel': serializer.toJson<double>(qytFuel),
      'dateDEqui': serializer.toJson<double?>(dateDEqui),
      'dateFEqui': serializer.toJson<double?>(dateFEqui),
      'dateDRavi': serializer.toJson<double?>(dateDRavi),
      'dateFRavi': serializer.toJson<double?>(dateFRavi),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isVisible': serializer.toJson<bool>(isVisible),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FeuilleFuel copyWith({
    int? localId,
    String? mobileUuid,
    Value<int?> odooId = const Value.absent(),
    int? feuilleLocalId,
    Value<int?> compresseurOdooId = const Value.absent(),
    double? qytFuel,
    Value<double?> dateDEqui = const Value.absent(),
    Value<double?> dateFEqui = const Value.absent(),
    Value<double?> dateDRavi = const Value.absent(),
    Value<double?> dateFRavi = const Value.absent(),
    String? syncStatus,
    bool? isVisible,
    String? createdAt,
    String? updatedAt,
  }) => FeuilleFuel(
    localId: localId ?? this.localId,
    mobileUuid: mobileUuid ?? this.mobileUuid,
    odooId: odooId.present ? odooId.value : this.odooId,
    feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
    compresseurOdooId: compresseurOdooId.present
        ? compresseurOdooId.value
        : this.compresseurOdooId,
    qytFuel: qytFuel ?? this.qytFuel,
    dateDEqui: dateDEqui.present ? dateDEqui.value : this.dateDEqui,
    dateFEqui: dateFEqui.present ? dateFEqui.value : this.dateFEqui,
    dateDRavi: dateDRavi.present ? dateDRavi.value : this.dateDRavi,
    dateFRavi: dateFRavi.present ? dateFRavi.value : this.dateFRavi,
    syncStatus: syncStatus ?? this.syncStatus,
    isVisible: isVisible ?? this.isVisible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeuilleFuel copyWithCompanion(FeuilleFuelsCompanion data) {
    return FeuilleFuel(
      localId: data.localId.present ? data.localId.value : this.localId,
      mobileUuid: data.mobileUuid.present
          ? data.mobileUuid.value
          : this.mobileUuid,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      feuilleLocalId: data.feuilleLocalId.present
          ? data.feuilleLocalId.value
          : this.feuilleLocalId,
      compresseurOdooId: data.compresseurOdooId.present
          ? data.compresseurOdooId.value
          : this.compresseurOdooId,
      qytFuel: data.qytFuel.present ? data.qytFuel.value : this.qytFuel,
      dateDEqui: data.dateDEqui.present ? data.dateDEqui.value : this.dateDEqui,
      dateFEqui: data.dateFEqui.present ? data.dateFEqui.value : this.dateFEqui,
      dateDRavi: data.dateDRavi.present ? data.dateDRavi.value : this.dateDRavi,
      dateFRavi: data.dateFRavi.present ? data.dateFRavi.value : this.dateFRavi,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleFuel(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('compresseurOdooId: $compresseurOdooId, ')
          ..write('qytFuel: $qytFuel, ')
          ..write('dateDEqui: $dateDEqui, ')
          ..write('dateFEqui: $dateFEqui, ')
          ..write('dateDRavi: $dateDRavi, ')
          ..write('dateFRavi: $dateFRavi, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    compresseurOdooId,
    qytFuel,
    dateDEqui,
    dateFEqui,
    dateDRavi,
    dateFRavi,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeuilleFuel &&
          other.localId == this.localId &&
          other.mobileUuid == this.mobileUuid &&
          other.odooId == this.odooId &&
          other.feuilleLocalId == this.feuilleLocalId &&
          other.compresseurOdooId == this.compresseurOdooId &&
          other.qytFuel == this.qytFuel &&
          other.dateDEqui == this.dateDEqui &&
          other.dateFEqui == this.dateFEqui &&
          other.dateDRavi == this.dateDRavi &&
          other.dateFRavi == this.dateFRavi &&
          other.syncStatus == this.syncStatus &&
          other.isVisible == this.isVisible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeuilleFuelsCompanion extends UpdateCompanion<FeuilleFuel> {
  final Value<int> localId;
  final Value<String> mobileUuid;
  final Value<int?> odooId;
  final Value<int> feuilleLocalId;
  final Value<int?> compresseurOdooId;
  final Value<double> qytFuel;
  final Value<double?> dateDEqui;
  final Value<double?> dateFEqui;
  final Value<double?> dateDRavi;
  final Value<double?> dateFRavi;
  final Value<String> syncStatus;
  final Value<bool> isVisible;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FeuilleFuelsCompanion({
    this.localId = const Value.absent(),
    this.mobileUuid = const Value.absent(),
    this.odooId = const Value.absent(),
    this.feuilleLocalId = const Value.absent(),
    this.compresseurOdooId = const Value.absent(),
    this.qytFuel = const Value.absent(),
    this.dateDEqui = const Value.absent(),
    this.dateFEqui = const Value.absent(),
    this.dateDRavi = const Value.absent(),
    this.dateFRavi = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeuilleFuelsCompanion.insert({
    this.localId = const Value.absent(),
    required String mobileUuid,
    this.odooId = const Value.absent(),
    required int feuilleLocalId,
    this.compresseurOdooId = const Value.absent(),
    this.qytFuel = const Value.absent(),
    this.dateDEqui = const Value.absent(),
    this.dateFEqui = const Value.absent(),
    this.dateDRavi = const Value.absent(),
    this.dateFRavi = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : mobileUuid = Value(mobileUuid),
       feuilleLocalId = Value(feuilleLocalId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeuilleFuel> custom({
    Expression<int>? localId,
    Expression<String>? mobileUuid,
    Expression<int>? odooId,
    Expression<int>? feuilleLocalId,
    Expression<int>? compresseurOdooId,
    Expression<double>? qytFuel,
    Expression<double>? dateDEqui,
    Expression<double>? dateFEqui,
    Expression<double>? dateDRavi,
    Expression<double>? dateFRavi,
    Expression<String>? syncStatus,
    Expression<bool>? isVisible,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (mobileUuid != null) 'mobile_uuid': mobileUuid,
      if (odooId != null) 'odoo_id': odooId,
      if (feuilleLocalId != null) 'feuille_local_id': feuilleLocalId,
      if (compresseurOdooId != null) 'compresseur_odoo_id': compresseurOdooId,
      if (qytFuel != null) 'qyt_fuel': qytFuel,
      if (dateDEqui != null) 'date_d_equi': dateDEqui,
      if (dateFEqui != null) 'date_f_equi': dateFEqui,
      if (dateDRavi != null) 'date_d_ravi': dateDRavi,
      if (dateFRavi != null) 'date_f_ravi': dateFRavi,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isVisible != null) 'is_visible': isVisible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeuilleFuelsCompanion copyWith({
    Value<int>? localId,
    Value<String>? mobileUuid,
    Value<int?>? odooId,
    Value<int>? feuilleLocalId,
    Value<int?>? compresseurOdooId,
    Value<double>? qytFuel,
    Value<double?>? dateDEqui,
    Value<double?>? dateFEqui,
    Value<double?>? dateDRavi,
    Value<double?>? dateFRavi,
    Value<String>? syncStatus,
    Value<bool>? isVisible,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FeuilleFuelsCompanion(
      localId: localId ?? this.localId,
      mobileUuid: mobileUuid ?? this.mobileUuid,
      odooId: odooId ?? this.odooId,
      feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
      compresseurOdooId: compresseurOdooId ?? this.compresseurOdooId,
      qytFuel: qytFuel ?? this.qytFuel,
      dateDEqui: dateDEqui ?? this.dateDEqui,
      dateFEqui: dateFEqui ?? this.dateFEqui,
      dateDRavi: dateDRavi ?? this.dateDRavi,
      dateFRavi: dateFRavi ?? this.dateFRavi,
      syncStatus: syncStatus ?? this.syncStatus,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (mobileUuid.present) {
      map['mobile_uuid'] = Variable<String>(mobileUuid.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (feuilleLocalId.present) {
      map['feuille_local_id'] = Variable<int>(feuilleLocalId.value);
    }
    if (compresseurOdooId.present) {
      map['compresseur_odoo_id'] = Variable<int>(compresseurOdooId.value);
    }
    if (qytFuel.present) {
      map['qyt_fuel'] = Variable<double>(qytFuel.value);
    }
    if (dateDEqui.present) {
      map['date_d_equi'] = Variable<double>(dateDEqui.value);
    }
    if (dateFEqui.present) {
      map['date_f_equi'] = Variable<double>(dateFEqui.value);
    }
    if (dateDRavi.present) {
      map['date_d_ravi'] = Variable<double>(dateDRavi.value);
    }
    if (dateFRavi.present) {
      map['date_f_ravi'] = Variable<double>(dateFRavi.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleFuelsCompanion(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('compresseurOdooId: $compresseurOdooId, ')
          ..write('qytFuel: $qytFuel, ')
          ..write('dateDEqui: $dateDEqui, ')
          ..write('dateFEqui: $dateFEqui, ')
          ..write('dateDRavi: $dateDRavi, ')
          ..write('dateFRavi: $dateFRavi, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeuilleEmployesTable extends FeuilleEmployes
    with TableInfo<$FeuilleEmployesTable, FeuilleEmploye> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeuilleEmployesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mobileUuidMeta = const VerificationMeta(
    'mobileUuid',
  );
  @override
  late final GeneratedColumn<String> mobileUuid = GeneratedColumn<String>(
    'mobile_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feuilleLocalIdMeta = const VerificationMeta(
    'feuilleLocalId',
  );
  @override
  late final GeneratedColumn<int> feuilleLocalId = GeneratedColumn<int>(
    'feuille_local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeOdooIdMeta = const VerificationMeta(
    'employeeOdooId',
  );
  @override
  late final GeneratedColumn<int> employeeOdooId = GeneratedColumn<int>(
    'employee_odoo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fonctionMeta = const VerificationMeta(
    'fonction',
  );
  @override
  late final GeneratedColumn<String> fonction = GeneratedColumn<String>(
    'fonction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateEmpMeta = const VerificationMeta(
    'dateEmp',
  );
  @override
  late final GeneratedColumn<String> dateEmp = GeneratedColumn<String>(
    'date_emp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDebutMeta = const VerificationMeta(
    'dateDebut',
  );
  @override
  late final GeneratedColumn<String> dateDebut = GeneratedColumn<String>(
    'date_debut',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateFinMeta = const VerificationMeta(
    'dateFin',
  );
  @override
  late final GeneratedColumn<String> dateFin = GeneratedColumn<String>(
    'date_fin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _differenceMeta = const VerificationMeta(
    'difference',
  );
  @override
  late final GeneratedColumn<double> difference = GeneratedColumn<double>(
    'difference',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _absentMeta = const VerificationMeta('absent');
  @override
  late final GeneratedColumn<bool> absent = GeneratedColumn<bool>(
    'absent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("absent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    employeeOdooId,
    fonction,
    observation,
    dateEmp,
    dateDebut,
    dateFin,
    difference,
    absent,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feuille_employes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeuilleEmploye> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('mobile_uuid')) {
      context.handle(
        _mobileUuidMeta,
        mobileUuid.isAcceptableOrUnknown(data['mobile_uuid']!, _mobileUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileUuidMeta);
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    }
    if (data.containsKey('feuille_local_id')) {
      context.handle(
        _feuilleLocalIdMeta,
        feuilleLocalId.isAcceptableOrUnknown(
          data['feuille_local_id']!,
          _feuilleLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feuilleLocalIdMeta);
    }
    if (data.containsKey('employee_odoo_id')) {
      context.handle(
        _employeeOdooIdMeta,
        employeeOdooId.isAcceptableOrUnknown(
          data['employee_odoo_id']!,
          _employeeOdooIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeOdooIdMeta);
    }
    if (data.containsKey('fonction')) {
      context.handle(
        _fonctionMeta,
        fonction.isAcceptableOrUnknown(data['fonction']!, _fonctionMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    if (data.containsKey('date_emp')) {
      context.handle(
        _dateEmpMeta,
        dateEmp.isAcceptableOrUnknown(data['date_emp']!, _dateEmpMeta),
      );
    }
    if (data.containsKey('date_debut')) {
      context.handle(
        _dateDebutMeta,
        dateDebut.isAcceptableOrUnknown(data['date_debut']!, _dateDebutMeta),
      );
    }
    if (data.containsKey('date_fin')) {
      context.handle(
        _dateFinMeta,
        dateFin.isAcceptableOrUnknown(data['date_fin']!, _dateFinMeta),
      );
    }
    if (data.containsKey('difference')) {
      context.handle(
        _differenceMeta,
        difference.isAcceptableOrUnknown(data['difference']!, _differenceMeta),
      );
    }
    if (data.containsKey('absent')) {
      context.handle(
        _absentMeta,
        absent.isAcceptableOrUnknown(data['absent']!, _absentMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  FeuilleEmploye map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeuilleEmploye(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      mobileUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_uuid'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      ),
      feuilleLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feuille_local_id'],
      )!,
      employeeOdooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employee_odoo_id'],
      )!,
      fonction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fonction'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
      dateEmp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_emp'],
      ),
      dateDebut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_debut'],
      ),
      dateFin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_fin'],
      ),
      difference: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difference'],
      ),
      absent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}absent'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeuilleEmployesTable createAlias(String alias) {
    return $FeuilleEmployesTable(attachedDatabase, alias);
  }
}

class FeuilleEmploye extends DataClass implements Insertable<FeuilleEmploye> {
  final int localId;
  final String mobileUuid;
  final int? odooId;
  final int feuilleLocalId;
  final int employeeOdooId;
  final String? fonction;
  final String? observation;
  final String? dateEmp;
  final String? dateDebut;
  final String? dateFin;
  final double? difference;
  final bool absent;
  final String syncStatus;
  final bool isVisible;
  final String createdAt;
  final String updatedAt;
  const FeuilleEmploye({
    required this.localId,
    required this.mobileUuid,
    this.odooId,
    required this.feuilleLocalId,
    required this.employeeOdooId,
    this.fonction,
    this.observation,
    this.dateEmp,
    this.dateDebut,
    this.dateFin,
    this.difference,
    required this.absent,
    required this.syncStatus,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['mobile_uuid'] = Variable<String>(mobileUuid);
    if (!nullToAbsent || odooId != null) {
      map['odoo_id'] = Variable<int>(odooId);
    }
    map['feuille_local_id'] = Variable<int>(feuilleLocalId);
    map['employee_odoo_id'] = Variable<int>(employeeOdooId);
    if (!nullToAbsent || fonction != null) {
      map['fonction'] = Variable<String>(fonction);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    if (!nullToAbsent || dateEmp != null) {
      map['date_emp'] = Variable<String>(dateEmp);
    }
    if (!nullToAbsent || dateDebut != null) {
      map['date_debut'] = Variable<String>(dateDebut);
    }
    if (!nullToAbsent || dateFin != null) {
      map['date_fin'] = Variable<String>(dateFin);
    }
    if (!nullToAbsent || difference != null) {
      map['difference'] = Variable<double>(difference);
    }
    map['absent'] = Variable<bool>(absent);
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_visible'] = Variable<bool>(isVisible);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FeuilleEmployesCompanion toCompanion(bool nullToAbsent) {
    return FeuilleEmployesCompanion(
      localId: Value(localId),
      mobileUuid: Value(mobileUuid),
      odooId: odooId == null && nullToAbsent
          ? const Value.absent()
          : Value(odooId),
      feuilleLocalId: Value(feuilleLocalId),
      employeeOdooId: Value(employeeOdooId),
      fonction: fonction == null && nullToAbsent
          ? const Value.absent()
          : Value(fonction),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
      dateEmp: dateEmp == null && nullToAbsent
          ? const Value.absent()
          : Value(dateEmp),
      dateDebut: dateDebut == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDebut),
      dateFin: dateFin == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFin),
      difference: difference == null && nullToAbsent
          ? const Value.absent()
          : Value(difference),
      absent: Value(absent),
      syncStatus: Value(syncStatus),
      isVisible: Value(isVisible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeuilleEmploye.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeuilleEmploye(
      localId: serializer.fromJson<int>(json['localId']),
      mobileUuid: serializer.fromJson<String>(json['mobileUuid']),
      odooId: serializer.fromJson<int?>(json['odooId']),
      feuilleLocalId: serializer.fromJson<int>(json['feuilleLocalId']),
      employeeOdooId: serializer.fromJson<int>(json['employeeOdooId']),
      fonction: serializer.fromJson<String?>(json['fonction']),
      observation: serializer.fromJson<String?>(json['observation']),
      dateEmp: serializer.fromJson<String?>(json['dateEmp']),
      dateDebut: serializer.fromJson<String?>(json['dateDebut']),
      dateFin: serializer.fromJson<String?>(json['dateFin']),
      difference: serializer.fromJson<double?>(json['difference']),
      absent: serializer.fromJson<bool>(json['absent']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'mobileUuid': serializer.toJson<String>(mobileUuid),
      'odooId': serializer.toJson<int?>(odooId),
      'feuilleLocalId': serializer.toJson<int>(feuilleLocalId),
      'employeeOdooId': serializer.toJson<int>(employeeOdooId),
      'fonction': serializer.toJson<String?>(fonction),
      'observation': serializer.toJson<String?>(observation),
      'dateEmp': serializer.toJson<String?>(dateEmp),
      'dateDebut': serializer.toJson<String?>(dateDebut),
      'dateFin': serializer.toJson<String?>(dateFin),
      'difference': serializer.toJson<double?>(difference),
      'absent': serializer.toJson<bool>(absent),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isVisible': serializer.toJson<bool>(isVisible),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FeuilleEmploye copyWith({
    int? localId,
    String? mobileUuid,
    Value<int?> odooId = const Value.absent(),
    int? feuilleLocalId,
    int? employeeOdooId,
    Value<String?> fonction = const Value.absent(),
    Value<String?> observation = const Value.absent(),
    Value<String?> dateEmp = const Value.absent(),
    Value<String?> dateDebut = const Value.absent(),
    Value<String?> dateFin = const Value.absent(),
    Value<double?> difference = const Value.absent(),
    bool? absent,
    String? syncStatus,
    bool? isVisible,
    String? createdAt,
    String? updatedAt,
  }) => FeuilleEmploye(
    localId: localId ?? this.localId,
    mobileUuid: mobileUuid ?? this.mobileUuid,
    odooId: odooId.present ? odooId.value : this.odooId,
    feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
    employeeOdooId: employeeOdooId ?? this.employeeOdooId,
    fonction: fonction.present ? fonction.value : this.fonction,
    observation: observation.present ? observation.value : this.observation,
    dateEmp: dateEmp.present ? dateEmp.value : this.dateEmp,
    dateDebut: dateDebut.present ? dateDebut.value : this.dateDebut,
    dateFin: dateFin.present ? dateFin.value : this.dateFin,
    difference: difference.present ? difference.value : this.difference,
    absent: absent ?? this.absent,
    syncStatus: syncStatus ?? this.syncStatus,
    isVisible: isVisible ?? this.isVisible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeuilleEmploye copyWithCompanion(FeuilleEmployesCompanion data) {
    return FeuilleEmploye(
      localId: data.localId.present ? data.localId.value : this.localId,
      mobileUuid: data.mobileUuid.present
          ? data.mobileUuid.value
          : this.mobileUuid,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      feuilleLocalId: data.feuilleLocalId.present
          ? data.feuilleLocalId.value
          : this.feuilleLocalId,
      employeeOdooId: data.employeeOdooId.present
          ? data.employeeOdooId.value
          : this.employeeOdooId,
      fonction: data.fonction.present ? data.fonction.value : this.fonction,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      dateEmp: data.dateEmp.present ? data.dateEmp.value : this.dateEmp,
      dateDebut: data.dateDebut.present ? data.dateDebut.value : this.dateDebut,
      dateFin: data.dateFin.present ? data.dateFin.value : this.dateFin,
      difference: data.difference.present
          ? data.difference.value
          : this.difference,
      absent: data.absent.present ? data.absent.value : this.absent,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleEmploye(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('employeeOdooId: $employeeOdooId, ')
          ..write('fonction: $fonction, ')
          ..write('observation: $observation, ')
          ..write('dateEmp: $dateEmp, ')
          ..write('dateDebut: $dateDebut, ')
          ..write('dateFin: $dateFin, ')
          ..write('difference: $difference, ')
          ..write('absent: $absent, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    employeeOdooId,
    fonction,
    observation,
    dateEmp,
    dateDebut,
    dateFin,
    difference,
    absent,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeuilleEmploye &&
          other.localId == this.localId &&
          other.mobileUuid == this.mobileUuid &&
          other.odooId == this.odooId &&
          other.feuilleLocalId == this.feuilleLocalId &&
          other.employeeOdooId == this.employeeOdooId &&
          other.fonction == this.fonction &&
          other.observation == this.observation &&
          other.dateEmp == this.dateEmp &&
          other.dateDebut == this.dateDebut &&
          other.dateFin == this.dateFin &&
          other.difference == this.difference &&
          other.absent == this.absent &&
          other.syncStatus == this.syncStatus &&
          other.isVisible == this.isVisible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeuilleEmployesCompanion extends UpdateCompanion<FeuilleEmploye> {
  final Value<int> localId;
  final Value<String> mobileUuid;
  final Value<int?> odooId;
  final Value<int> feuilleLocalId;
  final Value<int> employeeOdooId;
  final Value<String?> fonction;
  final Value<String?> observation;
  final Value<String?> dateEmp;
  final Value<String?> dateDebut;
  final Value<String?> dateFin;
  final Value<double?> difference;
  final Value<bool> absent;
  final Value<String> syncStatus;
  final Value<bool> isVisible;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FeuilleEmployesCompanion({
    this.localId = const Value.absent(),
    this.mobileUuid = const Value.absent(),
    this.odooId = const Value.absent(),
    this.feuilleLocalId = const Value.absent(),
    this.employeeOdooId = const Value.absent(),
    this.fonction = const Value.absent(),
    this.observation = const Value.absent(),
    this.dateEmp = const Value.absent(),
    this.dateDebut = const Value.absent(),
    this.dateFin = const Value.absent(),
    this.difference = const Value.absent(),
    this.absent = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeuilleEmployesCompanion.insert({
    this.localId = const Value.absent(),
    required String mobileUuid,
    this.odooId = const Value.absent(),
    required int feuilleLocalId,
    required int employeeOdooId,
    this.fonction = const Value.absent(),
    this.observation = const Value.absent(),
    this.dateEmp = const Value.absent(),
    this.dateDebut = const Value.absent(),
    this.dateFin = const Value.absent(),
    this.difference = const Value.absent(),
    this.absent = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : mobileUuid = Value(mobileUuid),
       feuilleLocalId = Value(feuilleLocalId),
       employeeOdooId = Value(employeeOdooId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeuilleEmploye> custom({
    Expression<int>? localId,
    Expression<String>? mobileUuid,
    Expression<int>? odooId,
    Expression<int>? feuilleLocalId,
    Expression<int>? employeeOdooId,
    Expression<String>? fonction,
    Expression<String>? observation,
    Expression<String>? dateEmp,
    Expression<String>? dateDebut,
    Expression<String>? dateFin,
    Expression<double>? difference,
    Expression<bool>? absent,
    Expression<String>? syncStatus,
    Expression<bool>? isVisible,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (mobileUuid != null) 'mobile_uuid': mobileUuid,
      if (odooId != null) 'odoo_id': odooId,
      if (feuilleLocalId != null) 'feuille_local_id': feuilleLocalId,
      if (employeeOdooId != null) 'employee_odoo_id': employeeOdooId,
      if (fonction != null) 'fonction': fonction,
      if (observation != null) 'observation': observation,
      if (dateEmp != null) 'date_emp': dateEmp,
      if (dateDebut != null) 'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (difference != null) 'difference': difference,
      if (absent != null) 'absent': absent,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isVisible != null) 'is_visible': isVisible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeuilleEmployesCompanion copyWith({
    Value<int>? localId,
    Value<String>? mobileUuid,
    Value<int?>? odooId,
    Value<int>? feuilleLocalId,
    Value<int>? employeeOdooId,
    Value<String?>? fonction,
    Value<String?>? observation,
    Value<String?>? dateEmp,
    Value<String?>? dateDebut,
    Value<String?>? dateFin,
    Value<double?>? difference,
    Value<bool>? absent,
    Value<String>? syncStatus,
    Value<bool>? isVisible,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FeuilleEmployesCompanion(
      localId: localId ?? this.localId,
      mobileUuid: mobileUuid ?? this.mobileUuid,
      odooId: odooId ?? this.odooId,
      feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
      employeeOdooId: employeeOdooId ?? this.employeeOdooId,
      fonction: fonction ?? this.fonction,
      observation: observation ?? this.observation,
      dateEmp: dateEmp ?? this.dateEmp,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      difference: difference ?? this.difference,
      absent: absent ?? this.absent,
      syncStatus: syncStatus ?? this.syncStatus,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (mobileUuid.present) {
      map['mobile_uuid'] = Variable<String>(mobileUuid.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (feuilleLocalId.present) {
      map['feuille_local_id'] = Variable<int>(feuilleLocalId.value);
    }
    if (employeeOdooId.present) {
      map['employee_odoo_id'] = Variable<int>(employeeOdooId.value);
    }
    if (fonction.present) {
      map['fonction'] = Variable<String>(fonction.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (dateEmp.present) {
      map['date_emp'] = Variable<String>(dateEmp.value);
    }
    if (dateDebut.present) {
      map['date_debut'] = Variable<String>(dateDebut.value);
    }
    if (dateFin.present) {
      map['date_fin'] = Variable<String>(dateFin.value);
    }
    if (difference.present) {
      map['difference'] = Variable<double>(difference.value);
    }
    if (absent.present) {
      map['absent'] = Variable<bool>(absent.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleEmployesCompanion(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('employeeOdooId: $employeeOdooId, ')
          ..write('fonction: $fonction, ')
          ..write('observation: $observation, ')
          ..write('dateEmp: $dateEmp, ')
          ..write('dateDebut: $dateDebut, ')
          ..write('dateFin: $dateFin, ')
          ..write('difference: $difference, ')
          ..write('absent: $absent, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeuilleMaterielsTable extends FeuilleMateriels
    with TableInfo<$FeuilleMaterielsTable, FeuilleMateriel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeuilleMaterielsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mobileUuidMeta = const VerificationMeta(
    'mobileUuid',
  );
  @override
  late final GeneratedColumn<String> mobileUuid = GeneratedColumn<String>(
    'mobile_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _odooIdMeta = const VerificationMeta('odooId');
  @override
  late final GeneratedColumn<int> odooId = GeneratedColumn<int>(
    'odoo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feuilleLocalIdMeta = const VerificationMeta(
    'feuilleLocalId',
  );
  @override
  late final GeneratedColumn<int> feuilleLocalId = GeneratedColumn<int>(
    'feuille_local_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    description,
    serialNumber,
    quantity,
    observation,
    status,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feuille_materiels';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeuilleMateriel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('mobile_uuid')) {
      context.handle(
        _mobileUuidMeta,
        mobileUuid.isAcceptableOrUnknown(data['mobile_uuid']!, _mobileUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_mobileUuidMeta);
    }
    if (data.containsKey('odoo_id')) {
      context.handle(
        _odooIdMeta,
        odooId.isAcceptableOrUnknown(data['odoo_id']!, _odooIdMeta),
      );
    }
    if (data.containsKey('feuille_local_id')) {
      context.handle(
        _feuilleLocalIdMeta,
        feuilleLocalId.isAcceptableOrUnknown(
          data['feuille_local_id']!,
          _feuilleLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feuilleLocalIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  FeuilleMateriel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeuilleMateriel(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      mobileUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_uuid'],
      )!,
      odooId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odoo_id'],
      ),
      feuilleLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feuille_local_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeuilleMaterielsTable createAlias(String alias) {
    return $FeuilleMaterielsTable(attachedDatabase, alias);
  }
}

class FeuilleMateriel extends DataClass implements Insertable<FeuilleMateriel> {
  final int localId;
  final String mobileUuid;
  final int? odooId;
  final int feuilleLocalId;
  final String? description;
  final String? serialNumber;
  final double? quantity;
  final String? observation;
  final String? status;
  final String syncStatus;
  final bool isVisible;
  final String createdAt;
  final String updatedAt;
  const FeuilleMateriel({
    required this.localId,
    required this.mobileUuid,
    this.odooId,
    required this.feuilleLocalId,
    this.description,
    this.serialNumber,
    this.quantity,
    this.observation,
    this.status,
    required this.syncStatus,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['mobile_uuid'] = Variable<String>(mobileUuid);
    if (!nullToAbsent || odooId != null) {
      map['odoo_id'] = Variable<int>(odooId);
    }
    map['feuille_local_id'] = Variable<int>(feuilleLocalId);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || serialNumber != null) {
      map['serial_number'] = Variable<String>(serialNumber);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['is_visible'] = Variable<bool>(isVisible);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FeuilleMaterielsCompanion toCompanion(bool nullToAbsent) {
    return FeuilleMaterielsCompanion(
      localId: Value(localId),
      mobileUuid: Value(mobileUuid),
      odooId: odooId == null && nullToAbsent
          ? const Value.absent()
          : Value(odooId),
      feuilleLocalId: Value(feuilleLocalId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      serialNumber: serialNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(serialNumber),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      syncStatus: Value(syncStatus),
      isVisible: Value(isVisible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeuilleMateriel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeuilleMateriel(
      localId: serializer.fromJson<int>(json['localId']),
      mobileUuid: serializer.fromJson<String>(json['mobileUuid']),
      odooId: serializer.fromJson<int?>(json['odooId']),
      feuilleLocalId: serializer.fromJson<int>(json['feuilleLocalId']),
      description: serializer.fromJson<String?>(json['description']),
      serialNumber: serializer.fromJson<String?>(json['serialNumber']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      observation: serializer.fromJson<String?>(json['observation']),
      status: serializer.fromJson<String?>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'mobileUuid': serializer.toJson<String>(mobileUuid),
      'odooId': serializer.toJson<int?>(odooId),
      'feuilleLocalId': serializer.toJson<int>(feuilleLocalId),
      'description': serializer.toJson<String?>(description),
      'serialNumber': serializer.toJson<String?>(serialNumber),
      'quantity': serializer.toJson<double?>(quantity),
      'observation': serializer.toJson<String?>(observation),
      'status': serializer.toJson<String?>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'isVisible': serializer.toJson<bool>(isVisible),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FeuilleMateriel copyWith({
    int? localId,
    String? mobileUuid,
    Value<int?> odooId = const Value.absent(),
    int? feuilleLocalId,
    Value<String?> description = const Value.absent(),
    Value<String?> serialNumber = const Value.absent(),
    Value<double?> quantity = const Value.absent(),
    Value<String?> observation = const Value.absent(),
    Value<String?> status = const Value.absent(),
    String? syncStatus,
    bool? isVisible,
    String? createdAt,
    String? updatedAt,
  }) => FeuilleMateriel(
    localId: localId ?? this.localId,
    mobileUuid: mobileUuid ?? this.mobileUuid,
    odooId: odooId.present ? odooId.value : this.odooId,
    feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
    description: description.present ? description.value : this.description,
    serialNumber: serialNumber.present ? serialNumber.value : this.serialNumber,
    quantity: quantity.present ? quantity.value : this.quantity,
    observation: observation.present ? observation.value : this.observation,
    status: status.present ? status.value : this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    isVisible: isVisible ?? this.isVisible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeuilleMateriel copyWithCompanion(FeuilleMaterielsCompanion data) {
    return FeuilleMateriel(
      localId: data.localId.present ? data.localId.value : this.localId,
      mobileUuid: data.mobileUuid.present
          ? data.mobileUuid.value
          : this.mobileUuid,
      odooId: data.odooId.present ? data.odooId.value : this.odooId,
      feuilleLocalId: data.feuilleLocalId.present
          ? data.feuilleLocalId.value
          : this.feuilleLocalId,
      description: data.description.present
          ? data.description.value
          : this.description,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleMateriel(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('description: $description, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('quantity: $quantity, ')
          ..write('observation: $observation, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    mobileUuid,
    odooId,
    feuilleLocalId,
    description,
    serialNumber,
    quantity,
    observation,
    status,
    syncStatus,
    isVisible,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeuilleMateriel &&
          other.localId == this.localId &&
          other.mobileUuid == this.mobileUuid &&
          other.odooId == this.odooId &&
          other.feuilleLocalId == this.feuilleLocalId &&
          other.description == this.description &&
          other.serialNumber == this.serialNumber &&
          other.quantity == this.quantity &&
          other.observation == this.observation &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.isVisible == this.isVisible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeuilleMaterielsCompanion extends UpdateCompanion<FeuilleMateriel> {
  final Value<int> localId;
  final Value<String> mobileUuid;
  final Value<int?> odooId;
  final Value<int> feuilleLocalId;
  final Value<String?> description;
  final Value<String?> serialNumber;
  final Value<double?> quantity;
  final Value<String?> observation;
  final Value<String?> status;
  final Value<String> syncStatus;
  final Value<bool> isVisible;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FeuilleMaterielsCompanion({
    this.localId = const Value.absent(),
    this.mobileUuid = const Value.absent(),
    this.odooId = const Value.absent(),
    this.feuilleLocalId = const Value.absent(),
    this.description = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.quantity = const Value.absent(),
    this.observation = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeuilleMaterielsCompanion.insert({
    this.localId = const Value.absent(),
    required String mobileUuid,
    this.odooId = const Value.absent(),
    required int feuilleLocalId,
    this.description = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.quantity = const Value.absent(),
    this.observation = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.isVisible = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : mobileUuid = Value(mobileUuid),
       feuilleLocalId = Value(feuilleLocalId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeuilleMateriel> custom({
    Expression<int>? localId,
    Expression<String>? mobileUuid,
    Expression<int>? odooId,
    Expression<int>? feuilleLocalId,
    Expression<String>? description,
    Expression<String>? serialNumber,
    Expression<double>? quantity,
    Expression<String>? observation,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<bool>? isVisible,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (mobileUuid != null) 'mobile_uuid': mobileUuid,
      if (odooId != null) 'odoo_id': odooId,
      if (feuilleLocalId != null) 'feuille_local_id': feuilleLocalId,
      if (description != null) 'description': description,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (quantity != null) 'quantity': quantity,
      if (observation != null) 'observation': observation,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (isVisible != null) 'is_visible': isVisible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeuilleMaterielsCompanion copyWith({
    Value<int>? localId,
    Value<String>? mobileUuid,
    Value<int?>? odooId,
    Value<int>? feuilleLocalId,
    Value<String?>? description,
    Value<String?>? serialNumber,
    Value<double?>? quantity,
    Value<String?>? observation,
    Value<String?>? status,
    Value<String>? syncStatus,
    Value<bool>? isVisible,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FeuilleMaterielsCompanion(
      localId: localId ?? this.localId,
      mobileUuid: mobileUuid ?? this.mobileUuid,
      odooId: odooId ?? this.odooId,
      feuilleLocalId: feuilleLocalId ?? this.feuilleLocalId,
      description: description ?? this.description,
      serialNumber: serialNumber ?? this.serialNumber,
      quantity: quantity ?? this.quantity,
      observation: observation ?? this.observation,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (mobileUuid.present) {
      map['mobile_uuid'] = Variable<String>(mobileUuid.value);
    }
    if (odooId.present) {
      map['odoo_id'] = Variable<int>(odooId.value);
    }
    if (feuilleLocalId.present) {
      map['feuille_local_id'] = Variable<int>(feuilleLocalId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeuilleMaterielsCompanion(')
          ..write('localId: $localId, ')
          ..write('mobileUuid: $mobileUuid, ')
          ..write('odooId: $odooId, ')
          ..write('feuilleLocalId: $feuilleLocalId, ')
          ..write('description: $description, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('quantity: $quantity, ')
          ..write('observation: $observation, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('isVisible: $isVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $EquipmentsTable equipments = $EquipmentsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $MaterialReferencesTable materialReferences =
      $MaterialReferencesTable(this);
  late final $FeuillesTable feuilles = $FeuillesTable(this);
  late final $FeuilleLignesTable feuilleLignes = $FeuilleLignesTable(this);
  late final $FeuilleFuelsTable feuilleFuels = $FeuilleFuelsTable(this);
  late final $FeuilleEmployesTable feuilleEmployes = $FeuilleEmployesTable(
    this,
  );
  late final $FeuilleMaterielsTable feuilleMateriels = $FeuilleMaterielsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    employees,
    equipments,
    tasks,
    locations,
    materialReferences,
    feuilles,
    feuilleLignes,
    feuilleFuels,
    feuilleEmployes,
    feuilleMateriels,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> localId,
      required int odooId,
      required String name,
      Value<int?> partnerOdooId,
      Value<String?> partnerName,
      Value<double?> dateDJ,
      Value<double?> dateDN,
      Value<bool> active,
      Value<String?> updatedAt,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> localId,
      Value<int> odooId,
      Value<String> name,
      Value<int?> partnerOdooId,
      Value<String?> partnerName,
      Value<double?> dateDJ,
      Value<double?> dateDN,
      Value<bool> active,
      Value<String?> updatedAt,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partnerOdooId => $composableBuilder(
    column: $table.partnerOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateDJ => $composableBuilder(
    column: $table.dateDJ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateDN => $composableBuilder(
    column: $table.dateDN,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partnerOdooId => $composableBuilder(
    column: $table.partnerOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateDJ => $composableBuilder(
    column: $table.dateDJ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateDN => $composableBuilder(
    column: $table.dateDN,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get partnerOdooId => $composableBuilder(
    column: $table.partnerOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dateDJ =>
      $composableBuilder(column: $table.dateDJ, builder: (column) => column);

  GeneratedColumn<double> get dateDN =>
      $composableBuilder(column: $table.dateDN, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> odooId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> partnerOdooId = const Value.absent(),
                Value<String?> partnerName = const Value.absent(),
                Value<double?> dateDJ = const Value.absent(),
                Value<double?> dateDN = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => ProjectsCompanion(
                localId: localId,
                odooId: odooId,
                name: name,
                partnerOdooId: partnerOdooId,
                partnerName: partnerName,
                dateDJ: dateDJ,
                dateDN: dateDN,
                active: active,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int odooId,
                required String name,
                Value<int?> partnerOdooId = const Value.absent(),
                Value<String?> partnerName = const Value.absent(),
                Value<double?> dateDJ = const Value.absent(),
                Value<double?> dateDN = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => ProjectsCompanion.insert(
                localId: localId,
                odooId: odooId,
                name: name,
                partnerOdooId: partnerOdooId,
                partnerName: partnerName,
                dateDJ: dateDJ,
                dateDN: dateDN,
                active: active,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$EmployeesTableCreateCompanionBuilder =
    EmployeesCompanion Function({
      Value<int> localId,
      required int odooId,
      required String name,
      Value<String?> jobName,
      Value<bool> active,
      Value<String?> updatedAt,
    });
typedef $$EmployeesTableUpdateCompanionBuilder =
    EmployeesCompanion Function({
      Value<int> localId,
      Value<int> odooId,
      Value<String> name,
      Value<String?> jobName,
      Value<bool> active,
      Value<String?> updatedAt,
    });

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobName => $composableBuilder(
    column: $table.jobName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobName => $composableBuilder(
    column: $table.jobName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get jobName =>
      $composableBuilder(column: $table.jobName, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          Employee,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
          Employee,
          PrefetchHooks Function()
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> odooId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> jobName = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => EmployeesCompanion(
                localId: localId,
                odooId: odooId,
                name: name,
                jobName: jobName,
                active: active,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int odooId,
                required String name,
                Value<String?> jobName = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => EmployeesCompanion.insert(
                localId: localId,
                odooId: odooId,
                name: name,
                jobName: jobName,
                active: active,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      Employee,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (Employee, BaseReferences<_$AppDatabase, $EmployeesTable, Employee>),
      Employee,
      PrefetchHooks Function()
    >;
typedef $$EquipmentsTableCreateCompanionBuilder =
    EquipmentsCompanion Function({
      Value<int> localId,
      required int odooId,
      required String name,
      Value<String?> categoryName,
      Value<int?> projectOdooId,
      Value<bool> active,
      Value<String?> updatedAt,
    });
typedef $$EquipmentsTableUpdateCompanionBuilder =
    EquipmentsCompanion Function({
      Value<int> localId,
      Value<int> odooId,
      Value<String> name,
      Value<String?> categoryName,
      Value<int?> projectOdooId,
      Value<bool> active,
      Value<String?> updatedAt,
    });

class $$EquipmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectOdooId => $composableBuilder(
    column: $table.projectOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EquipmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectOdooId => $composableBuilder(
    column: $table.projectOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get projectOdooId => $composableBuilder(
    column: $table.projectOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EquipmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EquipmentsTable,
          Equipment,
          $$EquipmentsTableFilterComposer,
          $$EquipmentsTableOrderingComposer,
          $$EquipmentsTableAnnotationComposer,
          $$EquipmentsTableCreateCompanionBuilder,
          $$EquipmentsTableUpdateCompanionBuilder,
          (
            Equipment,
            BaseReferences<_$AppDatabase, $EquipmentsTable, Equipment>,
          ),
          Equipment,
          PrefetchHooks Function()
        > {
  $$EquipmentsTableTableManager(_$AppDatabase db, $EquipmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> odooId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<int?> projectOdooId = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => EquipmentsCompanion(
                localId: localId,
                odooId: odooId,
                name: name,
                categoryName: categoryName,
                projectOdooId: projectOdooId,
                active: active,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int odooId,
                required String name,
                Value<String?> categoryName = const Value.absent(),
                Value<int?> projectOdooId = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => EquipmentsCompanion.insert(
                localId: localId,
                odooId: odooId,
                name: name,
                categoryName: categoryName,
                projectOdooId: projectOdooId,
                active: active,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EquipmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EquipmentsTable,
      Equipment,
      $$EquipmentsTableFilterComposer,
      $$EquipmentsTableOrderingComposer,
      $$EquipmentsTableAnnotationComposer,
      $$EquipmentsTableCreateCompanionBuilder,
      $$EquipmentsTableUpdateCompanionBuilder,
      (Equipment, BaseReferences<_$AppDatabase, $EquipmentsTable, Equipment>),
      Equipment,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> localId,
      required int odooId,
      Value<String?> numItem,
      required String libelle,
      Value<String?> typeTache,
      Value<String?> categorieActivity,
      Value<String?> categorie,
      Value<String?> typeActivite,
      Value<String?> updatedAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> localId,
      Value<int> odooId,
      Value<String?> numItem,
      Value<String> libelle,
      Value<String?> typeTache,
      Value<String?> categorieActivity,
      Value<String?> categorie,
      Value<String?> typeActivite,
      Value<String?> updatedAt,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numItem => $composableBuilder(
    column: $table.numItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libelle => $composableBuilder(
    column: $table.libelle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeTache => $composableBuilder(
    column: $table.typeTache,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorieActivity => $composableBuilder(
    column: $table.categorieActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeActivite => $composableBuilder(
    column: $table.typeActivite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numItem => $composableBuilder(
    column: $table.numItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libelle => $composableBuilder(
    column: $table.libelle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeTache => $composableBuilder(
    column: $table.typeTache,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorieActivity => $composableBuilder(
    column: $table.categorieActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeActivite => $composableBuilder(
    column: $table.typeActivite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<String> get numItem =>
      $composableBuilder(column: $table.numItem, builder: (column) => column);

  GeneratedColumn<String> get libelle =>
      $composableBuilder(column: $table.libelle, builder: (column) => column);

  GeneratedColumn<String> get typeTache =>
      $composableBuilder(column: $table.typeTache, builder: (column) => column);

  GeneratedColumn<String> get categorieActivity => $composableBuilder(
    column: $table.categorieActivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get typeActivite => $composableBuilder(
    column: $table.typeActivite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> odooId = const Value.absent(),
                Value<String?> numItem = const Value.absent(),
                Value<String> libelle = const Value.absent(),
                Value<String?> typeTache = const Value.absent(),
                Value<String?> categorieActivity = const Value.absent(),
                Value<String?> categorie = const Value.absent(),
                Value<String?> typeActivite = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TasksCompanion(
                localId: localId,
                odooId: odooId,
                numItem: numItem,
                libelle: libelle,
                typeTache: typeTache,
                categorieActivity: categorieActivity,
                categorie: categorie,
                typeActivite: typeActivite,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int odooId,
                Value<String?> numItem = const Value.absent(),
                required String libelle,
                Value<String?> typeTache = const Value.absent(),
                Value<String?> categorieActivity = const Value.absent(),
                Value<String?> categorie = const Value.absent(),
                Value<String?> typeActivite = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => TasksCompanion.insert(
                localId: localId,
                odooId: odooId,
                numItem: numItem,
                libelle: libelle,
                typeTache: typeTache,
                categorieActivity: categorieActivity,
                categorie: categorie,
                typeActivite: typeActivite,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      Value<int> localId,
      required int odooId,
      required String name,
      Value<String?> updatedAt,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<int> localId,
      Value<int> odooId,
      Value<String> name,
      Value<String?> updatedAt,
    });

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          Location,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
          Location,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> odooId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => LocationsCompanion(
                localId: localId,
                odooId: odooId,
                name: name,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int odooId,
                required String name,
                Value<String?> updatedAt = const Value.absent(),
              }) => LocationsCompanion.insert(
                localId: localId,
                odooId: odooId,
                name: name,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      Location,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
      Location,
      PrefetchHooks Function()
    >;
typedef $$MaterialReferencesTableCreateCompanionBuilder =
    MaterialReferencesCompanion Function({
      Value<int> localId,
      required int odooId,
      required String description,
      Value<String?> reference,
      Value<bool> active,
      Value<String?> updatedAt,
    });
typedef $$MaterialReferencesTableUpdateCompanionBuilder =
    MaterialReferencesCompanion Function({
      Value<int> localId,
      Value<int> odooId,
      Value<String> description,
      Value<String?> reference,
      Value<bool> active,
      Value<String?> updatedAt,
    });

class $$MaterialReferencesTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialReferencesTable> {
  $$MaterialReferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialReferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialReferencesTable> {
  $$MaterialReferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialReferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialReferencesTable> {
  $$MaterialReferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MaterialReferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialReferencesTable,
          MaterialReference,
          $$MaterialReferencesTableFilterComposer,
          $$MaterialReferencesTableOrderingComposer,
          $$MaterialReferencesTableAnnotationComposer,
          $$MaterialReferencesTableCreateCompanionBuilder,
          $$MaterialReferencesTableUpdateCompanionBuilder,
          (
            MaterialReference,
            BaseReferences<
              _$AppDatabase,
              $MaterialReferencesTable,
              MaterialReference
            >,
          ),
          MaterialReference,
          PrefetchHooks Function()
        > {
  $$MaterialReferencesTableTableManager(
    _$AppDatabase db,
    $MaterialReferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialReferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialReferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialReferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int> odooId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => MaterialReferencesCompanion(
                localId: localId,
                odooId: odooId,
                description: description,
                reference: reference,
                active: active,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required int odooId,
                required String description,
                Value<String?> reference = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
              }) => MaterialReferencesCompanion.insert(
                localId: localId,
                odooId: odooId,
                description: description,
                reference: reference,
                active: active,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialReferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialReferencesTable,
      MaterialReference,
      $$MaterialReferencesTableFilterComposer,
      $$MaterialReferencesTableOrderingComposer,
      $$MaterialReferencesTableAnnotationComposer,
      $$MaterialReferencesTableCreateCompanionBuilder,
      $$MaterialReferencesTableUpdateCompanionBuilder,
      (
        MaterialReference,
        BaseReferences<
          _$AppDatabase,
          $MaterialReferencesTable,
          MaterialReference
        >,
      ),
      MaterialReference,
      PrefetchHooks Function()
    >;
typedef $$FeuillesTableCreateCompanionBuilder =
    FeuillesCompanion Function({
      Value<int> localId,
      required String mobileUuid,
      Value<int?> odooId,
      required int nomProjetOdooId,
      required String quart,
      required String dateForage,
      Value<int?> foreuseOdooId,
      Value<int?> locationOdooId,
      Value<int?> hourMeter,
      Value<String?> fuelMeter,
      Value<String?> forageSignature,
      Value<String?> clientSignature,
      Value<String?> remarks,
      Value<String> syncStatus,
      Value<bool> isVisible,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FeuillesTableUpdateCompanionBuilder =
    FeuillesCompanion Function({
      Value<int> localId,
      Value<String> mobileUuid,
      Value<int?> odooId,
      Value<int> nomProjetOdooId,
      Value<String> quart,
      Value<String> dateForage,
      Value<int?> foreuseOdooId,
      Value<int?> locationOdooId,
      Value<int?> hourMeter,
      Value<String?> fuelMeter,
      Value<String?> forageSignature,
      Value<String?> clientSignature,
      Value<String?> remarks,
      Value<String> syncStatus,
      Value<bool> isVisible,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FeuillesTableFilterComposer
    extends Composer<_$AppDatabase, $FeuillesTable> {
  $$FeuillesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nomProjetOdooId => $composableBuilder(
    column: $table.nomProjetOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quart => $composableBuilder(
    column: $table.quart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateForage => $composableBuilder(
    column: $table.dateForage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foreuseOdooId => $composableBuilder(
    column: $table.foreuseOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationOdooId => $composableBuilder(
    column: $table.locationOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hourMeter => $composableBuilder(
    column: $table.hourMeter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelMeter => $composableBuilder(
    column: $table.fuelMeter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forageSignature => $composableBuilder(
    column: $table.forageSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientSignature => $composableBuilder(
    column: $table.clientSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeuillesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeuillesTable> {
  $$FeuillesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nomProjetOdooId => $composableBuilder(
    column: $table.nomProjetOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quart => $composableBuilder(
    column: $table.quart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateForage => $composableBuilder(
    column: $table.dateForage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foreuseOdooId => $composableBuilder(
    column: $table.foreuseOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationOdooId => $composableBuilder(
    column: $table.locationOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hourMeter => $composableBuilder(
    column: $table.hourMeter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelMeter => $composableBuilder(
    column: $table.fuelMeter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forageSignature => $composableBuilder(
    column: $table.forageSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientSignature => $composableBuilder(
    column: $table.clientSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeuillesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeuillesTable> {
  $$FeuillesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<int> get nomProjetOdooId => $composableBuilder(
    column: $table.nomProjetOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quart =>
      $composableBuilder(column: $table.quart, builder: (column) => column);

  GeneratedColumn<String> get dateForage => $composableBuilder(
    column: $table.dateForage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get foreuseOdooId => $composableBuilder(
    column: $table.foreuseOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get locationOdooId => $composableBuilder(
    column: $table.locationOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hourMeter =>
      $composableBuilder(column: $table.hourMeter, builder: (column) => column);

  GeneratedColumn<String> get fuelMeter =>
      $composableBuilder(column: $table.fuelMeter, builder: (column) => column);

  GeneratedColumn<String> get forageSignature => $composableBuilder(
    column: $table.forageSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientSignature => $composableBuilder(
    column: $table.clientSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeuillesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeuillesTable,
          Feuille,
          $$FeuillesTableFilterComposer,
          $$FeuillesTableOrderingComposer,
          $$FeuillesTableAnnotationComposer,
          $$FeuillesTableCreateCompanionBuilder,
          $$FeuillesTableUpdateCompanionBuilder,
          (Feuille, BaseReferences<_$AppDatabase, $FeuillesTable, Feuille>),
          Feuille,
          PrefetchHooks Function()
        > {
  $$FeuillesTableTableManager(_$AppDatabase db, $FeuillesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeuillesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeuillesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeuillesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> mobileUuid = const Value.absent(),
                Value<int?> odooId = const Value.absent(),
                Value<int> nomProjetOdooId = const Value.absent(),
                Value<String> quart = const Value.absent(),
                Value<String> dateForage = const Value.absent(),
                Value<int?> foreuseOdooId = const Value.absent(),
                Value<int?> locationOdooId = const Value.absent(),
                Value<int?> hourMeter = const Value.absent(),
                Value<String?> fuelMeter = const Value.absent(),
                Value<String?> forageSignature = const Value.absent(),
                Value<String?> clientSignature = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FeuillesCompanion(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                nomProjetOdooId: nomProjetOdooId,
                quart: quart,
                dateForage: dateForage,
                foreuseOdooId: foreuseOdooId,
                locationOdooId: locationOdooId,
                hourMeter: hourMeter,
                fuelMeter: fuelMeter,
                forageSignature: forageSignature,
                clientSignature: clientSignature,
                remarks: remarks,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String mobileUuid,
                Value<int?> odooId = const Value.absent(),
                required int nomProjetOdooId,
                required String quart,
                required String dateForage,
                Value<int?> foreuseOdooId = const Value.absent(),
                Value<int?> locationOdooId = const Value.absent(),
                Value<int?> hourMeter = const Value.absent(),
                Value<String?> fuelMeter = const Value.absent(),
                Value<String?> forageSignature = const Value.absent(),
                Value<String?> clientSignature = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FeuillesCompanion.insert(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                nomProjetOdooId: nomProjetOdooId,
                quart: quart,
                dateForage: dateForage,
                foreuseOdooId: foreuseOdooId,
                locationOdooId: locationOdooId,
                hourMeter: hourMeter,
                fuelMeter: fuelMeter,
                forageSignature: forageSignature,
                clientSignature: clientSignature,
                remarks: remarks,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeuillesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeuillesTable,
      Feuille,
      $$FeuillesTableFilterComposer,
      $$FeuillesTableOrderingComposer,
      $$FeuillesTableAnnotationComposer,
      $$FeuillesTableCreateCompanionBuilder,
      $$FeuillesTableUpdateCompanionBuilder,
      (Feuille, BaseReferences<_$AppDatabase, $FeuillesTable, Feuille>),
      Feuille,
      PrefetchHooks Function()
    >;
typedef $$FeuilleLignesTableCreateCompanionBuilder =
    FeuilleLignesCompanion Function({
      Value<int> localId,
      required String mobileUuid,
      Value<int?> odooId,
      required int feuilleLocalId,
      required String item,
      Value<int?> tacheOdooId,
      Value<String?> holeNo,
      Value<String?> note,
      Value<double?> dateD,
      Value<double?> dateF,
      Value<double?> rr,
      Value<int?> distance,
      Value<int?> fromDim,
      Value<int?> toDim,
      Value<int?> totalDim,
      Value<int> sequence,
      Value<String> syncStatus,
      Value<bool> isVisible,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FeuilleLignesTableUpdateCompanionBuilder =
    FeuilleLignesCompanion Function({
      Value<int> localId,
      Value<String> mobileUuid,
      Value<int?> odooId,
      Value<int> feuilleLocalId,
      Value<String> item,
      Value<int?> tacheOdooId,
      Value<String?> holeNo,
      Value<String?> note,
      Value<double?> dateD,
      Value<double?> dateF,
      Value<double?> rr,
      Value<int?> distance,
      Value<int?> fromDim,
      Value<int?> toDim,
      Value<int?> totalDim,
      Value<int> sequence,
      Value<String> syncStatus,
      Value<bool> isVisible,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FeuilleLignesTableFilterComposer
    extends Composer<_$AppDatabase, $FeuilleLignesTable> {
  $$FeuilleLignesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tacheOdooId => $composableBuilder(
    column: $table.tacheOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holeNo => $composableBuilder(
    column: $table.holeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateD => $composableBuilder(
    column: $table.dateD,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateF => $composableBuilder(
    column: $table.dateF,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rr => $composableBuilder(
    column: $table.rr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromDim => $composableBuilder(
    column: $table.fromDim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toDim => $composableBuilder(
    column: $table.toDim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDim => $composableBuilder(
    column: $table.totalDim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeuilleLignesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeuilleLignesTable> {
  $$FeuilleLignesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tacheOdooId => $composableBuilder(
    column: $table.tacheOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holeNo => $composableBuilder(
    column: $table.holeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateD => $composableBuilder(
    column: $table.dateD,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateF => $composableBuilder(
    column: $table.dateF,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rr => $composableBuilder(
    column: $table.rr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromDim => $composableBuilder(
    column: $table.fromDim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toDim => $composableBuilder(
    column: $table.toDim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDim => $composableBuilder(
    column: $table.totalDim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeuilleLignesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeuilleLignesTable> {
  $$FeuilleLignesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<int> get tacheOdooId => $composableBuilder(
    column: $table.tacheOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get holeNo =>
      $composableBuilder(column: $table.holeNo, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get dateD =>
      $composableBuilder(column: $table.dateD, builder: (column) => column);

  GeneratedColumn<double> get dateF =>
      $composableBuilder(column: $table.dateF, builder: (column) => column);

  GeneratedColumn<double> get rr =>
      $composableBuilder(column: $table.rr, builder: (column) => column);

  GeneratedColumn<int> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get fromDim =>
      $composableBuilder(column: $table.fromDim, builder: (column) => column);

  GeneratedColumn<int> get toDim =>
      $composableBuilder(column: $table.toDim, builder: (column) => column);

  GeneratedColumn<int> get totalDim =>
      $composableBuilder(column: $table.totalDim, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeuilleLignesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeuilleLignesTable,
          FeuilleLigne,
          $$FeuilleLignesTableFilterComposer,
          $$FeuilleLignesTableOrderingComposer,
          $$FeuilleLignesTableAnnotationComposer,
          $$FeuilleLignesTableCreateCompanionBuilder,
          $$FeuilleLignesTableUpdateCompanionBuilder,
          (
            FeuilleLigne,
            BaseReferences<_$AppDatabase, $FeuilleLignesTable, FeuilleLigne>,
          ),
          FeuilleLigne,
          PrefetchHooks Function()
        > {
  $$FeuilleLignesTableTableManager(_$AppDatabase db, $FeuilleLignesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeuilleLignesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeuilleLignesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeuilleLignesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> mobileUuid = const Value.absent(),
                Value<int?> odooId = const Value.absent(),
                Value<int> feuilleLocalId = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<int?> tacheOdooId = const Value.absent(),
                Value<String?> holeNo = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<double?> dateD = const Value.absent(),
                Value<double?> dateF = const Value.absent(),
                Value<double?> rr = const Value.absent(),
                Value<int?> distance = const Value.absent(),
                Value<int?> fromDim = const Value.absent(),
                Value<int?> toDim = const Value.absent(),
                Value<int?> totalDim = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FeuilleLignesCompanion(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                item: item,
                tacheOdooId: tacheOdooId,
                holeNo: holeNo,
                note: note,
                dateD: dateD,
                dateF: dateF,
                rr: rr,
                distance: distance,
                fromDim: fromDim,
                toDim: toDim,
                totalDim: totalDim,
                sequence: sequence,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String mobileUuid,
                Value<int?> odooId = const Value.absent(),
                required int feuilleLocalId,
                required String item,
                Value<int?> tacheOdooId = const Value.absent(),
                Value<String?> holeNo = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<double?> dateD = const Value.absent(),
                Value<double?> dateF = const Value.absent(),
                Value<double?> rr = const Value.absent(),
                Value<int?> distance = const Value.absent(),
                Value<int?> fromDim = const Value.absent(),
                Value<int?> toDim = const Value.absent(),
                Value<int?> totalDim = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FeuilleLignesCompanion.insert(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                item: item,
                tacheOdooId: tacheOdooId,
                holeNo: holeNo,
                note: note,
                dateD: dateD,
                dateF: dateF,
                rr: rr,
                distance: distance,
                fromDim: fromDim,
                toDim: toDim,
                totalDim: totalDim,
                sequence: sequence,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeuilleLignesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeuilleLignesTable,
      FeuilleLigne,
      $$FeuilleLignesTableFilterComposer,
      $$FeuilleLignesTableOrderingComposer,
      $$FeuilleLignesTableAnnotationComposer,
      $$FeuilleLignesTableCreateCompanionBuilder,
      $$FeuilleLignesTableUpdateCompanionBuilder,
      (
        FeuilleLigne,
        BaseReferences<_$AppDatabase, $FeuilleLignesTable, FeuilleLigne>,
      ),
      FeuilleLigne,
      PrefetchHooks Function()
    >;
typedef $$FeuilleFuelsTableCreateCompanionBuilder =
    FeuilleFuelsCompanion Function({
      Value<int> localId,
      required String mobileUuid,
      Value<int?> odooId,
      required int feuilleLocalId,
      Value<int?> compresseurOdooId,
      Value<double> qytFuel,
      Value<double?> dateDEqui,
      Value<double?> dateFEqui,
      Value<double?> dateDRavi,
      Value<double?> dateFRavi,
      Value<String> syncStatus,
      Value<bool> isVisible,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FeuilleFuelsTableUpdateCompanionBuilder =
    FeuilleFuelsCompanion Function({
      Value<int> localId,
      Value<String> mobileUuid,
      Value<int?> odooId,
      Value<int> feuilleLocalId,
      Value<int?> compresseurOdooId,
      Value<double> qytFuel,
      Value<double?> dateDEqui,
      Value<double?> dateFEqui,
      Value<double?> dateDRavi,
      Value<double?> dateFRavi,
      Value<String> syncStatus,
      Value<bool> isVisible,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FeuilleFuelsTableFilterComposer
    extends Composer<_$AppDatabase, $FeuilleFuelsTable> {
  $$FeuilleFuelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get compresseurOdooId => $composableBuilder(
    column: $table.compresseurOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qytFuel => $composableBuilder(
    column: $table.qytFuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateDEqui => $composableBuilder(
    column: $table.dateDEqui,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateFEqui => $composableBuilder(
    column: $table.dateFEqui,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateDRavi => $composableBuilder(
    column: $table.dateDRavi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dateFRavi => $composableBuilder(
    column: $table.dateFRavi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeuilleFuelsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeuilleFuelsTable> {
  $$FeuilleFuelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get compresseurOdooId => $composableBuilder(
    column: $table.compresseurOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qytFuel => $composableBuilder(
    column: $table.qytFuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateDEqui => $composableBuilder(
    column: $table.dateDEqui,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateFEqui => $composableBuilder(
    column: $table.dateFEqui,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateDRavi => $composableBuilder(
    column: $table.dateDRavi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dateFRavi => $composableBuilder(
    column: $table.dateFRavi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeuilleFuelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeuilleFuelsTable> {
  $$FeuilleFuelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get compresseurOdooId => $composableBuilder(
    column: $table.compresseurOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get qytFuel =>
      $composableBuilder(column: $table.qytFuel, builder: (column) => column);

  GeneratedColumn<double> get dateDEqui =>
      $composableBuilder(column: $table.dateDEqui, builder: (column) => column);

  GeneratedColumn<double> get dateFEqui =>
      $composableBuilder(column: $table.dateFEqui, builder: (column) => column);

  GeneratedColumn<double> get dateDRavi =>
      $composableBuilder(column: $table.dateDRavi, builder: (column) => column);

  GeneratedColumn<double> get dateFRavi =>
      $composableBuilder(column: $table.dateFRavi, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeuilleFuelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeuilleFuelsTable,
          FeuilleFuel,
          $$FeuilleFuelsTableFilterComposer,
          $$FeuilleFuelsTableOrderingComposer,
          $$FeuilleFuelsTableAnnotationComposer,
          $$FeuilleFuelsTableCreateCompanionBuilder,
          $$FeuilleFuelsTableUpdateCompanionBuilder,
          (
            FeuilleFuel,
            BaseReferences<_$AppDatabase, $FeuilleFuelsTable, FeuilleFuel>,
          ),
          FeuilleFuel,
          PrefetchHooks Function()
        > {
  $$FeuilleFuelsTableTableManager(_$AppDatabase db, $FeuilleFuelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeuilleFuelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeuilleFuelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeuilleFuelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> mobileUuid = const Value.absent(),
                Value<int?> odooId = const Value.absent(),
                Value<int> feuilleLocalId = const Value.absent(),
                Value<int?> compresseurOdooId = const Value.absent(),
                Value<double> qytFuel = const Value.absent(),
                Value<double?> dateDEqui = const Value.absent(),
                Value<double?> dateFEqui = const Value.absent(),
                Value<double?> dateDRavi = const Value.absent(),
                Value<double?> dateFRavi = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FeuilleFuelsCompanion(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                compresseurOdooId: compresseurOdooId,
                qytFuel: qytFuel,
                dateDEqui: dateDEqui,
                dateFEqui: dateFEqui,
                dateDRavi: dateDRavi,
                dateFRavi: dateFRavi,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String mobileUuid,
                Value<int?> odooId = const Value.absent(),
                required int feuilleLocalId,
                Value<int?> compresseurOdooId = const Value.absent(),
                Value<double> qytFuel = const Value.absent(),
                Value<double?> dateDEqui = const Value.absent(),
                Value<double?> dateFEqui = const Value.absent(),
                Value<double?> dateDRavi = const Value.absent(),
                Value<double?> dateFRavi = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FeuilleFuelsCompanion.insert(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                compresseurOdooId: compresseurOdooId,
                qytFuel: qytFuel,
                dateDEqui: dateDEqui,
                dateFEqui: dateFEqui,
                dateDRavi: dateDRavi,
                dateFRavi: dateFRavi,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeuilleFuelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeuilleFuelsTable,
      FeuilleFuel,
      $$FeuilleFuelsTableFilterComposer,
      $$FeuilleFuelsTableOrderingComposer,
      $$FeuilleFuelsTableAnnotationComposer,
      $$FeuilleFuelsTableCreateCompanionBuilder,
      $$FeuilleFuelsTableUpdateCompanionBuilder,
      (
        FeuilleFuel,
        BaseReferences<_$AppDatabase, $FeuilleFuelsTable, FeuilleFuel>,
      ),
      FeuilleFuel,
      PrefetchHooks Function()
    >;
typedef $$FeuilleEmployesTableCreateCompanionBuilder =
    FeuilleEmployesCompanion Function({
      Value<int> localId,
      required String mobileUuid,
      Value<int?> odooId,
      required int feuilleLocalId,
      required int employeeOdooId,
      Value<String?> fonction,
      Value<String?> observation,
      Value<String?> dateEmp,
      Value<String?> dateDebut,
      Value<String?> dateFin,
      Value<double?> difference,
      Value<bool> absent,
      Value<String> syncStatus,
      Value<bool> isVisible,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FeuilleEmployesTableUpdateCompanionBuilder =
    FeuilleEmployesCompanion Function({
      Value<int> localId,
      Value<String> mobileUuid,
      Value<int?> odooId,
      Value<int> feuilleLocalId,
      Value<int> employeeOdooId,
      Value<String?> fonction,
      Value<String?> observation,
      Value<String?> dateEmp,
      Value<String?> dateDebut,
      Value<String?> dateFin,
      Value<double?> difference,
      Value<bool> absent,
      Value<String> syncStatus,
      Value<bool> isVisible,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FeuilleEmployesTableFilterComposer
    extends Composer<_$AppDatabase, $FeuilleEmployesTable> {
  $$FeuilleEmployesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get employeeOdooId => $composableBuilder(
    column: $table.employeeOdooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateEmp => $composableBuilder(
    column: $table.dateEmp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateDebut => $composableBuilder(
    column: $table.dateDebut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateFin => $composableBuilder(
    column: $table.dateFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get absent => $composableBuilder(
    column: $table.absent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeuilleEmployesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeuilleEmployesTable> {
  $$FeuilleEmployesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get employeeOdooId => $composableBuilder(
    column: $table.employeeOdooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateEmp => $composableBuilder(
    column: $table.dateEmp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateDebut => $composableBuilder(
    column: $table.dateDebut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateFin => $composableBuilder(
    column: $table.dateFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get absent => $composableBuilder(
    column: $table.absent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeuilleEmployesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeuilleEmployesTable> {
  $$FeuilleEmployesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get employeeOdooId => $composableBuilder(
    column: $table.employeeOdooId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fonction =>
      $composableBuilder(column: $table.fonction, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateEmp =>
      $composableBuilder(column: $table.dateEmp, builder: (column) => column);

  GeneratedColumn<String> get dateDebut =>
      $composableBuilder(column: $table.dateDebut, builder: (column) => column);

  GeneratedColumn<String> get dateFin =>
      $composableBuilder(column: $table.dateFin, builder: (column) => column);

  GeneratedColumn<double> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get absent =>
      $composableBuilder(column: $table.absent, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeuilleEmployesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeuilleEmployesTable,
          FeuilleEmploye,
          $$FeuilleEmployesTableFilterComposer,
          $$FeuilleEmployesTableOrderingComposer,
          $$FeuilleEmployesTableAnnotationComposer,
          $$FeuilleEmployesTableCreateCompanionBuilder,
          $$FeuilleEmployesTableUpdateCompanionBuilder,
          (
            FeuilleEmploye,
            BaseReferences<
              _$AppDatabase,
              $FeuilleEmployesTable,
              FeuilleEmploye
            >,
          ),
          FeuilleEmploye,
          PrefetchHooks Function()
        > {
  $$FeuilleEmployesTableTableManager(
    _$AppDatabase db,
    $FeuilleEmployesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeuilleEmployesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeuilleEmployesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeuilleEmployesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> mobileUuid = const Value.absent(),
                Value<int?> odooId = const Value.absent(),
                Value<int> feuilleLocalId = const Value.absent(),
                Value<int> employeeOdooId = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String?> dateEmp = const Value.absent(),
                Value<String?> dateDebut = const Value.absent(),
                Value<String?> dateFin = const Value.absent(),
                Value<double?> difference = const Value.absent(),
                Value<bool> absent = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FeuilleEmployesCompanion(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                employeeOdooId: employeeOdooId,
                fonction: fonction,
                observation: observation,
                dateEmp: dateEmp,
                dateDebut: dateDebut,
                dateFin: dateFin,
                difference: difference,
                absent: absent,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String mobileUuid,
                Value<int?> odooId = const Value.absent(),
                required int feuilleLocalId,
                required int employeeOdooId,
                Value<String?> fonction = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String?> dateEmp = const Value.absent(),
                Value<String?> dateDebut = const Value.absent(),
                Value<String?> dateFin = const Value.absent(),
                Value<double?> difference = const Value.absent(),
                Value<bool> absent = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FeuilleEmployesCompanion.insert(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                employeeOdooId: employeeOdooId,
                fonction: fonction,
                observation: observation,
                dateEmp: dateEmp,
                dateDebut: dateDebut,
                dateFin: dateFin,
                difference: difference,
                absent: absent,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeuilleEmployesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeuilleEmployesTable,
      FeuilleEmploye,
      $$FeuilleEmployesTableFilterComposer,
      $$FeuilleEmployesTableOrderingComposer,
      $$FeuilleEmployesTableAnnotationComposer,
      $$FeuilleEmployesTableCreateCompanionBuilder,
      $$FeuilleEmployesTableUpdateCompanionBuilder,
      (
        FeuilleEmploye,
        BaseReferences<_$AppDatabase, $FeuilleEmployesTable, FeuilleEmploye>,
      ),
      FeuilleEmploye,
      PrefetchHooks Function()
    >;
typedef $$FeuilleMaterielsTableCreateCompanionBuilder =
    FeuilleMaterielsCompanion Function({
      Value<int> localId,
      required String mobileUuid,
      Value<int?> odooId,
      required int feuilleLocalId,
      Value<String?> description,
      Value<String?> serialNumber,
      Value<double?> quantity,
      Value<String?> observation,
      Value<String?> status,
      Value<String> syncStatus,
      Value<bool> isVisible,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FeuilleMaterielsTableUpdateCompanionBuilder =
    FeuilleMaterielsCompanion Function({
      Value<int> localId,
      Value<String> mobileUuid,
      Value<int?> odooId,
      Value<int> feuilleLocalId,
      Value<String?> description,
      Value<String?> serialNumber,
      Value<double?> quantity,
      Value<String?> observation,
      Value<String?> status,
      Value<String> syncStatus,
      Value<bool> isVisible,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FeuilleMaterielsTableFilterComposer
    extends Composer<_$AppDatabase, $FeuilleMaterielsTable> {
  $$FeuilleMaterielsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeuilleMaterielsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeuilleMaterielsTable> {
  $$FeuilleMaterielsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odooId => $composableBuilder(
    column: $table.odooId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeuilleMaterielsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeuilleMaterielsTable> {
  $$FeuilleMaterielsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get mobileUuid => $composableBuilder(
    column: $table.mobileUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odooId =>
      $composableBuilder(column: $table.odooId, builder: (column) => column);

  GeneratedColumn<int> get feuilleLocalId => $composableBuilder(
    column: $table.feuilleLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeuilleMaterielsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeuilleMaterielsTable,
          FeuilleMateriel,
          $$FeuilleMaterielsTableFilterComposer,
          $$FeuilleMaterielsTableOrderingComposer,
          $$FeuilleMaterielsTableAnnotationComposer,
          $$FeuilleMaterielsTableCreateCompanionBuilder,
          $$FeuilleMaterielsTableUpdateCompanionBuilder,
          (
            FeuilleMateriel,
            BaseReferences<
              _$AppDatabase,
              $FeuilleMaterielsTable,
              FeuilleMateriel
            >,
          ),
          FeuilleMateriel,
          PrefetchHooks Function()
        > {
  $$FeuilleMaterielsTableTableManager(
    _$AppDatabase db,
    $FeuilleMaterielsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeuilleMaterielsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeuilleMaterielsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeuilleMaterielsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String> mobileUuid = const Value.absent(),
                Value<int?> odooId = const Value.absent(),
                Value<int> feuilleLocalId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FeuilleMaterielsCompanion(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                description: description,
                serialNumber: serialNumber,
                quantity: quantity,
                observation: observation,
                status: status,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required String mobileUuid,
                Value<int?> odooId = const Value.absent(),
                required int feuilleLocalId,
                Value<String?> description = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FeuilleMaterielsCompanion.insert(
                localId: localId,
                mobileUuid: mobileUuid,
                odooId: odooId,
                feuilleLocalId: feuilleLocalId,
                description: description,
                serialNumber: serialNumber,
                quantity: quantity,
                observation: observation,
                status: status,
                syncStatus: syncStatus,
                isVisible: isVisible,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeuilleMaterielsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeuilleMaterielsTable,
      FeuilleMateriel,
      $$FeuilleMaterielsTableFilterComposer,
      $$FeuilleMaterielsTableOrderingComposer,
      $$FeuilleMaterielsTableAnnotationComposer,
      $$FeuilleMaterielsTableCreateCompanionBuilder,
      $$FeuilleMaterielsTableUpdateCompanionBuilder,
      (
        FeuilleMateriel,
        BaseReferences<_$AppDatabase, $FeuilleMaterielsTable, FeuilleMateriel>,
      ),
      FeuilleMateriel,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$EquipmentsTableTableManager get equipments =>
      $$EquipmentsTableTableManager(_db, _db.equipments);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$MaterialReferencesTableTableManager get materialReferences =>
      $$MaterialReferencesTableTableManager(_db, _db.materialReferences);
  $$FeuillesTableTableManager get feuilles =>
      $$FeuillesTableTableManager(_db, _db.feuilles);
  $$FeuilleLignesTableTableManager get feuilleLignes =>
      $$FeuilleLignesTableTableManager(_db, _db.feuilleLignes);
  $$FeuilleFuelsTableTableManager get feuilleFuels =>
      $$FeuilleFuelsTableTableManager(_db, _db.feuilleFuels);
  $$FeuilleEmployesTableTableManager get feuilleEmployes =>
      $$FeuilleEmployesTableTableManager(_db, _db.feuilleEmployes);
  $$FeuilleMaterielsTableTableManager get feuilleMateriels =>
      $$FeuilleMaterielsTableTableManager(_db, _db.feuilleMateriels);
}
