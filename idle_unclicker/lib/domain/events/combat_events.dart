import '../events/character_events.dart';

/// Event emitted when combat begins
class CombatStarted extends DomainEvent {
  final String characterId;
  final String? monsterName;
  final int monsterLevel;
  final int dungeonDepth;

  CombatStarted({
    required this.characterId,
    this.monsterName,
    required this.monsterLevel,
    required this.dungeonDepth,
    DateTime? occurredAt,
  }) : super(eventType: 'CombatStarted', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'monsterName': monsterName,
    'monsterLevel': monsterLevel,
    'dungeonDepth': dungeonDepth,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when player attacks monster
class PlayerAttacked extends DomainEvent {
  final String characterId;
  final int damageDealt;
  final bool wasCritical;
  final int monsterHealthRemaining;

  PlayerAttacked({
    required this.characterId,
    required this.damageDealt,
    required this.wasCritical,
    required this.monsterHealthRemaining,
    DateTime? occurredAt,
  }) : super(eventType: 'PlayerAttacked', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'damageDealt': damageDealt,
    'wasCritical': wasCritical,
    'monsterHealthRemaining': monsterHealthRemaining,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when monster attacks player
class MonsterAttacked extends DomainEvent {
  final String characterId;
  final String monsterName;
  final int damageDealt;
  final int playerHealthRemaining;

  MonsterAttacked({
    required this.characterId,
    required this.monsterName,
    required this.damageDealt,
    required this.playerHealthRemaining,
    DateTime? occurredAt,
  }) : super(eventType: 'MonsterAttacked', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'monsterName': monsterName,
    'damageDealt': damageDealt,
    'playerHealthRemaining': playerHealthRemaining,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when player flees from combat
class CombatFled extends DomainEvent {
  final String characterId;
  final String reason;
  final int healthRemaining;

  CombatFled({
    required this.characterId,
    required this.reason,
    required this.healthRemaining,
    DateTime? occurredAt,
  }) : super(eventType: 'CombatFled', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'reason': reason,
    'healthRemaining': healthRemaining,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when monster is defeated
class MonsterDefeated extends DomainEvent {
  final String characterId;
  final String monsterName;
  final int xpGained;
  final int goldGained;
  final int dungeonDepth;

  MonsterDefeated({
    required this.characterId,
    required this.monsterName,
    required this.xpGained,
    required this.goldGained,
    required this.dungeonDepth,
    DateTime? occurredAt,
  }) : super(eventType: 'MonsterDefeated', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'monsterName': monsterName,
    'xpGained': xpGained,
    'goldGained': goldGained,
    'dungeonDepth': dungeonDepth,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when player uses health potion in combat
class PotionUsedInCombat extends DomainEvent {
  final String characterId;
  final int healAmount;
  final int healthAfter;
  final int potionsRemaining;

  PotionUsedInCombat({
    required this.characterId,
    required this.healAmount,
    required this.healthAfter,
    required this.potionsRemaining,
    DateTime? occurredAt,
  }) : super(eventType: 'PotionUsedInCombat', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'healAmount': healAmount,
    'healthAfter': healthAfter,
    'potionsRemaining': potionsRemaining,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when loot is found after combat
class LootFound extends DomainEvent {
  final String characterId;
  final String itemName;
  final int itemLevel;
  final int rarity;

  LootFound({
    required this.characterId,
    required this.itemName,
    required this.itemLevel,
    required this.rarity,
    DateTime? occurredAt,
  }) : super(eventType: 'LootFound', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'itemName': itemName,
    'itemLevel': itemLevel,
    'rarity': rarity,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when character rests after combat
class CharacterRested extends DomainEvent {
  final String characterId;
  final int healthRegained;
  final int healthAfter;

  CharacterRested({
    required this.characterId,
    required this.healthRegained,
    required this.healthAfter,
    DateTime? occurredAt,
  }) : super(eventType: 'CharacterRested', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'healthRegained': healthRegained,
    'healthAfter': healthAfter,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when character returns to town
class ReturnedToTown extends DomainEvent {
  final String characterId;
  final String reason;
  final int dungeonDepth;

  ReturnedToTown({
    required this.characterId,
    required this.reason,
    required this.dungeonDepth,
    DateTime? occurredAt,
  }) : super(eventType: 'ReturnedToTown', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'characterId': characterId,
    'reason': reason,
    'dungeonDepth': dungeonDepth,
    'occurredAt': occurredAt.toIso8601String(),
  };
}
