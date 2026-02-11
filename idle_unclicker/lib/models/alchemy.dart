import 'package:hive/hive.dart';
import 'professions.dart';

part 'alchemy.g.dart';

/// PotionType - All available potion types
@HiveType(typeId: 47)
enum PotionType {
  // Health Potions
  @HiveField(0)
  healthMinor, // Restores 25% HP
  @HiveField(1)
  healthMajor, // Restores 50% HP
  @HiveField(2)
  healthSuperior, // Restores 75% HP
  // Mana Potions
  @HiveField(3)
  manaMinor, // Restores 25% MP
  @HiveField(4)
  manaMajor, // Restores 50% MP
  @HiveField(5)
  manaSuperior, // Restores 75% MP
  // Stat Buff Potions
  @HiveField(6)
  strength, // +STR for duration
  @HiveField(7)
  agility, // +DEX for duration
  @HiveField(8)
  intellect, // +INT for duration
  @HiveField(9)
  protection, // +DEF for duration
  // Utility Potions
  @HiveField(10)
  luck, // +Gold find
  @HiveField(11)
  wisdom, // +XP gain
  @HiveField(12)
  haste, // +Attack speed
  // Special Potions
  @HiveField(13)
  transmutationBoost, // +Miracle chance for transmutation
}

/// Extension for PotionType display and properties
extension PotionTypeExtension on PotionType {
  String get displayName {
    switch (this) {
      case PotionType.healthMinor:
        return 'Minor Health Potion';
      case PotionType.healthMajor:
        return 'Major Health Potion';
      case PotionType.healthSuperior:
        return 'Superior Health Potion';
      case PotionType.manaMinor:
        return 'Minor Mana Potion';
      case PotionType.manaMajor:
        return 'Major Mana Potion';
      case PotionType.manaSuperior:
        return 'Superior Mana Potion';
      case PotionType.strength:
        return 'Potion of Strength';
      case PotionType.agility:
        return 'Potion of Agility';
      case PotionType.intellect:
        return 'Potion of Intellect';
      case PotionType.protection:
        return 'Potion of Protection';
      case PotionType.luck:
        return 'Potion of Luck';
      case PotionType.wisdom:
        return 'Potion of Wisdom';
      case PotionType.haste:
        return 'Potion of Haste';
      case PotionType.transmutationBoost:
        return 'Transmutation Elixir';
    }
  }

  String get icon {
    switch (this) {
      case PotionType.healthMinor:
      case PotionType.healthMajor:
      case PotionType.healthSuperior:
        return '🧪';
      case PotionType.manaMinor:
      case PotionType.manaMajor:
      case PotionType.manaSuperior:
        return '💙';
      case PotionType.strength:
        return '💪';
      case PotionType.agility:
        return '⚡';
      case PotionType.intellect:
        return '🧠';
      case PotionType.protection:
        return '🛡️';
      case PotionType.luck:
        return '🍀';
      case PotionType.wisdom:
        return '📚';
      case PotionType.haste:
        return '💨';
      case PotionType.transmutationBoost:
        return '✨';
    }
  }

  String get color {
    switch (this) {
      case PotionType.healthMinor:
      case PotionType.healthMajor:
      case PotionType.healthSuperior:
        return '#FF0000';
      case PotionType.manaMinor:
      case PotionType.manaMajor:
      case PotionType.manaSuperior:
        return '#0000FF';
      case PotionType.strength:
        return '#FF4500';
      case PotionType.agility:
        return '#00FF00';
      case PotionType.intellect:
        return '#9400D3';
      case PotionType.protection:
        return '#4682B4';
      case PotionType.luck:
        return '#FFD700';
      case PotionType.wisdom:
        return '#4B0082';
      case PotionType.haste:
        return '#00FFFF';
      case PotionType.transmutationBoost:
        return '#FF00FF';
    }
  }

