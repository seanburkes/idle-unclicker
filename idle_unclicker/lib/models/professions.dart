import 'package:hive/hive.dart';
import 'dart:math';

part 'professions.g.dart';

/// ProfessionType - The four gathering/crafting professions
@HiveType(typeId: 30)
enum ProfessionType {
  @HiveField(0)
  mining,
  @HiveField(1)
  herbalism,
  @HiveField(2)
  skinning,
  @HiveField(3)
  crafting,
}

/// Extension for ProfessionType display and behavior
extension ProfessionTypeExtension on ProfessionType {
  String get displayName {
    switch (this) {
      case ProfessionType.mining:
        return 'Mining';
      case ProfessionType.herbalism:
        return 'Herbalism';
      case ProfessionType.skinning:
        return 'Skinning';
      case ProfessionType.crafting:
        return 'Crafting';
    }
  }

  String get description {
    switch (this) {
      case ProfessionType.mining:
        return 'Gather ores and minerals from stone creatures';
      case ProfessionType.herbalism:
        return 'Gather herbs and plants from nature creatures';
      case ProfessionType.skinning:
        return 'Gather hides from beast creatures';
      case ProfessionType.crafting:
        return 'Create potions, scrolls, and transmute materials';
    }
  }

  String get icon {
    switch (this) {
      case ProfessionType.mining:
        return '⛏️';
      case ProfessionType.herbalism:
        return '🌿';
      case ProfessionType.skinning:
        return '🐺';
      case ProfessionType.crafting:
        return '⚗️';
    }
  }

  String get color {
    switch (this) {
      case ProfessionType.mining:
        return '#8B4513'; // Brown
      case ProfessionType.herbalism:
        return '#228B22'; // Forest Green
      case ProfessionType.skinning:
        return '#D2691E'; // Chocolate
      case ProfessionType.crafting:
        return '#9932CC'; // Dark Orchid
    }
  }
}

/// MaterialType - All gatherable materials
@HiveType(typeId: 31)
enum MaterialType {
  // Ores (Mining)
  @HiveField(0)
  copperOre,
  @HiveField(1)
  ironOre,
  @HiveField(2)
  goldOre,
  @HiveField(3)
  mithrilOre,
  @HiveField(4)
  adamantiteOre,

  // Herbs (Herbalism)
  @HiveField(5)
  peacebloom,
  @HiveField(6)
  silverleaf,
  @HiveField(7)
  mageroyal,
  @HiveField(8)
  briarthorn,
  @HiveField(9)
  fadeleaf,

  // Hides (Skinning)
  @HiveField(10)
  ruinedLeather,
  @HiveField(11)
  lightLeather,
  @HiveField(12)
  mediumLeather,
  @HiveField(13)
  heavyLeather,
  @HiveField(14)
  ruggedLeather,

  // Astral Materials (Rare - focus mode only)
  @HiveField(15)
  astralOre,
  @HiveField(16)
  astralHerb,
  @HiveField(17)
  astralHide,
}

/// Extension for MaterialType display and properties
extension MaterialTypeExtension on MaterialType {
  String get displayName {
    switch (this) {
      // Ores
      case MaterialType.copperOre:
        return 'Copper Ore';
      case MaterialType.ironOre:
        return 'Iron Ore';
      case MaterialType.goldOre:
        return 'Gold Ore';
      case MaterialType.mithrilOre:
        return 'Mithril Ore';
      case MaterialType.adamantiteOre:
        return 'Adamantite Ore';
      // Herbs
      case MaterialType.peacebloom:
        return 'Peacebloom';
      case MaterialType.silverleaf:
        return 'Silverleaf';
      case MaterialType.mageroyal:
        return 'Mageroyal';
      case MaterialType.briarthorn:
        return 'Briarthorn';
      case MaterialType.fadeleaf:
        return 'Fadeleaf';
      // Hides
      case MaterialType.ruinedLeather:
        return 'Ruined Leather';
      case MaterialType.lightLeather:
        return 'Light Leather';
      case MaterialType.mediumLeather:
        return 'Medium Leather';
      case MaterialType.heavyLeather:
        return 'Heavy Leather';
      case MaterialType.ruggedLeather:
        return 'Rugged Leather';
      // Astral
      case MaterialType.astralOre:
        return 'Astral Ore';
      case MaterialType.astralHerb:
        return 'Astral Herb';
      case MaterialType.astralHide:
        return 'Astral Hide';
    }
  }

