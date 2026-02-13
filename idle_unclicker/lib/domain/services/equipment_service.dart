import 'dart:math';
import '../entities/equipment.dart';
import '../value_objects/equipment_enums.dart';

/// Domain service for equipment-related operations
///
/// Handles equipment generation, comparison, and upgrade logic
class EquipmentService {
  final Random _random;

  EquipmentService({Random? random}) : _random = random ?? Random();

  /// Generates random equipment for a dungeon level
  Equipment generateEquipment(
    int dungeonLevel, {
    EquipmentSlot? forcedSlot,
    EquipmentRarity? forcedRarity,
  }) {
    final slot = forcedSlot ?? _randomSlot();
    final rarity = forcedRarity ?? _randomRarity(dungeonLevel);

    final name = _generateEquipmentName(slot, rarity);
    final itemLevel = dungeonLevel + _random.nextInt(3);

    return Equipment.create(
      name: name,
      slot: slot,
      rarity: rarity,
      itemLevel: itemLevel,
    );
  }

  /// Generates multiple pieces of equipment
  List<Equipment> generateEquipmentBatch(
    int dungeonLevel,
    int count, {
    double magicFind = 1.0,
  }) {
    final equipment = <Equipment>[];

    for (var i = 0; i < count; i++) {
      // Magic find increases rarity chance
      final rarity = _randomRarityWithMagicFind(dungeonLevel, magicFind);
      equipment.add(generateEquipment(dungeonLevel, forcedRarity: rarity));
    }

    return equipment;
  }

  /// Generates a gem
  Gem generateGem({int? forcedTier}) {
    final types = GemType.values;
    final type = types[_random.nextInt(types.length)];
    final tier = forcedTier ?? _random.nextInt(5) + 1;

    final name = '${type.displayName} Gem';

    return Gem(name: name, type: type, tier: tier);
  }

  /// Upgrades equipment to next tier
  Equipment upgradeEquipment(Equipment equipment) {
    if (equipment.rarity == EquipmentRarity.legendary) {
      throw StateError('Cannot upgrade legendary equipment');
    }

    final nextRarity = EquipmentRarity.values[equipment.rarity.index + 1];

    // Create new equipment with upgraded rarity
    final upgraded = Equipment.create(
      name: equipment.name,
      slot: equipment.slot,
      rarity: nextRarity,
      itemLevel: equipment.itemLevel,
    );

    // Transfer gems
    for (
      var i = 0;
      i < equipment.sockets.length && i < upgraded.sockets.length;
      i++
    ) {
      if (equipment.sockets[i].isFilled && equipment.sockets[i].gem != null) {
        upgraded.insertGem(i, equipment.sockets[i].gem!);
      }
    }

    return upgraded;
  }

  /// Compares two equipment pieces and returns which is better
  EquipmentComparison compare(Equipment a, Equipment b) {
    if (a.slot != b.slot) {
      throw ArgumentError('Cannot compare equipment of different slots');
    }

    final aStats = a.totalStats.totalStats;
    final bStats = b.totalStats.totalStats;

    if (aStats > bStats) {
      return EquipmentComparison(
        better: a,
        worse: b,
        statDifference: aStats - bStats,
        isUpgrade: true,
      );
    } else if (bStats > aStats) {
      return EquipmentComparison(
        better: b,
        worse: a,
        statDifference: bStats - aStats,
        isUpgrade: true,
      );
    } else {
      return EquipmentComparison(
        better: a,
        worse: b,
        statDifference: 0,
        isUpgrade: false,
      );
    }
  }

  /// Calculates sell price for equipment
  int calculateSellPrice(Equipment equipment) {
    final basePrice = equipment.itemLevel * 10;
    final rarityMultiplier = equipment.rarity.starCount;
    return (basePrice * rarityMultiplier).toInt();
  }

  /// Calculates buy price for equipment
  int calculateBuyPrice(Equipment equipment) {
    return calculateSellPrice(equipment) * 2;
  }

