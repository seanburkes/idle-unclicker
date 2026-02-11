// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legendary_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatBonusAdapter extends TypeAdapter<StatBonus> {
  @override
  final int typeId = 53;

  @override
  StatBonus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatBonus(
      statName: fields[0] as String,
      value: fields[1] as double,
      isPercentage: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StatBonus obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.statName)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.isPercentage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatBonusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LegendaryEffectAdapter extends TypeAdapter<LegendaryEffect> {
  @override
  final int typeId = 54;

  @override
  LegendaryEffect read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LegendaryEffect(
      type: fields[0] as LegendaryEffectType,
      magnitude: fields[1] as double,
      description: fields[2] as String,
      isPassive: fields[3] as bool,
      isTriggered: fields[4] as bool,
      triggerCondition: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LegendaryEffect obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.magnitude)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isPassive)
      ..writeByte(4)
      ..write(obj.isTriggered)
      ..writeByte(5)
      ..write(obj.triggerCondition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegendaryEffectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LegendaryItemAdapter extends TypeAdapter<LegendaryItem> {
  @override
  final int typeId = 55;

  @override
  LegendaryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LegendaryItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      lore: fields[3] as String,
      equipmentType: fields[4] as EquipmentSlotType,
      effect: fields[5] as LegendaryEffect,
      baseStats: (fields[6] as List).cast<StatBonus>(),
      hasSentience: fields[7] as bool,
      sentience: fields[8] as SentienceType?,
      sentienceProgress: fields[9] as int,
      isAwakened: fields[10] as bool,
      reforgeCount: fields[11] as int,
      acquiredDate: fields[12] as DateTime,
      acquiredFloor: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LegendaryItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.lore)
      ..writeByte(4)
      ..write(obj.equipmentType)
      ..writeByte(5)
      ..write(obj.effect)
      ..writeByte(6)
      ..write(obj.baseStats)
      ..writeByte(7)
      ..write(obj.hasSentience)
      ..writeByte(8)
      ..write(obj.sentience)
      ..writeByte(9)
      ..write(obj.sentienceProgress)
      ..writeByte(10)
      ..write(obj.isAwakened)
      ..writeByte(11)
      ..write(obj.reforgeCount)
      ..writeByte(12)
      ..write(obj.acquiredDate)
      ..writeByte(13)
      ..write(obj.acquiredFloor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegendaryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LegendaryCollectionAdapter extends TypeAdapter<LegendaryCollection> {
  @override
  final int typeId = 56;

  @override
  LegendaryCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LegendaryCollection(
      ownedItems: (fields[0] as List).cast<LegendaryItem>(),
      discoveredIds: (fields[1] as List).cast<String>(),
      dropAttempts: (fields[2] as Map).cast<String, int>(),
      totalLegendariesAcquired: fields[3] as int,
      totalReforges: fields[4] as int,
      awakenedCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LegendaryCollection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ownedItems)
      ..writeByte(1)
      ..write(obj.discoveredIds)
      ..writeByte(2)
      ..write(obj.dropAttempts)
      ..writeByte(3)
      ..write(obj.totalLegendariesAcquired)
      ..writeByte(4)
      ..write(obj.totalReforges)
      ..writeByte(5)
      ..write(obj.awakenedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegendaryCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LegendaryEffectTypeAdapter extends TypeAdapter<LegendaryEffectType> {
  @override
  final int typeId = 50;

  @override
  LegendaryEffectType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LegendaryEffectType.damageBoost;
      case 1:
        return LegendaryEffectType.defenseBoost;
      case 2:
        return LegendaryEffectType.lifeSteal;
      case 3:
        return LegendaryEffectType.criticalMastery;
      case 4:
        return LegendaryEffectType.elementalDamage;
      case 5:
        return LegendaryEffectType.bossSlayer;
      case 6:
        return LegendaryEffectType.dragonBane;
      case 7:
        return LegendaryEffectType.undeadBane;
      case 8:
        return LegendaryEffectType.goldMagnet;
      case 9:
        return LegendaryEffectType.xpMagnet;
      case 10:
        return LegendaryEffectType.potionMastery;
      case 11:
        return LegendaryEffectType.immortality;
      case 12:
        return LegendaryEffectType.timeWarp;
      case 13:
        return LegendaryEffectType.summonHelper;
      case 14:
        return LegendaryEffectType.elementalConversion;
      case 15:
        return LegendaryEffectType.reflectDamage;
      case 16:
        return LegendaryEffectType.hpToDamage;
      case 17:
        return LegendaryEffectType.glassCannon;
      case 18:
        return LegendaryEffectType.immortalVengeance;
      case 19:
        return LegendaryEffectType.wishGranter;
      default:
        return LegendaryEffectType.damageBoost;
    }
  }

  @override
  void write(BinaryWriter writer, LegendaryEffectType obj) {
    switch (obj) {
      case LegendaryEffectType.damageBoost:
        writer.writeByte(0);
        break;
      case LegendaryEffectType.defenseBoost:
        writer.writeByte(1);
        break;
      case LegendaryEffectType.lifeSteal:
        writer.writeByte(2);
        break;
      case LegendaryEffectType.criticalMastery:
        writer.writeByte(3);
        break;
      case LegendaryEffectType.elementalDamage:
        writer.writeByte(4);
        break;
      case LegendaryEffectType.bossSlayer:
        writer.writeByte(5);
        break;
      case LegendaryEffectType.dragonBane:
        writer.writeByte(6);
        break;
      case LegendaryEffectType.undeadBane:
        writer.writeByte(7);
        break;
      case LegendaryEffectType.goldMagnet:
        writer.writeByte(8);
        break;
      case LegendaryEffectType.xpMagnet:
        writer.writeByte(9);
        break;
      case LegendaryEffectType.potionMastery:
        writer.writeByte(10);
        break;
      case LegendaryEffectType.immortality:
        writer.writeByte(11);
        break;
      case LegendaryEffectType.timeWarp:
        writer.writeByte(12);
        break;
      case LegendaryEffectType.summonHelper:
        writer.writeByte(13);
        break;
      case LegendaryEffectType.elementalConversion:
        writer.writeByte(14);
        break;
      case LegendaryEffectType.reflectDamage:
        writer.writeByte(15);
        break;
      case LegendaryEffectType.hpToDamage:
        writer.writeByte(16);
        break;
      case LegendaryEffectType.glassCannon:
        writer.writeByte(17);
        break;
      case LegendaryEffectType.immortalVengeance:
        writer.writeByte(18);
        break;
      case LegendaryEffectType.wishGranter:
        writer.writeByte(19);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegendaryEffectTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SentienceTypeAdapter extends TypeAdapter<SentienceType> {
  @override
  final int typeId = 51;

  @override
  SentienceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SentienceType.killDragons;
      case 1:
        return SentienceType.killBosses;
      case 2:
        return SentienceType.killUndead;
      case 3:
        return SentienceType.findGold;
      case 4:
        return SentienceType.exploreDeep;
      case 5:
        return SentienceType.surviveCombat;
      case 6:
        return SentienceType.usePotions;
      case 7:
        return SentienceType.enchantItems;
      case 8:
        return SentienceType.ascend;
      case 9:
        return SentienceType.collectSets;
      default:
        return SentienceType.killDragons;
    }
  }

  @override
  void write(BinaryWriter writer, SentienceType obj) {
    switch (obj) {
      case SentienceType.killDragons:
        writer.writeByte(0);
        break;
      case SentienceType.killBosses:
        writer.writeByte(1);
        break;
      case SentienceType.killUndead:
        writer.writeByte(2);
        break;
      case SentienceType.findGold:
        writer.writeByte(3);
        break;
      case SentienceType.exploreDeep:
        writer.writeByte(4);
        break;
      case SentienceType.surviveCombat:
        writer.writeByte(5);
        break;
      case SentienceType.usePotions:
        writer.writeByte(6);
        break;
      case SentienceType.enchantItems:
        writer.writeByte(7);
        break;
      case SentienceType.ascend:
        writer.writeByte(8);
        break;
      case SentienceType.collectSets:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentienceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentSlotTypeAdapter extends TypeAdapter<EquipmentSlotType> {
  @override
  final int typeId = 52;

  @override
  EquipmentSlotType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EquipmentSlotType.weapon;
      case 1:
        return EquipmentSlotType.armor;
      case 2:
        return EquipmentSlotType.jewelry;
      default:
        return EquipmentSlotType.weapon;
    }
  }

  @override
  void write(BinaryWriter writer, EquipmentSlotType obj) {
    switch (obj) {
      case EquipmentSlotType.weapon:
        writer.writeByte(0);
        break;
      case EquipmentSlotType.armor:
        writer.writeByte(1);
        break;
      case EquipmentSlotType.jewelry:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentSlotTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
