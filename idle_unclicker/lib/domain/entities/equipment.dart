import 'aggregate_root.dart';
import '../events/equipment_events.dart';
import '../value_objects/equipment_enums.dart';

/// Unique identifier for equipment items
class EquipmentId {
  final String value;

  const EquipmentId._(this.value);

  factory EquipmentId(String value) {
    if (value.isEmpty) throw ArgumentError('EquipmentId cannot be empty');
    return EquipmentId._(value);
  }

  factory EquipmentId.generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return EquipmentId('${timestamp}_$random');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EquipmentId($value)';
}

/// Aggregate Root: Equipment
///
/// Represents a piece of equipment that can be equipped by a character.
/// Enforces equipment invariants and manages socket state.
class Equipment extends AggregateRoot {
  final EquipmentId id;
  String name;
  final EquipmentSlot slot;
  EquipmentRarity rarity;
  int itemLevel;
  EquipmentStats baseStats;
  List<GemSocket> sockets;
  bool isEquipped;
  String? equippedByCharacterId;

  Equipment({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    this.itemLevel = 1,
    required this.baseStats,
    List<GemSocket>? sockets,
    this.isEquipped = false,
    this.equippedByCharacterId,
  }) : sockets = sockets ?? _createEmptySockets(rarity.socketCount);

  /// Factory method to create new equipment
  factory Equipment.create({
    required String name,
    required EquipmentSlot slot,
    required EquipmentRarity rarity,
    int itemLevel = 1,
    EquipmentStats? baseStats,
  }) {
    return Equipment(
      id: EquipmentId.generate(),
      name: name,
      slot: slot,
      rarity: rarity,
      itemLevel: itemLevel,
      baseStats: baseStats ?? _generateBaseStats(slot, rarity, itemLevel),
    );
  }

  /// Creates empty equipment for a slot
  factory Equipment.empty(EquipmentSlot slot) {
    return Equipment(
      id: EquipmentId('empty_${slot.name}'),
      name: 'None',
      slot: slot,
      rarity: EquipmentRarity.common,
      itemLevel: 0,
      baseStats: EquipmentStats.empty(),
      sockets: [],
    );
  }

  // === Domain Behaviors ===

  /// Calculates total stats including gems
  EquipmentStats get totalStats {
    var total = baseStats;
    for (final socket in sockets) {
      if (socket.isFilled && socket.gem != null) {
        total = total + socket.gem!.bonus;
      }
    }
    return total;
  }

  /// Equips this item to a character
  void equip(String characterId) {
    if (isEquipped) {
      throw StateError(
        'Equipment is already equipped by $equippedByCharacterId',
      );
    }

    isEquipped = true;
    equippedByCharacterId = characterId;

    recordEvent(
      EquipmentEquipped(
        equipmentId: id.value,
        characterId: characterId,
        slot: slot.name,
        equipmentName: name,
      ),
    );
  }

  /// Unequips this item
  void unequip() {
    if (!isEquipped) {
      throw StateError('Equipment is not equipped');
    }

    final previousOwner = equippedByCharacterId;
    isEquipped = false;
    equippedByCharacterId = null;

    recordEvent(
      EquipmentUnequipped(
        equipmentId: id.value,
        characterId: previousOwner!,
        slot: slot.name,
      ),
    );
  }

  /// Inserts a gem into an empty socket
  void insertGem(int socketIndex, Gem gem) {
    if (socketIndex < 0 || socketIndex >= sockets.length) {
      throw ArgumentError('Invalid socket index: $socketIndex');
    }

    final socket = sockets[socketIndex];
    if (socket.isFilled) {
      throw StateError('Socket $socketIndex is already filled');
    }

    sockets[socketIndex] = socket.insertGem(gem);

    recordEvent(
      GemInserted(
        equipmentId: id.value,
        socketIndex: socketIndex,
        gemName: gem.name,
        gemType: gem.type.name,
      ),
    );
  }

  /// Removes a gem from a socket
  Gem removeGem(int socketIndex) {
    if (socketIndex < 0 || socketIndex >= sockets.length) {
      throw ArgumentError('Invalid socket index: $socketIndex');
    }

    final socket = sockets[socketIndex];
    if (!socket.isFilled || socket.gem == null) {
      throw StateError('Socket $socketIndex is empty');
    }

    final gem = socket.gem!;
    sockets[socketIndex] = socket.removeGem();

    recordEvent(
      GemRemoved(
        equipmentId: id.value,
        socketIndex: socketIndex,
        gemName: gem.name,
      ),
    );

    return gem;
  }

  /// Upgrades the item level and improves stats
  void upgrade(int newLevel) {
    if (newLevel <= itemLevel) {
      throw ArgumentError('New level must be higher than current level');
    }

    final oldLevel = itemLevel;
    itemLevel = newLevel;

    // Improve base stats based on level increase
    final multiplier = newLevel / oldLevel;
    baseStats = EquipmentStats(
      attack: (baseStats.attack * multiplier).round(),
      defense: (baseStats.defense * multiplier).round(),
      health: (baseStats.health * multiplier).round(),
      mana: (baseStats.mana * multiplier).round(),
    );

    recordEvent(
      EquipmentUpgraded(
        equipmentId: id.value,
        oldLevel: oldLevel,
        newLevel: newLevel,
      ),
    );
  }

  /// Checks if this equipment is better than another
  bool isBetterThan(Equipment other) {
    if (slot != other.slot) {
      throw ArgumentError('Cannot compare equipment of different slots');
    }
    return totalStats.totalStats > other.totalStats.totalStats;
  }

  // === Properties ===

  bool get isEmpty => name == 'None' && itemLevel == 0;
  bool get canBeEnchanted => rarity.canBeEnchanted;
  bool get isLegendary => rarity.isLegendary;
  int get filledSocketCount => sockets.where((s) => s.isFilled).length;
  int get emptySocketCount => sockets.where((s) => !s.isFilled).length;
  bool get hasEmptySockets => emptySocketCount > 0;

  @override
  String toString() =>
      'Equipment($name, ${slot.displayName}, ${rarity.displayName}, L$itemLevel)';

  // === Private Helpers ===

  static List<GemSocket> _createEmptySockets(int count) {
    return List.generate(count, (_) => GemSocket.empty());
  }

  static EquipmentStats _generateBaseStats(
    EquipmentSlot slot,
    EquipmentRarity rarity,
    int level,
  ) {
    final rarityMultiplier = rarity.starCount;
    final levelMultiplier = level * 0.5;

    if (slot.isWeapon) {
      return EquipmentStats(
        attack: (5 * rarityMultiplier + levelMultiplier).round(),
      );
    } else if (slot.isArmor) {
      return EquipmentStats(
        defense: (3 * rarityMultiplier + levelMultiplier * 0.6).round(),
        health: (10 * rarityMultiplier + levelMultiplier).round(),
      );
    } else {
      // Fun slots - smaller bonuses
      return EquipmentStats(
        attack: (2 * rarityMultiplier).round(),
        defense: (1 * rarityMultiplier).round(),
      );
    }
  }
}
