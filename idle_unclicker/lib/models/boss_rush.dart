import 'package:hive/hive.dart';
import 'dart:math';
import 'character.dart';

part 'boss_rush.g.dart';

/// BossMechanic - Unique mechanics for boss fights
@HiveType(typeId: 70)
enum BossMechanic {
  @HiveField(0)
  overgrowth, // Boss heals 5% HP per turn
  @HiveField(1)
  timeLimit, // Must kill within X turns or enrages
  @HiveField(2)
  minionSwarm, // Spawns adds every 3 turns
  @HiveField(3)
  shieldPhases, // Invulnerable every 4th turn
  @HiveField(4)
  reflective, // Returns 20% damage to attacker
  @HiveField(5)
  elementalShift, // Rotates damage resistances
}

/// Extension for BossMechanic display and behavior
extension BossMechanicExtension on BossMechanic {
  String get displayName {
    switch (this) {
      case BossMechanic.overgrowth:
        return 'Overgrowth';
      case BossMechanic.timeLimit:
        return 'Time Limit';
      case BossMechanic.minionSwarm:
        return 'Minion Swarm';
      case BossMechanic.shieldPhases:
        return 'Shield Phases';
      case BossMechanic.reflective:
        return 'Reflective';
      case BossMechanic.elementalShift:
        return 'Elemental Shift';
    }
  }

  String get description {
    switch (this) {
      case BossMechanic.overgrowth:
        return 'Boss heals 5% HP each turn';
      case BossMechanic.timeLimit:
        return 'Enrages after 30 turns (3x damage)';
      case BossMechanic.minionSwarm:
        return 'Spawns minions every 3 turns';
      case BossMechanic.shieldPhases:
        return 'Invulnerable every 4th turn';
      case BossMechanic.reflective:
        return 'Returns 20% damage to attacker';
      case BossMechanic.elementalShift:
        return 'Rotates elemental resistances';
    }
  }

  String get icon {
    switch (this) {
      case BossMechanic.overgrowth:
        return '🌿';
      case BossMechanic.timeLimit:
        return '⏰';
      case BossMechanic.minionSwarm:
        return '👥';
      case BossMechanic.shieldPhases:
        return '🛡️';
      case BossMechanic.reflective:
        return '🪞';
      case BossMechanic.elementalShift:
        return '🔥';
    }
  }
}

/// EssenceType - Used for legendary crafting
@HiveType(typeId: 71)
enum EssenceType {
  @HiveField(0)
  fire,
  @HiveField(1)
  ice,
  @HiveField(2)
  lightning,
  @HiveField(3)
  shadow,
  @HiveField(4)
  nature,
  @HiveField(5)
  arcane,
  @HiveField(6)
  divine,
  @HiveField(7)
  chaos,
}

/// Extension for EssenceType display
extension EssenceTypeExtension on EssenceType {
  String get displayName {
    switch (this) {
      case EssenceType.fire:
        return 'Fire';
      case EssenceType.ice:
        return 'Ice';
      case EssenceType.lightning:
        return 'Lightning';
      case EssenceType.shadow:
        return 'Shadow';
      case EssenceType.nature:
        return 'Nature';
      case EssenceType.arcane:
        return 'Arcane';
      case EssenceType.divine:
        return 'Divine';
      case EssenceType.chaos:
        return 'Chaos';
    }
  }

  String get icon {
    switch (this) {
      case EssenceType.fire:
        return '🔥';
      case EssenceType.ice:
        return '❄️';
      case EssenceType.lightning:
        return '⚡';
      case EssenceType.shadow:
        return '🌑';
      case EssenceType.nature:
        return '🌿';
      case EssenceType.arcane:
        return '🔮';
      case EssenceType.divine:
        return '✨';
      case EssenceType.chaos:
        return '🌀';
    }
  }

