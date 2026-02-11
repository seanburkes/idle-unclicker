import 'dart:math';
import '../models/professions.dart';
import '../models/character.dart';

/// Service for managing Professions (gathering and crafting)
class ProfessionService {
  final Random _random = Random();
  ProfessionState _state;

  ProfessionService(this._state);

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize professions - creates all 4 professions at level 1
  void initializeProfessions() {
    for (final profession in _state.professions) {
      if (!profession.isUnlocked) {
        profession.unlock();
      }
    }
    _state.save();
  }

  // ============================================================================
  // Material Gathering
  // ============================================================================

  /// Gather materials during combat
  /// Called automatically during combat ticks
  /// Returns list of gathered materials for logging
  List<MaterialGatheredEvent> gatherMaterials({
    required ProfessionType professionType,
    required String monsterType,
    required bool isFocusMode,
    int dungeonDepth = 1,
  }) {
    final events = <MaterialGatheredEvent>[];
    final profession = _state.getProfession(professionType);

    if (profession == null || !profession.isUnlocked) return events;

    // Calculate base materials to gather
    double baseAmount = profession.gatherRate;

    // Apply level bonus
    baseAmount *= profession.getGatherBonus();

    // Apply depth scaling (more materials at deeper levels)
    baseAmount *= (1.0 + (dungeonDepth * 0.02));

    // Monster type bonus
    final monsterBonus = _getMonsterBonus(professionType, monsterType);
    baseAmount *= (1.0 + monsterBonus);

    // Determine what material to gather based on depth and profession
    final materialType = _selectMaterialType(professionType, dungeonDepth);

    // Check for astral material (only in focus mode >80%)
    if (isFocusMode && _random.nextDouble() < 0.1) {
      // 10% chance for astral material in focus mode
      final astralType = _getAstralMaterial(professionType);
      if (astralType != null) {
        _state.addMaterial(astralType, 1);
        events.add(
          MaterialGatheredEvent(
            material: astralType,
            amount: 1,
            isAstral: true,
          ),
        );

        // Add XP for gathering astral material
        profession.addExperience(50);
      }
    }

    // Add regular materials
    final amount = baseAmount.floor();
    if (amount > 0) {
      _state.addMaterial(materialType, amount);
      events.add(
        MaterialGatheredEvent(
          material: materialType,
          amount: amount,
          isAstral: false,
        ),
      );

      // Add XP for gathering
      profession.addExperience(amount * 2);
    }

    _state.lastGatherTick = DateTime.now();
    _state.save();

    return events;
  }

  /// Get bonus multiplier based on monster type matching profession
  double _getMonsterBonus(ProfessionType profession, String monsterType) {
    // Mining bonus from stone/earth creatures
    final stoneCreatures = ['golem', 'elemental', 'golem', 'golem'];
    // Herbalism bonus from plant/nature creatures
    final natureCreatures = ['treant', 'dryad', 'plant', 'ent'];
    // Skinning bonus from beasts
    final beastCreatures = ['wolf', 'bear', 'boar', 'stag', 'cat'];

    switch (profession) {
      case ProfessionType.mining:
        if (stoneCreatures.contains(monsterType.toLowerCase())) return 0.5;
        break;
      case ProfessionType.herbalism:
        if (natureCreatures.contains(monsterType.toLowerCase())) return 0.5;
        break;
      case ProfessionType.skinning:
        if (beastCreatures.contains(monsterType.toLowerCase())) return 0.5;
        break;
      case ProfessionType.crafting:
        return 0.0; // Crafting doesn't gather
    }

    return 0.0;
  }

  /// Select appropriate material type based on dungeon depth
  MaterialType _selectMaterialType(ProfessionType profession, int depth) {
    final tier = ((depth - 1) / 5).clamp(0, 4).toInt() + 1;

    switch (profession) {
      case ProfessionType.mining:
        switch (tier) {
          case 1:
            return MaterialType.copperOre;
          case 2:
            return MaterialType.ironOre;
          case 3:
            return MaterialType.goldOre;
          case 4:
            return MaterialType.mithrilOre;
          case 5:
          default:
            return MaterialType.adamantiteOre;
        }
      case ProfessionType.herbalism:
        switch (tier) {
          case 1:
            return MaterialType.peacebloom;
          case 2:
            return MaterialType.silverleaf;
          case 3:
            return MaterialType.mageroyal;
          case 4:
            return MaterialType.briarthorn;
          case 5:
          default:
            return MaterialType.fadeleaf;
        }
      case ProfessionType.skinning:
        switch (tier) {
          case 1:
            return MaterialType.ruinedLeather;
          case 2:
            return MaterialType.lightLeather;
          case 3:
            return MaterialType.mediumLeather;
          case 4:
            return MaterialType.heavyLeather;
          case 5:
          default:
            return MaterialType.ruggedLeather;
        }
      case ProfessionType.crafting:
        return MaterialType.copperOre; // Shouldn't be called for crafting
    }
  }

