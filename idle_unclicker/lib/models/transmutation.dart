import 'package:hive/hive.dart';

part 'transmutation.g.dart';

/// ItemTier - The rarity tiers for transmutable items
@HiveType(typeId: 40)
enum ItemTier {
  @HiveField(0)
  common, // Tier 1 - Grey
  @HiveField(1)
  uncommon, // Tier 2 - Green
  @HiveField(2)
  rare, // Tier 3 - Blue
  @HiveField(3)
  epic, // Tier 4 - Purple
  @HiveField(4)
  legendary, // Tier 5 - Gold
}

/// Extension for ItemTier display and properties
extension ItemTierExtension on ItemTier {
  String get displayName {
    switch (this) {
      case ItemTier.common:
        return 'Common';
      case ItemTier.uncommon:
        return 'Uncommon';
      case ItemTier.rare:
        return 'Rare';
      case ItemTier.epic:
        return 'Epic';
      case ItemTier.legendary:
        return 'Legendary';
    }
  }

  String get color {
    switch (this) {
      case ItemTier.common:
        return '#AAAAAA';
      case ItemTier.uncommon:
        return '#00FF00';
      case ItemTier.rare:
        return '#0088FF';
      case ItemTier.epic:
        return '#AA00FF';
      case ItemTier.legendary:
        return '#FFAA00';
    }
  }

  String get icon {
    switch (this) {
      case ItemTier.common:
        return '⚪';
      case ItemTier.uncommon:
        return '🟢';
      case ItemTier.rare:
        return '🔵';
      case ItemTier.epic:
        return '🟣';
      case ItemTier.legendary:
        return '🟡';
    }
  }

  /// Get the next tier up (null if already legendary)
  ItemTier? get nextTier {
    switch (this) {
      case ItemTier.common:
        return ItemTier.uncommon;
      case ItemTier.uncommon:
        return ItemTier.rare;
      case ItemTier.rare:
        return ItemTier.epic;
      case ItemTier.epic:
        return ItemTier.legendary;
      case ItemTier.legendary:
        return null;
    }
  }

  /// Get the tier number (1-5)
  int get tierNumber {
    switch (this) {
      case ItemTier.common:
        return 1;
      case ItemTier.uncommon:
        return 2;
      case ItemTier.rare:
        return 3;
      case ItemTier.epic:
        return 4;
      case ItemTier.legendary:
        return 5;
    }
  }

  /// Check if this tier can be transmuted up
  bool get canTransmuteUp => this != ItemTier.legendary;

  /// Get base miracle chance (only for epic->legendary)
  double get baseMiracleChance {
    if (this == ItemTier.epic) return 0.01; // 1% base chance
    return 0.0;
  }
}

/// TransmutableItemType - Types of items that can be transmuted
@HiveType(typeId: 41)
enum TransmutableItemType {
  @HiveField(0)
  equipment, // Weapons, armor from equipment system
  @HiveField(1)
  gems, // Gems from enchanting system
  @HiveField(2)
  materials, // Materials from professions system
}

/// Extension for TransmutableItemType
extension TransmutableItemTypeExtension on TransmutableItemType {
  String get displayName {
    switch (this) {
      case TransmutableItemType.equipment:
        return 'Equipment';
      case TransmutableItemType.gems:
        return 'Gems';
      case TransmutableItemType.materials:
        return 'Materials';
    }
  }

  String get icon {
    switch (this) {
      case TransmutableItemType.equipment:
        return '⚔️';
      case TransmutableItemType.gems:
        return '💎';
      case TransmutableItemType.materials:
        return '📦';
    }
  }
}

/// VolatileResult - Result of volatile transmutation attempt
@HiveType(typeId: 42)
enum VolatileResult {
  @HiveField(0)
  successPlusOneTier, // 50% chance: item becomes +1 tier
  @HiveField(1)
  failureNothing, // 50% chance: complete loss
}

/// Extension for VolatileResult
extension VolatileResultExtension on VolatileResult {
  String get displayName {
    switch (this) {
      case VolatileResult.successPlusOneTier:
        return 'Volatile Success';
      case VolatileResult.failureNothing:
        return 'Volatile Failure';
    }
  }

  String get description {
    switch (this) {
      case VolatileResult.successPlusOneTier:
        return 'Item upgraded by 2 tiers!';
      case VolatileResult.failureNothing:
        return 'Item destroyed completely!';
    }
  }
}

/// TransmutationRecipe - Recipe for transmuting items between tiers
@HiveType(typeId: 43)
class TransmutationRecipe extends HiveObject {
  @HiveField(0)
  TransmutableItemType itemType;

  @HiveField(1)
  ItemTier fromTier;

