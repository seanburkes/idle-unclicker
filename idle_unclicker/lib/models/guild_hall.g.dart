// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_hall.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomAdapter extends TypeAdapter<Room> {
  @override
  final int typeId = 9;

  @override
  Room read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Room(
      type: fields[0] as String,
      level: fields[1] as int,
      baseCost: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Room obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.baseCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EchoNPCAdapter extends TypeAdapter<EchoNPC> {
  @override
  final int typeId = 10;

  @override
  EchoNPC read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EchoNPC(
      name: fields[0] as String,
      race: fields[1] as String,
      characterClass: fields[2] as String,
      level: fields[3] as int,
      fate: fields[4] as String,
      positionX: fields[5] as double,
      positionY: fields[6] as double,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EchoNPC obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.race)
      ..writeByte(2)
      ..write(obj.characterClass)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.fate)
      ..writeByte(5)
      ..write(obj.positionX)
      ..writeByte(6)
      ..write(obj.positionY)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EchoNPCAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GuildHallAdapter extends TypeAdapter<GuildHall> {
  @override
  final int typeId = 11;

  @override
  GuildHall read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuildHall(
      rooms: (fields[0] as List).cast<Room>(),
      echoes: (fields[1] as List).cast<EchoNPC>(),
      isUnlocked: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      totalGoldInvested: fields[4] as int,
      playstylePreference: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GuildHall obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.rooms)
      ..writeByte(1)
      ..write(obj.echoes)
      ..writeByte(2)
      ..write(obj.isUnlocked)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.totalGoldInvested)
      ..writeByte(5)
      ..write(obj.playstylePreference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuildHallAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
