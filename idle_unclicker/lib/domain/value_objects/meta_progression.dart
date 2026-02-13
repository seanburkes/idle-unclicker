/// Enum representing meta-upgrade types
enum MetaUpgradeType {
  startingHp, // +5% HP per level
  startingPotion, // +1 potion per level
  xpGain, // +10% XP gain per level
  startingDepth, // +1 starting dungeon depth per level
}

/// Extension for meta-upgrade properties
extension MetaUpgradeTypeExtension on MetaUpgradeType {
  String get displayName {
    switch (this) {
      case MetaUpgradeType.startingHp:
        return 'Vitality';
      case MetaUpgradeType.startingPotion:
        return 'Alchemy';
      case MetaUpgradeType.xpGain:
        return 'Wisdom';
      case MetaUpgradeType.startingDepth:
        return 'Exploration';
    }
  }

  String get description {
    switch (this) {
      case MetaUpgradeType.startingHp:
        return '+5% Starting Health per level';
      case MetaUpgradeType.startingPotion:
        return '+1 Starting Potion per level';
      case MetaUpgradeType.xpGain:
        return '+10% XP Gain per level';
      case MetaUpgradeType.startingDepth:
        return '+1 Starting Dungeon Depth per level';
    }
  }

  int get baseCost {
    switch (this) {
      case MetaUpgradeType.startingHp:
        return 50;
      case MetaUpgradeType.startingPotion:
        return 100;
      case MetaUpgradeType.xpGain:
        return 75;
      case MetaUpgradeType.startingDepth:
        return 150;
    }
  }

  int get maxLevel {
    switch (this) {
      case MetaUpgradeType.startingHp:
        return 20; // Max 100% bonus
      case MetaUpgradeType.startingPotion:
        return 10;
      case MetaUpgradeType.xpGain:
        return 20; // Max 200%
      case MetaUpgradeType.startingDepth:
        return 10;
    }
  }

  /// Calculate cost for a specific level
  int calculateCost(int currentLevel) {
    // Cost increases by 50% per level
    return (baseCost * (1 + currentLevel * 0.5)).round();
  }

  /// Get bonus value for a level
  dynamic getBonusValue(int level) {
    switch (this) {
      case MetaUpgradeType.startingHp:
        return level * 0.05; // 5% per level
      case MetaUpgradeType.startingPotion:
        return level; // +1 per level
      case MetaUpgradeType.xpGain:
        return level * 0.10; // 10% per level
      case MetaUpgradeType.startingDepth:
        return level; // +1 per level
    }
  }
}

/// Value object representing a meta-upgrade
class MetaUpgrade {
  final MetaUpgradeType type;
  final int currentLevel;

  const MetaUpgrade({required this.type, this.currentLevel = 0});

  bool get isMaxed => currentLevel >= type.maxLevel;
  int get nextCost => type.calculateCost(currentLevel);
  bool canAfford(int echoShards) => echoShards >= nextCost;
  dynamic get currentBonus => type.getBonusValue(currentLevel);
  dynamic get nextBonus => type.getBonusValue(currentLevel + 1);

  MetaUpgrade upgrade() {
    if (isMaxed) {
      throw StateError('${type.displayName} is already at max level');
    }
    return MetaUpgrade(type: type, currentLevel: currentLevel + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaUpgrade &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          currentLevel == other.currentLevel;

  @override
  int get hashCode => type.hashCode ^ currentLevel.hashCode;

  @override
  String toString() =>
      'MetaUpgrade(${type.displayName}, L$currentLevel/${type.maxLevel})';
}

/// Enum representing room types in Guild Hall
enum RoomType { trainingHall, treasury, library, smithy }

/// Extension for room type properties
extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.trainingHall:
        return 'Training Hall';
      case RoomType.treasury:
        return 'Treasury';
      case RoomType.library:
        return 'Library';
      case RoomType.smithy:
        return 'Smithy';
    }
  }

  String get description {
    switch (this) {
      case RoomType.trainingHall:
        return '+1% Skill XP per level';
      case RoomType.treasury:
        return '+10% Gold find per level';
      case RoomType.library:
        return '+2x Bestiary fill rate per level';
      case RoomType.smithy:
        return '+5% Better equipment drops per level';
    }
  }

  String get icon {
    switch (this) {
      case RoomType.trainingHall:
        return '🏋️';
      case RoomType.treasury:
        return '💰';
      case RoomType.library:
        return '📚';
      case RoomType.smithy:
        return '⚒️';
    }
  }

  int get baseCost {
    switch (this) {
      case RoomType.trainingHall:
        return 1000;
      case RoomType.treasury:
        return 1500;
      case RoomType.library:
        return 2000;
      case RoomType.smithy:
        return 2500;
    }
  }

  /// Calculate bonus for a level
  double calculateBonus(int level) {
    switch (this) {
      case RoomType.trainingHall:
        return level * 0.01;
      case RoomType.treasury:
        return level * 0.10;
      case RoomType.library:
        return level * 2.0;
      case RoomType.smithy:
        return level * 0.05;
    }
  }
}

