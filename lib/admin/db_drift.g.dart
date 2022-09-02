// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_drift.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  SettingsCompanion copyWith({Value<String>? key, Value<String>? value}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? 'settings';
  @override
  String get actualTableName => 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final String assetnum;
  final String description;
  final String status;
  final String siteid;
  final String changedate;
  final String hierarchy;
  final String? parent;
  const Asset(
      {required this.assetnum,
      required this.description,
      required this.status,
      required this.siteid,
      required this.changedate,
      required this.hierarchy,
      this.parent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assetnum'] = Variable<String>(assetnum);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['siteid'] = Variable<String>(siteid);
    map['changedate'] = Variable<String>(changedate);
    map['hierarchy'] = Variable<String>(hierarchy);
    if (!nullToAbsent || parent != null) {
      map['parent'] = Variable<String>(parent);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      assetnum: Value(assetnum),
      description: Value(description),
      status: Value(status),
      siteid: Value(siteid),
      changedate: Value(changedate),
      hierarchy: Value(hierarchy),
      parent:
          parent == null && nullToAbsent ? const Value.absent() : Value(parent),
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      assetnum: serializer.fromJson<String>(json['assetnum']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      siteid: serializer.fromJson<String>(json['siteid']),
      changedate: serializer.fromJson<String>(json['changedate']),
      hierarchy: serializer.fromJson<String>(json['hierarchy']),
      parent: serializer.fromJson<String?>(json['parent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetnum': serializer.toJson<String>(assetnum),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'siteid': serializer.toJson<String>(siteid),
      'changedate': serializer.toJson<String>(changedate),
      'hierarchy': serializer.toJson<String>(hierarchy),
      'parent': serializer.toJson<String?>(parent),
    };
  }

  Asset copyWith(
          {String? assetnum,
          String? description,
          String? status,
          String? siteid,
          String? changedate,
          String? hierarchy,
          Value<String?> parent = const Value.absent()}) =>
      Asset(
        assetnum: assetnum ?? this.assetnum,
        description: description ?? this.description,
        status: status ?? this.status,
        siteid: siteid ?? this.siteid,
        changedate: changedate ?? this.changedate,
        hierarchy: hierarchy ?? this.hierarchy,
        parent: parent.present ? parent.value : this.parent,
      );
  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('assetnum: $assetnum, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('siteid: $siteid, ')
          ..write('changedate: $changedate, ')
          ..write('hierarchy: $hierarchy, ')
          ..write('parent: $parent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      assetnum, description, status, siteid, changedate, hierarchy, parent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.assetnum == this.assetnum &&
          other.description == this.description &&
          other.status == this.status &&
          other.siteid == this.siteid &&
          other.changedate == this.changedate &&
          other.hierarchy == this.hierarchy &&
          other.parent == this.parent);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<String> assetnum;
  final Value<String> description;
  final Value<String> status;
  final Value<String> siteid;
  final Value<String> changedate;
  final Value<String> hierarchy;
  final Value<String?> parent;
  const AssetsCompanion({
    this.assetnum = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.siteid = const Value.absent(),
    this.changedate = const Value.absent(),
    this.hierarchy = const Value.absent(),
    this.parent = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String assetnum,
    required String description,
    required String status,
    required String siteid,
    required String changedate,
    required String hierarchy,
    this.parent = const Value.absent(),
  })  : assetnum = Value(assetnum),
        description = Value(description),
        status = Value(status),
        siteid = Value(siteid),
        changedate = Value(changedate),
        hierarchy = Value(hierarchy);
  static Insertable<Asset> custom({
    Expression<String>? assetnum,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? siteid,
    Expression<String>? changedate,
    Expression<String>? hierarchy,
    Expression<String>? parent,
  }) {
    return RawValuesInsertable({
      if (assetnum != null) 'assetnum': assetnum,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (siteid != null) 'siteid': siteid,
      if (changedate != null) 'changedate': changedate,
      if (hierarchy != null) 'hierarchy': hierarchy,
      if (parent != null) 'parent': parent,
    });
  }

  AssetsCompanion copyWith(
      {Value<String>? assetnum,
      Value<String>? description,
      Value<String>? status,
      Value<String>? siteid,
      Value<String>? changedate,
      Value<String>? hierarchy,
      Value<String?>? parent}) {
    return AssetsCompanion(
      assetnum: assetnum ?? this.assetnum,
      description: description ?? this.description,
      status: status ?? this.status,
      siteid: siteid ?? this.siteid,
      changedate: changedate ?? this.changedate,
      hierarchy: hierarchy ?? this.hierarchy,
      parent: parent ?? this.parent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetnum.present) {
      map['assetnum'] = Variable<String>(assetnum.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (siteid.present) {
      map['siteid'] = Variable<String>(siteid.value);
    }
    if (changedate.present) {
      map['changedate'] = Variable<String>(changedate.value);
    }
    if (hierarchy.present) {
      map['hierarchy'] = Variable<String>(hierarchy.value);
    }
    if (parent.present) {
      map['parent'] = Variable<String>(parent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('assetnum: $assetnum, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('siteid: $siteid, ')
          ..write('changedate: $changedate, ')
          ..write('hierarchy: $hierarchy, ')
          ..write('parent: $parent')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _assetnumMeta = const VerificationMeta('assetnum');
  @override
  late final GeneratedColumn<String> assetnum = GeneratedColumn<String>(
      'assetnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _changedateMeta = const VerificationMeta('changedate');
  @override
  late final GeneratedColumn<String> changedate = GeneratedColumn<String>(
      'changedate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _hierarchyMeta = const VerificationMeta('hierarchy');
  @override
  late final GeneratedColumn<String> hierarchy = GeneratedColumn<String>(
      'hierarchy', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _parentMeta = const VerificationMeta('parent');
  @override
  late final GeneratedColumn<String> parent = GeneratedColumn<String>(
      'parent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [assetnum, description, status, siteid, changedate, hierarchy, parent];
  @override
  String get aliasedName => _alias ?? 'assets';
  @override
  String get actualTableName => 'assets';
  @override
  VerificationContext validateIntegrity(Insertable<Asset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assetnum')) {
      context.handle(_assetnumMeta,
          assetnum.isAcceptableOrUnknown(data['assetnum']!, _assetnumMeta));
    } else if (isInserting) {
      context.missing(_assetnumMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('siteid')) {
      context.handle(_siteidMeta,
          siteid.isAcceptableOrUnknown(data['siteid']!, _siteidMeta));
    } else if (isInserting) {
      context.missing(_siteidMeta);
    }
    if (data.containsKey('changedate')) {
      context.handle(
          _changedateMeta,
          changedate.isAcceptableOrUnknown(
              data['changedate']!, _changedateMeta));
    } else if (isInserting) {
      context.missing(_changedateMeta);
    }
    if (data.containsKey('hierarchy')) {
      context.handle(_hierarchyMeta,
          hierarchy.isAcceptableOrUnknown(data['hierarchy']!, _hierarchyMeta));
    } else if (isInserting) {
      context.missing(_hierarchyMeta);
    }
    if (data.containsKey('parent')) {
      context.handle(_parentMeta,
          parent.isAcceptableOrUnknown(data['parent']!, _parentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {siteid, assetnum};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      assetnum: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}assetnum'])!,
      description: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      siteid: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      changedate: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}changedate'])!,
      hierarchy: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}hierarchy'])!,
      parent: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}parent']),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class MeterDB extends DataClass implements Insertable<MeterDB> {
  final String meter;
  final String inspect;
  final String description;
  final int frequency;
  final String freqUnit;
  final String condition;
  final String craft;
  const MeterDB(
      {required this.meter,
      required this.inspect,
      required this.description,
      required this.frequency,
      required this.freqUnit,
      required this.condition,
      required this.craft});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meter'] = Variable<String>(meter);
    map['inspect'] = Variable<String>(inspect);
    map['description'] = Variable<String>(description);
    map['frequency'] = Variable<int>(frequency);
    map['freq_unit'] = Variable<String>(freqUnit);
    map['condition'] = Variable<String>(condition);
    map['craft'] = Variable<String>(craft);
    return map;
  }

  MeterDBsCompanion toCompanion(bool nullToAbsent) {
    return MeterDBsCompanion(
      meter: Value(meter),
      inspect: Value(inspect),
      description: Value(description),
      frequency: Value(frequency),
      freqUnit: Value(freqUnit),
      condition: Value(condition),
      craft: Value(craft),
    );
  }

  factory MeterDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeterDB(
      meter: serializer.fromJson<String>(json['meter']),
      inspect: serializer.fromJson<String>(json['inspect']),
      description: serializer.fromJson<String>(json['description']),
      frequency: serializer.fromJson<int>(json['frequency']),
      freqUnit: serializer.fromJson<String>(json['freqUnit']),
      condition: serializer.fromJson<String>(json['condition']),
      craft: serializer.fromJson<String>(json['craft']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meter': serializer.toJson<String>(meter),
      'inspect': serializer.toJson<String>(inspect),
      'description': serializer.toJson<String>(description),
      'frequency': serializer.toJson<int>(frequency),
      'freqUnit': serializer.toJson<String>(freqUnit),
      'condition': serializer.toJson<String>(condition),
      'craft': serializer.toJson<String>(craft),
    };
  }

  MeterDB copyWith(
          {String? meter,
          String? inspect,
          String? description,
          int? frequency,
          String? freqUnit,
          String? condition,
          String? craft}) =>
      MeterDB(
        meter: meter ?? this.meter,
        inspect: inspect ?? this.inspect,
        description: description ?? this.description,
        frequency: frequency ?? this.frequency,
        freqUnit: freqUnit ?? this.freqUnit,
        condition: condition ?? this.condition,
        craft: craft ?? this.craft,
      );
  @override
  String toString() {
    return (StringBuffer('MeterDB(')
          ..write('meter: $meter, ')
          ..write('inspect: $inspect, ')
          ..write('description: $description, ')
          ..write('frequency: $frequency, ')
          ..write('freqUnit: $freqUnit, ')
          ..write('condition: $condition, ')
          ..write('craft: $craft')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      meter, inspect, description, frequency, freqUnit, condition, craft);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeterDB &&
          other.meter == this.meter &&
          other.inspect == this.inspect &&
          other.description == this.description &&
          other.frequency == this.frequency &&
          other.freqUnit == this.freqUnit &&
          other.condition == this.condition &&
          other.craft == this.craft);
}

class MeterDBsCompanion extends UpdateCompanion<MeterDB> {
  final Value<String> meter;
  final Value<String> inspect;
  final Value<String> description;
  final Value<int> frequency;
  final Value<String> freqUnit;
  final Value<String> condition;
  final Value<String> craft;
  const MeterDBsCompanion({
    this.meter = const Value.absent(),
    this.inspect = const Value.absent(),
    this.description = const Value.absent(),
    this.frequency = const Value.absent(),
    this.freqUnit = const Value.absent(),
    this.condition = const Value.absent(),
    this.craft = const Value.absent(),
  });
  MeterDBsCompanion.insert({
    required String meter,
    required String inspect,
    required String description,
    required int frequency,
    required String freqUnit,
    required String condition,
    required String craft,
  })  : meter = Value(meter),
        inspect = Value(inspect),
        description = Value(description),
        frequency = Value(frequency),
        freqUnit = Value(freqUnit),
        condition = Value(condition),
        craft = Value(craft);
  static Insertable<MeterDB> custom({
    Expression<String>? meter,
    Expression<String>? inspect,
    Expression<String>? description,
    Expression<int>? frequency,
    Expression<String>? freqUnit,
    Expression<String>? condition,
    Expression<String>? craft,
  }) {
    return RawValuesInsertable({
      if (meter != null) 'meter': meter,
      if (inspect != null) 'inspect': inspect,
      if (description != null) 'description': description,
      if (frequency != null) 'frequency': frequency,
      if (freqUnit != null) 'freq_unit': freqUnit,
      if (condition != null) 'condition': condition,
      if (craft != null) 'craft': craft,
    });
  }

  MeterDBsCompanion copyWith(
      {Value<String>? meter,
      Value<String>? inspect,
      Value<String>? description,
      Value<int>? frequency,
      Value<String>? freqUnit,
      Value<String>? condition,
      Value<String>? craft}) {
    return MeterDBsCompanion(
      meter: meter ?? this.meter,
      inspect: inspect ?? this.inspect,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      freqUnit: freqUnit ?? this.freqUnit,
      condition: condition ?? this.condition,
      craft: craft ?? this.craft,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meter.present) {
      map['meter'] = Variable<String>(meter.value);
    }
    if (inspect.present) {
      map['inspect'] = Variable<String>(inspect.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (freqUnit.present) {
      map['freq_unit'] = Variable<String>(freqUnit.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (craft.present) {
      map['craft'] = Variable<String>(craft.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeterDBsCompanion(')
          ..write('meter: $meter, ')
          ..write('inspect: $inspect, ')
          ..write('description: $description, ')
          ..write('frequency: $frequency, ')
          ..write('freqUnit: $freqUnit, ')
          ..write('condition: $condition, ')
          ..write('craft: $craft')
          ..write(')'))
        .toString();
  }
}

class $MeterDBsTable extends MeterDBs with TableInfo<$MeterDBsTable, MeterDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeterDBsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _meterMeta = const VerificationMeta('meter');
  @override
  late final GeneratedColumn<String> meter = GeneratedColumn<String>(
      'meter', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _inspectMeta = const VerificationMeta('inspect');
  @override
  late final GeneratedColumn<String> inspect = GeneratedColumn<String>(
      'inspect', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _frequencyMeta = const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  final VerificationMeta _freqUnitMeta = const VerificationMeta('freqUnit');
  @override
  late final GeneratedColumn<String> freqUnit = GeneratedColumn<String>(
      'freq_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _conditionMeta = const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _craftMeta = const VerificationMeta('craft');
  @override
  late final GeneratedColumn<String> craft = GeneratedColumn<String>(
      'craft', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [meter, inspect, description, frequency, freqUnit, condition, craft];
  @override
  String get aliasedName => _alias ?? 'meter_d_bs';
  @override
  String get actualTableName => 'meter_d_bs';
  @override
  VerificationContext validateIntegrity(Insertable<MeterDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meter')) {
      context.handle(
          _meterMeta, meter.isAcceptableOrUnknown(data['meter']!, _meterMeta));
    } else if (isInserting) {
      context.missing(_meterMeta);
    }
    if (data.containsKey('inspect')) {
      context.handle(_inspectMeta,
          inspect.isAcceptableOrUnknown(data['inspect']!, _inspectMeta));
    } else if (isInserting) {
      context.missing(_inspectMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('freq_unit')) {
      context.handle(_freqUnitMeta,
          freqUnit.isAcceptableOrUnknown(data['freq_unit']!, _freqUnitMeta));
    } else if (isInserting) {
      context.missing(_freqUnitMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    } else if (isInserting) {
      context.missing(_conditionMeta);
    }
    if (data.containsKey('craft')) {
      context.handle(
          _craftMeta, craft.isAcceptableOrUnknown(data['craft']!, _craftMeta));
    } else if (isInserting) {
      context.missing(_craftMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {meter};
  @override
  MeterDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeterDB(
      meter: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}meter'])!,
      inspect: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}inspect'])!,
      description: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      frequency: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      freqUnit: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}freq_unit'])!,
      condition: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])!,
      craft: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}craft'])!,
    );
  }

  @override
  $MeterDBsTable createAlias(String alias) {
    return $MeterDBsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final String meter;
  final String code;
  final String description;
  final String? action;
  const Observation(
      {required this.meter,
      required this.code,
      required this.description,
      this.action});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meter'] = Variable<String>(meter);
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || action != null) {
      map['action'] = Variable<String>(action);
    }
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      meter: Value(meter),
      code: Value(code),
      description: Value(description),
      action:
          action == null && nullToAbsent ? const Value.absent() : Value(action),
    );
  }

  factory Observation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      meter: serializer.fromJson<String>(json['meter']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
      action: serializer.fromJson<String?>(json['action']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meter': serializer.toJson<String>(meter),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
      'action': serializer.toJson<String?>(action),
    };
  }

  Observation copyWith(
          {String? meter,
          String? code,
          String? description,
          Value<String?> action = const Value.absent()}) =>
      Observation(
        meter: meter ?? this.meter,
        code: code ?? this.code,
        description: description ?? this.description,
        action: action.present ? action.value : this.action,
      );
  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('meter: $meter, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('action: $action')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(meter, code, description, action);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.meter == this.meter &&
          other.code == this.code &&
          other.description == this.description &&
          other.action == this.action);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> meter;
  final Value<String> code;
  final Value<String> description;
  final Value<String?> action;
  const ObservationsCompanion({
    this.meter = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.action = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String meter,
    required String code,
    required String description,
    this.action = const Value.absent(),
  })  : meter = Value(meter),
        code = Value(code),
        description = Value(description);
  static Insertable<Observation> custom({
    Expression<String>? meter,
    Expression<String>? code,
    Expression<String>? description,
    Expression<String>? action,
  }) {
    return RawValuesInsertable({
      if (meter != null) 'meter': meter,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (action != null) 'action': action,
    });
  }

  ObservationsCompanion copyWith(
      {Value<String>? meter,
      Value<String>? code,
      Value<String>? description,
      Value<String?>? action}) {
    return ObservationsCompanion(
      meter: meter ?? this.meter,
      code: code ?? this.code,
      description: description ?? this.description,
      action: action ?? this.action,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meter.present) {
      map['meter'] = Variable<String>(meter.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('meter: $meter, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('action: $action')
          ..write(')'))
        .toString();
  }
}

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _meterMeta = const VerificationMeta('meter');
  @override
  late final GeneratedColumn<String> meter = GeneratedColumn<String>(
      'meter', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [meter, code, description, action];
  @override
  String get aliasedName => _alias ?? 'observations';
  @override
  String get actualTableName => 'observations';
  @override
  VerificationContext validateIntegrity(Insertable<Observation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meter')) {
      context.handle(
          _meterMeta, meter.isAcceptableOrUnknown(data['meter']!, _meterMeta));
    } else if (isInserting) {
      context.missing(_meterMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {meter, code};
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      meter: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}meter'])!,
      code: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      description: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      action: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}action']),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $MeterDBsTable meterDBs = $MeterDBsTable(this);
  late final $ObservationsTable observations = $ObservationsTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [settings, assets, meterDBs, observations];
}
