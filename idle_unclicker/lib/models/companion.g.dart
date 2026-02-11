// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanionAdapter extends TypeAdapter<Companion> {
  @override
  final int typeId = 7;

  @override
  Companion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Companion(
      name: fields[0] as String,
      role: fields[1] as String,
      level: fields[2] as int,
      experience: fields[3] as int,
      maxHealth: fields[4] as int,
      currentHealth: fields[5] as int,
      attack: fields[6] as int,
      defense: fields[7] as int,
      loyalty: fields[8] as double,
      totalCombats: fields[9] as int,
      fleesWitnessed: fields[10] as int,
      kills: fields[11] as int,
      isActive: fields[12] as bool,
      weaponType: fields[13] as String?,
      armorType: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Companion obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.experience)
      ..writeByte(4)
      ..write(obj.maxHealth)
      ..writeByte(5)
      ..write(obj.currentHealth)
      ..writeByte(6)
      ..write(obj.attack)
      ..writeByte(7)
      ..write(obj.defense)
      ..writeByte(8)
      ..write(obj.loyalty)
      ..writeByte(9)
      ..write(obj.totalCombats)
      ..writeByte(10)
      ..write(obj.fleesWitnessed)
      ..writeByte(11)
      ..write(obj.kills)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.weaponType)
      ..writeByte(14)
      ..write(obj.armorType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompanionRosterAdapter extends TypeAdapter<CompanionRoster> {
  @override
  final int typeId = 8;

  @override
  CompanionRoster read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanionRoster(
      companions: (fields[0] as List).cast<Companion>(),
      maxCompanions: fields[1] as int,
      totalHired: fields[2] as int,
      totalDeserted: fields[3] as int,
      totalSacrificed: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CompanionRoster obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.companions)
      ..writeByte(1)
      ..write(obj.maxCompanions)
      ..writeByte(2)
      ..write(obj.totalHired)
      ..writeByte(3)
      ..write(obj.totalDeserted)
      ..writeByte(4)
      ..write(obj.totalSacrificed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanionRosterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
