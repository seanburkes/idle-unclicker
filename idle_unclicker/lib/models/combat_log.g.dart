// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combat_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CombatLogAdapter extends TypeAdapter<CombatLog> {
  @override
  final int typeId = 4;

  @override
  CombatLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CombatLog(
      entries: (fields[0] as List).cast<String>(),
      maxEntries: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CombatLog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.entries)
      ..writeByte(1)
      ..write(obj.maxEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
