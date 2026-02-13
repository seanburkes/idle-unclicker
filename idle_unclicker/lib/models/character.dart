import 'dart:math';
import 'package:hive/hive.dart';

part 'character.g.dart';

@HiveType(typeId: 0)
class Character extends HiveObject {
  // Basic Info
  @HiveField(0)
  String name;
  @HiveField(1)
  String race;
  @HiveField(2)
  String characterClass;
  @HiveField(3)
  int level;

  // Experience
  @HiveField(4)
  double experience;
  @HiveField(5)
  double experienceToNextLevel;

  // Core Stats (DCSS-style)
  @HiveField(6)
  int strength;
  @HiveField(7)
  int dexterity;
  @HiveField(8)
  int intelligence;
  @HiveField(30)
  int constitution;
  @HiveField(31)
  int wisdom;
  @HiveField(32)
  int charisma;

  // Vitals
  @HiveField(9)
  int currentHealth;
  @HiveField(10)
  int maxHealth;
  @HiveField(11)
  int currentMana;
  @HiveField(12)
  int maxMana;

  // Progression
  @HiveField(13)
  int unallocatedPoints;

  // Status
  @HiveField(14)
  bool isAlive;
  @HiveField(15)
  int totalDeaths;

  // Dungeon Progress
  @HiveField(16)
  int dungeonDepth;

  // Inventory
  @HiveField(17)
  int healthPotions;
  @HiveField(18)
  int gold;

  // Equipment
  @HiveField(19)
  String weaponType; // quick, balanced, heavy, precise
  @HiveField(20)
  String armorType; // cloth, leather, chain, plate

  // Skills (auto-progressing)
  @HiveField(21)
  int weaponSkill;
  @HiveField(22)
  int fightingSkill;
  @HiveField(23)
  int armorSkill;
  @HiveField(24)
  int dodgingSkill;

  // Skill XP (for tracking progress)
  @HiveField(25)
  int weaponSkillXP;
  @HiveField(26)
  int fightingSkillXP;
  @HiveField(27)
  int armorSkillXP;
  @HiveField(28)
  int dodgingSkillXP;

  Character({
    required this.name,
    required this.race,
    required this.characterClass,
    this.level = 1,
    this.experience = 0,
    this.experienceToNextLevel = 100,
    this.strength = 10,
    this.dexterity = 10,
    this.intelligence = 10,
    this.constitution = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.currentHealth = 100,
    this.maxHealth = 100,
    this.currentMana = 50,
    this.maxMana = 50,
    this.unallocatedPoints = 0,
    this.isAlive = true,
    this.totalDeaths = 0,
    this.dungeonDepth = 1,
    this.healthPotions = 3,
    this.gold = 0,
    this.weaponType = 'balanced',
    this.armorType = 'leather',
    this.weaponSkill = 0,
    this.fightingSkill = 0,
    this.armorSkill = 0,
    this.dodgingSkill = 0,
    this.weaponSkillXP = 0,
    this.fightingSkillXP = 0,
    this.armorSkillXP = 0,
    this.dodgingSkillXP = 0,
  });

  factory Character.create(String name, String race, String characterClass) {
    // Roll stats using 3d6 for each ability score (classic D&D style)
    int roll3d6() {
      final random = Random();
      return random.nextInt(6) +
          1 +
          random.nextInt(6) +
          1 +
          random.nextInt(6) +
          1;
    }

    // Race modifiers
    final raceModifiers = {
      'Human': {'str': 0, 'dex': 0, 'con': 0, 'int': 0, 'wis': 0, 'cha': 0},
      'Elf': {'str': -1, 'dex': 2, 'con': -1, 'int': 1, 'wis': 0, 'cha': 1},
      'Dwarf': {'str': 1, 'dex': -1, 'con': 2, 'int': 0, 'wis': 1, 'cha': -1},
      'Halfling': {'str': -2, 'dex': 2, 'con': 0, 'int': 0, 'wis': 0, 'cha': 1},
      'Orc': {'str': 2, 'dex': 0, 'con': 1, 'int': -2, 'wis': 0, 'cha': -1},
    };

    final mods = raceModifiers[race] ?? raceModifiers['Human']!;

    // Base stats with racial modifiers
    final strength = max(3, min(18, roll3d6() + mods['str']!));
    final dexterity = max(3, min(18, roll3d6() + mods['dex']!));
    final constitution = max(3, min(18, roll3d6() + mods['con']!));
    final intelligence = max(3, min(18, roll3d6() + mods['int']!));
    final wisdom = max(3, min(18, roll3d6() + mods['wis']!));
    final charisma = max(3, min(18, roll3d6() + mods['cha']!));

    // HP calculation: 1d8 per level + CON bonus, min 1
    final conBonus = (constitution - 10) ~/ 2;
    final maxHealth = max(1, 8 + conBonus);

    // MP calculation: Based on INT + WIS
    final maxMana = max(0, intelligence + wisdom);

    // Class determines starting equipment
    final classEquipment = {
      // Everyone starts with a dagger; armor remains class flavored.
      'Warrior': {'weapon': 'quick', 'armor': 'chain'},
      'Rogue': {'weapon': 'quick', 'armor': 'leather'},
      'Mage': {'weapon': 'quick', 'armor': 'cloth'},
      'Ranger': {'weapon': 'quick', 'armor': 'leather'},
      'Cleric': {'weapon': 'quick', 'armor': 'chain'},
    };

    final equip = classEquipment[characterClass] ?? classEquipment['Warrior']!;

    return Character(
      name: name,
      race: race,
      characterClass: characterClass,
      level: 1,
      strength: strength,
      dexterity: dexterity,
      intelligence: intelligence,
      constitution: constitution,
      wisdom: wisdom,
      charisma: charisma,
      maxHealth: maxHealth,
      currentHealth: maxHealth,
      maxMana: maxMana,
      currentMana: maxMana,
      weaponType: equip['weapon']!,
      armorType: equip['armor']!,
      gold: roll3d6() * 10, // Starting gold: 3-180
    );
  }

