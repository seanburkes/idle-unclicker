// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipmentAdapter extends TypeAdapter<Equipment> {
  @override
  final int typeId = 2;

  @override
  Equipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equipment(
      name: fields[0] as String,
      slot: fields[1] as String,
      attackBonus: fields[2] as int,
      defenseBonus: fields[3] as int,
      healthBonus: fields[4] as int,
      manaBonus: fields[5] as int,
      level: fields[6] as int,
      rarity: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Equipment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.slot)
      ..writeByte(2)
      ..write(obj.attackBonus)
      ..writeByte(3)
      ..write(obj.defenseBonus)
      ..writeByte(4)
      ..write(obj.healthBonus)
      ..writeByte(5)
      ..write(obj.manaBonus)
      ..writeByte(6)
      ..write(obj.level)
      ..writeByte(7)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryAdapter extends TypeAdapter<Inventory> {
  @override
  final int typeId = 3;

  @override
  Inventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inventory(
      items: (fields[0] as List).cast<Equipment>(),
      gold: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Inventory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.gold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
