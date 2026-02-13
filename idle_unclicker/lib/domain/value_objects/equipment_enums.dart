/// Enum representing equipment slots
enum EquipmentSlot {
  head,
  shoulders,
  chest,
  gloves,
  pants,
  feet,
  mainHand,
  offHand,
  // Fun slots
  knees,
  toes,
  eyes,
  ears,
  mouth,
  nose,
}

/// Extension to get slot display names
extension EquipmentSlotExtension on EquipmentSlot {
  String get displayName {
    switch (this) {
      case EquipmentSlot.head:
        return 'Head';
      case EquipmentSlot.shoulders:
        return 'Shoulders';
      case EquipmentSlot.chest:
        return 'Chest';
      case EquipmentSlot.gloves:
        return 'Gloves';
      case EquipmentSlot.pants:
        return 'Pants';
      case EquipmentSlot.feet:
        return 'Feet';
      case EquipmentSlot.mainHand:
        return 'Main Hand';
      case EquipmentSlot.offHand:
        return 'Off Hand';
      case EquipmentSlot.knees:
        return 'Knees';
      case EquipmentSlot.toes:
        return 'Toes';
      case EquipmentSlot.eyes:
        return 'Eyes';
      case EquipmentSlot.ears:
        return 'Ears';
      case EquipmentSlot.mouth:
        return 'Mouth';
      case EquipmentSlot.nose:
        return 'Nose';
    }
  }

  bool get isPrimary {
    return [
      EquipmentSlot.head,
      EquipmentSlot.shoulders,
      EquipmentSlot.chest,
      EquipmentSlot.gloves,
      EquipmentSlot.pants,
      EquipmentSlot.feet,
      EquipmentSlot.mainHand,
      EquipmentSlot.offHand,
    ].contains(this);
  }

  bool get isWeapon =>
      this == EquipmentSlot.mainHand || this == EquipmentSlot.offHand;
  bool get isArmor => !isWeapon && isPrimary;
}

/// Enum representing equipment rarity tiers
enum EquipmentRarity {
  common, // 1 star, white
  uncommon, // 2 stars, green
  rare, // 3 stars, blue
  epic, // 4 stars, purple
  legendary, // 5 stars, orange
}

/// Extension for rarity properties
extension EquipmentRarityExtension on EquipmentRarity {
  int get starCount {
    switch (this) {
      case EquipmentRarity.common:
        return 1;
      case EquipmentRarity.uncommon:
        return 2;
      case EquipmentRarity.rare:
        return 3;
      case EquipmentRarity.epic:
        return 4;
      case EquipmentRarity.legendary:
        return 5;
    }
  }

  String get displayName {
    switch (this) {
      case EquipmentRarity.common:
        return 'Common';
      case EquipmentRarity.uncommon:
        return 'Uncommon';
      case EquipmentRarity.rare:
        return 'Rare';
      case EquipmentRarity.epic:
        return 'Epic';
      case EquipmentRarity.legendary:
        return 'Legendary';
    }
  }

  /// Number of gem sockets based on rarity
  int get socketCount {
    // Common=0, Uncommon=1, Rare=2, Epic=3, Legendary=4
    return starCount - 1;
  }

  bool get canBeEnchanted => this != EquipmentRarity.common;
  bool get isLegendary => this == EquipmentRarity.legendary;
}

/// Value object representing equipment bonuses
class EquipmentStats {
  final int attack;
  final int defense;
  final int health;
  final int mana;

  const EquipmentStats({
    this.attack = 0,
    this.defense = 0,
    this.health = 0,
    this.mana = 0,
  });

  factory EquipmentStats.empty() => const EquipmentStats();

  EquipmentStats operator +(EquipmentStats other) {
    return EquipmentStats(
      attack: attack + other.attack,
      defense: defense + other.defense,
      health: health + other.health,
      mana: mana + other.mana,
    );
  }

  int get totalStats => attack + defense + health + mana;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentStats &&
          runtimeType == other.runtimeType &&
          attack == other.attack &&
          defense == other.defense &&
          health == other.health &&
          mana == other.mana;

  @override
  int get hashCode =>
      attack.hashCode ^ defense.hashCode ^ health.hashCode ^ mana.hashCode;

  @override
  String toString() =>
      'EquipmentStats(ATK:$attack, DEF:$defense, HP:$health, MP:$mana)';
}

/// Value object representing a gem socket
class GemSocket {
  final bool isFilled;
  final Gem? gem;

  const GemSocket({this.isFilled = false, this.gem});

  factory GemSocket.empty() => const GemSocket();

  factory GemSocket.filled(Gem gem) => GemSocket(isFilled: true, gem: gem);

  GemSocket insertGem(Gem gem) {
    if (isFilled) throw StateError('Socket already filled');
    return GemSocket.filled(gem);
  }

  GemSocket removeGem() {
    if (!isFilled) throw StateError('Socket is empty');
    return GemSocket.empty();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GemSocket &&
          runtimeType == other.runtimeType &&
          isFilled == other.isFilled &&
          gem == other.gem;

  @override
  int get hashCode => isFilled.hashCode ^ (gem?.hashCode ?? 0);
}

/// Value object representing a gem
class Gem {
  final String name;
  final GemType type;
  final int tier; // 1-5

  const Gem({required this.name, required this.type, required this.tier})
    : assert(tier >= 1 && tier <= 5, 'Gem tier must be 1-5');

  EquipmentStats get bonus {
    final multiplier = tier;
    switch (type) {
      case GemType.ruby:
        return EquipmentStats(attack: 2 * multiplier);
      case GemType.sapphire:
        return EquipmentStats(defense: 2 * multiplier);
      case GemType.emerald:
        return EquipmentStats(health: 5 * multiplier);
      case GemType.amethyst:
        return EquipmentStats(mana: 3 * multiplier);
      case GemType.diamond:
        return EquipmentStats(
          attack: multiplier,
          defense: multiplier,
          health: multiplier * 2,
          mana: multiplier,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          tier == other.tier;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ tier.hashCode;

  @override
  String toString() => 'Gem($name, ${type.name}, T$tier)';
}

/// Enum representing gem types
enum GemType {
  ruby, // Attack
  sapphire, // Defense
  emerald, // Health
  amethyst, // Mana
  diamond, // All stats
}

/// Extension for gem type properties
extension GemTypeExtension on GemType {
  String get displayName {
    switch (this) {
      case GemType.ruby:
        return 'Ruby';
      case GemType.sapphire:
        return 'Sapphire';
      case GemType.emerald:
        return 'Emerald';
      case GemType.amethyst:
        return 'Amethyst';
      case GemType.diamond:
        return 'Diamond';
    }
  }

  String get statName {
    switch (this) {
      case GemType.ruby:
        return 'Attack';
      case GemType.sapphire:
        return 'Defense';
      case GemType.emerald:
        return 'Health';
      case GemType.amethyst:
        return 'Mana';
      case GemType.diamond:
        return 'All Stats';
    }
  }
}
