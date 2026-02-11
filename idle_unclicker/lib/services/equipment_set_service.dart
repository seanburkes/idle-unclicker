import 'dart:math';
import '../models/equipment.dart';
import '../models/equipment_sets.dart';
import '../models/character.dart';
import '../providers/game_provider.dart';

/// Service for managing equipment sets, synergies, and automation decisions
class EquipmentSetService {
  final Random _random = Random();
  final EquipmentSetState _state;

  // Cache for all set definitions
  late final Map<SetName, EquipmentSet> _setDefinitions;

  EquipmentSetService(this._state) {
    _setDefinitions = _initializeSetDefinitions();
  }

  /// Initialize all 8 equipment sets with their bonuses
  Map<SetName, EquipmentSet> _initializeSetDefinitions() {
    return {
      // Gladiator's Fury (Combat focus)
      SetName.gladiatorsFury: EquipmentSet(
        name: SetName.gladiatorsFury,
        description: 'Forged in the arena, worn by champions.',
        flavorText: 'Blood calls to blood.',
        bonuses: [
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 2,
            magnitude: 0.10,
            description: '+10% damage',
          ),
          SetBonus(
            type: SetBonusType.critChance,
            piecesRequired: 4,
            magnitude: 0.15,
            description: '+15% crit chance, +25% crit damage',
          ),
          SetBonus(
            type: SetBonusType.critDamage,
            piecesRequired: 4,
            magnitude: 0.25,
            description: '', // Combined with above
          ),
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 6,
            magnitude: 0.30,
            description: '+30% damage, 5% life steal',
          ),
          SetBonus(
            type: SetBonusType.lifeSteal,
            piecesRequired: 6,
            magnitude: 0.05,
            description: '', // Combined with above
          ),
        ],
      ),

      // Iron Fortress (Tank focus)
      SetName.ironFortress: EquipmentSet(
        name: SetName.ironFortress,
        description: 'Impenetrable defense at any cost.',
        flavorText: 'Stand firm, break nothing.',
        bonuses: [
          SetBonus(
            type: SetBonusType.damageReduction,
            piecesRequired: 2,
            magnitude: 0.15,
            description: '+15% armor',
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 4,
            magnitude: 0.20,
            description: '+20% HP, 10% damage reduction',
          ),
          SetBonus(
            type: SetBonusType.damageReduction,
            piecesRequired: 4,
            magnitude: 0.10,
            description: '', // Combined with above
          ),
          SetBonus(
            type: SetBonusType.damageReduction,
            piecesRequired: 6,
            magnitude: 0.40,
            description: '+40% armor, immune to first hit',
          ),
        ],
      ),