  // Note: Color getter is defined in the UI layer (boss_rush_screen.dart)
  // to avoid importing Flutter's material.dart in the model
  int get colorValue {
    switch (this) {
      case EssenceType.fire:
        return 0xFFFF4444;
      case EssenceType.ice:
        return 0xFF44AAFF;
      case EssenceType.lightning:
        return 0xFFFFDD44;
      case EssenceType.shadow:
        return 0xFF6644AA;
      case EssenceType.nature:
        return 0xFF44AA44;
      case EssenceType.arcane:
        return 0xFFAA44AA;
      case EssenceType.divine:
        return 0xFFFFD700;
      case EssenceType.chaos:
        return 0xFFFF00FF;
    }
  }
}

/// RiftModifier - Modifiers for daily rifts
@HiveType(typeId: 72)
enum RiftModifier {
  @HiveField(0)
  noPotions, // Cannot use potions
  @HiveField(1)
  doubleSpeed, // Combat 2x faster
  @HiveField(2)
  glassCannon, // Player deals 2x dmg, takes 2x dmg
  @HiveField(3)
  ironman, // Death is permanent (no resurrection)
  @HiveField(4)
  berserker, // All monsters enraged
  @HiveField(5)
  treasureHunter, // 2x gold/xp but 2x monster HP
}

/// Extension for RiftModifier display
extension RiftModifierExtension on RiftModifier {
  String get displayName {
    switch (this) {
      case RiftModifier.noPotions:
        return 'No Potions';
      case RiftModifier.doubleSpeed:
        return 'Double Speed';
      case RiftModifier.glassCannon:
        return 'Glass Cannon';
      case RiftModifier.ironman:
        return 'Ironman';
      case RiftModifier.berserker:
        return 'Berserker';
      case RiftModifier.treasureHunter:
        return 'Treasure Hunter';
    }
  }

  String get description {
    switch (this) {
      case RiftModifier.noPotions:
        return 'Cannot use health potions';
      case RiftModifier.doubleSpeed:
        return 'Combat ticks twice as fast';
      case RiftModifier.glassCannon:
        return 'Deal 2x damage, take 2x damage';
      case RiftModifier.ironman:
        return 'Death is permanent for this rift';
      case RiftModifier.berserker:
        return 'All monsters deal 50% more damage';
      case RiftModifier.treasureHunter:
        return '2x rewards but monsters have 2x HP';
    }
  }

  String get icon {
    switch (this) {
      case RiftModifier.noPotions:
        return '🚫';
      case RiftModifier.doubleSpeed:
        return '⚡';
      case RiftModifier.glassCannon:
        return '💎';
      case RiftModifier.ironman:
        return '☠️';
      case RiftModifier.berserker:
        return '😤';
      case RiftModifier.treasureHunter:
        return '💰';
    }
  }
}

