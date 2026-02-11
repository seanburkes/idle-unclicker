import 'package:hive/hive.dart';
import 'dart:math';

part 'legendary_items.g.dart';

/// LegendaryEffectType - Types of legendary effects
@HiveType(typeId: 50)
enum LegendaryEffectType {
  @HiveField(0)
  damageBoost,
  @HiveField(1)
  defenseBoost,
  @HiveField(2)
  lifeSteal,
  @HiveField(3)
  criticalMastery,
  @HiveField(4)
  elementalDamage,
  @HiveField(5)
  bossSlayer,
  @HiveField(6)
  dragonBane,
  @HiveField(7)
  undeadBane,
  @HiveField(8)
  goldMagnet,
  @HiveField(9)
  xpMagnet,
  @HiveField(10)
  potionMastery,
  @HiveField(11)
  immortality,
  @HiveField(12)
  timeWarp,
  @HiveField(13)
  summonHelper,
  @HiveField(14)
  elementalConversion,
  @HiveField(15)
  reflectDamage,
  @HiveField(16)
  hpToDamage,
  @HiveField(17)
  glassCannon,
  @HiveField(18)
  immortalVengeance,
  @HiveField(19)
  wishGranter,
}

/// Extension for LegendaryEffectType display
extension LegendaryEffectTypeExtension on LegendaryEffectType {
  String get displayName {
    switch (this) {
      case LegendaryEffectType.damageBoost:
        return 'Damage Boost';
      case LegendaryEffectType.defenseBoost:
        return 'Defense Boost';
      case LegendaryEffectType.lifeSteal:
        return 'Life Steal';
      case LegendaryEffectType.criticalMastery:
        return 'Critical Mastery';
      case LegendaryEffectType.elementalDamage:
        return 'Elemental Damage';
      case LegendaryEffectType.bossSlayer:
        return 'Boss Slayer';
      case LegendaryEffectType.dragonBane:
        return 'Dragon Bane';
      case LegendaryEffectType.undeadBane:
        return 'Undead Bane';
      case LegendaryEffectType.goldMagnet:
        return 'Gold Magnet';
      case LegendaryEffectType.xpMagnet:
        return 'XP Magnet';
      case LegendaryEffectType.potionMastery:
        return 'Potion Mastery';
      case LegendaryEffectType.immortality:
        return 'Immortality';
      case LegendaryEffectType.timeWarp:
        return 'Time Warp';
      case LegendaryEffectType.summonHelper:
        return 'Summon Helper';
      case LegendaryEffectType.elementalConversion:
        return 'Elemental Conversion';
      case LegendaryEffectType.reflectDamage:
        return 'Reflect Damage';
      case LegendaryEffectType.hpToDamage:
        return 'HP to Damage';
      case LegendaryEffectType.glassCannon:
        return 'Glass Cannon';
      case LegendaryEffectType.immortalVengeance:
        return 'Immortal Vengeance';
      case LegendaryEffectType.wishGranter:
        return 'Wish Granter';
    }
  }

  String get icon {
    switch (this) {
      case LegendaryEffectType.damageBoost:
        return '⚔️';
      case LegendaryEffectType.defenseBoost:
        return '🛡️';
      case LegendaryEffectType.lifeSteal:
        return '🩸';
      case LegendaryEffectType.criticalMastery:
        return '🎯';
      case LegendaryEffectType.elementalDamage:
        return '🔥';
      case LegendaryEffectType.bossSlayer:
        return '👑';
      case LegendaryEffectType.dragonBane:
        return '🐉';
      case LegendaryEffectType.undeadBane:
        return '💀';
      case LegendaryEffectType.goldMagnet:
        return '🪙';
      case LegendaryEffectType.xpMagnet:
        return '📚';
      case LegendaryEffectType.potionMastery:
        return '🧪';
      case LegendaryEffectType.immortality:
        return '📿';
      case LegendaryEffectType.timeWarp:
        return '⏳';
      case LegendaryEffectType.summonHelper:
        return '👻';
      case LegendaryEffectType.elementalConversion:
        return '⚡';
      case LegendaryEffectType.reflectDamage:
        return '🪞';
      case LegendaryEffectType.hpToDamage:
        return '💪';
      case LegendaryEffectType.glassCannon:
        return '💎';
      case LegendaryEffectType.immortalVengeance:
        return '☠️';
      case LegendaryEffectType.wishGranter:
        return '✨';
    }
  }
}