  // Combat calculations
  void takeDamage(int damage) {
    currentHealth -= damage;
    if (currentHealth <= 0) {
      currentHealth = 0;
      isAlive = false;
      totalDeaths++;
    }
  }

  void heal(int amount) {
    currentHealth += amount;
    if (currentHealth > maxHealth) {
      currentHealth = maxHealth;
    }
  }

  bool useHealthPotion() {
    if (healthPotions > 0) {
      healthPotions--;
      heal(maxHealth ~/ 2);
      return true;
    }
    return false;
  }

  void rest() {
    heal(maxHealth ~/ 4);
  }

  // Skill progression
  void gainSkillXP(String skill, int amount) {
    switch (skill) {
      case 'weapon':
        weaponSkillXP += amount;
        _checkSkillLevelUp('weapon');
        break;
      case 'fighting':
        fightingSkillXP += amount;
        _checkSkillLevelUp('fighting');
        break;
      case 'armor':
        armorSkillXP += amount;
        _checkSkillLevelUp('armor');
        break;
      case 'dodging':
        dodgingSkillXP += amount;
        _checkSkillLevelUp('dodging');
        break;
    }
  }

  void _checkSkillLevelUp(String skill) {
    final threshold = _getSkillThreshold(skill);
    int currentXP = _getSkillXP(skill);
    int currentLevel = _getSkillLevel(skill);

    while (currentXP >= threshold) {
      currentXP -= threshold;
      currentLevel++;
      _setSkillLevel(skill, currentLevel);
      _setSkillXP(skill, currentXP);
    }
  }

  int _getSkillThreshold(String skill) {
    final level = _getSkillLevel(skill);
    return 50 * (level + 1); // Each level costs more
  }

  int _getSkillXP(String skill) {
    switch (skill) {
      case 'weapon':
        return weaponSkillXP;
      case 'fighting':
        return fightingSkillXP;
      case 'armor':
        return armorSkillXP;
      case 'dodging':
        return dodgingSkillXP;
      default:
        return 0;
    }
  }

  void _setSkillXP(String skill, int xp) {
    switch (skill) {
      case 'weapon':
        weaponSkillXP = xp;
        break;
      case 'fighting':
        fightingSkillXP = xp;
        break;
      case 'armor':
        armorSkillXP = xp;
        break;
      case 'dodging':
        dodgingSkillXP = xp;
        break;
    }
  }

  int _getSkillLevel(String skill) {
    switch (skill) {
      case 'weapon':
        return weaponSkill;
      case 'fighting':
        return fightingSkill;
      case 'armor':
        return armorSkill;
      case 'dodging':
        return dodgingSkill;
      default:
        return 0;
    }
  }

  void _setSkillLevel(String skill, int level) {
    switch (skill) {
      case 'weapon':
        weaponSkill = level;
        break;
      case 'fighting':
        fightingSkill = level;
        break;
      case 'armor':
        armorSkill = level;
        break;
      case 'dodging':
        dodgingSkill = level;
        break;
    }
  }

  // Experience and leveling
  void gainExperience(double amount) {
    experience += amount;
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      levelUp();
    }
  }

  void levelUp() {
    level++;
    unallocatedPoints += 3;
    experienceToNextLevel = calculateExpForLevel(level);
    maxHealth += 10;
    currentHealth = maxHealth;
    maxMana += 5;
    currentMana = maxMana;
    healthPotions += 1;
  }

  static double calculateExpForLevel(int level) {
    return 100 * (1.16 * level);
  }

  // Derived combat stats
  bool get isAtCriticalHealth => currentHealth <= (maxHealth * 0.25);

  // RPG System derived stats
  int get attackPower {
    // Base from strength + weapon skill bonus
    return (strength ~/ 3) + (weaponSkill ~/ 2);
  }

  int get defense {
    // From constitution and armor skill
    return (constitution ~/ 4) + (armorSkill ~/ 3);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'race': race,
      'class': characterClass,
      'level': level,
      'health': '$currentHealth/$maxHealth',
      'mana': '$currentMana/$maxMana',
      'exp':
          '${experience.toStringAsFixed(0)}/${experienceToNextLevel.toStringAsFixed(0)}',
      'depth': dungeonDepth,
      'deaths': totalDeaths,
      'potions': healthPotions,
      'gold': gold,
      'weapon': weaponType,
      'armor': armorType,
      'skills': {
        'weapon': weaponSkill,
        'fighting': fightingSkill,
        'armor': armorSkill,
        'dodging': dodgingSkill,
      },
    };
  }
}
