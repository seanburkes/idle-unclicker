import 'dart:math';
import '../entities/character.dart';
import '../entities/game_state.dart';
import '../entities/guild_hall.dart';
import '../value_objects/meta_progression.dart';

/// Domain service for meta-progression operations
class MetaProgressionService {
  final Random _random;

  MetaProgressionService({Random? random}) : _random = random ?? Random();

  /// Calculate Echo Shards reward for ascension
  AscensionRewards calculateAscensionRewards({
    required double currentXp,
    required int level,
    required int totalDeaths,
  }) {
    return AscensionRewards.calculate(
      currentXp: currentXp,
      level: level,
      totalDeaths: totalDeaths,
    );
  }

  /// Check what would be unlocked at next ascension
  Map<String, List<String>> previewUnlocks(int currentAscensions) {
    final nextAscension = currentAscensions + 1;
    final newRaces = <String>[];
    final newClasses = <String>[];

    for (final race in UnlockableRace.values) {
      if (race.isUnlocked(nextAscension) &&
          !race.isUnlocked(currentAscensions)) {
        newRaces.add(race.displayName);
      }
    }

    for (final characterClass in UnlockableClass.values) {
      if (characterClass.isUnlocked(nextAscension) &&
          !characterClass.isUnlocked(currentAscensions)) {
        newClasses.add(characterClass.displayName);
      }
    }

    return {'races': newRaces, 'classes': newClasses};
  }

  /// Get recommended upgrade based on playstyle
  MetaUpgradeType? getRecommendedUpgrade(
    GameState gameState,
    String playstyle,
  ) {
    switch (playstyle.toLowerCase()) {
      case 'aggressive':
        // Prioritize HP and XP
        if (!gameState.getUpgrade(MetaUpgradeType.startingHp).isMaxed) {
          return MetaUpgradeType.startingHp;
        }
        if (!gameState.getUpgrade(MetaUpgradeType.xpGain).isMaxed) {
          return MetaUpgradeType.xpGain;
        }
        break;
      case 'defensive':
        // Prioritize HP and potions
        if (!gameState.getUpgrade(MetaUpgradeType.startingHp).isMaxed) {
          return MetaUpgradeType.startingHp;
        }
        if (!gameState.getUpgrade(MetaUpgradeType.startingPotion).isMaxed) {
          return MetaUpgradeType.startingPotion;
        }
        break;
      case 'loot':
        // Prioritize depth and XP
        if (!gameState.getUpgrade(MetaUpgradeType.startingDepth).isMaxed) {
          return MetaUpgradeType.startingDepth;
        }
        if (!gameState.getUpgrade(MetaUpgradeType.xpGain).isMaxed) {
          return MetaUpgradeType.xpGain;
        }
        break;
      case 'balanced':
      default:
        // Get cheapest available
        MetaUpgradeType? cheapest;
        int lowestCost = 999999;

        for (final type in MetaUpgradeType.values) {
          final upgrade = gameState.getUpgrade(type);
          if (!upgrade.isMaxed && upgrade.nextCost < lowestCost) {
            lowestCost = upgrade.nextCost;
            cheapest = type;
          }
        }
        return cheapest;
    }

    return null;
  }

  /// Get total meta-progression score
  int calculateMetaScore(GameState gameState, GuildHall? guildHall) {
    var score = 0;

    // Ascension points
    score += gameState.totalAscensions * 100;

    // Echo shards collected
    score += gameState.totalEchoesCollected;

    // Meta-upgrade points
    for (final upgrade in gameState.metaUpgrades.values) {
      score += upgrade.currentLevel * 10;
    }

    // Guild Hall points
    if (guildHall != null && guildHall.isUnlocked) {
      score += guildHall.totalRoomLevels * 50;
      score += guildHall.echoCount * 25;
    }

    return score;
  }

