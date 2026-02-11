// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alchemy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PotionEffectAdapter extends TypeAdapter<PotionEffect> {
  @override
  final int typeId = 48;

  @override
  PotionEffect read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PotionEffect(
      type: fields[0] as PotionType,
      durationSeconds: fields[1] as int,
      magnitude: fields[2] as double,
      isActive: fields[3] as bool,
      activatedAt: fields[4] as DateTime,
      expiresAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PotionEffect obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.durationSeconds)
      ..writeByte(2)
      ..write(obj.magnitude)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.activatedAt)
      ..writeByte(5)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PotionEffectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlchemyRecipeAdapter extends TypeAdapter<AlchemyRecipe> {
  @override
  final int typeId = 49;

  @override
  AlchemyRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlchemyRecipe(
      potionType: fields[0] as PotionType,
      requiredMaterials: (fields[1] as Map).cast<MaterialType, int>(),
      goldCost: fields[2] as int,
      brewTimeSeconds: fields[3] as int,
      outputQuantity: fields[4] as int,
      requiredAlchemyLevel: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlchemyRecipe obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.potionType)
      ..writeByte(1)
      ..write(obj.requiredMaterials)
      ..writeByte(2)
      ..write(obj.goldCost)
      ..writeByte(3)
      ..write(obj.brewTimeSeconds)
      ..writeByte(4)
      ..write(obj.outputQuantity)
      ..writeByte(5)
      ..write(obj.requiredAlchemyLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlchemyRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BrewingSlotAdapter extends TypeAdapter<BrewingSlot> {
  @override
  final int typeId = 50;

  @override
  BrewingSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrewingSlot(
      recipe: fields[0] as AlchemyRecipe?,
      startedAt: fields[1] as DateTime?,
      isComplete: fields[2] as bool,
      isAutoBrew: fields[3] as bool,
      progressSeconds: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BrewingSlot obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.recipe)
      ..writeByte(1)
      ..write(obj.startedAt)
      ..writeByte(2)
      ..write(obj.isComplete)
      ..writeByte(3)
      ..write(obj.isAutoBrew)
      ..writeByte(4)
      ..write(obj.progressSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrewingSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlchemyStateAdapter extends TypeAdapter<AlchemyState> {
  @override
  final int typeId = 51;

  @override
  AlchemyState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlchemyState(
      activeEffects: (fields[0] as List).cast<PotionEffect>(),
      availableRecipes: (fields[1] as List).cast<AlchemyRecipe>(),
      brewingSlots: (fields[2] as List).cast<BrewingSlot>(),
      inventory: (fields[3] as Map).cast<PotionType, int>(),
      totalBrewed: fields[4] as int,
      autoBrewEnabled: fields[5] as bool,
      alchemyLevel: fields[6] as int,
      alchemyExperience: fields[7] as int,
      lastBrewTick: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AlchemyState obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.activeEffects)
      ..writeByte(1)
      ..write(obj.availableRecipes)
      ..writeByte(2)
      ..write(obj.brewingSlots)
      ..writeByte(3)
      ..write(obj.inventory)
      ..writeByte(4)
      ..write(obj.totalBrewed)
      ..writeByte(5)
      ..write(obj.autoBrewEnabled)
      ..writeByte(6)
      ..write(obj.alchemyLevel)
      ..writeByte(7)
      ..write(obj.alchemyExperience)
      ..writeByte(8)
      ..write(obj.lastBrewTick);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlchemyStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PotionTypeAdapter extends TypeAdapter<PotionType> {
  @override
  final int typeId = 47;

  @override
  PotionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PotionType.healthMinor;
      case 1:
        return PotionType.healthMajor;
      case 2:
        return PotionType.healthSuperior;
      case 3:
        return PotionType.manaMinor;
      case 4:
        return PotionType.manaMajor;
      case 5:
        return PotionType.manaSuperior;
      case 6:
        return PotionType.strength;
      case 7:
        return PotionType.agility;
      case 8:
        return PotionType.intellect;
      case 9:
        return PotionType.protection;
      case 10:
        return PotionType.luck;
      case 11:
        return PotionType.wisdom;
      case 12:
        return PotionType.haste;
      case 13:
        return PotionType.transmutationBoost;
      default:
        return PotionType.healthMinor;
    }
  }

  @override
  void write(BinaryWriter writer, PotionType obj) {
    switch (obj) {
      case PotionType.healthMinor:
        writer.writeByte(0);
        break;
      case PotionType.healthMajor:
        writer.writeByte(1);
        break;
      case PotionType.healthSuperior:
        writer.writeByte(2);
        break;
      case PotionType.manaMinor:
        writer.writeByte(3);
        break;
      case PotionType.manaMajor:
        writer.writeByte(4);
        break;
      case PotionType.manaSuperior:
        writer.writeByte(5);
        break;
      case PotionType.strength:
        writer.writeByte(6);
        break;
      case PotionType.agility:
        writer.writeByte(7);
        break;
      case PotionType.intellect:
        writer.writeByte(8);
        break;
      case PotionType.protection:
        writer.writeByte(9);
        break;
      case PotionType.luck:
        writer.writeByte(10);
        break;
      case PotionType.wisdom:
        writer.writeByte(11);
        break;
      case PotionType.haste:
        writer.writeByte(12);
        break;
      case PotionType.transmutationBoost:
        writer.writeByte(13);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PotionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
