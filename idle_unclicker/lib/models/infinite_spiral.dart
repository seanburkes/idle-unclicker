import 'package:hive/hive.dart';
import 'dart:math';
import 'character.dart';

part 'infinite_spiral.g.dart';

/// SpiralState - Current state of the infinite spiral
@HiveType(typeId: 60)
enum SpiralState {
  @HiveField(0)
  ascending, // Climbing floors 1-100
  @HiveField(1)
  resetting, // Transition state
  @HiveField(2)
  spiraling, // After floor 100 reset, in loop
}

/// Extension for SpiralState display
extension SpiralStateExtension on SpiralState {
  String get displayName {
    switch (this) {
      case SpiralState.ascending:
        return 'Ascending';
      case SpiralState.resetting:
        return 'Resetting';
      case SpiralState.spiraling:
        return 'Spiraling';
    }
  }

  String get description {
    switch (this) {
      case SpiralState.ascending:
        return 'Climbing toward floor 100...';
      case SpiralState.resetting:
        return 'The Spiral consumes all...';
      case SpiralState.spiraling:
        return 'In the endless loop';
    }
  }

  String get icon {
    switch (this) {
      case SpiralState.ascending:
        return '⬆️';
      case SpiralState.resetting:
        return '🌀';
      case SpiralState.spiraling:
        return '♾️';
    }
  }
}

/// SpiralLoop - Represents one complete cycle through the spiral
@HiveType(typeId: 61)
class SpiralLoop extends HiveObject {
  @HiveField(0)
  int loopNumber; // 1, 2, 3...

  @HiveField(1)
  double enemyHpMultiplier; // 1.0 + loop * 0.1

  @HiveField(2)
  double enemyDamageMultiplier; // 1.0 + loop * 0.1

  @HiveField(3)
  double goldMultiplier; // 1.0 + loop * 0.05

  @HiveField(4)
  double xpMultiplier; // 1.0 + loop * 0.05

  @HiveField(5)
  int highestFloorReached; // Track personal best in this loop

  @HiveField(6)
  DateTime startedAt;

  @HiveField(7)
  int totalSecondsInLoop; // Duration tracking

  SpiralLoop({
    required this.loopNumber,
    required this.enemyHpMultiplier,
    required this.enemyDamageMultiplier,
    required this.goldMultiplier,
    required this.xpMultiplier,
    this.highestFloorReached = 1,
    required this.startedAt,
    this.totalSecondsInLoop = 0,
  });

  /// Create the first loop (loop 1)
  factory SpiralLoop.first() {
    return SpiralLoop(
      loopNumber: 1,
      enemyHpMultiplier: 1.0,
      enemyDamageMultiplier: 1.0,
      goldMultiplier: 1.0,
      xpMultiplier: 1.0,
      highestFloorReached: 1,
      startedAt: DateTime.now(),
    );
  }

  /// Create next loop based on current
  SpiralLoop next() {
    final nextLoop = loopNumber + 1;
    return SpiralLoop(
      loopNumber: nextLoop,
      enemyHpMultiplier: 1.0 + (nextLoop * 0.1),
      enemyDamageMultiplier: 1.0 + (nextLoop * 0.1),
      goldMultiplier: 1.0 + (nextLoop * 0.05),
      xpMultiplier: 1.0 + (nextLoop * 0.05),
      highestFloorReached: 1,
      startedAt: DateTime.now(),
    );
  }

  /// Update time spent in loop
  void addTime(int seconds) {
    totalSecondsInLoop += seconds;
  }

  /// Update highest floor reached
  void recordFloor(int floor) {
    if (floor > highestFloorReached) {
      highestFloorReached = floor;
    }
  }

