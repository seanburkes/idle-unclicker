// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 1;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      lastUpdateTime: fields[0] as DateTime,
      lastTrustedNtpTime: fields[1] as int,
      lastLocalTime: fields[2] as int,
      focusPercentage: fields[3] as double,
      lastInteractionTime: fields[4] as DateTime,
      totalTimeInAppSeconds: fields[5] as int,
      totalTimeAwaySeconds: fields[6] as int,
      totalClicks: fields[7] as int,
      totalXpPenalized: fields[8] as double,
      zenStreakDays: fields[9] as int,
      lastZenCheckDate: fields[10] as DateTime,
      idleMultiplier: fields[11] as double,
      echoShards: fields[12] as int,
      totalAscensions: fields[13] as int,
      startingHpBonus: fields[14] as int,
      startingPotionBonus: fields[15] as int,
      xpGainBonus: fields[16] as int,
      startingDepthBonus: fields[17] as int,
      unlockedRaces: (fields[18] as List).cast<String>(),
      unlockedClasses: (fields[19] as List).cast<String>(),
      totalEchoesCollected: fields[20] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.lastUpdateTime)
      ..writeByte(1)
      ..write(obj.lastTrustedNtpTime)
      ..writeByte(2)
      ..write(obj.lastLocalTime)
      ..writeByte(3)
      ..write(obj.focusPercentage)
      ..writeByte(4)
      ..write(obj.lastInteractionTime)
      ..writeByte(5)
      ..write(obj.totalTimeInAppSeconds)
      ..writeByte(6)
      ..write(obj.totalTimeAwaySeconds)
      ..writeByte(7)
      ..write(obj.totalClicks)
      ..writeByte(8)
      ..write(obj.totalXpPenalized)
      ..writeByte(9)
      ..write(obj.zenStreakDays)
      ..writeByte(10)
      ..write(obj.lastZenCheckDate)
      ..writeByte(11)
      ..write(obj.idleMultiplier)
      ..writeByte(12)
      ..write(obj.echoShards)
      ..writeByte(13)
      ..write(obj.totalAscensions)
      ..writeByte(14)
      ..write(obj.startingHpBonus)
      ..writeByte(15)
      ..write(obj.startingPotionBonus)
      ..writeByte(16)
      ..write(obj.xpGainBonus)
      ..writeByte(17)
      ..write(obj.startingDepthBonus)
      ..writeByte(18)
      ..write(obj.unlockedRaces)
      ..writeByte(19)
      ..write(obj.unlockedClasses)
      ..writeByte(20)
      ..write(obj.totalEchoesCollected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
