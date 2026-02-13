import 'character_events.dart';

/// Event emitted when equipment is equipped
class EquipmentEquipped extends DomainEvent {
  final String equipmentId;
  final String characterId;
  final String slot;
  final String equipmentName;

  EquipmentEquipped({
    required this.equipmentId,
    required this.characterId,
    required this.slot,
    required this.equipmentName,
    DateTime? occurredAt,
  }) : super(eventType: 'EquipmentEquipped', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'characterId': characterId,
    'slot': slot,
    'equipmentName': equipmentName,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when equipment is unequipped
class EquipmentUnequipped extends DomainEvent {
  final String equipmentId;
  final String characterId;
  final String slot;

  EquipmentUnequipped({
    required this.equipmentId,
    required this.characterId,
    required this.slot,
    DateTime? occurredAt,
  }) : super(eventType: 'EquipmentUnequipped', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'characterId': characterId,
    'slot': slot,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when a gem is inserted into equipment
class GemInserted extends DomainEvent {
  final String equipmentId;
  final int socketIndex;
  final String gemName;
  final String gemType;

  GemInserted({
    required this.equipmentId,
    required this.socketIndex,
    required this.gemName,
    required this.gemType,
    DateTime? occurredAt,
  }) : super(eventType: 'GemInserted', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'socketIndex': socketIndex,
    'gemName': gemName,
    'gemType': gemType,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when a gem is removed from equipment
class GemRemoved extends DomainEvent {
  final String equipmentId;
  final int socketIndex;
  final String gemName;

  GemRemoved({
    required this.equipmentId,
    required this.socketIndex,
    required this.gemName,
    DateTime? occurredAt,
  }) : super(eventType: 'GemRemoved', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'socketIndex': socketIndex,
    'gemName': gemName,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when equipment is upgraded
class EquipmentUpgraded extends DomainEvent {
  final String equipmentId;
  final int oldLevel;
  final int newLevel;

  EquipmentUpgraded({
    required this.equipmentId,
    required this.oldLevel,
    required this.newLevel,
    DateTime? occurredAt,
  }) : super(eventType: 'EquipmentUpgraded', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'oldLevel': oldLevel,
    'newLevel': newLevel,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when equipment is sold
class EquipmentSold extends DomainEvent {
  final String equipmentId;
  final String equipmentName;
  final int sellPrice;
  final String characterId;

  EquipmentSold({
    required this.equipmentId,
    required this.equipmentName,
    required this.sellPrice,
    required this.characterId,
    DateTime? occurredAt,
  }) : super(eventType: 'EquipmentSold', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'equipmentName': equipmentName,
    'sellPrice': sellPrice,
    'characterId': characterId,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

/// Event emitted when equipment is added to inventory
class EquipmentAddedToInventory extends DomainEvent {
  final String equipmentId;
  final String equipmentName;
  final String characterId;

  EquipmentAddedToInventory({
    required this.equipmentId,
    required this.equipmentName,
    required this.characterId,
    DateTime? occurredAt,
  }) : super(eventType: 'EquipmentAddedToInventory', occurredAt: occurredAt);

  @override
  Map<String, dynamic> toJson() => {
    'eventType': eventType,
    'equipmentId': equipmentId,
    'equipmentName': equipmentName,
    'characterId': characterId,
    'occurredAt': occurredAt.toIso8601String(),
  };
}
