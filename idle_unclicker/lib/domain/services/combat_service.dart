import 'dart:math';
import '../entities/character.dart';
import '../value_objects/combat_objects.dart';
import '../events/combat_events.dart';

/// Domain service for handling combat logic
///
/// This service encapsulates all combat-related business rules
/// and decision-making logic. It operates on domain entities
/// and emits domain events.
class CombatService {
  final Random _random;

  CombatService({Random? random}) : _random = random ?? Random();

  /// Process a single combat turn
  ///
  /// Returns the combat result after processing the turn
  CombatResult processCombatTurn(Character character, Monster monster) {
    final log = <String>[];
    var damageDealt = 0;
    var damageTaken = 0;

    // 1. Player attacks monster
    final playerHitChance = _calculateHitChance(
      character.attackPower,
      monster.evasion,
    );

    if (_random.nextInt(100) < playerHitChance) {
      // Hit! Calculate damage
      final critChance = 5; // Base 5% crit
      final isCrit = _random.nextInt(100) < critChance;
      var damage = character.attackPower;

      if (isCrit) {
        damage = (damage * 1.5).round();
        log.add('CRITICAL HIT! Dealt $damage damage to ${monster.name}');
      } else {
        log.add('Hit ${monster.name} for $damage damage');
      }

      final actualDamage = monster.takeDamage(damage);
      damageDealt += actualDamage;

      character.recordEvent(
        PlayerAttacked(
          characterId: character.id.value,
          damageDealt: actualDamage,
          wasCritical: isCrit,
          monsterHealthRemaining: monster.health,
        ),
      );
    } else {
      log.add('Missed ${monster.name}');
    }

    // Check if monster defeated
    if (monster.isDefeated) {
      final xpGain = monster.xpValue;
      final goldGain = monster.goldValue;

      character.recordEvent(
        MonsterDefeated(
          characterId: character.id.value,
          monsterName: monster.name,
          xpGained: xpGain,
          goldGained: goldGain,
          dungeonDepth: character.dungeonDepth,
        ),
      );

      // Award XP and gold
      character.gainExperience(xpGain.toDouble());
      character.gold += goldGain;

      // Award skill XP
      character.gainSkillXP('weapon', 5);
      character.gainSkillXP('fighting', 3);

      return CombatResult.victory(
        damageDealt: damageDealt,
        damageTaken: damageTaken,
        turns: 1,
        xp: xpGain,
        gold: goldGain,
        log: [...log, 'Defeated ${monster.name}!'],
      );
    }

    // 2. Monster attacks player (if not defeated)
    final monsterHitChance = monster.getHitChance(
      character.stats.dexterity, // Use dexterity as evasion
    );

    if (_random.nextInt(100) < monsterHitChance) {
      // Monster hits!
      final damage = monster.damage;
      character.takeDamage(damage);
      damageTaken += damage;

      character.recordEvent(
        MonsterAttacked(
          characterId: character.id.value,
          monsterName: monster.name,
          damageDealt: damage,
          playerHealthRemaining: character.health.current,
        ),
      );

      log.add('${monster.name} hit you for $damage damage');
    } else {
      log.add('Dodged ${monster.name}\'s attack');
      character.gainSkillXP('dodging', 2);
    }

    // Check if player died
    if (!character.isAlive) {
      return CombatResult.defeat(
        damageDealt: damageDealt,
        turns: 1,
        log: [...log, 'You were defeated by ${monster.name}!'],
      );
    }

    return CombatResult(
      victory: false,
      fled: false,
      totalDamageDealt: damageDealt,
      totalDamageTaken: damageTaken,
      turnsTaken: 1,
      log: log,
    );
  }

  /// Evaluates if the character should flee from combat
  ///
  /// Returns true if the AI decides to flee
  bool shouldFlee(Character character, Monster monster, {int potionsUsed = 0}) {
    // Flee if critical health and no potions
    if (character.isAtCriticalHealth && character.healthPotions == 0) {
      return true;
    }

    // Flee if health below 10% even with potions (emergency)
    if (character.health.current <= character.health.max * 0.1) {
      return _random.nextDouble() < 0.7; // 70% chance to flee
    }

    // Flee if monster is much stronger (3+ levels higher and low health)
    if (monster.level > character.level + 3 &&
        character.health.current <= character.health.max * 0.3) {
      return _random.nextDouble() < 0.5; // 50% chance to flee
    }

    return false;
  }

  /// Evaluates if the character should use a health potion
  ///
  /// Returns true if potion should be used
  bool shouldUsePotion(Character character) {
    if (character.healthPotions <= 0) return false;

    // Use potion if below 50% health
    if (character.health.current <= character.health.max * 0.5) {
      return _random.nextDouble() < 0.8; // 80% chance to use
    }

    // Use potion if below 25% health (emergency)
    if (character.health.current <= character.health.max * 0.25) {
      return true; // Always use in emergency
    }

    return false;
  }

  /// Uses a health potion and records the event
  ///
  /// Returns true if potion was used
  bool usePotion(Character character) {
    if (!character.useHealthPotion()) return false;

    final healAmount = character.health.max ~/ 2;

    character.recordEvent(
      PotionUsedInCombat(
        characterId: character.id.value,
        healAmount: healAmount,
        healthAfter: character.health.current,
        potionsRemaining: character.healthPotions,
      ),
    );

    return true;
  }

