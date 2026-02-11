import 'dart:math';
import '../models/legendary_items.dart';
import '../models/character.dart';
import '../models/boss_rush.dart';
import '../models/equipment_sets.dart';
import '../models/equipment.dart';
import '../providers/game_provider.dart';

/// Service for managing legendary items
class LegendaryItemService {
  final Random _random = Random();
  final LegendaryCollection _collection;

  LegendaryItemService(this._collection) {
    LegendaryDefinitions.initialize();
  }

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize legendary items system
  void initializeLegendaryItems() {
    LegendaryDefinitions.initialize();
  }

  // ============================================================================
  // Drop System
  // ============================================================================

  /// Calculate drop chance for a boss with pity system
  double calculateDropChance(
    int bossKillsSinceDrop, {
    bool isFirstBoss = false,
  }) {
    return LegendaryDropChance.calculateDropChance(
      bossKillsSinceDrop,
      isFirstBoss: isFirstBoss,
    );
  }

  /// Attempt to drop a legendary from a boss
  /// Returns the dropped legendary or null
  LegendaryItem? attemptDrop(Boss boss, Character character) {
    // Record this attempt
    _collection.recordDropAttempt(boss.floor.toString());

    // Calculate drop chance
    final bossKills = _collection.getBossKillsSinceDrop(boss.floor.toString());
    final isFirstBoss = boss.floor == 5;
    final dropChance = calculateDropChance(bossKills, isFirstBoss: isFirstBoss);

    // Roll for drop
    if (_random.nextDouble() > dropChance) {
      return null;
    }

    // Determine what type of item to drop
    final itemType = _determineDropType();

    // Generate the legendary
    final legendary = generateLegendary(boss, itemType);

    // Reset drop attempts for this boss
    _collection.resetDropAttempts(boss.floor.toString());

    // Add to collection
    _collection.addLegendary(legendary);

    return legendary;
  }

  /// Determine which slot type to drop
  EquipmentSlotType _determineDropType() {
    final roll = _random.nextDouble();
    if (roll < 0.40) {
      return EquipmentSlotType.weapon; // 40% weapons
    } else if (roll < 0.80) {
      return EquipmentSlotType.armor; // 40% armor
    } else {
      return EquipmentSlotType.jewelry; // 20% jewelry
    }
  }

  /// Generate a legendary item from a boss
  LegendaryItem generateLegendary(Boss boss, EquipmentSlotType itemType) {
    // Get random legendary of the appropriate type
    final definition = LegendaryDefinitions.getRandom(_random, type: itemType);

    // Create an instance
    return LegendaryDefinitions.createInstance(
      definition.id,
      boss.floor,
      _random,
    );
  }

  /// Get current drop chance for display
  String getDropChanceDisplay(int floor) {
    final bossKills = _collection.getBossKillsSinceDrop(floor.toString());
    final isFirstBoss = floor == 5;
    final chance = calculateDropChance(bossKills, isFirstBoss: isFirstBoss);
    return LegendaryDropChance.formatDropChance(chance);
  }

  // ============================================================================
  // Reforge System
  // ============================================================================

  /// Reforge costs
  static const int reforgeGoldCost = 1000;
  static const int reforgeEssenceCost = 1;

  /// Check if an item can be reforged
  bool canReforge(
    LegendaryItem item,
    int availableGold,
    int availableEssences,
  ) {
    return item.canReforge &&
        availableGold >= reforgeGoldCost &&
        availableEssences >= reforgeEssenceCost;
  }

  /// Reforge a legendary item (rerolls stats, keeps effect)
  /// Returns the new item or null if failed
  LegendaryItem? reforgeLegendary(
    LegendaryItem item,
    int availableGold,
    int availableEssences,
  ) {
    if (!canReforge(item, availableGold, availableEssences)) {
      return null;
    }

    // Generate new stats
    final newStats = LegendaryDefinitions.generateReforgeStats(
      item.equipmentType,
      item.acquiredFloor ?? 5,
      _random,
      item.reforgeCount + 1,
    );

    // Create reforged item
    final reforgedItem = item.copyForReforge(newStats);

    // Update collection
    _collection.replaceAfterReforge(item, reforgedItem);

    return reforgedItem;
  }

  /// Get reforge cost display
  Map<String, int> getReforgeCost() {
    return {'gold': reforgeGoldCost, 'essences': reforgeEssenceCost};
  }

  // ============================================================================
  // Sentience System
  // ============================================================================

