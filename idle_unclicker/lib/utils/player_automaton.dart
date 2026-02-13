import 'dart:math';
import '../models/character.dart';
import '../models/equipment.dart';
import '../models/enchanting.dart';
import '../models/boss_rush.dart';
import '../models/equipment_sets.dart';
import '../models/transmutation.dart';
import '../models/legendary_items.dart';
import '../models/infinite_spiral.dart';
import '../services/enchanting_service.dart';
import '../services/boss_rift_service.dart';
import '../services/profession_service.dart';
import '../services/equipment_set_service.dart';
import '../services/transmutation_service.dart';
import '../services/alchemy_service.dart';
import '../services/legendary_item_service.dart';
import '../services/spiral_service.dart';
import '../utils/rpg_system.dart';
import '../utils/procedural_generator.dart';

/// Player Automaton - AI system that makes decisions for the character
/// Handles: equipment, combat tactics, resource management, town visits, boss/rift decisions
class PlayerAutomaton {
  final Random _random = Random();

  /// Make all automated decisions for a combat turn
  /// Returns a log of actions taken
  List<String> processCombatTurn(Character character, AutomatonContext ctx) {
    final actions = <String>[];

    // 0. Check corruption drain if using equipment sets
    if (ctx.equipmentSetService != null) {
      final setService = ctx.equipmentSetService!;
      final corruptionDrain = setService.getCorruptionDrain(setService.state);
      if (corruptionDrain > 0) {
        final regen = setService.state.getTotalBonus(SetBonusType.hpRegen);
        if (regen < corruptionDrain * 3) {
          actions.add(
            'WARNING: Corruption drain (${(corruptionDrain * 100).toStringAsFixed(1)}%) exceeds regen!',
          );
          // Consider fleeing if corruption is killing us
          if (character.currentHealth <= character.maxHealth * 0.3) {
            actions.add('AUTO: Corruption too dangerous! Attempting to flee!');
            return actions;
          }
        }
      }
    }

    // 1. Check if we should flee (critical health, no potions)
    if (_shouldFlee(character)) {
      actions.add('AUTO: Attempting to flee!');
      return actions;
    }

    // 2. Use potion if health is low
    if (_shouldUsePotion(character)) {
      character.useHealthPotion();
      actions.add('AUTO: Used health potion');
    }

    // 3. Auto-equip better gear from inventory
    final equipActions = _autoEquip(character, ctx);
    actions.addAll(equipActions);

    return actions;
  }

  /// Decide post-combat actions (loot, continue, return to town)
  List<String> processPostCombat(Character character, bool victory) {
    final actions = <String>[];

    if (!victory) {
      // Died - will be handled by death system
      return actions;
    }

    // Check if we should return to town
    if (_shouldReturnToTown(character)) {
      actions.add(
        'AUTO: Inventory full or low on resources, returning to town',
      );
      return actions;
    }

    // Decide whether to continue or rest
    if (character.isAtCriticalHealth) {
      actions.add('AUTO: Resting to recover health');
      character.rest();
    }

    return actions;
  }

