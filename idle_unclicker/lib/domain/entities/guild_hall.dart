import '../events/meta_progression_events.dart';
import 'aggregate_root.dart';
import 'character.dart';
import '../value_objects/meta_progression.dart';

/// Aggregate Root: GuildHall
///
/// The meta-progression hub that unlocks after first ascension.
/// Manages rooms, echoes, and provides permanent bonuses.
class GuildHall extends AggregateRoot {
  final String gameStateId; // Links to GameState

  List<Room> rooms;
  List<EchoNPC> echoes;
  bool isUnlocked;
  int totalGoldInvested;
  String playstylePreference; // 'aggressive', 'defensive', 'loot', 'balanced'
  DateTime createdAt;

  GuildHall({
    required this.gameStateId,
    List<Room>? rooms,
    List<EchoNPC>? echoes,
    this.isUnlocked = false,
    this.totalGoldInvested = 0,
    this.playstylePreference = 'balanced',
    required this.createdAt,
  }) : rooms = rooms ?? _initializeRooms(),
       echoes = echoes ?? [];

  /// Factory to create new Guild Hall (locked until first ascension)
  factory GuildHall.create(String gameStateId) {
    return GuildHall(
      gameStateId: gameStateId,
      isUnlocked: false,
      createdAt: DateTime.now(),
    );
  }

  // === Domain Behaviors ===

  /// Unlock the Guild Hall
  void unlock(int ascensionNumber) {
    if (isUnlocked) {
      throw StateError('Guild Hall is already unlocked');
    }

    isUnlocked = true;

    recordEvent(
      GuildHallUnlocked(
        gameStateId: gameStateId,
        ascensionNumber: ascensionNumber,
      ),
    );
  }

  /// Upgrade a room
  void upgradeRoom(RoomType type, int goldCost) {
    if (!isUnlocked) {
      throw StateError('Guild Hall is locked');
    }

    final roomIndex = rooms.indexWhere((r) => r.type == type);
    if (roomIndex == -1) {
      throw ArgumentError('Room type $type not found');
    }

    final currentRoom = rooms[roomIndex];
    if (currentRoom.isMaxed) {
      throw StateError('${type.displayName} is already at max level');
    }

    final oldLevel = currentRoom.level;
    rooms[roomIndex] = currentRoom.upgrade();
    totalGoldInvested += goldCost;

    recordEvent(
      RoomUpgraded(
        gameStateId: gameStateId,
        roomType: type.name,
        oldLevel: oldLevel,
        newLevel: rooms[roomIndex].level,
        cost: goldCost,
      ),
    );
  }

  /// Add an Echo NPC from a character
  void addEcho(Character character, {required String fate}) {
    if (!isUnlocked) {
      throw StateError('Guild Hall is locked');
    }

    final echo = EchoNPC(
      name: character.identity.name,
      race: character.identity.race,
      characterClass: character.identity.characterClass,
      level: character.level,
      fate: fate,
      createdAt: DateTime.now(),
    );

    echoes.add(echo);

    recordEvent(
      EchoNPCCreated(
        gameStateId: gameStateId,
        echoName: echo.name,
        race: echo.race,
        characterClass: echo.characterClass,
        level: echo.level,
        fate: echo.fate,
      ),
    );
  }

  /// Get a room by type
  Room? getRoom(RoomType type) {
    try {
      return rooms.firstWhere((room) => room.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Get total bonuses from all rooms
  GuildHallBonuses get totalBonuses {
    double skillXpMultiplier = 1.0;
    double goldFindMultiplier = 1.0;
    double bestiaryRateMultiplier = 1.0;
    double equipmentDropMultiplier = 1.0;

    for (final room in rooms) {
      switch (room.type) {
        case RoomType.trainingHall:
          skillXpMultiplier += room.bonus;
          break;
        case RoomType.treasury:
          goldFindMultiplier += room.bonus;
          break;
        case RoomType.library:
          bestiaryRateMultiplier += room.bonus;
          break;
        case RoomType.smithy:
          equipmentDropMultiplier += room.bonus;
          break;
      }
    }

    return GuildHallBonuses(
      skillXpMultiplier: skillXpMultiplier,
      goldFindMultiplier: goldFindMultiplier,
      bestiaryRateMultiplier: bestiaryRateMultiplier,
      equipmentDropMultiplier: equipmentDropMultiplier,
    );
  }

  /// Get total room levels
  int get totalRoomLevels => rooms.fold(0, (sum, room) => sum + room.level);

  /// Get the highest level room
  Room? get highestLevelRoom {
    if (rooms.isEmpty) return null;
    return rooms.reduce((a, b) => a.level > b.level ? a : b);
  }

  /// Check if a room can be upgraded
  bool canUpgradeRoom(RoomType type, int availableGold) {
    if (!isUnlocked) return false;

    final room = getRoom(type);
    if (room == null || room.isMaxed) return false;

    return availableGold >= room.upgradeCost;
  }

  /// Get upgrade cost for a room
  int getUpgradeCost(RoomType type) {
    final room = getRoom(type);
    return room?.upgradeCost ?? 0;
  }

  /// Get the most upgraded room type
  RoomType? get dominantRoomType {
    if (rooms.isEmpty) return null;
    return rooms.reduce((a, b) => a.level > b.level ? a : b).type;
  }

  // === Properties ===

  bool get hasEchoes => echoes.isNotEmpty;
  int get echoCount => echoes.length;
  int get maxedRoomsCount => rooms.where((r) => r.isMaxed).length;

  /// Calculate room upgrade completion percentage
  double get completionPercentage {
    final maxPossible = rooms.length * Room.maxLevel;
    return (totalRoomLevels / maxPossible) * 100;
  }

  @override
  String toString() =>
      'GuildHall($totalRoomLevels total levels, $echoCount echoes, ${completionPercentage.toStringAsFixed(1)}% complete)';

  // === Private Helpers ===

  static List<Room> _initializeRooms() {
    return [
      const Room(type: RoomType.trainingHall),
      const Room(type: RoomType.treasury),
      const Room(type: RoomType.library),
      const Room(type: RoomType.smithy),
    ];
  }
}

/// Value object representing Guild Hall bonuses
class GuildHallBonuses {
  final double skillXpMultiplier;
  final double goldFindMultiplier;
  final double bestiaryRateMultiplier;
  final double equipmentDropMultiplier;

  const GuildHallBonuses({
    required this.skillXpMultiplier,
    required this.goldFindMultiplier,
    required this.bestiaryRateMultiplier,
    required this.equipmentDropMultiplier,
  });

  Map<String, double> toMap() => {
    'skillXpMultiplier': skillXpMultiplier,
    'goldFindMultiplier': goldFindMultiplier,
    'bestiaryRateMultiplier': bestiaryRateMultiplier,
    'equipmentDropMultiplier': equipmentDropMultiplier,
  };

  @override
  String toString() =>
      'GuildHallBonuses(Skill:${skillXpMultiplier.toStringAsFixed(2)}x, '
      'Gold:${goldFindMultiplier.toStringAsFixed(2)}x, '
      'Bestiary:${bestiaryRateMultiplier.toStringAsFixed(2)}x, '
      'Drops:${equipmentDropMultiplier.toStringAsFixed(2)}x)';
}