/// Boss - A powerful monster on every 5th floor
@HiveType(typeId: 73)
class Boss extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int level;

  @HiveField(2)
  int floor; // Always multiple of 5

  @HiveField(3)
  int maxHealth;

  @HiveField(4)
  int currentHealth;

  @HiveField(5)
  int damage;

  @HiveField(6)
  int armor;

  @HiveField(7)
  int evasion;

  @HiveField(8)
  BossMechanic mechanic;

  @HiveField(9)
  bool isDefeated;

  @HiveField(10)
  DateTime firstEncountered;

  @HiveField(11)
  List<EssenceType> essencesDropped;

  @HiveField(12)
  int turnCounter; // For mechanic tracking

  @HiveField(13)
  bool isEnraged; // For timeLimit mechanic

  @HiveField(14)
  bool isShielded; // For shieldPhases mechanic

  @HiveField(15)
  int currentResistanceIndex; // For elementalShift

  Boss({
    required this.name,
    required this.level,
    required this.floor,
    required this.maxHealth,
    required this.currentHealth,
    required this.damage,
    required this.armor,
    required this.evasion,
    required this.mechanic,
    this.isDefeated = false,
    required this.firstEncountered,
    required this.essencesDropped,
    this.turnCounter = 0,
    this.isEnraged = false,
    this.isShielded = false,
    this.currentResistanceIndex = 0,
  });

  /// Create a boss for a specific floor
  factory Boss.generate(int floor, Random random) {
    final mechanics = BossMechanic.values;
    final mechanic = mechanics[random.nextInt(mechanics.length)];

    // Boss stats are 3x normal monster stats for the floor
    final baseHealth = 20 + (floor * 5);
    final baseDamage = 5 + (floor ~/ 2);
    final baseArmor = floor ~/ 3;
    final baseEvasion = 5 + (floor ~/ 2);

    // Generate 1-3 random essences that this boss can drop
    final essenceCount = 1 + random.nextInt(3);
    final essences = <EssenceType>[];
    for (int i = 0; i < essenceCount; i++) {
      essences.add(
        EssenceType.values[random.nextInt(EssenceType.values.length)],
      );
    }

    // Generate boss name
    final prefixes = [
      'Ancient',
      'Corrupted',
      'Eldritch',
      'Malignant',
      'Primordial',
    ];
    final titles = ['Destroyer', 'Conqueror', 'Overlord', 'Tyrant', 'Devourer'];
    final name =
        '${prefixes[random.nextInt(prefixes.length)]} ${titles[random.nextInt(titles.length)]}';

    return Boss(
      name: name,
      level: (floor ~/ 5) + 5,
      floor: floor,
      maxHealth: baseHealth * 3,
      currentHealth: baseHealth * 3,
      damage: baseDamage * 3,
      armor: baseArmor * 3,
      evasion: baseEvasion * 3,
      mechanic: mechanic,
      firstEncountered: DateTime.now(),
      essencesDropped: essences,
    );
  }

  /// Apply mechanic effects at the start of a turn
  void applyMechanicStartOfTurn() {
    turnCounter++;

    switch (mechanic) {
      case BossMechanic.overgrowth:
        // Heal 5% of max HP
        final healAmount = (maxHealth * 0.05).round();
        currentHealth = min(maxHealth, currentHealth + healAmount);
        break;
      case BossMechanic.shieldPhases:
        // Toggle shield every 4th turn
        isShielded = turnCounter % 4 == 0;
        break;
      case BossMechanic.elementalShift:
        // Rotate resistance every 3 turns
        if (turnCounter % 3 == 0) {
          currentResistanceIndex =
              (currentResistanceIndex + 1) % EssenceType.values.length;
        }
        break;
      case BossMechanic.timeLimit:
        // Check for enrage at 30 turns
        if (turnCounter >= 30 && !isEnraged) {
          isEnraged = true;
          damage = (damage * 3).round(); // 3x damage when enraged
        }
        break;
      default:
        break;
    }
  }

  /// Check if boss should spawn minions this turn
  bool get shouldSpawnMinions {
    return mechanic == BossMechanic.minionSwarm && turnCounter % 3 == 0;
  }

  /// Calculate reflected damage for reflective mechanic
  int calculateReflectedDamage(int damageDealt) {
    if (mechanic != BossMechanic.reflective) return 0;
    return (damageDealt * 0.20).round();
  }

  /// Get current elemental resistance (for elementalShift)
  EssenceType? get currentResistance {
    if (mechanic != BossMechanic.elementalShift) return null;
    return EssenceType.values[currentResistanceIndex];
  }

  /// Mark boss as defeated and return essences
  List<EssenceType> defeat() {
    isDefeated = true;
    return List.from(essencesDropped);
  }

  double get healthPercent => currentHealth / maxHealth;
}

/// EchoEntry - Leaderboard entry for rifts (player or NPC echo)
@HiveType(typeId: 74)
class EchoEntry extends HiveObject {
  @HiveField(0)
  String echoName;

  @HiveField(1)
  String classType;

  @HiveField(2)
  int level;

  @HiveField(3)
  int floorReached;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  bool isPlayer;