  /// Process town activities (sell, buy, identify, enchant, craft, transmute, brew)
  List<String> processTownVisit(
    Character character,
    List<Equipment> inventory, {
    List<EnchantedEquipment> enchantedEquipment = const [],
    EnchantingService? enchantingService,
    ProfessionService? professionService,
    TransmutationService? transmutationService,
    AlchemyService? alchemyService,
    List<TransmutableItem> transmutableItems = const [],
    String playstyle = 'balanced',
    bool isInTown = true,
    bool isBeforeBoss = false,
  }) {
    final actions = <String>[];

    // Sell items that aren't equipped and are low value
    final itemsToSell = _getItemsToSell(character, inventory);
    for (final item in itemsToSell) {
      final sellPrice = _calculateSellPrice(item);
      character.gold += sellPrice;
      actions.add('AUTO: Sold ${item.name} for $sellPrice gold');
    }

    // Buy potions if needed
    if (character.healthPotions < 3 && character.gold >= 50) {
      final potionsToBuy = min(
        5 - character.healthPotions,
        character.gold ~/ 50,
      );
      character.gold -= potionsToBuy * 50;
      character.healthPotions += potionsToBuy;
      actions.add('AUTO: Bought $potionsToBuy health potions');
    }

    // Try to upgrade equipment if we have gold
    final upgradeActions = _tryUpgradeEquipment(character);
    actions.addAll(upgradeActions);

    // Auto-enchant equipment when in town
    if (enchantingService != null && enchantedEquipment.isNotEmpty) {
      final enchantActions = enchantingService.executeAutoEnchant(
        character,
        enchantedEquipment,
        playstyle,
        isInTown: isInTown,
      );
      actions.addAll(enchantActions);
    }

    // Auto-craft items using professions when in town
    if (professionService != null && isInTown) {
      final craftActions = professionService.executeAutoCraft(character);
      actions.addAll(craftActions);
    }

    // Auto-transmute excess items when in town
    if (transmutationService != null &&
        isInTown &&
        transmutableItems.isNotEmpty) {
      // Group items by tier
      final itemsByTier = <ItemTier, List<TransmutableItem>>{};
      for (final item in transmutableItems) {
        itemsByTier.putIfAbsent(item.tier, () => []).add(item);
      }

      // Check if we should auto-transmute
      final shouldTransmute = transmutationService.shouldAutoTransmute(
        totalInventoryItems: transmutableItems.length,
        maxInventorySize: 100, // Default max inventory
        itemsByTier: {for (var e in itemsByTier.entries) e.key: e.value.length},
        isInTown: isInTown,
      );

      if (shouldTransmute) {
        final transmuteActions = transmutationService.executeAutoTransmute(
          itemsByTier: itemsByTier,
          onItemsConsumed: (tier, count) {
            // Items are consumed during transmutation
          },
          onItemsProduced: (tier, count) {
            // Items are produced during transmutation
          },
        );
        actions.addAll(transmuteActions);
      }
    }

    // Auto-brew potions when in town
    if (alchemyService != null && isInTown) {
      final shouldBrew = alchemyService.shouldAutoBrew(
        currentHealth: character.currentHealth,
        maxHealth: character.maxHealth,
        isInCombat: false,
        isBeforeBoss: isBeforeBoss,
        isInTown: isInTown,
      );

      if (shouldBrew) {
        final brewActions = alchemyService.executeAutoBrew(
          character: character,
          isBeforeBoss: isBeforeBoss,
        );
        actions.addAll(brewActions);
      }
    }

    return actions;
  }

  /// Handle death and resurrection
  List<String> processDeath(Character character) {
    final actions = <String>[];

    actions.add('AUTO: Character died! Respawning in town...');

    // Reset to town
    character.dungeonDepth = 1;
    character.currentHealth = character.maxHealth;
    character.currentMana = character.maxMana;
    character.isAlive = true;
    character.totalDeaths++;

    // Keep some gold (50%), lose the rest
    character.gold = (character.gold * 0.5).round();

    // Ensure minimum potions
    character.healthPotions = max(3, character.healthPotions);

    actions.add('AUTO: Respawned. Lost 50% gold, kept equipment.');

    return actions;
  }

  /// Detect if there's a boss on the current floor and decide what to do
  /// Returns action log
  List<String> detectAndEvaluateBoss(
    Character character,
    int currentFloor,
    BossRiftService? bossService,
  ) {
    final actions = <String>[];

    if (bossService == null) return actions;
    if (!bossService.isBossFloor(currentFloor)) return actions;

    // Check if boss already defeated
    final alreadyDefeated = bossService.defeatedBosses.any(
      (b) => b.floor == currentFloor,
    );
    if (alreadyDefeated) return actions;

    // Get or generate boss
    final boss = bossService.generateBoss(currentFloor);
    if (boss == null) return actions;

    actions.add('AUTO: Boss ${boss.name} detected on floor $currentFloor!');
    actions.add(
      'AUTO: Mechanic: ${boss.mechanic.displayName} - ${boss.mechanic.description}',
    );

    // Evaluate if we can fight
    final confidence = bossService.canAttemptBoss(character, boss);
    actions.add(
      'AUTO: Power estimation: ${confidence.toStringAsFixed(0)}% confidence',
    );

    if (confidence < 70.0) {
      actions.add('AUTO: Too dangerous! Fleeing to safety...');
      // Signal to flee - caller should handle
    } else {
      actions.add('AUTO: Engaging boss!');
      // Signal to fight - caller should handle
    }

    return actions;
  }

