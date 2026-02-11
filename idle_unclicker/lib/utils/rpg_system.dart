import 'dart:math';

/// DCSS-inspired RPG rule system for Idle Unclicker
/// All formulas adapted for automated idle gameplay
class RPGSystem {
  static final Random _random = Random.secure();

  // ============================================================================
  // COMBAT MECHANICS
  // ============================================================================

  /// To-hit calculation: Accuracy vs Evasion
  /// Based on DCSS: chance to hit = 0.5 + 0.5 * tanh((accuracy - evasion) / 10)
  /// Returns true if hit succeeds
  static bool attemptHit(int accuracy, int evasion) {
    final diff = accuracy - evasion;
    final hitChance = 0.5 + 0.5 * _tanh(diff / 10.0);
    return _random.nextDouble() < hitChance;
  }

  /// Calculate hit chance percentage for display
  static int getHitChance(int accuracy, int evasion) {
    final diff = accuracy - evasion;
    final hitChance = 0.5 + 0.5 * _tanh(diff / 10.0);
    return (hitChance * 100).round();
  }

  /// Damage reduction from Armor Class (AC)
  /// DCSS-style: AC reduces damage by 0-AC randomly (uniform distribution)
  /// This creates interesting variance - sometimes armor blocks a lot, sometimes a little
  static int applyArmorReduction(int damage, int armorClass) {
    if (damage <= 0) return 0;
    final reduction = _random.nextInt(armorClass + 1); // 0 to AC
    return max(1, damage - reduction); // Minimum 1 damage on hit
  }

  /// Evasion calculation based on dexterity, dodging skill, and encumbrance
  static int calculateEvasion(
    int dexterity,
    int dodgingSkill,
    int armorEncumbrance,
  ) {
    final baseEV = 10;
    final dexBonus = dexterity ~/ 5;
    final skillBonus = dodgingSkill ~/ 3;
    final encumbrancePenalty = armorEncumbrance ~/ 2;
    return max(1, baseEV + dexBonus + skillBonus - encumbrancePenalty);
  }

  /// Accuracy calculation based on weapon skill, fighting skill, and dexterity
  static int calculateAccuracy(
    int weaponSkill,
    int fightingSkill,
    int dexterity,
  ) {
    final baseAcc = 10;
    final weaponBonus = weaponSkill ~/ 2;
    final fightingBonus = fightingSkill ~/ 4;
    final dexBonus = dexterity ~/ 8;
    return baseAcc + weaponBonus + fightingBonus + dexBonus;
  }

  /// Calculate weapon damage with strength bonus
  /// DCSS: Str bonus adds 0-25% damage based on weapon weight/str requirement
  static int calculateWeaponDamage(
    int baseDamage,
    int strength,
    int weaponStrRequirement,
  ) {
    final strBonus = max(0, strength - weaponStrRequirement);
    final bonusPercent = min(0.25, strBonus / 100.0); // Max 25% bonus
    final bonus = (baseDamage * bonusPercent).round();
    return baseDamage + bonus;
  }

  // ============================================================================
  // WEAPON TYPES
  // ============================================================================

  static final Map<String, WeaponType> weaponTypes = {
    'quick': WeaponType(
      name: 'Quick',
      baseDamage: 5,
      speed: 1.5,
      strRequirement: 8,
      accuracyBonus: 4,
      description: 'Fast but weak',
    ),
    'balanced': WeaponType(
      name: 'Balanced',
      baseDamage: 8,
      speed: 1.0,
      strRequirement: 12,
      accuracyBonus: 2,
      description: 'Average in all regards',
    ),
    'heavy': WeaponType(
      name: 'Heavy',
      baseDamage: 14,
      speed: 0.7,
      strRequirement: 18,
      accuracyBonus: -2,
      description: 'Slow but powerful',
    ),
    'precise': WeaponType(
      name: 'Precise',
      baseDamage: 6,
      speed: 1.2,
      strRequirement: 10,
      accuracyBonus: 6,
      description: 'Accurate strikes',
    ),
  };

  // ============================================================================
  // ARMOR TYPES
  // ============================================================================

  static final Map<String, ArmorType> armorTypes = {
    'cloth': ArmorType(
      name: 'Cloth',
      armorClass: 2,
      encumbrance: 0,
      description: 'Light but offers little protection',
    ),
    'leather': ArmorType(
      name: 'Leather',
      armorClass: 5,
      encumbrance: 2,
      description: 'Balance of protection and mobility',
    ),
    'chain': ArmorType(
      name: 'Chain',
      armorClass: 9,
      encumbrance: 5,
      description: 'Good protection, slows movement',
    ),
    'plate': ArmorType(
      name: 'Plate',
      armorClass: 15,
      encumbrance: 10,
      description: 'Heavy protection, greatly reduces evasion',
    ),
  };

  // ============================================================================
  // MONSTER GENERATION
  // ============================================================================