  EchoEntry({
    required this.echoName,
    required this.classType,
    required this.level,
    required this.floorReached,
    required this.date,
    this.isPlayer = false,
  });

  /// Create an echo entry from a character
  factory EchoEntry.fromCharacter(Character character, int floorReached) {
    return EchoEntry(
      echoName: character.name,
      classType: character.characterClass,
      level: character.level,
      floorReached: floorReached,
      date: DateTime.now(),
      isPlayer: true,
    );
  }

  /// Create a fake echo entry for leaderboard
  factory EchoEntry.generateFake(int targetFloor, Random random) {
    final names = [
      'Aldric',
      'Mira',
      'Thorne',
      'Lyra',
      'Kael',
      'Seraphina',
      'Draven',
      'Isolde',
    ];
    final classes = ['Warrior', 'Rogue', 'Mage', 'Ranger', 'Cleric'];

    // Generate a floor slightly above or below target
    final variance = random.nextInt(5) - 2; // -2 to +2
    final floor = max(1, targetFloor + variance);

    return EchoEntry(
      echoName: names[random.nextInt(names.length)],
      classType: classes[random.nextInt(classes.length)],
      level: 10 + random.nextInt(20),
      floorReached: floor,
      date: DateTime.now().subtract(Duration(days: random.nextInt(7))),
      isPlayer: false,
    );
  }

  String get displayTitle => '$echoName the $classType';
}

/// Rift - Daily challenge dungeon with modifiers
@HiveType(typeId: 75)
class Rift extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  RiftModifier modifier;

  @HiveField(4)
  int depth; // How many floors deep

  @HiveField(5)
  DateTime date; // When this rift was generated

  @HiveField(6)
  bool completed;

  @HiveField(7)
  int bestFloor; // Best floor reached

  @HiveField(8)
  List<EchoEntry> echoLeaderboard;

  @HiveField(9)
  int playerBestFloor; // Track player's personal best

  Rift({
    required this.id,
    required this.name,
    required this.description,
    required this.modifier,
    required this.depth,
    required this.date,
    this.completed = false,
    this.bestFloor = 0,
    required this.echoLeaderboard,
    this.playerBestFloor = 0,
  });

  /// Generate a daily rift
  factory Rift.generateDaily(Random random) {
    final modifiers = RiftModifier.values;
    final modifier = modifiers[random.nextInt(modifiers.length)];

    final names = [
      'Void',
      'Abyssal',
      'Celestial',
      'Infernal',
      'Ethereal',
      'Chaos',
    ];
    final suffixes = ['Nexus', 'Rift', 'Tear', 'Fracture', 'Vortex', 'Gate'];

    final name =
        '${names[random.nextInt(names.length)]} ${suffixes[random.nextInt(suffixes.length)]}';

    // Generate fake leaderboard entries
    final entries = <EchoEntry>[];
    for (int i = 0; i < 5; i++) {
      entries.add(EchoEntry.generateFake(10 + random.nextInt(10), random));
    }
    // Sort by floor reached
    entries.sort((a, b) => b.floorReached.compareTo(a.floorReached));

    return Rift(
      id: 'daily_${DateTime.now().toIso8601String().split('T').first}',
      name: name,
      description:
          'A ${modifier.displayName.toLowerCase()} challenge awaits...',
      modifier: modifier,
      depth: 10 + random.nextInt(10), // 10-20 floors
      date: DateTime.now(),
      echoLeaderboard: entries,
    );
  }

  /// Check if this is today's rift
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Update leaderboard with new entry
  void updateLeaderboard(EchoEntry entry) {
    // Remove old player entry if exists
    echoLeaderboard.removeWhere((e) => e.isPlayer);

    // Add new entry
    echoLeaderboard.add(entry);

    // Sort by floor reached
    echoLeaderboard.sort((a, b) => b.floorReached.compareTo(a.floorReached));

    // Keep top 10
    if (echoLeaderboard.length > 10) {
      echoLeaderboard = echoLeaderboard.sublist(0, 10);
    }

    // Update best floor
    if (entry.floorReached > bestFloor) {
      bestFloor = entry.floorReached;
    }
    if (entry.isPlayer && entry.floorReached > playerBestFloor) {
      playerBestFloor = entry.floorReached;
    }
  }

  /// Get modifier multipliers for combat
  Map<String, double> getCombatModifiers() {
    switch (modifier) {
      case RiftModifier.glassCannon:
        return {'playerDamage': 2.0, 'playerDefense': 0.5};
      case RiftModifier.treasureHunter:
        return {
          'goldMultiplier': 2.0,
          'xpMultiplier': 2.0,
          'monsterHealth': 2.0,
        };
      case RiftModifier.berserker:
        return {'monsterDamage': 1.5};
      default:
        return {};
    }
  }
}