  String get description {
    switch (this) {
      case PotionType.healthMinor:
        return 'Restores 25% of maximum health';
      case PotionType.healthMajor:
        return 'Restores 50% of maximum health';
      case PotionType.healthSuperior:
        return 'Restores 75% of maximum health';
      case PotionType.manaMinor:
        return 'Restores 25% of maximum mana';
      case PotionType.manaMajor:
        return 'Restores 50% of maximum mana';
      case PotionType.manaSuperior:
        return 'Restores 75% of maximum mana';
      case PotionType.strength:
        return 'Increases Strength by 20% for 10 minutes';
      case PotionType.agility:
        return 'Increases Dexterity by 20% for 10 minutes';
      case PotionType.intellect:
        return 'Increases Intelligence by 20% for 10 minutes';
      case PotionType.protection:
        return 'Increases Defense by 20% for 10 minutes';
      case PotionType.luck:
        return 'Increases gold find by 25% for 15 minutes';
      case PotionType.wisdom:
        return 'Increases XP gain by 25% for 15 minutes';
      case PotionType.haste:
        return 'Increases attack speed by 20% for 10 minutes';
      case PotionType.transmutationBoost:
        return 'Increases transmutation miracle chance by 2%';
    }
  }

  /// Get potion tier (1-3)
  int get tier {
    switch (this) {
      case PotionType.healthMinor:
      case PotionType.manaMinor:
        return 1;
      case PotionType.healthMajor:
      case PotionType.manaMajor:
      case PotionType.strength:
      case PotionType.agility:
      case PotionType.intellect:
      case PotionType.protection:
        return 2;
      case PotionType.healthSuperior:
      case PotionType.manaSuperior:
      case PotionType.luck:
      case PotionType.wisdom:
      case PotionType.haste:
      case PotionType.transmutationBoost:
        return 3;
    }
  }

  /// Check if this is a healing potion
  bool get isHealing =>
      this == PotionType.healthMinor ||
      this == PotionType.healthMajor ||
      this == PotionType.healthSuperior;

  /// Check if this is a mana potion
  bool get isMana =>
      this == PotionType.manaMinor ||
      this == PotionType.manaMajor ||
      this == PotionType.manaSuperior;

  /// Check if this is a buff potion
  bool get isBuff =>
      this == PotionType.strength ||
      this == PotionType.agility ||
      this == PotionType.intellect ||
      this == PotionType.protection ||
      this == PotionType.luck ||
      this == PotionType.wisdom ||
      this == PotionType.haste;

  /// Check if this is a special potion
  bool get isSpecial => this == PotionType.transmutationBoost;
}

/// PotionEffect - An active potion effect on the character
@HiveType(typeId: 48)
class PotionEffect extends HiveObject {
  @HiveField(0)
  PotionType type;

  @HiveField(1)
  int durationSeconds;

  @HiveField(2)
  double magnitude; // Percentage bonus (0.20 = +20%)

  @HiveField(3)
  bool isActive;

  @HiveField(4)
  DateTime activatedAt;

  @HiveField(5)
  DateTime? expiresAt;

  PotionEffect({
    required this.type,
    required this.durationSeconds,
    required this.magnitude,
    this.isActive = false,
    required this.activatedAt,
    this.expiresAt,
  });

  /// Create a new potion effect
  factory PotionEffect.create(PotionType type) {
    final duration = _getDurationForType(type);
    final magnitude = _getMagnitudeForType(type);
    final now = DateTime.now();

    return PotionEffect(
      type: type,
      durationSeconds: duration,
      magnitude: magnitude,
      isActive: true,
      activatedAt: now,
      expiresAt: now.add(Duration(seconds: duration)),
    );
  }

  static int _getDurationForType(PotionType type) {
    switch (type) {
      case PotionType.healthMinor:
      case PotionType.healthMajor:
      case PotionType.healthSuperior:
      case PotionType.manaMinor:
      case PotionType.manaMajor:
      case PotionType.manaSuperior:
        return 0; // Instant effect
      case PotionType.strength:
      case PotionType.agility:
      case PotionType.intellect:
      case PotionType.protection:
      case PotionType.haste:
        return 600; // 10 minutes
      case PotionType.luck:
      case PotionType.wisdom:
        return 900; // 15 minutes
      case PotionType.transmutationBoost:
        return 300; // 5 minutes for transmutation boost
    }
  }