  /// Check for daily rift availability in town
  /// Returns action log
  List<String> checkAndEvaluateRift(
    Character character,
    BossRiftService? bossService,
    bool isInTown,
  ) {
    final actions = <String>[];

    if (bossService == null) return actions;
    if (!isInTown) return actions;

    // Generate daily rift if needed
    final rift = bossService.generateDailyRift();
    if (rift == null) return actions;

    // Check if already completed today
    if (rift.completed) return actions;

    actions.add('AUTO: Daily Rift "${rift.name}" is available!');
    actions.add(
      'AUTO: Modifier: ${rift.modifier.displayName} - ${rift.modifier.description}',
    );

    // Evaluate if we should enter
    final confidence = bossService.shouldAttemptRift(character, rift);
    actions.add('AUTO: Rift confidence: ${confidence.toStringAsFixed(0)}%');

    if (confidence < 70.0) {
      // Special handling for ironman - more risk averse
      if (rift.modifier == RiftModifier.ironman) {
        actions.add('AUTO: Ironman modifier too risky. Skipping rift.');
      } else {
        actions.add('AUTO: Confidence too low. Skipping rift for now.');
      }
    } else {
      actions.add('AUTO: Entering rift!');
    }

    return actions;
  }

  /// Make boss combat decision during fight
  /// This is called each combat tick during boss fights
  List<String> processBossCombatTick(
    Character character,
    Boss boss,
    BossRiftService bossService,
  ) {
    final actions = <String>[];

    // Process boss mechanic
    bossService.processBossMechanicStart(boss);

    // Handle specific mechanics
    switch (boss.mechanic) {
      case BossMechanic.overgrowth:
        if (boss.currentHealth < boss.maxHealth) {
          actions.add('AUTO: ${boss.name} regenerates health!');
        }
        break;
      case BossMechanic.shieldPhases:
        if (boss.isShielded) {
          actions.add(
            'AUTO: ${boss.name} is shielded! Damage will be reduced.',
          );
        }
        break;
      case BossMechanic.timeLimit:
        if (boss.isEnraged) {
          actions.add('AUTO: WARNING! ${boss.name} is ENRAGED!');
        } else if (boss.turnCounter >= 25) {
          actions.add('AUTO: ${boss.name} will enrage soon!');
        }
        break;
      case BossMechanic.minionSwarm:
        if (bossService.shouldSpawnMinions(boss)) {
          actions.add('AUTO: ${boss.name} spawns minions!');
        }
        break;
      default:
        break;
    }

    // Check for flee condition (critical health)
    if (character.currentHealth <= character.maxHealth * 0.15) {
      actions.add('AUTO: Critical health during boss fight!');
      final confidence = bossService.canAttemptBoss(character, boss);
      if (confidence < 30.0) {
        actions.add('AUTO: Fleeing from boss!');
      }
    }

    return actions;
  }

  /// Calculate offline progression
  /// Only runs if more than 8 hours have passed
  OfflineResult calculateOfflineProgress(
    Character character,
    int offlineSeconds,
    int dungeonDepth,
  ) {
    // Only process if more than 8 hours (28800 seconds)
    if (offlineSeconds < 28800) {
      return OfflineResult(
        xpGained: 0,
        goldGained: 0,
        itemsFound: [],
        encounters: 0,
        didProcess: false,
      );
    }

    // Calculate how many 5-minute combat cycles occurred
    final cycles = offlineSeconds ~/ 300; // 5 minutes per cycle
    final maxCycles = min(cycles, 100); // Cap at 100 cycles to prevent overflow

    int totalXP = 0;
    int totalGold = 0;
    final itemsFound = <Equipment>[];
    int encounters = 0;
    int deaths = 0;

    // Simulate combat cycles
    for (int i = 0; i < maxCycles; i++) {
      // 30% chance of encounter per cycle
      if (_random.nextDouble() > 0.3) continue;

      encounters++;

      // Generate monster for current depth
      final monster = RPGSystem.generateMonster(dungeonDepth, character.level);

      // Simulate combat (simplified)
      final playerPower = character.attackPower + character.defense;
      final monsterPower = monster.damage + monster.armor;

      // Player wins if significantly stronger or lucky
      final winChance = playerPower / (playerPower + monsterPower);
      final won = _random.nextDouble() < winChance;

      if (won) {
        // Victory rewards
        totalXP += monster.xpValue;
        totalGold += ProceduralGenerator.rollDice(20) + dungeonDepth;

        // 15% chance to find item
        if (_random.nextDouble() < 0.15) {
          itemsFound.add(_generateRandomItem(dungeonDepth));
        }

        // 30% chance to find potion
        if (_random.nextDouble() < 0.30) {
          character.healthPotions = min(20, character.healthPotions + 1);
        }
      } else {
        // Death - respawn and continue from town at level 1
        deaths++;
        dungeonDepth = 1;
        // Keep partial rewards from this cycle
        totalXP += (monster.xpValue * 0.3).round();
      }

      // Stop if too many deaths
      if (deaths >= 3) {
        break;
      }
    }

    return OfflineResult(
      xpGained: totalXP,
      goldGained: totalGold,
      itemsFound: itemsFound,
      encounters: encounters,
      didProcess: true,
      deaths: deaths,
    );
  }