  /// Check and update sentience progress for an item
  void checkSentienceProgress(
    LegendaryItem item,
    Map<String, dynamic> gameState,
  ) {
    if (!item.hasSentience || item.sentience == null) return;

    final sentience = item.sentience!;
    int progressIncrease = 0;

    switch (sentience) {
      case SentienceType.killDragons:
        final dragonsKilled = gameState['dragonsKilled'] as int? ?? 0;
        progressIncrease = dragonsKilled * 10;
        break;
      case SentienceType.killBosses:
        final bossesKilled = gameState['bossesKilled'] as int? ?? 0;
        progressIncrease = bossesKilled * 15;
        break;
      case SentienceType.killUndead:
        final undeadKilled = gameState['undeadKilled'] as int? ?? 0;
        progressIncrease = undeadKilled * 5;
        break;
      case SentienceType.findGold:
        final goldFound = gameState['goldFound'] as int? ?? 0;
        progressIncrease = (goldFound ~/ 1000) * 5;
        break;
      case SentienceType.exploreDeep:
        final deepestFloor = gameState['deepestFloor'] as int? ?? 1;
        if (deepestFloor >= 20) {
          progressIncrease = (deepestFloor - 19) * 20;
        }
        break;
      case SentienceType.surviveCombat:
        final nearDeathSurvivals = gameState['nearDeathSurvivals'] as int? ?? 0;
        progressIncrease = nearDeathSurvivals * 25;
        break;
      case SentienceType.usePotions:
        final potionsUsed = gameState['potionsUsed'] as int? ?? 0;
        progressIncrease = potionsUsed * 10;
        break;
      case SentienceType.enchantItems:
        final itemsEnchanted = gameState['itemsEnchanted'] as int? ?? 0;
        progressIncrease = itemsEnchanted * 20;
        break;
      case SentienceType.ascend:
        final ascensions = gameState['ascensions'] as int? ?? 0;
        progressIncrease = ascensions * 20;
        break;
      case SentienceType.collectSets:
        final setsCompleted = gameState['setsCompleted'] as int? ?? 0;
        progressIncrease = setsCompleted * 15;
        break;
    }

    // Update progress
    _collection.updateSentienceProgress(item.id, progressIncrease);
  }

  /// Awaken a legendary (called when sentience reaches 100)
  void awakenLegendary(LegendaryItem item) {
    if (item.sentienceProgress >= 100 && !item.isAwakened) {
      _collection.updateSentienceProgress(item.id, 100);
    }
  }

  /// Get sentience progress description
  String getSentienceDescription(LegendaryItem item) {
    if (!item.hasSentience || item.sentience == null) {
      return 'This item has no sentience.';
    }

    if (item.isAwakened) {
      return '★ AWAKENED ★ The ${item.sentience!.displayName} is satisfied. Effect is 50% stronger.';
    }

    return '${item.sentience!.desireDescription} - Progress: ${item.sentienceProgress}%';
  }

  // ============================================================================
  // Automation Integration
  // ============================================================================

  /// Evaluate if a legendary should be equipped over current item
  bool shouldEquipLegendary(
    LegendaryItem legendary,
    EquipmentSetItem? currentItem,
  ) {
    // Legendaries are always better than non-legendaries
    if (currentItem == null) return true;

    // Check if current item is also legendary
    final currentIsLegendary = currentItem.equipment.rarity >= 5;

    if (!currentIsLegendary) {
      // Current is not legendary, equip the legendary
      return true;
    }

    // Both are legendary - compare based on sentience and stats
    final currentStats = _calculateItemPower(currentItem.equipment);
    final legendaryStats = legendary.totalStatValue;

    // Prefer awakened legendaries
    if (legendary.isAwakened) {
      return true;
    }

    // Prefer legendaries with higher stats (within 10% margin)
    return legendaryStats >= currentStats * 0.9;
  }

  /// Calculate the power score of an equipment item
  double _calculateItemPower(Equipment item) {
    return (item.attackBonus * 2.0) +
        (item.defenseBonus * 1.5) +
        (item.healthBonus * 0.5) +
        (item.manaBonus * 0.3) +
        (item.rarity * 5.0);
  }

  /// Get legendary bonus for combat calculations
  double getLegendaryBonus(LegendaryItem? item, LegendaryEffectType type) {
    if (item == null) return 0.0;
    if (item.effect.type != type) return 0.0;

    return item.effectiveMagnitude;
  }

  /// Execute automation for legendary items
  List<String> executeAutomation(GameProvider gameProvider) {
    final actions = <String>[];
    final character = gameProvider.character;
    if (character == null) return actions;

    // Auto-equip best legendaries for each slot
    for (final slot in EquipmentSlotType.values) {
      final bestLegendary = _collection.getBestForSlot(slot);
      if (bestLegendary != null) {
        // Check if we should equip it
        // This would integrate with the equipment system
        actions.add(
          'AUTO: Legendary ${bestLegendary.name} available for ${slot.toString().split('.').last} slot',
        );

        if (bestLegendary.isAwakened) {
          actions.add('  ★ ${bestLegendary.name} is Awakened!');
        }
      }
    }

    // Check for reforge opportunities
    for (final item in _collection.ownedItems.where((i) => i.canReforge)) {
      // Would check gold/essence availability
      if (item.reforgeCount < 3) {
        actions.add('AUTO: ${item.name} could be reforged for better stats');
      }
    }

    return actions;
  }

  // ============================================================================
  // Combat Integration
  // ============================================================================

