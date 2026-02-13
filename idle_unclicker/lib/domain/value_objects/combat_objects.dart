/// Value object representing a monster in combat
/// Invariants: health >= 0, level >= 1
class Monster {
  final String name;
  final int level;
  int health;
  final int maxHealth;
  final int damage;
  final int armor;
  final int evasion;
  final int xpValue;
  final int goldValue;

  Monster({
    required this.name,
    required this.level,
    required this.health,
    required this.maxHealth,
    required this.damage,
    required this.armor,
    required this.evasion,
    required this.xpValue,
    required this.goldValue,
  }) : assert(health >= 0, 'Monster health cannot be negative'),
       assert(maxHealth > 0, 'Monster max health must be positive'),
       assert(level >= 1, 'Monster level must be at least 1');

  /// Checks if monster is defeated
  bool get isDefeated => health <= 0;

  /// Calculates hit chance against target evasion
  /// Returns percentage (0-100)
  int getHitChance(int targetEvasion) {
    // Base 50% + accuracy bonus - target evasion
    final accuracy = (damage * 0.5).round();
    var chance = 50 + ((accuracy - targetEvasion) / 5).round();
    return chance.clamp(5, 95); // Never below 5%, never above 95%
  }

  /// Takes damage from player attack
  /// Returns actual damage dealt after armor reduction
  int takeDamage(int attackPower) {
    // Apply armor reduction: damage = attack - armor/2
    var actualDamage = (attackPower - (armor / 2)).round();
    actualDamage = actualDamage.clamp(1, attackPower); // Minimum 1 damage

    health -= actualDamage;
    if (health < 0) health = 0;

    return actualDamage;
  }

  @override
  String toString() => 'Monster($name, L$level, $health/$maxHealth HP)';
}

/// Combat result containing outcome information
class CombatResult {
  final bool victory;
  final bool fled;
  final int totalDamageDealt;
  final int totalDamageTaken;
  final int turnsTaken;
  final int xpGained;
  final int goldGained;
  final List<String> log;

  CombatResult({
    required this.victory,
    required this.fled,
    required this.totalDamageDealt,
    required this.totalDamageTaken,
    required this.turnsTaken,
    this.xpGained = 0,
    this.goldGained = 0,
    this.log = const [],
  });

  factory CombatResult.victory({
    required int damageDealt,
    required int damageTaken,
    required int turns,
    required int xp,
    required int gold,
    required List<String> log,
  }) => CombatResult(
    victory: true,
    fled: false,
    totalDamageDealt: damageDealt,
    totalDamageTaken: damageTaken,
    turnsTaken: turns,
    xpGained: xp,
    goldGained: gold,
    log: log,
  );

  factory CombatResult.defeat({
    required int damageDealt,
    required int turns,
    required List<String> log,
  }) => CombatResult(
    victory: false,
    fled: false,
    totalDamageDealt: damageDealt,
    totalDamageTaken: 0, // Character died
    turnsTaken: turns,
    log: log,
  );

  factory CombatResult.fled({
    required int damageDealt,
    required int damageTaken,
    required int turns,
    required String reason,
    required List<String> log,
  }) => CombatResult(
    victory: false,
    fled: true,
    totalDamageDealt: damageDealt,
    totalDamageTaken: damageTaken,
    turnsTaken: turns,
    log: [...log, 'Fled: $reason'],
  );
}

/// Represents an item found as loot
class LootItem {
  final String name;
  final String slot;
  final int level;
  final int rarity;
  final int attackBonus;
  final int defenseBonus;

  LootItem({
    required this.name,
    required this.slot,
    required this.level,
    required this.rarity,
    this.attackBonus = 0,
    this.defenseBonus = 0,
  });

  bool get isWeapon => slot == 'weapon' || slot == 'main_hand';
  bool get isArmor => slot == 'armor' || slot == 'chest';

  @override
  String toString() => 'LootItem($name, ${rarity}★, L$level)';
}