/// BossRushState - Tracks all boss rush and rift state
@HiveType(typeId: 76)
class BossRushState extends HiveObject {
  @HiveField(0)
  List<Boss> defeatedBosses;

  @HiveField(1)
  Boss? currentBoss;

  @HiveField(2)
  Rift? dailyRift;

  @HiveField(3)
  DateTime lastRiftDate;

  @HiveField(4)
  Map<EssenceType, int> essenceInventory;

  @HiveField(5)
  List<Rift> riftHistory;

  @HiveField(6)
  int totalBossesDefeated;

  @HiveField(7)
  int totalRiftsCompleted;

  BossRushState({
    required this.defeatedBosses,
    this.currentBoss,
    this.dailyRift,
    required this.lastRiftDate,
    required this.essenceInventory,
    required this.riftHistory,
    this.totalBossesDefeated = 0,
    this.totalRiftsCompleted = 0,
  });

  /// Create initial state
  factory BossRushState.create() {
    final inventory = <EssenceType, int>{};
    for (final essence in EssenceType.values) {
      inventory[essence] = 0;
    }

    return BossRushState(
      defeatedBosses: [],
      lastRiftDate: DateTime.now().subtract(const Duration(days: 1)),
      essenceInventory: inventory,
      riftHistory: [],
    );
  }

  /// Check if a new rift should be generated (daily rotation)
  bool get shouldGenerateNewRift {
    final now = DateTime.now();
    return now.difference(lastRiftDate).inDays >= 1;
  }

  /// Add essences to inventory
  void addEssences(List<EssenceType> essences) {
    for (final essence in essences) {
      essenceInventory[essence] = (essenceInventory[essence] ?? 0) + 1;
    }
  }

  /// Use essences for crafting
  bool useEssences(EssenceType type, int amount) {
    final current = essenceInventory[type] ?? 0;
    if (current < amount) return false;
    essenceInventory[type] = current - amount;
    return true;
  }

  /// Get total essence count
  int get totalEssences {
    return essenceInventory.values.fold(0, (sum, count) => sum + count);
  }

  /// Record defeated boss
  void recordBossDefeated(Boss boss) {
    defeatedBosses.add(boss);
    currentBoss = null;
    totalBossesDefeated++;
  }

  /// Record completed rift
  void recordRiftCompleted(Rift rift) {
    rift.completed = true;
    riftHistory.add(rift);
    totalRiftsCompleted++;
    dailyRift = null;
  }

  /// Generate boss for a floor if needed
  Boss? generateBossForFloor(int floor, Random random) {
    // Only generate on multiples of 5
    if (floor % 5 != 0) return null;

    // Check if we already have a current boss for this floor
    if (currentBoss != null &&
        currentBoss!.floor == floor &&
        !currentBoss!.isDefeated) {
      return currentBoss;
    }

    // Check if this boss was already defeated
    final alreadyDefeated = defeatedBosses.any((b) => b.floor == floor);
    if (alreadyDefeated) return null;

    // Generate new boss
    currentBoss = Boss.generate(floor, random);
    return currentBoss;
  }
}

// Note: Using Flutter's material Color class
// Import with: import 'package:flutter/material.dart';