  // ============================================================================
  // Private Decision Methods
  // ============================================================================

  bool _shouldFlee(Character character) {
    // Flee if critical health and no potions
    if (character.isAtCriticalHealth && character.healthPotions == 0) {
      return true;
    }
    // Flee if health below 10% even with potions (emergency)
    if (character.currentHealth <= character.maxHealth * 0.1) {
      return _random.nextDouble() < 0.7; // 70% chance to flee
    }
    return false;
  }

  bool _shouldUsePotion(Character character) {
    // Use potion if below 50% health and in danger
    if (character.healthPotions == 0) return false;
    if (character.currentHealth <= character.maxHealth * 0.5) {
      return _random.nextDouble() < 0.8; // 80% chance to use
    }
    return false;
  }

  bool _shouldReturnToTown(Character character) {
    // Return if low on potions AND gold to buy more
    if (character.healthPotions <= 1 && character.gold < 50) {
      return _random.nextDouble() < 0.9;
    }
    // Return if health is low after combat
    if (character.currentHealth <= character.maxHealth * 0.3) {
      return _random.nextDouble() < 0.5;
    }
    return false;
  }

  List<String> _autoEquip(Character character, AutomatonContext ctx) {
    final actions = <String>[];

    // Use Equipment Set Service if available for intelligent equip decisions
    if (ctx.equipmentSetService != null && ctx.setInventory.isNotEmpty) {
      final setService = ctx.equipmentSetService!;
      final equippedItems = ctx.equippedSetItems;

      // Get recommendations from set service
      final recommendations = setService.getAutoEquipRecommendations(
        ctx.setInventory,
        equippedItems,
        setService.state,
        character,
      );

      // Process recommendations
      final processedSlots = <String>{};
      for (final rec in recommendations.where((r) => r.shouldEquip).take(3)) {
        final slot = rec.item.equipment.slot;
        if (processedSlots.contains(slot)) continue;

        processedSlots.add(slot);

        // Log the decision
        if (rec.completesSetBonus) {
          actions.add(
            'AUTO: Equipped ${rec.item.displayName} - Completes ${rec.bonusTierCompleted}-piece bonus!',
          );
        } else if (rec.statTradeoff > 0) {
          actions.add(
            'AUTO: Equipped ${rec.item.displayName} - Better stats (+${(rec.statTradeoff * 100).toStringAsFixed(0)}%)',
          );
        } else if (rec.item.isSetPiece) {
          actions.add(
            'AUTO: Equipped ${rec.item.displayName} - Set progress (${rec.reason})',
          );
        }

        // Check for corruption risk
        if (rec.item.setName == SetName.voidWhisperers) {
          if (!setService.canSafelyEquipCorruption(character)) {
            actions.add(
              'WARNING: Equipped corrupted item without sufficient HP regen!',
            );
          }
        }
      }

      // Check for synergies if we made changes
      if (actions.isNotEmpty) {
        final synergy = setService.detectSynergies(setService.activeSets);
        if (synergy != null) {
          if (synergy.isUnexpected) {
            actions.add(
              '★ UNEXPECTED SYNERGY: ${synergy.displayName}! ${synergy.synergyBonus.description}',
            );
          } else {
            actions.add(
              'SET SYNERGY: ${synergy.displayName} - ${synergy.description}',
            );
          }
        }
      }
    }

    // Evaluate legendary items if service is available
    if (ctx.legendaryItemService != null && ctx.legendaryInventory.isNotEmpty) {
      final legendaryService = ctx.legendaryItemService!;

      // Check each slot for legendary upgrades
      for (final slot in EquipmentSlotType.values) {
        final slotLegendaries = ctx.legendaryInventory
            .where((l) => l.equipmentType == slot)
            .toList();

        if (slotLegendaries.isEmpty) continue;

        // Get the best legendary for this slot
        slotLegendaries.sort(
          (a, b) => b.totalStatValue.compareTo(a.totalStatValue),
        );
        final bestLegendary = slotLegendaries.first;

        // Check if we should equip it
        final shouldEquip = legendaryService.shouldEquipLegendary(
          bestLegendary,
          null, // Would need current equipped item reference
        );

        if (shouldEquip) {
          if (bestLegendary.isAwakened) {
            actions.add(
              '★ LEGENDARY EQUIPPED: ${bestLegendary.name} (Awakened ${bestLegendary.effect.type.icon})',
            );
          } else {
            actions.add(
              'LEGENDARY EQUIPPED: ${bestLegendary.name} ${bestLegendary.effect.type.icon}',
            );
          }

          // Check for sentience desires
          if (bestLegendary.hasSentience && !bestLegendary.isAwakened) {
            actions.add('  ${bestLegendary.sentience!.desireDescription}');
          }
        }
      }

      // Check for reforge opportunities
      final reforgeable = ctx.legendaryInventory
          .where((l) => l.canReforge)
          .toList();
      for (final item in reforgeable.take(2)) {
        if (item.reforgeCount < 2) {
          actions.add(
            'AUTO: ${item.name} could be reforged for better stats (${item.reforgeCount}/10)',
          );
        }
      }
    }

    // Fallback to simple stat comparison if no set service or legendaries
    if (actions.isEmpty) {
      if (ctx.availableWeapons.isNotEmpty) {
        final bestWeapon = ctx.availableWeapons.reduce(
          (a, b) => a.attackBonus > b.attackBonus ? a : b,
        );
        actions.add('AUTO: Equipped better weapon (${bestWeapon.name})');
      }

      if (ctx.availableArmor.isNotEmpty) {
        final bestArmor = ctx.availableArmor.reduce(
          (a, b) => a.defenseBonus > b.defenseBonus ? a : b,
        );
        actions.add('AUTO: Equipped better armor (${bestArmor.name})');
      }
    }

    return actions;
  }

