import 'package:hive/hive.dart';
import 'equipment.dart';

part 'equipment_sets.g.dart';

/// SetName - The eight equipment sets available in the game
@HiveType(typeId: 90)
enum SetName {
  @HiveField(0)
  gladiatorsFury, // Combat focus
  @HiveField(1)
  ironFortress, // Tank focus
  @HiveField(2)
  shadowWalker, // Rogue/evasion focus
  @HiveField(3)
  arcaneMastery, // Mage/magic focus
  @HiveField(4)
  naturesEmbrace, // Healing/regen focus
  @HiveField(5)
  dragonsWill, // Hybrid/all-rounder
  @HiveField(6)
  titansReach, // Strength focus
  @HiveField(7)
  voidWhisperers, // Cursed set
}

/// SetBonusType - Types of bonuses that set pieces can provide
@HiveType(typeId: 91)
enum SetBonusType {
  @HiveField(0)
  statBonus, // str/agi/int
  @HiveField(1)
  damageReduction,
  @HiveField(2)
  damageIncrease,
  @HiveField(3)
  lifeSteal,
  @HiveField(4)
  cooldownReduction, // for abilities
  @HiveField(5)
  goldFind,
  @HiveField(6)
  xpBonus,
  @HiveField(7)
  hpRegen,
  @HiveField(8)
  critChance,
  @HiveField(9)
  critDamage,
  @HiveField(10)
  corruptedHPDrain, // negative bonus
}

/// SetBonus - A single bonus tier within an equipment set
@HiveType(typeId: 92)
class SetBonus extends HiveObject {
  @HiveField(0)
  SetBonusType type;

  @HiveField(1)
  int piecesRequired; // 2, 4, or 6

  @HiveField(2)
  double magnitude; // percentage or flat value

  @HiveField(3)
  String description;

  @HiveField(4)
  bool isCorrupted;

  SetBonus({
    required this.type,
    required this.piecesRequired,
    required this.magnitude,
    required this.description,
    this.isCorrupted = false,
  });

  /// Get a human-readable name for this bonus type
  String get bonusTypeName {
    switch (type) {
      case SetBonusType.statBonus:
        return 'Stat Bonus';
      case SetBonusType.damageReduction:
        return 'Damage Reduction';
      case SetBonusType.damageIncrease:
        return 'Damage Increase';
      case SetBonusType.lifeSteal:
        return 'Life Steal';
      case SetBonusType.cooldownReduction:
        return 'Cooldown Reduction';
      case SetBonusType.goldFind:
        return 'Gold Find';
      case SetBonusType.xpBonus:
        return 'XP Bonus';
      case SetBonusType.hpRegen:
        return 'HP Regeneration';
      case SetBonusType.critChance:
        return 'Critical Chance';
      case SetBonusType.critDamage:
        return 'Critical Damage';
      case SetBonusType.corruptedHPDrain:
        return 'HP Drain (Corrupted)';
    }
  }

  /// Get the formatted magnitude for display
  String get formattedMagnitude {
    if (type == SetBonusType.hpRegen) {
      return '+${magnitude.toStringAsFixed(1)} HP/tick';
    }
    if (type == SetBonusType.corruptedHPDrain) {
      return '-${(magnitude * 100).toStringAsFixed(1)}% HP/tick';
    }
    return '+${(magnitude * 100).toStringAsFixed(0)}%';
  }

  /// Check if this bonus is currently active given equipped piece count
  bool isActive(int piecesEquipped) => piecesEquipped >= piecesRequired;
}

/// EquipmentSet - Defines a complete equipment set with all its bonuses
@HiveType(typeId: 93)
class EquipmentSet extends HiveObject {
  @HiveField(0)
  SetName name;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<SetBonus> bonuses; // 2, 4, 6 piece tiers

  @HiveField(3)
  bool isCorrupted;