  /// Generates starting equipment for a new character
  List<Equipment> generateStartingEquipment() {
    return [
      Equipment.create(
        name: 'Rusty Sword',
        slot: EquipmentSlot.mainHand,
        rarity: EquipmentRarity.common,
        itemLevel: 1,
      ),
      Equipment.create(
        name: 'Worn Leather Armor',
        slot: EquipmentSlot.chest,
        rarity: EquipmentRarity.common,
        itemLevel: 1,
      ),
    ];
  }

  // === Private Helpers ===

  EquipmentSlot _randomSlot() {
    final slots = EquipmentSlot.values;
    return slots[_random.nextInt(slots.length)];
  }

  EquipmentRarity _randomRarity(int dungeonLevel) {
    return _randomRarityWithMagicFind(dungeonLevel, 1.0);
  }

  EquipmentRarity _randomRarityWithMagicFind(
    int dungeonLevel,
    double magicFind,
  ) {
    // Base chances
    var commonChance = 60.0;
    var uncommonChance = 25.0;
    var rareChance = 10.0;
    var epicChance = 4.0;
    var legendaryChance = 1.0;

    // Adjust for dungeon level (higher levels = better gear)
    final levelBonus = dungeonLevel * 0.5;
    commonChance -= levelBonus;
    uncommonChance += levelBonus * 0.3;
    rareChance += levelBonus * 0.2;
    epicChance += levelBonus * 0.05;
    legendaryChance += levelBonus * 0.01;

    // Apply magic find
    commonChance /= magicFind;
    legendaryChance *= magicFind;

    final roll = _random.nextDouble() * 100;

    if (roll < legendaryChance) return EquipmentRarity.legendary;
    if (roll < legendaryChance + epicChance) return EquipmentRarity.epic;
    if (roll < legendaryChance + epicChance + rareChance)
      return EquipmentRarity.rare;
    if (roll < legendaryChance + epicChance + rareChance + uncommonChance) {
      return EquipmentRarity.uncommon;
    }
    return EquipmentRarity.common;
  }

  String _generateEquipmentName(EquipmentSlot slot, EquipmentRarity rarity) {
    final prefixes = {
      EquipmentRarity.common: ['Worn', 'Rusty', 'Tattered'],
      EquipmentRarity.uncommon: ['Sturdy', 'Polished', 'Fine'],
      EquipmentRarity.rare: ['Gleaming', 'Superior', 'Excellent'],
      EquipmentRarity.epic: ['Radiant', 'Mythical', 'Epic'],
      EquipmentRarity.legendary: ['Legendary', 'Ancient', 'Divine'],
    };

    final slotNames = {
      EquipmentSlot.head: 'Helmet',
      EquipmentSlot.shoulders: 'Pauldrons',
      EquipmentSlot.chest: 'Armor',
      EquipmentSlot.gloves: 'Gauntlets',
      EquipmentSlot.pants: 'Greaves',
      EquipmentSlot.feet: 'Boots',
      EquipmentSlot.mainHand: 'Sword',
      EquipmentSlot.offHand: 'Shield',
      EquipmentSlot.knees: 'Knee Pads',
      EquipmentSlot.toes: 'Toe Rings',
      EquipmentSlot.eyes: 'Goggles',
      EquipmentSlot.ears: 'Earrings',
      EquipmentSlot.mouth: 'Mouthguard',
      EquipmentSlot.nose: 'Nose Ring',
    };

    final prefixList = prefixes[rarity]!;
    final prefix = prefixList[_random.nextInt(prefixList.length)];
    final slotName = slotNames[slot]!;

    return '$prefix $slotName';
  }
}

/// Value object representing equipment comparison result
class EquipmentComparison {
  final Equipment better;
  final Equipment worse;
  final int statDifference;
  final bool isUpgrade;

  EquipmentComparison({
    required this.better,
    required this.worse,
    required this.statDifference,
    required this.isUpgrade,
  });

  bool get shouldEquip => isUpgrade && statDifference > 0;
}
