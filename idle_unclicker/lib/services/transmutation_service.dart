import 'dart:math';
import '../models/transmutation.dart';
import '../models/equipment.dart';
import '../models/professions.dart';
import '../models/enchanting.dart';
import '../models/alchemy.dart';

/// Service for managing transmutation of items between rarity tiers
class TransmutationService {
  final Random _random = Random();
  TransmutationState _state;
  AlchemyState? _alchemyState;

  TransmutationService(this._state, {AlchemyState? alchemyState})
    : _alchemyState = alchemyState;

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize all standard transmutation recipes
  void initializeRecipes() {
    final recipes = <TransmutationRecipe>[];

    // Create recipes for each item type
    for (final itemType in TransmutableItemType.values) {
      // Common → Uncommon
      recipes.add(
        TransmutationRecipe.standard(
          itemType: itemType,
          fromTier: ItemTier.common,
          toTier: ItemTier.uncommon,
        ),
      );

      // Uncommon → Rare
      recipes.add(
        TransmutationRecipe.standard(
          itemType: itemType,
          fromTier: ItemTier.uncommon,
          toTier: ItemTier.rare,
        ),
      );

      // Rare → Epic
      recipes.add(
        TransmutationRecipe.standard(
          itemType: itemType,
          fromTier: ItemTier.rare,
          toTier: ItemTier.epic,
        ),
      );

      // Epic → Legendary (with miracle chance)
      recipes.add(
        TransmutationRecipe.standard(
          itemType: itemType,
          fromTier: ItemTier.epic,
          toTier: ItemTier.legendary,
          goldCost: 100, // Legendary costs extra
        ),
      );

      // Volatile recipes for each tier
      for (final tier in [
        ItemTier.common,
        ItemTier.uncommon,
        ItemTier.rare,
        ItemTier.epic,
      ]) {
        recipes.add(
          TransmutationRecipe.volatile(itemType: itemType, fromTier: tier),
        );
      }
    }

    _state.availableRecipes = recipes;
    _state.save();
  }

  // ============================================================================
  // Transmutation Execution
  // ============================================================================

  /// Execute a transmutation
  /// Returns the result of the transmutation
  TransmutationResult transmute(
    TransmutationRecipe recipe,
    List<TransmutableItem> items, {
    bool useVolatile = false,
  }) {
    // Validate items
    if (items.length < recipe.inputQuantity) {
      return TransmutationResult.failure(
        reason: 'Not enough items (${items.length}/${recipe.inputQuantity})',
      );
    }

    // Check all items are the correct tier
    for (final item in items) {
      if (item.tier != recipe.fromTier) {
        return TransmutationResult.failure(
          reason:
              'Item ${item.name} is not ${recipe.fromTier.displayName} tier',
        );
      }
      if (item.isEquipped) {
        return TransmutationResult.failure(
          reason: 'Cannot transmute equipped item: ${item.name}',
        );
      }
    }

    // Calculate miracle chance with bonuses
    final miracleChance = calculateMiracleChance(recipe);

    // Execute transmutation
    if (recipe.isVolatile || useVolatile) {
      return _executeVolatileTransmute(recipe);
    }

    // Standard transmutation
    return _executeStandardTransmute(recipe, miracleChance);
  }

  /// Execute standard transmutation
  TransmutationResult _executeStandardTransmute(
    TransmutationRecipe recipe,
    double miracleChance,
  ) {
    // Check for miracle (epic → legendary only)
    final isMiracle =
        recipe.fromTier == ItemTier.epic &&
        _random.nextDouble() < miracleChance;

    if (isMiracle) {
      final result = TransmutationResult.success(
        resultTier: ItemTier.legendary,
        quantity: recipe.outputQuantity,
        wasMiracle: true,
      );
      _state.recordTransmutation(recipe, result);
      return result;
    }

    // Normal success
    final result = TransmutationResult.success(
      resultTier: recipe.toTier,
      quantity: recipe.outputQuantity,
    );
    _state.recordTransmutation(recipe, result);
    return result;
  }

  /// Execute volatile transmutation (50/50 chance)
  TransmutationResult _executeVolatileTransmute(TransmutationRecipe recipe) {
    _state.volatileAttempts++;

    // 50% chance of success
    final success = _random.nextBool();

    if (success) {
      // Success: +1 tier bonus
      final bonusTier = recipe.toTier.nextTier ?? recipe.toTier;
      _state.volatileSuccesses++;

      final result = TransmutationResult(
        success: true,
        resultTier: bonusTier,
        quantityProduced: recipe.outputQuantity,
        volatileOutcome: VolatileResult.successPlusOneTier,
        message: 'Volatile success! Item upgraded to ${bonusTier.displayName}!',
      );
      _state.recordTransmutation(recipe, result);
      return result;
    } else {
      // Failure: complete loss
      final result = TransmutationResult.failure(
        reason: 'Item destroyed in volatile transmutation',
        wasVolatile: true,
      );
      _state.recordTransmutation(recipe, result);
      return result;
    }
  }

  // ============================================================================
  // Validation & Requirements
  // ============================================================================

