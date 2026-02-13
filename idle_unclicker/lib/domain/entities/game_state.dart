import '../events/meta_progression_events.dart';
import 'aggregate_root.dart';
import 'character.dart';
import '../value_objects/meta_progression.dart';

/// Unique identifier for GameState
class GameStateId {
  final String value;

  const GameStateId._(this.value);

  factory GameStateId(String value) {
    if (value.isEmpty) throw ArgumentError('GameStateId cannot be empty');
    return GameStateId._(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GameStateId($value)';
}

/// Aggregate Root: GameState
///
/// Represents the global game state including:
/// - Meta-progression (ascensions, echo shards)
/// - Meta-upgrades (starting bonuses)
/// - Focus/Zen mechanics
/// - Time tracking
/// - Unlocks (races, classes)
class GameState extends AggregateRoot {
  final GameStateId id;

  // Meta-progression
  int echoShards;
  int totalAscensions;
  int totalEchoesCollected;

  // Meta-upgrades
  Map<MetaUpgradeType, MetaUpgrade> metaUpgrades;

  // Focus/Zen mechanics
  double focusPercentage;
  int zenStreakDays;
  DateTime lastZenCheckDate;

  // Time tracking
  DateTime lastUpdateTime;
  int totalTimeInAppSeconds;
  int totalTimeAwaySeconds;
  int totalInteractions;

  // Unlocks
  List<String> unlockedRaces;
  List<String> unlockedClasses;

  GameState({
    required this.id,
    this.echoShards = 0,
    this.totalAscensions = 0,
    this.totalEchoesCollected = 0,
    Map<MetaUpgradeType, MetaUpgrade>? metaUpgrades,
    this.focusPercentage = 0.0,
    this.zenStreakDays = 0,
    required this.lastZenCheckDate,
    required this.lastUpdateTime,
    this.totalTimeInAppSeconds = 0,
    this.totalTimeAwaySeconds = 0,
    this.totalInteractions = 0,
    List<String>? unlockedRaces,
    List<String>? unlockedClasses,
  }) : metaUpgrades = metaUpgrades ?? _initializeMetaUpgrades(),
       unlockedRaces = unlockedRaces ?? ['Human'],
       unlockedClasses = unlockedClasses ?? ['Warrior'];

  /// Factory to create new GameState
  factory GameState.create() {
    final now = DateTime.now();
    return GameState(
      id: GameStateId('global_game_state'),
      lastUpdateTime: now,
      lastZenCheckDate: now,
    );
  }

  // === Domain Behaviors ===

  /// Record an interaction (reduces focus)
  void recordInteraction() {
    totalInteractions++;
    focusPercentage = 0.0;

    recordEvent(
      InteractionRecorded(
        gameStateId: id.value,
        totalInteractions: totalInteractions,
      ),
    );
  }

  /// Update focus based on time away and in app
  void updateFocus(int secondsAway, int secondsInApp) {
    totalTimeAwaySeconds += secondsAway;
    totalTimeInAppSeconds += secondsInApp;

    double gain = 0.0;
    if (secondsAway > 0) {
      gain += secondsAway * 2.0;
    }
    if (secondsInApp > 0) {
      gain += secondsInApp * 0.5;
    }

    final oldFocus = focusPercentage;
    focusPercentage = (focusPercentage + gain).clamp(0.0, 100.0);

    if (focusPercentage != oldFocus) {
      recordEvent(
        FocusUpdated(
          gameStateId: id.value,
          oldFocus: oldFocus,
          newFocus: focusPercentage,
        ),
      );
    }
  }

  /// Check and update zen streak
  void checkZenStreak() {
    final now = DateTime.now();
    final daysSinceLastCheck = now.difference(lastZenCheckDate).inDays;

    if (daysSinceLastCheck >= 1) {
      final oldStreak = zenStreakDays;

      if (focusPercentage >= 80.0) {
        zenStreakDays++;
      } else {
        zenStreakDays = 0;
      }

      lastZenCheckDate = now;

      if (zenStreakDays != oldStreak) {
        recordEvent(
          ZenStreakUpdated(
            gameStateId: id.value,
            oldStreak: oldStreak,
            newStreak: zenStreakDays,
            maintained: zenStreakDays > oldStreak,
          ),
        );
      }
    }
  }

  /// Perform ascension - convert character progress to permanent bonuses
  void ascend(Character character) {
    final rewards = AscensionRewards.calculate(
      currentXp: character.experience.current,
      level: character.level,
      totalDeaths: character.totalDeaths,
    );

    echoShards += rewards.echoShards;
    totalEchoesCollected += rewards.echoShards;
    totalAscensions++;

    // Check for unlocks
    final newUnlocks = _checkUnlocks();

    recordEvent(
      AscensionPerformed(
        gameStateId: id.value,
        characterId: character.id.value,
        ascensionNumber: totalAscensions,
        echoShardsGained: rewards.echoShards,
        totalEchoShards: echoShards,
        newRacesUnlocked: newUnlocks['races'] ?? [],
        newClassesUnlocked: newUnlocks['classes'] ?? [],
      ),
    );
  }

  /// Purchase a meta-upgrade
  void purchaseUpgrade(MetaUpgradeType type) {
    final currentUpgrade = metaUpgrades[type]!;

    if (currentUpgrade.isMaxed) {
      throw StateError('${type.displayName} is already at max level');
    }

    if (!currentUpgrade.canAfford(echoShards)) {
      throw StateError('Not enough Echo Shards');
    }

    final cost = currentUpgrade.nextCost;
    echoShards -= cost;
    metaUpgrades[type] = currentUpgrade.upgrade();

    recordEvent(
      MetaUpgradePurchased(
        gameStateId: id.value,
        upgradeType: type.name,
        newLevel: metaUpgrades[type]!.currentLevel,
        cost: cost,
        remainingShards: echoShards,
      ),
    );
  }

  /// Get a meta-upgrade
  MetaUpgrade getUpgrade(MetaUpgradeType type) {
    return metaUpgrades[type]!;
  }

  /// Check if a race is unlocked
  bool isRaceUnlocked(String race) {
    return unlockedRaces.contains(race);
  }

  /// Check if a class is unlocked
  bool isClassUnlocked(String characterClass) {
    return unlockedClasses.contains(characterClass);
  }

  /// Get effective multiplier from focus
  double get effectiveFocusMultiplier {
    if (focusPercentage <= 0) return 0.5;
    return 0.5 + (focusPercentage * 0.02);
  }

  /// Get total starting bonuses
  Map<String, dynamic> get startingBonuses {
    return {
      'healthBonus':
          metaUpgrades[MetaUpgradeType.startingHp]?.currentBonus ?? 0.0,
      'potionBonus':
          metaUpgrades[MetaUpgradeType.startingPotion]?.currentBonus ?? 0,
      'xpMultiplier':
          1.0 + (metaUpgrades[MetaUpgradeType.xpGain]?.currentBonus ?? 0.0),
      'startingDepth':
          1 + (metaUpgrades[MetaUpgradeType.startingDepth]?.currentBonus ?? 0),
    };
  }

  // === Properties ===

  bool get hasAscended => totalAscensions > 0;
  int get totalUpgradeLevels =>
      metaUpgrades.values.fold(0, (sum, u) => sum + u.currentLevel);
  bool get canAscend => true; // Always can ascend (even at level 1)

  /// Get all available upgrades with their current status
  Map<MetaUpgradeType, Map<String, dynamic>> get availableUpgrades {
    final map = <MetaUpgradeType, Map<String, dynamic>>{};
    for (final type in MetaUpgradeType.values) {
      final upgrade = metaUpgrades[type]!;
      map[type] = {
        'currentLevel': upgrade.currentLevel,
        'maxLevel': upgrade.type.maxLevel,
        'nextCost': upgrade.nextCost,
        'canAfford': upgrade.canAfford(echoShards),
        'isMaxed': upgrade.isMaxed,
        'currentBonus': upgrade.currentBonus,
        'nextBonus': upgrade.nextBonus,
      };
    }
    return map;
  }

  @override
  String toString() =>
      'GameState($totalAscensions ascensions, $echoShards shards, $totalUpgradeLevels upgrades)';

  // === Private Helpers ===

  static Map<MetaUpgradeType, MetaUpgrade> _initializeMetaUpgrades() {
    return {
      for (final type in MetaUpgradeType.values)
        type: MetaUpgrade(type: type, currentLevel: 0),
    };
  }

  Map<String, List<String>> _checkUnlocks() {
    final newRaces = <String>[];
    final newClasses = <String>[];

    for (final race in UnlockableRace.values) {
      if (race.isUnlocked(totalAscensions) &&
          !unlockedRaces.contains(race.displayName)) {
        unlockedRaces = [...unlockedRaces, race.displayName];
        newRaces.add(race.displayName);
      }
    }

    for (final characterClass in UnlockableClass.values) {
      if (characterClass.isUnlocked(totalAscensions) &&
          !unlockedClasses.contains(characterClass.displayName)) {
        unlockedClasses = [...unlockedClasses, characterClass.displayName];
        newClasses.add(characterClass.displayName);
      }
    }

    return {'races': newRaces, 'classes': newClasses};
  }
}