  /// Get formatted duration
  String get formattedDuration {
    final duration = Duration(seconds: totalSecondsInLoop);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// TaleType - The 20 different tale achievements
@HiveType(typeId: 62)
enum TaleType {
  @HiveField(0)
  dragonSlayer, // Killed 100 dragons
  @HiveField(1)
  bossConqueror, // Defeated 50 bosses
  @HiveField(2)
  treasureHunter, // Found 1M gold
  @HiveField(3)
  dungeonDelver, // Reached floor 100
  @HiveField(4)
  immortal, // Survived 100 combats below 10% HP
  @HiveField(5)
  legendaryCollector, // Collected 10 legendaries
  @HiveField(6)
  masterEnchanter, // Enchanted 100 items
  @HiveField(7)
  setCompletionist, // Completed 5 full sets
  @HiveField(8)
  mercenaryCommander, // Had 50 companions
  @HiveField(9)
  transmutationMaster, // Performed 100 transmutes
  @HiveField(10)
  alchemyExpert, // Brewed 500 potions
  @HiveField(11)
  ascendedBeing, // Ascended 10 times
  @HiveField(12)
  speedRunner, // Reached floor 100 in under 1 hour
  @HiveField(13)
  pacifist, // Reached floor 50 without killing
  @HiveField(14)
  hoarder, // Collected 1000 items
  @HiveField(15)
  perfectionist, // Reforged item 10 times
  @HiveField(16)
  awakenedOne, // Awakened 5 legendaries
  @HiveField(17)
  spiralWalker, // Completed 10 spiral loops
  @HiveField(18)
  immortalLegend, // Died 100 times
  @HiveField(19)
  theUntouchable, // Dodged 1000 attacks
}

/// Extension for TaleType display and bonuses
extension TaleTypeExtension on TaleType {
  String get displayName {
    switch (this) {
      case TaleType.dragonSlayer:
        return 'Dragon Slayer';
      case TaleType.bossConqueror:
        return 'Boss Conqueror';
      case TaleType.treasureHunter:
        return 'Treasure Hunter';
      case TaleType.dungeonDelver:
        return 'Dungeon Delver';
      case TaleType.immortal:
        return 'Immortal';
      case TaleType.legendaryCollector:
        return 'Legendary Collector';
      case TaleType.masterEnchanter:
        return 'Master Enchanter';
      case TaleType.setCompletionist:
        return 'Set Completionist';
      case TaleType.mercenaryCommander:
        return 'Mercenary Commander';
      case TaleType.transmutationMaster:
        return 'Transmutation Master';
      case TaleType.alchemyExpert:
        return 'Alchemy Expert';
      case TaleType.ascendedBeing:
        return 'Ascended Being';
      case TaleType.speedRunner:
        return 'Speed Runner';
      case TaleType.pacifist:
        return 'Pacifist';
      case TaleType.hoarder:
        return 'Hoarder';
      case TaleType.perfectionist:
        return 'Perfectionist';
      case TaleType.awakenedOne:
        return 'Awakened One';
      case TaleType.spiralWalker:
        return 'Spiral Walker';
      case TaleType.immortalLegend:
        return 'Immortal Legend';
      case TaleType.theUntouchable:
        return 'The Untouchable';
    }
  }

  String get description {
    switch (this) {
      case TaleType.dragonSlayer:
        return 'Slay 100 dragons';
      case TaleType.bossConqueror:
        return 'Defeat 50 bosses';
      case TaleType.treasureHunter:
        return 'Accumulate 1,000,000 gold';
      case TaleType.dungeonDelver:
        return 'Reach floor 100';
      case TaleType.immortal:
        return 'Survive 100 combats below 10% HP';
      case TaleType.legendaryCollector:
        return 'Collect 10 legendary items';
      case TaleType.masterEnchanter:
        return 'Enchant 100 items';
      case TaleType.setCompletionist:
        return 'Complete 5 full equipment sets';
      case TaleType.mercenaryCommander:
        return 'Have 50 companions join your party';
      case TaleType.transmutationMaster:
        return 'Perform 100 transmutations';
      case TaleType.alchemyExpert:
        return 'Brew 500 potions';
      case TaleType.ascendedBeing:
        return 'Ascend 10 times';
      case TaleType.speedRunner:
        return 'Reach floor 100 in under 1 hour';
      case TaleType.pacifist:
        return 'Reach floor 50 without killing';
      case TaleType.hoarder:
        return 'Collect 1000 items';
      case TaleType.perfectionist:
        return 'Reforge a legendary item 10 times';
      case TaleType.awakenedOne:
        return 'Awaken 5 legendary items';
      case TaleType.spiralWalker:
        return 'Complete 10 spiral loops';
      case TaleType.immortalLegend:
        return 'Die 100 times';
      case TaleType.theUntouchable:
        return 'Dodge 1000 attacks';
    }
  }

  String get icon {
    switch (this) {
      case TaleType.dragonSlayer:
        return '🐉';
      case TaleType.bossConqueror:
        return '👑';
      case TaleType.treasureHunter:
        return '💰';
      case TaleType.dungeonDelver:
        return '🏰';
      case TaleType.immortal:
        return '⚡';
      case TaleType.legendaryCollector:
        return '✨';
      case TaleType.masterEnchanter:
        return '🔮';
      case TaleType.setCompletionist:
        return '🎭';
      case TaleType.mercenaryCommander:
        return '⚔️';
      case TaleType.transmutationMaster:
        return '⚗️';
      case TaleType.alchemyExpert:
        return '🧪';
      case TaleType.ascendedBeing:
        return '☀️';
      case TaleType.speedRunner:
        return '⚡';
      case TaleType.pacifist:
        return '🕊️';
      case TaleType.hoarder:
        return '📦';
      case TaleType.perfectionist:
        return '💎';
      case TaleType.awakenedOne:
        return '👁️';
      case TaleType.spiralWalker:
        return '🌀';
      case TaleType.immortalLegend:
        return '💀';
      case TaleType.theUntouchable:
        return '💨';
    }
  }

  /// Get the bonus provided by this tale
  TaleBonus get bonus {
    switch (this) {
      // Combat Tales (7)
      case TaleType.dragonSlayer:
        return TaleBonus(
          source: this,
          magnitude: 0.01,
          description: '+1% damage vs dragons',
        );
      case TaleType.bossConqueror:
        return TaleBonus(
          source: this,
          magnitude: 0.02,
          description: '+2% damage vs bosses',
        );
      case TaleType.immortal:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% HP regeneration',
        );
      case TaleType.legendaryCollector:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% legendary drop rate',
        );
      case TaleType.theUntouchable:
        return TaleBonus(
          source: this,
          magnitude: 0.02,
          description: '+2% evasion',
        );
      case TaleType.immortalLegend:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% resurrection speed',
        );
      case TaleType.awakenedOne:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% sentience progress speed',
        );
      // Progression Tales (6)
      case TaleType.dungeonDelver:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% XP gain',
        );
      case TaleType.ascendedBeing:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% echo shard gain',
        );
      case TaleType.speedRunner:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% movement speed',
        );
      case TaleType.spiralWalker:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% all spiral rewards',
        );
      case TaleType.hoarder:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% inventory space',
        );
      case TaleType.transmutationMaster:
        return TaleBonus(
          source: this,
          magnitude: 0.02,
          description: '+2% miracle chance',
        );
      // Crafting Tales (4)
      case TaleType.masterEnchanter:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% enchantment power',
        );
      case TaleType.setCompletionist:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% set bonus effectiveness',
        );
      case TaleType.alchemyExpert:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% potion duration',
        );
      case TaleType.perfectionist:
        return TaleBonus(
          source: this,
          magnitude: 0.05,
          description: '+5% reforge stat range',
        );
      // Unique Tales (3)
      case TaleType.treasureHunter:
        return TaleBonus(
          source: this,
          magnitude: 0.10,
          description: '+10% gold find',
        );
      case TaleType.mercenaryCommander:
        return TaleBonus(
          source: this,
          magnitude: 1.0,
          description: 'Can hire 3rd companion',
        );
      case TaleType.pacifist:
        return TaleBonus(
          source: this,
          magnitude: 0.25,
          description: '+25% XP from non-combat sources',
        );
    }
  }

  /// Get the target amount needed to complete this tale
  int get targetAmount {
    switch (this) {
      case TaleType.dragonSlayer:
        return 100;
      case TaleType.bossConqueror:
        return 50;
      case TaleType.treasureHunter:
        return 1000000;
      case TaleType.dungeonDelver:
        return 1;
      case TaleType.immortal:
        return 100;
      case TaleType.legendaryCollector:
        return 10;
      case TaleType.masterEnchanter:
        return 100;
      case TaleType.setCompletionist:
        return 5;
      case TaleType.mercenaryCommander:
        return 50;
      case TaleType.transmutationMaster:
        return 100;
      case TaleType.alchemyExpert:
        return 500;
      case TaleType.ascendedBeing:
        return 10;
      case TaleType.speedRunner:
        return 3600; // 1 hour in seconds
      case TaleType.pacifist:
        return 50;
      case TaleType.hoarder:
        return 1000;
      case TaleType.perfectionist:
        return 10;
      case TaleType.awakenedOne:
        return 5;
      case TaleType.spiralWalker:
        return 10;
      case TaleType.immortalLegend:
        return 100;
      case TaleType.theUntouchable:
        return 1000;
    }
  }
}