  /// Check if transmutation can be performed
  bool canTransmute(
    TransmutationRecipe recipe,
    List<TransmutableItem> inventory, {
    int availableGold = 0,
  }) {
    // Check gold cost
    if (availableGold < recipe.goldCost) return false;

    // Check item count
    final eligibleItems = inventory
        .where(
          (item) =>
              item.tier == recipe.fromTier &&
              item.type == recipe.itemType &&
              !item.isEquipped,
        )
        .toList();

    return eligibleItems.length >= recipe.inputQuantity;
  }

  /// Calculate miracle chance for a recipe
  /// Base 1% for epic → legendary, can be boosted by alchemy
  double calculateMiracleChance(TransmutationRecipe recipe) {
    if (recipe.fromTier != ItemTier.epic) return 0.0;

    double baseChance = 0.01; // 1% base

    // Add alchemy boost if available
    if (_alchemyState != null) {
      baseChance += _alchemyState!.transmutationBoost;
    }

    return baseChance.clamp(0.0, 0.10); // Max 10% with boosts
  }

  /// Execute volatile transmutation directly
  /// Returns the outcome (success with +1 tier or complete loss)
  VolatileResult executeVolatileTransmute() {
    return _random.nextBool()
        ? VolatileResult.successPlusOneTier
        : VolatileResult.failureNothing;
  }

  // ============================================================================
  // Automation
  // ============================================================================

  /// Determine if auto-transmutation should run
  /// Returns true if inventory conditions warrant auto-transmute
  bool shouldAutoTransmute({
    required int totalInventoryItems,
    required int maxInventorySize,
    required Map<ItemTier, int> itemsByTier,
    required bool isInTown,
  }) {
    if (!_state.autoTransmuteEnabled) return false;
    if (!isInTown) return false; // Only auto-transmute in town

    // Check if inventory is above threshold
    final threshold = (maxInventorySize * _state.inventoryFullThreshold / 100)
        .round();
    if (totalInventoryItems < threshold) return false;

    // Check if we have enough items to transmute
    bool hasTransmutableItems = false;
    for (final entry in itemsByTier.entries) {
      final tier = entry.key;
      final count = entry.value;

      // Don't auto-transmute above threshold
      if (tier.tierNumber > _state.autoTransmuteThreshold.tierNumber) {
        continue;
      }

      // Check if we have 10+ of this tier
      if (count >= 10) {
        hasTransmutableItems = true;
        break;
      }
    }

    return hasTransmutableItems;
  }

  /// Execute automatic transmutation
  /// Transmutes excess items below the threshold tier
  /// Returns list of actions taken for logging
  List<String> executeAutoTransmute({
    required Map<ItemTier, List<TransmutableItem>> itemsByTier,
    required Function(ItemTier, int) onItemsConsumed,
    required Function(ItemTier, int) onItemsProduced,
  }) {
    final actions = <String>[];

    // Process from lowest tier up
    final tiersToProcess = [
      ItemTier.common,
      ItemTier.uncommon,
      ItemTier.rare,
    ].where((t) => t.tierNumber <= _state.autoTransmuteThreshold.tierNumber);

    for (final fromTier in tiersToProcess) {
      final items = itemsByTier[fromTier] ?? [];
      final eligibleItems = items.where((i) => !i.isEquipped).toList();

      if (eligibleItems.length < 10) continue;

      // Calculate how many transmutations we can do
      final transmuteCount = eligibleItems.length ~/ 10;

      // Find the recipe
      final toTier = fromTier.nextTier;
      if (toTier == null) continue;

      final recipe = _findRecipe(
        itemType: TransmutableItemType.equipment, // Default to equipment
        fromTier: fromTier,
        toTier: toTier,
      );

      if (recipe == null) continue;

      // Execute transmutations
      for (int i = 0; i < transmuteCount; i++) {
        final itemsToTransmute = eligibleItems.skip(i * 10).take(10).toList();

        final result = transmute(recipe, itemsToTransmute);

        if (result.success) {
          // Consume input items
          onItemsConsumed(fromTier, 10);

          // Produce output items
          onItemsProduced(result.resultTier, result.quantityProduced);

          if (result.wasMiracle) {
            actions.add(
              'AUTO: ★ MIRACLE! ${fromTier.displayName} → ${result.resultTier.displayName} with bonus stats! ★',
            );
          } else {
            actions.add(
              'AUTO: Transmuted 10 ${fromTier.displayName} → ${result.quantityProduced} ${result.resultTier.displayName}',
            );
          }
        }
      }
    }

    return actions;
  }

  /// Attempt a miracle on any item
  /// 1% base chance to upgrade one tier
  TransmutationResult? attemptMiracle(TransmutableItem item) {
    final chance = item.tier.baseMiracleChance;
    if (chance <= 0) return null;

    if (_random.nextDouble() < chance) {
      final nextTier = item.tier.nextTier;
      if (nextTier != null) {
        return TransmutationResult.success(
          resultTier: nextTier,
          quantity: 1,
          wasMiracle: true,
        );
      }
    }
    return null;
  }

  // ============================================================================
  // Recipe Management
  // ============================================================================