  @HiveField(4)
  double hpDrainPercent; // if corrupted, e.g., 0.01 = 1% per tick

  @HiveField(5)
  String? flavorText;

  EquipmentSet({
    required this.name,
    required this.description,
    required this.bonuses,
    this.isCorrupted = false,
    this.hpDrainPercent = 0.0,
    this.flavorText,
  });

  /// Get the display name for this set
  String get displayName {
    switch (name) {
      case SetName.gladiatorsFury:
        return "Gladiator's Fury";
      case SetName.ironFortress:
        return 'Iron Fortress';
      case SetName.shadowWalker:
        return 'Shadow Walker';
      case SetName.arcaneMastery:
        return 'Arcane Mastery';
      case SetName.naturesEmbrace:
        return "Nature's Embrace";
      case SetName.dragonsWill:
        return "Dragon's Will";
      case SetName.titansReach:
        return "Titan's Reach";
      case SetName.voidWhisperers:
        return 'Void Whisperers';
    }
  }

  /// Get the 2-piece bonus if any
  SetBonus? get twoPieceBonus {
    try {
      return bonuses.firstWhere((b) => b.piecesRequired == 2);
    } catch (_) {
      return null;
    }
  }

  /// Get the 4-piece bonus if any
  SetBonus? get fourPieceBonus {
    try {
      return bonuses.firstWhere((b) => b.piecesRequired == 4);
    } catch (_) {
      return null;
    }
  }

  /// Get the 6-piece bonus if any
  SetBonus? get sixPieceBonus {
    try {
      return bonuses.firstWhere((b) => b.piecesRequired == 6);
    } catch (_) {
      return null;
    }
  }

  /// Get bonuses for a specific piece threshold
  List<SetBonus> getBonusesForPieces(int pieces) {
    return bonuses.where((b) => b.piecesRequired <= pieces).toList();
  }

  /// Get the color associated with this set
  String get setColor {
    switch (name) {
      case SetName.gladiatorsFury:
        return '#FF4444'; // Red
      case SetName.ironFortress:
        return '#888888'; // Grey/Silver
      case SetName.shadowWalker:
        return '#444444'; // Dark Grey
      case SetName.arcaneMastery:
        return '#8844FF'; // Purple
      case SetName.naturesEmbrace:
        return '#44FF44'; // Green
      case SetName.dragonsWill:
        return '#FFAA00'; // Gold
      case SetName.titansReach:
        return '#FF8800'; // Orange
      case SetName.voidWhisperers:
        return '#AA00AA'; // Dark Purple
    }
  }

  /// Get icon for this set
  String get icon {
    switch (name) {
      case SetName.gladiatorsFury:
        return '⚔️';
      case SetName.ironFortress:
        return '🛡️';
      case SetName.shadowWalker:
        return '🥷';
      case SetName.arcaneMastery:
        return '🔮';
      case SetName.naturesEmbrace:
        return '🌿';
      case SetName.dragonsWill:
        return '🐉';
      case SetName.titansReach:
        return '🏔️';
      case SetName.voidWhisperers:
        return '👁️';
    }
  }
}

/// ActiveSet - Tracks the current state of a set for a player
@HiveType(typeId: 94)
class ActiveSet extends HiveObject {
  @HiveField(0)
  SetName setName;

  @HiveField(1)
  int piecesEquipped; // 0-6

  @HiveField(2)
  List<SetBonus> activeBonuses; // unlocked based on piecesEquipped

  @HiveField(3)
  DateTime? firstDiscovered;

  @HiveField(4)
  DateTime? lastEquipped;

  ActiveSet({
    required this.setName,
    this.piecesEquipped = 0,
    this.activeBonuses = const [],
    this.firstDiscovered,
    this.lastEquipped,
  });

  /// Update active bonuses based on current piece count
  void updateActiveBonuses(List<SetBonus> allBonuses) {
    activeBonuses = allBonuses
        .where((b) => b.piecesRequired <= piecesEquipped)
        .toList();
  }

