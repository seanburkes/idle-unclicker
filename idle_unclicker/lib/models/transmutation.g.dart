// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transmutation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransmutationRecipeAdapter extends TypeAdapter<TransmutationRecipe> {
  @override
  final int typeId = 43;

  @override
  TransmutationRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransmutationRecipe(
      itemType: fields[0] as TransmutableItemType,
      fromTier: fields[1] as ItemTier,
      toTier: fields[2] as ItemTier,
      inputQuantity: fields[3] as int,
      outputQuantity: fields[4] as int,
      miracleChance: fields[5] as double,
      isVolatile: fields[6] as bool,
      goldCost: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TransmutationRecipe obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.itemType)
      ..writeByte(1)
      ..write(obj.fromTier)
      ..writeByte(2)
      ..write(obj.toTier)
      ..writeByte(3)
      ..write(obj.inputQuantity)
      ..writeByte(4)
      ..write(obj.outputQuantity)
      ..writeByte(5)
      ..write(obj.miracleChance)
      ..writeByte(6)
      ..write(obj.isVolatile)
      ..writeByte(7)
      ..write(obj.goldCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmutationRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransmutationResultAdapter extends TypeAdapter<TransmutationResult> {
  @override
  final int typeId = 44;

  @override
  TransmutationResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransmutationResult(
      success: fields[0] as bool,
      resultTier: fields[1] as ItemTier,
      quantityProduced: fields[2] as int,
      wasMiracle: fields[3] as bool,
      volatileOutcome: fields[4] as VolatileResult?,
      message: fields[5] as String,
      timestamp: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TransmutationResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.success)
      ..writeByte(1)
      ..write(obj.resultTier)
      ..writeByte(2)
      ..write(obj.quantityProduced)
      ..writeByte(3)
      ..write(obj.wasMiracle)
      ..writeByte(4)
      ..write(obj.volatileOutcome)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmutationResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransmutationHistoryAdapter extends TypeAdapter<TransmutationHistory> {
  @override
  final int typeId = 45;

  @override
  TransmutationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransmutationHistory(
      timestamp: fields[0] as DateTime,
      recipe: fields[1] as TransmutationRecipe,
      result: fields[2] as TransmutationResult,
      totalAttempts: fields[3] as int,
      miracleCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TransmutationHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.recipe)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.totalAttempts)
      ..writeByte(4)
      ..write(obj.miracleCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmutationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransmutationStateAdapter extends TypeAdapter<TransmutationState> {
  @override
  final int typeId = 46;

  @override
  TransmutationState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransmutationState(
      availableRecipes: (fields[0] as List).cast<TransmutationRecipe>(),
      history: (fields[1] as List).cast<TransmutationHistory>(),
      transmuteCounts: (fields[2] as Map).cast<ItemTier, int>(),
      autoTransmuteEnabled: fields[3] as bool,
      autoTransmuteThreshold: fields[4] as ItemTier,
      inventoryFullThreshold: fields[5] as int,
      totalTransmutations: fields[6] as int,
      totalMiracles: fields[7] as int,
      volatileAttempts: fields[8] as int,
      volatileSuccesses: fields[9] as int,
      lastTransmuteTick: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransmutationState obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.availableRecipes)
      ..writeByte(1)
      ..write(obj.history)
      ..writeByte(2)
      ..write(obj.transmuteCounts)
      ..writeByte(3)
      ..write(obj.autoTransmuteEnabled)
      ..writeByte(4)
      ..write(obj.autoTransmuteThreshold)
      ..writeByte(5)
      ..write(obj.inventoryFullThreshold)
      ..writeByte(6)
      ..write(obj.totalTransmutations)
      ..writeByte(7)
      ..write(obj.totalMiracles)
      ..writeByte(8)
      ..write(obj.volatileAttempts)
      ..writeByte(9)
      ..write(obj.volatileSuccesses)
      ..writeByte(10)
      ..write(obj.lastTransmuteTick);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmutationStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTierAdapter extends TypeAdapter<ItemTier> {
  @override
  final int typeId = 40;

  @override
  ItemTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemTier.common;
      case 1:
        return ItemTier.uncommon;
      case 2:
        return ItemTier.rare;
      case 3:
        return ItemTier.epic;
      case 4:
        return ItemTier.legendary;
      default:
        return ItemTier.common;
    }
  }

  @override
  void write(BinaryWriter writer, ItemTier obj) {
    switch (obj) {
      case ItemTier.common:
        writer.writeByte(0);
        break;
      case ItemTier.uncommon:
        writer.writeByte(1);
        break;
      case ItemTier.rare:
        writer.writeByte(2);
        break;
      case ItemTier.epic:
        writer.writeByte(3);
        break;
      case ItemTier.legendary:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransmutableItemTypeAdapter extends TypeAdapter<TransmutableItemType> {
  @override
  final int typeId = 41;

  @override
  TransmutableItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransmutableItemType.equipment;
      case 1:
        return TransmutableItemType.gems;
      case 2:
        return TransmutableItemType.materials;
      default:
        return TransmutableItemType.equipment;
    }
  }

  @override
  void write(BinaryWriter writer, TransmutableItemType obj) {
    switch (obj) {
      case TransmutableItemType.equipment:
        writer.writeByte(0);
        break;
      case TransmutableItemType.gems:
        writer.writeByte(1);
        break;
      case TransmutableItemType.materials:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransmutableItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VolatileResultAdapter extends TypeAdapter<VolatileResult> {
  @override
  final int typeId = 42;

  @override
  VolatileResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VolatileResult.successPlusOneTier;
      case 1:
        return VolatileResult.failureNothing;
      default:
        return VolatileResult.successPlusOneTier;
    }
  }

  @override
  void write(BinaryWriter writer, VolatileResult obj) {
    switch (obj) {
      case VolatileResult.successPlusOneTier:
        writer.writeByte(0);
        break;
      case VolatileResult.failureNothing:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolatileResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