/// SentienceType - What sentient legendaries desire
@HiveType(typeId: 51)
enum SentienceType {
  @HiveField(0)
  killDragons,
  @HiveField(1)
  killBosses,
  @HiveField(2)
  killUndead,
  @HiveField(3)
  findGold,
  @HiveField(4)
  exploreDeep,
  @HiveField(5)
  surviveCombat,
  @HiveField(6)
  usePotions,
  @HiveField(7)
  enchantItems,
  @HiveField(8)
  ascend,
  @HiveField(9)
  collectSets,
}

/// Extension for SentienceType display
extension SentienceTypeExtension on SentienceType {
  String get displayName {
    switch (this) {
      case SentienceType.killDragons:
        return 'Dragon Slayer';
      case SentienceType.killBosses:
        return 'Boss Hunter';
      case SentienceType.killUndead:
        return 'Undead Purifier';
      case SentienceType.findGold:
        return 'Treasure Seeker';
      case SentienceType.exploreDeep:
        return 'Depth Explorer';
      case SentienceType.surviveCombat:
        return 'Survivor';
      case SentienceType.usePotions:
        return 'Alchemical';
      case SentienceType.enchantItems:
        return 'Enchanter';
      case SentienceType.ascend:
        return 'Transcendent';
      case SentienceType.collectSets:
        return 'Collector';
    }
  }

  String get description {
    switch (this) {
      case SentienceType.killDragons:
        return 'Wants to kill dragons';
      case SentienceType.killBosses:
        return 'Wants to kill bosses';
      case SentienceType.killUndead:
        return 'Wants to kill undead';
      case SentienceType.findGold:
        return 'Wants to accumulate gold';
      case SentienceType.exploreDeep:
        return 'Wants to explore deep floors';
      case SentienceType.surviveCombat:
        return 'Wants to survive combat';
      case SentienceType.usePotions:
        return 'Wants potion consumption';
      case SentienceType.enchantItems:
        return 'Wants enchanting activity';
      case SentienceType.ascend:
        return 'Wants character ascension';
      case SentienceType.collectSets:
        return 'Wants set completion';
    }
  }

  String get desireDescription {
    switch (this) {
      case SentienceType.killDragons:
        return 'Kill dragons (+10% per dragon)';
      case SentienceType.killBosses:
        return 'Kill bosses (+15% per boss)';
      case SentienceType.killUndead:
        return 'Kill undead (+5% per undead)';
      case SentienceType.findGold:
        return 'Find 1000 gold (+5% per 1000)';
      case SentienceType.exploreDeep:
        return 'Reach floor 20+ (+20% per deep floor)';
      case SentienceType.surviveCombat:
        return 'Survive dangerous combat (+25% per near-death)';
      case SentienceType.usePotions:
        return 'Use potions (+10% per potion)';
      case SentienceType.enchantItems:
        return 'Enchant items (+20% per enchant)';
      case SentienceType.ascend:
        return 'Ascend (+20% per ascension)';
      case SentienceType.collectSets:
        return 'Complete sets (+15% per set)';
    }
  }
}

/// EquipmentType - Type of equipment slot
@HiveType(typeId: 52)
enum EquipmentSlotType {
  @HiveField(0)
  weapon,
  @HiveField(1)
  armor,
  @HiveField(2)
  jewelry,
}

/// StatBonus - A stat bonus for legendary items (reforgable)
@HiveType(typeId: 53)
class StatBonus extends HiveObject {
  @HiveField(0)
  String statName;

  @HiveField(1)
  double value;

  @HiveField(2)
  bool isPercentage;

  StatBonus({
    required this.statName,
    required this.value,
    this.isPercentage = true,
  });

  String get displayString {
    final sign = value >= 0 ? '+' : '';
    final suffix = isPercentage ? '%' : '';
    return '$sign${value.toStringAsFixed(1)}$suffix $statName';
  }
}

/// LegendaryEffect - The unique effect of a legendary item
@HiveType(typeId: 54)
class LegendaryEffect extends HiveObject {
  @HiveField(0)
  LegendaryEffectType type;

  @HiveField(1)
  double magnitude;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isPassive;

  @HiveField(4)
  bool isTriggered;

  @HiveField(5)
  String? triggerCondition;

