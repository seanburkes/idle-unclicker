import 'package:hive/hive.dart';

part 'game_state.g.dart';

@HiveType(typeId: 1)
class GameState extends HiveObject {
  @HiveField(0)
  DateTime lastUpdateTime;

  @HiveField(1)
  int lastTrustedNtpTime;

  @HiveField(2)
  int lastLocalTime;

  @HiveField(3)
  double focusPercentage;

  @HiveField(4)
  DateTime lastInteractionTime;

  @HiveField(5)
  int totalTimeInAppSeconds;

  @HiveField(6)
  int totalTimeAwaySeconds;

  @HiveField(7)
  int totalClicks;

  @HiveField(8)
  double totalXpPenalized;

  @HiveField(9)
  int zenStreakDays;

  @HiveField(10)
  DateTime lastZenCheckDate;

  @HiveField(11)
  double idleMultiplier;

  // Ascension / Meta-progression
  @HiveField(12)
  int echoShards;

  @HiveField(13)
  int totalAscensions;

  @HiveField(14)
  int startingHpBonus; // +5% per level, max 100%

  @HiveField(15)
  int startingPotionBonus; // +1 per level, max 10

  @HiveField(16)
  int xpGainBonus; // +10% per level, max 200%

  @HiveField(17)
  int startingDepthBonus; // +1 per level, max 10

  @HiveField(18)
  List<String> unlockedRaces;

  @HiveField(19)
  List<String> unlockedClasses;

  @HiveField(20)
  int totalEchoesCollected; // All-time shard total

  GameState({
    required this.lastUpdateTime,
    required this.lastTrustedNtpTime,
    required this.lastLocalTime,
    this.focusPercentage = 0.0,
    required this.lastInteractionTime,
    this.totalTimeInAppSeconds = 0,
    this.totalTimeAwaySeconds = 0,
    this.totalClicks = 0,
    this.totalXpPenalized = 0.0,
    this.zenStreakDays = 0,
    required this.lastZenCheckDate,
    this.idleMultiplier = 1.0,
    this.echoShards = 0,
    this.totalAscensions = 0,
    this.startingHpBonus = 0,
    this.startingPotionBonus = 0,
    this.xpGainBonus = 0,
    this.startingDepthBonus = 0,
    this.unlockedRaces = const ['Human'],
    this.unlockedClasses = const ['Warrior'],
    this.totalEchoesCollected = 0,
  });

  factory GameState.create() {
    final now = DateTime.now();
    return GameState(
      lastUpdateTime: now,
      lastTrustedNtpTime: now.millisecondsSinceEpoch,
      lastLocalTime: now.millisecondsSinceEpoch,
      lastInteractionTime: now,
      lastZenCheckDate: now,
    );
  }

  double get effectiveMultiplier {
    if (focusPercentage <= 0) return 0.5;
    return 0.5 + (focusPercentage * 0.02);
  }

  void recordInteraction() {
    totalClicks++;
    focusPercentage = 0.0;
    lastInteractionTime = DateTime.now();
  }

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

    focusPercentage = (focusPercentage + gain).clamp(0.0, 100.0);
  }

  void checkZenStreak() {
    final now = DateTime.now();
    final daysSinceLastCheck = now.difference(lastZenCheckDate).inDays;

    if (daysSinceLastCheck >= 1) {
      if (focusPercentage >= 80.0) {
        zenStreakDays++;
      } else {
        zenStreakDays = 0;
      }
      lastZenCheckDate = now;
    }
  }

  // ===========================================================================
  // Ascension / Meta-Progression Methods
  // ===========================================================================

  /// Calculate Echo Shards from current character XP
  int calculateEchoShards(double currentXp, int level, int totalDeaths) {
    // Base from XP
    double shards = currentXp / 10.0;
    // Bonus for level
    shards += level * 5;
    // Bonus for survival (fewer deaths = more shards)
    shards = shards * (1.0 - (totalDeaths * 0.1)).clamp(0.5, 1.0);
    return shards.round();
  }

  /// Perform ascension - convert current progress to permanent bonuses
  void ascend(double currentXp, int level, int totalDeaths) {
    final shards = calculateEchoShards(currentXp, level, totalDeaths);
    echoShards += shards;
    totalEchoesCollected += shards;
    totalAscensions++;

    // Unlock new races/classes based on ascension count
    if (totalAscensions >= 1) {
      if (!unlockedRaces.contains('Elf'))
        unlockedRaces = [...unlockedRaces, 'Elf'];
      if (!unlockedClasses.contains('Rogue'))
        unlockedClasses = [...unlockedClasses, 'Rogue'];
    }
    if (totalAscensions >= 3) {
      if (!unlockedRaces.contains('Dwarf'))
        unlockedRaces = [...unlockedRaces, 'Dwarf'];
      if (!unlockedClasses.contains('Mage'))
        unlockedClasses = [...unlockedClasses, 'Mage'];
    }
    if (totalAscensions >= 5) {
      if (!unlockedRaces.contains('Halfling'))
        unlockedRaces = [...unlockedRaces, 'Halfling'];
      if (!unlockedClasses.contains('Ranger'))
        unlockedClasses = [...unlockedClasses, 'Ranger'];
    }
    if (totalAscensions >= 10) {
      if (!unlockedRaces.contains('Orc'))
        unlockedRaces = [...unlockedRaces, 'Orc'];
      if (!unlockedClasses.contains('Cleric'))
        unlockedClasses = [...unlockedClasses, 'Cleric'];
    }
  }

  // Meta-upgrade costs and application
  static const Map<String, int> upgradeCosts = {
    'hp': 50, // +5% HP per level
    'potion': 100, // +1 starting potion
    'xp': 75, // +10% XP gain
    'depth': 150, // +1 starting dungeon depth
  };

  static const Map<String, int> upgradeMax = {
    'hp': 20, // Max 100% bonus
    'potion': 10,
    'xp': 20, // Max 200%
    'depth': 10,
  };

  bool canAffordUpgrade(String type) {
    final cost = upgradeCosts[type] ?? 999999;
    return echoShards >= cost;
  }

  int getCurrentLevel(String type) {
    switch (type) {
      case 'hp':
        return startingHpBonus;
      case 'potion':
        return startingPotionBonus;
      case 'xp':
        return xpGainBonus;
      case 'depth':
        return startingDepthBonus;
      default:
        return 0;
    }
  }

  bool canUpgrade(String type) {
    final current = getCurrentLevel(type);
    final max = upgradeMax[type] ?? 0;
    return current < max && canAffordUpgrade(type);
  }

  /// Purchase a meta-upgrade
  bool purchaseUpgrade(String type) {
    if (!canUpgrade(type)) return false;

    final cost = upgradeCosts[type] ?? 0;
    echoShards -= cost;

    switch (type) {
      case 'hp':
        startingHpBonus++;
        break;
      case 'potion':
        startingPotionBonus++;
        break;
      case 'xp':
        xpGainBonus++;
        break;
      case 'depth':
        startingDepthBonus++;
        break;
    }

    return true;
  }

  /// Apply meta-bonuses to a new character
  Map<String, dynamic> getStartingBonuses() {
    return {
      'hpMultiplier': 1.0 + (startingHpBonus * 0.05),
      'bonusPotions': startingPotionBonus,
      'xpMultiplier': 1.0 + (xpGainBonus * 0.10),
      'startingDepth': 1 + startingDepthBonus,
    };
  }
}