  String get description {
    switch (this) {
      // Ores
      case MaterialType.copperOre:
        return 'Common ore used for basic crafting';
      case MaterialType.ironOre:
        return 'Sturdy ore for improved equipment';
      case MaterialType.goldOre:
        return 'Precious ore with magical properties';
      case MaterialType.mithrilOre:
        return 'Lightweight but incredibly strong';
      case MaterialType.adamantiteOre:
        return 'Legendary ore of immense power';
      // Herbs
      case MaterialType.peacebloom:
        return 'Common herb with healing properties';
      case MaterialType.silverleaf:
        return 'Herb that enhances mana restoration';
      case MaterialType.mageroyal:
        return 'Royal herb used in powerful potions';
      case MaterialType.briarthorn:
        return 'Thorny herb with defensive properties';
      case MaterialType.fadeleaf:
        return 'Rare herb used for magical scrolls';
      // Hides
      case MaterialType.ruinedLeather:
        return 'Poor quality leather scraps';
      case MaterialType.lightLeather:
        return 'Soft leather for basic crafting';
      case MaterialType.mediumLeather:
        return 'Standard quality leather';
      case MaterialType.heavyLeather:
        return 'Thick leather for armor';
      case MaterialType.ruggedLeather:
        return 'Toughened leather of exceptional quality';
      // Astral
      case MaterialType.astralOre:
        return 'Cosmic ore that glows with starlight';
      case MaterialType.astralHerb:
        return 'Otherworldly herb with unknown power';
      case MaterialType.astralHide:
        return 'Hide from a creature of the void';
    }
  }

  String get icon {
    switch (this) {
      // Ores
      case MaterialType.copperOre:
        return '🟤';
      case MaterialType.ironOre:
        return '⚫';
      case MaterialType.goldOre:
        return '🟡';
      case MaterialType.mithrilOre:
        return '⚪';
      case MaterialType.adamantiteOre:
        return '🔵';
      // Herbs
      case MaterialType.peacebloom:
        return '🌸';
      case MaterialType.silverleaf:
        return '🌿';
      case MaterialType.mageroyal:
        return '🌺';
      case MaterialType.briarthorn:
        return '🥀';
      case MaterialType.fadeleaf:
        return '🍃';
      // Hides
      case MaterialType.ruinedLeather:
        return '📜';
      case MaterialType.lightLeather:
        return '🟫';
      case MaterialType.mediumLeather:
        return '🟧';
      case MaterialType.heavyLeather:
        return '🟥';
      case MaterialType.ruggedLeather:
        return '🟪';
      // Astral
      case MaterialType.astralOre:
        return '✨';
      case MaterialType.astralHerb:
        return '💫';
      case MaterialType.astralHide:
        return '🌌';
    }
  }

  ProfessionType get associatedProfession {
    switch (this) {
      // Ores
      case MaterialType.copperOre:
      case MaterialType.ironOre:
      case MaterialType.goldOre:
      case MaterialType.mithrilOre:
      case MaterialType.adamantiteOre:
      case MaterialType.astralOre:
        return ProfessionType.mining;
      // Herbs
      case MaterialType.peacebloom:
      case MaterialType.silverleaf:
      case MaterialType.mageroyal:
      case MaterialType.briarthorn:
      case MaterialType.fadeleaf:
      case MaterialType.astralHerb:
        return ProfessionType.herbalism;
      // Hides
      case MaterialType.ruinedLeather:
      case MaterialType.lightLeather:
      case MaterialType.mediumLeather:
      case MaterialType.heavyLeather:
      case MaterialType.ruggedLeather:
      case MaterialType.astralHide:
        return ProfessionType.skinning;
    }
  }

  int get tier {
    switch (this) {
      // Tier 1
      case MaterialType.copperOre:
      case MaterialType.peacebloom:
      case MaterialType.ruinedLeather:
        return 1;
      // Tier 2
      case MaterialType.ironOre:
      case MaterialType.silverleaf:
      case MaterialType.lightLeather:
        return 2;
      // Tier 3
      case MaterialType.goldOre:
      case MaterialType.mageroyal:
      case MaterialType.mediumLeather:
        return 3;
      // Tier 4
      case MaterialType.mithrilOre:
      case MaterialType.briarthorn:
      case MaterialType.heavyLeather:
        return 4;
      // Tier 5
      case MaterialType.adamantiteOre:
      case MaterialType.fadeleaf:
      case MaterialType.ruggedLeather:
        return 5;
      // Astral (special tier)
      case MaterialType.astralOre:
      case MaterialType.astralHerb:
      case MaterialType.astralHide:
        return 6;
    }
  }