  LegendaryEffect({
    required this.type,
    required this.magnitude,
    required this.description,
    this.isPassive = true,
    this.isTriggered = false,
    this.triggerCondition,
  });

  String get formattedDescription {
    final magStr = magnitude.abs() >= 1
        ? magnitude.toStringAsFixed(0)
        : '${(magnitude * 100).toStringAsFixed(0)}%';
    return description.replaceAll('{magnitude}', magStr);
  }
}

/// LegendaryItem - A unique legendary item
@HiveType(typeId: 55)
class LegendaryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String lore;

  @HiveField(4)
  EquipmentSlotType equipmentType;

  @HiveField(5)
  LegendaryEffect effect;

  @HiveField(6)
  List<StatBonus> baseStats;

  @HiveField(7)
  bool hasSentience;

  @HiveField(8)
  SentienceType? sentience;

  @HiveField(9)
  int sentienceProgress;

  @HiveField(10)
  bool isAwakened;

  @HiveField(11)
  int reforgeCount;

  @HiveField(12)
  DateTime acquiredDate;

  @HiveField(13)
  int? acquiredFloor;

  LegendaryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.lore,
    required this.equipmentType,
    required this.effect,
    required this.baseStats,
    this.hasSentience = false,
    this.sentience,
    this.sentienceProgress = 0,
    this.isAwakened = false,
    this.reforgeCount = 0,
    required this.acquiredDate,
    this.acquiredFloor,
  });

  /// Check if this item can be reforged (max 10 times)
  bool get canReforge => reforgeCount < 10;

  /// Get the effective magnitude (awakened items are 50% stronger)
  double get effectiveMagnitude {
    if (!isAwakened) return effect.magnitude;
    return effect.magnitude * 1.5;
  }

  /// Get sentience progress as percentage
  double get sentiencePercent => sentienceProgress / 100.0;

  /// Get total stat value for comparison
  double get totalStatValue {
    return baseStats.fold(0.0, (sum, stat) => sum + stat.value.abs());
  }

  /// Get rarity color (legendary = gold)
  String get rarityColor => '#FFAA00';

  /// Get icon based on equipment type
  String get typeIcon {
    switch (equipmentType) {
      case EquipmentSlotType.weapon:
        return '⚔️';
      case EquipmentSlotType.armor:
        return '🛡️';
      case EquipmentSlotType.jewelry:
        return '💍';
    }
  }

  /// Create a copy for reforge (keeps effect, rerolls stats)
  LegendaryItem copyForReforge(List<StatBonus> newStats) {
    return LegendaryItem(
      id: id,
      name: name,
      description: description,
      lore: lore,
      equipmentType: equipmentType,
      effect: effect,
      baseStats: newStats,
      hasSentience: hasSentience,
      sentience: sentience,
      sentienceProgress: sentienceProgress,
      isAwakened: isAwakened,
      reforgeCount: reforgeCount + 1,
      acquiredDate: acquiredDate,
      acquiredFloor: acquiredFloor,
    );
  }
}

/// LegendaryCollection - Tracks all legendary items
@HiveType(typeId: 56)
class LegendaryCollection extends HiveObject {
  @HiveField(0)
  List<LegendaryItem> ownedItems;

  @HiveField(1)
  List<String> discoveredIds;

  @HiveField(2)
  Map<String, int> dropAttempts;

  @HiveField(3)
  int totalLegendariesAcquired;

  @HiveField(4)
  int totalReforges;

  @HiveField(5)
  int awakenedCount;

  LegendaryCollection({
    this.ownedItems = const [],
    this.discoveredIds = const [],
    this.dropAttempts = const {},
    this.totalLegendariesAcquired = 0,
    this.totalReforges = 0,
    this.awakenedCount = 0,
  });

  /// Create empty collection
  factory LegendaryCollection.create() {
    return LegendaryCollection(
      ownedItems: [],
      discoveredIds: [],
      dropAttempts: {},
    );
  }

  /// Get unique legendary IDs owned
  Set<String> get ownedIds => ownedItems.map((i) => i.id).toSet();

  /// Check if a specific legendary is owned
  bool hasLegendary(String id) => ownedIds.contains(id);

  /// Get best item for a slot
  LegendaryItem? getBestForSlot(EquipmentSlotType slot) {
    final slotItems = ownedItems.where((i) => i.equipmentType == slot).toList();
    if (slotItems.isEmpty) return null;

    slotItems.sort((a, b) => b.totalStatValue.compareTo(a.totalStatValue));
    return slotItems.first;
  }