  @HiveField(2)
  ItemTier toTier;

  @HiveField(3)
  int inputQuantity; // Always 10 for standard transmutation

  @HiveField(4)
  int outputQuantity; // Always 1

  @HiveField(5)
  double miracleChance; // 1% for epic->legendary, 0% otherwise

  @HiveField(6)
  bool isVolatile; // High-risk mode

  @HiveField(7)
  int goldCost; // Optional gold cost

  TransmutationRecipe({
    required this.itemType,
    required this.fromTier,
    required this.toTier,
    this.inputQuantity = 10,
    this.outputQuantity = 1,
    this.miracleChance = 0.0,
    this.isVolatile = false,
    this.goldCost = 0,
  });

  /// Get display name for this recipe
  String get displayName => '${fromTier.displayName} → ${toTier.displayName}';

  /// Get description
  String get description {
    if (isVolatile) {
      return '50% chance of +2 tiers, 50% destruction';
    }
    if (miracleChance > 0) {
      return '$inputQuantity ${fromTier.displayName} → $outputQuantity ${toTier.displayName} (${(miracleChance * 100).toStringAsFixed(0)}% miracle)';
    }
    return '$inputQuantity ${fromTier.displayName} → $outputQuantity ${toTier.displayName}';
  }

  /// Create a standard 10:1 transmutation recipe
  factory TransmutationRecipe.standard({
    required TransmutableItemType itemType,
    required ItemTier fromTier,
    required ItemTier toTier,
    int goldCost = 0,
  }) {
    return TransmutationRecipe(
      itemType: itemType,
      fromTier: fromTier,
      toTier: toTier,
      inputQuantity: 10,
      outputQuantity: 1,
      miracleChance: fromTier.baseMiracleChance,
      isVolatile: false,
      goldCost: goldCost,
    );
  }

  /// Create a volatile transmutation recipe
  factory TransmutationRecipe.volatile({
    required TransmutableItemType itemType,
    required ItemTier fromTier,
  }) {
    final toTier = fromTier.nextTier ?? fromTier;
    return TransmutationRecipe(
      itemType: itemType,
      fromTier: fromTier,
      toTier: toTier,
      inputQuantity: 10,
      outputQuantity: 1,
      miracleChance: 0.0,
      isVolatile: true,
      goldCost: 100, // Volatile costs extra
    );
  }
}

/// TransmutationResult - Result of a transmutation attempt
@HiveType(typeId: 44)
class TransmutationResult extends HiveObject {
  @HiveField(0)
  bool success;

  @HiveField(1)
  ItemTier resultTier;

  @HiveField(2)
  int quantityProduced;

  @HiveField(3)
  bool wasMiracle;

  @HiveField(4)
  VolatileResult? volatileOutcome;

  @HiveField(5)
  String message;

  @HiveField(6)
  DateTime timestamp;