  /// Get the astral material for a profession
  MaterialType? _getAstralMaterial(ProfessionType profession) {
    switch (profession) {
      case ProfessionType.mining:
        return MaterialType.astralOre;
      case ProfessionType.herbalism:
        return MaterialType.astralHerb;
      case ProfessionType.skinning:
        return MaterialType.astralHide;
      case ProfessionType.crafting:
        return null;
    }
  }

  // ============================================================================
  // Crafting
  // ============================================================================

  /// Get list of all craftable recipes
  List<CraftingRecipe> getCraftableRecipes() {
    return CraftedItemType.values.map((itemType) {
      return CraftingRecipe(
        itemType: itemType,
        requiredMaterials: itemType.requiredMaterials,
        requiredCraftingLevel: 1,
      );
    }).toList();
  }

  /// Check if a specific item can be crafted
  bool canCraft(CraftedItemType itemType) {
    final craftingProfession = _state.getProfession(ProfessionType.crafting);
    if (craftingProfession == null || !craftingProfession.isUnlocked) {
      return false;
    }

    final recipe = CraftingRecipe(
      itemType: itemType,
      requiredMaterials: itemType.requiredMaterials,
      requiredCraftingLevel: 1,
    );

    return recipe.canCraft(craftingProfession.level, _state.inventory);
  }

  /// Craft an item
  CraftResult craft(CraftedItemType itemType, {int amount = 1}) {
    if (!canCraft(itemType)) {
      return CraftResult.failure('Missing required materials');
    }

    final recipe = CraftingRecipe(
      itemType: itemType,
      requiredMaterials: itemType.requiredMaterials,
      requiredCraftingLevel: 1,
    );

    // Check if we have enough materials for the requested amount
    for (final entry in recipe.requiredMaterials.entries) {
      final available = _state.inventory[entry.key] ?? 0;
      final needed = entry.value * amount;
      if (available < needed) {
        return CraftResult.failure(
          'Not enough ${entry.key.displayName} (need $needed, have $available)',
        );
      }
    }

    // Consume materials
    for (final entry in recipe.requiredMaterials.entries) {
      _state.removeMaterial(entry.key, entry.value * amount);
    }

    // Add crafted items
    _state.addCraftedItem(itemType, amount);

    // Add XP to crafting profession
    final craftingProfession = _state.getProfession(ProfessionType.crafting)!;
    craftingProfession.addExperience(20 * amount);

    _state.save();

    return CraftResult.success(itemType, amount);
  }

  // ============================================================================
  // Automation
  // ============================================================================

  /// Execute automatic crafting based on character needs
  /// Called during town visits
  List<String> executeAutoCraft(Character character) {
    final actions = <String>[];

    if (!_state.autoCraftEnabled) return actions;

    final craftingProfession = _state.getProfession(ProfessionType.crafting);
    if (craftingProfession == null || !craftingProfession.isUnlocked) {
      return actions;
    }

    // 1. Craft health potions if HP < 50%
    final healthPercent = character.currentHealth / character.maxHealth;
    if (healthPercent < 0.5) {
      final potionCount = _state.getCraftedItemQuantity(
        CraftedItemType.healthPotion,
      );
      if (potionCount < 5 && canCraft(CraftedItemType.healthPotion)) {
        final result = craft(CraftedItemType.healthPotion);
        if (result.success) {
          actions.add('AUTO: ${result.message} (Low health detected)');
        }
      }
    }

    // 2. Craft mana potions if MP < 50%
    final manaPercent = character.maxMana > 0
        ? character.currentMana / character.maxMana
        : 1.0;
    if (manaPercent < 0.5) {
      final potionCount = _state.getCraftedItemQuantity(
        CraftedItemType.manaPotion,
      );
      if (potionCount < 3 && canCraft(CraftedItemType.manaPotion)) {
        final result = craft(CraftedItemType.manaPotion);
        if (result.success) {
          actions.add('AUTO: ${result.message} (Low mana detected)');
        }
      }
    }

    // 3. Craft scroll of escape if danger detected (low health + no potions)
    if (healthPercent < 0.3 && character.healthPotions == 0) {
      final scrollCount = _state.getCraftedItemQuantity(
        CraftedItemType.scrollOfEscape,
      );
      if (scrollCount < 2 && canCraft(CraftedItemType.scrollOfEscape)) {
        final result = craft(CraftedItemType.scrollOfEscape);
        if (result.success) {
          actions.add('AUTO: ${result.message} (Emergency escape prepared)');
        }
      }
    }

    // 4. Transmute excess common materials (10:1 ratio)
    final transmutations = _state.getAvailableTransmutations();
    for (final transmute in transmutations.take(3)) {
      // Limit to 3 per tick
      final amount =
          (_state.getMaterialQuantity(transmute.from) ~/ transmute.ratio);
      if (amount > 0) {
        _state.removeMaterial(transmute.from, amount * transmute.ratio);
        _state.addMaterial(transmute.to, amount);
        actions.add(
          'AUTO: Transmuted ${amount * transmute.ratio} ${transmute.from.displayName} → $amount ${transmute.to.displayName}',
        );
      }
    }

    // 5. Sell excess materials if inventory near capacity
    if (_state.isInventoryNearCapacity) {
      final sold = _sellExcessMaterials();
      if (sold > 0) {
        actions.add('AUTO: Sold excess materials for $sold gold');
      }
    }

    _state.save();
    return actions;
  }