      // Shadow Walker (Rogue/evasion focus)
      SetName.shadowWalker: EquipmentSet(
        name: SetName.shadowWalker,
        description: 'Unseen, unheard, unforgettable.',
        flavorText: 'The shadows welcome you.',
        bonuses: [
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 2,
            magnitude: 0.10,
            description: '+10% evasion',
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 4,
            magnitude: 0.20,
            description: '+20% attack speed, +15% move speed',
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 4,
            magnitude: 0.15,
            description: '', // Move speed combined
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 6,
            magnitude: 0.30,
            description: '+30% evasion, first attack crits',
          ),
          SetBonus(
            type: SetBonusType.critChance,
            piecesRequired: 6,
            magnitude: 1.0,
            description: '', // First attack always crits
          ),
        ],
      ),

      // Arcane Mastery (Mage/magic focus)
      SetName.arcaneMastery: EquipmentSet(
        name: SetName.arcaneMastery,
        description: 'Power drawn from the weave itself.',
        flavorText: 'Knowledge is power. Power is everything.',
        bonuses: [
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 2,
            magnitude: 0.10,
            description: '+10% intellect',
          ),
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 4,
            magnitude: 0.25,
            description: '+25% skill damage, -10% cooldowns',
          ),
          SetBonus(
            type: SetBonusType.cooldownReduction,
            piecesRequired: 4,
            magnitude: 0.10,
            description: '', // Combined with above
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 6,
            magnitude: 0.50,
            description: '+50% intellect, 20% chance free spells',
          ),
        ],
      ),

      // Nature's Embrace (Healing/regen focus)
      SetName.naturesEmbrace: EquipmentSet(
        name: SetName.naturesEmbrace,
        description: 'The wilds provide for those who listen.',
        flavorText: 'Life finds a way.',
        bonuses: [
          SetBonus(
            type: SetBonusType.hpRegen,
            piecesRequired: 2,
            magnitude: 5.0,
            description: '+5 HP regen per tick',
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 4,
            magnitude: 0.20,
            description: '+20% healing, +25% potion effectiveness',
          ),
          SetBonus(
            type: SetBonusType.hpRegen,
            piecesRequired: 6,
            magnitude: 10.0,
            description: '+10 HP regen, revive once per combat',
          ),
        ],
      ),

      // Dragon's Will (Hybrid/all-rounder)
      SetName.dragonsWill: EquipmentSet(
        name: SetName.dragonsWill,
        description: 'Ancient power flows through dragon-touched gear.',
        flavorText: 'The dragon remembers.',
        bonuses: [
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 2,
            magnitude: 0.05,
            description: '+5% all stats',
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 4,
            magnitude: 0.10,
            description: '+10% all stats, +10% gold find',
          ),
          SetBonus(
            type: SetBonusType.goldFind,
            piecesRequired: 4,
            magnitude: 0.10,
            description: '', // Combined with above
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 6,
            magnitude: 0.15,
            description: '+15% all stats, +20% XP, +15% gold',
          ),
          SetBonus(
            type: SetBonusType.xpBonus,
            piecesRequired: 6,
            magnitude: 0.20,
            description: '', // Combined with above
          ),
          SetBonus(
            type: SetBonusType.goldFind,
            piecesRequired: 6,
            magnitude: 0.15,
            description: '', // Combined with above
          ),
        ],
      ),

      // Titan's Reach (Strength focus)
      SetName.titansReach: EquipmentSet(
        name: SetName.titansReach,
        description: 'Feel the weight of mountains in every blow.',
        flavorText: 'Unstoppable force.',
        bonuses: [
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 2,
            magnitude: 0.10,
            description: '+10% strength',
          ),
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 4,
            magnitude: 0.25,
            description: '+25% weapon damage, stun immunity',
          ),
          SetBonus(
            type: SetBonusType.statBonus,
            piecesRequired: 6,
            magnitude: 0.50,
            description: '+50% strength, 25% chance to stun',
          ),
        ],
      ),

      // Void Whisperers (CORRUPTED - powerful but risky)
      SetName.voidWhisperers: EquipmentSet(
        name: SetName.voidWhisperers,
        description: 'The void speaks. It demands sacrifice.',
        flavorText: 'Power beyond comprehension. Cost beyond measure.',
        isCorrupted: true,
        hpDrainPercent: 0.02, // 2% per tick at 6 pieces
        bonuses: [
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 2,
            magnitude: 0.20,
            description: '+20% damage',
          ),
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 4,
            magnitude: 0.40,
            description: '+40% damage, +20% crit chance',
          ),
          SetBonus(
            type: SetBonusType.critChance,
            piecesRequired: 4,
            magnitude: 0.20,
            description: '', // Combined with above
          ),
          SetBonus(
            type: SetBonusType.damageIncrease,
            piecesRequired: 6,
            magnitude: 0.75,
            description: '+75% damage, all attacks crit',
            isCorrupted: true,
          ),
          SetBonus(
            type: SetBonusType.critChance,
            piecesRequired: 6,
            magnitude: 1.0,
            description: '', // All attacks crit
            isCorrupted: true,
          ),
          SetBonus(
            type: SetBonusType.corruptedHPDrain,
            piecesRequired: 6,
            magnitude: 0.02,
            description: 'Drains 2% HP per combat tick',
            isCorrupted: true,
          ),
        ],
      ),
    };
  }

  /// Get all set definitions
  Map<SetName, EquipmentSet> get allSets => _setDefinitions;

  /// Get a specific set definition
  EquipmentSet? getSetDefinition(SetName name) => _setDefinitions[name];

  /// Determine which set an item belongs to based on name patterns
  SetName? getSetForItem(Equipment item) {
    final nameLower = item.name.toLowerCase();

    // Check for set prefixes in item name
    if (nameLower.contains('gladiator')) return SetName.gladiatorsFury;
    if (nameLower.contains('fortress') || nameLower.contains('iron')) {
      return SetName.ironFortress;
    }
    if (nameLower.contains('shadow')) return SetName.shadowWalker;
    if (nameLower.contains('arcane') || nameLower.contains('mage')) {
      return SetName.arcaneMastery;
    }
    if (nameLower.contains('nature') || nameLower.contains('druid')) {
      return SetName.naturesEmbrace;
    }
    if (nameLower.contains('dragon')) return SetName.dragonsWill;
    if (nameLower.contains('titan')) return SetName.titansReach;
    if (nameLower.contains('void') || nameLower.contains('corrupt')) {
      return SetName.voidWhisperers;
    }

    // Random assignment based on slot and level for generated items
    if (_random.nextDouble() < 0.15) {
      // 15% chance for any item to be a set piece
      return _assignRandomSet(item);
    }

    return null;
  }

  /// Assign a random set based on item characteristics
  SetName _assignRandomSet(Equipment item) {
    // Weight sets based on item slot and level
    final possibleSets = SetName.values.where((s) {
      if (s == SetName.voidWhisperers) {
        // Corrupted items only at higher levels
        return item.level >= 10;
      }
      return true;
    }).toList();

    return possibleSets[_random.nextInt(possibleSets.length)];
  }

  /// Calculate active sets based on equipped items
  Map<SetName, ActiveSet> calculateActiveSets(
    List<EquipmentSetItem> equippedItems,
  ) {
    final activeSets = <SetName, ActiveSet>{};

    // Count pieces per set
    for (final item in equippedItems) {
      if (item.isSetPiece && item.setName != null) {
        final setName = item.setName!;

        if (!activeSets.containsKey(setName)) {
          activeSets[setName] = ActiveSet(
            setName: setName,
            firstDiscovered: DateTime.now(),
          );
        }

        activeSets[setName]!.piecesEquipped++;
      }
    }

    // Update active bonuses for each set
    for (final entry in activeSets.entries) {
      final setDef = _setDefinitions[entry.key];
      if (setDef != null) {
        entry.value.updateActiveBonuses(setDef.bonuses);
        entry.value.lastEquipped = DateTime.now();
      }
    }

    return activeSets;
  }

  /// Get all active bonuses from equipped items
  List<SetBonus> getActiveBonuses(List<EquipmentSetItem> equippedItems) {
    final activeSets = calculateActiveSets(equippedItems);
    final bonuses = <SetBonus>[];

    for (final activeSet in activeSets.values) {
      bonuses.addAll(activeSet.activeBonuses);
    }

    return bonuses;
  }

  /// Detect synergies when mixing sets
  SetSynergy? detectSynergies(Map<SetName, ActiveSet> activeSets) {
    // Need at least 2 different sets with at least 2 pieces each
    final qualifyingSets = activeSets.values
        .where((s) => s.piecesEquipped >= 2)
        .toList();

    if (qualifyingSets.length < 2) return null;

    // Check for known synergies
    final primary = qualifyingSets.first;
    final secondary = qualifyingSets.length > 1 ? qualifyingSets[1] : null;

    if (secondary != null) {
      final synergy = _getKnownSynergy(primary.setName, secondary.setName);
      if (synergy != null) {
        return synergy;
      }

      // Random chance for unexpected synergy (10%)
      if (_random.nextDouble() < 0.10) {
        return _generateUnexpectedSynergy(primary.setName, secondary.setName);
      }
    }

    // Simple 2-piece bonus synergy
    if (qualifyingSets.length >= 2) {
      return SetSynergy(
        primarySet: primary.setName,
        secondarySet: secondary?.setName,
        synergyBonus: SetBonus(
          type: SetBonusType.damageIncrease,
          piecesRequired: 2,
          magnitude: 0.05,
          description: '+5% damage from set mixing',
        ),
        description: 'Mixing sets provides a small damage bonus.',
      );
    }

    return null;
  }

  /// Get known synergy between specific sets
  SetSynergy? _getKnownSynergy(SetName primary, SetName secondary) {
    // Gladiator + Shadow = Silent Fury
    if ((primary == SetName.gladiatorsFury &&
            secondary == SetName.shadowWalker) ||
        (primary == SetName.shadowWalker &&
            secondary == SetName.gladiatorsFury)) {
      return SetSynergy(
        primarySet: primary,
        secondarySet: secondary,
        synergyName: 'Silent Fury',
        synergyBonus: SetBonus(
          type: SetBonusType.damageIncrease,
          piecesRequired: 2,
          magnitude: 0.10,
          description: '+10% damage while in combat',
        ),
        description: 'The fury of the arena meets the silence of shadows.',
      );
    }

    // Iron Fortress + Nature = Living Bastion
    if ((primary == SetName.ironFortress &&
            secondary == SetName.naturesEmbrace) ||
        (primary == SetName.naturesEmbrace &&
            secondary == SetName.ironFortress)) {
      return SetSynergy(
        primarySet: primary,
        secondarySet: secondary,
        synergyName: 'Living Bastion',
        synergyBonus: SetBonus(
          type: SetBonusType.hpRegen,
          piecesRequired: 2,
          magnitude: 8.0,
          description: '+8 HP regen per tick',
        ),
        description: 'Nature reinforces the fortress.',
      );
    }

    // Arcane + Dragon = Draconic Sorcery
    if ((primary == SetName.arcaneMastery &&
            secondary == SetName.dragonsWill) ||
        (primary == SetName.dragonsWill &&
            secondary == SetName.arcaneMastery)) {
      return SetSynergy(
        primarySet: primary,
        secondarySet: secondary,
        synergyName: 'Draconic Sorcery',
        synergyBonus: SetBonus(
          type: SetBonusType.xpBonus,
          piecesRequired: 2,
          magnitude: 0.15,
          description: '+15% XP gain',
        ),
        description: 'Ancient dragon magic enhances learning.',
      );
    }

    // Titan + Gladiator = Colosseum Champion
    if ((primary == SetName.titansReach &&
            secondary == SetName.gladiatorsFury) ||
        (primary == SetName.gladiatorsFury &&
            secondary == SetName.titansReach)) {
      return SetSynergy(
        primarySet: primary,
        secondarySet: secondary,
        synergyName: 'Colosseum Champion',
        synergyBonus: SetBonus(
          type: SetBonusType.critDamage,
          piecesRequired: 2,
          magnitude: 0.30,
          description: '+30% critical damage',
        ),
        description: 'The strength of titans fuels the fury of gladiators.',
      );
    }

    return null;
  }

  /// Generate a random unexpected synergy
  SetSynergy _generateUnexpectedSynergy(SetName primary, SetName secondary) {
    final synergyTypes = [
      SetBonusType.goldFind,
      SetBonusType.xpBonus,
      SetBonusType.hpRegen,
      SetBonusType.cooldownReduction,
    ];

    final type = synergyTypes[_random.nextInt(synergyTypes.length)];
    final magnitude = 0.05 + (_random.nextDouble() * 0.10);

    return SetSynergy(
      primarySet: primary,
      secondarySet: secondary,
      isUnexpected: true,
      synergyBonus: SetBonus(
        type: type,
        piecesRequired: 2,
        magnitude: magnitude,
        description: '+${(magnitude * 100).toStringAsFixed(0)}% ${type.name}',
      ),
      description: 'An unexpected combination yields surprising results!',
    );
  }

  /// Evaluate whether to equip an item considering set bonuses
  SetEvaluationResult evaluateSetVsStats(
    EquipmentSetItem newItem,
    EquipmentSetItem? currentItem,
    EquipmentSetState currentState,
    Character character,
  ) {
    // Calculate raw stat scores
    final newStats = _calculateStatScore(newItem.equipment);
    final currentStats = currentItem != null
        ? _calculateStatScore(currentItem.equipment)
        : 0.0;
    final statDifference = newStats - currentStats;

    // Calculate potential set bonus value
    double setBonusValue = 0.0;
    bool completesBonus = false;
    int? bonusTier;

    if (newItem.isSetPiece && newItem.setName != null) {
      final currentPieces =
          currentState.activeSets[newItem.setName]?.piecesEquipped ?? 0;
      final newPieces = currentPieces + 1;

      // Check if this completes a bonus tier
      final setDef = _setDefinitions[newItem.setName];
      if (setDef != null) {
        for (final bonus in setDef.bonuses) {
          if (currentPieces < bonus.piecesRequired &&
              newPieces >= bonus.piecesRequired) {
            completesBonus = true;
            bonusTier = bonus.piecesRequired;
            setBonusValue = _calculateBonusValue(bonus, character);
            break;
          }
        }

        // Partial value for progress toward next tier
        if (!completesBonus) {
          final nextTier = _getNextTier(setDef, currentPieces);
          if (nextTier != null) {
            setBonusValue = _calculateBonusValue(nextTier, character) * 0.3;
          }
        }
      }
    }

    // Check for corruption risk
    final isCorrupted = newItem.setName == SetName.voidWhisperers;
    final hpRegen = currentState.getTotalBonus(SetBonusType.hpRegen);
    final isCorruptionSafe = hpRegen >= 0.10; // Need at least 10% HP regen

    // Decision logic
    bool shouldEquip = false;
    String recommendation;

    if (isCorrupted && !isCorruptionSafe) {
      // Never equip corrupted without sufficient regen
      shouldEquip = false;
      recommendation =
          'CORRUPTED: Insufficient HP regen (${(hpRegen * 100).toStringAsFixed(0)}%)';
    } else if (completesBonus && bonusTier != null) {
      // Always prioritize completing set bonuses
      if (statDifference >= -0.15) {
        // Within -15% threshold
        shouldEquip = true;
        recommendation = 'Equip: Completes $bonusTier-piece bonus!';
      } else {
        shouldEquip = false;
        recommendation = 'Skip: Stats too low even for set bonus';
      }
    } else if (statDifference > 0) {
      // Better stats, no set loss
      shouldEquip = true;
      recommendation =
          'Equip: Better stats (+${(statDifference * 100).toStringAsFixed(0)}%)';
    } else if (statDifference >= -0.10 && newItem.isSetPiece) {
      // Slight stat loss but set piece
      shouldEquip = true;
      recommendation = 'Equip: Accept -10% for set progress';
    } else if (statDifference < -0.15) {
      // Too much stat loss
      shouldEquip = false;
      recommendation =
          'Skip: Too much stat loss (${(statDifference * 100).toStringAsFixed(0)}%)';
    } else {
      // Marginal case
      shouldEquip = statDifference >= -0.05;
      recommendation = shouldEquip
          ? 'Equip: Marginal improvement'
          : 'Skip: No significant benefit';
    }

    return SetEvaluationResult(
      shouldEquip: shouldEquip,
      recommendation: recommendation,
      currentStatScore: currentStats,
      newStatScore: newStats,
      setBonusValue: setBonusValue,
      isCorruptedRisk: isCorrupted && !isCorruptionSafe,
    );
  }

  /// Calculate a stat score for an equipment piece
  double _calculateStatScore(Equipment item) {
    // Weight different stats based on importance
    return (item.attackBonus * 2.0) +
        (item.defenseBonus * 1.5) +
        (item.healthBonus * 0.5) +
        (item.manaBonus * 0.3) +
        (item.rarity * 5.0) +
        (item.level * 0.5);
  }

  /// Calculate the combat value of a set bonus
  double _calculateBonusValue(SetBonus bonus, Character character) {
    switch (bonus.type) {
      case SetBonusType.damageIncrease:
        return bonus.magnitude * 100; // Very valuable
      case SetBonusType.damageReduction:
        return bonus.magnitude * 80;
      case SetBonusType.lifeSteal:
        return bonus.magnitude * 150; // Extremely valuable
      case SetBonusType.critChance:
        return bonus.magnitude * 60;
      case SetBonusType.critDamage:
        return bonus.magnitude * 50;
      case SetBonusType.statBonus:
        return bonus.magnitude * 40;
      case SetBonusType.hpRegen:
        return bonus.magnitude * 10;
      case SetBonusType.goldFind:
      case SetBonusType.xpBonus:
        return bonus.magnitude * 30;
      case SetBonusType.cooldownReduction:
        return bonus.magnitude * 45;
      case SetBonusType.corruptedHPDrain:
        return -bonus.magnitude * 200; // Negative value
    }
  }

  /// Get the next unachieved bonus tier
  SetBonus? _getNextTier(EquipmentSet set, int currentPieces) {
    for (final bonus in set.bonuses) {
      if (bonus.piecesRequired > currentPieces) {
        return bonus;
      }
    }
    return null;
  }

  /// Check if a set is complete (all 6 pieces)
  bool isSetComplete(SetName setName, List<EquipmentSetItem> equippedItems) {
    final pieces = equippedItems.where((i) => i.setName == setName).length;
    return pieces >= 6;
  }

  /// Calculate total HP drain from all corrupted sets
  double getCorruptionDrain(EquipmentSetState state) {
    return state.totalCorruptionDrain;
  }

  /// Get recommendations for auto-equip
  List<SetRecommendation> getAutoEquipRecommendations(
    List<EquipmentSetItem> inventory,
    List<EquipmentSetItem> equipped,
    EquipmentSetState state,
    Character character,
  ) {
    final recommendations = <SetRecommendation>[];

    // Group by slot
    final equippedBySlot = <String, EquipmentSetItem>{};
    for (final item in equipped) {
      equippedBySlot[item.equipment.slot] = item;
    }

    // Evaluate each inventory item
    for (final item in inventory) {
      final currentItem = equippedBySlot[item.equipment.slot];

      final eval = evaluateSetVsStats(item, currentItem, state, character);

      // Calculate if this completes a set bonus
      bool completesBonus = false;
      int? bonusTier;
      if (item.isSetPiece && item.setName != null) {
        final currentPieces =
            state.activeSets[item.setName]?.piecesEquipped ?? 0;
        final newPieces = currentPieces + 1;

        final setDef = _setDefinitions[item.setName];
        if (setDef != null) {
          for (final bonus in setDef.bonuses) {
            if (currentPieces < bonus.piecesRequired &&
                newPieces >= bonus.piecesRequired) {
              completesBonus = true;
              bonusTier = bonus.piecesRequired;
              break;
            }
          }
        }
      }

      recommendations.add(
        SetRecommendation(
          item: item,
          shouldEquip: eval.shouldEquip,
          reason: eval.recommendation,
          statTradeoff: eval.netChange,
          completesSetBonus: completesBonus,
          bonusTierCompleted: bonusTier,
        ),
      );
    }

    // Sort by priority: set completion > stat upgrade > set progress
    recommendations.sort((a, b) {
      if (a.completesSetBonus && !b.completesSetBonus) return -1;
      if (!a.completesSetBonus && b.completesSetBonus) return 1;
      return b.statTradeoff.compareTo(a.statTradeoff);
    });

    return recommendations;
  }

  /// Execute auto-equip logic
  List<String> executeAutoEquip(
    GameProvider gameProvider,
    List<EquipmentSetItem> inventory,
    List<EquipmentSetItem> equipped,
  ) {
    final actions = <String>[];
    final character = gameProvider.character;
    if (character == null) return actions;

    final recommendations = getAutoEquipRecommendations(
      inventory,
      equipped,
      _state,
      character,
    );

    // Track which slots we've processed
    final processedSlots = <String>{};

    for (final rec in recommendations) {
      final slot = rec.item.equipment.slot;

      // Skip if already processed this slot
      if (processedSlots.contains(slot)) continue;

      if (rec.shouldEquip) {
        actions.add(
          'AUTO: Equipped ${rec.item.equipment.name} (${rec.reason})',
        );
        processedSlots.add(slot);

        // Update state
        if (rec.item.isSetPiece && rec.item.setName != null) {
          if (!_state.activeSets.containsKey(rec.item.setName)) {
            _state.activeSets[rec.item.setName!] = ActiveSet(
              setName: rec.item.setName!,
            );
          }
          _state.activeSets[rec.item.setName!]!.piecesEquipped++;

          // Discover the set
          final setDef = _setDefinitions[rec.item.setName];
          if (setDef != null) {
            _state.discoverSet(setDef);
          }

          if (rec.completesSetBonus) {
            actions.add(
              'SET BONUS: Unlocked ${rec.bonusTierCompleted}-piece bonus for ${rec.item.setName}!',
            );
          }
        }
      }
    }

    // Check for synergies
    final synergy = detectSynergies(_state.activeSets);
    if (synergy != null &&
        (_state.activeSynergy?.primarySet != synergy.primarySet ||
            _state.activeSynergy?.secondarySet != synergy.secondarySet)) {
      _state.activeSynergy = synergy;
      _state.discoverSynergy(synergy);

      if (synergy.isUnexpected) {
        actions.add('★ UNEXPECTED SYNERGY: ${synergy.displayName}!');
        actions.add('  ${synergy.description}');
      } else {
        actions.add(
          'SYNERGY: ${synergy.displayName} - ${synergy.synergyBonus.description}',
        );
      }
    }

    // Warn about corruption
    if (_state.hasCorruptionEquipped) {
      final drain = _state.totalCorruptionDrain;
      actions.add(
        '⚠️ CORRUPTION: Taking ${(drain * 100).toStringAsFixed(1)}% HP drain per tick',
      );
    }

    _state.lastUpdated = DateTime.now();
    return actions;
  }

  /// Initialize sets for a new player
  void initializeSets() {
    // Discover all sets (player knows they exist but hasn't found pieces)
    for (final setDef in _setDefinitions.values) {
      _state.discoverSet(setDef);
    }
  }

  /// Get equipment set state
  EquipmentSetState get state => _state;

  /// Apply corruption HP drain during combat
  int calculateCorruptionDamage(int maxHealth) {
    final drain = _state.totalCorruptionDrain;
    if (drain <= 0) return 0;
    return (maxHealth * drain).round();
  }

  /// Check if character can safely equip corrupted items
  bool canSafelyEquipCorruption(Character character) {
    // Need at least 200% effective HP regen to offset corruption
    final regen = _state.getTotalBonus(SetBonusType.hpRegen);
    return regen >= 0.10; // 10% regen per tick minimum
  }

  /// Get all discovered sets
  List<EquipmentSet> get discoveredSets => _state.discoveredSets;

  /// Get active sets
  Map<SetName, ActiveSet> get activeSets => _state.activeSets;

  /// Get current synergy
  SetSynergy? get currentSynergy => _state.activeSynergy;

  /// Get total active bonuses
  List<SetBonus> get totalActiveBonuses => _state.allActiveBonuses;
}
