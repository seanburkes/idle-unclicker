// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bestiary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BestiaryAdapter extends TypeAdapter<Bestiary> {
  @override
  final int typeId = 6;

  @override
  Bestiary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bestiary(
      monsterKills: (fields[0] as Map).cast<String, int>(),
      unlockedEntries: (fields[1] as List).cast<String>(),
      totalUniqueMonsters: fields[2] as int,
      totalKills: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Bestiary obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.monsterKills)
      ..writeByte(1)
      ..write(obj.unlockedEntries)
      ..writeByte(2)
      ..write(obj.totalUniqueMonsters)
      ..writeByte(3)
      ..write(obj.totalKills);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BestiaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
