// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetAdapter extends TypeAdapter<Asset> {
  @override
  final int typeId = 1;

  @override
  Asset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Asset(
      assetNumber: fields[0] as String,
      hierarchy: fields[4] as String?,
      name: fields[1] as String,
      parent: fields[2] as String?,
      siteid: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Asset obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.assetNumber)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parent)
      ..writeByte(3)
      ..write(obj.siteid)
      ..writeByte(4)
      ..write(obj.hierarchy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
