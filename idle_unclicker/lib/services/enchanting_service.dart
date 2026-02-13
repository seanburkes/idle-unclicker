import 'dart:math';
import '../models/enchanting.dart';
import '../models/character.dart';

// Re-export StringExtension from enchanting.dart
export '../models/enchanting.dart' show StringExtension;

/// Service for managing equipment enchanting, gems, and sockets
class EnchantingService {
  final Random _random = Random();

  /// Socket a gem into equipment
  /// Returns true if successful
  bool socketGem(EnchantedEquipment equipment, int socketIndex, Gem gem) {
    if (socketIndex < 0 || socketIndex >= equipment.sockets.length) {
      return false;
    }

    return equipment.socketGem(socketIndex, gem);
  }

  /// Remove a gem from equipment
  /// Returns the removed gem or null if failed
  Gem? removeGem(EnchantedEquipment equipment, int socketIndex) {
    if (socketIndex < 0 || socketIndex >= equipment.sockets.length) {
      return null;
    }

    return equipment.removeGem(socketIndex);
  }

  /// Enchant an item with a random prefix/suffix
  /// Returns EnchantmentResult with success/failure/destroyed status
  EnchantmentResult enchant(EnchantedEquipment equipment) {
    // Check destruction risk first
    final risk = calculateRisk(equipment);

    if (_random.nextDouble() < risk) {
      // Item destroyed!
      equipment.recordDestruction();
      return EnchantmentResult.destroyed();
    }

    // Generate enchantment
    final enchantment = Enchantment.generate(_random);
    equipment.applyEnchantment(enchantment);

    return EnchantmentResult.success(enchantment);
  }

  /// Calculate the destruction risk for enchanting this item
  /// Base 5% + 1% per previous attempt, capped at 20%
  double calculateRisk(EnchantedEquipment equipment) {
    return equipment.destructionRisk;
  }

  /// Calculate the risk percentage as a user-friendly string
  String getRiskDisplay(EnchantedEquipment equipment) {
    final risk = (calculateRisk(equipment) * 100).round();
    return '$risk%';
  }

  /// Determine if the automaton should auto-enchant this item
  /// Only enchants in town, never legendary, evaluates curses based on playstyle
  bool shouldAutoEnchant(
    Character character,
    EnchantedEquipment equipment,
    String playstyle, {
    required bool isInTown,
  }) {
    // Must be in town for safety
    if (!isInTown) return false;

    // Never enchant legendary items (too risky/valuable)
    if (equipment.baseEquipment.isLegendary) return false;

    // Don't enchant if risk is too high (>15%)
    if (equipment.destructionRisk > 0.15) return false;

    // Don't enchant if already has a good enchantment
    if (equipment.isEnchanted && !equipment.isCursed) return false;

    // Don't enchant if item level is too low for current character
    if (equipment.baseEquipment.level < character.level - 5) return false;

    return true;
  }

  /// Execute auto-enchant for a character
  /// Finds the best non-legendary item and enchants it if safe
  /// Returns a log of actions taken
  List<String> executeAutoEnchant(
    Character character,
    List<EnchantedEquipment> equipment,
    String playstyle, {
    required bool isInTown,
  }) {
    final actions = <String>[];

    if (!isInTown) return actions;
    if (equipment.isEmpty) return actions;

    // Find the best candidate for enchanting
    EnchantedEquipment? bestCandidate;
    double bestScore = -1;

    for (final item in equipment) {
      if (!shouldAutoEnchant(character, item, playstyle, isInTown: isInTown)) {
        continue;
      }

      // Score items: prefer items with open sockets, higher rarity, closer to character level
      double score = 0;

      // Prefer items with sockets (gem potential)
      score += item.socketCount * 10;

      // Prefer higher rarity (but not legendary)
      score += item.baseEquipment.rarity * 5;

      // Prefer items close to character level
      final levelDiff = (character.level - item.baseEquipment.level).abs();
      score -= levelDiff * 2;

      // Prefer items with no enchantment
      if (!item.isEnchanted) score += 20;

      // Prefer weapons for DPS classes, armor for tanks
      if (playstyle.toLowerCase() == 'aggressive' &&
          item.baseEquipment.slot == 'weapon') {
        score += 15;
      } else if (playstyle.toLowerCase() == 'defensive' &&
          item.baseEquipment.slot == 'armor') {
        score += 15;
      }

      if (score > bestScore) {
        bestScore = score;
        bestCandidate = item;
      }
    }

    if (bestCandidate != null) {
      final risk = getRiskDisplay(bestCandidate);
      actions.add(
        'AUTO: Attempting to enchant ${bestCandidate.baseEquipment.name} (Risk: $risk)',
      );

      final result = enchant(bestCandidate);

      if (result.destroyed) {
        actions.add(
          'AUTO: ${bestCandidate.baseEquipment.name} was destroyed during enchantment!',
        );
      } else if (result.success && result.enchantment != null) {
        final enchantedName = result.enchantment!.getEnchantmentName(
          bestCandidate.baseEquipment.name,
        );
        if (result.enchantment!.isCursed) {
          actions.add(
            'AUTO: Applied cursed enchantment: $enchantedName (watch out for the drawback!)',
          );
        } else {
          actions.add('AUTO: Successfully enchanted: $enchantedName');
        }
      }
    }

    return actions;
  }