/// TaleBonus - Permanent bonus granted by completing a tale
@HiveType(typeId: 63)
class TaleBonus extends HiveObject {
  @HiveField(0)
  TaleType source;

  @HiveField(1)
  double magnitude; // Permanent bonus %

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isActive;

  TaleBonus({
    required this.source,
    required this.magnitude,
    required this.description,
    this.isActive = true,
  });

  /// Get formatted magnitude for display
  String get formattedMagnitude {
    if (source == TaleType.mercenaryCommander) {
      return '+1 slot';
    }
    return '+${(magnitude * 100).toStringAsFixed(0)}%';
  }
}

/// Tale - A completed or in-progress achievement
@HiveType(typeId: 64)
class Tale extends HiveObject {
  @HiveField(0)
  TaleType type;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime? earnedAt;

  @HiveField(4)
  String? characterName; // Who earned it

  @HiveField(5)
  int? characterLevel;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  TaleBonus? bonus;

  Tale({
    required this.type,
    required this.title,
    required this.description,
    this.earnedAt,
    this.characterName,
    this.characterLevel,
    this.isCompleted = false,
    this.bonus,
  });

  /// Create a new tale from type
  factory Tale.fromType(TaleType type) {
    return Tale(
      type: type,
      title: type.displayName,
      description: type.description,
      bonus: type.bonus,
    );
  }