  static double _getMagnitudeForType(PotionType type) {
    switch (type) {
      case PotionType.healthMinor:
      case PotionType.healthMajor:
      case PotionType.healthSuperior:
      case PotionType.manaMinor:
      case PotionType.manaMajor:
      case PotionType.manaSuperior:
        return 0.0; // Instant effect
      case PotionType.strength:
      case PotionType.agility:
      case PotionType.intellect:
      case PotionType.protection:
      case PotionType.haste:
        return 0.20; // +20%
      case PotionType.luck:
      case PotionType.wisdom:
        return 0.25; // +25%
      case PotionType.transmutationBoost:
        return 0.02; // +2% miracle chance
    }
  }

  /// Get remaining duration in seconds
  int get remainingSeconds {
    if (!isActive || expiresAt == null) return 0;
    final remaining = expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining.clamp(0, durationSeconds);
  }

  /// Check if effect has expired
  bool get hasExpired {
    if (!isActive) return true;
    if (expiresAt == null) return false; // Instant effect
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get display string for remaining time
  String get remainingTimeDisplay {
    if (hasExpired) return 'Expired';
    if (expiresAt == null) return 'Instant';
    final remaining = remainingSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  /// Apply the effect (mark as active)
  void apply() {
    isActive = true;
    activatedAt = DateTime.now();
    expiresAt = activatedAt.add(Duration(seconds: durationSeconds));
  }

  /// Deactivate the effect
  void deactivate() {
    isActive = false;
  }
}

/// AlchemyRecipe - Recipe for brewing potions
@HiveType(typeId: 49)
class AlchemyRecipe extends HiveObject {
  @HiveField(0)
  PotionType potionType;

  @HiveField(1)
  Map<MaterialType, int> requiredMaterials;

  @HiveField(2)
  int goldCost;

  @HiveField(3)
  int brewTimeSeconds;

  @HiveField(4)
  int outputQuantity;

  @HiveField(5)
  int requiredAlchemyLevel;

  AlchemyRecipe({
    required this.potionType,
    required this.requiredMaterials,
    this.goldCost = 0,
    required this.brewTimeSeconds,
    this.outputQuantity = 1,
    this.requiredAlchemyLevel = 1,
  });

  /// Get display name
  String get displayName => potionType.displayName;

  /// Get icon
  String get icon => potionType.icon;

  /// Get color
  String get color => potionType.color;

  /// Get description
  String get description => potionType.description;

  /// Get formatted brew time
  String get brewTimeDisplay {
    final minutes = brewTimeSeconds ~/ 60;
    if (minutes > 0) {
      return '$minutes min';
    }
    return '$brewTimeSeconds sec';
  }

  /// Check if player can craft this
  bool canCraft(int alchemyLevel, Map<MaterialType, int> inventory, int gold) {
    if (alchemyLevel < requiredAlchemyLevel) return false;
    if (gold < goldCost) return false;

    for (final entry in requiredMaterials.entries) {
      final available = inventory[entry.key] ?? 0;
      if (available < entry.value) return false;
    }

    return true;
  }

  /// Create all standard potion recipes
  static List<AlchemyRecipe> createAllRecipes() {
    return [
      // Health Potions
      AlchemyRecipe(
        potionType: PotionType.healthMinor,
        requiredMaterials: {MaterialType.peacebloom: 3},
        goldCost: 50,
        brewTimeSeconds: 120, // 2 minutes
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.healthMajor,
        requiredMaterials: {
          MaterialType.peacebloom: 2,
          MaterialType.silverleaf: 2,
        },
        goldCost: 100,
        brewTimeSeconds: 300, // 5 minutes
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.healthSuperior,
        requiredMaterials: {
          MaterialType.mageroyal: 3,
          MaterialType.briarthorn: 2,
        },
        goldCost: 250,
        brewTimeSeconds: 600, // 10 minutes
        outputQuantity: 1,
      ),

      // Mana Potions
      AlchemyRecipe(
        potionType: PotionType.manaMinor,
        requiredMaterials: {MaterialType.silverleaf: 3},
        goldCost: 50,
        brewTimeSeconds: 120,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.manaMajor,
        requiredMaterials: {
          MaterialType.mageroyal: 2,
          MaterialType.briarthorn: 1,
        },
        goldCost: 100,
        brewTimeSeconds: 300,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.manaSuperior,
        requiredMaterials: {
          MaterialType.fadeleaf: 2,
          MaterialType.briarthorn: 2,
        },
        goldCost: 250,
        brewTimeSeconds: 600,
        outputQuantity: 1,
      ),

      // Buff Potions
      AlchemyRecipe(
        potionType: PotionType.strength,
        requiredMaterials: {
          MaterialType.ironOre: 2,
          MaterialType.peacebloom: 1,
        },
        goldCost: 100,
        brewTimeSeconds: 300,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.agility,
        requiredMaterials: {
          MaterialType.lightLeather: 2,
          MaterialType.silverleaf: 1,
        },
        goldCost: 100,
        brewTimeSeconds: 300,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.intellect,
        requiredMaterials: {MaterialType.goldOre: 2, MaterialType.mageroyal: 1},
        goldCost: 150,
        brewTimeSeconds: 300,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.protection,
        requiredMaterials: {
          MaterialType.ironOre: 2,
          MaterialType.mediumLeather: 1,
        },
        goldCost: 150,
        brewTimeSeconds: 300,
        outputQuantity: 1,
      ),

      // Utility Potions
      AlchemyRecipe(
        potionType: PotionType.luck,
        requiredMaterials: {MaterialType.goldOre: 3, MaterialType.fadeleaf: 1},
        goldCost: 200,
        brewTimeSeconds: 600,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.wisdom,
        requiredMaterials: {
          MaterialType.mithrilOre: 2,
          MaterialType.mageroyal: 2,
        },
        goldCost: 200,
        brewTimeSeconds: 600,
        outputQuantity: 1,
      ),
      AlchemyRecipe(
        potionType: PotionType.haste,
        requiredMaterials: {
          MaterialType.mithrilOre: 2,
          MaterialType.lightLeather: 2,
        },
        goldCost: 200,
        brewTimeSeconds: 600,
        outputQuantity: 1,
      ),

      // Special Potions
      AlchemyRecipe(
        potionType: PotionType.transmutationBoost,
        requiredMaterials: {
          MaterialType.astralHerb: 1,
          MaterialType.fadeleaf: 2,
        },
        goldCost: 500,
        brewTimeSeconds: 600, // 10 minutes
        outputQuantity: 1,
        requiredAlchemyLevel: 5,
      ),
    ];
  }
}

/// BrewingSlot - A slot for brewing potions
@HiveType(typeId: 50)
class BrewingSlot extends HiveObject {
  @HiveField(0)
  AlchemyRecipe? recipe;

  @HiveField(1)
  DateTime? startedAt;

  @HiveField(2)
  bool isComplete;

  @HiveField(3)
  bool isAutoBrew; // Automation flagged this slot

  @HiveField(4)
  int progressSeconds; // Current progress

  BrewingSlot({
    this.recipe,
    this.startedAt,
    this.isComplete = false,
    this.isAutoBrew = false,
    this.progressSeconds = 0,
  });

  /// Create an empty brewing slot
  factory BrewingSlot.empty() {
    return BrewingSlot();
  }

  /// Check if slot is available
  bool get isAvailable => recipe == null && !isComplete;

  /// Check if brewing is in progress
  bool get isBrewing => recipe != null && !isComplete && !isFinished;

  /// Check if brewing is finished
  bool get isFinished {
    if (recipe == null || startedAt == null) return false;
    final elapsed = DateTime.now().difference(startedAt!).inSeconds;
    return elapsed >= recipe!.brewTimeSeconds;
  }

  /// Get progress percentage (0.0 - 1.0)
  double get progressPercent {
    if (recipe == null) return 0.0;
    if (isComplete) return 1.0;
    final elapsed = DateTime.now()
        .difference(startedAt ?? DateTime.now())
        .inSeconds;
    return (elapsed / recipe!.brewTimeSeconds).clamp(0.0, 1.0);
  }

  /// Get remaining seconds
  int get remainingSeconds {
    if (recipe == null || isComplete) return 0;
    final elapsed = DateTime.now()
        .difference(startedAt ?? DateTime.now())
        .inSeconds;
    return (recipe!.brewTimeSeconds - elapsed).clamp(
      0,
      recipe!.brewTimeSeconds,
    );
  }

  /// Start brewing
  void startBrewing(AlchemyRecipe newRecipe, {bool autoBrew = false}) {
    recipe = newRecipe;
    startedAt = DateTime.now();
    isComplete = false;
    isAutoBrew = autoBrew;
    progressSeconds = 0;
  }

  /// Complete brewing
  PotionType? completeBrewing() {
    if (!isFinished) return null;
    isComplete = true;
    return recipe?.potionType;
  }

  /// Collect the potion and clear slot
  PotionType? collect() {
    if (!isComplete) return null;
    final potionType = recipe?.potionType;
    clear();
    return potionType;
  }

  /// Clear the slot
  void clear() {
    recipe = null;
    startedAt = null;
    isComplete = false;
    isAutoBrew = false;
    progressSeconds = 0;
  }

  /// Update progress (called periodically)
  void updateProgress() {
    if (recipe == null || isComplete) return;

    final elapsed = DateTime.now()
        .difference(startedAt ?? DateTime.now())
        .inSeconds;
    progressSeconds = elapsed;

    if (elapsed >= recipe!.brewTimeSeconds) {
      isComplete = true;
    }
  }
}

/// AlchemyState - Main state class for alchemy system
@HiveType(typeId: 51)
class AlchemyState extends HiveObject {
  @HiveField(0)
  List<PotionEffect> activeEffects;

  @HiveField(1)
  List<AlchemyRecipe> availableRecipes;

  @HiveField(2)
  List<BrewingSlot> brewingSlots;

  @HiveField(3)
  Map<PotionType, int> inventory; // Brewed potions ready to use

  @HiveField(4)
  int totalBrewed;

  @HiveField(5)
  bool autoBrewEnabled;

  @HiveField(6)
  int alchemyLevel;

  @HiveField(7)
  int alchemyExperience;

  @HiveField(8)
  DateTime lastBrewTick;

  AlchemyState({
    required this.activeEffects,
    required this.availableRecipes,
    required this.brewingSlots,
    required this.inventory,
    this.totalBrewed = 0,
    this.autoBrewEnabled = true,
    this.alchemyLevel = 1,
    this.alchemyExperience = 0,
    required this.lastBrewTick,
  });

  /// Create initial alchemy state
  factory AlchemyState.create() {
    return AlchemyState(
      activeEffects: [],
      availableRecipes: AlchemyRecipe.createAllRecipes(),
      brewingSlots: [
        BrewingSlot.empty(),
        BrewingSlot.empty(),
        BrewingSlot.empty(),
      ],
      inventory: {},
      lastBrewTick: DateTime.now(),
    );
  }

  /// Get available brewing slots
  List<BrewingSlot> get availableSlots =>
      brewingSlots.where((s) => s.isAvailable).toList();

  /// Get brewing slots in progress
  List<BrewingSlot> get activeSlots =>
      brewingSlots.where((s) => s.isBrewing).toList();

  /// Get completed slots
  List<BrewingSlot> get completedSlots =>
      brewingSlots.where((s) => s.isComplete).toList();

  /// Get potion count
  int getPotionCount(PotionType type) => inventory[type] ?? 0;

  /// Get total healing potions
  int get healingPotionCount {
    return (inventory[PotionType.healthMinor] ?? 0) +
        (inventory[PotionType.healthMajor] ?? 0) +
        (inventory[PotionType.healthSuperior] ?? 0);
  }

  /// Get total mana potions
  int get manaPotionCount {
    return (inventory[PotionType.manaMinor] ?? 0) +
        (inventory[PotionType.manaMajor] ?? 0) +
        (inventory[PotionType.manaSuperior] ?? 0);
  }

  /// Add potion to inventory
  void addPotion(PotionType type, int amount) {
    inventory[type] = (inventory[type] ?? 0) + amount;
    totalBrewed += amount;
    save();
  }

  /// Remove potion from inventory
  bool removePotion(PotionType type, int amount) {
    final current = inventory[type] ?? 0;
    if (current < amount) return false;
    inventory[type] = current - amount;
    save();
    return true;
  }

  /// Use a potion (adds to active effects or applies instantly)
  bool usePotion(PotionType type) {
    if (!removePotion(type, 1)) return false;

    if (type.isHealing || type.isMana) {
      // Instant effects - don't add to active effects
      return true;
    }

    // Buff potions - add to active effects
    final effect = PotionEffect.create(type);

    // Remove any existing effect of same type
    activeEffects.removeWhere((e) => e.type == type);

    activeEffects.add(effect);
    save();
    return true;
  }

  /// Update all active effects (remove expired)
  void updateEffects() {
    activeEffects.removeWhere((e) => e.hasExpired);
    save();
  }

  /// Get active effect for a potion type
  PotionEffect? getActiveEffect(PotionType type) {
    try {
      return activeEffects.firstWhere((e) => e.type == type && e.isActive);
    } catch (_) {
      return null;
    }
  }

  /// Check if a potion effect is active
  bool isEffectActive(PotionType type) {
    return activeEffects.any(
      (e) => e.type == type && e.isActive && !e.hasExpired,
    );
  }

  /// Get transmutation boost percentage
  double get transmutationBoost {
    final effect = getActiveEffect(PotionType.transmutationBoost);
    if (effect == null || effect.hasExpired) return 0.0;
    return effect.magnitude;
  }

  /// Update brewing progress for all slots
  void updateBrewingProgress() {
    for (final slot in brewingSlots) {
      slot.updateProgress();
    }
    save();
  }

  /// Start brewing in first available slot
  bool startBrewing(AlchemyRecipe recipe, {bool autoBrew = false}) {
    final available = availableSlots;
    if (available.isEmpty) return false;

    available.first.startBrewing(recipe, autoBrew: autoBrew);
    save();
    return true;
  }

  /// Collect all completed brews
  List<PotionType> collectCompleted() {
    final collected = <PotionType>[];

    for (final slot in brewingSlots) {
      if (slot.isComplete) {
        final potionType = slot.collect();
        if (potionType != null) {
          collected.add(potionType);
          addPotion(potionType, slot.recipe?.outputQuantity ?? 1);
        }
      }
    }

    if (collected.isNotEmpty) {
      save();
    }

    return collected;
  }

  /// Add alchemy experience
  void addExperience(int amount) {
    alchemyExperience += amount;

    // Level up if enough experience (simple formula)
    final required = alchemyLevel * 100;
    while (alchemyExperience >= required) {
      alchemyExperience -= required;
      alchemyLevel++;
    }

    save();
  }

  /// Toggle auto-brew
  void toggleAutoBrew() {
    autoBrewEnabled = !autoBrewEnabled;
    save();
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    return {
      'totalBrewed': totalBrewed,
      'alchemyLevel': alchemyLevel,
      'activeEffects': activeEffects.length,
      'brewingSlotsInUse': activeSlots.length,
      'completedBrews': completedSlots.length,
      'healingPotions': healingPotionCount,
      'manaPotions': manaPotionCount,
    };
  }
}

/// Helper class for alchemy-related calculations
class AlchemyHelper {
  /// Calculate healing amount for a health potion
  static int calculateHealing(PotionType type, int maxHealth) {
    switch (type) {
      case PotionType.healthMinor:
        return (maxHealth * 0.25).round();
      case PotionType.healthMajor:
        return (maxHealth * 0.50).round();
      case PotionType.healthSuperior:
        return (maxHealth * 0.75).round();
      default:
        return 0;
    }
  }

  /// Calculate mana restoration for a mana potion
  static int calculateManaRestore(PotionType type, int maxMana) {
    switch (type) {
      case PotionType.manaMinor:
        return (maxMana * 0.25).round();
      case PotionType.manaMajor:
        return (maxMana * 0.50).round();
      case PotionType.manaSuperior:
        return (maxMana * 0.75).round();
      default:
        return 0;
    }
  }
}
