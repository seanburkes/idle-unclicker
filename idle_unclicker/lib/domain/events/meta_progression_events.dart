import 'character_events.dart';

/// Event emitted when an interaction is recorded
class InteractionRecorded extends DomainEvent {
  final String gameStateId;
  final int totalInteractions;

  InteractionRecorded({
    required this.gameStateId,
    required this.totalInteractions,
    DateTime? occurredAt,
  }) : super(eventType: 'InteractionRecorded', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'totalInteractions': totalInteractions,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when focus is updated
class FocusUpdated extends DomainEvent {
  final String gameStateId;
  final double oldFocus;
  final double newFocus;

  FocusUpdated({
    required this.gameStateId,
    required this.oldFocus,
    required this.newFocus,
    DateTime? occurredAt,
  }) : super(eventType: 'FocusUpdated', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'oldFocus': oldFocus,
    'newFocus': newFocus,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when zen streak is updated
class ZenStreakUpdated extends DomainEvent {
  final String gameStateId;
  final int oldStreak;
  final int newStreak;
  final bool maintained;

  ZenStreakUpdated({
    required this.gameStateId,
    required this.oldStreak,
    required this.newStreak,
    required this.maintained,
    DateTime? occurredAt,
  }) : super(eventType: 'ZenStreakUpdated', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'oldStreak': oldStreak,
    'newStreak': newStreak,
    'maintained': maintained,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when ascension is performed
class AscensionPerformed extends DomainEvent {
  final String gameStateId;
  final String characterId;
  final int ascensionNumber;
  final int echoShardsGained;
  final int totalEchoShards;
  final List<String> newRacesUnlocked;
  final List<String> newClassesUnlocked;

  AscensionPerformed({
    required this.gameStateId,
    required this.characterId,
    required this.ascensionNumber,
    required this.echoShardsGained,
    required this.totalEchoShards,
    this.newRacesUnlocked = const [],
    this.newClassesUnlocked = const [],
    DateTime? occurredAt,
  }) : super(eventType: 'AscensionPerformed', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'characterId': characterId,
    'ascensionNumber': ascensionNumber,
    'echoShardsGained': echoShardsGained,
    'totalEchoShards': totalEchoShards,
    'newRacesUnlocked': newRacesUnlocked,
    'newClassesUnlocked': newClassesUnlocked,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when a meta-upgrade is purchased
class MetaUpgradePurchased extends DomainEvent {
  final String gameStateId;
  final String upgradeType;
  final int newLevel;
  final int cost;
  final int remainingShards;

  MetaUpgradePurchased({
    required this.gameStateId,
    required this.upgradeType,
    required this.newLevel,
    required this.cost,
    required this.remainingShards,
    DateTime? occurredAt,
  }) : super(eventType: 'MetaUpgradePurchased', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'upgradeType': upgradeType,
    'newLevel': newLevel,
    'cost': cost,
    'remainingShards': remainingShards,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when Guild Hall is unlocked
class GuildHallUnlocked extends DomainEvent {
  final String gameStateId;
  final int ascensionNumber;

  GuildHallUnlocked({
    required this.gameStateId,
    required this.ascensionNumber,
    DateTime? occurredAt,
  }) : super(eventType: 'GuildHallUnlocked', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'ascensionNumber': ascensionNumber,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when a Guild Hall room is upgraded
class RoomUpgraded extends DomainEvent {
  final String gameStateId;
  final String roomType;
  final int oldLevel;
  final int newLevel;
  final int cost;

  RoomUpgraded({
    required this.gameStateId,
    required this.roomType,
    required this.oldLevel,
    required this.newLevel,
    required this.cost,
    DateTime? occurredAt,
  }) : super(eventType: 'RoomUpgraded', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'roomType': roomType,
    'oldLevel': oldLevel,
    'newLevel': newLevel,
    'cost': cost,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when an Echo NPC is created
class EchoNPCCreated extends DomainEvent {
  final String gameStateId;
  final String echoName;
  final String race;
  final String characterClass;
  final int level;
  final String fate;

  EchoNPCCreated({
    required this.gameStateId,
    required this.echoName,
    required this.race,
    required this.characterClass,
    required this.level,
    required this.fate,
    DateTime? occurredAt,
  }) : super(eventType: 'EchoNPCCreated', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'echoName': echoName,
    'race': race,
    'characterClass': characterClass,
    'level': level,
    'fate': fate,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when a race is unlocked
class RaceUnlocked extends DomainEvent {
  final String gameStateId;
  final String raceName;
  final int requiredAscensions;

  RaceUnlocked({
    required this.gameStateId,
    required this.raceName,
    required this.requiredAscensions,
    DateTime? occurredAt,
  }) : super(eventType: 'RaceUnlocked', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'raceName': raceName,
    'requiredAscensions': requiredAscensions,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when a class is unlocked
class ClassUnlocked extends DomainEvent {
  final String gameStateId;
  final String className;
  final int requiredAscensions;

  ClassUnlocked({
    required this.gameStateId,
    required this.className,
    required this.requiredAscensions,
    DateTime? occurredAt,
  }) : super(eventType: 'ClassUnlocked', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'gameStateId': gameStateId,
    'className': className,
    'requiredAscensions': requiredAscensions,
    'occurredAt': occurredAt.toIso8601String(),
  };
}