  /// Complete this tale
  void complete(Character character) {
    isCompleted = true;
    earnedAt = DateTime.now();
    characterName = character.name;
    characterLevel = character.level;
    bonus?.isActive = true;
  }

  /// Get flavor text for completed tale
  String get flavorText {
    if (!isCompleted) return 'Not yet earned...';
    switch (type) {
      case TaleType.dragonSlayer:
        return 'The dragons fear your name.';
      case TaleType.bossConqueror:
        return 'No tyrant stands before you.';
      case TaleType.treasureHunter:
        return 'Wealth beyond measure.';
      case TaleType.dungeonDelver:
        return 'The depths hold no secrets.';
      case TaleType.immortal:
        return 'Death cannot claim you.';
      case TaleType.legendaryCollector:
        return 'Legends answer your call.';
      case TaleType.masterEnchanter:
        return 'Magic bends to your will.';
      case TaleType.setCompletionist:
        return 'Perfection in every piece.';
      case TaleType.mercenaryCommander:
        return 'Armies follow your banner.';
      case TaleType.transmutationMaster:
        return 'Lead becomes gold.';
      case TaleType.alchemyExpert:
        return 'The elixir of mastery.';
      case TaleType.ascendedBeing:
        return 'Transcendence achieved.';
      case TaleType.speedRunner:
        return 'Faster than time itself.';
      case TaleType.pacifist:
        return 'Peace through understanding.';
      case TaleType.hoarder:
        return 'Everything has a place.';
      case TaleType.perfectionist:
        return 'Nothing is ever enough.';
      case TaleType.awakenedOne:
        return 'The items speak your name.';
      case TaleType.spiralWalker:
        return 'The loop knows you well.';
      case TaleType.immortalLegend:
        return 'Death is but a doorway.';
      case TaleType.theUntouchable:
        return 'Strikes pass through air.';
    }
  }
}

/// TalesCollection - All tales and their progress
@HiveType(typeId: 65)
class TalesCollection extends HiveObject {
  @HiveField(0)
  List<Tale> allTales;

  @HiveField(1)
  Map<TaleType, int> progress; // Current progress toward each tale

  @HiveField(2)
  DateTime? becameLegendAt;