  /// Calculate effective power considering set bonuses
  double calculateEffectivePower(
    Character character,
    EquipmentSetService? setService,
  ) {
    double basePower = character.attackPower + character.defense.toDouble();

    if (setService == null) return basePower;

    // Add value from set bonuses
    for (final bonus in setService.totalActiveBonuses) {
      switch (bonus.type) {
        case SetBonusType.damageIncrease:
          basePower *= (1 + bonus.magnitude);
          break;
        case SetBonusType.damageReduction:
          basePower *= (1 + bonus.magnitude * 0.5); // Defensive value
          break;
        case SetBonusType.lifeSteal:
          basePower *= (1 + bonus.magnitude * 2); // Survival value
          break;
        case SetBonusType.critChance:
        case SetBonusType.critDamage:
          basePower *= (1 + bonus.magnitude * 0.8);
          break;
        default:
          basePower *= (1 + bonus.magnitude * 0.3);
      }
    }

    // Apply corruption penalty if present
    final corruptionDrain = setService.getCorruptionDrain(setService.state);
    if (corruptionDrain > 0) {
      // Reduce effective power if we can't sustain the drain
      final regen = setService.state.getTotalBonus(SetBonusType.hpRegen);
      if (regen < corruptionDrain * 5) {
        basePower *= 0.8; // 20% penalty for risky corruption use
      }
    }

    return basePower;
  }

  /// Calculate effective power considering legendary bonuses
  double calculateEffectivePowerWithLegendaries(
    Character character,
    EquipmentSetService? setService,
    LegendaryItemService? legendaryService,
  ) {
    double basePower = calculateEffectivePower(character, setService);

    if (legendaryService == null) return basePower;

    // Add legendary bonuses
    final equippedLegendaries = legendaryService.ownedLegendaries
        .where((l) => l.acquiredDate != null) // Actually equipped
        .toList();

    // Damage bonuses
    final damageBonus = legendaryService.getDamageBonus(equippedLegendaries);
    basePower *= (1 + damageBonus);

    // Defense bonuses
    final defenseBonus = legendaryService.getDefenseBonus(equippedLegendaries);
    basePower *= (1 + defenseBonus * 0.5);

    // Crit bonuses
    final critBonuses = legendaryService.getCritBonuses(equippedLegendaries);
    basePower *=
        (1 + critBonuses['chance']! * 0.8 + critBonuses['damage']! * 0.5);

    // Life steal survival value
    final lifeSteal = legendaryService.getLifeSteal(equippedLegendaries);
    basePower *= (1 + lifeSteal * 2);

    return basePower;
  }

