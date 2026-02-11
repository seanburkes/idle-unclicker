import 'dart:math';
import '../models/alchemy.dart';
import '../models/professions.dart';
import '../models/character.dart';

/// Service for managing alchemy and potion brewing
class AlchemyService {
  final Random _random = Random();
  AlchemyState _state;
  ProfessionState? _professionState;

  AlchemyService(this._state, {ProfessionState? professionState})
    : _professionState = professionState;

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize all alchemy recipes
  void initializeRecipes() {
    // Recipes are already created in AlchemyState.create()
    // This method ensures they're loaded
    if (_state.availableRecipes.isEmpty) {
      _state.availableRecipes = AlchemyRecipe.createAllRecipes();
      _state.save();
    }
  }

  // ============================================================================
  // Brewing
  // ============================================================================

  /// Start brewing a potion
  /// Returns true if successfully started
  bool brew(AlchemyRecipe recipe, {bool autoBrew = false}) {
    // Check requirements
    if (!canBrew(recipe)) {
      return false;
    }

    // Find available slot
    final availableSlot = _state.availableSlots.firstOrNull;
    if (availableSlot == null) {
      return false;
    }

    // Consume materials
    if (_professionState != null) {
      for (final entry in recipe.requiredMaterials.entries) {
        _professionState!.removeMaterial(entry.key, entry.value);
      }
      _professionState!.save();
    }

    // Start brewing
    availableSlot.startBrewing(recipe, autoBrew: autoBrew);
    _state.save();

    return true;
  }

  /// Check if a recipe can be brewed
  bool canBrew(AlchemyRecipe recipe) {
    // Check if we have an available slot
    if (_state.availableSlots.isEmpty) return false;

    // Check gold cost
    // Note: Gold check should be done externally via Character

    // Check materials
    if (_professionState != null) {
      for (final entry in recipe.requiredMaterials.entries) {
        final available = _professionState!.inventory[entry.key] ?? 0;
        if (available < entry.value) return false;
      }
    }

    // Check alchemy level
    if (_state.alchemyLevel < recipe.requiredAlchemyLevel) return false;

    return true;
  }

  /// Collect a completed brew from a slot
  /// Returns the potion type if successful, null if not complete
  PotionType? collectBrew(BrewingSlot slot) {
    if (!slot.isComplete) return null;

    final potionType = slot.collect();
    if (potionType != null) {
      _state.addPotion(potionType, slot.recipe?.outputQuantity ?? 1);
      _state.addExperience(20); // XP for successful brew
      return potionType;
    }

    return null;
  }

  /// Collect all completed brews
  List<PotionType> collectAllCompleted() {
    return _state.collectCompleted();
  }

  /// Update brewing progress for all slots
  void updateBrewingProgress() {
    _state.updateBrewingProgress();
  }

  // ============================================================================
  // Potion Effects
  // ============================================================================

  /// Get all active potion effects
  List<PotionEffect> getActiveEffects() {
    _state.updateEffects(); // Clean up expired
    return _state.activeEffects.where((e) => e.isActive).toList();
  }

  /// Apply a potion effect to the character
  /// Returns true if successfully applied
  bool applyPotionEffect(PotionType type) {
    return _state.usePotion(type);
  }

  /// Get effect multiplier for a specific effect type
  double getEffectMultiplier(String effectType) {
    double multiplier = 1.0;

    for (final effect in _state.activeEffects) {
      if (!effect.isActive || effect.hasExpired) continue;

      switch (effectType) {
        case 'goldFind':
          if (effect.type == PotionType.luck) {
            multiplier += effect.magnitude;
          }
          break;
        case 'xpGain':
          if (effect.type == PotionType.wisdom) {
            multiplier += effect.magnitude;
          }
          break;
        case 'attackSpeed':
          if (effect.type == PotionType.haste) {
            multiplier += effect.magnitude;
          }
          break;
        case 'strength':
          if (effect.type == PotionType.strength) {
            multiplier += effect.magnitude;
          }
          break;
        case 'dexterity':
          if (effect.type == PotionType.agility) {
            multiplier += effect.magnitude;
          }
          break;
        case 'intelligence':
          if (effect.type == PotionType.intellect) {
            multiplier += effect.magnitude;
          }
          break;
        case 'defense':
          if (effect.type == PotionType.protection) {
            multiplier += effect.magnitude;
          }
          break;
      }
    }

    return multiplier;
  }

  /// Get transmutation boost percentage
  /// Returns 0.0-1.0 representing boost to miracle chance
  double extendMiracleChance() {
    return _state.transmutationBoost;
  }

  // ============================================================================
  // Automation
  // ============================================================================

  /// Determine if auto-brewing should run
  /// Returns true if potions are needed
  bool shouldAutoBrew({
    required int currentHealth,
    required int maxHealth,
    required bool isInCombat,
    required bool isBeforeBoss,
    required bool isInTown,
  }) {
    if (!_state.autoBrewEnabled) return false;
    if (!isInTown) return false; // Only brew in town

    // Keep 1 slot free for emergency brewing
    if (_state.availableSlots.length <= 1) return false;

    // Check if we need health potions
    final healthPercent = currentHealth / maxHealth;
    final healingPotions = _state.healingPotionCount;

    if (healthPercent < 0.5 && healingPotions < 3) {
      return true;
    }

    // Check if preparing for boss fight
    if (isBeforeBoss) {
      // Ensure we have buff potions for boss
      final buffPotions = _state.inventory.entries
          .where((e) => e.key.isBuff)
          .fold(0, (sum, e) => sum + e.value);

      if (buffPotions < 2) {
        return true;
      }
    }

    // Check if we're critically low on any potion type
    if (healingPotions < 2) {
      return true;
    }

    return false;
  }

