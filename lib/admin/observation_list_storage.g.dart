// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation_list_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObservationsAdapter extends TypeAdapter<Observations> {
  @override
  final int typeId = 3;

  @override
  Observations read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Observations(
      code: fields[0] as String,
      description: fields[1] as String,
      action: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Observations obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.action);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ObservationListAdapter extends TypeAdapter<ObservationList> {
  @override
  final int typeId = 2;

  @override
  ObservationList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObservationList(
      condition: fields[5] as String,
      extendedDescription: fields[2] as String,
      freqUnit: fields[4] as String,
      frequency: fields[3] as int,
      inspect: fields[1] as String,
      meterGroup: fields[0] as String,
      observations: (fields[6] as List).cast<Observations>(),
    );
  }

  @override
  void write(BinaryWriter writer, ObservationList obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.meterGroup)
      ..writeByte(1)
      ..write(obj.inspect)
      ..writeByte(2)
      ..write(obj.extendedDescription)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.freqUnit)
      ..writeByte(5)
      ..write(obj.condition)
      ..writeByte(6)
      ..write(obj.observations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservationListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