  /// Calculate damage bonus from legendaries
  double getDamageBonus(
    List<LegendaryItem> equippedLegendaries, {
    String? targetType,
  }) {
    double bonus = 0.0;

    for (final item in equippedLegendaries) {
      switch (item.effect.type) {
        case LegendaryEffectType.damageBoost:
          bonus += item.effectiveMagnitude;
          break;
        case LegendaryEffectType.bossSlayer:
          if (targetType == 'boss') {
            bonus += item.effectiveMagnitude;
          }
          break;
        case LegendaryEffectType.dragonBane:
          if (targetType == 'dragon') {
            bonus += item.effectiveMagnitude;
          }
          break;
        case LegendaryEffectType.undeadBane:
          if (targetType == 'undead') {
            bonus += item.effectiveMagnitude;
          }
          break;
        case LegendaryEffectType.glassCannon:
          bonus += item.effectiveMagnitude;
          break;
        case LegendaryEffectType.hpToDamage:
          // This is handled separately in character stats
          break;
        default:
          break;
      }
    }

    return bonus;
  }

  /// Calculate defense bonus from legendaries
  double getDefenseBonus(List<LegendaryItem> equippedLegendaries) {
    double bonus = 0.0;

    for (final item in equippedLegendaries) {
      switch (item.effect.type) {
        case LegendaryEffectType.defenseBoost:
          bonus += item.effectiveMagnitude;
          break;
        default:
          break;
      }
    }

    return bonus;
  }

  /// Calculate life steal from legendaries
  double getLifeSteal(List<LegendaryItem> equippedLegendaries) {
    for (final item in equippedLegendaries) {
      if (item.effect.type == LegendaryEffectType.lifeSteal) {
        return item.effectiveMagnitude;
      }
    }
    return 0.0;
  }

  /// Calculate crit bonuses from legendaries
  Map<String, double> getCritBonuses(List<LegendaryItem> equippedLegendaries) {
    double chanceBonus = 0.0;
    double damageBonus = 0.0;

    for (final item in equippedLegendaries) {
      if (item.effect.type == LegendaryEffectType.criticalMastery) {
        chanceBonus += item.effectiveMagnitude;
        damageBonus += 0.50; // +50% crit damage from critical mastery
      }
    }

    return {'chance': chanceBonus, 'damage': damageBonus};
  }

  /// Check for immortality effect
  bool hasImmortality(List<LegendaryItem> equippedLegendaries) {
    return equippedLegendaries.any(
      (item) => item.effect.type == LegendaryEffectType.immortality,
    );
  }

  /// Get cooldown reduction from legendaries
  double getCooldownReduction(List<LegendaryItem> equippedLegendaries) {
    double reduction = 0.0;

    for (final item in equippedLegendaries) {
      if (item.effect.type == LegendaryEffectType.timeWarp) {
        reduction += item.effectiveMagnitude;
      }
    }

    return reduction.clamp(0.0, 0.75); // Max 75% reduction
  }

  /// Get gold find bonus from legendaries
  double getGoldFindBonus(List<LegendaryItem> equippedLegendaries) {
    for (final item in equippedLegendaries) {
      if (item.effect.type == LegendaryEffectType.goldMagnet) {
        return item.effectiveMagnitude;
      }
    }
    return 0.0;
  }

  /// Get XP bonus from legendaries
  double getXPBonus(List<LegendaryItem> equippedLegendaries) {
    for (final item in equippedLegendaries) {
      if (item.effect.type == LegendaryEffectType.xpMagnet) {
        return item.effectiveMagnitude;
      }
    }
    return 0.0;
  }

  // ============================================================================
  // Collection Queries
  // ============================================================================

  /// Get the legendary collection
  LegendaryCollection get collection => _collection;

  /// Get all owned legendaries
  List<LegendaryItem> get ownedLegendaries => _collection.ownedItems;

  /// Get discovered legendary IDs
  List<String> get discoveredLegendaries => _collection.discoveredIds;

  /// Get undiscovered legendary IDs
  List<String> get undiscoveredLegendaries {
    final allIds = LegendaryDefinitions.allDefinitions.map((d) => d.id).toSet();
    final discovered = discoveredLegendaries.toSet();
    return allIds.difference(discovered).toList();
  }

  /// Get collection statistics
  Map<String, dynamic> getCollectionStats() {
    return {
      'totalOwned': _collection.ownedItems.length,
      'totalDiscovered': _collection.discoveredIds.length,
      'totalAvailable': LegendaryDefinitions.allDefinitions.length,
      'awakenedCount': _collection.awakenedCount,
      'totalReforges': _collection.totalReforges,
      'completionPercent':
          _collection.discoveredIds.length /
          LegendaryDefinitions.allDefinitions.length *
          100,
    };
  }

  /// Check if player has a specific legendary
  bool hasLegendary(String id) => _collection.hasLegendary(id);

  /// Get a legendary by ID
  LegendaryItem? getLegendary(String id) {
    try {
      return _collection.ownedItems.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Extension to help with equipment slot matching
extension EquipmentSlotTypeExtension on EquipmentSlotType {
  String get displayName {
    switch (this) {
      case EquipmentSlotType.weapon:
        return 'Weapon';
      case EquipmentSlotType.armor:
        return 'Armor';
      case EquipmentSlotType.jewelry:
        return 'Jewelry';
    }
  }
}