  /// Process spiral-related decisions
  /// Called during combat to handle floor 100 transitions and tale optimization
  List<String> processSpiralDecisions(
    Character character,
    AutomatonContext ctx,
  ) {
    final actions = <String>[];

    if (ctx.spiralService == null) return actions;
    final spiral = ctx.spiralService!;

    // Check if approaching floor 100
    if (character.dungeonDepth >= 95 && !spiral.spiral.hasReachedFloor100) {
      actions.add(
        'AUTO: Approaching the Spiral! Preparing for transcendence...',
      );

      // Be more cautious near floor 100 to ensure we make it
      if (character.currentHealth < character.maxHealth * 0.5) {
        actions.add('AUTO: Health low before Spiral - considering retreat');
      }
    }

    // If in spiral mode, adjust tactics based on multipliers
    if (ctx.isInSpiral) {
      final loopInfo = spiral.getCurrentLoopInfo();
      final enemyMult = loopInfo['enemyHpMultiplier'] as double;

      // Be more careful in higher loops
      if (enemyMult > 1.5 &&
          character.currentHealth < character.maxHealth * 0.4) {
        actions.add('AUTO: High loop enemy multipliers - playing defensively');
      }

      // Check for incomplete tales that might influence decisions
      final spiralContext = spiral.getAutomatonContext();
      final incompleteTales =
          spiralContext['incompleteTales'] as List<TaleType>;

      // Optimize for tale completion
      for (final taleType in incompleteTales.take(3)) {
        switch (taleType) {
          case TaleType.dragonSlayer:
            actions.add('AUTO: Seeking dragons for Dragon Slayer tale...');
            break;
          case TaleType.bossConqueror:
            actions.add('AUTO: Prioritizing boss encounters...');
            break;
          case TaleType.pacifist:
            // If trying for pacifist, avoid kills
            if (character.dungeonDepth < 50) {
              actions.add('AUTO: Pacifist run - avoiding combat when possible');
            }
            break;
          case TaleType.treasureHunter:
            actions.add('AUTO: Prioritizing gold-rich areas...');
            break;
          default:
            break;
        }
      }
    }

    return actions;
  }

  /// Handle floor 100 transition logic
  List<String> handleFloor100Transition(
    Character character,
    SpiralService spiralService,
    bool autoAdvanceEnabled,
  ) {
    final actions = <String>[];

    if (character.dungeonDepth < 100) return actions;

    if (!spiralService.spiral.hasReachedFloor100) {
      actions.add('🌀 Floor 100 reached for the first time!');
      actions.add('The Spiral awaits... Enable auto-advance to begin looping.');
    } else if (autoAdvanceEnabled) {
      actions.add('🌀 The Spiral continues...');
      actions.add(
        'Loop ${spiralService.spiral.currentLoop.loopNumber} complete!',
      );
    }

    return actions;
  }

  /// Check if should continue to next loop or rest
  bool shouldContinueToNextLoop(Character character, AutomatonContext ctx) {
    if (!ctx.isInSpiral) return false;
    if (ctx.spiralService == null) return false;

    // Check if auto-advance is enabled
    if (!ctx.spiralService!.spiral.autoAdvanceEnabled) return false;

    // Check if health is adequate for next loop
    if (character.currentHealth < character.maxHealth * 0.3) {
      return false; // Rest first
    }

    // Check potion supply
    if (character.healthPotions < 2) {
      return false; // Need more potions
    }

    return true;
  }

  List<Equipment> _getItemsToSell(
    Character character,
    List<Equipment> inventory,
  ) {
    // Sell items that are worse than equipped gear
    return inventory.where((item) {
      // Keep items that might be useful
      if (item.rarity >= 3) return false; // Keep rare+ items
      if (item.level >= character.level) return false; // Keep high level items
      return true;
    }).toList();
  }

  int _calculateSellPrice(Equipment item) {
    final basePrice = item.level * 10;
    final rarityMultiplier = item.rarity;
    return basePrice * rarityMultiplier;
  }