  /// Get all awakened items
  List<LegendaryItem> get awakenedItems =>
      ownedItems.where((i) => i.isAwakened).toList();

  /// Get sentience progress for a legendary
  int getSentienceProgress(String legendaryId) {
    final item = ownedItems.firstWhere(
      (i) => i.id == legendaryId,
      orElse: () => LegendaryItem(
        id: '',
        name: '',
        description: '',
        lore: '',
        equipmentType: EquipmentSlotType.weapon,
        effect: LegendaryEffect(
          type: LegendaryEffectType.damageBoost,
          magnitude: 0,
          description: '',
        ),
        baseStats: [],
        acquiredDate: DateTime.now(),
      ),
    );
    return item.id.isEmpty ? 0 : item.sentienceProgress;
  }

  /// Record a drop attempt for pity system
  void recordDropAttempt(String bossId) {
    dropAttempts[bossId] = (dropAttempts[bossId] ?? 0) + 1;
  }

  /// Get boss kills since last drop
  int getBossKillsSinceDrop(String bossId) {
    return dropAttempts[bossId] ?? 0;
  }

  /// Reset drop attempts after a drop
  void resetDropAttempts(String bossId) {
    dropAttempts[bossId] = 0;
  }

  /// Add a legendary to collection
  void addLegendary(LegendaryItem item) {
    ownedItems.add(item);
    totalLegendariesAcquired++;
    if (!discoveredIds.contains(item.id)) {
      discoveredIds.add(item.id);
    }
  }

  /// Update sentience progress
  void updateSentienceProgress(String legendaryId, int progress) {
    final index = ownedItems.indexWhere((i) => i.id == legendaryId);
    if (index >= 0) {
      final item = ownedItems[index];
      item.sentienceProgress = progress.clamp(0, 100);
      if (item.sentienceProgress >= 100 && !item.isAwakened) {
        item.isAwakened = true;
        awakenedCount++;
      }
      ownedItems[index] = item;
    }
  }

  /// Replace an item after reforge
  void replaceAfterReforge(LegendaryItem oldItem, LegendaryItem newItem) {
    final index = ownedItems.indexWhere((i) => i.id == oldItem.id);
    if (index >= 0) {
      ownedItems[index] = newItem;
      totalReforges++;
    }
  }
}

/// LegendaryDropChance - Calculates drop chances with pity system
class LegendaryDropChance {
  static const double baseDropRate = 0.05; // 5%
  static const double maxDropRate = 0.25; // 25%
  static const double pityIncrement = 0.01; // +1% per 10 kills
  static const int killsPerIncrement = 10;
  static const double firstBossBonus = 0.10; // 10% for first boss

  /// Calculate drop chance for a boss
  static double calculateDropChance(
    int bossKillsSinceDrop, {
    bool isFirstBoss = false,
  }) {
    if (isFirstBoss) {
      return firstBossBonus;
    }

    final pityBonus = (bossKillsSinceDrop ~/ killsPerIncrement) * pityIncrement;
    return (baseDropRate + pityBonus).clamp(baseDropRate, maxDropRate);
  }

  /// Format drop chance for display
  static String formatDropChance(double chance) {
    return '${(chance * 100).toStringAsFixed(1)}%';
  }
}

/// LegendaryDefinitions - All 20 legendary item definitions
class LegendaryDefinitions {
  static final Map<String, LegendaryItem> _definitions = {};
  static bool _initialized = false;