  @HiveField(3)
  int totalTalesCompleted;

  TalesCollection({
    required this.allTales,
    required this.progress,
    this.becameLegendAt,
    this.totalTalesCompleted = 0,
  });

  /// Create initial tales collection with all 20 tales
  factory TalesCollection.create() {
    final tales = <Tale>[];
    final progressMap = <TaleType, int>{};

    for (final type in TaleType.values) {
      tales.add(Tale.fromType(type));
      progressMap[type] = 0;
    }

    return TalesCollection(allTales: tales, progress: progressMap);
  }

  /// Get completed tales
  List<Tale> get completedTales =>
      allTales.where((t) => t.isCompleted).toList();

  /// Get in-progress tales
  List<Tale> get inProgressTales =>
      allTales.where((t) => !t.isCompleted && progress[t.type]! > 0).toList();

  /// Get total bonus multiplier (sum of all tale effects)
  double get totalBonusMultiplier {
    double multiplier = 1.0;
    for (final tale in completedTales) {
      if (tale.bonus != null && tale.bonus!.isActive) {
        // Some bonuses are additive, others multiplicative
        switch (tale.type) {
          case TaleType.mercenaryCommander:
            // Special case - companion slot
            break;
          default:
            multiplier += tale.bonus!.magnitude;
        }
      }
    }
    return multiplier;
  }

  /// Check if player is a Legend (all 20 tales complete)
  bool get isLegend {
    return completedTales.length >= 20 && becameLegendAt != null;
  }

  /// Get progress toward becoming Legend (0.0 to 1.0)
  double get legendProgress => completedTales.length / 20.0;

  /// Get progress for a specific tale
  int getProgress(TaleType type) => progress[type] ?? 0;

  /// Add progress to a tale
  void addProgress(TaleType type, int amount) {
    if (progress.containsKey(type)) {
      final tale = allTales.firstWhere((t) => t.type == type);
      if (!tale.isCompleted) {
        progress[type] = (progress[type]! + amount).clamp(0, type.targetAmount);
      }
    }
  }

  /// Set progress for a tale (used for special tales)
  void setProgress(TaleType type, int amount) {
    if (progress.containsKey(type)) {
      final tale = allTales.firstWhere((t) => t.type == type);
      if (!tale.isCompleted) {
        progress[type] = amount.clamp(0, type.targetAmount);
      }
    }
  }

  /// Check and complete a tale if progress reached
  bool checkCompletion(TaleType type, Character character) {
    final tale = allTales.firstWhere((t) => t.type == type);
    if (tale.isCompleted) return false;

    if (progress[type]! >= type.targetAmount) {
      tale.complete(character);
      totalTalesCompleted++;

      // Check if became Legend
      if (totalTalesCompleted >= 20 && becameLegendAt == null) {
        becameLegendAt = DateTime.now();
      }

      return true;
    }
    return false;
  }

  /// Get bonus for a specific effect type
  double getBonusForEffect(String effectType) {
    double total = 0.0;
    for (final tale in completedTales) {
      if (tale.bonus != null && tale.bonus!.description.contains(effectType)) {
        total += tale.bonus!.magnitude;
      }
    }
    return total;
  }
}

/// InfiniteSpiral - Main spiral state container
@HiveType(typeId: 66)
class InfiniteSpiral extends HiveObject {
  @HiveField(0)
  SpiralState state;

  @HiveField(1)
  SpiralLoop currentLoop;

  @HiveField(2)
  List<SpiralLoop> loopHistory;

  @HiveField(3)
  int totalLoopsCompleted;

  @HiveField(4)
  bool hasReachedFloor100;

  @HiveField(5)
  DateTime? firstSpiralDate;

  @HiveField(6)
  TalesCollection tales;

  @HiveField(7)
  bool autoAdvanceEnabled;

  // Progress tracking for tales
  @HiveField(8)
  int totalDragonsKilled;

  @HiveField(9)
  int totalBossesDefeated;

  @HiveField(10)
  int totalGoldAccumulated;

  @HiveField(11)
  int timesSurvivedCritical;

  @HiveField(12)
  int totalLegendariesCollected;

  @HiveField(13)
  int totalItemsEnchanted;

  @HiveField(14)
  int totalSetsCompleted;