/// Value object representing a Guild Hall room
class Room {
  final RoomType type;
  final int level;
  static const int maxLevel = 10;

  const Room({required this.type, this.level = 0});

  bool get isMaxed => level >= maxLevel;
  int get upgradeCost => isMaxed ? 0 : (type.baseCost * (1.5 * level)).round();
  double get bonus => type.calculateBonus(level);
  double get nextBonus => type.calculateBonus(level + 1);

  Room upgrade() {
    if (isMaxed) {
      throw StateError('${type.displayName} is already at max level');
    }
    return Room(type: type, level: level + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          level == other.level;

  @override
  int get hashCode => type.hashCode ^ level.hashCode;

  @override
  String toString() => 'Room(${type.displayName}, L$level/$maxLevel)';
}

/// Value object representing an Echo NPC
class EchoNPC {
  final String name;
  final String race;
  final String characterClass;
  final int level;
  final String fate; // How they died/ascended
  final DateTime createdAt;

  const EchoNPC({
    required this.name,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.fate,
    required this.createdAt,
  });

  String get displayTitle => '$name the $race $characterClass (Lv.$level)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EchoNPC &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          race == other.race &&
          characterClass == other.characterClass &&
          level == other.level;

  @override
  int get hashCode =>
      name.hashCode ^ race.hashCode ^ characterClass.hashCode ^ level.hashCode;

  @override
  String toString() => 'EchoNPC($displayTitle)';
}

/// Value object representing ascension rewards calculation
class AscensionRewards {
  final int echoShards;
  final int levelBonus;
  final double survivalMultiplier;

  const AscensionRewards({
    required this.echoShards,
    required this.levelBonus,
    required this.survivalMultiplier,
  });

  factory AscensionRewards.calculate({
    required double currentXp,
    required int level,
    required int totalDeaths,
  }) {
    // Base from XP
    double shards = currentXp / 10.0;
    // Bonus for level
    shards += level * 5;
    // Bonus for survival (fewer deaths = more shards)
    final survivalMultiplier = (1.0 - (totalDeaths * 0.1)).clamp(0.5, 1.0);
    shards = shards * survivalMultiplier;

    return AscensionRewards(
      echoShards: shards.round(),
      levelBonus: level,
      survivalMultiplier: survivalMultiplier,
    );
  }

  int get totalShards => echoShards;

  @override
  String toString() =>
      'AscensionRewards($echoShards shards, ${(survivalMultiplier * 100).toStringAsFixed(0)}% survival)';
}

/// Enum representing unlockable races
enum UnlockableRace {
  human('Human', 0),
  elf('Elf', 1),
  dwarf('Dwarf', 3),
  halfling('Halfling', 5),
  orc('Orc', 10);

  final String displayName;
  final int requiredAscensions;

  const UnlockableRace(this.displayName, this.requiredAscensions);

  bool isUnlocked(int ascensionCount) => ascensionCount >= requiredAscensions;
}

/// Enum representing unlockable classes
enum UnlockableClass {
  warrior('Warrior', 0),
  rogue('Rogue', 1),
  mage('Mage', 3),
  ranger('Ranger', 5),
  cleric('Cleric', 10);

  final String displayName;
  final int requiredAscensions;

  const UnlockableClass(this.displayName, this.requiredAscensions);

  bool isUnlocked(int ascensionCount) => ascensionCount >= requiredAscensions;
}