  /// Initialize all legendary definitions
  static void initialize() {
    if (_initialized) return;

    // WEAPONS (8)

    // 1. Blade of the Dragon King
    _definitions['blade_dragon_king'] = LegendaryItem(
      id: 'blade_dragon_king',
      name: 'Blade of the Dragon King',
      description: 'A blade forged from the scales of an ancient dragon.',
      lore:
          'The dragon\'s rage lives within this blade, hungering for the blood of its kin.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.dragonBane,
        magnitude: 0.50,
        description: '+{magnitude}% damage to dragons',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 25, isPercentage: true),
        StatBonus(statName: 'Strength', value: 15, isPercentage: false),
      ],
      hasSentience: true,
      sentience: SentienceType.killDragons,
      acquiredDate: DateTime.now(),
    );

    // 2. Death's Whisper
    _definitions['deaths_whisper'] = LegendaryItem(
      id: 'deaths_whisper',
      name: 'Death\'s Whisper',
      description: 'A blade that whispers promises of life stolen from others.',
      lore:
          'Death does not speak loudly. It whispers, and those who listen gain its power.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.lifeSteal,
        magnitude: 0.10,
        description: 'Heal for {magnitude}% of damage dealt',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 15, isPercentage: true),
        StatBonus(statName: 'Attack Speed', value: 10, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.killUndead,
      acquiredDate: DateTime.now(),
    );

    // 3. Stormcaller
    _definitions['stormcaller'] = LegendaryItem(
      id: 'stormcaller',
      name: 'Stormcaller',
      description: 'A blade crackling with lightning essence.',
      lore: 'Thunder answers to no one, but this blade commands it.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.elementalDamage,
        magnitude: 0.30,
        description: 'Lightning damage with {magnitude}% chance to stun',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 20, isPercentage: true),
        StatBonus(statName: 'Crit Chance', value: 8, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.killBosses,
      acquiredDate: DateTime.now(),
    );

    // 4. The World Ender
    _definitions['world_ender'] = LegendaryItem(
      id: 'world_ender',
      name: 'The World Ender',
      description: 'A massive blade said to have ended worlds.',
      lore: 'In the hands of a true warrior, even gods fall before this blade.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.bossSlayer,
        magnitude: 0.30,
        description: '+{magnitude}% damage to bosses',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 35, isPercentage: true),
        StatBonus(statName: 'Strength', value: 20, isPercentage: false),
      ],
      hasSentience: false,
      acquiredDate: DateTime.now(),
    );

    // 5. Glass Edge
    _definitions['glass_edge'] = LegendaryItem(
      id: 'glass_edge',
      name: 'Glass Edge',
      description: 'A blade of crystalline beauty and deadly sharpness.',
      lore: 'Beautiful, fragile, and absolutely lethal. Like its wielder.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.glassCannon,
        magnitude: 1.0,
        description: '+100% damage, -30% max HP',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 50, isPercentage: true),
        StatBonus(statName: 'Crit Damage', value: 25, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.surviveCombat,
      acquiredDate: DateTime.now(),
    );

    // 6. Soul Reaver
    _definitions['soul_reaver'] = LegendaryItem(
      id: 'soul_reaver',
      name: 'Soul Reaver',
      description: 'A blade that feeds on the life force of its victims.',
      lore:
          'Your vitality is its strength. The more you have, the more it takes.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.hpToDamage,
        magnitude: 0.1,
        description: '+1 damage per 10 max HP',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 15, isPercentage: true),
        StatBonus(statName: 'Max HP', value: 100, isPercentage: false),
      ],
      hasSentience: true,
      sentience: SentienceType.exploreDeep,
      acquiredDate: DateTime.now(),
    );

    // 7. Chronos Blade
    _definitions['chronos_blade'] = LegendaryItem(
      id: 'chronos_blade',
      name: 'Chronos Blade',
      description: 'A blade that cuts through time itself.',
      lore: 'Time is but another barrier to those who know how to slice it.',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.timeWarp,
        magnitude: 0.20,
        description: '-{magnitude}% cooldown reduction',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 12, isPercentage: true),
        StatBonus(statName: 'Attack Speed', value: 15, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.usePotions,
      acquiredDate: DateTime.now(),
    );

    // 8. Gambler's Ruin
    _definitions['gamblers_ruin'] = LegendaryItem(
      id: 'gamblers_ruin',
      name: 'Gambler\'s Ruin',
      description: 'A blade that gambles with fate itself.',
      lore: 'Fortune favors the bold, and ruins the foolish. Which are you?',
      equipmentType: EquipmentSlotType.weapon,
      effect: LegendaryEffect(
        type: LegendaryEffectType.wishGranter,
        magnitude: 1.0,
        description: 'Random powerful effect each combat',
      ),
      baseStats: [
        StatBonus(statName: 'Damage', value: 20, isPercentage: true),
        StatBonus(statName: 'Luck', value: 15, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.findGold,
      acquiredDate: DateTime.now(),
    );

    // ARMOR (8)

    // 9. Aegis of the Immortal
    _definitions['aegis_immortal'] = LegendaryItem(
      id: 'aegis_immortal',
      name: 'Aegis of the Immortal',
      description: 'A shield that denies death itself.',
      lore: 'Death comes for all. Except those who carry this.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.immortality,
        magnitude: 1.0,
        description: 'Survive one fatal blow per combat',
      ),
      baseStats: [
        StatBonus(statName: 'Armor', value: 40, isPercentage: true),
        StatBonus(statName: 'Max HP', value: 20, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.surviveCombat,
      acquiredDate: DateTime.now(),
    );

    // 10. Dragon Scale Plate
    _definitions['dragon_scale_plate'] = LegendaryItem(
      id: 'dragon_scale_plate',
      name: 'Dragon Scale Plate',
      description: 'Armor forged from the scales of an elder dragon.',
      lore:
          'To wear a dragon\'s scales is to claim its power. Dragons notice such claims.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.defenseBoost,
        magnitude: 0.50,
        description: '+{magnitude}% armor, +30% vs dragons',
      ),
      baseStats: [
        StatBonus(statName: 'Armor', value: 50, isPercentage: true),
        StatBonus(statName: 'Fire Resist', value: 30, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.killDragons,
      acquiredDate: DateTime.now(),
    );

    // 11. Void Shroud
    _definitions['void_shroud'] = LegendaryItem(
      id: 'void_shroud',
      name: 'Void Shroud',
      description: 'Armor that exists partially in the void.',
      lore:
          'The void does not give. It only takes. But sometimes, it takes from your enemies.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.reflectDamage,
        magnitude: 0.20,
        description: 'Reflect {magnitude}% of damage taken',
      ),
      baseStats: [
        StatBonus(statName: 'Armor', value: 30, isPercentage: true),
        StatBonus(statName: 'Evasion', value: 10, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.killBosses,
      acquiredDate: DateTime.now(),
    );

    // 12. Titan's Heart
    _definitions['titans_heart'] = LegendaryItem(
      id: 'titans_heart',
      name: 'Titan\'s Heart',
      description: 'Armor imbued with the essence of ancient titans.',
      lore: 'Titans do not fall. Neither shall you.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.defenseBoost,
        magnitude: 0.40,
        description: '+{magnitude}% max HP',
      ),
      baseStats: [
        StatBonus(statName: 'Max HP', value: 40, isPercentage: true),
        StatBonus(statName: 'Armor', value: 25, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.exploreDeep,
      acquiredDate: DateTime.now(),
    );

    // 13. Crown of the Golden King
    _definitions['crown_golden_king'] = LegendaryItem(
      id: 'crown_golden_king',
      name: 'Crown of the Golden King',
      description: 'A crown that draws wealth to its wearer.',
      lore: 'The Golden King never wanted for coin. His crown saw to that.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.goldMagnet,
        magnitude: 0.50,
        description: '+{magnitude}% gold find',
      ),
      baseStats: [
        StatBonus(statName: 'Armor', value: 15, isPercentage: true),
        StatBonus(statName: 'Charisma', value: 20, isPercentage: false),
      ],
      hasSentience: true,
      sentience: SentienceType.findGold,
      acquiredDate: DateTime.now(),
    );

    // 14. Scholar's Mantle
    _definitions['scholars_mantle'] = LegendaryItem(
      id: 'scholars_mantle',
      name: 'Scholar\'s Mantle',
      description: 'A mantle woven from pages of forbidden tomes.',
      lore:
          'Knowledge is power. This mantle contains more knowledge than most libraries.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.xpMagnet,
        magnitude: 0.50,
        description: '+{magnitude}% XP gain',
      ),
      baseStats: [
        StatBonus(statName: 'Intelligence', value: 25, isPercentage: false),
        StatBonus(statName: 'Armor', value: 10, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.ascend,
      acquiredDate: DateTime.now(),
    );

    // 15. Potion Master's Robes
    _definitions['potion_master_robes'] = LegendaryItem(
      id: 'potion_master_robes',
      name: 'Potion Master\'s Robes',
      description: 'Robes that enhance any potion consumed.',
      lore:
          'The greatest alchemists wore these. Their secrets soaked into the fabric.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.potionMastery,
        magnitude: 0.50,
        description: '+{magnitude}% potion effectiveness',
      ),
      baseStats: [
        StatBonus(statName: 'Armor', value: 12, isPercentage: true),
        StatBonus(statName: 'Wisdom', value: 15, isPercentage: false),
      ],
      hasSentience: true,
      sentience: SentienceType.usePotions,
      acquiredDate: DateTime.now(),
    );

    // 16. Death's Embrace
    _definitions['deaths_embrace'] = LegendaryItem(
      id: 'deaths_embrace',
      name: 'Death\'s Embrace',
      description: 'Armor that turns death into a weapon.',
      lore: 'If you must die, die striking back. Death respects such defiance.',
      equipmentType: EquipmentSlotType.armor,
      effect: LegendaryEffect(
        type: LegendaryEffectType.immortalVengeance,
        magnitude: 0.50,
        description: 'Deal {magnitude}% max HP as damage on death',
      ),
      baseStats: [
        StatBonus(statName: 'Armor', value: 20, isPercentage: true),
        StatBonus(statName: 'Max HP', value: 15, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.surviveCombat,
      acquiredDate: DateTime.now(),
    );

    // JEWELRY (4)

    // 17. Ring of Critical Mastery
    _definitions['ring_critical_mastery'] = LegendaryItem(
      id: 'ring_critical_mastery',
      name: 'Ring of Critical Mastery',
      description: 'A ring that sharpens every strike to perfection.',
      lore: 'Precision is an art. This ring makes you its master.',
      equipmentType: EquipmentSlotType.jewelry,
      effect: LegendaryEffect(
        type: LegendaryEffectType.criticalMastery,
        magnitude: 0.25,
        description: '+{magnitude}% crit chance, +50% crit damage',
      ),
      baseStats: [
        StatBonus(statName: 'Dexterity', value: 15, isPercentage: false),
        StatBonus(statName: 'Crit Chance', value: 12, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.killBosses,
      acquiredDate: DateTime.now(),
    );

    // 18. Amulet of the Summoner
    _definitions['amulet_summoner'] = LegendaryItem(
      id: 'amulet_summoner',
      name: 'Amulet of the Summoner',
      description: 'An amulet that binds shadow allies to your service.',
      lore: 'You are never alone. The shadows answer your call.',
      equipmentType: EquipmentSlotType.jewelry,
      effect: LegendaryEffect(
        type: LegendaryEffectType.summonHelper,
        magnitude: 1.0,
        description: 'Summon a shadow ally in combat',
      ),
      baseStats: [
        StatBonus(statName: 'Intelligence', value: 20, isPercentage: false),
        StatBonus(statName: 'Max HP', value: 10, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.collectSets,
      acquiredDate: DateTime.now(),
    );

    // 19. Band of Elemental Power
    _definitions['band_elemental_power'] = LegendaryItem(
      id: 'band_elemental_power',
      name: 'Band of Elemental Power',
      description: 'A ring that channels elemental fury.',
      lore: 'Fire burns. Ice freezes. Lightning strikes. You command them all.',
      equipmentType: EquipmentSlotType.jewelry,
      effect: LegendaryEffect(
        type: LegendaryEffectType.elementalConversion,
        magnitude: 0.30,
        description: 'Convert damage to fire with burn effect',
      ),
      baseStats: [
        StatBonus(statName: 'Intelligence', value: 15, isPercentage: false),
        StatBonus(statName: 'Damage', value: 15, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.enchantItems,
      acquiredDate: DateTime.now(),
    );

    // 20. Chronostone Pendant
    _definitions['chronostone_pendant'] = LegendaryItem(
      id: 'chronostone_pendant',
      name: 'Chronostone Pendant',
      description: 'A pendant that bends time around its wearer.',
      lore: 'Time flows differently for those who wear the Chronostone.',
      equipmentType: EquipmentSlotType.jewelry,
      effect: LegendaryEffect(
        type: LegendaryEffectType.timeWarp,
        magnitude: 0.30,
        description: '-{magnitude}% all cooldowns',
      ),
      baseStats: [
        StatBonus(statName: 'Wisdom', value: 20, isPercentage: false),
        StatBonus(statName: 'Attack Speed', value: 12, isPercentage: true),
      ],
      hasSentience: true,
      sentience: SentienceType.ascend,
      acquiredDate: DateTime.now(),
    );

    _initialized = true;
  }

  /// Get a legendary definition by ID
  static LegendaryItem? getDefinition(String id) {
    if (!_initialized) initialize();
    return _definitions[id];
  }

  /// Get all legendary definitions
  static List<LegendaryItem> get allDefinitions {
    if (!_initialized) initialize();
    return _definitions.values.toList();
  }

  /// Get definitions by equipment type
  static List<LegendaryItem> getByType(EquipmentSlotType type) {
    if (!_initialized) initialize();
    return _definitions.values.where((d) => d.equipmentType == type).toList();
  }

  /// Get random legendary definition
  static LegendaryItem getRandom(Random random, {EquipmentSlotType? type}) {
    if (!_initialized) initialize();

    List<LegendaryItem> candidates;
    if (type != null) {
      candidates = getByType(type);
    } else {
      candidates = allDefinitions;
    }

    return candidates[random.nextInt(candidates.length)];
  }

  /// Create an instance from a definition
  static LegendaryItem createInstance(String id, int floor, Random random) {
    if (!_initialized) initialize();

    final definition = _definitions[id]!;

    // Generate base stats based on floor and reforge count (0 for new drops)
    final stats = _generateBaseStats(
      definition.equipmentType,
      floor,
      random,
      0,
    );

    return LegendaryItem(
      id: definition.id,
      name: definition.name,
      description: definition.description,
      lore: definition.lore,
      equipmentType: definition.equipmentType,
      effect: LegendaryEffect(
        type: definition.effect.type,
        magnitude: definition.effect.magnitude,
        description: definition.effect.description,
        isPassive: definition.effect.isPassive,
        isTriggered: definition.effect.isTriggered,
        triggerCondition: definition.effect.triggerCondition,
      ),
      baseStats: stats,
      hasSentience: definition.hasSentience,
      sentience: definition.sentience,
      sentienceProgress: 0,
      isAwakened: false,
      reforgeCount: 0,
      acquiredDate: DateTime.now(),
      acquiredFloor: floor,
    );
  }

  /// Generate base stats for a legendary item
  static List<StatBonus> _generateBaseStats(
    EquipmentSlotType type,
    int floor,
    Random random,
    int reforgeCount,
  ) {
    final stats = <StatBonus>[];
    final baseMultiplier = 1.0 + (floor / 50.0); // Scale with floor
    final reforgeBonus =
        reforgeCount * 0.05; // Each reforge improves stats by 5%

    switch (type) {
      case EquipmentSlotType.weapon:
        stats.add(
          StatBonus(
            statName: 'Damage',
            value:
                (15.0 + random.nextDouble() * 15.0) *
                baseMultiplier *
                (1 + reforgeBonus),
            isPercentage: true,
          ),
        );
        stats.add(
          StatBonus(
            statName: random.nextBool() ? 'Crit Chance' : 'Attack Speed',
            value: (5.0 + random.nextDouble() * 10.0) * (1 + reforgeBonus),
            isPercentage: true,
          ),
        );
        break;
      case EquipmentSlotType.armor:
        stats.add(
          StatBonus(
            statName: 'Armor',
            value:
                (20.0 + random.nextDouble() * 20.0) *
                baseMultiplier *
                (1 + reforgeBonus),
            isPercentage: true,
          ),
        );
        stats.add(
          StatBonus(
            statName: random.nextBool() ? 'Max HP' : 'Evasion',
            value: (10.0 + random.nextDouble() * 15.0) * (1 + reforgeBonus),
            isPercentage: true,
          ),
        );
        break;
      case EquipmentSlotType.jewelry:
        stats.add(
          StatBonus(
            statName: [
              'Strength',
              'Dexterity',
              'Intelligence',
              'Wisdom',
            ][random.nextInt(4)],
            value:
                (10.0 + random.nextDouble() * 15.0) *
                baseMultiplier *
                (1 + reforgeBonus),
            isPercentage: false,
          ),
        );
        stats.add(
          StatBonus(
            statName: random.nextBool() ? 'Gold Find' : 'XP Gain',
            value: (5.0 + random.nextDouble() * 10.0) * (1 + reforgeBonus),
            isPercentage: true,
          ),
        );
        break;
    }

    return stats;
  }

  /// Generate new stats for reforge
  static List<StatBonus> generateReforgeStats(
    EquipmentSlotType type,
    int originalFloor,
    Random random,
    int newReforgeCount,
  ) {
    return _generateBaseStats(type, originalFloor, random, newReforgeCount);
  }
}