  TransmutationResult({
    required this.success,
    required this.resultTier,
    this.quantityProduced = 0,
    this.wasMiracle = false,
    this.volatileOutcome,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TransmutationResult.success({
    required ItemTier resultTier,
    required int quantity,
    bool wasMiracle = false,
  }) {
    final message = wasMiracle
        ? '★ MIRACLE! Item transmuted to ${resultTier.displayName} with bonus stats! ★'
        : 'Successfully transmuted to ${resultTier.displayName}';

    return TransmutationResult(
      success: true,
      resultTier: resultTier,
      quantityProduced: quantity,
      wasMiracle: wasMiracle,
      message: message,
    );
  }

  factory TransmutationResult.failure({
    required String reason,
    bool wasVolatile = false,
  }) {
    return TransmutationResult(
      success: false,
      resultTier: ItemTier.common,
      quantityProduced: 0,
      message: wasVolatile
          ? 'Volatile transmutation failed! Item destroyed!'
          : 'Transmutation failed: $reason',
    );
  }
}

/// TransmutationHistory - Record of past transmutation attempts
@HiveType(typeId: 45)
class TransmutationHistory extends HiveObject {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  TransmutationRecipe recipe;

  @HiveField(2)
  TransmutationResult result;

  @HiveField(3)
  int totalAttempts;

  @HiveField(4)
  int miracleCount;

  TransmutationHistory({
    required this.timestamp,
    required this.recipe,
    required this.result,
    this.totalAttempts = 1,
    this.miracleCount = 0,
  });
}

/// TransmutationState - Main state class for transmutation system
@HiveType(typeId: 46)
class TransmutationState extends HiveObject {
  @HiveField(0)
  List<TransmutationRecipe> availableRecipes;

  @HiveField(1)
  List<TransmutationHistory> history;

  @HiveField(2)
  Map<ItemTier, int> transmuteCounts; // Track how many of each tier created

  @HiveField(3)
  bool autoTransmuteEnabled;

  @HiveField(4)
  ItemTier autoTransmuteThreshold; // Don't auto-transmute above this tier

  @HiveField(5)
  int inventoryFullThreshold; // Auto-transmute when inventory > X items

  @HiveField(6)
  int totalTransmutations;

  @HiveField(7)
  int totalMiracles;

  @HiveField(8)
  int volatileAttempts;

  @HiveField(9)
  int volatileSuccesses;

  @HiveField(10)
  DateTime lastTransmuteTick;

  TransmutationState({
    required this.availableRecipes,
    required this.history,
    required this.transmuteCounts,
    this.autoTransmuteEnabled = true,
    this.autoTransmuteThreshold = ItemTier.epic, // Don't auto-transmute epics
    this.inventoryFullThreshold = 80, // 80% full triggers auto-transmute
    this.totalTransmutations = 0,
    this.totalMiracles = 0,
    this.volatileAttempts = 0,
    this.volatileSuccesses = 0,
    required this.lastTransmuteTick,
  });

  /// Create initial transmutation state
  factory TransmutationState.create() {
    return TransmutationState(
      availableRecipes: [],
      history: [],
      transmuteCounts: {
        ItemTier.common: 0,
        ItemTier.uncommon: 0,
        ItemTier.rare: 0,
        ItemTier.epic: 0,
        ItemTier.legendary: 0,
      },
      lastTransmuteTick: DateTime.now(),
    );
  }

  /// Record a successful transmutation
  void recordTransmutation(
    TransmutationRecipe recipe,
    TransmutationResult result,
  ) {
    totalTransmutations++;

    if (result.wasMiracle) {
      totalMiracles++;
    }

    if (recipe.isVolatile) {
      volatileAttempts++;
      if (result.success) {
        volatileSuccesses++;
      }
    }

    // Update counts
    if (result.success) {
      transmuteCounts[result.resultTier] =
          (transmuteCounts[result.resultTier] ?? 0) + result.quantityProduced;
    }

    // Add to history
    history.add(
      TransmutationHistory(
        timestamp: DateTime.now(),
        recipe: recipe,
        result: result,
      ),
    );

    // Keep history manageable (last 100)
    if (history.length > 100) {
      history.removeAt(0);
    }

    lastTransmuteTick = DateTime.now();
    save();
  }

  /// Get miracle rate as percentage
  double get miracleRate {
    if (totalTransmutations == 0) return 0.0;
    return totalMiracles / totalTransmutations;
  }

  /// Get volatile success rate
  double get volatileSuccessRate {
    if (volatileAttempts == 0) return 0.0;
    return volatileSuccesses / volatileAttempts;
  }

  /// Get count of specific tier created
  int getTierCount(ItemTier tier) => transmuteCounts[tier] ?? 0;

  /// Get total legendary items created
  int get legendaryCount => transmuteCounts[ItemTier.legendary] ?? 0;

  /// Get recent history (last 10)
  List<TransmutationHistory> get recentHistory {
    return history.reversed.take(10).toList();
  }

  /// Toggle auto-transmute
  void toggleAutoTransmute() {
    autoTransmuteEnabled = !autoTransmuteEnabled;
    save();
  }

  /// Set auto-transmute threshold
  void setThreshold(ItemTier threshold) {
    autoTransmuteThreshold = threshold;
    save();
  }

  /// Get statistics summary
  Map<String, dynamic> getStats() {
    return {
      'totalTransmutations': totalTransmutations,
      'totalMiracles': totalMiracles,
      'miracleRate': miracleRate,
      'volatileAttempts': volatileAttempts,
      'volatileSuccesses': volatileSuccesses,
      'volatileSuccessRate': volatileSuccessRate,
      'legendaryCount': legendaryCount,
      'commonCreated': getTierCount(ItemTier.common),
      'uncommonCreated': getTierCount(ItemTier.uncommon),
      'rareCreated': getTierCount(ItemTier.rare),
      'epicCreated': getTierCount(ItemTier.epic),
    };
  }
}

/// Helper class for tracking transmutable items in inventory
class TransmutableItem {
  final TransmutableItemType type;
  final ItemTier tier;
  final String name;
  final String? sourceId; // Equipment ID, MaterialType, or Gem reference
  final bool isEquipped;

  TransmutableItem({
    required this.type,
    required this.tier,
    required this.name,
    this.sourceId,
    this.isEquipped = false,
  });

  /// Check if this item can be transmuted
  bool get canTransmute => tier.canTransmuteUp && !isEquipped;

  /// Get display string
  String get display => '${tier.icon} $name (${tier.displayName})';
}
