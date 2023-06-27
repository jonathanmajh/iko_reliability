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
  String get aliasedName => _alias ?? 'login_settings';
  @override
  String get actualTableName => 'login_settings';
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
  const LoginSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  LoginSettingsCompanion.insert({
    required String key,
    required String value,
  })  : key = Value(key),
        value = Value(value);
  static Insertable<LoginSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  LoginSettingsCompanion copyWith({Value<String>? key, Value<String>? value}) {
    return LoginSettingsCompanion(
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
    return (StringBuffer('LoginSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value')
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
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _newAssetMeta =
      const VerificationMeta('newAsset');
  @override
  late final GeneratedColumn<bool> newAsset =
      GeneratedColumn<bool>('new_asset', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("new_asset" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
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
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      newAsset: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}new_asset'])!,
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
  final int id;
  final bool newAsset;
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
    map['id'] = Variable<int>(id);
    map['new_asset'] = Variable<bool>(newAsset);
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
      id: serializer.fromJson<int>(json['id']),
      newAsset: serializer.fromJson<bool>(json['newAsset']),
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
      'id': serializer.toJson<int>(id),
      'newAsset': serializer.toJson<bool>(newAsset),
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
          int? id,
          bool? newAsset}) =>
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
  final Value<int> id;
  final Value<bool> newAsset;
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
    this.id = const Value.absent(),
    this.newAsset = const Value.absent(),
  })  : assetnum = Value(assetnum),
        description = Value(description),
        status = Value(status),
        siteid = Value(siteid),
        changedate = Value(changedate),
        priority = Value(priority);
  static Insertable<Asset> custom({
    Expression<String>? assetnum,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? siteid,
    Expression<String>? changedate,
    Expression<String>? hierarchy,
    Expression<String>? parent,
    Expression<int>? priority,
    Expression<int>? id,
    Expression<bool>? newAsset,
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
      Value<int>? id,
      Value<bool>? newAsset}) {
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
      map['id'] = Variable<int>(id.value);
    }
    if (newAsset.present) {
      map['new_asset'] = Variable<bool>(newAsset.value);
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
          ..write('newAsset: $newAsset')
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
  @override
  List<GeneratedColumn> get $columns => [
        wonum,
        description,
        status,
        siteid,
        reportdate,
        downtime,
        type,
        assetnum
      ];
  @override
  String get aliasedName => _alias ?? 'workorders';
  @override
  String get actualTableName => 'workorders';
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
  const Workorder(
      {required this.wonum,
      required this.description,
      required this.status,
      required this.siteid,
      required this.reportdate,
      required this.downtime,
      required this.type,
      required this.assetnum});
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
          String? assetnum}) =>
      Workorder(
        wonum: wonum ?? this.wonum,
        description: description ?? this.description,
        status: status ?? this.status,
        siteid: siteid ?? this.siteid,
        reportdate: reportdate ?? this.reportdate,
        downtime: downtime ?? this.downtime,
        type: type ?? this.type,
        assetnum: assetnum ?? this.assetnum,
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
          ..write('assetnum: $assetnum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      wonum, description, status, siteid, reportdate, downtime, type, assetnum);
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
          other.assetnum == this.assetnum);
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
  const WorkordersCompanion({
    this.wonum = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.siteid = const Value.absent(),
    this.reportdate = const Value.absent(),
    this.downtime = const Value.absent(),
    this.type = const Value.absent(),
    this.assetnum = const Value.absent(),
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
      Value<String>? assetnum}) {
    return WorkordersCompanion(
      wonum: wonum ?? this.wonum,
      description: description ?? this.description,
      status: status ?? this.status,
      siteid: siteid ?? this.siteid,
      reportdate: reportdate ?? this.reportdate,
      downtime: downtime ?? this.downtime,
      type: type ?? this.type,
      assetnum: assetnum ?? this.assetnum,
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
          ..write('assetnum: $assetnum')
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        description,
        siteid,
        safety,
        regulatory,
        economic,
        throughput,
        quality
      ];
  @override
  String get aliasedName => _alias ?? 'system_criticalitys';
  @override
  String get actualTableName => 'system_criticalitys';
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
  const SystemCriticality(
      {required this.id,
      required this.description,
      this.siteid,
      required this.safety,
      required this.regulatory,
      required this.economic,
      required this.throughput,
      required this.quality});
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
          int? quality}) =>
      SystemCriticality(
        id: id ?? this.id,
        description: description ?? this.description,
        siteid: siteid.present ? siteid.value : this.siteid,
        safety: safety ?? this.safety,
        regulatory: regulatory ?? this.regulatory,
        economic: economic ?? this.economic,
        throughput: throughput ?? this.throughput,
        quality: quality ?? this.quality,
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
          ..write('quality: $quality')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description, siteid, safety, regulatory,
      economic, throughput, quality);
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
          other.quality == this.quality);
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
  const SystemCriticalitysCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.siteid = const Value.absent(),
    this.safety = const Value.absent(),
    this.regulatory = const Value.absent(),
    this.economic = const Value.absent(),
    this.throughput = const Value.absent(),
    this.quality = const Value.absent(),
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
  }) : description = Value(description);
  static Insertable<SystemCriticality> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<String>? siteid,
    Expression<int>? safety,
    Expression<int>? regulatory,
    Expression<int>? economic,
    Expression<int>? throughput,
    Expression<int>? quality,
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
      Value<int>? quality}) {
    return SystemCriticalitysCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      siteid: siteid ?? this.siteid,
      safety: safety ?? this.safety,
      regulatory: regulatory ?? this.regulatory,
      economic: economic ?? this.economic,
      throughput: throughput ?? this.throughput,
      quality: quality ?? this.quality,
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
          ..write('quality: $quality')
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
  late final GeneratedColumn<int> asset = GeneratedColumn<int>(
      'asset', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns =>
      [asset, system, type, frequency, downtime];
  @override
  String get aliasedName => _alias ?? 'asset_criticalitys';
  @override
  String get actualTableName => 'asset_criticalitys';
  @override
  VerificationContext validateIntegrity(Insertable<AssetCriticality> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset')) {
      context.handle(
          _assetMeta, asset.isAcceptableOrUnknown(data['asset']!, _assetMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {asset};
  @override
  AssetCriticality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetCriticality(
      asset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}asset'])!,
      system: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}system'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      downtime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downtime'])!,
    );
  }

  @override
  $AssetCriticalitysTable createAlias(String alias) {
    return $AssetCriticalitysTable(attachedDatabase, alias);
  }
}

