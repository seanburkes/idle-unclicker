import 'package:hive/hive.dart';

part 'bestiary.g.dart';

/// Bestiary - Tracks monster knowledge and provides bonuses
/// Knowledge persists across ascensions
@HiveType(typeId: 6)
class Bestiary extends HiveObject {
  // Map of monster type ID to kill count
  @HiveField(0)
  Map<String, int> monsterKills;

  // Unlocked knowledge entries (monster type IDs)
  @HiveField(1)
  List<String> unlockedEntries;

  // Track total unique monsters encountered
  @HiveField(2)
  int totalUniqueMonsters;

  // Track total kills across all monsters
  @HiveField(3)
  int totalKills;

  Bestiary({
    this.monsterKills = const {},
    this.unlockedEntries = const [],
    this.totalUniqueMonsters = 0,
    this.totalKills = 0,
  });

  factory Bestiary.create() {
    return Bestiary(
      monsterKills: {},
      unlockedEntries: [],
      totalUniqueMonsters: 0,
      totalKills: 0,
    );
  }

  /// Record a kill and return true if new knowledge was unlocked
  bool recordKill(String monsterType, String monsterName) {
    final currentKills = monsterKills[monsterType] ?? 0;
    monsterKills = {...monsterKills, monsterType: currentKills + 1};
    totalKills++;

    if (currentKills == 0) {
      totalUniqueMonsters++;
    }

    // Check if knowledge level increased
    final oldLevel = _getKnowledgeLevel(currentKills);
    final newLevel = _getKnowledgeLevel(currentKills + 1);

    if (newLevel > oldLevel && !unlockedEntries.contains(monsterType)) {
      // Unlock entry at 10 kills
      if (newLevel >= 1) {
        unlockedEntries = [...unlockedEntries, monsterType];
        return true;
      }
    }

    return false;
  }

  int _getKnowledgeLevel(int kills) {
    if (kills >= 500) return 4;
    if (kills >= 100) return 3;
    if (kills >= 50) return 2;
    if (kills >= 10) return 1;
    return 0;
  }

  /// Get kill count for a monster type
  int getKillCount(String monsterType) {
    return monsterKills[monsterType] ?? 0;
  }

  /// Get knowledge level for a monster type (0-4)
  int getKnowledgeLevel(String monsterType) {
    return _getKnowledgeLevel(getKillCount(monsterType));
  }

  /// Check if we have knowledge about this monster
  bool hasKnowledge(String monsterType) {
    return getKnowledgeLevel(monsterType) > 0;
  }

  /// Get total bonuses from all known monsters
  Map<String, double> getTotalBonuses() {
    final bonuses = <String, double>{};

    for (final entry in monsterKills.entries) {
      final level = getKnowledgeLevel(entry.key);
      if (level > 0) {
        final entryBonuses = BestiaryData.getBonusesForLevel(level);
        for (final bonus in entryBonuses.entries) {
          bonuses[bonus.key] = (bonuses[bonus.key] ?? 0) + bonus.value;
        }
      }
    }

    return bonuses;
  }

  /// Get formatted knowledge milestones for a monster
  List<Map<String, dynamic>> getMilestones(String monsterType) {
    final kills = getKillCount(monsterType);
    final milestones = [
      {'kills': 10, 'bonus': 'Knowledge unlocked', 'reached': kills >= 10},
      {'kills': 50, 'bonus': '+2% damage vs this type', 'reached': kills >= 50},
      {
        'kills': 100,
        'bonus': '+5% evasion vs this type',
        'reached': kills >= 100,
      },
      {'kills': 500, 'bonus': 'Learn weakness', 'reached': kills >= 500},
    ];
    return milestones;
  }
}

