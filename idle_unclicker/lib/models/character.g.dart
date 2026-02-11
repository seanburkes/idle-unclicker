// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterAdapter extends TypeAdapter<Character> {
  @override
  final int typeId = 0;

  @override
  Character read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Character(
      name: fields[0] as String,
      race: fields[1] as String,
      characterClass: fields[2] as String,
      level: fields[3] as int,
      experience: fields[4] as double,
      experienceToNextLevel: fields[5] as double,
      strength: fields[6] as int,
      dexterity: fields[7] as int,
      intelligence: fields[8] as int,
      constitution: fields[30] as int,
      wisdom: fields[31] as int,
      charisma: fields[32] as int,
      currentHealth: fields[9] as int,
      maxHealth: fields[10] as int,
      currentMana: fields[11] as int,
      maxMana: fields[12] as int,
      unallocatedPoints: fields[13] as int,
      isAlive: fields[14] as bool,
      totalDeaths: fields[15] as int,
      dungeonDepth: fields[16] as int,
      healthPotions: fields[17] as int,
      gold: fields[18] as int,
      weaponType: fields[19] as String,
      armorType: fields[20] as String,
      weaponSkill: fields[21] as int,
      fightingSkill: fields[22] as int,
      armorSkill: fields[23] as int,
      dodgingSkill: fields[24] as int,
      weaponSkillXP: fields[25] as int,
      fightingSkillXP: fields[26] as int,
      armorSkillXP: fields[27] as int,
      dodgingSkillXP: fields[28] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Character obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.race)
      ..writeByte(2)
      ..write(obj.characterClass)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.experience)
      ..writeByte(5)
      ..write(obj.experienceToNextLevel)
      ..writeByte(6)
      ..write(obj.strength)
      ..writeByte(7)
      ..write(obj.dexterity)
      ..writeByte(8)
      ..write(obj.intelligence)
      ..writeByte(30)
      ..write(obj.constitution)
      ..writeByte(31)
      ..write(obj.wisdom)
      ..writeByte(32)
      ..write(obj.charisma)
      ..writeByte(9)
      ..write(obj.currentHealth)
      ..writeByte(10)
      ..write(obj.maxHealth)
      ..writeByte(11)
      ..write(obj.currentMana)
      ..writeByte(12)
      ..write(obj.maxMana)
      ..writeByte(13)
      ..write(obj.unallocatedPoints)
      ..writeByte(14)
      ..write(obj.isAlive)
      ..writeByte(15)
      ..write(obj.totalDeaths)
      ..writeByte(16)
      ..write(obj.dungeonDepth)
      ..writeByte(17)
      ..write(obj.healthPotions)
      ..writeByte(18)
      ..write(obj.gold)
      ..writeByte(19)
      ..write(obj.weaponType)
      ..writeByte(20)
      ..write(obj.armorType)
      ..writeByte(21)
      ..write(obj.weaponSkill)
      ..writeByte(22)
      ..write(obj.fightingSkill)
      ..writeByte(23)
      ..write(obj.armorSkill)
      ..writeByte(24)
      ..write(obj.dodgingSkill)
      ..writeByte(25)
      ..write(obj.weaponSkillXP)
      ..writeByte(26)
      ..write(obj.fightingSkillXP)
      ..writeByte(27)
      ..write(obj.armorSkillXP)
      ..writeByte(28)
      ..write(obj.dodgingSkillXP);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