  @HiveField(15)
  int totalCompanionsHad;

  @HiveField(16)
  int totalTransmutesPerformed;

  @HiveField(17)
  int totalPotionsBrewed;

  @HiveField(18)
  int totalTimesAscended;

  @HiveField(19)
  int totalAttacksDodged;

  @HiveField(20)
  int totalTimesDied;

  @HiveField(21)
  int totalLegendariesAwakened;

  @HiveField(22)
  int totalReforgesDone;

  @HiveField(23)
  int totalItemsCollected;

  @HiveField(24)
  DateTime? loopStartTime; // For speed runner

  @HiveField(25)
  int killsThisRun; // For pacifist

  InfiniteSpiral({
    required this.state,
    required this.currentLoop,
    required this.loopHistory,
    this.totalLoopsCompleted = 0,
    this.hasReachedFloor100 = false,
    this.firstSpiralDate,
    required this.tales,
    this.autoAdvanceEnabled = true,
    this.totalDragonsKilled = 0,
    this.totalBossesDefeated = 0,
    this.totalGoldAccumulated = 0,
    this.timesSurvivedCritical = 0,
    this.totalLegendariesCollected = 0,
    this.totalItemsEnchanted = 0,
    this.totalSetsCompleted = 0,
    this.totalCompanionsHad = 0,
    this.totalTransmutesPerformed = 0,
    this.totalPotionsBrewed = 0,
    this.totalTimesAscended = 0,
    this.totalAttacksDodged = 0,
    this.totalTimesDied = 0,
    this.totalLegendariesAwakened = 0,
    this.totalReforgesDone = 0,
    this.totalItemsCollected = 0,
    this.loopStartTime,
    this.killsThisRun = 0,
  });

  /// Create initial spiral state
  factory InfiniteSpiral.create() {
    return InfiniteSpiral(
      state: SpiralState.ascending,
      currentLoop: SpiralLoop.first(),
      loopHistory: [],
      tales: TalesCollection.create(),
      firstSpiralDate: DateTime.now(),
      loopStartTime: DateTime.now(),
    );
  }

  /// Check if currently in a spiral loop (post-floor 100)
  bool get isInSpiral => state == SpiralState.spiraling;

  /// Get total time spent in spiral
  Duration get totalTimeInSpiral {
    int totalSeconds = currentLoop.totalSecondsInLoop;
    for (final loop in loopHistory) {
      totalSeconds += loop.totalSecondsInLoop;
    }
    return Duration(seconds: totalSeconds);
  }

