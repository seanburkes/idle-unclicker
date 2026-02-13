/// Base class for all domain events
abstract class DomainEvent {
  final DateTime occurredAt;
  final String eventType;

  DomainEvent({DateTime? occurredAt, required this.eventType})
    : occurredAt = occurredAt ?? DateTime.now();

  Map<String, dynamic> toJson();
}

/// Event emitted when character takes damage
class CharacterDamaged extends DomainEvent {
  final String characterId;
  final int damage;
  final int currentHealth;
  final int maxHealth;

  CharacterDamaged({
    required this.characterId,
    required this.damage,
    required this.currentHealth,
    required this.maxHealth,
    DateTime? occurredAt,
  }) : super(eventType: 'CharacterDamaged', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'damage': damage,
    'currentHealth': currentHealth,
    'maxHealth': maxHealth,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when character dies
class CharacterDied extends DomainEvent {
  final String characterId;
  final int totalDeaths;

  CharacterDied({
    required this.characterId,
    required this.totalDeaths,
    DateTime? occurredAt,
  }) : super(eventType: 'CharacterDied', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'totalDeaths': totalDeaths,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when character gains experience
class ExperienceGained extends DomainEvent {
  final String characterId;
  final double amount;
  final double currentExp;
  final double expToNextLevel;

  ExperienceGained({
    required this.characterId,
    required this.amount,
    required this.currentExp,
    required this.expToNextLevel,
    DateTime? occurredAt,
  }) : super(eventType: 'ExperienceGained', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'amount': amount,
    'currentExp': currentExp,
    'expToNextLevel': expToNextLevel,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when character levels up
class CharacterLeveledUp extends DomainEvent {
  final String characterId;
  final int newLevel;
  final int unallocatedPoints;

  CharacterLeveledUp({
    required this.characterId,
    required this.newLevel,
    required this.unallocatedPoints,
    DateTime? occurredAt,
  }) : super(eventType: 'CharacterLeveledUp', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'newLevel': newLevel,
    'unallocatedPoints': unallocatedPoints,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when character heals
class CharacterHealed extends DomainEvent {
  final String characterId;
  final int amount;
  final int currentHealth;
  final int maxHealth;

  CharacterHealed({
    required this.characterId,
    required this.amount,
    required this.currentHealth,
    required this.maxHealth,
    DateTime? occurredAt,
  }) : super(eventType: 'CharacterHealed', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'amount': amount,
    'currentHealth': currentHealth,
    'maxHealth': maxHealth,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when skill XP is gained
class SkillExperienceGained extends DomainEvent {
  final String characterId;
  final String skillName;
  final int amount;
  final int currentSkillXP;
  final int currentSkillLevel;

  SkillExperienceGained({
    required this.characterId,
    required this.skillName,
    required this.amount,
    required this.currentSkillXP,
    required this.currentSkillLevel,
    DateTime? occurredAt,
  }) : super(eventType: 'SkillExperienceGained', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'skillName': skillName,
    'amount': amount,
    'currentSkillXP': currentSkillXP,
    'currentSkillLevel': currentSkillLevel,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when skill levels up
class SkillLeveledUp extends DomainEvent {
  final String characterId;
  final String skillName;
  final int newLevel;

  SkillLeveledUp({
    required this.characterId,
    required this.skillName,
    required this.newLevel,
    DateTime? occurredAt,
  }) : super(eventType: 'SkillLeveledUp', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'skillName': skillName,
    'newLevel': newLevel,
    'occurredAt': occurredAt.toIso8601String(),
  };
}