  bool get isAstral {
    return this == MaterialType.astralOre ||
        this == MaterialType.astralHerb ||
        this == MaterialType.astralHide;
  }

  /// Get the sell price for this material
  int get sellPrice {
    if (isAstral) return 100 * tier;
    return 10 * tier;
  }
}

/// Material - A gathered crafting material
@HiveType(typeId: 32)
class Material extends HiveObject {
  @HiveField(0)
  MaterialType type;

  @HiveField(1)
  int quantity;

  Material({required this.type, this.quantity = 0});

  String get name => type.displayName;
  String get description => type.description;
  String get icon => type.icon;
  bool get isAstral => type.isAstral;
  int get tier => type.tier;
  int get sellPrice => type.sellPrice * quantity;

  /// Create a copy with modified quantity
  Material copyWith({int? quantity}) {
    return Material(type: type, quantity: quantity ?? this.quantity);
  }

  @override
  String toString() => '${type.displayName} x$quantity';
}

/// CraftedItemType - Types of items that can be crafted
@HiveType(typeId: 33)
enum CraftedItemType {
  @HiveField(0)
  healthPotion,
  @HiveField(1)
  manaPotion,
  @HiveField(2)
  scrollOfEscape,
}

/// Extension for CraftedItemType
extension CraftedItemTypeExtension on CraftedItemType {
  String get displayName {
    switch (this) {
      case CraftedItemType.healthPotion:
        return 'Health Potion';
      case CraftedItemType.manaPotion:
        return 'Mana Potion';
      case CraftedItemType.scrollOfEscape:
        return 'Scroll of Escape';
    }
  }

  String get description {
    switch (this) {
      case CraftedItemType.healthPotion:
        return 'Restores 50% of maximum health';
      case CraftedItemType.manaPotion:
        return 'Restores 50% of maximum mana';
      case CraftedItemType.scrollOfEscape:
        return 'Instantly escape to town';
    }
  }

  String get icon {
    switch (this) {
      case CraftedItemType.healthPotion:
        return '🧪';
      case CraftedItemType.manaPotion:
        return '💙';
      case CraftedItemType.scrollOfEscape:
        return '📜';
    }
  }

  /// Get the required materials for this recipe
  Map<MaterialType, int> get requiredMaterials {
    switch (this) {
      case CraftedItemType.healthPotion:
        return {MaterialType.peacebloom: 3, MaterialType.silverleaf: 1};
      case CraftedItemType.manaPotion:
        return {MaterialType.mageroyal: 2, MaterialType.briarthorn: 1};
      case CraftedItemType.scrollOfEscape:
        return {MaterialType.fadeleaf: 1, MaterialType.lightLeather: 1};
    }
  }
}

/// Profession - A gathering or crafting profession
@HiveType(typeId: 34)
class Profession extends HiveObject {
  @HiveField(0)
  ProfessionType type;

  @HiveField(1)
  int level; // 1-100

  @HiveField(2)
  int experience;

  @HiveField(3)
  int experienceToNextLevel;

  @HiveField(4)
  double gatherRate; // Materials per tick

  @HiveField(5)
  bool isUnlocked;

  Profession({
    required this.type,
    this.level = 1,
    this.experience = 0,
    this.experienceToNextLevel = 100,
    this.gatherRate = 0.1,
    this.isUnlocked = false,
  });

  /// Create a new profession at level 1
  factory Profession.create(ProfessionType type) {
    return Profession(
      type: type,
      level: 1,
      experience: 0,
      experienceToNextLevel: 100,
      gatherRate: 0.1,
      isUnlocked: true,
    );
  }

  String get name => type.displayName;
  String get description => type.description;
  String get icon => type.icon;
  String get color => type.color;

  /// Calculate experience needed for next level
  static int calculateXpForLevel(int level) {
    return (100 * pow(1.1, level - 1)).round();
  }

  /// Add experience and handle level ups
  void addExperience(int amount) {
    if (!isUnlocked) return;

    experience += amount;

    while (experience >= experienceToNextLevel && level < 100) {
      experience -= experienceToNextLevel;
      level++;
      experienceToNextLevel = calculateXpForLevel(level);
      _updateGatherRate();
    }
  }

  /// Update gather rate based on level
  void _updateGatherRate() {
    // Base 0.1 + 0.001 per level
    gatherRate = 0.1 + (level * 0.001);
  }

  /// Get bonus multiplier from profession level
  double getGatherBonus() {
    return 1.0 + (level * 0.01); // 1% per level
  }

  /// Get progress percentage to next level
  double get levelProgress {
    if (level >= 100) return 1.0;
    return experience / experienceToNextLevel;
  }

