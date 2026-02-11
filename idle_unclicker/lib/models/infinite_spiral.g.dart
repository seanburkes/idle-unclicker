// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'infinite_spiral.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpiralLoopAdapter extends TypeAdapter<SpiralLoop> {
  @override
  final int typeId = 61;

  @override
  SpiralLoop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpiralLoop(
      loopNumber: fields[0] as int,
      enemyHpMultiplier: fields[1] as double,
      enemyDamageMultiplier: fields[2] as double,
      goldMultiplier: fields[3] as double,
      xpMultiplier: fields[4] as double,
      highestFloorReached: fields[5] as int,
      startedAt: fields[6] as DateTime,
      totalSecondsInLoop: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpiralLoop obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.loopNumber)
      ..writeByte(1)
      ..write(obj.enemyHpMultiplier)
      ..writeByte(2)
      ..write(obj.enemyDamageMultiplier)
      ..writeByte(3)
      ..write(obj.goldMultiplier)
      ..writeByte(4)
      ..write(obj.xpMultiplier)
      ..writeByte(5)
      ..write(obj.highestFloorReached)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.totalSecondsInLoop);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpiralLoopAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaleBonusAdapter extends TypeAdapter<TaleBonus> {
  @override
  final int typeId = 63;

  @override
  TaleBonus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaleBonus(
      source: fields[0] as TaleType,
      magnitude: fields[1] as double,
      description: fields[2] as String,
      isActive: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaleBonus obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.source)
      ..writeByte(1)
      ..write(obj.magnitude)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaleBonusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaleAdapter extends TypeAdapter<Tale> {
  @override
  final int typeId = 64;

  @override
  Tale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tale(
      type: fields[0] as TaleType,
      title: fields[1] as String,
      description: fields[2] as String,
      earnedAt: fields[3] as DateTime?,
      characterName: fields[4] as String?,
      characterLevel: fields[5] as int?,
      isCompleted: fields[6] as bool,
      bonus: fields[7] as TaleBonus?,
    );
  }

  @override
  void write(BinaryWriter writer, Tale obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.earnedAt)
      ..writeByte(4)
      ..write(obj.characterName)
      ..writeByte(5)
      ..write(obj.characterLevel)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.bonus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TalesCollectionAdapter extends TypeAdapter<TalesCollection> {
  @override
  final int typeId = 65;

  @override
  TalesCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TalesCollection(
      allTales: (fields[0] as List).cast<Tale>(),
      progress: (fields[1] as Map).cast<TaleType, int>(),
      becameLegendAt: fields[2] as DateTime?,
      totalTalesCompleted: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TalesCollection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.allTales)
      ..writeByte(1)
      ..write(obj.progress)
      ..writeByte(2)
      ..write(obj.becameLegendAt)
      ..writeByte(3)
      ..write(obj.totalTalesCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TalesCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InfiniteSpiralAdapter extends TypeAdapter<InfiniteSpiral> {
  @override
  final int typeId = 66;

  @override
  InfiniteSpiral read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InfiniteSpiral(
      state: fields[0] as SpiralState,
      currentLoop: fields[1] as SpiralLoop,
      loopHistory: (fields[2] as List).cast<SpiralLoop>(),
      totalLoopsCompleted: fields[3] as int,
      hasReachedFloor100: fields[4] as bool,
      firstSpiralDate: fields[5] as DateTime?,
      tales: fields[6] as TalesCollection,
      autoAdvanceEnabled: fields[7] as bool,
      totalDragonsKilled: fields[8] as int,
      totalBossesDefeated: fields[9] as int,
      totalGoldAccumulated: fields[10] as int,
      timesSurvivedCritical: fields[11] as int,
      totalLegendariesCollected: fields[12] as int,
      totalItemsEnchanted: fields[13] as int,
      totalSetsCompleted: fields[14] as int,
      totalCompanionsHad: fields[15] as int,
      totalTransmutesPerformed: fields[16] as int,
      totalPotionsBrewed: fields[17] as int,
      totalTimesAscended: fields[18] as int,
      totalAttacksDodged: fields[19] as int,
      totalTimesDied: fields[20] as int,
      totalLegendariesAwakened: fields[21] as int,
      totalReforgesDone: fields[22] as int,
      totalItemsCollected: fields[23] as int,
      loopStartTime: fields[24] as DateTime?,
      killsThisRun: fields[25] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InfiniteSpiral obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.state)
      ..writeByte(1)
      ..write(obj.currentLoop)
      ..writeByte(2)
      ..write(obj.loopHistory)
      ..writeByte(3)
      ..write(obj.totalLoopsCompleted)
      ..writeByte(4)
      ..write(obj.hasReachedFloor100)
      ..writeByte(5)
      ..write(obj.firstSpiralDate)
      ..writeByte(6)
      ..write(obj.tales)
      ..writeByte(7)
      ..write(obj.autoAdvanceEnabled)
      ..writeByte(8)
      ..write(obj.totalDragonsKilled)
      ..writeByte(9)
      ..write(obj.totalBossesDefeated)
      ..writeByte(10)
      ..write(obj.totalGoldAccumulated)
      ..writeByte(11)
      ..write(obj.timesSurvivedCritical)
      ..writeByte(12)
      ..write(obj.totalLegendariesCollected)
      ..writeByte(13)
      ..write(obj.totalItemsEnchanted)
      ..writeByte(14)
      ..write(obj.totalSetsCompleted)
      ..writeByte(15)
      ..write(obj.totalCompanionsHad)
      ..writeByte(16)
      ..write(obj.totalTransmutesPerformed)
      ..writeByte(17)
      ..write(obj.totalPotionsBrewed)
      ..writeByte(18)
      ..write(obj.totalTimesAscended)
      ..writeByte(19)
      ..write(obj.totalAttacksDodged)
      ..writeByte(20)
      ..write(obj.totalTimesDied)
      ..writeByte(21)
      ..write(obj.totalLegendariesAwakened)
      ..writeByte(22)
      ..write(obj.totalReforgesDone)
      ..writeByte(23)
      ..write(obj.totalItemsCollected)
      ..writeByte(24)
      ..write(obj.loopStartTime)
      ..writeByte(25)
      ..write(obj.killsThisRun);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfiniteSpiralAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpiralStateAdapter extends TypeAdapter<SpiralState> {
  @override
  final int typeId = 60;

  @override
  SpiralState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SpiralState.ascending;
      case 1:
        return SpiralState.resetting;
      case 2:
        return SpiralState.spiraling;
      default:
        return SpiralState.ascending;
    }
  }

  @override
  void write(BinaryWriter writer, SpiralState obj) {
    switch (obj) {
      case SpiralState.ascending:
        writer.writeByte(0);
        break;
      case SpiralState.resetting:
        writer.writeByte(1);
        break;
      case SpiralState.spiraling:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpiralStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaleTypeAdapter extends TypeAdapter<TaleType> {
  @override
  final int typeId = 62;

  @override
  TaleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaleType.dragonSlayer;
      case 1:
        return TaleType.bossConqueror;
      case 2:
        return TaleType.treasureHunter;
      case 3:
        return TaleType.dungeonDelver;
      case 4:
        return TaleType.immortal;
      case 5:
        return TaleType.legendaryCollector;
      case 6:
        return TaleType.masterEnchanter;
      case 7:
        return TaleType.setCompletionist;
      case 8:
        return TaleType.mercenaryCommander;
      case 9:
        return TaleType.transmutationMaster;
      case 10:
        return TaleType.alchemyExpert;
      case 11:
        return TaleType.ascendedBeing;
      case 12:
        return TaleType.speedRunner;
      case 13:
        return TaleType.pacifist;
      case 14:
        return TaleType.hoarder;
      case 15:
        return TaleType.perfectionist;
      case 16:
        return TaleType.awakenedOne;
      case 17:
        return TaleType.spiralWalker;
      case 18:
        return TaleType.immortalLegend;
      case 19:
        return TaleType.theUntouchable;
      default:
        return TaleType.dragonSlayer;
    }
  }

  @override
  void write(BinaryWriter writer, TaleType obj) {
    switch (obj) {
      case TaleType.dragonSlayer:
        writer.writeByte(0);
        break;
      case TaleType.bossConqueror:
        writer.writeByte(1);
        break;
      case TaleType.treasureHunter:
        writer.writeByte(2);
        break;
      case TaleType.dungeonDelver:
        writer.writeByte(3);
        break;
      case TaleType.immortal:
        writer.writeByte(4);
        break;
      case TaleType.legendaryCollector:
        writer.writeByte(5);
        break;
      case TaleType.masterEnchanter:
        writer.writeByte(6);
        break;
      case TaleType.setCompletionist:
        writer.writeByte(7);
        break;
      case TaleType.mercenaryCommander:
        writer.writeByte(8);
        break;
      case TaleType.transmutationMaster:
        writer.writeByte(9);
        break;
      case TaleType.alchemyExpert:
        writer.writeByte(10);
        break;
      case TaleType.ascendedBeing:
        writer.writeByte(11);
        break;
      case TaleType.speedRunner:
        writer.writeByte(12);
        break;
      case TaleType.pacifist:
        writer.writeByte(13);
        break;
      case TaleType.hoarder:
        writer.writeByte(14);
        break;
      case TaleType.perfectionist:
        writer.writeByte(15);
        break;
      case TaleType.awakenedOne:
        writer.writeByte(16);
        break;
      case TaleType.spiralWalker:
        writer.writeByte(17);
        break;
      case TaleType.immortalLegend:
        writer.writeByte(18);
        break;
      case TaleType.theUntouchable:
        writer.writeByte(19);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
