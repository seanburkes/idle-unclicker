// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professions.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialAdapter extends TypeAdapter<Material> {
  @override
  final int typeId = 32;

  @override
  Material read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Material(
      type: fields[0] as MaterialType,
      quantity: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Material obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfessionAdapter extends TypeAdapter<Profession> {
  @override
  final int typeId = 34;

  @override
  Profession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profession(
      type: fields[0] as ProfessionType,
      level: fields[1] as int,
      experience: fields[2] as int,
      experienceToNextLevel: fields[3] as int,
      gatherRate: fields[4] as double,
      isUnlocked: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Profession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.experience)
      ..writeByte(3)
      ..write(obj.experienceToNextLevel)
      ..writeByte(4)
      ..write(obj.gatherRate)
      ..writeByte(5)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CraftingRecipeAdapter extends TypeAdapter<CraftingRecipe> {
  @override
  final int typeId = 35;

  @override
  CraftingRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CraftingRecipe(
      itemType: fields[0] as CraftedItemType,
      requiredMaterials: (fields[1] as Map).cast<MaterialType, int>(),
      requiredCraftingLevel: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CraftingRecipe obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.itemType)
      ..writeByte(1)
      ..write(obj.requiredMaterials)
      ..writeByte(2)
      ..write(obj.requiredCraftingLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CraftingRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfessionStateAdapter extends TypeAdapter<ProfessionState> {
  @override
  final int typeId = 36;

  @override
  ProfessionState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfessionState(
      professions: (fields[0] as List).cast<Profession>(),
      inventory: (fields[1] as Map).cast<MaterialType, int>(),
      totalCraftsCompleted: fields[2] as int,
      lastGatherTick: fields[3] as DateTime,
      recentGatherLog: (fields[4] as List).cast<String>(),
      autoCraftEnabled: fields[5] as bool,
      craftedItemsInventory: (fields[6] as Map).cast<CraftedItemType, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProfessionState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.professions)
      ..writeByte(1)
      ..write(obj.inventory)
      ..writeByte(2)
      ..write(obj.totalCraftsCompleted)
      ..writeByte(3)
      ..write(obj.lastGatherTick)
      ..writeByte(4)
      ..write(obj.recentGatherLog)
      ..writeByte(5)
      ..write(obj.autoCraftEnabled)
      ..writeByte(6)
      ..write(obj.craftedItemsInventory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfessionTypeAdapter extends TypeAdapter<ProfessionType> {
  @override
  final int typeId = 30;

  @override
  ProfessionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProfessionType.mining;
      case 1:
        return ProfessionType.herbalism;
      case 2:
        return ProfessionType.skinning;
      case 3:
        return ProfessionType.crafting;
      default:
        return ProfessionType.mining;
    }
  }

  @override
  void write(BinaryWriter writer, ProfessionType obj) {
    switch (obj) {
      case ProfessionType.mining:
        writer.writeByte(0);
        break;
      case ProfessionType.herbalism:
        writer.writeByte(1);
        break;
      case ProfessionType.skinning:
        writer.writeByte(2);
        break;
      case ProfessionType.crafting:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfessionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialTypeAdapter extends TypeAdapter<MaterialType> {
  @override
  final int typeId = 31;

  @override
  MaterialType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MaterialType.copperOre;
      case 1:
        return MaterialType.ironOre;
      case 2:
        return MaterialType.goldOre;
      case 3:
        return MaterialType.mithrilOre;
      case 4:
        return MaterialType.adamantiteOre;
      case 5:
        return MaterialType.peacebloom;
      case 6:
        return MaterialType.silverleaf;
      case 7:
        return MaterialType.mageroyal;
      case 8:
        return MaterialType.briarthorn;
      case 9:
        return MaterialType.fadeleaf;
      case 10:
        return MaterialType.ruinedLeather;
      case 11:
        return MaterialType.lightLeather;
      case 12:
        return MaterialType.mediumLeather;
      case 13:
        return MaterialType.heavyLeather;
      case 14:
        return MaterialType.ruggedLeather;
      case 15:
        return MaterialType.astralOre;
      case 16:
        return MaterialType.astralHerb;
      case 17:
        return MaterialType.astralHide;
      default:
        return MaterialType.copperOre;
    }
  }

  @override
  void write(BinaryWriter writer, MaterialType obj) {
    switch (obj) {
      case MaterialType.copperOre:
        writer.writeByte(0);
        break;
      case MaterialType.ironOre:
        writer.writeByte(1);
        break;
      case MaterialType.goldOre:
        writer.writeByte(2);
        break;
      case MaterialType.mithrilOre:
        writer.writeByte(3);
        break;
      case MaterialType.adamantiteOre:
        writer.writeByte(4);
        break;
      case MaterialType.peacebloom:
        writer.writeByte(5);
        break;
      case MaterialType.silverleaf:
        writer.writeByte(6);
        break;
      case MaterialType.mageroyal:
        writer.writeByte(7);
        break;
      case MaterialType.briarthorn:
        writer.writeByte(8);
        break;
      case MaterialType.fadeleaf:
        writer.writeByte(9);
        break;
      case MaterialType.ruinedLeather:
        writer.writeByte(10);
        break;
      case MaterialType.lightLeather:
        writer.writeByte(11);
        break;
      case MaterialType.mediumLeather:
        writer.writeByte(12);
        break;
      case MaterialType.heavyLeather:
        writer.writeByte(13);
        break;
      case MaterialType.ruggedLeather:
        writer.writeByte(14);
        break;
      case MaterialType.astralOre:
        writer.writeByte(15);
        break;
      case MaterialType.astralHerb:
        writer.writeByte(16);
        break;
      case MaterialType.astralHide:
        writer.writeByte(17);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CraftedItemTypeAdapter extends TypeAdapter<CraftedItemType> {
  @override
  final int typeId = 33;

  @override
  CraftedItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CraftedItemType.healthPotion;
      case 1:
        return CraftedItemType.manaPotion;
      case 2:
        return CraftedItemType.scrollOfEscape;
      default:
        return CraftedItemType.healthPotion;
    }
  }

  @override
  void write(BinaryWriter writer, CraftedItemType obj) {
    switch (obj) {
      case CraftedItemType.healthPotion:
        writer.writeByte(0);
        break;
      case CraftedItemType.manaPotion:
        writer.writeByte(1);
        break;
      case CraftedItemType.scrollOfEscape:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CraftedItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