  /// Generate monster stats based on dungeon depth
  /// DCSS: Monsters get tougher every few dungeon levels
  static MonsterTemplate generateMonster(int depth, int playerLevel) {
    final difficulty = depth + (playerLevel ~/ 3);

    // Determine monster "role" - affects stat distribution
    final roles = ['brute', 'skirmisher', 'caster', 'fast'];
    final role = roles[_random.nextInt(roles.length)];

    late int health;
    late int damage;
    late int armor;
    late int evasion;
    late int accuracy;
    late double speed;
    late String behavior;

    switch (role) {
      case 'brute':
        health = 20 + (difficulty * 8);
        damage = 4 + (difficulty * 2);
        armor = 2 + (difficulty ~/ 2);
        evasion = 5 + (difficulty ~/ 3);
        accuracy = 8 + difficulty;
        speed = 1.0;
        behavior = 'tanky';
        break;
      case 'skirmisher':
        health = 15 + (difficulty * 5);
        damage = 3 + (difficulty * 2);
        armor = 1 + (difficulty ~/ 3);
        evasion = 10 + (difficulty ~/ 2);
        accuracy = 12 + difficulty;
        speed = 1.2;
        behavior = 'evasive';
        break;
      case 'caster':
        health = 12 + (difficulty * 4);
        damage = 5 + (difficulty * 3);
        armor = 0;
        evasion = 8 + (difficulty ~/ 2);
        accuracy = 10 + difficulty;
        speed = 0.9;
        behavior = 'fragile_striker';
        break;
      case 'fast':
        health = 10 + (difficulty * 4);
        damage = 2 + difficulty;
        armor = 0;
        evasion = 15 + difficulty;
        accuracy = 8 + difficulty;
        speed = 1.5;
        behavior = 'swarmer';
        break;
      default:
        health = 15 + (difficulty * 6);
        damage = 3 + difficulty;
        armor = 1 + (difficulty ~/ 2);
        evasion = 8 + (difficulty ~/ 3);
        accuracy = 10 + difficulty;
        speed = 1.0;
        behavior = 'balanced';
    }

    return MonsterTemplate(
      role: role,
      health: health,
      damage: damage,
      armor: armor,
      evasion: evasion,
      accuracy: accuracy,
      speed: speed,
      behavior: behavior,
      xpValue: (difficulty * 5) + 10,
    );
  }

  // ============================================================================
  // SKILLS (Auto-progressing for idle gameplay)
  // ============================================================================

  /// Calculate skill experience gain per combat turn
  static SkillGain calculateSkillGain(
    String skillName,
    int currentSkill,
    int difficulty,
  ) {
    // Higher skill = slower progression (diminishing returns)
    final progressRate = 100.0 / (currentSkill + 10);
    final gain = (difficulty * progressRate).round();

    return SkillGain(
      skillName: skillName,
      experience: gain,
      nextLevelAt: _calculateSkillThreshold(currentSkill),
    );
  }

  static int _calculateSkillThreshold(int skillLevel) {
    // DCSS-like: Each skill level requires more XP
    // Level 1: 50, Level 2: 100, Level 3: 150, etc.
    return 50 * skillLevel;
  }

  // ============================================================================
  // STATUS EFFECTS
  // ============================================================================

  static final Map<String, StatusEffect> statusEffects = {
    'poison': StatusEffect(
      name: 'Poison',
      duration: 5,
      effectPerTurn: (stats) => stats.takeDamage(2),
      description: 'Taking damage over time',
    ),
    'slow': StatusEffect(
      name: 'Slow',
      duration: 3,
      modifier: (stats) => stats.speed *= 0.5,
      description: 'Actions take twice as long',
    ),
    'might': StatusEffect(
      name: 'Might',
      duration: 10,
      modifier: (stats) => stats.damage += 5,
      description: 'Dealing extra damage',
    ),
    'agility': StatusEffect(
      name: 'Agility',
      duration: 10,
      modifier: (stats) => stats.evasion += 5,
      description: 'Harder to hit',
    ),
  };

  // ============================================================================
  // UTILITY
  // ============================================================================

  static double _tanh(double x) {
    // Hyperbolic tangent approximation
    final e2x = exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }

  static int rollDice(int sides, {int count = 1}) {
    int total = 0;
    for (int i = 0; i < count; i++) {
      total += _random.nextInt(sides) + 1;
    }
    return total;
  }

  static bool rollPercent(int chance) {
    return _random.nextInt(100) < chance;
  }
}

// ============================================================================
// DATA CLASSES
// ============================================================================

class WeaponType {
  final String name;
  final int baseDamage;
  final double speed;
  final int strRequirement;
  final int accuracyBonus;
  final String description;

  WeaponType({
    required this.name,
    required this.baseDamage,
    required this.speed,
    required this.strRequirement,
    required this.accuracyBonus,
    required this.description,
  });
}

class ArmorType {
  final String name;
  final int armorClass;
  final int encumbrance;
  final String description;

  ArmorType({
    required this.name,
    required this.armorClass,
    required this.encumbrance,
    required this.description,
  });
}

class MonsterTemplate {
  final String role;
  final int health;
  final int damage;
  final int armor;
  final int evasion;
  final int accuracy;
  final double speed;
  final String behavior;
  final int xpValue;

  MonsterTemplate({
    required this.role,
    required this.health,
    required this.damage,
    required this.armor,
    required this.evasion,
    required this.accuracy,
    required this.speed,
    required this.behavior,
    required this.xpValue,
  });
}

class SkillGain {
  final String skillName;
  final int experience;
  final int nextLevelAt;

  SkillGain({
    required this.skillName,
    required this.experience,
    required this.nextLevelAt,
  });
}

class CombatStats {
  int damage;
  double speed;
  int evasion;
  int armor;
  int accuracy;
  int health;
  int maxHealth;

  CombatStats({
    this.damage = 0,
    this.speed = 1.0,
    this.evasion = 10,
    this.armor = 0,
    this.accuracy = 10,
    this.health = 100,
    this.maxHealth = 100,
  });

  void takeDamage(int amount) {
    health = max(0, health - amount);
  }
}

class StatusEffect {
  final String name;
  final int duration;
  final void Function(CombatStats)? effectPerTurn;
  final void Function(CombatStats)? modifier;
  final String description;

  StatusEffect({
    required this.name,
    required this.duration,
    required this.description,
    this.effectPerTurn,
    this.modifier,
  });
}