  /// Get total gem bonuses from equipment
  Map<String, double> getGemBonuses(EnchantedEquipment equipment) {
    return equipment.calculateGemBonuses();
  }

  /// Get total enchantment bonuses from equipment
  Map<String, double> getEnchantmentBonuses(EnchantedEquipment equipment) {
    return equipment.calculateEnchantmentBonuses();
  }

  /// Get all bonuses (gems + enchantments)
  Map<String, double> getAllBonuses(EnchantedEquipment equipment) {
    return equipment.calculateTotalBonuses();
  }

  /// Check if a curse is acceptable for a given playstyle
  bool isCurseAcceptable(CurseType curse, String playstyle) {
    switch (playstyle.toLowerCase()) {
      case 'aggressive':
        // Aggressive playstyle accepts damage-boosting curses
        return curse == CurseType.bloodthirsty || curse == CurseType.fragile;
      case 'defensive':
        // Defensive playstyle accepts armor/survival tradeoffs
        return curse == CurseType.greedy;
      case 'loot':
        // Loot-focused accepts gold curse
        return curse == CurseType.greedy;
      case 'balanced':
      default:
        // Balanced playstyle avoids most curses unless very beneficial
        return false;
    }
  }

  /// Generate a random gem
  Gem generateRandomGem() {
    return Gem.random(_random);
  }

  /// Generate multiple random gems
  List<Gem> generateRandomGems(int count) {
    return List.generate(count, (_) => generateRandomGem());
  }

  /// Check if equipment has empty sockets
  bool hasEmptySockets(EnchantedEquipment equipment) {
    return equipment.emptySocketCount > 0;
  }

  /// Get a recommendation for which gem to socket
  String? getGemRecommendation(EnchantedEquipment equipment, String playstyle) {
    if (!hasEmptySockets(equipment)) return null;

    switch (playstyle.toLowerCase()) {
      case 'aggressive':
        return equipment.baseEquipment.slot == 'weapon'
            ? 'Ruby (+Strength/Damage)'
            : 'Emerald (+Agility/Speed)';
      case 'defensive':
        return equipment.baseEquipment.slot == 'armor'
            ? 'Sapphire (+Intellect/Magic Resist)'
            : 'Ruby (+Strength/Health)';
      case 'loot':
        return 'Emerald (+Agility/Gold Find)';
      case 'balanced':
      default:
        // Match gem to equipment type
        if (equipment.baseEquipment.attackBonus > 0) {
          return 'Ruby (+Strength)';
        } else if (equipment.baseEquipment.defenseBonus > 0) {
          return 'Sapphire (+Intellect/Resist)';
        } else {
          return 'Emerald (+Agility)';
        }
    }
  }

  /// Get all items that can be enchanted from a list
  List<EnchantedEquipment> getEnchantableItems(
    List<EnchantedEquipment> equipment, {
    required bool isInTown,
  }) {
    return equipment.where((item) {
      if (!isInTown) return false;
      if (item.baseEquipment.isLegendary) return false;
      if (item.destructionRisk > 0.20) return false;
      return true;
    }).toList();
  }

  /// Calculate the total power increase from enchanting
  double calculatePowerIncrease(EnchantedEquipment equipment) {
    final baseAttack = equipment.baseEquipment.attackBonus;
    final baseDefense = equipment.baseEquipment.defenseBonus;

    final effectiveAttack = equipment.effectiveAttackBonus;
    final effectiveDefense = equipment.effectiveDefenseBonus;

    final attackIncrease = baseAttack > 0
        ? (effectiveAttack - baseAttack) / baseAttack
        : 0.0;
    final defenseIncrease = baseDefense > 0
        ? (effectiveDefense - baseDefense) / baseDefense
        : 0.0;

    // Average the increases
    if (attackIncrease > 0 && defenseIncrease > 0) {
      return (attackIncrease + defenseIncrease) / 2;
    } else if (attackIncrease > 0) {
      return attackIncrease;
    } else if (defenseIncrease > 0) {
      return defenseIncrease;
    }

    return 0.0;
  }

  /// Get a display name for an equipment slot
  String getSlotDisplayName(String slot) {
    switch (slot.toLowerCase()) {
      case 'weapon':
        return 'Weapon';
      case 'armor':
        return 'Armor';
      case 'accessory':
        return 'Accessory';
      case 'helmet':
        return 'Helmet';
      case 'gloves':
        return 'Gloves';
      case 'boots':
        return 'Boots';
      case 'head':
        return 'Head';
      case 'shoulders':
        return 'Shoulders';
      case 'chest':
        return 'Chest';
      case 'pants':
        return 'Pants';
      case 'feet':
        return 'Feet';
      case 'main_hand':
        return 'Main Hand';
      case 'off_hand':
        return 'Off Hand';
      case 'knees':
        return 'Knees';
      case 'toes':
        return 'Toes';
      case 'eyes':
        return 'Eyes';
      case 'ears':
        return 'Ears';
      case 'mouth':
        return 'Mouth';
      case 'nose':
        return 'Nose';
      default:
        return slot.capitalize();
    }
  }

  /// Format a bonus percentage for display
  String formatBonus(double percent) {
    final value = (percent * 100).round();
    final sign = value >= 0 ? '+' : '';
    return '$sign$value%';
  }
}