  /// Get formatted total time
  String get formattedTotalTime {
    final duration = totalTimeInSpiral;
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    if (days > 0) {
      return '${days}d ${hours}h';
    }
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  /// Record floor progress
  void recordFloor(int floor) {
    currentLoop.recordFloor(floor);
    if (floor >= 100 && !hasReachedFloor100) {
      hasReachedFloor100 = true;
    }
  }

  /// Add time to current loop
  void addLoopTime(int seconds) {
    currentLoop.addTime(seconds);
  }

  /// Execute spiral reset (called when reaching floor 100)
  void executeReset() {
    // Save current loop to history
    loopHistory.add(currentLoop);
    totalLoopsCompleted++;

    // Create next loop
    currentLoop = currentLoop.next();

    // Reset state
    state = SpiralState.spiraling;

    // Reset loop-specific progress
    loopStartTime = DateTime.now();
    killsThisRun = 0;
  }

  /// Get enemy HP multiplier for current loop
  double get enemyHpMultiplier => currentLoop.enemyHpMultiplier;

  /// Get enemy damage multiplier for current loop
  double get enemyDamageMultiplier => currentLoop.enemyDamageMultiplier;

  /// Get gold multiplier for current loop
  double get goldMultiplier => currentLoop.goldMultiplier;

  /// Get XP multiplier for current loop
  double get xpMultiplier => currentLoop.xpMultiplier;

  /// Get combined multiplier with tale bonuses
  double getCombinedMultiplier(String type) {
    double base = 1.0;
    switch (type) {
      case 'enemyHp':
        base = enemyHpMultiplier;
        break;
      case 'enemyDamage':
        base = enemyDamageMultiplier;
        break;
      case 'gold':
        base = goldMultiplier;
        final taleBonus = tales.getBonusForEffect('gold find');
        return base * (1.0 + taleBonus);
      case 'xp':
        base = xpMultiplier;
        final taleBonus = tales.getBonusForEffect('XP gain');
        return base * (1.0 + taleBonus);
    }
    return base;
  }

  // Tale progress tracking methods

  void recordDragonKill() {
    totalDragonsKilled++;
    tales.addProgress(TaleType.dragonSlayer, 1);
  }

  void recordBossDefeated() {
    totalBossesDefeated++;
    tales.addProgress(TaleType.bossConqueror, 1);
  }

  void recordGoldFound(int amount) {
    totalGoldAccumulated += amount;
    tales.addProgress(TaleType.treasureHunter, amount);
  }

  void recordFloor100Reached(Character character) {
    tales.addProgress(TaleType.dungeonDelver, 1);
    // Check speed runner
    if (loopStartTime != null) {
      final secondsTaken = DateTime.now().difference(loopStartTime!).inSeconds;
      if (secondsTaken < 3600) {
        tales.setProgress(TaleType.speedRunner, 3600 - secondsTaken);
      }
    }
    tales.checkCompletion(TaleType.dungeonDelver, character);
    tales.checkCompletion(TaleType.speedRunner, character);
  }

  void recordCriticalSurvival() {
    timesSurvivedCritical++;
    tales.addProgress(TaleType.immortal, 1);
  }

  void recordLegendaryCollected() {
    totalLegendariesCollected++;
    tales.addProgress(TaleType.legendaryCollector, 1);
  }

  void recordItemEnchanted() {
    totalItemsEnchanted++;
    tales.addProgress(TaleType.masterEnchanter, 1);
  }

  void recordSetCompleted() {
    totalSetsCompleted++;
    tales.addProgress(TaleType.setCompletionist, 1);
  }

  void recordCompanionJoined() {
    totalCompanionsHad++;
    tales.addProgress(TaleType.mercenaryCommander, 1);
  }

  void recordTransmute() {
    totalTransmutesPerformed++;
    tales.addProgress(TaleType.transmutationMaster, 1);
  }

  void recordPotionBrewed() {
    totalPotionsBrewed++;
    tales.addProgress(TaleType.alchemyExpert, 1);
  }

  void recordAscension() {
    totalTimesAscended++;
    tales.addProgress(TaleType.ascendedBeing, 1);
  }

  void recordAttackDodged() {
    totalAttacksDodged++;
    tales.addProgress(TaleType.theUntouchable, 1);
  }

  void recordDeath() {
    totalTimesDied++;
    tales.addProgress(TaleType.immortalLegend, 1);
  }

  void recordLegendaryAwakened() {
    totalLegendariesAwakened++;
    tales.addProgress(TaleType.awakenedOne, 1);
  }

  void recordReforge() {
    totalReforgesDone++;
    tales.addProgress(TaleType.perfectionist, 1);
  }

  void recordItemCollected() {
    totalItemsCollected++;
    tales.addProgress(TaleType.hoarder, 1);
  }

  void recordKill() {
    killsThisRun++;
  }

  /// Check all tale completions
  List<TaleType> checkAllTaleCompletions(Character character) {
    final completed = <TaleType>[];

    for (final type in TaleType.values) {
      if (tales.checkCompletion(type, character)) {
        completed.add(type);
      }
    }

    return completed;
  }

  /// Get active tale bonuses summary
  Map<String, double> getActiveBonuses() {
    final bonuses = <String, double>{};

    for (final tale in tales.completedTales) {
      if (tale.bonus != null && tale.bonus!.isActive) {
        final key = tale.type.displayName;
        bonuses[key] = tale.bonus!.magnitude;
      }
    }

    return bonuses;
  }

  /// Get legend status info
  Map<String, dynamic> getLegendStatus() {
    return {
      'isLegend': tales.isLegend,
      'talesCompleted': tales.totalTalesCompleted,
      'talesTotal': 20,
      'progress': tales.legendProgress,
      'becameLegendAt': tales.becameLegendAt,
      'canEquipDualLegendary': tales.isLegend,
    };
  }
}
