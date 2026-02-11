// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enchanting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GemAdapter extends TypeAdapter<Gem> {
  @override
  final int typeId = 25;

  @override
  Gem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gem(
      type: fields[0] as GemType,
      tier: fields[1] as GemTier,
    );
  }

  @override
  void write(BinaryWriter writer, Gem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.tier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnchantmentAdapter extends TypeAdapter<Enchantment> {
  @override
  final int typeId = 26;

  @override
  Enchantment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Enchantment(
      prefix: fields[0] as PrefixType,
      suffix: fields[1] as SuffixType,
      curse: fields[2] as CurseType,
      prefixMagnitude: fields[3] as double,
      suffixMagnitude: fields[4] as double,
      curseDrawbackMagnitude: fields[5] as double,
      isCursed: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Enchantment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.prefix)
      ..writeByte(1)
      ..write(obj.suffix)
      ..writeByte(2)
      ..write(obj.curse)
      ..writeByte(3)
      ..write(obj.prefixMagnitude)
      ..writeByte(4)
      ..write(obj.suffixMagnitude)
      ..writeByte(5)
      ..write(obj.curseDrawbackMagnitude)
      ..writeByte(6)
      ..write(obj.isCursed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnchantmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SocketAdapter extends TypeAdapter<Socket> {
  @override
  final int typeId = 27;

  @override
  Socket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Socket(
      gem: fields[0] as Gem?,
      isLocked: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Socket obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.gem)
      ..writeByte(1)
      ..write(obj.isLocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnchantedEquipmentAdapter extends TypeAdapter<EnchantedEquipment> {
  @override
  final int typeId = 28;

  @override
  EnchantedEquipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnchantedEquipment(
      baseEquipment: fields[0] as Equipment,
      sockets: (fields[1] as List).cast<Socket>(),
      enchantment: fields[2] as Enchantment?,
      enchantAttempts: fields[3] as int,
      historyLog: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EnchantedEquipment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.baseEquipment)
      ..writeByte(1)
      ..write(obj.sockets)
      ..writeByte(2)
      ..write(obj.enchantment)
      ..writeByte(3)
      ..write(obj.enchantAttempts)
      ..writeByte(4)
      ..write(obj.historyLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnchantedEquipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GemTypeAdapter extends TypeAdapter<GemType> {
  @override
  final int typeId = 20;

  @override
  GemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GemType.ruby;
      case 1:
        return GemType.sapphire;
      case 2:
        return GemType.emerald;
      default:
        return GemType.ruby;
    }
  }

  @override
  void write(BinaryWriter writer, GemType obj) {
    switch (obj) {
      case GemType.ruby:
        writer.writeByte(0);
        break;
      case GemType.sapphire:
        writer.writeByte(1);
        break;
      case GemType.emerald:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GemTierAdapter extends TypeAdapter<GemTier> {
  @override
  final int typeId = 21;

  @override
  GemTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GemTier.cracked;
      case 1:
        return GemTier.flawed;
      case 2:
        return GemTier.regular;
      case 3:
        return GemTier.flawless;
      case 4:
        return GemTier.perfect;
      default:
        return GemTier.cracked;
    }
  }

  @override
  void write(BinaryWriter writer, GemTier obj) {
    switch (obj) {
      case GemTier.cracked:
        writer.writeByte(0);
        break;
      case GemTier.flawed:
        writer.writeByte(1);
        break;
      case GemTier.regular:
        writer.writeByte(2);
        break;
      case GemTier.flawless:
        writer.writeByte(3);
        break;
      case GemTier.perfect:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GemTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrefixTypeAdapter extends TypeAdapter<PrefixType> {
  @override
  final int typeId = 22;

  @override
  PrefixType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PrefixType.sharp;
      case 1:
        return PrefixType.sturdy;
      case 2:
        return PrefixType.lucky;
      case 3:
        return PrefixType.swift;
      case 4:
        return PrefixType.wise;
      case 5:
        return PrefixType.vital;
      case 6:
        return PrefixType.precise;
      case 7:
        return PrefixType.resilient;
      default:
        return PrefixType.sharp;
    }
  }

  @override
  void write(BinaryWriter writer, PrefixType obj) {
    switch (obj) {
      case PrefixType.sharp:
        writer.writeByte(0);
        break;
      case PrefixType.sturdy:
        writer.writeByte(1);
        break;
      case PrefixType.lucky:
        writer.writeByte(2);
        break;
      case PrefixType.swift:
        writer.writeByte(3);
        break;
      case PrefixType.wise:
        writer.writeByte(4);
        break;
      case PrefixType.vital:
        writer.writeByte(5);
        break;
      case PrefixType.precise:
        writer.writeByte(6);
        break;
      case PrefixType.resilient:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrefixTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SuffixTypeAdapter extends TypeAdapter<SuffixType> {
  @override
  final int typeId = 23;

  @override
  SuffixType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SuffixType.ofPower;
      case 1:
        return SuffixType.ofProtection;
      case 2:
        return SuffixType.ofFortune;
      case 3:
        return SuffixType.ofHaste;
      case 4:
        return SuffixType.ofWisdom;
      case 5:
        return SuffixType.ofVitality;
      case 6:
        return SuffixType.ofPrecision;
      case 7:
        return SuffixType.ofEvasion;
      case 8:
        return SuffixType.ofStrength;
      case 9:
        return SuffixType.ofAgility;
      default:
        return SuffixType.ofPower;
    }
  }

  @override
  void write(BinaryWriter writer, SuffixType obj) {
    switch (obj) {
      case SuffixType.ofPower:
        writer.writeByte(0);
        break;
      case SuffixType.ofProtection:
        writer.writeByte(1);
        break;
      case SuffixType.ofFortune:
        writer.writeByte(2);
        break;
      case SuffixType.ofHaste:
        writer.writeByte(3);
        break;
      case SuffixType.ofWisdom:
        writer.writeByte(4);
        break;
      case SuffixType.ofVitality:
        writer.writeByte(5);
        break;
      case SuffixType.ofPrecision:
        writer.writeByte(6);
        break;
      case SuffixType.ofEvasion:
        writer.writeByte(7);
        break;
      case SuffixType.ofStrength:
        writer.writeByte(8);
        break;
      case SuffixType.ofAgility:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuffixTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurseTypeAdapter extends TypeAdapter<CurseType> {
  @override
  final int typeId = 24;

  @override
  CurseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CurseType.none;
      case 1:
        return CurseType.bloodthirsty;
      case 2:
        return CurseType.greedy;
      case 3:
        return CurseType.reckless;
      case 4:
        return CurseType.fragile;
      default:
        return CurseType.none;
    }
  }

  @override
  void write(BinaryWriter writer, CurseType obj) {
    switch (obj) {
      case CurseType.none:
        writer.writeByte(0);
        break;
      case CurseType.bloodthirsty:
        writer.writeByte(1);
        break;
      case CurseType.greedy:
        writer.writeByte(2);
        break;
      case CurseType.reckless:
        writer.writeByte(3);
        break;
      case CurseType.fragile:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