  /// Unlock this profession
  void unlock() {
    isUnlocked = true;
  }

  @override
  String toString() => '${type.displayName} (Lv.$level)';
}

/// CraftingRecipe - A recipe for crafting items
@HiveType(typeId: 35)
class CraftingRecipe extends HiveObject {
  @HiveField(0)
  CraftedItemType itemType;

  @HiveField(1)
  Map<MaterialType, int> requiredMaterials;

  @HiveField(2)
  int requiredCraftingLevel;

  CraftingRecipe({
    required this.itemType,
    required this.requiredMaterials,
    this.requiredCraftingLevel = 1,
  });

  String get name => itemType.displayName;
  String get description => itemType.description;
  String get icon => itemType.icon;

  /// Check if player can craft this (has materials and level)
  bool canCraft(int craftingLevel, Map<MaterialType, int> inventory) {
    if (craftingLevel < requiredCraftingLevel) return false;

    for (final entry in requiredMaterials.entries) {
      final available = inventory[entry.key] ?? 0;
      if (available < entry.value) return false;
    }

    return true;
  }
}

/// ProfessionState - Tracks all profession progress and inventory
@HiveType(typeId: 36)
class ProfessionState extends HiveObject {
  @HiveField(0)
  List<Profession> professions;

  @HiveField(1)
  Map<MaterialType, int> inventory; // MaterialType -> quantity

  @HiveField(2)
  int totalCraftsCompleted;

  @HiveField(3)
  DateTime lastGatherTick;

  @HiveField(4)
  List<String> recentGatherLog; // Last 10 materials gathered

  @HiveField(5)
  bool autoCraftEnabled;

  @HiveField(6)
  Map<CraftedItemType, int> craftedItemsInventory;

  ProfessionState({
    required this.professions,
    required this.inventory,
    this.totalCraftsCompleted = 0,
    required this.lastGatherTick,
    this.recentGatherLog = const [],
    this.autoCraftEnabled = true,
    this.craftedItemsInventory = const {},
  });

  /// Create initial profession state
  factory ProfessionState.create() {
    final professions = ProfessionType.values.map((type) {
      return Profession.create(type);
    }).toList();

    final inventory = <MaterialType, int>{};
    for (final type in MaterialType.values) {
      inventory[type] = 0;
    }

    final craftedInventory = <CraftedItemType, int>{};
    for (final type in CraftedItemType.values) {
      craftedInventory[type] = 0;
    }

    return ProfessionState(
      professions: professions,
      inventory: inventory,
      lastGatherTick: DateTime.now(),
      recentGatherLog: [],
      craftedItemsInventory: craftedInventory,
    );
  }

