// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_sets.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetBonusAdapter extends TypeAdapter<SetBonus> {
  @override
  final int typeId = 92;

  @override
  SetBonus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetBonus(
      type: fields[0] as SetBonusType,
      piecesRequired: fields[1] as int,
      magnitude: fields[2] as double,
      description: fields[3] as String,
      isCorrupted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SetBonus obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.piecesRequired)
      ..writeByte(2)
      ..write(obj.magnitude)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.isCorrupted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetBonusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentSetAdapter extends TypeAdapter<EquipmentSet> {
  @override
  final int typeId = 93;

  @override
  EquipmentSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentSet(
      name: fields[0] as SetName,
      description: fields[1] as String,
      bonuses: (fields[2] as List).cast<SetBonus>(),
      isCorrupted: fields[3] as bool,
      hpDrainPercent: fields[4] as double,
      flavorText: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentSet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.bonuses)
      ..writeByte(3)
      ..write(obj.isCorrupted)
      ..writeByte(4)
      ..write(obj.hpDrainPercent)
      ..writeByte(5)
      ..write(obj.flavorText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActiveSetAdapter extends TypeAdapter<ActiveSet> {
  @override
  final int typeId = 94;

  @override
  ActiveSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveSet(
      setName: fields[0] as SetName,
      piecesEquipped: fields[1] as int,
      activeBonuses: (fields[2] as List).cast<SetBonus>(),
      firstDiscovered: fields[3] as DateTime?,
      lastEquipped: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveSet obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.setName)
      ..writeByte(1)
      ..write(obj.piecesEquipped)
      ..writeByte(2)
      ..write(obj.activeBonuses)
      ..writeByte(3)
      ..write(obj.firstDiscovered)
      ..writeByte(4)
      ..write(obj.lastEquipped);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetSynergyAdapter extends TypeAdapter<SetSynergy> {
  @override
  final int typeId = 95;

  @override
  SetSynergy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetSynergy(
      primarySet: fields[0] as SetName,
      secondarySet: fields[1] as SetName?,
      synergyBonus: fields[2] as SetBonus,
      isUnexpected: fields[3] as bool,
      synergyName: fields[4] as String?,
      description: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SetSynergy obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.primarySet)
      ..writeByte(1)
      ..write(obj.secondarySet)
      ..writeByte(2)
      ..write(obj.synergyBonus)
      ..writeByte(3)
      ..write(obj.isUnexpected)
      ..writeByte(4)
      ..write(obj.synergyName)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetSynergyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentSetStateAdapter extends TypeAdapter<EquipmentSetState> {
  @override
  final int typeId = 96;

  @override
  EquipmentSetState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentSetState(
      activeSets: (fields[0] as Map?)?.cast<SetName, ActiveSet>(),
      discoveredSets: (fields[1] as List).cast<EquipmentSet>(),
      totalSetPiecesEquipped: fields[2] as int,
      activeSynergy: fields[3] as SetSynergy?,
      discoveredSynergies: (fields[4] as List).cast<SetSynergy>(),
      lastUpdated: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentSetState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.activeSets)
      ..writeByte(1)
      ..write(obj.discoveredSets)
      ..writeByte(2)
      ..write(obj.totalSetPiecesEquipped)
      ..writeByte(3)
      ..write(obj.activeSynergy)
      ..writeByte(4)
      ..write(obj.discoveredSynergies)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentSetStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentSetItemAdapter extends TypeAdapter<EquipmentSetItem> {
  @override
  final int typeId = 97;

  @override
  EquipmentSetItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentSetItem(
      equipment: fields[0] as Equipment,
      setName: fields[1] as SetName?,
      setPieceNumber: fields[2] as int,
      isSetPiece: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentSetItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.equipment)
      ..writeByte(1)
      ..write(obj.setName)
      ..writeByte(2)
      ..write(obj.setPieceNumber)
      ..writeByte(3)
      ..write(obj.isSetPiece);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentSetItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetNameAdapter extends TypeAdapter<SetName> {
  @override
  final int typeId = 90;

  @override
  SetName read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SetName.gladiatorsFury;
      case 1:
        return SetName.ironFortress;
      case 2:
        return SetName.shadowWalker;
      case 3:
        return SetName.arcaneMastery;
      case 4:
        return SetName.naturesEmbrace;
      case 5:
        return SetName.dragonsWill;
      case 6:
        return SetName.titansReach;
      case 7:
        return SetName.voidWhisperers;
      default:
        return SetName.gladiatorsFury;
    }
  }

  @override
  void write(BinaryWriter writer, SetName obj) {
    switch (obj) {
      case SetName.gladiatorsFury:
        writer.writeByte(0);
        break;
      case SetName.ironFortress:
        writer.writeByte(1);
        break;
      case SetName.shadowWalker:
        writer.writeByte(2);
        break;
      case SetName.arcaneMastery:
        writer.writeByte(3);
        break;
      case SetName.naturesEmbrace:
        writer.writeByte(4);
        break;
      case SetName.dragonsWill:
        writer.writeByte(5);
        break;
      case SetName.titansReach:
        writer.writeByte(6);
        break;
      case SetName.voidWhisperers:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetNameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetBonusTypeAdapter extends TypeAdapter<SetBonusType> {
  @override
  final int typeId = 91;

  @override
  SetBonusType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SetBonusType.statBonus;
      case 1:
        return SetBonusType.damageReduction;
      case 2:
        return SetBonusType.damageIncrease;
      case 3:
        return SetBonusType.lifeSteal;
      case 4:
        return SetBonusType.cooldownReduction;
      case 5:
        return SetBonusType.goldFind;
      case 6:
        return SetBonusType.xpBonus;
      case 7:
        return SetBonusType.hpRegen;
      case 8:
        return SetBonusType.critChance;
      case 9:
        return SetBonusType.critDamage;
      case 10:
        return SetBonusType.corruptedHPDrain;
      default:
        return SetBonusType.statBonus;
    }
  }

  @override
  void write(BinaryWriter writer, SetBonusType obj) {
    switch (obj) {
      case SetBonusType.statBonus:
        writer.writeByte(0);
        break;
      case SetBonusType.damageReduction:
        writer.writeByte(1);
        break;
      case SetBonusType.damageIncrease:
        writer.writeByte(2);
        break;
      case SetBonusType.lifeSteal:
        writer.writeByte(3);
        break;
      case SetBonusType.cooldownReduction:
        writer.writeByte(4);
        break;
      case SetBonusType.goldFind:
        writer.writeByte(5);
        break;
      case SetBonusType.xpBonus:
        writer.writeByte(6);
        break;
      case SetBonusType.hpRegen:
        writer.writeByte(7);
        break;
      case SetBonusType.critChance:
        writer.writeByte(8);
        break;
      case SetBonusType.critDamage:
        writer.writeByte(9);
        break;
      case SetBonusType.corruptedHPDrain:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetBonusTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