class AssetCriticality extends DataClass
    implements Insertable<AssetCriticality> {
  final int asset;
  final int system;
  final String type;
  final int frequency;
  final int downtime;
  const AssetCriticality(
      {required this.asset,
      required this.system,
      required this.type,
      required this.frequency,
      required this.downtime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset'] = Variable<int>(asset);
    map['system'] = Variable<int>(system);
    map['type'] = Variable<String>(type);
    map['frequency'] = Variable<int>(frequency);
    map['downtime'] = Variable<int>(downtime);
    return map;
  }

  AssetCriticalitysCompanion toCompanion(bool nullToAbsent) {
    return AssetCriticalitysCompanion(
      asset: Value(asset),
      system: Value(system),
      type: Value(type),
      frequency: Value(frequency),
      downtime: Value(downtime),
    );
  }

  factory AssetCriticality.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetCriticality(
      asset: serializer.fromJson<int>(json['asset']),
      system: serializer.fromJson<int>(json['system']),
      type: serializer.fromJson<String>(json['type']),
      frequency: serializer.fromJson<int>(json['frequency']),
      downtime: serializer.fromJson<int>(json['downtime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'asset': serializer.toJson<int>(asset),
      'system': serializer.toJson<int>(system),
      'type': serializer.toJson<String>(type),
      'frequency': serializer.toJson<int>(frequency),
      'downtime': serializer.toJson<int>(downtime),
    };
  }

  AssetCriticality copyWith(
          {int? asset,
          int? system,
          String? type,
          int? frequency,
          int? downtime}) =>
      AssetCriticality(
        asset: asset ?? this.asset,
        system: system ?? this.system,
        type: type ?? this.type,
        frequency: frequency ?? this.frequency,
        downtime: downtime ?? this.downtime,
      );
  @override
  String toString() {
    return (StringBuffer('AssetCriticality(')
          ..write('asset: $asset, ')
          ..write('system: $system, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('downtime: $downtime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(asset, system, type, frequency, downtime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetCriticality &&
          other.asset == this.asset &&
          other.system == this.system &&
          other.type == this.type &&
          other.frequency == this.frequency &&
          other.downtime == this.downtime);
}

class AssetCriticalitysCompanion extends UpdateCompanion<AssetCriticality> {
  final Value<int> asset;
  final Value<int> system;
  final Value<String> type;
  final Value<int> frequency;
  final Value<int> downtime;
  const AssetCriticalitysCompanion({
    this.asset = const Value.absent(),
    this.system = const Value.absent(),
    this.type = const Value.absent(),
    this.frequency = const Value.absent(),
    this.downtime = const Value.absent(),
  });
  AssetCriticalitysCompanion.insert({
    this.asset = const Value.absent(),
    required int system,
    required String type,
    required int frequency,
    required int downtime,
  })  : system = Value(system),
        type = Value(type),
        frequency = Value(frequency),
        downtime = Value(downtime);
  static Insertable<AssetCriticality> custom({
    Expression<int>? asset,
    Expression<int>? system,
    Expression<String>? type,
    Expression<int>? frequency,
    Expression<int>? downtime,
  }) {
    return RawValuesInsertable({
      if (asset != null) 'asset': asset,
      if (system != null) 'system': system,
      if (type != null) 'type': type,
      if (frequency != null) 'frequency': frequency,
      if (downtime != null) 'downtime': downtime,
    });
  }

  AssetCriticalitysCompanion copyWith(
      {Value<int>? asset,
      Value<int>? system,
      Value<String>? type,
      Value<int>? frequency,
      Value<int>? downtime}) {
    return AssetCriticalitysCompanion(
      asset: asset ?? this.asset,
      system: system ?? this.system,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      downtime: downtime ?? this.downtime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (asset.present) {
      map['asset'] = Variable<int>(asset.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetCriticalitysCompanion(')
          ..write('asset: $asset, ')
          ..write('system: $system, ')
          ..write('type: $type, ')
          ..write('frequency: $frequency, ')
          ..write('downtime: $downtime')
          ..write(')'))
        .toString();
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
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
        assetCriticalitys
      ];
}