  /// Calculate optimal room upgrade order
  List<RoomType> getOptimalUpgradeOrder(GuildHall guildHall, String playstyle) {
    if (!guildHall.isUnlocked) return [];

    final rooms = List<Room>.from(guildHall.rooms);

    switch (playstyle.toLowerCase()) {
      case 'aggressive':
        // Prioritize training hall for skill XP
        rooms.sort((a, b) {
          if (a.type == RoomType.trainingHall) return -1;
          if (b.type == RoomType.trainingHall) return 1;
          return a.upgradeCost.compareTo(b.upgradeCost);
        });
        break;
      case 'loot':
        // Prioritize smithy for better drops
        rooms.sort((a, b) {
          if (a.type == RoomType.smithy) return -1;
          if (b.type == RoomType.smithy) return 1;
          return a.upgradeCost.compareTo(b.upgradeCost);
        });
        break;
      case 'defensive':
        // Prioritize treasury for gold
        rooms.sort((a, b) {
          if (a.type == RoomType.treasury) return -1;
          if (b.type == RoomType.treasury) return 1;
          return a.upgradeCost.compareTo(b.upgradeCost);
        });
        break;
      default:
        // Sort by cost efficiency (bonus per gold)
        rooms.sort((a, b) {
          if (a.isMaxed) return 1;
          if (b.isMaxed) return -1;
          final aEfficiency = a.nextBonus / a.upgradeCost;
          final bEfficiency = b.nextBonus / b.upgradeCost;
          return bEfficiency.compareTo(aEfficiency);
        });
    }

    return rooms.where((r) => !r.isMaxed).map((r) => r.type).toList();
  }

  /// Calculate combined bonuses from GameState and GuildHall
  CombinedBonuses calculateCombinedBonuses(
    GameState gameState,
    GuildHall? guildHall,
  ) {
    final startingBonuses = gameState.startingBonuses;
    final guildHallBonuses =
        guildHall?.totalBonuses ??
        const GuildHallBonuses(
          skillXpMultiplier: 1.0,
          goldFindMultiplier: 1.0,
          bestiaryRateMultiplier: 1.0,
          equipmentDropMultiplier: 1.0,
        );

    return CombinedBonuses(
      healthBonus: startingBonuses['healthBonus'] as double,
      potionBonus: startingBonuses['potionBonus'] as int,
      xpMultiplier:
          (startingBonuses['xpMultiplier'] as double) *
          guildHallBonuses.skillXpMultiplier,
      startingDepth: startingBonuses['startingDepth'] as int,
      goldFindMultiplier: guildHallBonuses.goldFindMultiplier,
      equipmentDropMultiplier: guildHallBonuses.equipmentDropMultiplier,
      bestiaryRateMultiplier: guildHallBonuses.bestiaryRateMultiplier,
    );
  }

  /// Generate echo fate description
  String generateEchoFate(Character character, bool ascended) {
    final fates = [
      'Ascended to legend after ${character.totalDeaths} deaths',
      'Fell in battle at floor ${character.dungeonDepth}',
      'Completed their journey at level ${character.level}',
      'Sacrificed everything for the greater good',
      'Mastered the arts of the ${character.identity.characterClass}',
    ];

    if (ascended) {
      return fates[0];
    }

    return fates[_random.nextInt(fates.length)];
  }
}

/// Value object representing combined bonuses
class CombinedBonuses {
  final double healthBonus;
  final int potionBonus;
  final double xpMultiplier;
  final int startingDepth;
  final double goldFindMultiplier;
  final double equipmentDropMultiplier;
  final double bestiaryRateMultiplier;

  const CombinedBonuses({
    required this.healthBonus,
    required this.potionBonus,
    required this.xpMultiplier,
    required this.startingDepth,
    required this.goldFindMultiplier,
    required this.equipmentDropMultiplier,
    required this.bestiaryRateMultiplier,
  });

  @override
  String toString() =>
      'CombinedBonuses(HP:${(healthBonus * 100).toStringAsFixed(0)}%, '
      'Pots:$potionBonus, XP:${xpMultiplier.toStringAsFixed(2)}x, '
      'Depth:$startingDepth)';
}
