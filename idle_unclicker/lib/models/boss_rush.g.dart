// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_rush.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BossAdapter extends TypeAdapter<Boss> {
  @override
  final int typeId = 73;

  @override
  Boss read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Boss(
      name: fields[0] as String,
      level: fields[1] as int,
      floor: fields[2] as int,
      maxHealth: fields[3] as int,
      currentHealth: fields[4] as int,
      damage: fields[5] as int,
      armor: fields[6] as int,
      evasion: fields[7] as int,
      mechanic: fields[8] as BossMechanic,
      isDefeated: fields[9] as bool,
      firstEncountered: fields[10] as DateTime,
      essencesDropped: (fields[11] as List).cast<EssenceType>(),
      turnCounter: fields[12] as int,
      isEnraged: fields[13] as bool,
      isShielded: fields[14] as bool,
      currentResistanceIndex: fields[15] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Boss obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.floor)
      ..writeByte(3)
      ..write(obj.maxHealth)
      ..writeByte(4)
      ..write(obj.currentHealth)
      ..writeByte(5)
      ..write(obj.damage)
      ..writeByte(6)
      ..write(obj.armor)
      ..writeByte(7)
      ..write(obj.evasion)
      ..writeByte(8)
      ..write(obj.mechanic)
      ..writeByte(9)
      ..write(obj.isDefeated)
      ..writeByte(10)
      ..write(obj.firstEncountered)
      ..writeByte(11)
      ..write(obj.essencesDropped)
      ..writeByte(12)
      ..write(obj.turnCounter)
      ..writeByte(13)
      ..write(obj.isEnraged)
      ..writeByte(14)
      ..write(obj.isShielded)
      ..writeByte(15)
      ..write(obj.currentResistanceIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EchoEntryAdapter extends TypeAdapter<EchoEntry> {
  @override
  final int typeId = 74;

  @override
  EchoEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EchoEntry(
      echoName: fields[0] as String,
      classType: fields[1] as String,
      level: fields[2] as int,
      floorReached: fields[3] as int,
      date: fields[4] as DateTime,
      isPlayer: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EchoEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.echoName)
      ..writeByte(1)
      ..write(obj.classType)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.floorReached)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.isPlayer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EchoEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiftAdapter extends TypeAdapter<Rift> {
  @override
  final int typeId = 75;

  @override
  Rift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rift(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      modifier: fields[3] as RiftModifier,
      depth: fields[4] as int,
      date: fields[5] as DateTime,
      completed: fields[6] as bool,
      bestFloor: fields[7] as int,
      echoLeaderboard: (fields[8] as List).cast<EchoEntry>(),
      playerBestFloor: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Rift obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.modifier)
      ..writeByte(4)
      ..write(obj.depth)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.bestFloor)
      ..writeByte(8)
      ..write(obj.echoLeaderboard)
      ..writeByte(9)
      ..write(obj.playerBestFloor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BossRushStateAdapter extends TypeAdapter<BossRushState> {
  @override
  final int typeId = 76;

  @override
  BossRushState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BossRushState(
      defeatedBosses: (fields[0] as List).cast<Boss>(),
      currentBoss: fields[1] as Boss?,
      dailyRift: fields[2] as Rift?,
      lastRiftDate: fields[3] as DateTime,
      essenceInventory: (fields[4] as Map).cast<EssenceType, int>(),
      riftHistory: (fields[5] as List).cast<Rift>(),
      totalBossesDefeated: fields[6] as int,
      totalRiftsCompleted: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BossRushState obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.defeatedBosses)
      ..writeByte(1)
      ..write(obj.currentBoss)
      ..writeByte(2)
      ..write(obj.dailyRift)
      ..writeByte(3)
      ..write(obj.lastRiftDate)
      ..writeByte(4)
      ..write(obj.essenceInventory)
      ..writeByte(5)
      ..write(obj.riftHistory)
      ..writeByte(6)
      ..write(obj.totalBossesDefeated)
      ..writeByte(7)
      ..write(obj.totalRiftsCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossRushStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BossMechanicAdapter extends TypeAdapter<BossMechanic> {
  @override
  final int typeId = 70;

  @override
  BossMechanic read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BossMechanic.overgrowth;
      case 1:
        return BossMechanic.timeLimit;
      case 2:
        return BossMechanic.minionSwarm;
      case 3:
        return BossMechanic.shieldPhases;
      case 4:
        return BossMechanic.reflective;
      case 5:
        return BossMechanic.elementalShift;
      default:
        return BossMechanic.overgrowth;
    }
  }

  @override
  void write(BinaryWriter writer, BossMechanic obj) {
    switch (obj) {
      case BossMechanic.overgrowth:
        writer.writeByte(0);
        break;
      case BossMechanic.timeLimit:
        writer.writeByte(1);
        break;
      case BossMechanic.minionSwarm:
        writer.writeByte(2);
        break;
      case BossMechanic.shieldPhases:
        writer.writeByte(3);
        break;
      case BossMechanic.reflective:
        writer.writeByte(4);
        break;
      case BossMechanic.elementalShift:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BossMechanicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EssenceTypeAdapter extends TypeAdapter<EssenceType> {
  @override
  final int typeId = 71;

  @override
  EssenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EssenceType.fire;
      case 1:
        return EssenceType.ice;
      case 2:
        return EssenceType.lightning;
      case 3:
        return EssenceType.shadow;
      case 4:
        return EssenceType.nature;
      case 5:
        return EssenceType.arcane;
      case 6:
        return EssenceType.divine;
      case 7:
        return EssenceType.chaos;
      default:
        return EssenceType.fire;
    }
  }

  @override
  void write(BinaryWriter writer, EssenceType obj) {
    switch (obj) {
      case EssenceType.fire:
        writer.writeByte(0);
        break;
      case EssenceType.ice:
        writer.writeByte(1);
        break;
      case EssenceType.lightning:
        writer.writeByte(2);
        break;
      case EssenceType.shadow:
        writer.writeByte(3);
        break;
      case EssenceType.nature:
        writer.writeByte(4);
        break;
      case EssenceType.arcane:
        writer.writeByte(5);
        break;
      case EssenceType.divine:
        writer.writeByte(6);
        break;
      case EssenceType.chaos:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EssenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RiftModifierAdapter extends TypeAdapter<RiftModifier> {
  @override
  final int typeId = 72;

  @override
  RiftModifier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RiftModifier.noPotions;
      case 1:
        return RiftModifier.doubleSpeed;
      case 2:
        return RiftModifier.glassCannon;
      case 3:
        return RiftModifier.ironman;
      case 4:
        return RiftModifier.berserker;
      case 5:
        return RiftModifier.treasureHunter;
      default:
        return RiftModifier.noPotions;
    }
  }

  @override
  void write(BinaryWriter writer, RiftModifier obj) {
    switch (obj) {
      case RiftModifier.noPotions:
        writer.writeByte(0);
        break;
      case RiftModifier.doubleSpeed:
        writer.writeByte(1);
        break;
      case RiftModifier.glassCannon:
        writer.writeByte(2);
        break;
      case RiftModifier.ironman:
        writer.writeByte(3);
        break;
      case RiftModifier.berserker:
        writer.writeByte(4);
        break;
      case RiftModifier.treasureHunter:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiftModifierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