  /// Execute automatic brewing
  /// Returns list of actions taken for logging
  List<String> executeAutoBrew({
    required Character character,
    required bool isBeforeBoss,
  }) {
    final actions = <String>[];

    // Priority 1: Health potions if low
    final healthPercent = character.currentHealth / character.maxHealth;
    final healingPotions = _state.healingPotionCount;

    if (healthPercent < 0.5 && healingPotions < 3) {
      // Brew strongest health potion we can
      final recipe = _findBestHealthRecipe();
      if (recipe != null && canBrew(recipe)) {
        if (brew(recipe, autoBrew: true)) {
          actions.add(
            'AUTO: Brewing ${recipe.displayName} (Low health detected)',
          );
        }
      }
    }

    // Priority 2: Buff potions before boss
    if (isBeforeBoss) {
      // Brew strength potion if available
      final strengthRecipe = _findRecipe(PotionType.strength);
      if (strengthRecipe != null &&
          _state.getPotionCount(PotionType.strength) < 2 &&
          canBrew(strengthRecipe)) {
        if (brew(strengthRecipe, autoBrew: true)) {
          actions.add(
            'AUTO: Brewing ${strengthRecipe.displayName} (Boss preparation)',
          );
        }
      }

      // Brew protection potion
      final protectionRecipe = _findRecipe(PotionType.protection);
      if (protectionRecipe != null &&
          _state.getPotionCount(PotionType.protection) < 2 &&
          canBrew(protectionRecipe)) {
        if (brew(protectionRecipe, autoBrew: true)) {
          actions.add(
            'AUTO: Brewing ${protectionRecipe.displayName} (Boss preparation)',
          );
        }
      }
    }

    // Priority 3: Transmutation boost if we have materials
    final transmuteRecipe = _findRecipe(PotionType.transmutationBoost);
    if (transmuteRecipe != null &&
        _state.getPotionCount(PotionType.transmutationBoost) < 1 &&
        canBrew(transmuteRecipe)) {
      if (brew(transmuteRecipe, autoBrew: true)) {
        actions.add('AUTO: Brewing ${transmuteRecipe.displayName}');
      }
    }

    return actions;
  }

  /// Find the best available health potion recipe
  AlchemyRecipe? _findBestHealthRecipe() {
    final candidates = [
      PotionType.healthSuperior,
      PotionType.healthMajor,
      PotionType.healthMinor,
    ];

    for (final type in candidates) {
      final recipe = _findRecipe(type);
      if (recipe != null && canBrew(recipe)) {
        return recipe;
      }
    }

    return null;
  }

  /// Find recipe by potion type
  AlchemyRecipe? _findRecipe(PotionType type) {
    try {
      return _state.availableRecipes.firstWhere((r) => r.potionType == type);
    } catch (_) {
      return null;
    }
  }

  // ============================================================================
  // Potions Management
  // ============================================================================

  /// Use a healing potion on the character
  /// Returns the amount healed
  int useHealingPotion(Character character) {
    // Find best available healing potion
    final types = [
      PotionType.healthSuperior,
      PotionType.healthMajor,
      PotionType.healthMinor,
    ];

    for (final type in types) {
      if (_state.getPotionCount(type) > 0) {
        if (_state.usePotion(type)) {
          final healed = AlchemyHelper.calculateHealing(
            type,
            character.maxHealth,
          );
          character.currentHealth = (character.currentHealth + healed).clamp(
            0,
            character.maxHealth,
          );
          return healed;
        }
      }
    }

    return 0;
  }

  /// Use a mana potion on the character
  /// Returns the amount restored
  int useManaPotion(Character character) {
    final types = [
      PotionType.manaSuperior,
      PotionType.manaMajor,
      PotionType.manaMinor,
    ];

    for (final type in types) {
      if (_state.getPotionCount(type) > 0) {
        if (_state.usePotion(type)) {
          final restored = AlchemyHelper.calculateManaRestore(
            type,
            character.maxMana,
          );
          character.currentMana = (character.currentMana + restored).clamp(
            0,
            character.maxMana,
          );
          return restored;
        }
      }
    }

    return 0;
  }

  /// Get potion count for a type
  int getPotionCount(PotionType type) => _state.getPotionCount(type);

  /// Get total healing potions
  int get healingPotionCount => _state.healingPotionCount;

  /// Get total mana potions
  int get manaPotionCount => _state.manaPotionCount;

  // ============================================================================
  // State Management
  // ============================================================================

  /// Get current state
  AlchemyState get state => _state;

  /// Update state reference
  void updateState(AlchemyState newState) {
    _state = newState;
  }

  /// Update profession state reference
  void updateProfessionState(ProfessionState professionState) {
    _professionState = professionState;
  }

  /// Toggle auto-brew
  void toggleAutoBrew() {
    _state.toggleAutoBrew();
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    return _state.getStats();
  }

  // ============================================================================
  // Brewing Slot Management
  // ============================================================================

  /// Get all brewing slots
  List<BrewingSlot> get brewingSlots => _state.brewingSlots;

  /// Get available slots
  List<BrewingSlot> get availableSlots => _state.availableSlots;

  /// Get active brewing slots
  List<BrewingSlot> get activeSlots => _state.activeSlots;

  /// Get completed slots
  List<BrewingSlot> get completedSlots => _state.completedSlots;

  /// Cancel brewing in a slot
  void cancelBrew(BrewingSlot slot) {
    // Return materials if cancelled
    if (slot.recipe != null && _professionState != null) {
      for (final entry in slot.recipe!.requiredMaterials.entries) {
        _professionState!.addMaterial(entry.key, entry.value);
      }
      _professionState!.save();
    }
    slot.clear();
    _state.save();
  }
}