  /// Evaluates if character should rest after combat
  ///
  /// Returns true if resting is recommended
  bool shouldRestAfterCombat(Character character) {
    // Rest if below 50% health and we have time
    if (character.health.current <= character.health.max * 0.5) {
      return true;
    }

    // Rest if at critical health
    if (character.isAtCriticalHealth) {
      return true;
    }

    return false;
  }

  /// Makes the character rest and recover health
  void rest(Character character) {
    final healthBefore = character.health.current;
    character.rest();
    final healthRegained = character.health.current - healthBefore;

    character.recordEvent(
      CharacterRested(
        characterId: character.id.value,
        healthRegained: healthRegained,
        healthAfter: character.health.current,
      ),
    );
  }

  /// Evaluates if character should return to town
  ///
  /// Returns true if returning to town is recommended
  bool shouldReturnToTown(Character character) {
    // Return if low on potions AND gold to buy more
    if (character.healthPotions <= 1 && character.gold < 50) {
      return _random.nextDouble() < 0.9;
    }

    // Return if health is critically low after combat
    if (character.health.current <= character.health.max * 0.2) {
      return _random.nextDouble() < 0.7;
    }

    // Return if multiple deaths already
    if (character.totalDeaths >= 2) {
      return _random.nextDouble() < 0.5;
    }

    return false;
  }

  /// Returns character to town
  void returnToTown(Character character, {required String reason}) {
    character.dungeonDepth = 1;

    character.recordEvent(
      ReturnedToTown(
        characterId: character.id.value,
        reason: reason,
        dungeonDepth: 1,
      ),
    );
  }

  /// Generates a monster for the current dungeon depth
  Monster generateMonster(int dungeonDepth, int characterLevel) {
    // Determine monster level (varies by depth and character level)
    final baseLevel = dungeonDepth;
    final variance = _random.nextInt(3) - 1; // -1, 0, or 1
    final level = (baseLevel + variance).clamp(1, characterLevel + 5);

    // Generate monster name based on level
    final name = _generateMonsterName(level);

    // Calculate stats based on level
    final health = 20 + (level * 8) + _random.nextInt(level * 2);
    final damage = 3 + (level * 2) + _random.nextInt(level);
    final armor = (level * 1.5).round();
    final evasion = (level * 1.2).round();

    // Calculate rewards
    final xpValue = 10 + (level * 5) + _random.nextInt(level * 2);
    final goldValue = 2 + level + _random.nextInt(level);

    return Monster(
      name: name,
      level: level,
      health: health,
      maxHealth: health,
      damage: damage,
      armor: armor,
      evasion: evasion,
      xpValue: xpValue,
      goldValue: goldValue,
    );
  }

  /// Generates loot after defeating a monster
  LootItem? generateLoot(int dungeonDepth, int monsterLevel) {
    // 20% chance to find loot
    if (_random.nextDouble() > 0.2) return null;

    final slots = ['weapon', 'armor', 'helmet', 'gloves', 'boots'];
    final slot = slots[_random.nextInt(slots.length)];

    // Determine rarity (weighted toward common)
    final rarityRoll = _random.nextInt(100);
    final rarity = rarityRoll < 70
        ? 1
        : rarityRoll < 90
        ? 2
        : rarityRoll < 98
        ? 3
        : 4;

    // Calculate item stats
    final level = monsterLevel + _random.nextInt(3);
    final attackBonus = slot == 'weapon' ? level + (rarity * 2) : 0;
    final defenseBonus = slot == 'armor'
        ? level + (rarity * 2)
        : slot == 'helmet' || slot == 'gloves' || slot == 'boots'
        ? (level ~/ 2) + rarity
        : 0;

    final rarityNames = ['', 'Common', 'Uncommon', 'Rare', 'Epic'];
    final name = '${rarityNames[rarity]} ${slot.capitalize()}';

    return LootItem(
      name: name,
      slot: slot,
      level: level,
      rarity: rarity,
      attackBonus: attackBonus,
      defenseBonus: defenseBonus,
    );
  }

  /// Calculate hit chance based on accuracy and evasion
  int _calculateHitChance(int accuracy, int evasion) {
    // Base 50% + (accuracy - evasion) / 5
    var chance = 50 + ((accuracy - evasion) / 5).round();
    return chance.clamp(5, 95);
  }

  /// Generate a monster name based on level
  String _generateMonsterName(int level) {
    final adjectives = [
      'Small', 'Weak', 'Young', // Low levels
      '', 'Wild', 'Feral', // Medium levels
      'Large', 'Veteran', 'Strong', // High levels
      'Massive', 'Elder', 'Ancient', // Very high levels
    ];

    final creatures = [
      'Goblin',
      'Rat',
      'Slime',
      'Wolf',
      'Skeleton',
      'Zombie',
      'Orc',
      'Troll',
      'Demon',
      'Dragon',
      'Behemoth',
      'Titan',
    ];

    final adjIndex = ((level - 1) / 3).floor().clamp(0, adjectives.length - 1);
    final creatureIndex = (level / 2).floor().clamp(0, creatures.length - 1);

    final adjective = adjectives[adjIndex];
    final creature = creatures[creatureIndex % creatures.length];

    return adjective.isEmpty ? creature : '$adjective $creature';
  }
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
