/// Value object representing character ability scores
/// Uses D&D style 3d6-based stats with racial modifiers
/// Invariants: All stats between 3 and 18
class CharacterStats {
  final int strength;
  final int dexterity;
  final int intelligence;
  final int constitution;
  final int wisdom;
  final int charisma;

  const CharacterStats({
    required this.strength,
    required this.dexterity,
    required this.intelligence,
    required this.constitution,
    required this.wisdom,
    required this.charisma,
  }) : assert(strength >= 3 && strength <= 18, 'Strength must be 3-18'),
       assert(dexterity >= 3 && dexterity <= 18, 'Dexterity must be 3-18'),
       assert(
         intelligence >= 3 && intelligence <= 18,
         'Intelligence must be 3-18',
       ),
       assert(
         constitution >= 3 && constitution <= 18,
         'Constitution must be 3-18',
       ),
       assert(wisdom >= 3 && wisdom <= 18, 'Wisdom must be 3-18'),
       assert(charisma >= 3 && charisma <= 18, 'Charisma must be 3-18');

  /// Creates default average stats (all 10s)
  factory CharacterStats.average() => const CharacterStats(
    strength: 10,
    dexterity: 10,
    intelligence: 10,
    constitution: 10,
    wisdom: 10,
    charisma: 10,
  );

  /// Calculates HP bonus from constitution
  /// D&D style: (CON - 10) / 2
  int get constitutionBonus => (constitution - 10) ~/ 2;

  /// Calculates max mana based on INT + WIS
  int get baseMaxMana => intelligence + wisdom;

  /// Calculates attack power from strength
  int get baseAttackPower => strength ~/ 3;

  /// Calculates defense from constitution
  int get baseDefense => constitution ~/ 4;

  /// Allocates a point to a stat
  /// Returns null if stat already at max (18)
  CharacterStats? allocatePoint(String stat) {
    switch (stat.toLowerCase()) {
      case 'strength':
      case 'str':
        if (strength >= 18) return null;
        return CharacterStats(
          strength: strength + 1,
          dexterity: dexterity,
          intelligence: intelligence,
          constitution: constitution,
          wisdom: wisdom,
          charisma: charisma,
        );
      case 'dexterity':
      case 'dex':
        if (dexterity >= 18) return null;
        return CharacterStats(
          strength: strength,
          dexterity: dexterity + 1,
          intelligence: intelligence,
          constitution: constitution,
          wisdom: wisdom,
          charisma: charisma,
        );
      case 'intelligence':
      case 'int':
        if (intelligence >= 18) return null;
        return CharacterStats(
          strength: strength,
          dexterity: dexterity,
          intelligence: intelligence + 1,
          constitution: constitution,
          wisdom: wisdom,
          charisma: charisma,
        );
      case 'constitution':
      case 'con':
        if (constitution >= 18) return null;
        return CharacterStats(
          strength: strength,
          dexterity: dexterity,
          intelligence: intelligence,
          constitution: constitution + 1,
          wisdom: wisdom,
          charisma: charisma,
        );
      case 'wisdom':
      case 'wis':
        if (wisdom >= 18) return null;
        return CharacterStats(
          strength: strength,
          dexterity: dexterity,
          intelligence: intelligence,
          constitution: constitution,
          wisdom: wisdom + 1,
          charisma: charisma,
        );
      case 'charisma':
      case 'cha':
        if (charisma >= 18) return null;
        return CharacterStats(
          strength: strength,
          dexterity: dexterity,
          intelligence: intelligence,
          constitution: constitution,
          wisdom: wisdom,
          charisma: charisma + 1,
        );
      default:
        return null;
    }
  }

  /// Racial modifiers for character creation
  static Map<String, int> getRaceModifiers(String race) {
    final modifiers = {
      'Human': {'str': 0, 'dex': 0, 'con': 0, 'int': 0, 'wis': 0, 'cha': 0},
      'Elf': {'str': -1, 'dex': 2, 'con': -1, 'int': 1, 'wis': 0, 'cha': 1},
      'Dwarf': {'str': 1, 'dex': -1, 'con': 2, 'int': 0, 'wis': 1, 'cha': -1},
      'Halfling': {'str': -2, 'dex': 2, 'con': 0, 'int': 0, 'wis': 0, 'cha': 1},
      'Orc': {'str': 2, 'dex': 0, 'con': 1, 'int': -2, 'wis': 0, 'cha': -1},
    };
    return modifiers[race] ?? modifiers['Human']!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterStats &&
          runtimeType == other.runtimeType &&
          strength == other.strength &&
          dexterity == other.dexterity &&
          intelligence == other.intelligence &&
          constitution == other.constitution &&
          wisdom == other.wisdom &&
          charisma == other.charisma;

  @override
  int get hashCode =>
      strength.hashCode ^
      dexterity.hashCode ^
      intelligence.hashCode ^
      constitution.hashCode ^
      wisdom.hashCode ^
      charisma.hashCode;

  @override
  String toString() =>
      'Stats(STR:$strength, DEX:$dexterity, INT:$intelligence, CON:$constitution, WIS:$wisdom, CHA:$charisma)';

  /// Converts to map for serialization
  Map<String, int> toMap() => {
    'strength': strength,
    'dexterity': dexterity,
    'intelligence': intelligence,
    'constitution': constitution,
    'wisdom': wisdom,
    'charisma': charisma,
  };

  /// Creates from map
  factory CharacterStats.fromMap(Map<String, dynamic> map) => CharacterStats(
    strength: map['strength'] ?? 10,
    dexterity: map['dexterity'] ?? 10,
    intelligence: map['intelligence'] ?? 10,
    constitution: map['constitution'] ?? 10,
    wisdom: map['wisdom'] ?? 10,
    charisma: map['charisma'] ?? 10,
  );
}