  /// Check if a specific bonus tier is active
  bool hasBonusTier(int piecesRequired) {
    return piecesEquipped >= piecesRequired;
  }

  /// Get the next bonus threshold (2, 4, or 6)
  int? get nextBonusThreshold {
    if (piecesEquipped < 2) return 2;
    if (piecesEquipped < 4) return 4;
    if (piecesEquipped < 6) return 6;
    return null;
  }

  /// Get pieces needed for next bonus
  int get piecesToNextBonus {
    final next = nextBonusThreshold;
    if (next == null) return 0;
    return next - piecesEquipped;
  }
}

/// SetSynergy - Special bonus from mixing different sets
@HiveType(typeId: 95)
class SetSynergy extends HiveObject {
  @HiveField(0)
  SetName primarySet;

  @HiveField(1)
  SetName? secondarySet; // optional 2nd set

  @HiveField(2)
  SetBonus synergyBonus;

  @HiveField(3)
  bool isUnexpected; // random synergy from weird combinations

  @HiveField(4)
  String? synergyName; // e.g., "Silent Fury"

  @HiveField(5)
  String description;

  SetSynergy({
    required this.primarySet,
    this.secondarySet,
    required this.synergyBonus,
    this.isUnexpected = false,
    this.synergyName,
    required this.description,
  });

  /// Get the display name for this synergy
  String get displayName {
    if (synergyName != null) return synergyName!;

    final primary = _getSetName(primarySet);
    if (secondarySet == null) return '$primary Synergy';

    final secondary = _getSetName(secondarySet!);
    return '$primary + $secondary Mix';
  }

  String _getSetName(SetName name) {
    switch (name) {
      case SetName.gladiatorsFury:
        return 'Gladiator';
      case SetName.ironFortress:
        return 'Fortress';
      case SetName.shadowWalker:
        return 'Shadow';
      case SetName.arcaneMastery:
        return 'Arcane';
      case SetName.naturesEmbrace:
        return 'Nature';
      case SetName.dragonsWill:
        return 'Dragon';
      case SetName.titansReach:
        return 'Titan';
      case SetName.voidWhisperers:
        return 'Void';
    }
  }
}

/// EquipmentSetState - Complete state of equipment sets for a player
@HiveType(typeId: 96)
class EquipmentSetState extends HiveObject {
  @HiveField(0)
  Map<SetName, ActiveSet> activeSets;

  @HiveField(1)
  List<EquipmentSet> discoveredSets; // sets the player has seen

  @HiveField(2)
  int totalSetPiecesEquipped;

  @HiveField(3)
  SetSynergy? activeSynergy; // if mixing sets

  @HiveField(4)
  List<SetSynergy> discoveredSynergies; // all discovered synergies

  @HiveField(5)
  DateTime lastUpdated;

  EquipmentSetState({
    Map<SetName, ActiveSet>? activeSets,
    this.discoveredSets = const [],
    this.totalSetPiecesEquipped = 0,
    this.activeSynergy,
    this.discoveredSynergies = const [],
    DateTime? lastUpdated,
  }) : activeSets = activeSets ?? {},
       lastUpdated = lastUpdated ?? DateTime.now();

  /// Mark a set as discovered
  void discoverSet(EquipmentSet set) {
    if (!discoveredSets.any((s) => s.name == set.name)) {
      discoveredSets = [...discoveredSets, set];
    }
  }

  /// Mark a synergy as discovered
  void discoverSynergy(SetSynergy synergy) {
    if (!discoveredSynergies.any(
      (s) =>
          s.primarySet == synergy.primarySet &&
          s.secondarySet == synergy.secondarySet,
    )) {
      discoveredSynergies = [...discoveredSynergies, synergy];
    }
  }