  List<String> _tryUpgradeEquipment(Character character) {
    final actions = <String>[];

    final weapons = RPGSystem.weaponProgression;
    final armors = RPGSystem.armorProgression;
    final maxTier = RPGSystem.maxGearTierForLevel(character.level);

    // Try to buy better weapon if affordable
    final currentWeaponIdx = weapons.indexOf(character.weaponType);
    if (currentWeaponIdx < min(weapons.length - 1, maxTier) &&
        character.gold >= 200) {
      if (_random.nextDouble() < 0.3) {
        // 30% chance to find upgrade
        character.weaponType = weapons[currentWeaponIdx + 1];
        character.gold -= 200;
        final type = RPGSystem.weaponTypes[character.weaponType]!;
        actions.add('AUTO: Bought better weapon: ${type.name}');
      }
    }

    // Try to buy better armor
    final currentArmorIdx = armors.indexOf(character.armorType);
    if (currentArmorIdx < min(armors.length - 1, maxTier) &&
        character.gold >= 200) {
      if (_random.nextDouble() < 0.3) {
        character.armorType = armors[currentArmorIdx + 1];
        character.gold -= 200;
        final type = RPGSystem.armorTypes[character.armorType]!;
        actions.add('AUTO: Bought better armor: ${type.name}');
      }
    }

    return actions;
  }

  Equipment _generateRandomItem(int depth) {
    final slots = Equipment.allSlots;
    final slot = slots[_random.nextInt(slots.length)];

    final rarities = [1, 1, 1, 2, 2, 3]; // Weighted toward common
    final rarity = rarities[_random.nextInt(rarities.length)];

    return Equipment(
      name: 'Found ${slot.replaceAll('_', ' ')} ($rarity★)',
      slot: slot,
      level: depth + _random.nextInt(3),
      rarity: rarity,
      attackBonus: slot == 'main_hand' ? depth + rarity : 0,
      defenseBonus: slot == 'chest' ? depth + rarity : 0,
    );
  }
}

/// Context for automaton decisions
class AutomatonContext {
  final List<Equipment> availableWeapons;
  final List<Equipment> availableArmor;
  final int currentDungeonDepth;
  final bool isInCombat;
  final bool isInTown;
  final List<EnchantedEquipment> enchantedEquipment;
  final EnchantingService? enchantingService;
  final BossRiftService? bossRiftService;
  final ProfessionService? professionService;
  final EquipmentSetService? equipmentSetService;
  final String playstyle;
  final Boss? currentBoss;
  final double focusPercentage;
  final List<EquipmentSetItem> setInventory;
  final List<EquipmentSetItem> equippedSetItems;
  final TransmutationService? transmutationService;
  final AlchemyService? alchemyService;
  final List<TransmutableItem> transmutableItems;
  final bool isBeforeBoss;
  final LegendaryItemService? legendaryItemService;
  final List<LegendaryItem> legendaryInventory;
  final List<LegendaryItem> equippedLegendaries;
  final SpiralService? spiralService;
  final bool isInSpiral;
  final int currentSpiralLoop;

  AutomatonContext({
    this.availableWeapons = const [],
    this.availableArmor = const [],
    this.currentDungeonDepth = 1,
    this.isInCombat = false,
    this.isInTown = false,
    this.enchantedEquipment = const [],
    this.enchantingService,
    this.bossRiftService,
    this.professionService,
    this.equipmentSetService,
    this.playstyle = 'balanced',
    this.currentBoss,
    this.focusPercentage = 0.0,
    this.setInventory = const [],
    this.equippedSetItems = const [],
    this.transmutationService,
    this.alchemyService,
    this.transmutableItems = const [],
    this.isBeforeBoss = false,
    this.legendaryItemService,
    this.legendaryInventory = const [],
    this.equippedLegendaries = const [],
    this.spiralService,
    this.isInSpiral = false,
    this.currentSpiralLoop = 1,
  });
}

/// Results from offline progression calculation
class OfflineResult {
  final int xpGained;
  final int goldGained;
  final List<Equipment> itemsFound;
  final int encounters;
  final bool didProcess;
  final int deaths;

  OfflineResult({
    required this.xpGained,
    required this.goldGained,
    required this.itemsFound,
    required this.encounters,
    required this.didProcess,
    this.deaths = 0,
  });

  String get summary {
    if (!didProcess) return 'No offline progress (less than 8 hours)';
    return '$encounters battles, $xpGained XP, $goldGained gold, ${itemsFound.length} items${deaths > 0 ? ', $deaths deaths' : ''}';
  }
}
