// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_tree.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkillTreeAdapter extends TypeAdapter<SkillTree> {
  @override
  final int typeId = 5;

  @override
  SkillTree read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkillTree(
      unlockedNodes: (fields[0] as List).cast<String>(),
      unlockProgress: fields[1] as double,
      totalPlaytimeMinutes: fields[2] as int,
      lastUpdate: fields[3] as DateTime,
      playstyle: fields[4] as String,
      killsRecorded: fields[5] as int,
      fleesRecorded: fields[6] as int,
      goldLooted: fields[7] as int,
      preferredBranch: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SkillTree obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.unlockedNodes)
      ..writeByte(1)
      ..write(obj.unlockProgress)
      ..writeByte(2)
      ..write(obj.totalPlaytimeMinutes)
      ..writeByte(3)
      ..write(obj.lastUpdate)
      ..writeByte(4)
      ..write(obj.playstyle)
      ..writeByte(5)
      ..write(obj.killsRecorded)
      ..writeByte(6)
      ..write(obj.fleesRecorded)
      ..writeByte(7)
      ..write(obj.goldLooted)
      ..writeByte(8)
      ..write(obj.preferredBranch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillTreeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