  /// Sell excess materials (common tiers, keeping some reserve)
  int _sellExcessMaterials() {
    int totalGold = 0;

    // Sell copper ore (keep 50)
    final copperAmount = _state.getMaterialQuantity(MaterialType.copperOre);
    if (copperAmount > 50) {
      final toSell = copperAmount - 50;
      _state.removeMaterial(MaterialType.copperOre, toSell);
      totalGold += MaterialType.copperOre.sellPrice * toSell;
    }

    // Sell peacebloom (keep 50)
    final peacebloomAmount = _state.getMaterialQuantity(
      MaterialType.peacebloom,
    );
    if (peacebloomAmount > 50) {
      final toSell = peacebloomAmount - 50;
      _state.removeMaterial(MaterialType.peacebloom, toSell);
      totalGold += MaterialType.peacebloom.sellPrice * toSell;
    }

    // Sell ruined leather (keep 50)
    final ruinedAmount = _state.getMaterialQuantity(MaterialType.ruinedLeather);
    if (ruinedAmount > 50) {
      final toSell = ruinedAmount - 50;
      _state.removeMaterial(MaterialType.ruinedLeather, toSell);
      totalGold += MaterialType.ruinedLeather.sellPrice * toSell;
    }

    return totalGold;
  }

  // ============================================================================
  // Profession Leveling
  // ============================================================================

  /// Add XP to a profession
  void addProfessionXP(ProfessionType type, int amount) {
    final profession = _state.getProfession(type);
    if (profession == null || !profession.isUnlocked) return;

    profession.addExperience(amount);
    _state.save();
  }

  /// Calculate gather bonus from profession level
  double calculateGatherBonus(ProfessionType type) {
    final profession = _state.getProfession(type);
    if (profession == null || !profession.isUnlocked) return 1.0;

    return profession.getGatherBonus();
  }

  // ============================================================================
  // State Management
  // ============================================================================

  ProfessionState get state => _state;

  void updateState(ProfessionState newState) {
    _state = newState;
  }

  /// Get profession statistics summary
  Map<String, dynamic> getSummary() {
    final summary = <String, dynamic>{};

    for (final profession in _state.professions) {
      summary[profession.type.displayName] = {
        'level': profession.level,
        'experience': profession.experience,
        'xpToNext': profession.experienceToNextLevel,
        'progress': profession.levelProgress,
        'gatherRate': profession.gatherRate,
        'isUnlocked': profession.isUnlocked,
      };
    }

    summary['totalCrafts'] = _state.totalCraftsCompleted;
    summary['inventoryValue'] = _state.inventoryValue;
    summary['astralMaterials'] = _state.astralMaterialCount;
    summary['autoCraftEnabled'] = _state.autoCraftEnabled;

    return summary;
  }

  /// Get materials organized by profession
  Map<ProfessionType, List<Map<String, dynamic>>> getMaterialsByProfession() {
    final result = <ProfessionType, List<Map<String, dynamic>>>{};

    for (final professionType in ProfessionType.values) {
      if (professionType == ProfessionType.crafting) continue;

      final materials = <Map<String, dynamic>>[];
      for (final entry in _state.inventory.entries) {
        if (entry.key.associatedProfession == professionType) {
          materials.add({
            'type': entry.key,
            'name': entry.key.displayName,
            'quantity': entry.value,
            'icon': entry.key.icon,
            'isAstral': entry.key.isAstral,
            'tier': entry.key.tier,
          });
        }
      }

      // Sort by tier
      materials.sort((a, b) => (a['tier'] as int).compareTo(b['tier'] as int));
      result[professionType] = materials;
    }

    return result;
  }

  /// Toggle auto-crafting
  void toggleAutoCraft() {
    _state.autoCraftEnabled = !_state.autoCraftEnabled;
    _state.save();
  }

  /// Get auto-craft status
  bool get autoCraftEnabled => _state.autoCraftEnabled;
}
