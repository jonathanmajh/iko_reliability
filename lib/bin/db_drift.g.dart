// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_drift.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
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
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

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
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoginSettingsTable extends LoginSettings
    with TableInfo<$LoginSettingsTable, LoginSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoginSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'login_settings';
  @override
  VerificationContext validateIntegrity(Insertable<LoginSetting> instance,
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
  LoginSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoginSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $LoginSettingsTable createAlias(String alias) {
    return $LoginSettingsTable(attachedDatabase, alias);
  }
}

class LoginSetting extends DataClass implements Insertable<LoginSetting> {
  final String key;
  final String value;
  const LoginSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LoginSettingsCompanion toCompanion(bool nullToAbsent) {
    return LoginSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory LoginSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoginSetting(
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

  LoginSetting copyWith({String? key, String? value}) => LoginSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('LoginSetting(')
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
      (other is LoginSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class LoginSettingsCompanion extends UpdateCompanion<LoginSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LoginSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoginSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<LoginSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoginSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return LoginSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoginSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeterDBsTable extends MeterDBs with TableInfo<$MeterDBsTable, MeterDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeterDBsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _meterMeta = const VerificationMeta('meter');
  @override
  late final GeneratedColumn<String> meter = GeneratedColumn<String>(
      'meter', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inspectMeta =
      const VerificationMeta('inspect');
  @override
  late final GeneratedColumn<String> inspect = GeneratedColumn<String>(
      'inspect', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _freqUnitMeta =
      const VerificationMeta('freqUnit');
  @override
  late final GeneratedColumn<String> freqUnit = GeneratedColumn<String>(
      'freq_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _craftMeta = const VerificationMeta('craft');
  @override
  late final GeneratedColumn<String> craft = GeneratedColumn<String>(
      'craft', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [meter, inspect, description, frequency, freqUnit, condition, craft];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meter_d_bs';
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
      meter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter'])!,
      inspect: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}inspect'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      freqUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}freq_unit'])!,
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])!,
      craft: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}craft'])!,
    );
  }

  @override
  $MeterDBsTable createAlias(String alias) {
    return $MeterDBsTable(attachedDatabase, alias);
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
  final Value<int> rowid;
  const MeterDBsCompanion({
    this.meter = const Value.absent(),
    this.inspect = const Value.absent(),
    this.description = const Value.absent(),
    this.frequency = const Value.absent(),
    this.freqUnit = const Value.absent(),
    this.condition = const Value.absent(),
    this.craft = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeterDBsCompanion.insert({
    required String meter,
    required String inspect,
    required String description,
    required int frequency,
    required String freqUnit,
    required String condition,
    required String craft,
    this.rowid = const Value.absent(),
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (meter != null) 'meter': meter,
      if (inspect != null) 'inspect': inspect,
      if (description != null) 'description': description,
      if (frequency != null) 'frequency': frequency,
      if (freqUnit != null) 'freq_unit': freqUnit,
      if (condition != null) 'condition': condition,
      if (craft != null) 'craft': craft,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeterDBsCompanion copyWith(
      {Value<String>? meter,
      Value<String>? inspect,
      Value<String>? description,
      Value<int>? frequency,
      Value<String>? freqUnit,
      Value<String>? condition,
      Value<String>? craft,
      Value<int>? rowid}) {
    return MeterDBsCompanion(
      meter: meter ?? this.meter,
      inspect: inspect ?? this.inspect,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      freqUnit: freqUnit ?? this.freqUnit,
      condition: condition ?? this.condition,
      craft: craft ?? this.craft,
      rowid: rowid ?? this.rowid,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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
          ..write('craft: $craft, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _meterMeta = const VerificationMeta('meter');
  @override
  late final GeneratedColumn<String> meter = GeneratedColumn<String>(
      'meter', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [meter, code, description, action];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
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
      meter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action']),
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
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
  final Value<int> rowid;
  const ObservationsCompanion({
    this.meter = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.action = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String meter,
    required String code,
    required String description,
    this.action = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : meter = Value(meter),
        code = Value(code),
        description = Value(description);
  static Insertable<Observation> custom({
    Expression<String>? meter,
    Expression<String>? code,
    Expression<String>? description,
    Expression<String>? action,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (meter != null) 'meter': meter,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (action != null) 'action': action,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith(
      {Value<String>? meter,
      Value<String>? code,
      Value<String>? description,
      Value<String?>? action,
      Value<int>? rowid}) {
    return ObservationsCompanion(
      meter: meter ?? this.meter,
      code: code ?? this.code,
      description: description ?? this.description,
      action: action ?? this.action,
      rowid: rowid ?? this.rowid,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservationsCompanion(')
          ..write('meter: $meter, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('action: $action, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetnumMeta =
      const VerificationMeta('assetnum');
  @override
  late final GeneratedColumn<String> assetnum = GeneratedColumn<String>(
      'assetnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changedateMeta =
      const VerificationMeta('changedate');
  @override
  late final GeneratedColumn<String> changedate = GeneratedColumn<String>(
      'changedate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hierarchyMeta =
      const VerificationMeta('hierarchy');
  @override
  late final GeneratedColumn<String> hierarchy = GeneratedColumn<String>(
      'hierarchy', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentMeta = const VerificationMeta('parent');
  @override
  late final GeneratedColumn<String> parent = GeneratedColumn<String>(
      'parent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _newAssetMeta =
      const VerificationMeta('newAsset');
  @override
  late final GeneratedColumn<int> newAsset = GeneratedColumn<int>(
      'new_asset', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        assetnum,
        description,
        status,
        siteid,
        changedate,
        hierarchy,
        parent,
        priority,
        id,
        newAsset
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
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
    }
    if (data.containsKey('parent')) {
      context.handle(_parentMeta,
          parent.isAcceptableOrUnknown(data['parent']!, _parentMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('new_asset')) {
      context.handle(_newAssetMeta,
          newAsset.isAcceptableOrUnknown(data['new_asset']!, _newAssetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {siteid, assetnum},
      ];
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      assetnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assetnum'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      changedate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changedate'])!,
      hierarchy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hierarchy']),
      parent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      newAsset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_asset'])!,
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final String assetnum;
  final String description;
  final String status;
  final String siteid;
  final String changedate;
  final String? hierarchy;
  final String? parent;
  final int priority;
  final String id;
  final int newAsset;
  const Asset(
      {required this.assetnum,
      required this.description,
      required this.status,
      required this.siteid,
      required this.changedate,
      this.hierarchy,
      this.parent,
      required this.priority,
      required this.id,
      required this.newAsset});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assetnum'] = Variable<String>(assetnum);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['siteid'] = Variable<String>(siteid);
    map['changedate'] = Variable<String>(changedate);
    if (!nullToAbsent || hierarchy != null) {
      map['hierarchy'] = Variable<String>(hierarchy);
    }
    if (!nullToAbsent || parent != null) {
      map['parent'] = Variable<String>(parent);
    }
    map['priority'] = Variable<int>(priority);
    map['id'] = Variable<String>(id);
    map['new_asset'] = Variable<int>(newAsset);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      assetnum: Value(assetnum),
      description: Value(description),
      status: Value(status),
      siteid: Value(siteid),
      changedate: Value(changedate),
      hierarchy: hierarchy == null && nullToAbsent
          ? const Value.absent()
          : Value(hierarchy),
      parent:
          parent == null && nullToAbsent ? const Value.absent() : Value(parent),
      priority: Value(priority),
      id: Value(id),
      newAsset: Value(newAsset),
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
      hierarchy: serializer.fromJson<String?>(json['hierarchy']),
      parent: serializer.fromJson<String?>(json['parent']),
      priority: serializer.fromJson<int>(json['priority']),
      id: serializer.fromJson<String>(json['id']),
      newAsset: serializer.fromJson<int>(json['newAsset']),
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
      'hierarchy': serializer.toJson<String?>(hierarchy),
      'parent': serializer.toJson<String?>(parent),
      'priority': serializer.toJson<int>(priority),
      'id': serializer.toJson<String>(id),
      'newAsset': serializer.toJson<int>(newAsset),
    };
  }

  Asset copyWith(
          {String? assetnum,
          String? description,
          String? status,
          String? siteid,
          String? changedate,
          Value<String?> hierarchy = const Value.absent(),
          Value<String?> parent = const Value.absent(),
          int? priority,
          String? id,
          int? newAsset}) =>
      Asset(
        assetnum: assetnum ?? this.assetnum,
        description: description ?? this.description,
        status: status ?? this.status,
        siteid: siteid ?? this.siteid,
        changedate: changedate ?? this.changedate,
        hierarchy: hierarchy.present ? hierarchy.value : this.hierarchy,
        parent: parent.present ? parent.value : this.parent,
        priority: priority ?? this.priority,
        id: id ?? this.id,
        newAsset: newAsset ?? this.newAsset,
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
          ..write('parent: $parent, ')
          ..write('priority: $priority, ')
          ..write('id: $id, ')
          ..write('newAsset: $newAsset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetnum, description, status, siteid,
      changedate, hierarchy, parent, priority, id, newAsset);
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
          other.parent == this.parent &&
          other.priority == this.priority &&
          other.id == this.id &&
          other.newAsset == this.newAsset);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<String> assetnum;
  final Value<String> description;
  final Value<String> status;
  final Value<String> siteid;
  final Value<String> changedate;
  final Value<String?> hierarchy;
  final Value<String?> parent;
  final Value<int> priority;
  final Value<String> id;
  final Value<int> newAsset;
  final Value<int> rowid;
  const AssetsCompanion({
    this.assetnum = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.siteid = const Value.absent(),
    this.changedate = const Value.absent(),
    this.hierarchy = const Value.absent(),
    this.parent = const Value.absent(),
    this.priority = const Value.absent(),
    this.id = const Value.absent(),
    this.newAsset = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String assetnum,
    required String description,
    required String status,
    required String siteid,
    required String changedate,
    this.hierarchy = const Value.absent(),
    this.parent = const Value.absent(),
    required int priority,
    required String id,
    this.newAsset = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : assetnum = Value(assetnum),
        description = Value(description),
        status = Value(status),
        siteid = Value(siteid),
        changedate = Value(changedate),
        priority = Value(priority),
        id = Value(id);
  static Insertable<Asset> custom({
    Expression<String>? assetnum,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? siteid,
    Expression<String>? changedate,
    Expression<String>? hierarchy,
    Expression<String>? parent,
    Expression<int>? priority,
    Expression<String>? id,
    Expression<int>? newAsset,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetnum != null) 'assetnum': assetnum,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (siteid != null) 'siteid': siteid,
      if (changedate != null) 'changedate': changedate,
      if (hierarchy != null) 'hierarchy': hierarchy,
      if (parent != null) 'parent': parent,
      if (priority != null) 'priority': priority,
      if (id != null) 'id': id,
      if (newAsset != null) 'new_asset': newAsset,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith(
      {Value<String>? assetnum,
      Value<String>? description,
      Value<String>? status,
      Value<String>? siteid,
      Value<String>? changedate,
      Value<String?>? hierarchy,
      Value<String?>? parent,
      Value<int>? priority,
      Value<String>? id,
      Value<int>? newAsset,
      Value<int>? rowid}) {
    return AssetsCompanion(
      assetnum: assetnum ?? this.assetnum,
      description: description ?? this.description,
      status: status ?? this.status,
      siteid: siteid ?? this.siteid,
      changedate: changedate ?? this.changedate,
      hierarchy: hierarchy ?? this.hierarchy,
      parent: parent ?? this.parent,
      priority: priority ?? this.priority,
      id: id ?? this.id,
      newAsset: newAsset ?? this.newAsset,
      rowid: rowid ?? this.rowid,
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
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (newAsset.present) {
      map['new_asset'] = Variable<int>(newAsset.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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
          ..write('parent: $parent, ')
          ..write('priority: $priority, ')
          ..write('id: $id, ')
          ..write('newAsset: $newAsset, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkordersTable extends Workorders
    with TableInfo<$WorkordersTable, Workorder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkordersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wonumMeta = const VerificationMeta('wonum');
  @override
  late final GeneratedColumn<String> wonum = GeneratedColumn<String>(
      'wonum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reportdateMeta =
      const VerificationMeta('reportdate');
  @override
  late final GeneratedColumn<String> reportdate = GeneratedColumn<String>(
      'reportdate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downtimeMeta =
      const VerificationMeta('downtime');
  @override
  late final GeneratedColumn<double> downtime = GeneratedColumn<double>(
      'downtime', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetnumMeta =
      const VerificationMeta('assetnum');
  @override
  late final GeneratedColumn<String> assetnum = GeneratedColumn<String>(
      'assetnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordTypeMeta =
      const VerificationMeta('recordType');
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
      'record_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        wonum,
        description,
        status,
        siteid,
        reportdate,
        downtime,
        type,
        assetnum,
        details,
        recordType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workorders';
  @override
  VerificationContext validateIntegrity(Insertable<Workorder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wonum')) {
      context.handle(
          _wonumMeta, wonum.isAcceptableOrUnknown(data['wonum']!, _wonumMeta));
    } else if (isInserting) {
      context.missing(_wonumMeta);
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
    if (data.containsKey('reportdate')) {
      context.handle(
          _reportdateMeta,
          reportdate.isAcceptableOrUnknown(
              data['reportdate']!, _reportdateMeta));
    } else if (isInserting) {
      context.missing(_reportdateMeta);
    }
    if (data.containsKey('downtime')) {
      context.handle(_downtimeMeta,
          downtime.isAcceptableOrUnknown(data['downtime']!, _downtimeMeta));
    } else if (isInserting) {
      context.missing(_downtimeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('assetnum')) {
      context.handle(_assetnumMeta,
          assetnum.isAcceptableOrUnknown(data['assetnum']!, _assetnumMeta));
    } else if (isInserting) {
      context.missing(_assetnumMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    if (data.containsKey('record_type')) {
      context.handle(
          _recordTypeMeta,
          recordType.isAcceptableOrUnknown(
              data['record_type']!, _recordTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {siteid, wonum};
  @override
  Workorder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workorder(
      wonum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wonum'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      reportdate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reportdate'])!,
      downtime: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}downtime'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      assetnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assetnum'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
      recordType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_type']),
    );
  }

  @override
  $WorkordersTable createAlias(String alias) {
    return $WorkordersTable(attachedDatabase, alias);
  }
}

class Workorder extends DataClass implements Insertable<Workorder> {
  final String wonum;
  final String description;
  final String status;
  final String siteid;
  final String reportdate;
  final double downtime;
  final String type;
  final String assetnum;
  final String? details;
  final String? recordType;
  const Workorder(
      {required this.wonum,
      required this.description,
      required this.status,
      required this.siteid,
      required this.reportdate,
      required this.downtime,
      required this.type,
      required this.assetnum,
      this.details,
      this.recordType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wonum'] = Variable<String>(wonum);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['siteid'] = Variable<String>(siteid);
    map['reportdate'] = Variable<String>(reportdate);
    map['downtime'] = Variable<double>(downtime);
    map['type'] = Variable<String>(type);
    map['assetnum'] = Variable<String>(assetnum);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || recordType != null) {
      map['record_type'] = Variable<String>(recordType);
    }
    return map;
  }

  WorkordersCompanion toCompanion(bool nullToAbsent) {
    return WorkordersCompanion(
      wonum: Value(wonum),
      description: Value(description),
      status: Value(status),
      siteid: Value(siteid),
      reportdate: Value(reportdate),
      downtime: Value(downtime),
      type: Value(type),
      assetnum: Value(assetnum),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      recordType: recordType == null && nullToAbsent
          ? const Value.absent()
          : Value(recordType),
    );
  }

  factory Workorder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workorder(
      wonum: serializer.fromJson<String>(json['wonum']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      siteid: serializer.fromJson<String>(json['siteid']),
      reportdate: serializer.fromJson<String>(json['reportdate']),
      downtime: serializer.fromJson<double>(json['downtime']),
      type: serializer.fromJson<String>(json['type']),
      assetnum: serializer.fromJson<String>(json['assetnum']),
      details: serializer.fromJson<String?>(json['details']),
      recordType: serializer.fromJson<String?>(json['recordType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wonum': serializer.toJson<String>(wonum),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'siteid': serializer.toJson<String>(siteid),
      'reportdate': serializer.toJson<String>(reportdate),
      'downtime': serializer.toJson<double>(downtime),
      'type': serializer.toJson<String>(type),
      'assetnum': serializer.toJson<String>(assetnum),
      'details': serializer.toJson<String?>(details),
      'recordType': serializer.toJson<String?>(recordType),
    };
  }

  Workorder copyWith(
          {String? wonum,
          String? description,
          String? status,
          String? siteid,
          String? reportdate,
          double? downtime,
          String? type,
          String? assetnum,
          Value<String?> details = const Value.absent(),
          Value<String?> recordType = const Value.absent()}) =>
      Workorder(
        wonum: wonum ?? this.wonum,
        description: description ?? this.description,
        status: status ?? this.status,
        siteid: siteid ?? this.siteid,
        reportdate: reportdate ?? this.reportdate,
        downtime: downtime ?? this.downtime,
        type: type ?? this.type,
        assetnum: assetnum ?? this.assetnum,
        details: details.present ? details.value : this.details,
        recordType: recordType.present ? recordType.value : this.recordType,
      );
  @override
  String toString() {
    return (StringBuffer('Workorder(')
          ..write('wonum: $wonum, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('siteid: $siteid, ')
          ..write('reportdate: $reportdate, ')
          ..write('downtime: $downtime, ')
          ..write('type: $type, ')
          ..write('assetnum: $assetnum, ')
          ..write('details: $details, ')
          ..write('recordType: $recordType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wonum, description, status, siteid,
      reportdate, downtime, type, assetnum, details, recordType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workorder &&
          other.wonum == this.wonum &&
          other.description == this.description &&
          other.status == this.status &&
          other.siteid == this.siteid &&
          other.reportdate == this.reportdate &&
          other.downtime == this.downtime &&
          other.type == this.type &&
          other.assetnum == this.assetnum &&
          other.details == this.details &&
          other.recordType == this.recordType);
}

class WorkordersCompanion extends UpdateCompanion<Workorder> {
  final Value<String> wonum;
  final Value<String> description;
  final Value<String> status;
  final Value<String> siteid;
  final Value<String> reportdate;
  final Value<double> downtime;
  final Value<String> type;
  final Value<String> assetnum;
  final Value<String?> details;
  final Value<String?> recordType;
  final Value<int> rowid;
  const WorkordersCompanion({
    this.wonum = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.siteid = const Value.absent(),
    this.reportdate = const Value.absent(),
    this.downtime = const Value.absent(),
    this.type = const Value.absent(),
    this.assetnum = const Value.absent(),
    this.details = const Value.absent(),
    this.recordType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkordersCompanion.insert({
    required String wonum,
    required String description,
    required String status,
    required String siteid,
    required String reportdate,
    required double downtime,
    required String type,
    required String assetnum,
    this.details = const Value.absent(),
    this.recordType = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : wonum = Value(wonum),
        description = Value(description),
        status = Value(status),
        siteid = Value(siteid),
        reportdate = Value(reportdate),
        downtime = Value(downtime),
        type = Value(type),
        assetnum = Value(assetnum);
  static Insertable<Workorder> custom({
    Expression<String>? wonum,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? siteid,
    Expression<String>? reportdate,
    Expression<double>? downtime,
    Expression<String>? type,
    Expression<String>? assetnum,
    Expression<String>? details,
    Expression<String>? recordType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wonum != null) 'wonum': wonum,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (siteid != null) 'siteid': siteid,
      if (reportdate != null) 'reportdate': reportdate,
      if (downtime != null) 'downtime': downtime,
      if (type != null) 'type': type,
      if (assetnum != null) 'assetnum': assetnum,
      if (details != null) 'details': details,
      if (recordType != null) 'record_type': recordType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkordersCompanion copyWith(
      {Value<String>? wonum,
      Value<String>? description,
      Value<String>? status,
      Value<String>? siteid,
      Value<String>? reportdate,
      Value<double>? downtime,
      Value<String>? type,
      Value<String>? assetnum,
      Value<String?>? details,
      Value<String?>? recordType,
      Value<int>? rowid}) {
    return WorkordersCompanion(
      wonum: wonum ?? this.wonum,
      description: description ?? this.description,
      status: status ?? this.status,
      siteid: siteid ?? this.siteid,
      reportdate: reportdate ?? this.reportdate,
      downtime: downtime ?? this.downtime,
      type: type ?? this.type,
      assetnum: assetnum ?? this.assetnum,
      details: details ?? this.details,
      recordType: recordType ?? this.recordType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wonum.present) {
      map['wonum'] = Variable<String>(wonum.value);
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
    if (reportdate.present) {
      map['reportdate'] = Variable<String>(reportdate.value);
    }
    if (downtime.present) {
      map['downtime'] = Variable<double>(downtime.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (assetnum.present) {
      map['assetnum'] = Variable<String>(assetnum.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkordersCompanion(')
          ..write('wonum: $wonum, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('siteid: $siteid, ')
          ..write('reportdate: $reportdate, ')
          ..write('downtime: $downtime, ')
          ..write('type: $type, ')
          ..write('assetnum: $assetnum, ')
          ..write('details: $details, ')
          ..write('recordType: $recordType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SystemCriticalitysTable extends SystemCriticalitys
    with TableInfo<$SystemCriticalitysTable, SystemCriticality> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SystemCriticalitysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _safetyMeta = const VerificationMeta('safety');
  @override
  late final GeneratedColumn<int> safety = GeneratedColumn<int>(
      'safety', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _regulatoryMeta =
      const VerificationMeta('regulatory');
  @override
  late final GeneratedColumn<int> regulatory = GeneratedColumn<int>(
      'regulatory', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _economicMeta =
      const VerificationMeta('economic');
  @override
  late final GeneratedColumn<int> economic = GeneratedColumn<int>(
      'economic', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _throughputMeta =
      const VerificationMeta('throughput');
  @override
  late final GeneratedColumn<int> throughput = GeneratedColumn<int>(
      'throughput', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
      'quality', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lineMeta = const VerificationMeta('line');
  @override
  late final GeneratedColumn<String> line = GeneratedColumn<String>(
      'line', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        description,
        siteid,
        safety,
        regulatory,
        economic,
        throughput,
        quality,
        line,
        score
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'system_criticalitys';
  @override
  VerificationContext validateIntegrity(Insertable<SystemCriticality> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('siteid')) {
      context.handle(_siteidMeta,
          siteid.isAcceptableOrUnknown(data['siteid']!, _siteidMeta));
    }
    if (data.containsKey('safety')) {
      context.handle(_safetyMeta,
          safety.isAcceptableOrUnknown(data['safety']!, _safetyMeta));
    }
    if (data.containsKey('regulatory')) {
      context.handle(
          _regulatoryMeta,
          regulatory.isAcceptableOrUnknown(
              data['regulatory']!, _regulatoryMeta));
    }
    if (data.containsKey('economic')) {
      context.handle(_economicMeta,
          economic.isAcceptableOrUnknown(data['economic']!, _economicMeta));
    }
    if (data.containsKey('throughput')) {
      context.handle(
          _throughputMeta,
          throughput.isAcceptableOrUnknown(
              data['throughput']!, _throughputMeta));
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    }
    if (data.containsKey('line')) {
      context.handle(
          _lineMeta, line.isAcceptableOrUnknown(data['line']!, _lineMeta));
    } else if (isInserting) {
      context.missing(_lineMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SystemCriticality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SystemCriticality(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid']),
      safety: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}safety'])!,
      regulatory: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}regulatory'])!,
      economic: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}economic'])!,
      throughput: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}throughput'])!,
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality'])!,
      line: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
    );
  }

  @override
  $SystemCriticalitysTable createAlias(String alias) {
    return $SystemCriticalitysTable(attachedDatabase, alias);
  }
}

class SystemCriticality extends DataClass
    implements Insertable<SystemCriticality> {
  final int id;
  final String description;
  final String? siteid;
  final int safety;
  final int regulatory;
  final int economic;
  final int throughput;
  final int quality;
  final String line;
  final double score;
  const SystemCriticality(
      {required this.id,
      required this.description,
      this.siteid,
      required this.safety,
      required this.regulatory,
      required this.economic,
      required this.throughput,
      required this.quality,
      required this.line,
      required this.score});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || siteid != null) {
      map['siteid'] = Variable<String>(siteid);
    }
    map['safety'] = Variable<int>(safety);
    map['regulatory'] = Variable<int>(regulatory);
    map['economic'] = Variable<int>(economic);
    map['throughput'] = Variable<int>(throughput);
    map['quality'] = Variable<int>(quality);
    map['line'] = Variable<String>(line);
    map['score'] = Variable<double>(score);
    return map;
  }

  SystemCriticalitysCompanion toCompanion(bool nullToAbsent) {
    return SystemCriticalitysCompanion(
      id: Value(id),
      description: Value(description),
      siteid:
          siteid == null && nullToAbsent ? const Value.absent() : Value(siteid),
      safety: Value(safety),
      regulatory: Value(regulatory),
      economic: Value(economic),
      throughput: Value(throughput),
      quality: Value(quality),
      line: Value(line),
      score: Value(score),
    );
  }

  factory SystemCriticality.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SystemCriticality(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      siteid: serializer.fromJson<String?>(json['siteid']),
      safety: serializer.fromJson<int>(json['safety']),
      regulatory: serializer.fromJson<int>(json['regulatory']),
      economic: serializer.fromJson<int>(json['economic']),
      throughput: serializer.fromJson<int>(json['throughput']),
      quality: serializer.fromJson<int>(json['quality']),
      line: serializer.fromJson<String>(json['line']),
      score: serializer.fromJson<double>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'siteid': serializer.toJson<String?>(siteid),
      'safety': serializer.toJson<int>(safety),
      'regulatory': serializer.toJson<int>(regulatory),
      'economic': serializer.toJson<int>(economic),
      'throughput': serializer.toJson<int>(throughput),
      'quality': serializer.toJson<int>(quality),
      'line': serializer.toJson<String>(line),
      'score': serializer.toJson<double>(score),
    };
  }

  SystemCriticality copyWith(
          {int? id,
          String? description,
          Value<String?> siteid = const Value.absent(),
          int? safety,
          int? regulatory,
          int? economic,
          int? throughput,
          int? quality,
          String? line,
          double? score}) =>
      SystemCriticality(
        id: id ?? this.id,
        description: description ?? this.description,
        siteid: siteid.present ? siteid.value : this.siteid,
        safety: safety ?? this.safety,
        regulatory: regulatory ?? this.regulatory,
        economic: economic ?? this.economic,
        throughput: throughput ?? this.throughput,
        quality: quality ?? this.quality,
        line: line ?? this.line,
        score: score ?? this.score,
      );
  @override
  String toString() {
    return (StringBuffer('SystemCriticality(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('siteid: $siteid, ')
          ..write('safety: $safety, ')
          ..write('regulatory: $regulatory, ')
          ..write('economic: $economic, ')
          ..write('throughput: $throughput, ')
          ..write('quality: $quality, ')
          ..write('line: $line, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description, siteid, safety, regulatory,
      economic, throughput, quality, line, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SystemCriticality &&
          other.id == this.id &&
          other.description == this.description &&
          other.siteid == this.siteid &&
          other.safety == this.safety &&
          other.regulatory == this.regulatory &&
          other.economic == this.economic &&
          other.throughput == this.throughput &&
          other.quality == this.quality &&
          other.line == this.line &&
          other.score == this.score);
}

class SystemCriticalitysCompanion extends UpdateCompanion<SystemCriticality> {
  final Value<int> id;
  final Value<String> description;
  final Value<String?> siteid;
  final Value<int> safety;
  final Value<int> regulatory;
  final Value<int> economic;
  final Value<int> throughput;
  final Value<int> quality;
  final Value<String> line;
  final Value<double> score;
  const SystemCriticalitysCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.siteid = const Value.absent(),
    this.safety = const Value.absent(),
    this.regulatory = const Value.absent(),
    this.economic = const Value.absent(),
    this.throughput = const Value.absent(),
    this.quality = const Value.absent(),
    this.line = const Value.absent(),
    this.score = const Value.absent(),
  });
  SystemCriticalitysCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    this.siteid = const Value.absent(),
    this.safety = const Value.absent(),
    this.regulatory = const Value.absent(),
    this.economic = const Value.absent(),
    this.throughput = const Value.absent(),
    this.quality = const Value.absent(),
    required String line,
    this.score = const Value.absent(),
  })  : description = Value(description),
        line = Value(line);
  static Insertable<SystemCriticality> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<String>? siteid,
    Expression<int>? safety,
    Expression<int>? regulatory,
    Expression<int>? economic,
    Expression<int>? throughput,
    Expression<int>? quality,
    Expression<String>? line,
    Expression<double>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (siteid != null) 'siteid': siteid,
      if (safety != null) 'safety': safety,
      if (regulatory != null) 'regulatory': regulatory,
      if (economic != null) 'economic': economic,
      if (throughput != null) 'throughput': throughput,
      if (quality != null) 'quality': quality,
      if (line != null) 'line': line,
      if (score != null) 'score': score,
    });
  }

  SystemCriticalitysCompanion copyWith(
      {Value<int>? id,
      Value<String>? description,
      Value<String?>? siteid,
      Value<int>? safety,
      Value<int>? regulatory,
      Value<int>? economic,
      Value<int>? throughput,
      Value<int>? quality,
      Value<String>? line,
      Value<double>? score}) {
    return SystemCriticalitysCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      siteid: siteid ?? this.siteid,
      safety: safety ?? this.safety,
      regulatory: regulatory ?? this.regulatory,
      economic: economic ?? this.economic,
      throughput: throughput ?? this.throughput,
      quality: quality ?? this.quality,
      line: line ?? this.line,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (siteid.present) {
      map['siteid'] = Variable<String>(siteid.value);
    }
    if (safety.present) {
      map['safety'] = Variable<int>(safety.value);
    }
    if (regulatory.present) {
      map['regulatory'] = Variable<int>(regulatory.value);
    }
    if (economic.present) {
      map['economic'] = Variable<int>(economic.value);
    }
    if (throughput.present) {
      map['throughput'] = Variable<int>(throughput.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (line.present) {
      map['line'] = Variable<String>(line.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SystemCriticalitysCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('siteid: $siteid, ')
          ..write('safety: $safety, ')
          ..write('regulatory: $regulatory, ')
          ..write('economic: $economic, ')
          ..write('throughput: $throughput, ')
          ..write('quality: $quality, ')
          ..write('line: $line, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $AssetCriticalitysTable extends AssetCriticalitys
    with TableInfo<$AssetCriticalitysTable, AssetCriticality> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetCriticalitysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetMeta = const VerificationMeta('asset');
  @override
  late final GeneratedColumn<String> asset = GeneratedColumn<String>(
      'asset', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES assets (id)'));
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<int> system = GeneratedColumn<int>(
      'system', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES system_criticalitys (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downtimeMeta =
      const VerificationMeta('downtime');
  @override
  late final GeneratedColumn<int> downtime = GeneratedColumn<int>(
      'downtime', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _earlyDetectionMeta =
      const VerificationMeta('earlyDetection');
  @override
  late final GeneratedColumn<double> earlyDetection = GeneratedColumn<double>(
      'early_detection', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _manualMeta = const VerificationMeta('manual');
  @override
  late final GeneratedColumn<bool> manual = GeneratedColumn<bool>(
      'manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("manual" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _manualPriorityMeta =
      const VerificationMeta('manualPriority');
  @override
  late final GeneratedColumn<bool> manualPriority = GeneratedColumn<bool>(
      'manual_priority', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("manual_priority" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _newPriorityMeta =
      const VerificationMeta('newPriority');
  @override
  late final GeneratedColumn<int> newPriority = GeneratedColumn<int>(
      'new_priority', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _newRPNMeta = const VerificationMeta('newRPN');
  @override
  late final GeneratedColumn<double> newRPN = GeneratedColumn<double>(
      'new_r_p_n', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lockedSystemMeta =
      const VerificationMeta('lockedSystem');
  @override
  late final GeneratedColumn<bool> lockedSystem = GeneratedColumn<bool>(
      'locked_system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("locked_system" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        asset,
        system,
        type,
        frequency,
        downtime,
        earlyDetection,
        manual,
        manualPriority,
        newPriority,
        newRPN,
        lockedSystem
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_criticalitys';
  @override
  VerificationContext validateIntegrity(Insertable<AssetCriticality> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset')) {
      context.handle(
          _assetMeta, asset.isAcceptableOrUnknown(data['asset']!, _assetMeta));
    } else if (isInserting) {
      context.missing(_assetMeta);
    }
    if (data.containsKey('system')) {
      context.handle(_systemMeta,
          system.isAcceptableOrUnknown(data['system']!, _systemMeta));
    } else if (isInserting) {
      context.missing(_systemMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('downtime')) {
      context.handle(_downtimeMeta,
          downtime.isAcceptableOrUnknown(data['downtime']!, _downtimeMeta));
    } else if (isInserting) {
      context.missing(_downtimeMeta);
    }
    if (data.containsKey('early_detection')) {
      context.handle(
          _earlyDetectionMeta,
          earlyDetection.isAcceptableOrUnknown(
              data['early_detection']!, _earlyDetectionMeta));
    }
    if (data.containsKey('manual')) {
      context.handle(_manualMeta,
          manual.isAcceptableOrUnknown(data['manual']!, _manualMeta));
    }
    if (data.containsKey('manual_priority')) {
      context.handle(
          _manualPriorityMeta,
          manualPriority.isAcceptableOrUnknown(
              data['manual_priority']!, _manualPriorityMeta));
    }
    if (data.containsKey('new_priority')) {
      context.handle(
          _newPriorityMeta,
          newPriority.isAcceptableOrUnknown(
              data['new_priority']!, _newPriorityMeta));
    }
    if (data.containsKey('new_r_p_n')) {
      context.handle(_newRPNMeta,
          newRPN.isAcceptableOrUnknown(data['new_r_p_n']!, _newRPNMeta));
    }
    if (data.containsKey('locked_system')) {
      context.handle(
          _lockedSystemMeta,
          lockedSystem.isAcceptableOrUnknown(
              data['locked_system']!, _lockedSystemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {asset};
  @override
  AssetCriticality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetCriticality(
      asset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset'])!,
      system: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}system'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      downtime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downtime'])!,
      earlyDetection: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}early_detection'])!,
      manual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manual'])!,
      manualPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manual_priority'])!,
      newPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_priority']),
      newRPN: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}new_r_p_n'])!,
      lockedSystem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}locked_system'])!,
    );
  }

  @override
  $AssetCriticalitysTable createAlias(String alias) {
    return $AssetCriticalitysTable(attachedDatabase, alias);
  }
}

class AssetCriticality extends DataClass
    implements Insertable<AssetCriticality> {
  final String asset;
  final int system;
  final String type;
  final int frequency;
  final int downtime;
  final double earlyDetection;
  final bool manual;
  final bool manualPriority;
  final int? newPriority;
  final double newRPN;
  final bool lockedSystem;
  const AssetCriticality(
      {required this.asset,
      required this.system,
      required this.type,
      required this.frequency,
      required this.downtime,
      required this.earlyDetection,
      required this.manual,
      required this.manualPriority,
      this.newPriority,
      required this.newRPN,
      required this.lockedSystem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset'] = Variable<String>(asset);
    map['system'] = Variable<int>(system);
    map['type'] = Variable<String>(type);
    map['frequency'] = Variable<int>(frequency);
    map['downtime'] = Variable<int>(downtime);
    map['early_detection'] = Variable<double>(earlyDetection);
    map['manual'] = Variable<bool>(manual);
    map['manual_priority'] = Variable<bool>(manualPriority);
    if (!nullToAbsent || newPriority != null) {
      map['new_priority'] = Variable<int>(newPriority);
    }
    map['new_r_p_n'] = Variable<double>(newRPN);
    map['locked_system'] = Variable<bool>(lockedSystem);
    return map;
  }

  AssetCriticalitysCompanion toCompanion(bool nullToAbsent) {
    return AssetCriticalitysCompanion(
      asset: Value(asset),
      system: Value(system),
      type: Value(type),
      frequency: Value(frequency),
      downtime: Value(downtime),
      earlyDetection: Value(earlyDetection),
      manual: Value(manual),
      manualPriority: Value(manualPriority),
      newPriority: newPriority == null && nullToAbsent
          ? const Value.absent()
          : Value(newPriority),
      newRPN: Value(newRPN),
      lockedSystem: Value(lockedSystem),
    );
  }

  factory AssetCriticality.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetCriticality(
      asset: serializer.fromJson<String>(json['asset']),
      system: serializer.fromJson<int>(json['system']),
      type: serializer.fromJson<String>(json['type']),
      frequency: serializer.fromJson<int>(json['frequency']),
      downtime: serializer.fromJson<int>(json['downtime']),
      earlyDetection: serializer.fromJson<double>(json['earlyDetection']),
      manual: serializer.fromJson<bool>(json['manual']),
      manualPriority: serializer.fromJson<bool>(json['manualPriority']),
      newPriority: serializer.fromJson<int?>(json['newPriority']),
      newRPN: serializer.fromJson<double>(json['newRPN']),
      lockedSystem: serializer.fromJson<bool>(json['lockedSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'asset': serializer.toJson<String>(asset),
      'system': serializer.toJson<int>(system),
      'type': serializer.toJson<String>(type),
      'frequency': serializer.toJson<int>(frequency),
      'downtime': serializer.toJson<int>(downtime),
      'earlyDetection': serializer.toJson<double>(earlyDetection),
      'manual': serializer.toJson<bool>(manual),
      'manualPriority': serializer.toJson<bool>(manualPriority),
      'newPriority': serializer.toJson<int?>(newPriority),
      'newRPN': serializer.toJson<double>(newRPN),
      'lockedSystem': serializer.toJson<bool>(lockedSystem),
    };
  }

  AssetCriticality copyWith(
          {String? asset,
          int? system,
          String? type,
          int? frequency,
          int? downtime,
          double? earlyDetection,
          bool? manual,
          bool? manualPriority,
          Value<int?> newPriority = const Value.absent(),
          double? newRPN,
          bool? lockedSystem}) =>
      AssetCriticality(
        asset: asset ?? this.asset,
        system: system ?? this.system,
        type: type ?? this.type,
        frequency: frequency ?? this.frequency,
        downtime: downtime ?? this.downtime,
        earlyDetection: earlyDetection ?? this.earlyDetection,
        manual: manual ?? this.manual,
        manualPriority: manualPriority ?? this.manualPriority,
        newPriority: newPriority.present ? newPriority.value : this.newPriority,
        newRPN: newRPN ?? this.newRPN,
        lockedSystem: lockedSystem ?? this.lockedSystem,
      );
  @override
  String toString() {
    return (StringBuffer('AssetCriticality(')
          ..write('asset: $asset, ')
          ..write('system: $system, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('downtime: $downtime, ')
          ..write('earlyDetection: $earlyDetection, ')
          ..write('manual: $manual, ')
          ..write('manualPriority: $manualPriority, ')
          ..write('newPriority: $newPriority, ')
          ..write('newRPN: $newRPN, ')
          ..write('lockedSystem: $lockedSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      asset,
      system,
      type,
      frequency,
      downtime,
      earlyDetection,
      manual,
      manualPriority,
      newPriority,
      newRPN,
      lockedSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetCriticality &&
          other.asset == this.asset &&
          other.system == this.system &&
          other.type == this.type &&
          other.frequency == this.frequency &&
          other.downtime == this.downtime &&
          other.earlyDetection == this.earlyDetection &&
          other.manual == this.manual &&
          other.manualPriority == this.manualPriority &&
          other.newPriority == this.newPriority &&
          other.newRPN == this.newRPN &&
          other.lockedSystem == this.lockedSystem);
}

class AssetCriticalitysCompanion extends UpdateCompanion<AssetCriticality> {
  final Value<String> asset;
  final Value<int> system;
  final Value<String> type;
  final Value<int> frequency;
  final Value<int> downtime;
  final Value<double> earlyDetection;
  final Value<bool> manual;
  final Value<bool> manualPriority;
  final Value<int?> newPriority;
  final Value<double> newRPN;
  final Value<bool> lockedSystem;
  final Value<int> rowid;
  const AssetCriticalitysCompanion({
    this.asset = const Value.absent(),
    this.system = const Value.absent(),
    this.type = const Value.absent(),
    this.frequency = const Value.absent(),
    this.downtime = const Value.absent(),
    this.earlyDetection = const Value.absent(),
    this.manual = const Value.absent(),
    this.manualPriority = const Value.absent(),
    this.newPriority = const Value.absent(),
    this.newRPN = const Value.absent(),
    this.lockedSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetCriticalitysCompanion.insert({
    required String asset,
    required int system,
    required String type,
    required int frequency,
    required int downtime,
    this.earlyDetection = const Value.absent(),
    this.manual = const Value.absent(),
    this.manualPriority = const Value.absent(),
    this.newPriority = const Value.absent(),
    this.newRPN = const Value.absent(),
    this.lockedSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : asset = Value(asset),
        system = Value(system),
        type = Value(type),
        frequency = Value(frequency),
        downtime = Value(downtime);
  static Insertable<AssetCriticality> custom({
    Expression<String>? asset,
    Expression<int>? system,
    Expression<String>? type,
    Expression<int>? frequency,
    Expression<int>? downtime,
    Expression<double>? earlyDetection,
    Expression<bool>? manual,
    Expression<bool>? manualPriority,
    Expression<int>? newPriority,
    Expression<double>? newRPN,
    Expression<bool>? lockedSystem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (asset != null) 'asset': asset,
      if (system != null) 'system': system,
      if (type != null) 'type': type,
      if (frequency != null) 'frequency': frequency,
      if (downtime != null) 'downtime': downtime,
      if (earlyDetection != null) 'early_detection': earlyDetection,
      if (manual != null) 'manual': manual,
      if (manualPriority != null) 'manual_priority': manualPriority,
      if (newPriority != null) 'new_priority': newPriority,
      if (newRPN != null) 'new_r_p_n': newRPN,
      if (lockedSystem != null) 'locked_system': lockedSystem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetCriticalitysCompanion copyWith(
      {Value<String>? asset,
      Value<int>? system,
      Value<String>? type,
      Value<int>? frequency,
      Value<int>? downtime,
      Value<double>? earlyDetection,
      Value<bool>? manual,
      Value<bool>? manualPriority,
      Value<int?>? newPriority,
      Value<double>? newRPN,
      Value<bool>? lockedSystem,
      Value<int>? rowid}) {
    return AssetCriticalitysCompanion(
      asset: asset ?? this.asset,
      system: system ?? this.system,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      downtime: downtime ?? this.downtime,
      earlyDetection: earlyDetection ?? this.earlyDetection,
      manual: manual ?? this.manual,
      manualPriority: manualPriority ?? this.manualPriority,
      newPriority: newPriority ?? this.newPriority,
      newRPN: newRPN ?? this.newRPN,
      lockedSystem: lockedSystem ?? this.lockedSystem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (asset.present) {
      map['asset'] = Variable<String>(asset.value);
    }
    if (system.present) {
      map['system'] = Variable<int>(system.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (downtime.present) {
      map['downtime'] = Variable<int>(downtime.value);
    }
    if (earlyDetection.present) {
      map['early_detection'] = Variable<double>(earlyDetection.value);
    }
    if (manual.present) {
      map['manual'] = Variable<bool>(manual.value);
    }
    if (manualPriority.present) {
      map['manual_priority'] = Variable<bool>(manualPriority.value);
    }
    if (newPriority.present) {
      map['new_priority'] = Variable<int>(newPriority.value);
    }
    if (newRPN.present) {
      map['new_r_p_n'] = Variable<double>(newRPN.value);
    }
    if (lockedSystem.present) {
      map['locked_system'] = Variable<bool>(lockedSystem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetCriticalitysCompanion(')
          ..write('asset: $asset, ')
          ..write('system: $system, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('downtime: $downtime, ')
          ..write('earlyDetection: $earlyDetection, ')
          ..write('manual: $manual, ')
          ..write('manualPriority: $manualPriority, ')
          ..write('newPriority: $newPriority, ')
          ..write('newRPN: $newRPN, ')
          ..write('lockedSystem: $lockedSystem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetUploadsTable extends AssetUploads
    with TableInfo<$AssetUploadsTable, AssetUpload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetMeta = const VerificationMeta('asset');
  @override
  late final GeneratedColumn<String> asset = GeneratedColumn<String>(
      'asset', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES assets (id)'));
  static const VerificationMeta _sjpDescriptionMeta =
      const VerificationMeta('sjpDescription');
  @override
  late final GeneratedColumn<String> sjpDescription = GeneratedColumn<String>(
      'sjp_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _installationDateMeta =
      const VerificationMeta('installationDate');
  @override
  late final GeneratedColumn<String> installationDate = GeneratedColumn<String>(
      'installation_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vendorMeta = const VerificationMeta('vendor');
  @override
  late final GeneratedColumn<String> vendor = GeneratedColumn<String>(
      'vendor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modelNumMeta =
      const VerificationMeta('modelNum');
  @override
  late final GeneratedColumn<String> modelNum = GeneratedColumn<String>(
      'model_num', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assetCriticalityMeta =
      const VerificationMeta('assetCriticality');
  @override
  late final GeneratedColumn<int> assetCriticality = GeneratedColumn<int>(
      'asset_criticality', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        asset,
        sjpDescription,
        installationDate,
        vendor,
        manufacturer,
        modelNum,
        assetCriticality
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_uploads';
  @override
  VerificationContext validateIntegrity(Insertable<AssetUpload> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset')) {
      context.handle(
          _assetMeta, asset.isAcceptableOrUnknown(data['asset']!, _assetMeta));
    } else if (isInserting) {
      context.missing(_assetMeta);
    }
    if (data.containsKey('sjp_description')) {
      context.handle(
          _sjpDescriptionMeta,
          sjpDescription.isAcceptableOrUnknown(
              data['sjp_description']!, _sjpDescriptionMeta));
    }
    if (data.containsKey('installation_date')) {
      context.handle(
          _installationDateMeta,
          installationDate.isAcceptableOrUnknown(
              data['installation_date']!, _installationDateMeta));
    }
    if (data.containsKey('vendor')) {
      context.handle(_vendorMeta,
          vendor.isAcceptableOrUnknown(data['vendor']!, _vendorMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('model_num')) {
      context.handle(_modelNumMeta,
          modelNum.isAcceptableOrUnknown(data['model_num']!, _modelNumMeta));
    }
    if (data.containsKey('asset_criticality')) {
      context.handle(
          _assetCriticalityMeta,
          assetCriticality.isAcceptableOrUnknown(
              data['asset_criticality']!, _assetCriticalityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {asset};
  @override
  AssetUpload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetUpload(
      asset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset'])!,
      sjpDescription: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sjp_description']),
      installationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}installation_date']),
      vendor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vendor']),
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      modelNum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_num']),
      assetCriticality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}asset_criticality']),
    );
  }

  @override
  $AssetUploadsTable createAlias(String alias) {
    return $AssetUploadsTable(attachedDatabase, alias);
  }
}

class AssetUpload extends DataClass implements Insertable<AssetUpload> {
  final String asset;
  final String? sjpDescription;
  final String? installationDate;
  final String? vendor;
  final String? manufacturer;
  final String? modelNum;
  final int? assetCriticality;
  const AssetUpload(
      {required this.asset,
      this.sjpDescription,
      this.installationDate,
      this.vendor,
      this.manufacturer,
      this.modelNum,
      this.assetCriticality});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset'] = Variable<String>(asset);
    if (!nullToAbsent || sjpDescription != null) {
      map['sjp_description'] = Variable<String>(sjpDescription);
    }
    if (!nullToAbsent || installationDate != null) {
      map['installation_date'] = Variable<String>(installationDate);
    }
    if (!nullToAbsent || vendor != null) {
      map['vendor'] = Variable<String>(vendor);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || modelNum != null) {
      map['model_num'] = Variable<String>(modelNum);
    }
    if (!nullToAbsent || assetCriticality != null) {
      map['asset_criticality'] = Variable<int>(assetCriticality);
    }
    return map;
  }

  AssetUploadsCompanion toCompanion(bool nullToAbsent) {
    return AssetUploadsCompanion(
      asset: Value(asset),
      sjpDescription: sjpDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(sjpDescription),
      installationDate: installationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(installationDate),
      vendor:
          vendor == null && nullToAbsent ? const Value.absent() : Value(vendor),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      modelNum: modelNum == null && nullToAbsent
          ? const Value.absent()
          : Value(modelNum),
      assetCriticality: assetCriticality == null && nullToAbsent
          ? const Value.absent()
          : Value(assetCriticality),
    );
  }

  factory AssetUpload.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetUpload(
      asset: serializer.fromJson<String>(json['asset']),
      sjpDescription: serializer.fromJson<String?>(json['sjpDescription']),
      installationDate: serializer.fromJson<String?>(json['installationDate']),
      vendor: serializer.fromJson<String?>(json['vendor']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      modelNum: serializer.fromJson<String?>(json['modelNum']),
      assetCriticality: serializer.fromJson<int?>(json['assetCriticality']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'asset': serializer.toJson<String>(asset),
      'sjpDescription': serializer.toJson<String?>(sjpDescription),
      'installationDate': serializer.toJson<String?>(installationDate),
      'vendor': serializer.toJson<String?>(vendor),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'modelNum': serializer.toJson<String?>(modelNum),
      'assetCriticality': serializer.toJson<int?>(assetCriticality),
    };
  }

  AssetUpload copyWith(
          {String? asset,
          Value<String?> sjpDescription = const Value.absent(),
          Value<String?> installationDate = const Value.absent(),
          Value<String?> vendor = const Value.absent(),
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> modelNum = const Value.absent(),
          Value<int?> assetCriticality = const Value.absent()}) =>
      AssetUpload(
        asset: asset ?? this.asset,
        sjpDescription:
            sjpDescription.present ? sjpDescription.value : this.sjpDescription,
        installationDate: installationDate.present
            ? installationDate.value
            : this.installationDate,
        vendor: vendor.present ? vendor.value : this.vendor,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        modelNum: modelNum.present ? modelNum.value : this.modelNum,
        assetCriticality: assetCriticality.present
            ? assetCriticality.value
            : this.assetCriticality,
      );
  @override
  String toString() {
    return (StringBuffer('AssetUpload(')
          ..write('asset: $asset, ')
          ..write('sjpDescription: $sjpDescription, ')
          ..write('installationDate: $installationDate, ')
          ..write('vendor: $vendor, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('modelNum: $modelNum, ')
          ..write('assetCriticality: $assetCriticality')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(asset, sjpDescription, installationDate,
      vendor, manufacturer, modelNum, assetCriticality);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetUpload &&
          other.asset == this.asset &&
          other.sjpDescription == this.sjpDescription &&
          other.installationDate == this.installationDate &&
          other.vendor == this.vendor &&
          other.manufacturer == this.manufacturer &&
          other.modelNum == this.modelNum &&
          other.assetCriticality == this.assetCriticality);
}

class AssetUploadsCompanion extends UpdateCompanion<AssetUpload> {
  final Value<String> asset;
  final Value<String?> sjpDescription;
  final Value<String?> installationDate;
  final Value<String?> vendor;
  final Value<String?> manufacturer;
  final Value<String?> modelNum;
  final Value<int?> assetCriticality;
  final Value<int> rowid;
  const AssetUploadsCompanion({
    this.asset = const Value.absent(),
    this.sjpDescription = const Value.absent(),
    this.installationDate = const Value.absent(),
    this.vendor = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.modelNum = const Value.absent(),
    this.assetCriticality = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetUploadsCompanion.insert({
    required String asset,
    this.sjpDescription = const Value.absent(),
    this.installationDate = const Value.absent(),
    this.vendor = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.modelNum = const Value.absent(),
    this.assetCriticality = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : asset = Value(asset);
  static Insertable<AssetUpload> custom({
    Expression<String>? asset,
    Expression<String>? sjpDescription,
    Expression<String>? installationDate,
    Expression<String>? vendor,
    Expression<String>? manufacturer,
    Expression<String>? modelNum,
    Expression<int>? assetCriticality,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (asset != null) 'asset': asset,
      if (sjpDescription != null) 'sjp_description': sjpDescription,
      if (installationDate != null) 'installation_date': installationDate,
      if (vendor != null) 'vendor': vendor,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (modelNum != null) 'model_num': modelNum,
      if (assetCriticality != null) 'asset_criticality': assetCriticality,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetUploadsCompanion copyWith(
      {Value<String>? asset,
      Value<String?>? sjpDescription,
      Value<String?>? installationDate,
      Value<String?>? vendor,
      Value<String?>? manufacturer,
      Value<String?>? modelNum,
      Value<int?>? assetCriticality,
      Value<int>? rowid}) {
    return AssetUploadsCompanion(
      asset: asset ?? this.asset,
      sjpDescription: sjpDescription ?? this.sjpDescription,
      installationDate: installationDate ?? this.installationDate,
      vendor: vendor ?? this.vendor,
      manufacturer: manufacturer ?? this.manufacturer,
      modelNum: modelNum ?? this.modelNum,
      assetCriticality: assetCriticality ?? this.assetCriticality,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (asset.present) {
      map['asset'] = Variable<String>(asset.value);
    }
    if (sjpDescription.present) {
      map['sjp_description'] = Variable<String>(sjpDescription.value);
    }
    if (installationDate.present) {
      map['installation_date'] = Variable<String>(installationDate.value);
    }
    if (vendor.present) {
      map['vendor'] = Variable<String>(vendor.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (modelNum.present) {
      map['model_num'] = Variable<String>(modelNum.value);
    }
    if (assetCriticality.present) {
      map['asset_criticality'] = Variable<int>(assetCriticality.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetUploadsCompanion(')
          ..write('asset: $asset, ')
          ..write('sjpDescription: $sjpDescription, ')
          ..write('installationDate: $installationDate, ')
          ..write('vendor: $vendor, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('modelNum: $modelNum, ')
          ..write('assetCriticality: $assetCriticality, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SparePartsTable extends SpareParts
    with TableInfo<$SparePartsTable, SparePart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SparePartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemnumMeta =
      const VerificationMeta('itemnum');
  @override
  late final GeneratedColumn<String> itemnum = GeneratedColumn<String>(
      'itemnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetnumMeta =
      const VerificationMeta('assetnum');
  @override
  late final GeneratedColumn<String> assetnum = GeneratedColumn<String>(
      'assetnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sparepartidMeta =
      const VerificationMeta('sparepartid');
  @override
  late final GeneratedColumn<int> sparepartid = GeneratedColumn<int>(
      'sparepartid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [itemnum, assetnum, siteid, quantity, sparepartid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spare_parts';
  @override
  VerificationContext validateIntegrity(Insertable<SparePart> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('itemnum')) {
      context.handle(_itemnumMeta,
          itemnum.isAcceptableOrUnknown(data['itemnum']!, _itemnumMeta));
    } else if (isInserting) {
      context.missing(_itemnumMeta);
    }
    if (data.containsKey('assetnum')) {
      context.handle(_assetnumMeta,
          assetnum.isAcceptableOrUnknown(data['assetnum']!, _assetnumMeta));
    } else if (isInserting) {
      context.missing(_assetnumMeta);
    }
    if (data.containsKey('siteid')) {
      context.handle(_siteidMeta,
          siteid.isAcceptableOrUnknown(data['siteid']!, _siteidMeta));
    } else if (isInserting) {
      context.missing(_siteidMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('sparepartid')) {
      context.handle(
          _sparepartidMeta,
          sparepartid.isAcceptableOrUnknown(
              data['sparepartid']!, _sparepartidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sparepartid};
  @override
  SparePart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SparePart(
      itemnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itemnum'])!,
      assetnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assetnum'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      sparepartid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sparepartid'])!,
    );
  }

  @override
  $SparePartsTable createAlias(String alias) {
    return $SparePartsTable(attachedDatabase, alias);
  }
}

class SparePart extends DataClass implements Insertable<SparePart> {
  final String itemnum;
  final String assetnum;
  final String siteid;
  final double quantity;
  final int sparepartid;
  const SparePart(
      {required this.itemnum,
      required this.assetnum,
      required this.siteid,
      required this.quantity,
      required this.sparepartid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['itemnum'] = Variable<String>(itemnum);
    map['assetnum'] = Variable<String>(assetnum);
    map['siteid'] = Variable<String>(siteid);
    map['quantity'] = Variable<double>(quantity);
    map['sparepartid'] = Variable<int>(sparepartid);
    return map;
  }

  SparePartsCompanion toCompanion(bool nullToAbsent) {
    return SparePartsCompanion(
      itemnum: Value(itemnum),
      assetnum: Value(assetnum),
      siteid: Value(siteid),
      quantity: Value(quantity),
      sparepartid: Value(sparepartid),
    );
  }

  factory SparePart.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SparePart(
      itemnum: serializer.fromJson<String>(json['itemnum']),
      assetnum: serializer.fromJson<String>(json['assetnum']),
      siteid: serializer.fromJson<String>(json['siteid']),
      quantity: serializer.fromJson<double>(json['quantity']),
      sparepartid: serializer.fromJson<int>(json['sparepartid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemnum': serializer.toJson<String>(itemnum),
      'assetnum': serializer.toJson<String>(assetnum),
      'siteid': serializer.toJson<String>(siteid),
      'quantity': serializer.toJson<double>(quantity),
      'sparepartid': serializer.toJson<int>(sparepartid),
    };
  }

  SparePart copyWith(
          {String? itemnum,
          String? assetnum,
          String? siteid,
          double? quantity,
          int? sparepartid}) =>
      SparePart(
        itemnum: itemnum ?? this.itemnum,
        assetnum: assetnum ?? this.assetnum,
        siteid: siteid ?? this.siteid,
        quantity: quantity ?? this.quantity,
        sparepartid: sparepartid ?? this.sparepartid,
      );
  @override
  String toString() {
    return (StringBuffer('SparePart(')
          ..write('itemnum: $itemnum, ')
          ..write('assetnum: $assetnum, ')
          ..write('siteid: $siteid, ')
          ..write('quantity: $quantity, ')
          ..write('sparepartid: $sparepartid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemnum, assetnum, siteid, quantity, sparepartid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SparePart &&
          other.itemnum == this.itemnum &&
          other.assetnum == this.assetnum &&
          other.siteid == this.siteid &&
          other.quantity == this.quantity &&
          other.sparepartid == this.sparepartid);
}

class SparePartsCompanion extends UpdateCompanion<SparePart> {
  final Value<String> itemnum;
  final Value<String> assetnum;
  final Value<String> siteid;
  final Value<double> quantity;
  final Value<int> sparepartid;
  const SparePartsCompanion({
    this.itemnum = const Value.absent(),
    this.assetnum = const Value.absent(),
    this.siteid = const Value.absent(),
    this.quantity = const Value.absent(),
    this.sparepartid = const Value.absent(),
  });
  SparePartsCompanion.insert({
    required String itemnum,
    required String assetnum,
    required String siteid,
    required double quantity,
    this.sparepartid = const Value.absent(),
  })  : itemnum = Value(itemnum),
        assetnum = Value(assetnum),
        siteid = Value(siteid),
        quantity = Value(quantity);
  static Insertable<SparePart> custom({
    Expression<String>? itemnum,
    Expression<String>? assetnum,
    Expression<String>? siteid,
    Expression<double>? quantity,
    Expression<int>? sparepartid,
  }) {
    return RawValuesInsertable({
      if (itemnum != null) 'itemnum': itemnum,
      if (assetnum != null) 'assetnum': assetnum,
      if (siteid != null) 'siteid': siteid,
      if (quantity != null) 'quantity': quantity,
      if (sparepartid != null) 'sparepartid': sparepartid,
    });
  }

  SparePartsCompanion copyWith(
      {Value<String>? itemnum,
      Value<String>? assetnum,
      Value<String>? siteid,
      Value<double>? quantity,
      Value<int>? sparepartid}) {
    return SparePartsCompanion(
      itemnum: itemnum ?? this.itemnum,
      assetnum: assetnum ?? this.assetnum,
      siteid: siteid ?? this.siteid,
      quantity: quantity ?? this.quantity,
      sparepartid: sparepartid ?? this.sparepartid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemnum.present) {
      map['itemnum'] = Variable<String>(itemnum.value);
    }
    if (assetnum.present) {
      map['assetnum'] = Variable<String>(assetnum.value);
    }
    if (siteid.present) {
      map['siteid'] = Variable<String>(siteid.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (sparepartid.present) {
      map['sparepartid'] = Variable<int>(sparepartid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SparePartsCompanion(')
          ..write('itemnum: $itemnum, ')
          ..write('assetnum: $assetnum, ')
          ..write('siteid: $siteid, ')
          ..write('quantity: $quantity, ')
          ..write('sparepartid: $sparepartid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prnumMeta = const VerificationMeta('prnum');
  @override
  late final GeneratedColumn<String> prnum = GeneratedColumn<String>(
      'prnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prDescriptionMeta =
      const VerificationMeta('prDescription');
  @override
  late final GeneratedColumn<String> prDescription = GeneratedColumn<String>(
      'pr_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poDescriptionMeta =
      const VerificationMeta('poDescription');
  @override
  late final GeneratedColumn<String> poDescription = GeneratedColumn<String>(
      'po_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ponumMeta = const VerificationMeta('ponum');
  @override
  late final GeneratedColumn<String> ponum = GeneratedColumn<String>(
      'ponum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _leadTimeMeta =
      const VerificationMeta('leadTime');
  @override
  late final GeneratedColumn<double> leadTime = GeneratedColumn<double>(
      'lead_time', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _itemnumMeta =
      const VerificationMeta('itemnum');
  @override
  late final GeneratedColumn<String> itemnum = GeneratedColumn<String>(
      'itemnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _poStatusMeta =
      const VerificationMeta('poStatus');
  @override
  late final GeneratedColumn<bool> poStatus = GeneratedColumn<bool>(
      'po_status', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("po_status" IN (0, 1))'));
  static const VerificationMeta _prlineidMeta =
      const VerificationMeta('prlineid');
  @override
  late final GeneratedColumn<int> prlineid = GeneratedColumn<int>(
      'prlineid', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        prnum,
        prDescription,
        poDescription,
        ponum,
        startDate,
        siteid,
        endDate,
        leadTime,
        itemnum,
        unitCost,
        poStatus,
        prlineid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<Purchase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prnum')) {
      context.handle(
          _prnumMeta, prnum.isAcceptableOrUnknown(data['prnum']!, _prnumMeta));
    } else if (isInserting) {
      context.missing(_prnumMeta);
    }
    if (data.containsKey('pr_description')) {
      context.handle(
          _prDescriptionMeta,
          prDescription.isAcceptableOrUnknown(
              data['pr_description']!, _prDescriptionMeta));
    } else if (isInserting) {
      context.missing(_prDescriptionMeta);
    }
    if (data.containsKey('po_description')) {
      context.handle(
          _poDescriptionMeta,
          poDescription.isAcceptableOrUnknown(
              data['po_description']!, _poDescriptionMeta));
    } else if (isInserting) {
      context.missing(_poDescriptionMeta);
    }
    if (data.containsKey('ponum')) {
      context.handle(
          _ponumMeta, ponum.isAcceptableOrUnknown(data['ponum']!, _ponumMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('siteid')) {
      context.handle(_siteidMeta,
          siteid.isAcceptableOrUnknown(data['siteid']!, _siteidMeta));
    } else if (isInserting) {
      context.missing(_siteidMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('lead_time')) {
      context.handle(_leadTimeMeta,
          leadTime.isAcceptableOrUnknown(data['lead_time']!, _leadTimeMeta));
    } else if (isInserting) {
      context.missing(_leadTimeMeta);
    }
    if (data.containsKey('itemnum')) {
      context.handle(_itemnumMeta,
          itemnum.isAcceptableOrUnknown(data['itemnum']!, _itemnumMeta));
    } else if (isInserting) {
      context.missing(_itemnumMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('po_status')) {
      context.handle(_poStatusMeta,
          poStatus.isAcceptableOrUnknown(data['po_status']!, _poStatusMeta));
    } else if (isInserting) {
      context.missing(_poStatusMeta);
    }
    if (data.containsKey('prlineid')) {
      context.handle(_prlineidMeta,
          prlineid.isAcceptableOrUnknown(data['prlineid']!, _prlineidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prlineid};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      prnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prnum'])!,
      prDescription: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pr_description'])!,
      poDescription: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_description'])!,
      ponum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ponum']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      leadTime: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lead_time'])!,
      itemnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itemnum'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      poStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}po_status'])!,
      prlineid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prlineid'])!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String prnum;
  final String prDescription;
  final String poDescription;
  final String? ponum;
  final String startDate;
  final String siteid;
  final String? endDate;
  final double leadTime;
  final String itemnum;
  final double unitCost;
  final bool poStatus;
  final int prlineid;
  const Purchase(
      {required this.prnum,
      required this.prDescription,
      required this.poDescription,
      this.ponum,
      required this.startDate,
      required this.siteid,
      this.endDate,
      required this.leadTime,
      required this.itemnum,
      required this.unitCost,
      required this.poStatus,
      required this.prlineid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prnum'] = Variable<String>(prnum);
    map['pr_description'] = Variable<String>(prDescription);
    map['po_description'] = Variable<String>(poDescription);
    if (!nullToAbsent || ponum != null) {
      map['ponum'] = Variable<String>(ponum);
    }
    map['start_date'] = Variable<String>(startDate);
    map['siteid'] = Variable<String>(siteid);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['lead_time'] = Variable<double>(leadTime);
    map['itemnum'] = Variable<String>(itemnum);
    map['unit_cost'] = Variable<double>(unitCost);
    map['po_status'] = Variable<bool>(poStatus);
    map['prlineid'] = Variable<int>(prlineid);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      prnum: Value(prnum),
      prDescription: Value(prDescription),
      poDescription: Value(poDescription),
      ponum:
          ponum == null && nullToAbsent ? const Value.absent() : Value(ponum),
      startDate: Value(startDate),
      siteid: Value(siteid),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      leadTime: Value(leadTime),
      itemnum: Value(itemnum),
      unitCost: Value(unitCost),
      poStatus: Value(poStatus),
      prlineid: Value(prlineid),
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      prnum: serializer.fromJson<String>(json['prnum']),
      prDescription: serializer.fromJson<String>(json['prDescription']),
      poDescription: serializer.fromJson<String>(json['poDescription']),
      ponum: serializer.fromJson<String?>(json['ponum']),
      startDate: serializer.fromJson<String>(json['startDate']),
      siteid: serializer.fromJson<String>(json['siteid']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      leadTime: serializer.fromJson<double>(json['leadTime']),
      itemnum: serializer.fromJson<String>(json['itemnum']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      poStatus: serializer.fromJson<bool>(json['poStatus']),
      prlineid: serializer.fromJson<int>(json['prlineid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prnum': serializer.toJson<String>(prnum),
      'prDescription': serializer.toJson<String>(prDescription),
      'poDescription': serializer.toJson<String>(poDescription),
      'ponum': serializer.toJson<String?>(ponum),
      'startDate': serializer.toJson<String>(startDate),
      'siteid': serializer.toJson<String>(siteid),
      'endDate': serializer.toJson<String?>(endDate),
      'leadTime': serializer.toJson<double>(leadTime),
      'itemnum': serializer.toJson<String>(itemnum),
      'unitCost': serializer.toJson<double>(unitCost),
      'poStatus': serializer.toJson<bool>(poStatus),
      'prlineid': serializer.toJson<int>(prlineid),
    };
  }

  Purchase copyWith(
          {String? prnum,
          String? prDescription,
          String? poDescription,
          Value<String?> ponum = const Value.absent(),
          String? startDate,
          String? siteid,
          Value<String?> endDate = const Value.absent(),
          double? leadTime,
          String? itemnum,
          double? unitCost,
          bool? poStatus,
          int? prlineid}) =>
      Purchase(
        prnum: prnum ?? this.prnum,
        prDescription: prDescription ?? this.prDescription,
        poDescription: poDescription ?? this.poDescription,
        ponum: ponum.present ? ponum.value : this.ponum,
        startDate: startDate ?? this.startDate,
        siteid: siteid ?? this.siteid,
        endDate: endDate.present ? endDate.value : this.endDate,
        leadTime: leadTime ?? this.leadTime,
        itemnum: itemnum ?? this.itemnum,
        unitCost: unitCost ?? this.unitCost,
        poStatus: poStatus ?? this.poStatus,
        prlineid: prlineid ?? this.prlineid,
      );
  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('prnum: $prnum, ')
          ..write('prDescription: $prDescription, ')
          ..write('poDescription: $poDescription, ')
          ..write('ponum: $ponum, ')
          ..write('startDate: $startDate, ')
          ..write('siteid: $siteid, ')
          ..write('endDate: $endDate, ')
          ..write('leadTime: $leadTime, ')
          ..write('itemnum: $itemnum, ')
          ..write('unitCost: $unitCost, ')
          ..write('poStatus: $poStatus, ')
          ..write('prlineid: $prlineid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      prnum,
      prDescription,
      poDescription,
      ponum,
      startDate,
      siteid,
      endDate,
      leadTime,
      itemnum,
      unitCost,
      poStatus,
      prlineid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.prnum == this.prnum &&
          other.prDescription == this.prDescription &&
          other.poDescription == this.poDescription &&
          other.ponum == this.ponum &&
          other.startDate == this.startDate &&
          other.siteid == this.siteid &&
          other.endDate == this.endDate &&
          other.leadTime == this.leadTime &&
          other.itemnum == this.itemnum &&
          other.unitCost == this.unitCost &&
          other.poStatus == this.poStatus &&
          other.prlineid == this.prlineid);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> prnum;
  final Value<String> prDescription;
  final Value<String> poDescription;
  final Value<String?> ponum;
  final Value<String> startDate;
  final Value<String> siteid;
  final Value<String?> endDate;
  final Value<double> leadTime;
  final Value<String> itemnum;
  final Value<double> unitCost;
  final Value<bool> poStatus;
  final Value<int> prlineid;
  const PurchasesCompanion({
    this.prnum = const Value.absent(),
    this.prDescription = const Value.absent(),
    this.poDescription = const Value.absent(),
    this.ponum = const Value.absent(),
    this.startDate = const Value.absent(),
    this.siteid = const Value.absent(),
    this.endDate = const Value.absent(),
    this.leadTime = const Value.absent(),
    this.itemnum = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.poStatus = const Value.absent(),
    this.prlineid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String prnum,
    required String prDescription,
    required String poDescription,
    this.ponum = const Value.absent(),
    required String startDate,
    required String siteid,
    this.endDate = const Value.absent(),
    required double leadTime,
    required String itemnum,
    required double unitCost,
    required bool poStatus,
    this.prlineid = const Value.absent(),
  })  : prnum = Value(prnum),
        prDescription = Value(prDescription),
        poDescription = Value(poDescription),
        startDate = Value(startDate),
        siteid = Value(siteid),
        leadTime = Value(leadTime),
        itemnum = Value(itemnum),
        unitCost = Value(unitCost),
        poStatus = Value(poStatus);
  static Insertable<Purchase> custom({
    Expression<String>? prnum,
    Expression<String>? prDescription,
    Expression<String>? poDescription,
    Expression<String>? ponum,
    Expression<String>? startDate,
    Expression<String>? siteid,
    Expression<String>? endDate,
    Expression<double>? leadTime,
    Expression<String>? itemnum,
    Expression<double>? unitCost,
    Expression<bool>? poStatus,
    Expression<int>? prlineid,
  }) {
    return RawValuesInsertable({
      if (prnum != null) 'prnum': prnum,
      if (prDescription != null) 'pr_description': prDescription,
      if (poDescription != null) 'po_description': poDescription,
      if (ponum != null) 'ponum': ponum,
      if (startDate != null) 'start_date': startDate,
      if (siteid != null) 'siteid': siteid,
      if (endDate != null) 'end_date': endDate,
      if (leadTime != null) 'lead_time': leadTime,
      if (itemnum != null) 'itemnum': itemnum,
      if (unitCost != null) 'unit_cost': unitCost,
      if (poStatus != null) 'po_status': poStatus,
      if (prlineid != null) 'prlineid': prlineid,
    });
  }

  PurchasesCompanion copyWith(
      {Value<String>? prnum,
      Value<String>? prDescription,
      Value<String>? poDescription,
      Value<String?>? ponum,
      Value<String>? startDate,
      Value<String>? siteid,
      Value<String?>? endDate,
      Value<double>? leadTime,
      Value<String>? itemnum,
      Value<double>? unitCost,
      Value<bool>? poStatus,
      Value<int>? prlineid}) {
    return PurchasesCompanion(
      prnum: prnum ?? this.prnum,
      prDescription: prDescription ?? this.prDescription,
      poDescription: poDescription ?? this.poDescription,
      ponum: ponum ?? this.ponum,
      startDate: startDate ?? this.startDate,
      siteid: siteid ?? this.siteid,
      endDate: endDate ?? this.endDate,
      leadTime: leadTime ?? this.leadTime,
      itemnum: itemnum ?? this.itemnum,
      unitCost: unitCost ?? this.unitCost,
      poStatus: poStatus ?? this.poStatus,
      prlineid: prlineid ?? this.prlineid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prnum.present) {
      map['prnum'] = Variable<String>(prnum.value);
    }
    if (prDescription.present) {
      map['pr_description'] = Variable<String>(prDescription.value);
    }
    if (poDescription.present) {
      map['po_description'] = Variable<String>(poDescription.value);
    }
    if (ponum.present) {
      map['ponum'] = Variable<String>(ponum.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (siteid.present) {
      map['siteid'] = Variable<String>(siteid.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (leadTime.present) {
      map['lead_time'] = Variable<double>(leadTime.value);
    }
    if (itemnum.present) {
      map['itemnum'] = Variable<String>(itemnum.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (poStatus.present) {
      map['po_status'] = Variable<bool>(poStatus.value);
    }
    if (prlineid.present) {
      map['prlineid'] = Variable<int>(prlineid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('prnum: $prnum, ')
          ..write('prDescription: $prDescription, ')
          ..write('poDescription: $poDescription, ')
          ..write('ponum: $ponum, ')
          ..write('startDate: $startDate, ')
          ..write('siteid: $siteid, ')
          ..write('endDate: $endDate, ')
          ..write('leadTime: $leadTime, ')
          ..write('itemnum: $itemnum, ')
          ..write('unitCost: $unitCost, ')
          ..write('poStatus: $poStatus, ')
          ..write('prlineid: $prlineid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemnumMeta =
      const VerificationMeta('itemnum');
  @override
  late final GeneratedColumn<String> itemnum = GeneratedColumn<String>(
      'itemnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commodityGroupMeta =
      const VerificationMeta('commodityGroup');
  @override
  late final GeneratedColumn<String> commodityGroup = GeneratedColumn<String>(
      'commodity_group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _glClassMeta =
      const VerificationMeta('glClass');
  @override
  late final GeneratedColumn<String> glClass = GeneratedColumn<String>(
      'gl_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [itemnum, description, status, commodityGroup, glClass];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('itemnum')) {
      context.handle(_itemnumMeta,
          itemnum.isAcceptableOrUnknown(data['itemnum']!, _itemnumMeta));
    } else if (isInserting) {
      context.missing(_itemnumMeta);
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
    if (data.containsKey('commodity_group')) {
      context.handle(
          _commodityGroupMeta,
          commodityGroup.isAcceptableOrUnknown(
              data['commodity_group']!, _commodityGroupMeta));
    } else if (isInserting) {
      context.missing(_commodityGroupMeta);
    }
    if (data.containsKey('gl_class')) {
      context.handle(_glClassMeta,
          glClass.isAcceptableOrUnknown(data['gl_class']!, _glClassMeta));
    } else if (isInserting) {
      context.missing(_glClassMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemnum};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      itemnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itemnum'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      commodityGroup: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}commodity_group'])!,
      glClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gl_class'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String itemnum;
  final String description;
  final String status;
  final String commodityGroup;
  final String glClass;
  const Item(
      {required this.itemnum,
      required this.description,
      required this.status,
      required this.commodityGroup,
      required this.glClass});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['itemnum'] = Variable<String>(itemnum);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    map['commodity_group'] = Variable<String>(commodityGroup);
    map['gl_class'] = Variable<String>(glClass);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      itemnum: Value(itemnum),
      description: Value(description),
      status: Value(status),
      commodityGroup: Value(commodityGroup),
      glClass: Value(glClass),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      itemnum: serializer.fromJson<String>(json['itemnum']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      commodityGroup: serializer.fromJson<String>(json['commodityGroup']),
      glClass: serializer.fromJson<String>(json['glClass']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemnum': serializer.toJson<String>(itemnum),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'commodityGroup': serializer.toJson<String>(commodityGroup),
      'glClass': serializer.toJson<String>(glClass),
    };
  }

  Item copyWith(
          {String? itemnum,
          String? description,
          String? status,
          String? commodityGroup,
          String? glClass}) =>
      Item(
        itemnum: itemnum ?? this.itemnum,
        description: description ?? this.description,
        status: status ?? this.status,
        commodityGroup: commodityGroup ?? this.commodityGroup,
        glClass: glClass ?? this.glClass,
      );
  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('itemnum: $itemnum, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('commodityGroup: $commodityGroup, ')
          ..write('glClass: $glClass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemnum, description, status, commodityGroup, glClass);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.itemnum == this.itemnum &&
          other.description == this.description &&
          other.status == this.status &&
          other.commodityGroup == this.commodityGroup &&
          other.glClass == this.glClass);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> itemnum;
  final Value<String> description;
  final Value<String> status;
  final Value<String> commodityGroup;
  final Value<String> glClass;
  final Value<int> rowid;
  const ItemsCompanion({
    this.itemnum = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.commodityGroup = const Value.absent(),
    this.glClass = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String itemnum,
    required String description,
    required String status,
    required String commodityGroup,
    required String glClass,
    this.rowid = const Value.absent(),
  })  : itemnum = Value(itemnum),
        description = Value(description),
        status = Value(status),
        commodityGroup = Value(commodityGroup),
        glClass = Value(glClass);
  static Insertable<Item> custom({
    Expression<String>? itemnum,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? commodityGroup,
    Expression<String>? glClass,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemnum != null) 'itemnum': itemnum,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (commodityGroup != null) 'commodity_group': commodityGroup,
      if (glClass != null) 'gl_class': glClass,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? itemnum,
      Value<String>? description,
      Value<String>? status,
      Value<String>? commodityGroup,
      Value<String>? glClass,
      Value<int>? rowid}) {
    return ItemsCompanion(
      itemnum: itemnum ?? this.itemnum,
      description: description ?? this.description,
      status: status ?? this.status,
      commodityGroup: commodityGroup ?? this.commodityGroup,
      glClass: glClass ?? this.glClass,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemnum.present) {
      map['itemnum'] = Variable<String>(itemnum.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (commodityGroup.present) {
      map['commodity_group'] = Variable<String>(commodityGroup.value);
    }
    if (glClass.present) {
      map['gl_class'] = Variable<String>(glClass.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('itemnum: $itemnum, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('commodityGroup: $commodityGroup, ')
          ..write('glClass: $glClass, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpareCriticalitysTable extends SpareCriticalitys
    with TableInfo<$SpareCriticalitysTable, SpareCriticality> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpareCriticalitysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<int> usage = GeneratedColumn<int>(
      'usage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _leadTimeMeta =
      const VerificationMeta('leadTime');
  @override
  late final GeneratedColumn<int> leadTime = GeneratedColumn<int>(
      'lead_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
      'cost', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _assetRPNMeta =
      const VerificationMeta('assetRPN');
  @override
  late final GeneratedColumn<double> assetRPN = GeneratedColumn<double>(
      'asset_r_p_n', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _manualMeta = const VerificationMeta('manual');
  @override
  late final GeneratedColumn<bool> manual = GeneratedColumn<bool>(
      'manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("manual" IN (0, 1))'));
  static const VerificationMeta _manualPriorityMeta =
      const VerificationMeta('manualPriority');
  @override
  late final GeneratedColumn<bool> manualPriority = GeneratedColumn<bool>(
      'manual_priority', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("manual_priority" IN (0, 1))'));
  static const VerificationMeta _newPriorityMeta =
      const VerificationMeta('newPriority');
  @override
  late final GeneratedColumn<int> newPriority = GeneratedColumn<int>(
      'new_priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newRPNMeta = const VerificationMeta('newRPN');
  @override
  late final GeneratedColumn<double> newRPN = GeneratedColumn<double>(
      'new_r_p_n', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _siteidMeta = const VerificationMeta('siteid');
  @override
  late final GeneratedColumn<String> siteid = GeneratedColumn<String>(
      'siteid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemnumMeta =
      const VerificationMeta('itemnum');
  @override
  late final GeneratedColumn<String> itemnum = GeneratedColumn<String>(
      'itemnum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        usage,
        leadTime,
        cost,
        assetRPN,
        manual,
        manualPriority,
        newPriority,
        newRPN,
        siteid,
        itemnum
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spare_criticalitys';
  @override
  VerificationContext validateIntegrity(Insertable<SpareCriticality> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('usage')) {
      context.handle(
          _usageMeta, usage.isAcceptableOrUnknown(data['usage']!, _usageMeta));
    } else if (isInserting) {
      context.missing(_usageMeta);
    }
    if (data.containsKey('lead_time')) {
      context.handle(_leadTimeMeta,
          leadTime.isAcceptableOrUnknown(data['lead_time']!, _leadTimeMeta));
    } else if (isInserting) {
      context.missing(_leadTimeMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
          _costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('asset_r_p_n')) {
      context.handle(_assetRPNMeta,
          assetRPN.isAcceptableOrUnknown(data['asset_r_p_n']!, _assetRPNMeta));
    } else if (isInserting) {
      context.missing(_assetRPNMeta);
    }
    if (data.containsKey('manual')) {
      context.handle(_manualMeta,
          manual.isAcceptableOrUnknown(data['manual']!, _manualMeta));
    } else if (isInserting) {
      context.missing(_manualMeta);
    }
    if (data.containsKey('manual_priority')) {
      context.handle(
          _manualPriorityMeta,
          manualPriority.isAcceptableOrUnknown(
              data['manual_priority']!, _manualPriorityMeta));
    } else if (isInserting) {
      context.missing(_manualPriorityMeta);
    }
    if (data.containsKey('new_priority')) {
      context.handle(
          _newPriorityMeta,
          newPriority.isAcceptableOrUnknown(
              data['new_priority']!, _newPriorityMeta));
    } else if (isInserting) {
      context.missing(_newPriorityMeta);
    }
    if (data.containsKey('new_r_p_n')) {
      context.handle(_newRPNMeta,
          newRPN.isAcceptableOrUnknown(data['new_r_p_n']!, _newRPNMeta));
    } else if (isInserting) {
      context.missing(_newRPNMeta);
    }
    if (data.containsKey('siteid')) {
      context.handle(_siteidMeta,
          siteid.isAcceptableOrUnknown(data['siteid']!, _siteidMeta));
    } else if (isInserting) {
      context.missing(_siteidMeta);
    }
    if (data.containsKey('itemnum')) {
      context.handle(_itemnumMeta,
          itemnum.isAcceptableOrUnknown(data['itemnum']!, _itemnumMeta));
    } else if (isInserting) {
      context.missing(_itemnumMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpareCriticality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpareCriticality(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      usage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage'])!,
      leadTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lead_time'])!,
      cost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost'])!,
      assetRPN: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}asset_r_p_n'])!,
      manual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manual'])!,
      manualPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manual_priority'])!,
      newPriority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_priority'])!,
      newRPN: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}new_r_p_n'])!,
      siteid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteid'])!,
      itemnum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}itemnum'])!,
    );
  }

  @override
  $SpareCriticalitysTable createAlias(String alias) {
    return $SpareCriticalitysTable(attachedDatabase, alias);
  }
}

class SpareCriticality extends DataClass
    implements Insertable<SpareCriticality> {
  final String id;
  final int usage;
  final int leadTime;
  final int cost;
  final double assetRPN;
  final bool manual;
  final bool manualPriority;
  final int newPriority;
  final double newRPN;
  final String siteid;
  final String itemnum;
  const SpareCriticality(
      {required this.id,
      required this.usage,
      required this.leadTime,
      required this.cost,
      required this.assetRPN,
      required this.manual,
      required this.manualPriority,
      required this.newPriority,
      required this.newRPN,
      required this.siteid,
      required this.itemnum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['usage'] = Variable<int>(usage);
    map['lead_time'] = Variable<int>(leadTime);
    map['cost'] = Variable<int>(cost);
    map['asset_r_p_n'] = Variable<double>(assetRPN);
    map['manual'] = Variable<bool>(manual);
    map['manual_priority'] = Variable<bool>(manualPriority);
    map['new_priority'] = Variable<int>(newPriority);
    map['new_r_p_n'] = Variable<double>(newRPN);
    map['siteid'] = Variable<String>(siteid);
    map['itemnum'] = Variable<String>(itemnum);
    return map;
  }

  SpareCriticalitysCompanion toCompanion(bool nullToAbsent) {
    return SpareCriticalitysCompanion(
      id: Value(id),
      usage: Value(usage),
      leadTime: Value(leadTime),
      cost: Value(cost),
      assetRPN: Value(assetRPN),
      manual: Value(manual),
      manualPriority: Value(manualPriority),
      newPriority: Value(newPriority),
      newRPN: Value(newRPN),
      siteid: Value(siteid),
      itemnum: Value(itemnum),
    );
  }

  factory SpareCriticality.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpareCriticality(
      id: serializer.fromJson<String>(json['id']),
      usage: serializer.fromJson<int>(json['usage']),
      leadTime: serializer.fromJson<int>(json['leadTime']),
      cost: serializer.fromJson<int>(json['cost']),
      assetRPN: serializer.fromJson<double>(json['assetRPN']),
      manual: serializer.fromJson<bool>(json['manual']),
      manualPriority: serializer.fromJson<bool>(json['manualPriority']),
      newPriority: serializer.fromJson<int>(json['newPriority']),
      newRPN: serializer.fromJson<double>(json['newRPN']),
      siteid: serializer.fromJson<String>(json['siteid']),
      itemnum: serializer.fromJson<String>(json['itemnum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'usage': serializer.toJson<int>(usage),
      'leadTime': serializer.toJson<int>(leadTime),
      'cost': serializer.toJson<int>(cost),
      'assetRPN': serializer.toJson<double>(assetRPN),
      'manual': serializer.toJson<bool>(manual),
      'manualPriority': serializer.toJson<bool>(manualPriority),
      'newPriority': serializer.toJson<int>(newPriority),
      'newRPN': serializer.toJson<double>(newRPN),
      'siteid': serializer.toJson<String>(siteid),
      'itemnum': serializer.toJson<String>(itemnum),
    };
  }

  SpareCriticality copyWith(
          {String? id,
          int? usage,
          int? leadTime,
          int? cost,
          double? assetRPN,
          bool? manual,
          bool? manualPriority,
          int? newPriority,
          double? newRPN,
          String? siteid,
          String? itemnum}) =>
      SpareCriticality(
        id: id ?? this.id,
        usage: usage ?? this.usage,
        leadTime: leadTime ?? this.leadTime,
        cost: cost ?? this.cost,
        assetRPN: assetRPN ?? this.assetRPN,
        manual: manual ?? this.manual,
        manualPriority: manualPriority ?? this.manualPriority,
        newPriority: newPriority ?? this.newPriority,
        newRPN: newRPN ?? this.newRPN,
        siteid: siteid ?? this.siteid,
        itemnum: itemnum ?? this.itemnum,
      );
  @override
  String toString() {
    return (StringBuffer('SpareCriticality(')
          ..write('id: $id, ')
          ..write('usage: $usage, ')
          ..write('leadTime: $leadTime, ')
          ..write('cost: $cost, ')
          ..write('assetRPN: $assetRPN, ')
          ..write('manual: $manual, ')
          ..write('manualPriority: $manualPriority, ')
          ..write('newPriority: $newPriority, ')
          ..write('newRPN: $newRPN, ')
          ..write('siteid: $siteid, ')
          ..write('itemnum: $itemnum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, usage, leadTime, cost, assetRPN, manual,
      manualPriority, newPriority, newRPN, siteid, itemnum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpareCriticality &&
          other.id == this.id &&
          other.usage == this.usage &&
          other.leadTime == this.leadTime &&
          other.cost == this.cost &&
          other.assetRPN == this.assetRPN &&
          other.manual == this.manual &&
          other.manualPriority == this.manualPriority &&
          other.newPriority == this.newPriority &&
          other.newRPN == this.newRPN &&
          other.siteid == this.siteid &&
          other.itemnum == this.itemnum);
}

class SpareCriticalitysCompanion extends UpdateCompanion<SpareCriticality> {
  final Value<String> id;
  final Value<int> usage;
  final Value<int> leadTime;
  final Value<int> cost;
  final Value<double> assetRPN;
  final Value<bool> manual;
  final Value<bool> manualPriority;
  final Value<int> newPriority;
  final Value<double> newRPN;
  final Value<String> siteid;
  final Value<String> itemnum;
  final Value<int> rowid;
  const SpareCriticalitysCompanion({
    this.id = const Value.absent(),
    this.usage = const Value.absent(),
    this.leadTime = const Value.absent(),
    this.cost = const Value.absent(),
    this.assetRPN = const Value.absent(),
    this.manual = const Value.absent(),
    this.manualPriority = const Value.absent(),
    this.newPriority = const Value.absent(),
    this.newRPN = const Value.absent(),
    this.siteid = const Value.absent(),
    this.itemnum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpareCriticalitysCompanion.insert({
    required String id,
    required int usage,
    required int leadTime,
    required int cost,
    required double assetRPN,
    required bool manual,
    required bool manualPriority,
    required int newPriority,
    required double newRPN,
    required String siteid,
    required String itemnum,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        usage = Value(usage),
        leadTime = Value(leadTime),
        cost = Value(cost),
        assetRPN = Value(assetRPN),
        manual = Value(manual),
        manualPriority = Value(manualPriority),
        newPriority = Value(newPriority),
        newRPN = Value(newRPN),
        siteid = Value(siteid),
        itemnum = Value(itemnum);
  static Insertable<SpareCriticality> custom({
    Expression<String>? id,
    Expression<int>? usage,
    Expression<int>? leadTime,
    Expression<int>? cost,
    Expression<double>? assetRPN,
    Expression<bool>? manual,
    Expression<bool>? manualPriority,
    Expression<int>? newPriority,
    Expression<double>? newRPN,
    Expression<String>? siteid,
    Expression<String>? itemnum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usage != null) 'usage': usage,
      if (leadTime != null) 'lead_time': leadTime,
      if (cost != null) 'cost': cost,
      if (assetRPN != null) 'asset_r_p_n': assetRPN,
      if (manual != null) 'manual': manual,
      if (manualPriority != null) 'manual_priority': manualPriority,
      if (newPriority != null) 'new_priority': newPriority,
      if (newRPN != null) 'new_r_p_n': newRPN,
      if (siteid != null) 'siteid': siteid,
      if (itemnum != null) 'itemnum': itemnum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpareCriticalitysCompanion copyWith(
      {Value<String>? id,
      Value<int>? usage,
      Value<int>? leadTime,
      Value<int>? cost,
      Value<double>? assetRPN,
      Value<bool>? manual,
      Value<bool>? manualPriority,
      Value<int>? newPriority,
      Value<double>? newRPN,
      Value<String>? siteid,
      Value<String>? itemnum,
      Value<int>? rowid}) {
    return SpareCriticalitysCompanion(
      id: id ?? this.id,
      usage: usage ?? this.usage,
      leadTime: leadTime ?? this.leadTime,
      cost: cost ?? this.cost,
      assetRPN: assetRPN ?? this.assetRPN,
      manual: manual ?? this.manual,
      manualPriority: manualPriority ?? this.manualPriority,
      newPriority: newPriority ?? this.newPriority,
      newRPN: newRPN ?? this.newRPN,
      siteid: siteid ?? this.siteid,
      itemnum: itemnum ?? this.itemnum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (usage.present) {
      map['usage'] = Variable<int>(usage.value);
    }
    if (leadTime.present) {
      map['lead_time'] = Variable<int>(leadTime.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (assetRPN.present) {
      map['asset_r_p_n'] = Variable<double>(assetRPN.value);
    }
    if (manual.present) {
      map['manual'] = Variable<bool>(manual.value);
    }
    if (manualPriority.present) {
      map['manual_priority'] = Variable<bool>(manualPriority.value);
    }
    if (newPriority.present) {
      map['new_priority'] = Variable<int>(newPriority.value);
    }
    if (newRPN.present) {
      map['new_r_p_n'] = Variable<double>(newRPN.value);
    }
    if (siteid.present) {
      map['siteid'] = Variable<String>(siteid.value);
    }
    if (itemnum.present) {
      map['itemnum'] = Variable<String>(itemnum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpareCriticalitysCompanion(')
          ..write('id: $id, ')
          ..write('usage: $usage, ')
          ..write('leadTime: $leadTime, ')
          ..write('cost: $cost, ')
          ..write('assetRPN: $assetRPN, ')
          ..write('manual: $manual, ')
          ..write('manualPriority: $manualPriority, ')
          ..write('newPriority: $newPriority, ')
          ..write('newRPN: $newRPN, ')
          ..write('siteid: $siteid, ')
          ..write('itemnum: $itemnum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  _$MyDatabaseManager get managers => _$MyDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $LoginSettingsTable loginSettings = $LoginSettingsTable(this);
  late final $MeterDBsTable meterDBs = $MeterDBsTable(this);
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $WorkordersTable workorders = $WorkordersTable(this);
  late final $SystemCriticalitysTable systemCriticalitys =
      $SystemCriticalitysTable(this);
  late final $AssetCriticalitysTable assetCriticalitys =
      $AssetCriticalitysTable(this);
  late final $AssetUploadsTable assetUploads = $AssetUploadsTable(this);
  late final $SparePartsTable spareParts = $SparePartsTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $SpareCriticalitysTable spareCriticalitys =
      $SpareCriticalitysTable(this);
  Selectable<SystemCriticality> systemsFilteredBySite(String? siteid) {
    return customSelect(
        'SELECT * FROM system_criticalitys WHERE line IN (SELECT substr(assetnum, 1, 1) FROM assets WHERE siteid = ?1) AND siteid IS NULL UNION SELECT * FROM system_criticalitys WHERE siteid = ?1',
        variables: [
          Variable<String>(siteid)
        ],
        readsFrom: {
          systemCriticalitys,
          assets,
        }).asyncMap(systemCriticalitys.mapFromRow);
  }

  Selectable<int?> maxSystemID() {
    return customSelect('SELECT max(id) AS _c0 FROM system_criticalitys',
        variables: [],
        readsFrom: {
          systemCriticalitys,
        }).map((QueryRow row) => row.readNullable<int>('_c0'));
  }

  Selectable<AssetCriticality> assetCriticalityOrdered(String siteid) {
    return customSelect(
        'SELECT * FROM asset_criticalitys WHERE substr(asset, 1, 2) = ?1 AND asset NOT IN (SELECT siteid || parent FROM assets WHERE parent IS NOT NULL) ORDER BY new_r_p_n DESC',
        variables: [
          Variable<String>(siteid)
        ],
        readsFrom: {
          assetCriticalitys,
          assets,
        }).asyncMap(assetCriticalitys.mapFromRow);
  }

  Selectable<UniqueRpnNumbersResult> uniqueRpnNumbers(String siteid) {
    return customSelect(
        'SELECT new_r_p_n, count(asset) AS _c0 FROM asset_criticalitys WHERE new_r_p_n > 0 AND asset LIKE ?1 AND asset NOT IN (SELECT siteid || parent FROM assets WHERE parent IS NOT NULL) GROUP BY new_r_p_n',
        variables: [
          Variable<String>(siteid)
        ],
        readsFrom: {
          assetCriticalitys,
          assets,
        }).map((QueryRow row) => UniqueRpnNumbersResult(
          newRPN: row.read<double>('new_r_p_n'),
          countasset: row.read<int>('_c0'),
        ));
  }

  Selectable<UniqueRpnNumbersSpareResult> uniqueRpnNumbersSpare(String siteid) {
    return customSelect(
        'SELECT new_r_p_n, count(itemnum) AS _c0 FROM spare_criticalitys WHERE new_r_p_n > 0 AND siteid = ?1 GROUP BY new_r_p_n',
        variables: [
          Variable<String>(siteid)
        ],
        readsFrom: {
          spareCriticalitys,
        }).map((QueryRow row) => UniqueRpnNumbersSpareResult(
          newRPN: row.read<double>('new_r_p_n'),
          countitemnum: row.read<int>('_c0'),
        ));
  }

  Selectable<SpareCriticalityAssetInfoResult> spareCriticalityAssetInfo(
      String siteid, String itemnum) {
    return customSelect(
        'SELECT DISTINCT(sp.itemnum)AS itemnum, (SELECT sum(quantity) FROM spare_parts AS s1 WHERE s1.itemnum = sp.itemnum AND s1.siteid = sp.siteid) AS quantity, (SELECT max(new_r_p_n) FROM asset_criticalitys WHERE asset IN (SELECT sp.siteid || s2.assetnum FROM spare_parts AS s2 WHERE s2.itemnum = sp.itemnum AND s2.siteid = sp.siteid)) AS assetRPN FROM spare_parts AS sp WHERE sp.siteid = ?1 AND sp.itemnum LIKE ?2',
        variables: [
          Variable<String>(siteid),
          Variable<String>(itemnum)
        ],
        readsFrom: {
          spareParts,
          assetCriticalitys,
        }).map((QueryRow row) => SpareCriticalityAssetInfoResult(
          itemnum: row.read<String>('itemnum'),
          quantity: row.readNullable<double>('quantity'),
          assetRPN: row.readNullable<double>('assetRPN'),
        ));
  }

  Selectable<SpareCriticalityAutoCalculationResult>
      spareCriticalityAutoCalculation(String siteid, String itemnum) {
    return customSelect(
        'SELECT DISTINCT(sp.itemnum)AS itemnum, (SELECT sum(quantity) FROM spare_parts AS s1 WHERE s1.itemnum = sp.itemnum AND s1.siteid = sp.siteid) AS quantity, (SELECT ifnull(avg(pr.unit_cost), -1) FROM purchases AS pr WHERE pr.itemnum = sp.itemnum AND pr.siteid = sp.siteid AND pr.po_status = 1) AS unitCost, (SELECT ifnull(avg(pr.lead_time), -1) FROM purchases AS pr WHERE pr.itemnum = sp.itemnum AND pr.siteid = sp.siteid AND pr.po_status = 1) AS leadTime, (SELECT max(new_r_p_n) FROM asset_criticalitys WHERE asset IN (SELECT sp.siteid || s2.assetnum FROM spare_parts AS s2 WHERE s2.itemnum = sp.itemnum AND s2.siteid = sp.siteid)) AS assetRPN FROM spare_parts AS sp WHERE sp.siteid = ?1 AND sp.itemnum LIKE ?2',
        variables: [
          Variable<String>(siteid),
          Variable<String>(itemnum)
        ],
        readsFrom: {
          spareParts,
          purchases,
          assetCriticalitys,
        }).map((QueryRow row) => SpareCriticalityAutoCalculationResult(
          itemnum: row.read<String>('itemnum'),
          quantity: row.readNullable<double>('quantity'),
          unitCost: row.read<double>('unitCost'),
          leadTime: row.read<double>('leadTime'),
          assetRPN: row.readNullable<double>('assetRPN'),
        ));
  }

  Selectable<AssetsAssociatedWithItemResult> assetsAssociatedWithItem(
      String siteid, String itemnum) {
    return customSelect(
        'SELECT sp.assetnum, a.description, ac.new_r_p_n, sp.quantity FROM spare_parts AS sp LEFT JOIN assets AS a ON sp.assetnum = a.assetnum AND sp.siteid = a.siteid LEFT JOIN asset_criticalitys AS ac ON sp.siteid || sp.assetnum = ac.asset WHERE sp.siteid = ?1 AND sp.itemnum = ?2',
        variables: [
          Variable<String>(siteid),
          Variable<String>(itemnum)
        ],
        readsFrom: {
          spareParts,
          assets,
          assetCriticalitys,
        }).map((QueryRow row) => AssetsAssociatedWithItemResult(
          assetnum: row.read<String>('assetnum'),
          description: row.readNullable<String>('description'),
          newRPN: row.readNullable<double>('new_r_p_n'),
          quantity: row.read<double>('quantity'),
        ));
  }

  Selectable<CompletedAssetRpnResult> completedAssetRpn(String siteid) {
    return customSelect(
        'SELECT count(assetnum) AS totalAssets, count(DISTINCT parent) AS parentAssets, (SELECT count(asset) FROM asset_criticalitys WHERE new_r_p_n > 0 AND asset LIKE ?1 || \'%\' AND asset NOT IN (SELECT DISTINCT ?1 || parent FROM assets WHERE siteid = ?1 AND parent IS NOT NULL)) AS completeChilds FROM assets WHERE siteid = ?1',
        variables: [
          Variable<String>(siteid)
        ],
        readsFrom: {
          assets,
          assetCriticalitys,
        }).map((QueryRow row) => CompletedAssetRpnResult(
          totalAssets: row.read<int>('totalAssets'),
          parentAssets: row.read<int>('parentAssets'),
          completeChilds: row.read<int>('completeChilds'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        settings,
        loginSettings,
        meterDBs,
        observations,
        assets,
        workorders,
        systemCriticalitys,
        assetCriticalitys,
        assetUploads,
        spareParts,
        purchases,
        items,
        spareCriticalitys
      ];
}

typedef $$SettingsTableInsertCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableProcessedTableManager,
    $$SettingsTableInsertCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder> {
  $$SettingsTableTableManager(_$MyDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SettingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SettingsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SettingsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
        ));
}

class $$SettingsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableProcessedTableManager,
    $$SettingsTableInsertCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder> {
  $$SettingsTableProcessedTableManager(super.$state);
}

class $$SettingsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SettingsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$LoginSettingsTableInsertCompanionBuilder = LoginSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$LoginSettingsTableUpdateCompanionBuilder = LoginSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$LoginSettingsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $LoginSettingsTable,
    LoginSetting,
    $$LoginSettingsTableFilterComposer,
    $$LoginSettingsTableOrderingComposer,
    $$LoginSettingsTableProcessedTableManager,
    $$LoginSettingsTableInsertCompanionBuilder,
    $$LoginSettingsTableUpdateCompanionBuilder> {
  $$LoginSettingsTableTableManager(_$MyDatabase db, $LoginSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LoginSettingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LoginSettingsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$LoginSettingsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoginSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              LoginSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
        ));
}

class $$LoginSettingsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $LoginSettingsTable,
    LoginSetting,
    $$LoginSettingsTableFilterComposer,
    $$LoginSettingsTableOrderingComposer,
    $$LoginSettingsTableProcessedTableManager,
    $$LoginSettingsTableInsertCompanionBuilder,
    $$LoginSettingsTableUpdateCompanionBuilder> {
  $$LoginSettingsTableProcessedTableManager(super.$state);
}

class $$LoginSettingsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $LoginSettingsTable> {
  $$LoginSettingsTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$LoginSettingsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $LoginSettingsTable> {
  $$LoginSettingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MeterDBsTableInsertCompanionBuilder = MeterDBsCompanion Function({
  required String meter,
  required String inspect,
  required String description,
  required int frequency,
  required String freqUnit,
  required String condition,
  required String craft,
  Value<int> rowid,
});
typedef $$MeterDBsTableUpdateCompanionBuilder = MeterDBsCompanion Function({
  Value<String> meter,
  Value<String> inspect,
  Value<String> description,
  Value<int> frequency,
  Value<String> freqUnit,
  Value<String> condition,
  Value<String> craft,
  Value<int> rowid,
});

class $$MeterDBsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $MeterDBsTable,
    MeterDB,
    $$MeterDBsTableFilterComposer,
    $$MeterDBsTableOrderingComposer,
    $$MeterDBsTableProcessedTableManager,
    $$MeterDBsTableInsertCompanionBuilder,
    $$MeterDBsTableUpdateCompanionBuilder> {
  $$MeterDBsTableTableManager(_$MyDatabase db, $MeterDBsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MeterDBsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MeterDBsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MeterDBsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> meter = const Value.absent(),
            Value<String> inspect = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<String> freqUnit = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String> craft = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeterDBsCompanion(
            meter: meter,
            inspect: inspect,
            description: description,
            frequency: frequency,
            freqUnit: freqUnit,
            condition: condition,
            craft: craft,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String meter,
            required String inspect,
            required String description,
            required int frequency,
            required String freqUnit,
            required String condition,
            required String craft,
            Value<int> rowid = const Value.absent(),
          }) =>
              MeterDBsCompanion.insert(
            meter: meter,
            inspect: inspect,
            description: description,
            frequency: frequency,
            freqUnit: freqUnit,
            condition: condition,
            craft: craft,
            rowid: rowid,
          ),
        ));
}

class $$MeterDBsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $MeterDBsTable,
    MeterDB,
    $$MeterDBsTableFilterComposer,
    $$MeterDBsTableOrderingComposer,
    $$MeterDBsTableProcessedTableManager,
    $$MeterDBsTableInsertCompanionBuilder,
    $$MeterDBsTableUpdateCompanionBuilder> {
  $$MeterDBsTableProcessedTableManager(super.$state);
}

class $$MeterDBsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $MeterDBsTable> {
  $$MeterDBsTableFilterComposer(super.$state);
  ColumnFilters<String> get meter => $state.composableBuilder(
      column: $state.table.meter,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get inspect => $state.composableBuilder(
      column: $state.table.inspect,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get freqUnit => $state.composableBuilder(
      column: $state.table.freqUnit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get condition => $state.composableBuilder(
      column: $state.table.condition,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get craft => $state.composableBuilder(
      column: $state.table.craft,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MeterDBsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $MeterDBsTable> {
  $$MeterDBsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get meter => $state.composableBuilder(
      column: $state.table.meter,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get inspect => $state.composableBuilder(
      column: $state.table.inspect,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get freqUnit => $state.composableBuilder(
      column: $state.table.freqUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get condition => $state.composableBuilder(
      column: $state.table.condition,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get craft => $state.composableBuilder(
      column: $state.table.craft,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ObservationsTableInsertCompanionBuilder = ObservationsCompanion
    Function({
  required String meter,
  required String code,
  required String description,
  Value<String?> action,
  Value<int> rowid,
});
typedef $$ObservationsTableUpdateCompanionBuilder = ObservationsCompanion
    Function({
  Value<String> meter,
  Value<String> code,
  Value<String> description,
  Value<String?> action,
  Value<int> rowid,
});

class $$ObservationsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $ObservationsTable,
    Observation,
    $$ObservationsTableFilterComposer,
    $$ObservationsTableOrderingComposer,
    $$ObservationsTableProcessedTableManager,
    $$ObservationsTableInsertCompanionBuilder,
    $$ObservationsTableUpdateCompanionBuilder> {
  $$ObservationsTableTableManager(_$MyDatabase db, $ObservationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ObservationsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ObservationsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ObservationsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> meter = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> action = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ObservationsCompanion(
            meter: meter,
            code: code,
            description: description,
            action: action,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String meter,
            required String code,
            required String description,
            Value<String?> action = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ObservationsCompanion.insert(
            meter: meter,
            code: code,
            description: description,
            action: action,
            rowid: rowid,
          ),
        ));
}

class $$ObservationsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $ObservationsTable,
    Observation,
    $$ObservationsTableFilterComposer,
    $$ObservationsTableOrderingComposer,
    $$ObservationsTableProcessedTableManager,
    $$ObservationsTableInsertCompanionBuilder,
    $$ObservationsTableUpdateCompanionBuilder> {
  $$ObservationsTableProcessedTableManager(super.$state);
}

class $$ObservationsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer(super.$state);
  ColumnFilters<String> get meter => $state.composableBuilder(
      column: $state.table.meter,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ObservationsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get meter => $state.composableBuilder(
      column: $state.table.meter,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AssetsTableInsertCompanionBuilder = AssetsCompanion Function({
  required String assetnum,
  required String description,
  required String status,
  required String siteid,
  required String changedate,
  Value<String?> hierarchy,
  Value<String?> parent,
  required int priority,
  required String id,
  Value<int> newAsset,
  Value<int> rowid,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<String> assetnum,
  Value<String> description,
  Value<String> status,
  Value<String> siteid,
  Value<String> changedate,
  Value<String?> hierarchy,
  Value<String?> parent,
  Value<int> priority,
  Value<String> id,
  Value<int> newAsset,
  Value<int> rowid,
});

class $$AssetsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $AssetsTable,
    Asset,
    $$AssetsTableFilterComposer,
    $$AssetsTableOrderingComposer,
    $$AssetsTableProcessedTableManager,
    $$AssetsTableInsertCompanionBuilder,
    $$AssetsTableUpdateCompanionBuilder> {
  $$AssetsTableTableManager(_$MyDatabase db, $AssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AssetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AssetsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$AssetsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> assetnum = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> siteid = const Value.absent(),
            Value<String> changedate = const Value.absent(),
            Value<String?> hierarchy = const Value.absent(),
            Value<String?> parent = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<int> newAsset = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetsCompanion(
            assetnum: assetnum,
            description: description,
            status: status,
            siteid: siteid,
            changedate: changedate,
            hierarchy: hierarchy,
            parent: parent,
            priority: priority,
            id: id,
            newAsset: newAsset,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String assetnum,
            required String description,
            required String status,
            required String siteid,
            required String changedate,
            Value<String?> hierarchy = const Value.absent(),
            Value<String?> parent = const Value.absent(),
            required int priority,
            required String id,
            Value<int> newAsset = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetsCompanion.insert(
            assetnum: assetnum,
            description: description,
            status: status,
            siteid: siteid,
            changedate: changedate,
            hierarchy: hierarchy,
            parent: parent,
            priority: priority,
            id: id,
            newAsset: newAsset,
            rowid: rowid,
          ),
        ));
}

class $$AssetsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $AssetsTable,
    Asset,
    $$AssetsTableFilterComposer,
    $$AssetsTableOrderingComposer,
    $$AssetsTableProcessedTableManager,
    $$AssetsTableInsertCompanionBuilder,
    $$AssetsTableUpdateCompanionBuilder> {
  $$AssetsTableProcessedTableManager(super.$state);
}

class $$AssetsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer(super.$state);
  ColumnFilters<String> get assetnum => $state.composableBuilder(
      column: $state.table.assetnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get changedate => $state.composableBuilder(
      column: $state.table.changedate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get hierarchy => $state.composableBuilder(
      column: $state.table.hierarchy,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get parent => $state.composableBuilder(
      column: $state.table.parent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get priority => $state.composableBuilder(
      column: $state.table.priority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get newAsset => $state.composableBuilder(
      column: $state.table.newAsset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter assetCriticalitysRefs(
      ComposableFilter Function($$AssetCriticalitysTableFilterComposer f) f) {
    final $$AssetCriticalitysTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.assetCriticalitys,
            getReferencedColumn: (t) => t.asset,
            builder: (joinBuilder, parentComposers) =>
                $$AssetCriticalitysTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.assetCriticalitys,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter assetUploadsRefs(
      ComposableFilter Function($$AssetUploadsTableFilterComposer f) f) {
    final $$AssetUploadsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.assetUploads,
        getReferencedColumn: (t) => t.asset,
        builder: (joinBuilder, parentComposers) =>
            $$AssetUploadsTableFilterComposer(ComposerState($state.db,
                $state.db.assetUploads, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$AssetsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get assetnum => $state.composableBuilder(
      column: $state.table.assetnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get changedate => $state.composableBuilder(
      column: $state.table.changedate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get hierarchy => $state.composableBuilder(
      column: $state.table.hierarchy,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parent => $state.composableBuilder(
      column: $state.table.parent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get priority => $state.composableBuilder(
      column: $state.table.priority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get newAsset => $state.composableBuilder(
      column: $state.table.newAsset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WorkordersTableInsertCompanionBuilder = WorkordersCompanion Function({
  required String wonum,
  required String description,
  required String status,
  required String siteid,
  required String reportdate,
  required double downtime,
  required String type,
  required String assetnum,
  Value<String?> details,
  Value<String?> recordType,
  Value<int> rowid,
});
typedef $$WorkordersTableUpdateCompanionBuilder = WorkordersCompanion Function({
  Value<String> wonum,
  Value<String> description,
  Value<String> status,
  Value<String> siteid,
  Value<String> reportdate,
  Value<double> downtime,
  Value<String> type,
  Value<String> assetnum,
  Value<String?> details,
  Value<String?> recordType,
  Value<int> rowid,
});

class $$WorkordersTableTableManager extends RootTableManager<
    _$MyDatabase,
    $WorkordersTable,
    Workorder,
    $$WorkordersTableFilterComposer,
    $$WorkordersTableOrderingComposer,
    $$WorkordersTableProcessedTableManager,
    $$WorkordersTableInsertCompanionBuilder,
    $$WorkordersTableUpdateCompanionBuilder> {
  $$WorkordersTableTableManager(_$MyDatabase db, $WorkordersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WorkordersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WorkordersTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$WorkordersTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> wonum = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> siteid = const Value.absent(),
            Value<String> reportdate = const Value.absent(),
            Value<double> downtime = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> assetnum = const Value.absent(),
            Value<String?> details = const Value.absent(),
            Value<String?> recordType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkordersCompanion(
            wonum: wonum,
            description: description,
            status: status,
            siteid: siteid,
            reportdate: reportdate,
            downtime: downtime,
            type: type,
            assetnum: assetnum,
            details: details,
            recordType: recordType,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String wonum,
            required String description,
            required String status,
            required String siteid,
            required String reportdate,
            required double downtime,
            required String type,
            required String assetnum,
            Value<String?> details = const Value.absent(),
            Value<String?> recordType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkordersCompanion.insert(
            wonum: wonum,
            description: description,
            status: status,
            siteid: siteid,
            reportdate: reportdate,
            downtime: downtime,
            type: type,
            assetnum: assetnum,
            details: details,
            recordType: recordType,
            rowid: rowid,
          ),
        ));
}

class $$WorkordersTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $WorkordersTable,
    Workorder,
    $$WorkordersTableFilterComposer,
    $$WorkordersTableOrderingComposer,
    $$WorkordersTableProcessedTableManager,
    $$WorkordersTableInsertCompanionBuilder,
    $$WorkordersTableUpdateCompanionBuilder> {
  $$WorkordersTableProcessedTableManager(super.$state);
}

class $$WorkordersTableFilterComposer
    extends FilterComposer<_$MyDatabase, $WorkordersTable> {
  $$WorkordersTableFilterComposer(super.$state);
  ColumnFilters<String> get wonum => $state.composableBuilder(
      column: $state.table.wonum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get reportdate => $state.composableBuilder(
      column: $state.table.reportdate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get downtime => $state.composableBuilder(
      column: $state.table.downtime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get assetnum => $state.composableBuilder(
      column: $state.table.assetnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get details => $state.composableBuilder(
      column: $state.table.details,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recordType => $state.composableBuilder(
      column: $state.table.recordType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WorkordersTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $WorkordersTable> {
  $$WorkordersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get wonum => $state.composableBuilder(
      column: $state.table.wonum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get reportdate => $state.composableBuilder(
      column: $state.table.reportdate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get downtime => $state.composableBuilder(
      column: $state.table.downtime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get assetnum => $state.composableBuilder(
      column: $state.table.assetnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get details => $state.composableBuilder(
      column: $state.table.details,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recordType => $state.composableBuilder(
      column: $state.table.recordType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SystemCriticalitysTableInsertCompanionBuilder
    = SystemCriticalitysCompanion Function({
  Value<int> id,
  required String description,
  Value<String?> siteid,
  Value<int> safety,
  Value<int> regulatory,
  Value<int> economic,
  Value<int> throughput,
  Value<int> quality,
  required String line,
  Value<double> score,
});
typedef $$SystemCriticalitysTableUpdateCompanionBuilder
    = SystemCriticalitysCompanion Function({
  Value<int> id,
  Value<String> description,
  Value<String?> siteid,
  Value<int> safety,
  Value<int> regulatory,
  Value<int> economic,
  Value<int> throughput,
  Value<int> quality,
  Value<String> line,
  Value<double> score,
});

class $$SystemCriticalitysTableTableManager extends RootTableManager<
    _$MyDatabase,
    $SystemCriticalitysTable,
    SystemCriticality,
    $$SystemCriticalitysTableFilterComposer,
    $$SystemCriticalitysTableOrderingComposer,
    $$SystemCriticalitysTableProcessedTableManager,
    $$SystemCriticalitysTableInsertCompanionBuilder,
    $$SystemCriticalitysTableUpdateCompanionBuilder> {
  $$SystemCriticalitysTableTableManager(
      _$MyDatabase db, $SystemCriticalitysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SystemCriticalitysTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$SystemCriticalitysTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SystemCriticalitysTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> siteid = const Value.absent(),
            Value<int> safety = const Value.absent(),
            Value<int> regulatory = const Value.absent(),
            Value<int> economic = const Value.absent(),
            Value<int> throughput = const Value.absent(),
            Value<int> quality = const Value.absent(),
            Value<String> line = const Value.absent(),
            Value<double> score = const Value.absent(),
          }) =>
              SystemCriticalitysCompanion(
            id: id,
            description: description,
            siteid: siteid,
            safety: safety,
            regulatory: regulatory,
            economic: economic,
            throughput: throughput,
            quality: quality,
            line: line,
            score: score,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String description,
            Value<String?> siteid = const Value.absent(),
            Value<int> safety = const Value.absent(),
            Value<int> regulatory = const Value.absent(),
            Value<int> economic = const Value.absent(),
            Value<int> throughput = const Value.absent(),
            Value<int> quality = const Value.absent(),
            required String line,
            Value<double> score = const Value.absent(),
          }) =>
              SystemCriticalitysCompanion.insert(
            id: id,
            description: description,
            siteid: siteid,
            safety: safety,
            regulatory: regulatory,
            economic: economic,
            throughput: throughput,
            quality: quality,
            line: line,
            score: score,
          ),
        ));
}

class $$SystemCriticalitysTableProcessedTableManager
    extends ProcessedTableManager<
        _$MyDatabase,
        $SystemCriticalitysTable,
        SystemCriticality,
        $$SystemCriticalitysTableFilterComposer,
        $$SystemCriticalitysTableOrderingComposer,
        $$SystemCriticalitysTableProcessedTableManager,
        $$SystemCriticalitysTableInsertCompanionBuilder,
        $$SystemCriticalitysTableUpdateCompanionBuilder> {
  $$SystemCriticalitysTableProcessedTableManager(super.$state);
}

class $$SystemCriticalitysTableFilterComposer
    extends FilterComposer<_$MyDatabase, $SystemCriticalitysTable> {
  $$SystemCriticalitysTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get safety => $state.composableBuilder(
      column: $state.table.safety,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get regulatory => $state.composableBuilder(
      column: $state.table.regulatory,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get economic => $state.composableBuilder(
      column: $state.table.economic,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get throughput => $state.composableBuilder(
      column: $state.table.throughput,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quality => $state.composableBuilder(
      column: $state.table.quality,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get line => $state.composableBuilder(
      column: $state.table.line,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter assetCriticalitysRefs(
      ComposableFilter Function($$AssetCriticalitysTableFilterComposer f) f) {
    final $$AssetCriticalitysTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.assetCriticalitys,
            getReferencedColumn: (t) => t.system,
            builder: (joinBuilder, parentComposers) =>
                $$AssetCriticalitysTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.assetCriticalitys,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$SystemCriticalitysTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $SystemCriticalitysTable> {
  $$SystemCriticalitysTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get safety => $state.composableBuilder(
      column: $state.table.safety,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get regulatory => $state.composableBuilder(
      column: $state.table.regulatory,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get economic => $state.composableBuilder(
      column: $state.table.economic,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get throughput => $state.composableBuilder(
      column: $state.table.throughput,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quality => $state.composableBuilder(
      column: $state.table.quality,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get line => $state.composableBuilder(
      column: $state.table.line,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AssetCriticalitysTableInsertCompanionBuilder
    = AssetCriticalitysCompanion Function({
  required String asset,
  required int system,
  required String type,
  required int frequency,
  required int downtime,
  Value<double> earlyDetection,
  Value<bool> manual,
  Value<bool> manualPriority,
  Value<int?> newPriority,
  Value<double> newRPN,
  Value<bool> lockedSystem,
  Value<int> rowid,
});
typedef $$AssetCriticalitysTableUpdateCompanionBuilder
    = AssetCriticalitysCompanion Function({
  Value<String> asset,
  Value<int> system,
  Value<String> type,
  Value<int> frequency,
  Value<int> downtime,
  Value<double> earlyDetection,
  Value<bool> manual,
  Value<bool> manualPriority,
  Value<int?> newPriority,
  Value<double> newRPN,
  Value<bool> lockedSystem,
  Value<int> rowid,
});

class $$AssetCriticalitysTableTableManager extends RootTableManager<
    _$MyDatabase,
    $AssetCriticalitysTable,
    AssetCriticality,
    $$AssetCriticalitysTableFilterComposer,
    $$AssetCriticalitysTableOrderingComposer,
    $$AssetCriticalitysTableProcessedTableManager,
    $$AssetCriticalitysTableInsertCompanionBuilder,
    $$AssetCriticalitysTableUpdateCompanionBuilder> {
  $$AssetCriticalitysTableTableManager(
      _$MyDatabase db, $AssetCriticalitysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AssetCriticalitysTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$AssetCriticalitysTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$AssetCriticalitysTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> asset = const Value.absent(),
            Value<int> system = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<int> downtime = const Value.absent(),
            Value<double> earlyDetection = const Value.absent(),
            Value<bool> manual = const Value.absent(),
            Value<bool> manualPriority = const Value.absent(),
            Value<int?> newPriority = const Value.absent(),
            Value<double> newRPN = const Value.absent(),
            Value<bool> lockedSystem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetCriticalitysCompanion(
            asset: asset,
            system: system,
            type: type,
            frequency: frequency,
            downtime: downtime,
            earlyDetection: earlyDetection,
            manual: manual,
            manualPriority: manualPriority,
            newPriority: newPriority,
            newRPN: newRPN,
            lockedSystem: lockedSystem,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String asset,
            required int system,
            required String type,
            required int frequency,
            required int downtime,
            Value<double> earlyDetection = const Value.absent(),
            Value<bool> manual = const Value.absent(),
            Value<bool> manualPriority = const Value.absent(),
            Value<int?> newPriority = const Value.absent(),
            Value<double> newRPN = const Value.absent(),
            Value<bool> lockedSystem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetCriticalitysCompanion.insert(
            asset: asset,
            system: system,
            type: type,
            frequency: frequency,
            downtime: downtime,
            earlyDetection: earlyDetection,
            manual: manual,
            manualPriority: manualPriority,
            newPriority: newPriority,
            newRPN: newRPN,
            lockedSystem: lockedSystem,
            rowid: rowid,
          ),
        ));
}

class $$AssetCriticalitysTableProcessedTableManager
    extends ProcessedTableManager<
        _$MyDatabase,
        $AssetCriticalitysTable,
        AssetCriticality,
        $$AssetCriticalitysTableFilterComposer,
        $$AssetCriticalitysTableOrderingComposer,
        $$AssetCriticalitysTableProcessedTableManager,
        $$AssetCriticalitysTableInsertCompanionBuilder,
        $$AssetCriticalitysTableUpdateCompanionBuilder> {
  $$AssetCriticalitysTableProcessedTableManager(super.$state);
}

class $$AssetCriticalitysTableFilterComposer
    extends FilterComposer<_$MyDatabase, $AssetCriticalitysTable> {
  $$AssetCriticalitysTableFilterComposer(super.$state);
  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get downtime => $state.composableBuilder(
      column: $state.table.downtime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get earlyDetection => $state.composableBuilder(
      column: $state.table.earlyDetection,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get manual => $state.composableBuilder(
      column: $state.table.manual,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get manualPriority => $state.composableBuilder(
      column: $state.table.manualPriority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get newPriority => $state.composableBuilder(
      column: $state.table.newPriority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get newRPN => $state.composableBuilder(
      column: $state.table.newRPN,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get lockedSystem => $state.composableBuilder(
      column: $state.table.lockedSystem,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$AssetsTableFilterComposer get asset {
    final $$AssetsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.asset,
        referencedTable: $state.db.assets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$AssetsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.assets, joinBuilder, parentComposers)));
    return composer;
  }

  $$SystemCriticalitysTableFilterComposer get system {
    final $$SystemCriticalitysTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.system,
            referencedTable: $state.db.systemCriticalitys,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$SystemCriticalitysTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.systemCriticalitys,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $$AssetCriticalitysTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $AssetCriticalitysTable> {
  $$AssetCriticalitysTableOrderingComposer(super.$state);
  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get frequency => $state.composableBuilder(
      column: $state.table.frequency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get downtime => $state.composableBuilder(
      column: $state.table.downtime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get earlyDetection => $state.composableBuilder(
      column: $state.table.earlyDetection,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get manual => $state.composableBuilder(
      column: $state.table.manual,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get manualPriority => $state.composableBuilder(
      column: $state.table.manualPriority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get newPriority => $state.composableBuilder(
      column: $state.table.newPriority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get newRPN => $state.composableBuilder(
      column: $state.table.newRPN,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get lockedSystem => $state.composableBuilder(
      column: $state.table.lockedSystem,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AssetsTableOrderingComposer get asset {
    final $$AssetsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.asset,
        referencedTable: $state.db.assets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AssetsTableOrderingComposer(ComposerState(
                $state.db, $state.db.assets, joinBuilder, parentComposers)));
    return composer;
  }

  $$SystemCriticalitysTableOrderingComposer get system {
    final $$SystemCriticalitysTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.system,
            referencedTable: $state.db.systemCriticalitys,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$SystemCriticalitysTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.systemCriticalitys,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

typedef $$AssetUploadsTableInsertCompanionBuilder = AssetUploadsCompanion
    Function({
  required String asset,
  Value<String?> sjpDescription,
  Value<String?> installationDate,
  Value<String?> vendor,
  Value<String?> manufacturer,
  Value<String?> modelNum,
  Value<int?> assetCriticality,
  Value<int> rowid,
});
typedef $$AssetUploadsTableUpdateCompanionBuilder = AssetUploadsCompanion
    Function({
  Value<String> asset,
  Value<String?> sjpDescription,
  Value<String?> installationDate,
  Value<String?> vendor,
  Value<String?> manufacturer,
  Value<String?> modelNum,
  Value<int?> assetCriticality,
  Value<int> rowid,
});

class $$AssetUploadsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $AssetUploadsTable,
    AssetUpload,
    $$AssetUploadsTableFilterComposer,
    $$AssetUploadsTableOrderingComposer,
    $$AssetUploadsTableProcessedTableManager,
    $$AssetUploadsTableInsertCompanionBuilder,
    $$AssetUploadsTableUpdateCompanionBuilder> {
  $$AssetUploadsTableTableManager(_$MyDatabase db, $AssetUploadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AssetUploadsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AssetUploadsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$AssetUploadsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> asset = const Value.absent(),
            Value<String?> sjpDescription = const Value.absent(),
            Value<String?> installationDate = const Value.absent(),
            Value<String?> vendor = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> modelNum = const Value.absent(),
            Value<int?> assetCriticality = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetUploadsCompanion(
            asset: asset,
            sjpDescription: sjpDescription,
            installationDate: installationDate,
            vendor: vendor,
            manufacturer: manufacturer,
            modelNum: modelNum,
            assetCriticality: assetCriticality,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String asset,
            Value<String?> sjpDescription = const Value.absent(),
            Value<String?> installationDate = const Value.absent(),
            Value<String?> vendor = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> modelNum = const Value.absent(),
            Value<int?> assetCriticality = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetUploadsCompanion.insert(
            asset: asset,
            sjpDescription: sjpDescription,
            installationDate: installationDate,
            vendor: vendor,
            manufacturer: manufacturer,
            modelNum: modelNum,
            assetCriticality: assetCriticality,
            rowid: rowid,
          ),
        ));
}

class $$AssetUploadsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $AssetUploadsTable,
    AssetUpload,
    $$AssetUploadsTableFilterComposer,
    $$AssetUploadsTableOrderingComposer,
    $$AssetUploadsTableProcessedTableManager,
    $$AssetUploadsTableInsertCompanionBuilder,
    $$AssetUploadsTableUpdateCompanionBuilder> {
  $$AssetUploadsTableProcessedTableManager(super.$state);
}

class $$AssetUploadsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $AssetUploadsTable> {
  $$AssetUploadsTableFilterComposer(super.$state);
  ColumnFilters<String> get sjpDescription => $state.composableBuilder(
      column: $state.table.sjpDescription,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get installationDate => $state.composableBuilder(
      column: $state.table.installationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get vendor => $state.composableBuilder(
      column: $state.table.vendor,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get manufacturer => $state.composableBuilder(
      column: $state.table.manufacturer,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get modelNum => $state.composableBuilder(
      column: $state.table.modelNum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get assetCriticality => $state.composableBuilder(
      column: $state.table.assetCriticality,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$AssetsTableFilterComposer get asset {
    final $$AssetsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.asset,
        referencedTable: $state.db.assets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$AssetsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.assets, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$AssetUploadsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $AssetUploadsTable> {
  $$AssetUploadsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get sjpDescription => $state.composableBuilder(
      column: $state.table.sjpDescription,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get installationDate => $state.composableBuilder(
      column: $state.table.installationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get vendor => $state.composableBuilder(
      column: $state.table.vendor,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get manufacturer => $state.composableBuilder(
      column: $state.table.manufacturer,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get modelNum => $state.composableBuilder(
      column: $state.table.modelNum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get assetCriticality => $state.composableBuilder(
      column: $state.table.assetCriticality,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AssetsTableOrderingComposer get asset {
    final $$AssetsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.asset,
        referencedTable: $state.db.assets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AssetsTableOrderingComposer(ComposerState(
                $state.db, $state.db.assets, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$SparePartsTableInsertCompanionBuilder = SparePartsCompanion Function({
  required String itemnum,
  required String assetnum,
  required String siteid,
  required double quantity,
  Value<int> sparepartid,
});
typedef $$SparePartsTableUpdateCompanionBuilder = SparePartsCompanion Function({
  Value<String> itemnum,
  Value<String> assetnum,
  Value<String> siteid,
  Value<double> quantity,
  Value<int> sparepartid,
});

class $$SparePartsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $SparePartsTable,
    SparePart,
    $$SparePartsTableFilterComposer,
    $$SparePartsTableOrderingComposer,
    $$SparePartsTableProcessedTableManager,
    $$SparePartsTableInsertCompanionBuilder,
    $$SparePartsTableUpdateCompanionBuilder> {
  $$SparePartsTableTableManager(_$MyDatabase db, $SparePartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SparePartsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SparePartsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SparePartsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> itemnum = const Value.absent(),
            Value<String> assetnum = const Value.absent(),
            Value<String> siteid = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<int> sparepartid = const Value.absent(),
          }) =>
              SparePartsCompanion(
            itemnum: itemnum,
            assetnum: assetnum,
            siteid: siteid,
            quantity: quantity,
            sparepartid: sparepartid,
          ),
          getInsertCompanionBuilder: ({
            required String itemnum,
            required String assetnum,
            required String siteid,
            required double quantity,
            Value<int> sparepartid = const Value.absent(),
          }) =>
              SparePartsCompanion.insert(
            itemnum: itemnum,
            assetnum: assetnum,
            siteid: siteid,
            quantity: quantity,
            sparepartid: sparepartid,
          ),
        ));
}

class $$SparePartsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $SparePartsTable,
    SparePart,
    $$SparePartsTableFilterComposer,
    $$SparePartsTableOrderingComposer,
    $$SparePartsTableProcessedTableManager,
    $$SparePartsTableInsertCompanionBuilder,
    $$SparePartsTableUpdateCompanionBuilder> {
  $$SparePartsTableProcessedTableManager(super.$state);
}

class $$SparePartsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $SparePartsTable> {
  $$SparePartsTableFilterComposer(super.$state);
  ColumnFilters<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get assetnum => $state.composableBuilder(
      column: $state.table.assetnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sparepartid => $state.composableBuilder(
      column: $state.table.sparepartid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SparePartsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $SparePartsTable> {
  $$SparePartsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get assetnum => $state.composableBuilder(
      column: $state.table.assetnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sparepartid => $state.composableBuilder(
      column: $state.table.sparepartid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PurchasesTableInsertCompanionBuilder = PurchasesCompanion Function({
  required String prnum,
  required String prDescription,
  required String poDescription,
  Value<String?> ponum,
  required String startDate,
  required String siteid,
  Value<String?> endDate,
  required double leadTime,
  required String itemnum,
  required double unitCost,
  required bool poStatus,
  Value<int> prlineid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> prnum,
  Value<String> prDescription,
  Value<String> poDescription,
  Value<String?> ponum,
  Value<String> startDate,
  Value<String> siteid,
  Value<String?> endDate,
  Value<double> leadTime,
  Value<String> itemnum,
  Value<double> unitCost,
  Value<bool> poStatus,
  Value<int> prlineid,
});

class $$PurchasesTableTableManager extends RootTableManager<
    _$MyDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableProcessedTableManager,
    $$PurchasesTableInsertCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder> {
  $$PurchasesTableTableManager(_$MyDatabase db, $PurchasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PurchasesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PurchasesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$PurchasesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> prnum = const Value.absent(),
            Value<String> prDescription = const Value.absent(),
            Value<String> poDescription = const Value.absent(),
            Value<String?> ponum = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String> siteid = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<double> leadTime = const Value.absent(),
            Value<String> itemnum = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<bool> poStatus = const Value.absent(),
            Value<int> prlineid = const Value.absent(),
          }) =>
              PurchasesCompanion(
            prnum: prnum,
            prDescription: prDescription,
            poDescription: poDescription,
            ponum: ponum,
            startDate: startDate,
            siteid: siteid,
            endDate: endDate,
            leadTime: leadTime,
            itemnum: itemnum,
            unitCost: unitCost,
            poStatus: poStatus,
            prlineid: prlineid,
          ),
          getInsertCompanionBuilder: ({
            required String prnum,
            required String prDescription,
            required String poDescription,
            Value<String?> ponum = const Value.absent(),
            required String startDate,
            required String siteid,
            Value<String?> endDate = const Value.absent(),
            required double leadTime,
            required String itemnum,
            required double unitCost,
            required bool poStatus,
            Value<int> prlineid = const Value.absent(),
          }) =>
              PurchasesCompanion.insert(
            prnum: prnum,
            prDescription: prDescription,
            poDescription: poDescription,
            ponum: ponum,
            startDate: startDate,
            siteid: siteid,
            endDate: endDate,
            leadTime: leadTime,
            itemnum: itemnum,
            unitCost: unitCost,
            poStatus: poStatus,
            prlineid: prlineid,
          ),
        ));
}

class $$PurchasesTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableProcessedTableManager,
    $$PurchasesTableInsertCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder> {
  $$PurchasesTableProcessedTableManager(super.$state);
}

class $$PurchasesTableFilterComposer
    extends FilterComposer<_$MyDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer(super.$state);
  ColumnFilters<String> get prnum => $state.composableBuilder(
      column: $state.table.prnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get prDescription => $state.composableBuilder(
      column: $state.table.prDescription,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get poDescription => $state.composableBuilder(
      column: $state.table.poDescription,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get ponum => $state.composableBuilder(
      column: $state.table.ponum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get leadTime => $state.composableBuilder(
      column: $state.table.leadTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get unitCost => $state.composableBuilder(
      column: $state.table.unitCost,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get poStatus => $state.composableBuilder(
      column: $state.table.poStatus,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get prlineid => $state.composableBuilder(
      column: $state.table.prlineid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PurchasesTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get prnum => $state.composableBuilder(
      column: $state.table.prnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get prDescription => $state.composableBuilder(
      column: $state.table.prDescription,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get poDescription => $state.composableBuilder(
      column: $state.table.poDescription,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get ponum => $state.composableBuilder(
      column: $state.table.ponum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get leadTime => $state.composableBuilder(
      column: $state.table.leadTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get unitCost => $state.composableBuilder(
      column: $state.table.unitCost,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get poStatus => $state.composableBuilder(
      column: $state.table.poStatus,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get prlineid => $state.composableBuilder(
      column: $state.table.prlineid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ItemsTableInsertCompanionBuilder = ItemsCompanion Function({
  required String itemnum,
  required String description,
  required String status,
  required String commodityGroup,
  required String glClass,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> itemnum,
  Value<String> description,
  Value<String> status,
  Value<String> commodityGroup,
  Value<String> glClass,
  Value<int> rowid,
});

class $$ItemsTableTableManager extends RootTableManager<
    _$MyDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableProcessedTableManager,
    $$ItemsTableInsertCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder> {
  $$ItemsTableTableManager(_$MyDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$ItemsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> itemnum = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> commodityGroup = const Value.absent(),
            Value<String> glClass = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            itemnum: itemnum,
            description: description,
            status: status,
            commodityGroup: commodityGroup,
            glClass: glClass,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String itemnum,
            required String description,
            required String status,
            required String commodityGroup,
            required String glClass,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            itemnum: itemnum,
            description: description,
            status: status,
            commodityGroup: commodityGroup,
            glClass: glClass,
            rowid: rowid,
          ),
        ));
}

class $$ItemsTableProcessedTableManager extends ProcessedTableManager<
    _$MyDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableProcessedTableManager,
    $$ItemsTableInsertCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder> {
  $$ItemsTableProcessedTableManager(super.$state);
}

class $$ItemsTableFilterComposer
    extends FilterComposer<_$MyDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get commodityGroup => $state.composableBuilder(
      column: $state.table.commodityGroup,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get glClass => $state.composableBuilder(
      column: $state.table.glClass,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ItemsTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get commodityGroup => $state.composableBuilder(
      column: $state.table.commodityGroup,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get glClass => $state.composableBuilder(
      column: $state.table.glClass,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SpareCriticalitysTableInsertCompanionBuilder
    = SpareCriticalitysCompanion Function({
  required String id,
  required int usage,
  required int leadTime,
  required int cost,
  required double assetRPN,
  required bool manual,
  required bool manualPriority,
  required int newPriority,
  required double newRPN,
  required String siteid,
  required String itemnum,
  Value<int> rowid,
});
typedef $$SpareCriticalitysTableUpdateCompanionBuilder
    = SpareCriticalitysCompanion Function({
  Value<String> id,
  Value<int> usage,
  Value<int> leadTime,
  Value<int> cost,
  Value<double> assetRPN,
  Value<bool> manual,
  Value<bool> manualPriority,
  Value<int> newPriority,
  Value<double> newRPN,
  Value<String> siteid,
  Value<String> itemnum,
  Value<int> rowid,
});

class $$SpareCriticalitysTableTableManager extends RootTableManager<
    _$MyDatabase,
    $SpareCriticalitysTable,
    SpareCriticality,
    $$SpareCriticalitysTableFilterComposer,
    $$SpareCriticalitysTableOrderingComposer,
    $$SpareCriticalitysTableProcessedTableManager,
    $$SpareCriticalitysTableInsertCompanionBuilder,
    $$SpareCriticalitysTableUpdateCompanionBuilder> {
  $$SpareCriticalitysTableTableManager(
      _$MyDatabase db, $SpareCriticalitysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SpareCriticalitysTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$SpareCriticalitysTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SpareCriticalitysTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<int> usage = const Value.absent(),
            Value<int> leadTime = const Value.absent(),
            Value<int> cost = const Value.absent(),
            Value<double> assetRPN = const Value.absent(),
            Value<bool> manual = const Value.absent(),
            Value<bool> manualPriority = const Value.absent(),
            Value<int> newPriority = const Value.absent(),
            Value<double> newRPN = const Value.absent(),
            Value<String> siteid = const Value.absent(),
            Value<String> itemnum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpareCriticalitysCompanion(
            id: id,
            usage: usage,
            leadTime: leadTime,
            cost: cost,
            assetRPN: assetRPN,
            manual: manual,
            manualPriority: manualPriority,
            newPriority: newPriority,
            newRPN: newRPN,
            siteid: siteid,
            itemnum: itemnum,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required int usage,
            required int leadTime,
            required int cost,
            required double assetRPN,
            required bool manual,
            required bool manualPriority,
            required int newPriority,
            required double newRPN,
            required String siteid,
            required String itemnum,
            Value<int> rowid = const Value.absent(),
          }) =>
              SpareCriticalitysCompanion.insert(
            id: id,
            usage: usage,
            leadTime: leadTime,
            cost: cost,
            assetRPN: assetRPN,
            manual: manual,
            manualPriority: manualPriority,
            newPriority: newPriority,
            newRPN: newRPN,
            siteid: siteid,
            itemnum: itemnum,
            rowid: rowid,
          ),
        ));
}

class $$SpareCriticalitysTableProcessedTableManager
    extends ProcessedTableManager<
        _$MyDatabase,
        $SpareCriticalitysTable,
        SpareCriticality,
        $$SpareCriticalitysTableFilterComposer,
        $$SpareCriticalitysTableOrderingComposer,
        $$SpareCriticalitysTableProcessedTableManager,
        $$SpareCriticalitysTableInsertCompanionBuilder,
        $$SpareCriticalitysTableUpdateCompanionBuilder> {
  $$SpareCriticalitysTableProcessedTableManager(super.$state);
}

class $$SpareCriticalitysTableFilterComposer
    extends FilterComposer<_$MyDatabase, $SpareCriticalitysTable> {
  $$SpareCriticalitysTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get usage => $state.composableBuilder(
      column: $state.table.usage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get leadTime => $state.composableBuilder(
      column: $state.table.leadTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get cost => $state.composableBuilder(
      column: $state.table.cost,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get assetRPN => $state.composableBuilder(
      column: $state.table.assetRPN,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get manual => $state.composableBuilder(
      column: $state.table.manual,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get manualPriority => $state.composableBuilder(
      column: $state.table.manualPriority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get newPriority => $state.composableBuilder(
      column: $state.table.newPriority,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get newRPN => $state.composableBuilder(
      column: $state.table.newRPN,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SpareCriticalitysTableOrderingComposer
    extends OrderingComposer<_$MyDatabase, $SpareCriticalitysTable> {
  $$SpareCriticalitysTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get usage => $state.composableBuilder(
      column: $state.table.usage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get leadTime => $state.composableBuilder(
      column: $state.table.leadTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get cost => $state.composableBuilder(
      column: $state.table.cost,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get assetRPN => $state.composableBuilder(
      column: $state.table.assetRPN,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get manual => $state.composableBuilder(
      column: $state.table.manual,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get manualPriority => $state.composableBuilder(
      column: $state.table.manualPriority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get newPriority => $state.composableBuilder(
      column: $state.table.newPriority,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get newRPN => $state.composableBuilder(
      column: $state.table.newRPN,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get siteid => $state.composableBuilder(
      column: $state.table.siteid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get itemnum => $state.composableBuilder(
      column: $state.table.itemnum,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$MyDatabaseManager {
  final _$MyDatabase _db;
  _$MyDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$LoginSettingsTableTableManager get loginSettings =>
      $$LoginSettingsTableTableManager(_db, _db.loginSettings);
  $$MeterDBsTableTableManager get meterDBs =>
      $$MeterDBsTableTableManager(_db, _db.meterDBs);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$WorkordersTableTableManager get workorders =>
      $$WorkordersTableTableManager(_db, _db.workorders);
  $$SystemCriticalitysTableTableManager get systemCriticalitys =>
      $$SystemCriticalitysTableTableManager(_db, _db.systemCriticalitys);
  $$AssetCriticalitysTableTableManager get assetCriticalitys =>
      $$AssetCriticalitysTableTableManager(_db, _db.assetCriticalitys);
  $$AssetUploadsTableTableManager get assetUploads =>
      $$AssetUploadsTableTableManager(_db, _db.assetUploads);
  $$SparePartsTableTableManager get spareParts =>
      $$SparePartsTableTableManager(_db, _db.spareParts);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$SpareCriticalitysTableTableManager get spareCriticalitys =>
      $$SpareCriticalitysTableTableManager(_db, _db.spareCriticalitys);
}

class UniqueRpnNumbersResult {
  final double newRPN;
  final int countasset;
  UniqueRpnNumbersResult({
    required this.newRPN,
    required this.countasset,
  });
}

class UniqueRpnNumbersSpareResult {
  final double newRPN;
  final int countitemnum;
  UniqueRpnNumbersSpareResult({
    required this.newRPN,
    required this.countitemnum,
  });
}

class SpareCriticalityAssetInfoResult {
  final String itemnum;
  final double? quantity;
  final double? assetRPN;
  SpareCriticalityAssetInfoResult({
    required this.itemnum,
    this.quantity,
    this.assetRPN,
  });
}

class SpareCriticalityAutoCalculationResult {
  final String itemnum;
  final double? quantity;
  final double unitCost;
  final double leadTime;
  final double? assetRPN;
  SpareCriticalityAutoCalculationResult({
    required this.itemnum,
    this.quantity,
    required this.unitCost,
    required this.leadTime,
    this.assetRPN,
  });
}

class AssetsAssociatedWithItemResult {
  final String assetnum;
  final String? description;
  final double? newRPN;
  final double quantity;
  AssetsAssociatedWithItemResult({
    required this.assetnum,
    this.description,
    this.newRPN,
    required this.quantity,
  });
}

class CompletedAssetRpnResult {
  final int totalAssets;
  final int parentAssets;
  final int completeChilds;
  CompletedAssetRpnResult({
    required this.totalAssets,
    required this.parentAssets,
    required this.completeChilds,
  });
}