  /// Find a recipe by criteria
  TransmutationRecipe? _findRecipe({
    required TransmutableItemType itemType,
    required ItemTier fromTier,
    required ItemTier toTier,
  }) {
    try {
      return _state.availableRecipes.firstWhere(
        (r) =>
            r.itemType == itemType &&
            r.fromTier == fromTier &&
            r.toTier == toTier &&
            !r.isVolatile,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all available recipes for an item type
  List<TransmutationRecipe> getRecipesForType(TransmutableItemType itemType) {
    return _state.availableRecipes
        .where((r) => r.itemType == itemType && !r.isVolatile)
        .toList();
  }

  /// Get volatile recipes for an item type
  List<TransmutationRecipe> getVolatileRecipes(TransmutableItemType itemType) {
    return _state.availableRecipes
        .where((r) => r.itemType == itemType && r.isVolatile)
        .toList();
  }

  // ============================================================================
  // Statistics & State
  // ============================================================================

  /// Get transmutation statistics
  Map<String, dynamic> getTransmutationStats() {
    return _state.getStats();
  }

  /// Get recent transmutation history
  List<TransmutationHistory> getRecentHistory() {
    return _state.recentHistory;
  }

  /// Get total transmutations performed
  int get totalTransmutations => _state.totalTransmutations;

  /// Get total miracles witnessed
  int get totalMiracles => _state.totalMiracles;

  /// Get legendary items created
  int get legendaryCount => _state.legendaryCount;

  /// Toggle auto-transmute
  void toggleAutoTransmute() {
    _state.toggleAutoTransmute();
  }

  /// Set auto-transmute threshold
  void setAutoTransmuteThreshold(ItemTier threshold) {
    _state.setThreshold(threshold);
  }

  /// Get current state
  TransmutationState get state => _state;

  /// Update state reference
  void updateState(TransmutationState newState) {
    _state = newState;
  }

  /// Update alchemy state reference
  void updateAlchemyState(AlchemyState alchemyState) {
    _alchemyState = alchemyState;
  }

  // ============================================================================
  // Inventory Helpers
  // ============================================================================

  /// Create transmutable items from equipment list
  List<TransmutableItem> createTransmutableEquipment(
    List<Equipment> equipment, {
    Set<String> equippedIds = const {},
  }) {
    return equipment.map((e) {
      // Map equipment rarity (1-5) to ItemTier
      final tier = _equipmentRarityToTier(e.rarity);

      return TransmutableItem(
        type: TransmutableItemType.equipment,
        tier: tier,
        name: e.name,
        sourceId: e.key?.toString(),
        isEquipped: equippedIds.contains(e.key?.toString()),
      );
    }).toList();
  }

  /// Convert equipment rarity to ItemTier
  ItemTier _equipmentRarityToTier(int rarity) {
    switch (rarity.clamp(1, 5)) {
      case 1:
        return ItemTier.common;
      case 2:
        return ItemTier.uncommon;
      case 3:
        return ItemTier.rare;
      case 4:
        return ItemTier.epic;
      case 5:
        return ItemTier.legendary;
      default:
        return ItemTier.common;
    }
  }

  /// Create transmutable items from materials
  List<TransmutableItem> createTransmutableMaterials(
    Map<MaterialType, int> materials,
  ) {
    final items = <TransmutableItem>[];

    for (final entry in materials.entries) {
      // Map material tier to ItemTier (1-6 to 1-5)
      final tier = _materialTierToItemTier(entry.key.tier);

      // Add one item per quantity
      for (int i = 0; i < entry.value; i++) {
        items.add(
          TransmutableItem(
            type: TransmutableItemType.materials,
            tier: tier,
            name: entry.key.displayName,
            sourceId: entry.key.toString(),
            isEquipped: false,
          ),
        );
      }
    }

    return items;
  }

  /// Convert material tier to ItemTier
  ItemTier _materialTierToItemTier(int materialTier) {
    switch (materialTier.clamp(1, 6)) {
      case 1:
        return ItemTier.common;
      case 2:
        return ItemTier.uncommon;
      case 3:
        return ItemTier.rare;
      case 4:
        return ItemTier.epic;
      case 5:
      case 6:
        return ItemTier.legendary;
      default:
        return ItemTier.common;
    }
  }

  /// Create transmutable items from gems
  List<TransmutableItem> createTransmutableGems(List<Gem> gems) {
    return gems.map((g) {
      final tier = _gemTierToItemTier(g.tier);

      return TransmutableItem(
        type: TransmutableItemType.gems,
        tier: tier,
        name: g.name,
        sourceId: g.key?.toString(),
        isEquipped: false,
      );
    }).toList();
  }

  /// Convert gem tier to ItemTier
  ItemTier _gemTierToItemTier(GemTier gemTier) {
    switch (gemTier) {
      case GemTier.cracked:
        return ItemTier.common;
      case GemTier.flawed:
        return ItemTier.uncommon;
      case GemTier.regular:
        return ItemTier.rare;
      case GemTier.flawless:
        return ItemTier.epic;
      case GemTier.perfect:
        return ItemTier.legendary;
    }
  }
}