  /// Get total HP drain from all corrupted sets
  double get totalCorruptionDrain {
    double total = 0.0;
    for (final activeSet in activeSets.values) {
      if (activeSet.setName == SetName.voidWhisperers &&
          activeSet.piecesEquipped >= 2) {
        // Void Whisperers drain increases with pieces
        total += 0.005 * activeSet.piecesEquipped;
      }
    }
    return total;
  }

  /// Check if any corrupted set pieces are equipped
  bool get hasCorruptionEquipped {
    return activeSets.values.any(
      (s) => s.setName == SetName.voidWhisperers && s.piecesEquipped > 0,
    );
  }

  /// Get all active bonuses across all sets
  List<SetBonus> get allActiveBonuses {
    final bonuses = <SetBonus>[];
    for (final activeSet in activeSets.values) {
      bonuses.addAll(activeSet.activeBonuses);
    }
    if (activeSynergy != null) {
      bonuses.add(activeSynergy!.synergyBonus);
    }
    return bonuses;
  }

  /// Get total bonus of a specific type
  double getTotalBonus(SetBonusType type) {
    double total = 0.0;
    for (final bonus in allActiveBonuses) {
      if (bonus.type == type) {
        total += bonus.magnitude;
      }
    }
    return total;
  }

  /// Reset all set progress (e.g., on ascension)
  void reset() {
    activeSets = {};
    totalSetPiecesEquipped = 0;
    activeSynergy = null;
    lastUpdated = DateTime.now();
  }
}

/// EquipmentSetItem - Wrapper to track which set an equipment belongs to
@HiveType(typeId: 97)
class EquipmentSetItem extends HiveObject {
  @HiveField(0)
  Equipment equipment;

  @HiveField(1)
  SetName? setName; // null if not part of any set

  @HiveField(2)
  int setPieceNumber; // 1-6 to identify which piece of the set

  @HiveField(3)
  bool isSetPiece;

  EquipmentSetItem({
    required this.equipment,
    this.setName,
    this.setPieceNumber = 0,
    this.isSetPiece = false,
  });

  /// Get the display name including set info
  String get displayName {
    if (!isSetPiece || setName == null) return equipment.name;

    final setNameStr = _getSetDisplayName(setName!);
    return '$setNameStr ${equipment.name}';
  }

  String _getSetDisplayName(SetName name) {
    switch (name) {
      case SetName.gladiatorsFury:
        return '[Gladiator]';
      case SetName.ironFortress:
        return '[Fortress]';
      case SetName.shadowWalker:
        return '[Shadow]';
      case SetName.arcaneMastery:
        return '[Arcane]';
      case SetName.naturesEmbrace:
        return '[Nature]';
      case SetName.dragonsWill:
        return '[Dragon]';
      case SetName.titansReach:
        return '[Titan]';
      case SetName.voidWhisperers:
        return '[Void]';
    }
  }
}

/// SetRecommendation - Recommendation from automation system
class SetRecommendation {
  final EquipmentSetItem item;
  final bool shouldEquip;
  final String reason;
  final double statTradeoff; // negative means losing stats, positive gaining
  final bool completesSetBonus;
  final int? bonusTierCompleted; // 2, 4, or 6

  SetRecommendation({
    required this.item,
    required this.shouldEquip,
    required this.reason,
    this.statTradeoff = 0.0,
    this.completesSetBonus = false,
    this.bonusTierCompleted,
  });
}

/// SetEvaluationResult - Result of evaluating set vs raw stats
class SetEvaluationResult {
  final bool shouldEquip;
  final String recommendation;
  final double currentStatScore;
  final double newStatScore;
  final double setBonusValue;
  final bool isCorruptedRisk;

  SetEvaluationResult({
    required this.shouldEquip,
    required this.recommendation,
    required this.currentStatScore,
    required this.newStatScore,
    required this.setBonusValue,
    this.isCorruptedRisk = false,
  });

  double get netChange => newStatScore - currentStatScore + setBonusValue;
}
