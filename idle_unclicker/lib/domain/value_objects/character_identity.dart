/// Value object representing a unique character identifier
/// Immutable and based on UUID string
class CharacterId {
  final String value;

  const CharacterId._(this.value);

  /// Creates a CharacterId from a string
  /// Validates that it's not empty
  factory CharacterId(String value) {
    if (value.isEmpty) {
      throw ArgumentError('CharacterId cannot be empty');
    }
    return CharacterId._(value);
  }

  /// Creates a CharacterId from character name and creation timestamp
  factory CharacterId.fromNameAndTime(String name, DateTime createdAt) {
    return CharacterId('${name}_${createdAt.millisecondsSinceEpoch}');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CharacterId($value)';
}

/// Value object representing character identity info
class CharacterIdentity {
  final String name;
  final String race;
  final String characterClass;

  CharacterIdentity({
    required this.name,
    required this.race,
    required this.characterClass,
  }) {
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
    if (race.isEmpty) throw ArgumentError('Race cannot be empty');
    if (characterClass.isEmpty) throw ArgumentError('Class cannot be empty');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterIdentity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          race == other.race &&
          characterClass == other.characterClass;

  @override
  int get hashCode => name.hashCode ^ race.hashCode ^ characterClass.hashCode;

  @override
  String toString() => '$name the $race $characterClass';
}