  /// Get a profession by type
  Profession? getProfession(ProfessionType type) {
    try {
      return professions.firstWhere((p) => p.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Get material quantity
  int getMaterialQuantity(MaterialType type) {
    return inventory[type] ?? 0;
  }

  /// Add materials to inventory
  void addMaterial(MaterialType type, int amount) {
    final current = inventory[type] ?? 0;
    inventory[type] = current + amount;

    // Add to recent gather log
    final logEntry = '${type.displayName} x$amount';
    recentGatherLog.add(logEntry);
    if (recentGatherLog.length > 10) {
      recentGatherLog.removeAt(0);
    }
  }

  /// Remove materials from inventory
  bool removeMaterial(MaterialType type, int amount) {
    final current = inventory[type] ?? 0;
    if (current < amount) return false;
    inventory[type] = current - amount;
    return true;
  }

  /// Get total materials of a specific profession
  int getTotalMaterialsForProfession(ProfessionType profession) {
    int total = 0;
    for (final entry in inventory.entries) {
      if (entry.key.associatedProfession == profession) {
        total += entry.value;
      }
    }
    return total;
  }

  /// Get astral materials count
  int get astralMaterialCount {
    int count = 0;
    for (final entry in inventory.entries) {
      if (entry.key.isAstral) {
        count += entry.value;
      }
    }
    return count;
  }

  /// Get crafted item quantity
  int getCraftedItemQuantity(CraftedItemType type) {
    return craftedItemsInventory[type] ?? 0;
  }

  /// Add crafted item
  void addCraftedItem(CraftedItemType type, int amount) {
    final current = craftedItemsInventory[type] ?? 0;
    craftedItemsInventory[type] = current + amount;
    totalCraftsCompleted += amount;
  }

  /// Remove crafted item
  bool removeCraftedItem(CraftedItemType type, int amount) {
    final current = craftedItemsInventory[type] ?? 0;
    if (current < amount) return false;
    craftedItemsInventory[type] = current - amount;
    return true;
  }

  /// Get inventory value (sell price)
  int get inventoryValue {
    int total = 0;
    for (final entry in inventory.entries) {
      total += entry.key.sellPrice * entry.value;
    }
    return total;
  }

  /// Get available transmutations (tier 1-4 can be transmuted up)
  List<TransmutationOption> getAvailableTransmutations() {
    final options = <TransmutationOption>[];

    // Mining transmutations
    _addTransmutationOption(
      options,
      MaterialType.copperOre,
      MaterialType.ironOre,
    );
    _addTransmutationOption(
      options,
      MaterialType.ironOre,
      MaterialType.goldOre,
    );
    _addTransmutationOption(
      options,
      MaterialType.goldOre,
      MaterialType.mithrilOre,
    );
    _addTransmutationOption(
      options,
      MaterialType.mithrilOre,
      MaterialType.adamantiteOre,
    );

    // Herbalism transmutations
    _addTransmutationOption(
      options,
      MaterialType.peacebloom,
      MaterialType.silverleaf,
    );
    _addTransmutationOption(
      options,
      MaterialType.silverleaf,
      MaterialType.mageroyal,
    );
    _addTransmutationOption(
      options,
      MaterialType.mageroyal,
      MaterialType.briarthorn,
    );
    _addTransmutationOption(
      options,
      MaterialType.briarthorn,
      MaterialType.fadeleaf,
    );

    // Skinning transmutations
    _addTransmutationOption(
      options,
      MaterialType.ruinedLeather,
      MaterialType.lightLeather,
    );
    _addTransmutationOption(
      options,
      MaterialType.lightLeather,
      MaterialType.mediumLeather,
    );
    _addTransmutationOption(
      options,
      MaterialType.mediumLeather,
      MaterialType.heavyLeather,
    );
    _addTransmutationOption(
      options,
      MaterialType.heavyLeather,
      MaterialType.ruggedLeather,
    );

    return options;
  }

  void _addTransmutationOption(
    List<TransmutationOption> options,
    MaterialType from,
    MaterialType to,
  ) {
    final quantity = inventory[from] ?? 0;
    if (quantity >= 10) {
      options.add(TransmutationOption(from: from, to: to, ratio: 10));
    }
  }

  /// Check if inventory is near capacity (for auto-selling)
  bool get isInventoryNearCapacity {
    int totalItems = 0;
    for (final count in inventory.values) {
      totalItems += count;
    }
    return totalItems >= 900; // Near 1000 limit
  }
}

/// TransmutationOption - A possible material transmutation
class TransmutationOption {
  final MaterialType from;
  final MaterialType to;
  final int ratio; // How many 'from' to get 1 'to'

  TransmutationOption({required this.from, required this.to, this.ratio = 10});

  String get description => '$ratio ${from.displayName} → 1 ${to.displayName}';
}

/// MaterialGatheredEvent - Event data when materials are gathered
class MaterialGatheredEvent {
  final MaterialType material;
  final int amount;
  final bool isAstral;
  final DateTime timestamp;

  MaterialGatheredEvent({
    required this.material,
    required this.amount,
    this.isAstral = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// CraftResult - Result of a crafting attempt
class CraftResult {
  final bool success;
  final CraftedItemType itemType;
  final int amountCrafted;
  final String message;

  CraftResult({
    required this.success,
    required this.itemType,
    this.amountCrafted = 0,
    required this.message,
  });

  factory CraftResult.success(CraftedItemType type, int amount) {
    return CraftResult(
      success: true,
      itemType: type,
      amountCrafted: amount,
      message: 'Crafted ${type.displayName} x$amount',
    );
  }

  factory CraftResult.failure(String reason) {
    return CraftResult(
      success: false,
      itemType: CraftedItemType.healthPotion,
      message: 'Crafting failed: $reason',
    );
  }
}

/// ProfessionBonus - Calculated bonuses from professions
class ProfessionBonus {
  final double gatheringSpeed;
  final double craftEfficiency;
  final double rareMaterialChance;

  ProfessionBonus({
    this.gatheringSpeed = 1.0,
    this.craftEfficiency = 1.0,
    this.rareMaterialChance = 0.0,
  });

  ProfessionBonus combine(ProfessionBonus other) {
    return ProfessionBonus(
      gatheringSpeed: gatheringSpeed * other.gatheringSpeed,
      craftEfficiency: craftEfficiency * other.craftEfficiency,
      rareMaterialChance: rareMaterialChance + other.rareMaterialChance,
    );
  }
}