/// Monster type definitions and data
class BestiaryData {
  static const Map<String, Map<String, dynamic>> monsterTypes = {
    'goblin': {
      'name': 'Goblin',
      'description': 'Small, green, and surprisingly stabby.',
      'weakness': 'fire',
      'resistance': 'poison',
    },
    'orc': {
      'name': 'Orc',
      'description': 'Big, green, and very angry.',
      'weakness': 'lightning',
      'resistance': 'physical',
    },
    'skeleton': {
      'name': 'Skeleton',
      'description': 'All bones, no brains. Literally.',
      'weakness': 'blunt',
      'resistance': 'piercing',
    },
    'zombie': {
      'name': 'Zombie',
      'description': 'Slow, hungry, and already dead.',
      'weakness': 'fire',
      'resistance': 'poison',
    },
    'spider': {
      'name': 'Giant Spider',
      'description': 'Eight legs of NOPE.',
      'weakness': 'fire',
      'resistance': 'poison',
    },
    'bat': {
      'name': 'Giant Bat',
      'description': 'Flying rodent of unusual size.',
      'weakness': 'lightning',
      'resistance': 'wind',
    },
    'rat': {
      'name': 'Giant Rat',
      'description': 'Diseased and hungry. Like your ex.',
      'weakness': 'poison',
      'resistance': 'disease',
    },
    'slime': {
      'name': 'Slime',
      'description': 'It jiggles. It wiggles. It dissolves.',
      'weakness': 'ice',
      'resistance': 'physical',
    },
    'ghost': {
      'name': 'Ghost',
      'description': 'Can walk through walls but still hits you.',
      'weakness': 'light',
      'resistance': 'physical',
    },
    'demon': {
      'name': 'Demon',
      'description': 'From the depths, here to ruin your day.',
      'weakness': 'holy',
      'resistance': 'fire',
    },
    'dragon': {
      'name': 'Dragon',
      'description': 'Hoards gold and breathes fire. Classic.',
      'weakness': 'ice',
      'resistance': 'fire',
    },
    'lich': {
      'name': 'Lich',
      'description': 'Undead wizard. Overachiever.',
      'weakness': 'holy',
      'resistance': 'dark',
    },
  };

  static Map<String, double> getBonusesForLevel(int level) {
    switch (level) {
      case 1: // 10 kills
        return {'damage': 0.02};
      case 2: // 50 kills
        return {'damage': 0.02, 'evasion': 0.05};
      case 3: // 100 kills
        return {'damage': 0.02, 'evasion': 0.05, 'loot': 0.10};
      case 4: // 500 kills
        return {
          'damage': 0.02,
          'evasion': 0.05,
          'loot': 0.10,
          'critChance': 0.02,
        };
      default:
        return {};
    }
  }

  static String getMonsterName(String type) {
    return monsterTypes[type]?['name'] ?? type;
  }

  static String getMonsterDescription(String type) {
    return monsterTypes[type]?['description'] ?? 'Unknown creature';
  }

  static String? getWeakness(String type) {
    return monsterTypes[type]?['weakness'];
  }

  static String? getResistance(String type) {
    return monsterTypes[type]?['resistance'];
  }

  /// Get icon/color for monster type
  static Map<String, dynamic> getVisuals(String type) {
    final visuals = {
      'goblin': {'icon': '👺', 'color': 0xFF4CAF50},
      'orc': {'icon': '👹', 'color': 0xFF8BC34A},
      'skeleton': {'icon': '💀', 'color': 0xFF9E9E9E},
      'zombie': {'icon': '🧟', 'color': 0xFF795548},
      'spider': {'icon': '🕷️', 'color': 0xFF673AB7},
      'bat': {'icon': '🦇', 'color': 0xFF607D8B},
      'rat': {'icon': '🐀', 'color': 0xFF5D4037},
      'slime': {'icon': '🟢', 'color': 0xFF00E676},
      'ghost': {'icon': '👻', 'color': 0xFFE0E0E0},
      'demon': {'icon': '😈', 'color': 0xFFD32F2F},
      'dragon': {'icon': '🐉', 'color': 0xFFFF5722},
      'lich': {'icon': '🧙‍♂️', 'color': 0xFF9C27B0},
    };
    return visuals[type] ?? {'icon': '❓', 'color': 0xFF757575};
  }
}
